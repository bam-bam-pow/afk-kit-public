---
name: corrections-log
description: Analyzes post-build corrections to learn patterns and improve future builds. Use when user says "analyze my corrections", "learn from my fixes", "what did I fix", or "update patterns".
---

# Corrections Log Skill

You learn from post-build corrections to reduce repeated mistakes over time.

## Trigger Phrases

Activate when user says:
- "analyze my corrections"
- "learn from my fixes"
- "what did I fix"
- "what did I change"
- "update patterns"
- "analyze commits since build"

## Analysis Process

### Step 1: Find Build Commits vs Fix Commits

```bash
# Set REVIEWER to the team member who made corrections
# e.g., REVIEWER="Jane" or use git config: REVIEWER=$(git config user.name)
REVIEWER=${REVIEWER:-$(git config user.name)}

# Get the last Claude commit (during overnight build)
CLAUDE_COMMIT=$(git log --oneline --author="Claude" --since="12 hours ago" | tail -1 | cut -d' ' -f1)

# If no Claude commits, use commits before reviewer's fixes
if [ -z "$CLAUDE_COMMIT" ]; then
  # Find first reviewer commit today
  FIRST_REVIEWER=$(git log --oneline --author="$REVIEWER" --since="8 hours ago" | tail -1 | cut -d' ' -f1)
  CLAUDE_COMMIT="${FIRST_REVIEWER}^"
fi

# Get reviewer's fix commits
git log --oneline --author="$REVIEWER" --since="8 hours ago"
```

### Step 2: Get the Diff

```bash
# Full diff of reviewer's changes
git diff $CLAUDE_COMMIT..HEAD --stat
git diff $CLAUDE_COMMIT..HEAD
```

### Step 3: Categorize Each Change

For each file changed, analyze the diff and categorize:

| Category | Description | Example |
|----------|-------------|---------|
| `broken` | Code didn't work (errors, crashes, wrong behavior) | Fixed null pointer, fixed async bug |
| `design` | UI/UX didn't match expectations | Adjusted spacing, changed colors, resized components |
| `pattern` | Violated project conventions in CLAUDE.md | Used wrong import pattern, wrong file structure |
| `missing` | Feature was incomplete | Added missing validation, added edge case handling |
| `security` | Security or auth issue | Fixed exposed data, added permission check |

### Step 4: Log to CORRECTIONS.jsonl

Append one line per distinct correction to `~/.afk/builds/{date}/CORRECTIONS.jsonl`:

```json
{
  "timestamp": "{ISO-8601-timestamp}",
  "file": "frontend/src/components/items/tag-filter.tsx",
  "category": "design",
  "description": "Filter tags were too large, created visual clutter",
  "before_snippet": "<Badge className=\"px-4 py-2 text-sm\">",
  "after_snippet": "<Badge className=\"px-2 py-1 text-xs\">",
  "pattern_extracted": "Use smaller badge sizes (px-2 py-1 text-xs) for filter tags",
  "commit": "abc1234",
  "project": "my-project"
}
```

### Step 5: Extract Patterns

For each correction, determine if it represents a learnable pattern:

**Good patterns (add to QUALITY-PATTERNS.md):**
- Specific, actionable guidance
- Applies beyond this one instance
- Can be checked programmatically or by reading

**Not patterns (skip):**
- One-off bug fixes
- Data-specific issues
- External dependency problems

### Step 6: Update QUALITY-PATTERNS.md

File location: `~/.afk/learning/QUALITY-PATTERNS.md`

```markdown
# Quality Patterns — Auto-Generated
> Last updated: {timestamp}
> Based on {N} corrections across {M} builds

## Design Patterns (Team Standards)

### Component Sizing
- Keep slide-out panels at max-w-md (448px), not max-w-lg
- Modal max width: max-w-xl for forms, max-w-2xl for content
- [Source: {date}, detail-panel.tsx]

### Spacing
- Use gap-2 between form fields, not gap-4
- Section padding: p-4, not p-6
- [Source: {date}, create-modal.tsx]

## Code Patterns

### Frontend-Backend Sync
- After ANY backend schema change, regenerate frontend types
- Use `Optional[T] = None` for all nullable Pydantic fields
- Zod schemas must exactly mirror Pydantic (don't add extra fields)
- [Source: {date}, 4 occurrences]

### React Patterns
- Always provide default value for optional props: `prop = defaultValue`
- Use early return for loading/error states, not nested conditionals
- Destructure props at function signature, not inside body
- [Source: {date}, multiple files]

### Error Handling
- Always wrap async operations in try/catch
- Show user-friendly toast on error, log full error to console
- Never swallow errors silently
- [Source: {date}, item-services.ts]

## Anti-Patterns (Avoid These)

### TypeScript
- ❌ Don't use `any` — use `unknown` and narrow
- ❌ Don't use non-null assertion `!` — use proper null checks
- ❌ Don't inline object literals in JSX — extract to variables
- [Source: multiple builds]

### Styling
- ❌ Don't use inline styles — use Tailwind classes
- ❌ Don't mix spacing scales (gap-2 with gap-6)
- ❌ Don't use arbitrary values [w-137px] — use Tailwind scale
- [Source: {date}, various]

### Architecture
- ❌ Don't create abstractions "for future flexibility"
- ❌ Don't add state that could be derived
- ❌ Don't split components until there's actual reuse
- [Source: CLAUDE.md, CONSTITUTION.md]

## Project-Specific Rules

### Your Project
- {Entity} validation: {your validation rules}
- API paths use kebab-case: `/api/v1/follow-ups` not `/api/v1/followups`
- Phone numbers stored in E.164 format with leading `+`
- [Source: project CONFLICT-RESOLUTION-PATCH.md]
```

### Step 7: Report to User

Report to the user:

```
📚 Corrections analyzed!

Found {N} commits with {M} changes.

By category:
• Design: {n} fixes
• Broken: {n} fixes  
• Pattern: {n} fixes
• Missing: {n} fixes

New patterns extracted: {count}
{list of new patterns, 1 line each}

Updated QUALITY-PATTERNS.md ✅

Reply "patterns" to review all, "reject {description}" to remove one.
```

## User Commands

### `patterns`
Show full contents of QUALITY-PATTERNS.md

### `reject {pattern description}`
Remove a pattern from QUALITY-PATTERNS.md if the team disagrees with the extraction.

### `history`
Show summary of all corrections across builds:
```bash
cat ~/.afk/learning/corrections-history.jsonl | \
  jq -r '.category' | sort | uniq -c | sort -rn
```

### `corrections {date}`
Show corrections from a specific build date.

## Maintenance

### Weekly Pattern Review

Prompt the team weekly:
```
📋 Weekly pattern review

You have {N} patterns across {categories}.

Top 5 most-triggered patterns:
1. {pattern} — triggered {n} times
2. ...

Any patterns to prune or refine?
Reply "review" to see all, or "prune" to clean up.
```

### Pattern Consolidation

If similar patterns exist, consolidate:
```
Before:
- Use gap-2 for form fields
- Use small spacing for form fields
- Keep form fields compact

After:
- Use `gap-2` between form fields consistently
```

## Integration

This skill works with:
- `build-orchestrator` — Loads patterns into build context
- `quality-tracker` — Compares logged errors to extracted patterns
- `session-monitor` — Reports pattern usage in status updates
