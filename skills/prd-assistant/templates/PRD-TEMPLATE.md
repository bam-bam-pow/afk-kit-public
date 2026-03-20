# {Feature Name} - Product Requirements Document

> **Version:** 1.0  
> **Last Updated:** {YYYY-MM-DD}  
> **Owner:** {OWNER_NAME} ({OWNER_ROLE})
> **Status:** {Draft | Ready for Review | Ready for Development}

---

## Executive Summary

{2-3 sentences max. What are we building and why? This should be understandable by anyone in the company.}

**Design Philosophy:** {One sentence that guides all decisions. Example: "Build for the user who needs it today, not the enterprise that might need it someday."}

---

## Goals & Success Metrics

### Primary Goals

1. **{Goal 1}** - {Why it matters}
2. **{Goal 2}** - {Why it matters}
3. **{Goal 3}** - {Why it matters}

### Success Metrics

| Metric | Target | How to Measure |
|--------|--------|----------------|
| {metric 1} | {specific number} | {measurement method} |
| {metric 2} | {specific number} | {measurement method} |
| {metric 3} | {specific number} | {measurement method} |

---

## User Stories

### Core User Stories (P0)

| ID | As a... | I want to... | So that... | Acceptance Criteria |
|----|---------|--------------|------------|---------------------|
| US-1 | {user type} | {action} | {benefit} | {testable criteria} |
| US-2 | {user type} | {action} | {benefit} | {testable criteria} |

### Secondary User Stories (P1)

| ID | As a... | I want to... | So that... | Acceptance Criteria |
|----|---------|--------------|------------|---------------------|
| US-X | {user type} | {action} | {benefit} | {testable criteria} |

### Future Considerations (P2)

| ID | As a... | I want to... | So that... | Notes |
|----|---------|--------------|------------|-------|
| US-Y | {user type} | {action} | {benefit} | {why deferred} |

---

## Information Architecture

### Route Structure

```
/{feature}                    → Main view (default)
/{feature}?view={variant}     → Alternate view
/{feature}/{action}           → Action flow (e.g., import)
/{feature}?selected={id}      → Detail panel open
```

### Navigation Changes

**Sidebar Update:**
- Add: `/{feature}` (new section)
- Remove: {any deprecated routes}
- Keep: {related routes}

**Redirect Legacy Routes:**
- `/{old-route}` → `/{feature}?{params}`

---

## Data Model

### {Primary Entity} Entity

```typescript
interface {Entity} {
  // Identity
  id: string;
  {field}: {type};
  
  // Core Fields
  {field}: {type};
  {field}?: {type};  // Optional
  
  // Relationships
  {relationId}: string;
  
  // System Fields
  tenantId: string;
  createdAt: Date;
  updatedAt: Date;
  createdBy: string;
  deletedAt?: Date;  // Soft delete
}
```

### Enums

```typescript
type {EntityStatus} = 
  | '{value1}'   // {description}
  | '{value2}'   // {description}
  | '{value3}';  // {description}

type {EntityType} = 
  | '{value1}'   // {description}
  | '{value2}';  // {description}
```

### {Secondary Entity} Entity

```typescript
interface {SecondaryEntity} {
  id: string;
  {primaryEntityId}: string;
  // ... fields
}
```

---

## UI Specifications

### Design References

> Visual inspiration collected during intake. These are the north star for UI implementation.

| # | Reference | What To Emulate | Applies To |
|---|-----------|----------------|------------|
| 1 | {source — Mobbin, screenshot, app URL} | {specific pattern} | {which screens} |
| 2 | {source} | {pattern} | {screens} |

**Design Direction:**
- Layout: {e.g., sidebar nav, card grid, split panel}
- Tone: {e.g., minimal, bold, enterprise}
- Key interactions: {e.g., inline editing, drag-and-drop}

> The build phase MUST reference these when implementing frontend components.
> QA review agents will check output against these references.

### 1. {Main View Name}

**Route:** `/{feature}`

**Layout:** {Description of layout - sidebar + main, full width, etc.}

```
┌─────────────────────────────────────────────────────────────────────────┐
│  {Header}                                           [+ Action Button]   │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  {ASCII wireframe of the main view}                                     │
│                                                                         │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐                     │
│  │  Element 1  │  │  Element 2  │  │  Element 3  │                     │
│  └─────────────┘  └─────────────┘  └─────────────┘                     │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  Main content area                                              │   │
│  │                                                                 │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

**Behavior:**

| Action | Result |
|--------|--------|
| {user action} | {system response} |
| {user action} | {system response} |

### 2. {Detail View / Panel Name}

**Trigger:** {How user gets here}

```
┌────────────────────────────────────────────┐
│ {Panel Header}                        [×]  │
├────────────────────────────────────────────┤
│                                            │
│  {ASCII wireframe of detail view}          │
│                                            │
└────────────────────────────────────────────┘
```

**Sections:**

1. **{Section 1}** - {What it contains}
2. **{Section 2}** - {What it contains}
3. **{Section 3}** - {What it contains}

### 3. {Action Modal / Flow Name}

**Trigger:** {Button click, keyboard shortcut, etc.}

**Layout:** {Modal size, position}

```
┌────────────────────────────────────────────┐
│ {Modal Title}                         [×]  │
├────────────────────────────────────────────┤
│                                            │
│  {Form field 1}                            │
│  ┌────────────────────────────────────┐    │
│  │                                    │    │
│  └────────────────────────────────────┘    │
│                                            │
│  {Form field 2}                            │
│  ┌────────────────────────────────────┐    │
│  │                                    │    │
│  └────────────────────────────────────┘    │
│                                            │
│         [Cancel]  [Primary Action]         │
│                                            │
└────────────────────────────────────────────┘
```

**Validation:**
- {Field 1}: {validation rules}
- {Field 2}: {validation rules}

**Behavior:**

| Action | Result |
|--------|--------|
| {action} | {result} |

---

## API Specifications

### Endpoints Overview

```
# CRUD
GET     /api/v1/{feature}                    # List with filters, pagination
GET     /api/v1/{feature}/{id}               # Get single item
POST    /api/v1/{feature}                    # Create item
PATCH   /api/v1/{feature}/{id}               # Update item
DELETE  /api/v1/{feature}/{id}               # Soft delete

# Bulk Operations
POST    /api/v1/{feature}/bulk-{action}      # Bulk action

# Related Resources
GET     /api/v1/{feature}/{id}/{related}     # List related items
POST    /api/v1/{feature}/{id}/{related}     # Add related item
```

### Query Parameters (List Endpoint)

| Parameter | Type | Description |
|-----------|------|-------------|
| `search` | string | Full-text search on {fields} |
| `{filter}` | string | Filter by {field} |
| `sort` | string | Sort field (prefix `-` for desc) |
| `page` | number | Page number (default: 1) |
| `limit` | number | Items per page (default: 25, max: 100) |

---

## Validation Rules

### {Entity} Creation

| Field | Required | Validation |
|-------|----------|------------|
| {field1} | Yes | {rules} |
| {field2} | Conditional | Required if {condition} |
| {field3} | No | {format rules if any} |

**Special Validation:**
```
A {entity} is valid if AT LEAST ONE of these conditions is met:
1. {condition 1}
2. {condition 2}
3. {condition 3}
```

---

## Edge Cases & Error Handling

| Scenario | Expected Behavior |
|----------|-------------------|
| {edge case 1} | {how to handle} |
| {edge case 2} | {how to handle} |
| {error condition} | {error message + recovery} |

---

## Non-Functional Requirements

### Performance

| Metric | Target |
|--------|--------|
| List load time | < {X}ms |
| Search response | < {X}ms |
| Action completion | < {X}ms |

### Accessibility

- {A11y requirement 1}
- {A11y requirement 2}

### Mobile

- {Mobile consideration 1}
- {Mobile consideration 2}

---

## Dependencies

### Internal

- {Feature X} must be complete
- {API Y} must be available

### External

- {Service Z} integration (if applicable)

### Stubs (Out of Scope)

- {Integration A} - stubbed, full implementation in future
- {Feature B} - UI present but non-functional

---

## Rollout Plan

### Phase 1: Internal Testing

- {What's included}
- {Who tests}

### Phase 2: Beta

- {What's included}
- {Who gets access}

### Phase 3: GA

- {Full rollout details}
- {Migration from old flows}

---

## Open Questions

> Items needing stakeholder input before development

1. **{Question}** - {Context, options being considered}
2. **{Question}** - {Context, options being considered}

---

## Appendix

### A. Glossary

| Term | Definition |
|------|------------|
| {term} | {definition} |

### B. Research References

- {Source 1}: {Key finding}
- {Source 2}: {Key finding}

### C. Rejected Alternatives

| Alternative | Why Rejected |
|-------------|--------------|
| {option} | {reason} |

---

*End of PRD*
