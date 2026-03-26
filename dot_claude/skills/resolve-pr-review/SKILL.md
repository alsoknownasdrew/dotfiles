---
name: resolve-pr-review
description: Use when the user asks to address, fix, or resolve PR review comments on the current branch. Triggers on "fix PR comments", "address review", "resolve review feedback", or after a code review bot posts feedback.
---

# Resolve PR Review

Address the latest PR review comment with atomic commits, push fixes, and mark previous comments as outdated.

## Workflow

```dot
digraph resolve {
  rankdir=TB;
  node [shape=box];

  identify [label="1. Identify PR & latest comment"];
  categorize [label="2. Categorize & group issues"];
  parallel [label="3. Dispatch parallel agents\n(one per independent fix)", shape=parallelogram];
  collect [label="4. Collect results, apply sequentially"];
  test [label="5. Run full test suite"];
  review [label="6. Deep code review\n(3 parallel review agents)", shape=parallelogram];
  fix_review [label="7. Fix review findings"];
  minimize_push [label="8. Minimize comments + push"];

  identify -> categorize -> parallel -> collect -> test;
  test -> collect [label="failing — fix in main context"];
  test -> review [label="passing"];
  review -> fix_review [label="issues found"];
  review -> minimize_push [label="clean"];
  fix_review -> test [label="re-test"];
}
```

## Step 1: Identify PR and Latest Review Feedback

GitHub stores review feedback in **three separate locations**. You must check all three to find the latest review:

```bash
# Get PR for current branch
gh pr view --json number,title,url,headRefName

# 1. Issue comments — top-level PR comments (e.g., manual "Code Review" posts)
gh api repos/{owner}/{repo}/issues/{pr_number}/comments \
  --jq '.[] | {id, node_id, type: "issue_comment", created_at: .created_at, user: .user.login, body: (.body | split("\n")[0][:100])}'

# 2. PR reviews — review bodies submitted via GitHub's review UI or bots
#    These have a separate API endpoint and are often missed!
gh api repos/{owner}/{repo}/pulls/{pr_number}/reviews \
  --jq '.[] | select(.body != "" and .body != null) | {id, node_id, type: "review", state: .state, submitted_at: .submitted_at, user: .user.login, body: (.body | split("\n")[0][:100])}'

# 3. Inline review comments — line-level annotations on specific files
gh api repos/{owner}/{repo}/pulls/{pr_number}/comments \
  --jq '.[] | {id, node_id, type: "inline_comment", created_at: .created_at, user: .user.login, path: .path, body: (.body | split("\n")[0][:100])}'
```

**Determine the latest review to address:** Compare timestamps across all three sources. The most recent non-bot, non-status-update entry is the one to address. Filter out:
- Bot status comments (e.g., "Claude finished @user's task")
- Dismissed or retracted reviews
- Your own automated comments

**Fetch the full body** of the identified review:
```bash
# For issue comments:
gh api repos/{owner}/{repo}/issues/{pr_number}/comments/{comment_id} --jq '.body'

# For PR reviews:
gh api repos/{owner}/{repo}/pulls/{pr_number}/reviews/{review_id} --jq '.body'

# For inline comments:
gh api repos/{owner}/{repo}/pulls/{pr_number}/comments/{comment_id} --jq '.body'
```

**Important:** The three GitHub API endpoints for PR feedback:
- `issues/{pr}/comments` — top-level PR comments
- `pulls/{pr}/reviews` — review submissions (the body written when submitting a review)
- `pulls/{pr}/comments` — inline review comments on specific lines/files

## Step 2: Categorize and Group Issues

Read the latest review and classify each issue:

| Category | Action |
|----------|--------|
| Bug / incorrect behavior | Fix with code change + test |
| Misleading docs/JSDoc | Fix the wording |
| Latent inconsistency | Fix the root cause |
| Missing validation | Add validation + test |
| Lockfile / version mismatch | Regenerate with `npm install --package-lock-only` |
| Awareness-only observation | Skip — no code change needed |
| PR description nit | Update via `gh pr edit` if needed |

**Determine independence:** Issues that touch different files are independent. Issues touching the same file or where one fix depends on another's output are dependent and must be sequential.

## Step 3: Fix Issues in Parallel

**Dispatch one Agent per independent fix** using `isolation: "worktree"`. Each agent works in its own git worktree so there are no conflicts.

Each agent prompt must include:
- The specific review issue to fix (quote it verbatim)
- The file paths involved
- Whether to add/update tests
- Instruction to commit with this message format:

```
fix: <what changed> — <why>

<Optional body explaining the before/after behavior>

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>
```

**Example dispatch pattern:**

```
Agent 1 (worktree): "Fix clearCache JSDoc — change 'cancel' to 'complete but not populate cache' in src/features/client.ts"
Agent 2 (worktree): "Sort cleaned brand IDs in normalizeBrandIds for consistent API URLs in src/features/client.ts"
Agent 3 (worktree): "Add boolean validation in validateResponse + test in test/features-client.test.ts"
Agent 4 (worktree): "Run npm install --package-lock-only to sync package-lock.json version"
```

**Dependent fixes** (same file, or fix B relies on fix A) must go to the **same agent** or be applied sequentially in the main context.

## Step 4: Collect and Apply Results

Once all agents complete:
1. Cherry-pick or apply each agent's commit from its worktree branch into the main branch — one commit per fix, preserving atomic history
2. If agents touched the same file, apply in logical order and resolve any conflicts
3. Run the full test suite once after all fixes are applied

If tests fail, fix in the main context and create a new commit.

## Step 5: Deep Code Review (Before Push)

**This step prevents the fix-review-fix loop.** Before pushing, dispatch 3 parallel review agents to catch anything a reviewer would flag. Each runs in the main worktree (read-only, no isolation needed).

**Dispatch all 3 in a single message:**

| Agent | Subagent Type | Focus |
|-------|---------------|-------|
| Code simplicity | `compound-engineering:review:code-simplicity-reviewer` | Dead code, unnecessary complexity, YAGNI, formatting |
| Security | `compound-engineering:review:security-sentinel` | URL safety, input validation, type assertions, info leakage |
| Performance | `compound-engineering:review:performance-oracle` | Memory leaks, unbounded growth, cache correctness, promise handling |

Each agent should run `git diff main...HEAD -- src/ test/` to see the full PR diff, then read the complete changed files.

**Triage findings into 3 buckets:**

| Bucket | Action |
|--------|--------|
| Must fix | Bugs, CI failures (Prettier/lint), security issues, dead code |
| Should fix | Input validation gaps, missing test coverage, fragile patterns |
| Skip | Awareness-only, v-next candidates, theoretical edge cases |

**Fix all "must fix" and "should fix" items**, then re-run the test suite + `npm run doctor`. Only proceed to push when both are clean.

## Step 6: Minimize Previous Comments and Push

Do these in parallel — they are independent:

**Minimize all outdated feedback across all three endpoints:**

GitHub's `minimizeComment` GraphQL mutation works on any comment-like node (issue comments, PR reviews, and inline review comments) — use the same mutation for all three. Minimize everything except the latest entry from each endpoint.

```bash
# 1. Issue comments — minimize all except the latest
gh api repos/{owner}/{repo}/issues/{pr_number}/comments \
  --jq '.[:-1] | .[].node_id' | while read nid; do
  gh api graphql -f query="mutation { minimizeComment(input: {subjectId: \"$nid\", classifier: OUTDATED}) { minimizedComment { isMinimized } } }" --silent
done

# 2. PR reviews — minimize all non-empty reviews except the latest
gh api repos/{owner}/{repo}/pulls/{pr_number}/reviews \
  --jq '[.[] | select(.body != "" and .body != null) | .node_id] | .[:-1] | .[]' | while read nid; do
  gh api graphql -f query="mutation { minimizeComment(input: {subjectId: \"$nid\", classifier: OUTDATED}) { minimizedComment { isMinimized } } }" --silent
done

# 3. Inline review comments — minimize all except the latest
gh api repos/{owner}/{repo}/pulls/{pr_number}/comments \
  --jq '[.[] | .node_id] | .[:-1] | .[]' | while read nid; do
  gh api graphql -f query="mutation { minimizeComment(input: {subjectId: \"$nid\", classifier: OUTDATED}) { minimizedComment { isMinimized } } }" --silent
done
```

**Push:**
```bash
git push origin <branch-name>
```

## Common Mistakes

- **Only checking issue comments** — GitHub stores review feedback in THREE places: issue comments (`/issues/.../comments`), PR reviews (`/pulls/.../reviews`), and inline review comments (`/pulls/.../comments`). You must check all three or you will miss reviews submitted via GitHub's review UI or by bots that post review bodies. This is the most common cause of "no new review to address" false negatives.
- **Forgetting node_id** — the GraphQL `minimizeComment` mutation needs the `node_id`, not the numeric `id`
- **Amending commits instead of atomic** — each fix must be its own commit for clear review history
- **Sending dependent fixes to separate worktrees** — if two fixes touch the same file, they must be sequenced (same agent or main context)
- **Only minimizing issue comments** — the `minimizeComment` mutation works on PR reviews and inline comments too. You must minimize outdated entries from all three endpoints (`/issues/.../comments`, `/pulls/.../reviews`, `/pulls/.../comments`), not just issue comments. Forgetting PR reviews leaves a wall of stale bot reviews cluttering the PR.
- **Minimizing the latest comment** — only minimize comments *before* the one you're addressing
- **Skipping the deep review** — this is the most important step; without it you push fixes that create new review comments, looping indefinitely
- **Skipping the final test run** — always run the full suite after applying all worktree results, even if agents tested individually
- **Pushing before doctor passes** — always run `npm run doctor` (or equivalent) to catch formatting/lint/type issues before push
