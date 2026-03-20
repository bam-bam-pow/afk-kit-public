---
name: quality-tracker
description: Tracks type errors, lint fixes, and quality issues during Claude Code builds. Automatically logs to TYPE-ERRORS.md. Use when fixing type errors, running lint, or encountering build failures.
---

# Quality Tracker Skill

You track and log quality issues encountered during development. This data feeds the learning loop.

## When to Log

Log to TYPE-ERRORS.md whenever you:
- Fix a TypeScript/type error
- Auto-fix a lint error
- Fix a test failure
- Resolve an import/export mismatch
- Handle a runtime error

## Log Format

Append to `~/.afk/builds/{date}/TYPE-ERRORS.md`:

```markdown
| {HH:MM} | {relative/path/to/file.ts} | {error message} | {category} | {what you did} |
```

## Categories

Use these exact category names:

| Category | When to Use |
|----------|-------------|
| `frontend-backend-sync` | Type mismatch between API response and frontend interface |
| `import-export` | Missing import, wrong export, circular dependency |
| `null-safety` | Accessing property on potentially null/undefined |
| `async-handling` | Promise not awaited, missing async, race condition |
| `state-management` | React state issues, stale closure, missing dependency |
| `schema-mismatch` | Pydantic/Zod schema doesn't match actual data |
| `migration` | Database migration issue |
| `lint` | ESLint/Biome auto-fixed |
| `test-failure` | Test failed and was fixed |
| `runtime` | Error only caught at runtime |

## Examples

```markdown
| 02:15 | frontend/src/components/items/item-detail.tsx | Property 'notes' does not exist on type 'ItemResponse' | frontend-backend-sync | Added notes?: string to ItemResponse interface |
| 02:18 | backend/src/apps/items/schemas/responses.py | Field 'tags' missing Optional wrapper | null-safety | Changed tags: list[Tag] to tags: Optional[list[Tag]] = None |
| 02:23 | frontend/src/routes/_app/_.items.tsx | Cannot find module '@/components/items/tag-filter' | import-export | Fixed import path, was missing /index |
| 02:31 | frontend/src/hooks/use-items-query.ts | 'data' is possibly undefined | null-safety | Added optional chaining: data?.items ?? [] |
| 02:45 | backend/src/apps/items/services/item_services.py | Incompatible return type | schema-mismatch | Service returned ORM model instead of schema |
```

## Detailed Logging (For Complex Fixes)

For errors that required significant debugging, also append to session.log:

```
[TYPE-ERROR-DETAIL] {timestamp}
File: {path}
Error: {full error message}
Context: {what you were trying to do}
Root cause: {why it happened}
Fix applied: {what you changed}
Prevention: {how to avoid in future}
---
```

## Integration with Build Orchestrator

The build-orchestrator skill will:
1. Read TYPE-ERRORS.md at end of session
2. Include count in morning briefing
3. Surface patterns to corrections-log skill

## Quick Reference Commands

During a build, you can use these internal commands:

```bash
# View error count by category
grep -E "^\|" ~/.afk/builds/$(date +%Y-%m-%d)/TYPE-ERRORS.md | cut -d'|' -f5 | sort | uniq -c

# View most recent errors
tail -10 ~/.afk/builds/$(date +%Y-%m-%d)/TYPE-ERRORS.md
```

## Pattern Detection

If you notice the same type of error 3+ times in one session, add a note:

```markdown
## Recurring Pattern Detected

**Pattern:** Frontend interfaces not updated after backend schema changes
**Occurrences:** 4 times this session
**Files affected:** item-detail.tsx, item-list.tsx, create-modal.tsx, tag-filter.tsx
**Suggested fix:** Add a pre-commit hook or script to regenerate frontend types from backend schemas
```

This helps the corrections-log skill identify systemic issues.
