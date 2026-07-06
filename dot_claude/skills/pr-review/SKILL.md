---
name: af:pr-review
description: Review a PR and post findings as a PR comment. Use when the user says "review PR", "pr-review", "review and comment", or wants to review someone else's PR.
---

# PR Review & Comment

Review a PR using compound-engineering's multi-agent review and post findings as a PR comment.

## Input
- PR number (required). Ask if not provided.

## Steps

### 1. Review
Invoke skill: `compound-engineering:ce-review`

Review the PR. Categorize each finding by priority:
- **P1** — Bugs, security issues, data loss risks, broken functionality
- **P2** — Logic errors, missing edge cases, schema mismatches, test gaps
- **P3** — Style, naming, minor improvements, nice-to-haves

### 2. Post PR Comment
Post the review as a single PR comment with findings organized by priority (P1 first, then P2, then P3).

### 3. Minimize outdated comments
Minimize any previous review comments from this workflow that are now outdated.

### 4. Approve if good
A PR is **good** when it has **no P1 and no P2 findings** (P3-only or clean).

- If good: approve on GitHub with `gh pr review <number> --repo <owner/repo> --approve --body "<one-line why>"`.
- If it has any P1 or P2: do **not** approve. Leave the findings comment only.

Approval uses the caller's `gh` auth, so the PR is approved as the current user.

## Rules
- Always post the review as a PR comment — do not wait to be asked.
- If there are no findings, post a short approval comment.
- Only approve when there are no P1/P2 findings. Never merge.
