# Commit Message Template

Use this format for all commits. Copy and fill in the sections.

---

```
[TYPE]: Brief description (50 chars or less)

[Optional body - wrap at 72 chars]
- What changed
- Why it changed (if not obvious from the diff)
- Any caveats or known issues

[Optional footer]
Refs: #LINEAR-123
Breaking: [description if applicable]
```

---

## Types

| Type | When to Use |
|------|-------------|
| `feat:` | New feature for the user |
| `fix:` | Bug fix |
| `refactor:` | Code restructuring (no behavior change) |
| `docs:` | Documentation only changes |
| `test:` | Adding or updating tests |
| `chore:` | Maintenance, deps, config, CI |
| `style:` | Formatting, linting (no code change) |
| `perf:` | Performance improvement |

---

## Examples

### Feature
```
feat: Add transaction categorization via Claude API

- Implements /api/categorize endpoint
- Uses few-shot examples from user corrections
- Stores confidence score with each categorization

Refs: #LIN-42
```

### Bug Fix
```
fix: Prevent duplicate transactions on sync

- Added external_id uniqueness check before insert
- Existing duplicates will be ignored (not deleted)

Refs: #LIN-58
```

### Refactor
```
refactor: Extract tax calculation logic to dedicated service

- Moved from routes to app/services/tax_calculator.py
- No behavior change, all tests pass
- Prep for adding quarterly estimate feature
```

### Documentation
```
docs: Add ADR for SQLite over Postgres decision

- Documents single-user rationale
- Links to benchmark data
```

### Chore
```
chore: Update dependencies to latest stable

- fastapi 0.109.0 -> 0.110.0
- pydantic 2.5 -> 2.6
- All tests pass
```

### Breaking Change
```
feat: Restructure API response format

- All endpoints now return {data, meta} envelope
- Pagination moved to meta.pagination

Breaking: Clients must update to handle new response shape
Refs: #LIN-99
```

---

## Rules

1. **Subject line**: Imperative mood ("Add feature" not "Added feature")
2. **Length**: Subject ≤50 chars, body wrapped at 72
3. **No period** at end of subject line
4. **Blank line** between subject and body
5. **Reference issues** when applicable
6. **One logical change** per commit

---

## Pre-Commit Checklist

Before writing your commit message:
- [ ] Tests pass
- [ ] Linting passes
- [ ] No debug code left in
- [ ] No hardcoded secrets
- [ ] Changes are cohesive (one logical unit)
