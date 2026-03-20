# CLAUDE.md Sprint Section Template

This template is used by prd-assistant to generate the "Current Sprint" section for CLAUDE.md after a PRD is finalized.

---

## Template

```markdown
# 🎯 CURRENT SPRINT: {{FEATURE_NAME}}

> **Priority:** This section takes precedence over general patterns when building {{FEATURE_NAME}} features.

## Document Hierarchy

Read these documents in order. Higher priority wins on conflicts:

1. **{{FEATURE_SLUG}}-CONFLICT-RESOLUTION.md** — CANONICAL (resolves all conflicts)
2. **CLAUDE.md** — Development patterns (this file)
3. **{{FEATURE_SLUG}}-EDD.md** — Technical design
4. **{{FEATURE_SLUG}}-PRD.md** — Product requirements

## {{FEATURE_NAME}} Structure

{{#if backend_structure}}
Create new app at `backend/src/apps/{{app_name}}/`:

```
src/apps/{{app_name}}/
├── __init__.py
├── models/
{{#each models}}
│   ├── {{this}}.py
{{/each}}
├── schemas/
│   ├── __init__.py
│   ├── common.py
│   ├── requests.py
│   └── responses.py
├── services/
{{#each services}}
│   ├── {{this}}_services.py
{{/each}}
├── router.py
└── enums.py
```
{{/if}}

{{#if frontend_structure}}
## Frontend Routes

Create routes at `frontend/src/routes/_app/`:

```
_app/
{{#each routes}}
├── {{this}}
{{/each}}
```

Components at `frontend/src/components/{{component_dir}}/`:
```
{{component_dir}}/
{{#each components}}
├── {{this}}
{{/each}}
```
{{/if}}

---

## 🤖 Autonomous Build Mode

### Phase Structure

Build in this order. Complete each phase before moving to the next.

| Phase | Focus | Checkpoint |
|-------|-------|------------|
{{#each phases}}
| {{this.number}} | **{{this.name}}** | {{this.checkpoint}} |
{{/each}}

### Checkpoint Protocol

After completing each phase:

1. **Run tests** (if any exist for that phase)
2. **Verify manually** — can you perform the core action?
3. **Update task status** — mark Claude task complete (and Linear ticket if configured)
4. **Commit with phase tag** — `git commit -m "feat({{app_name}}): Phase X - description"`
5. **Log progress** — Update MORNING-BRIEFING.md with:
   - What was completed
   - Any deviations from spec
   - Any blockers for next phase

### If Stuck

1. **Check Context7** for library documentation — don't guess at APIs
2. **Check existing apps** for patterns — refer to similar apps as references
3. **If blocked >15 minutes**, mark task as blocked with details and move to next parallelizable work
4. **Never leave broken code** — revert if a phase can't complete cleanly

---

## Key Decisions (Do Not Re-decide)

| Decision | Choice | Rationale |
|----------|--------|-----------|
{{#each decisions}}
| {{this.decision}} | {{this.choice}} | {{this.rationale}} |
{{/each}}

---

## Definition of Done

The {{FEATURE_NAME}} is done when:

{{#each definition_of_done}}
- [ ] {{this}}
{{/each}}

---

*End of {{FEATURE_NAME}} Sprint Section*
```

---

## Generation Instructions

When generating this section from a finalized PRD:

### 1. Extract Feature Info

```
FEATURE_NAME: From PRD title
FEATURE_SLUG: kebab-case version (e.g., "my-feature", "text-banking")
app_name: snake_case for backend (e.g., "people", "text_banking")
```

### 2. Extract Structure from EDD

- Backend models from EDD Data Model section
- Services from EDD Service Layer section
- Frontend routes from EDD Frontend Implementation section
- Components from EDD file structure

### 3. Generate Phases from PRD

Map PRD sections to build phases:
1. Backend Models & Migrations
2. Backend Schemas & Enums
3. Backend Services (CRUD)
4. Backend Router & Auth
5. Frontend Types & API Service
6. Frontend Main View
7. Frontend Detail View
8. Frontend Actions (modals, forms)
9. Backend Additional Features
10. Frontend Additional Features
11. Import/Export (if applicable)
12. Bulk Operations (if applicable)
13. Polish & Integration

### 4. Extract Decisions

Pull from:
- PRD "Key Decisions" section if exists
- Conflict Resolution Patch resolutions
- Any inline decisions marked in PRD/EDD

### 5. Extract Definition of Done

Pull from:
- PRD "Success Metrics" section
- PRD user stories (convert to checklist)
- Any explicit DoD in PRD

---

## Example Output

For a User Dashboard PRD:

```markdown
# 🎯 CURRENT SPRINT: User Dashboard MVP

> **Priority:** This section takes precedence over general patterns when building User Dashboard features.

## Document Hierarchy

1. **USER-DASHBOARD-CONFLICT-RESOLUTION.md** — CANONICAL
2. **CLAUDE.md** — Development patterns
3. **USER-DASHBOARD-EDD.md** — Technical design
4. **USER-DASHBOARD-PRD.md** — Product requirements

## Dashboard App Structure

Create new app at `backend/src/apps/dashboard/`:

```
src/apps/dashboard/
├── __init__.py
├── models/
│   ├── widget.py
│   ├── layout.py
│   └── preference.py
├── schemas/
│   ├── __init__.py
│   ├── common.py
│   ├── requests.py
│   └── responses.py
├── services/
│   ├── widget_services.py
│   ├── layout_services.py
│   └── preference_services.py
├── router.py
└── enums.py
```

## Key Decisions (Do Not Re-decide)

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Widget detail route | `/dashboard?widget={id}` | Preserves layout context |
| Layout storage | JSON column | Flexible widget arrangement |
| Default widgets | activity + metrics | Most common use case |

## Definition of Done

- [ ] Can view dashboard with default widget layout
- [ ] Can add and remove widgets
- [ ] Can view widget detail in slide-out panel
- [ ] Can customize layout with drag-and-drop
- [ ] Can save layout preferences per user
```
