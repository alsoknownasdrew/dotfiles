# Sprint Review Card Generator

Generate a brutalist HTML sprint review page from local git commits, grouped by domain, topic, and type.

## Usage

```
/sprint-review [days]
```

**Examples:**
- `/sprint-review` — Last 14 days, current user
- `/sprint-review 7` — Last 7 days

## Instructions

### 1. Determine parameters

- Days: Use provided value or default to 14
- Calculate start date from today
- Author: resolve per-repo via `git -C "$repo" config user.name`

### 2. Gather commits

Scan all subdirectories with `.git` folders. For each repo, collect commits by the user within the date range:

```bash
for dir in */; do
  if [ -d "$dir/.git" ]; then
    project=$(basename "$dir")
    author=$(git -C "$dir" config user.name 2>/dev/null)
    if [ -n "$author" ]; then
      commits=$(git -C "$dir" log --author="$author" --since="{start_date}" --pretty=format:"%h|%ad|%s" --date=short 2>/dev/null)
      if [ -n "$commits" ]; then
        echo "=== $project ==="
        echo "$commits"
      fi
    fi
  fi
done
```

CRITICAL: Always use `--author` filter to only count the user's own commits.

### 3. Classify commits

For each commit, determine:

- **Type**: `feature` or `fix` — infer from conventional commit prefix (`feat` → feature, `fix`/`chore`/`refactor`/`style`/`test`/`docs` → fix). When no prefix, infer from the commit message content.
- **Project**: the subdirectory name (e.g., `analytics`, `core`, `admin-new`)
- **Domain**: a high-level work area that groups multiple projects working toward the same goal. Infer from commit content and which projects are touched together. Examples: "Analytics Pipeline", "Feature Flags", "Auth System". Aim for 2-6 domains.
- **Topic**: a sub-grouping within a domain representing a coherent thread of work. Examples: "Schema Unification", "Query Fixes", "Hardening", "Security". Aim for 2-4 topics per domain.

### 4. Consolidate commits into cards

Do NOT create one card per commit. Instead, group related commits into a single card with a human-readable summary:

- Multiple commits touching the same area for the same reason → one card
- The card title should describe WHAT was accomplished, not list commit messages
- Keep card titles to 1-2 lines max
- Each card shows: project name, summary title, type tag (feature/fix)

### 5. Generate HTML

Write `sprint-review.html` in the current directory using the design system below. Open it when done:

```bash
open sprint-review.html
```

## Design System

Brutalist aesthetic — warm paper background, bold typography, offset box-shadow hover effects.

### Fonts
- Google Fonts: `Space Mono` (monospace labels) + `Inter` (headings and body)

### Colors
```
Background:     #e8e4df  (warm paper)
Text:           #1a1a1a
Card bg:        #fff
Muted text:     #888, #999, #666
Domain numbers: #d0ccc7
Accent/feature: #2563eb  (blue)
Fix tag:        #1a1a1a  (black)
Accent bar:     #2563eb
```

### HTML Structure

```html
<header>
  <h1>Sprint<br>Review</h1>
  <div class="date">{date range}</div>
  <div class="accent-bar"></div>
</header>

<!-- Repeat per domain -->
<div class="domain">
  <div class="domain-header">
    <div class="domain-number">01</div>
    <div class="domain-title">{Domain<br>Name}</div>
  </div>

  <!-- Repeat per topic -->
  <div class="topic">
    <div class="topic-title">{Topic Name}</div>
    <div class="cards">

      <!-- Repeat per card -->
      <div class="card">
        <div class="card-top">
          <span class="project">{project}</span>
          <span class="tag feature|fix">feature|fix</span>
        </div>
        <div class="card-title">{Summary}</div>
      </div>

    </div>
  </div>
</div>
```

### CSS Reference

```css
@import url('https://fonts.googleapis.com/css2?family=Space+Mono:wght@400;700&family=Inter:wght@400;700;900&display=swap');

* { margin: 0; padding: 0; box-sizing: border-box; }

body {
  font-family: 'Inter', sans-serif;
  background: #e8e4df;
  color: #1a1a1a;
  padding: 3rem 2.5rem;
  min-height: 100vh;
}

header { margin-bottom: 4rem; }

h1 {
  font-size: clamp(3rem, 8vw, 6rem);
  font-weight: 900;
  text-transform: uppercase;
  letter-spacing: -3px;
  line-height: 0.9;
  margin-bottom: 0.5rem;
}

.date {
  font-family: 'Space Mono', monospace;
  font-size: 1rem;
  color: #888;
  letter-spacing: 2px;
}

.accent-bar {
  width: 120px;
  height: 8px;
  background: #2563eb;
  margin-top: 1rem;
}

.domain { margin-bottom: 4rem; }

.domain-header {
  display: flex;
  align-items: center;
  gap: 1rem;
  margin-bottom: 2rem;
}

.domain-number {
  font-family: 'Space Mono', monospace;
  font-size: 4rem;
  font-weight: 700;
  color: #d0ccc7;
  line-height: 1;
  user-select: none;
}

.domain-title {
  font-size: 1.8rem;
  font-weight: 900;
  text-transform: uppercase;
  letter-spacing: -1px;
  line-height: 1.1;
}

.topic {
  margin-bottom: 2rem;
  padding-left: 1.5rem;
  border-left: 4px solid #1a1a1a;
}

.topic-title {
  font-family: 'Space Mono', monospace;
  font-size: 0.75rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 3px;
  margin-bottom: 1rem;
  color: #666;
}

.cards {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(340px, 1fr));
  gap: 0.75rem;
}

.card {
  border: 2px solid #1a1a1a;
  padding: 1.25rem;
  background: #fff;
  transition: transform 0.15s ease, box-shadow 0.15s ease;
}

.card:hover {
  transform: translate(-3px, -3px);
  box-shadow: 6px 6px 0 #1a1a1a;
}

.card-top {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0.6rem;
}

.project {
  font-family: 'Space Mono', monospace;
  font-size: 0.65rem;
  color: #999;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 1.5px;
}

.card-title {
  font-size: 0.95rem;
  font-weight: 700;
  line-height: 1.4;
}

.tag {
  font-family: 'Space Mono', monospace;
  font-size: 0.6rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 1px;
  padding: 0.2rem 0.5rem;
  flex-shrink: 0;
}

.tag.feature { background: #2563eb; color: #fff; }
.tag.fix { background: #1a1a1a; color: #fff; }
```

## Notes

- This is for sprint review meetings — keep summaries clear and non-technical where possible
- No stats, no commit counts, no LOC — just what was accomplished
- Consolidate aggressively: 30 commits might become 8-12 cards
- Domain names should be meaningful to the team, not just project names
- The page must be self-contained (no external dependencies except Google Fonts)
- Requires local clones of repos to be present in the working directory
