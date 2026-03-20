# {Feature Name} - Engineering Design Document

**Date:** {YYYY-MM-DD}  
**Author:** {name}  
**Status:** {Draft | Review | Approved}  
**PRD Reference:** {link to PRD}

---

## Overview

### Summary

{1-2 paragraphs summarizing what we're building technically.}

### Goals

1. {Technical goal 1}
2. {Technical goal 2}
3. {Technical goal 3}

### Non-Goals

- {What we're explicitly not doing in this implementation}

---

## Architecture Overview

### System Context

```
┌─────────────────────────────────────────────────────────────────────┐
│                           Frontend (React)                          │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐                 │
│  │  Component  │  │  Component  │  │  Component  │                 │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘                 │
│         └────────────────┼────────────────┘                         │
│                          ▼                                          │
│                   TanStack Query                                    │
│                          │                                          │
└──────────────────────────┼──────────────────────────────────────────┘
                           │ HTTP/REST
                           ▼
┌──────────────────────────────────────────────────────────────────────┐
│                          Backend (FastAPI)                           │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐                  │
│  │   Router    │→ │  Services   │→ │   Models    │                  │
│  └─────────────┘  └─────────────┘  └──────┬──────┘                  │
│                                           │                          │
└───────────────────────────────────────────┼──────────────────────────┘
                                            │ SQLAlchemy
                                            ▼
                                     ┌─────────────┐
                                     │  PostgreSQL │
                                     └─────────────┘
```

### Component Diagram

{More detailed diagram of the specific feature components}

---

## Data Model

### New Tables

#### `{table_name}` Table

```python
class {ModelName}(Base):
    """
    {Description of what this model represents}
    """
    __tablename__ = "{table_name}"
    
    # Primary Key
    id = Column(Integer, primary_key=True, autoincrement=True)
    
    # Core Fields
    {field_name} = Column({Type}, nullable={True|False})
    {field_name} = Column({Type}, nullable={True|False}, default={value})
    
    # Foreign Keys
    {relation}_id = Column(Integer, ForeignKey("{table}.id"), nullable=False)
    tenant_id = Column(Integer, ForeignKey("tenants.id"), nullable=False)
    
    # Timestamps
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=False)
    deleted_at = Column(DateTime(timezone=True), nullable=True)
    
    # Relationships
    {relation} = relationship("{RelatedModel}", back_populates="{back_ref}")
    tenant = relationship("Tenant", back_populates="{table_name}")
    
    def __repr__(self):
        return f"<{ModelName}(id={self.id}, {key_field}={self.{key_field}})>"
```

**Indexes:**
```python
# Add to model or migration
Index("ix_{table}_{field}", {ModelName}.{field})
Index("ix_{table}_tenant_{field}", {ModelName}.tenant_id, {ModelName}.{field})
```

#### `{second_table_name}` Table

{Repeat pattern for additional tables}

### Enums

```python
from enum import Enum

class {EnumName}(str, Enum):
    """
    {Description}
    """
    {VALUE_1} = "{value-1}"    # {description}
    {VALUE_2} = "{value-2}"    # {description}
    {VALUE_3} = "{value-3}"    # {description}
```

### Migration Plan

```bash
# Step 1: Create migration
alembic revision --autogenerate -m "add {feature} tables"

# Step 2: Review generated migration
# - Verify column types
# - Verify foreign keys
# - Verify indexes
# - Add any data migrations if needed

# Step 3: Apply migration
alembic upgrade head
```

**Migration Checklist:**
- [ ] All foreign keys have `ondelete` behavior specified
- [ ] Indexes created for frequently queried fields
- [ ] No breaking changes to existing tables
- [ ] Rollback tested (`alembic downgrade -1`)

---

## API Design

### Endpoint Specifications

#### `GET /api/v1/{feature}`

**Purpose:** List {entities} with filtering and pagination

**Auth:** `get_auth_context` (tenant-scoped)

**Query Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `search` | string | null | Search in {fields} |
| `{filter}` | string | null | Filter by {field} |
| `page` | int | 1 | Page number |
| `limit` | int | 25 | Items per page (max 100) |
| `sort` | string | "-created_at" | Sort field |

**Response:**
```json
{
  "data": {
    "items": [
      {
        "id": 1,
        "{field}": "{value}",
        // ... all response fields
      }
    ],
    "total": 100,
    "page": 1,
    "limit": 25,
    "pages": 4
  },
  "success": true,
  "message": null
}
```

#### `POST /api/v1/{feature}`

**Purpose:** Create a new {entity}

**Auth:** `get_auth_context` (tenant-scoped)

**Request Body:**
```json
{
  "{field}": "{value}",        // Required
  "{optional_field}": "{value}" // Optional
}
```

**Validation:**
```python
class {Entity}Create(BaseModel):
    {field}: str = Field(..., min_length=1, max_length=255, description="{description}")
    {optional_field}: Optional[str] = Field(None, description="{description}")
    
    @model_validator(mode='after')
    def validate_{rule}(self):
        # Custom validation logic
        return self
```

**Response:** `201 Created`
```json
{
  "data": {
    "id": 1,
    // ... created entity
  },
  "success": true,
  "message": "{Entity} created successfully"
}
```

**Errors:**
| Code | Condition | Message |
|------|-----------|---------|
| 400 | Validation failed | "{field}: {error}" |
| 409 | Duplicate | "{Entity} with this {field} already exists" |

#### `PATCH /api/v1/{feature}/{id}`

{Continue pattern for all endpoints}

#### `POST /api/v1/{feature}/bulk-{action}`

**Purpose:** Bulk {action} on multiple {entities}

**Request Body:**
```json
{
  "ids": [1, 2, 3],
  "{action_params}": "{value}"
}
```

**Response:**
```json
{
  "data": {
    "success_count": 2,
    "failed_count": 1,
    "failed_ids": [3],
    "errors": [
      {"id": 3, "error": "Not found"}
    ]
  },
  "success": true
}
```

---

## Pydantic Schemas

### Common Schemas

```python
# schemas/common.py

from pydantic import BaseModel, ConfigDict, Field
from typing import Optional
from datetime import datetime

class {Entity}Base(BaseModel):
    """Shared fields for {entity}"""
    {field}: str = Field(..., description="{description}")
    {optional_field}: Optional[str] = Field(None, description="{description}")

class {Entity}Response({Entity}Base):
    """Response schema for {entity}"""
    model_config = ConfigDict(from_attributes=True)
    
    id: int
    tenant_id: int
    created_at: datetime
    updated_at: datetime
```

### Request Schemas

```python
# schemas/requests.py

class {Entity}Create({Entity}Base):
    """Create a new {entity}"""
    pass

class {Entity}Update(BaseModel):
    """Update an existing {entity} (all fields optional)"""
    {field}: Optional[str] = None
    
class {Entity}Filters(BaseModel):
    """Query filters for listing {entities}"""
    search: Optional[str] = None
    {filter}: Optional[str] = None
```

### Response Schemas

```python
# schemas/responses.py

class {Entity}ListResponse(BaseModel):
    """Paginated list of {entities}"""
    items: list[{Entity}Response]
    total: int
    page: int
    limit: int
    pages: int
```

---

## Service Layer

### {entity}_services.py

```python
from sqlalchemy import select, func
from sqlalchemy.orm import Session
from fastapi import HTTPException, status

from src.apps.{feature}.models import {Model}
from src.apps.{feature}.schemas import {Entity}Create, {Entity}Response
from src.core.helpers.pagination import QueryPaginator

def get_{entity}(db: Session, {entity}_id: int, tenant_id: int) -> {Entity}Response:
    """
    Get a single {entity} by ID.
    
    Raises:
        HTTPException 404: {Entity} not found
    """
    stmt = select({Model}).where(
        {Model}.id == {entity}_id,
        {Model}.tenant_id == tenant_id,
        {Model}.deleted_at.is_(None)
    )
    {entity} = db.execute(stmt).scalar_one_or_none()
    
    if not {entity}:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="{Entity} not found"
        )
    
    return {Entity}Response.model_validate({entity})

def list_{entities}(
    db: Session,
    tenant_id: int,
    filters: {Entity}Filters,
    page: int = 1,
    limit: int = 25
) -> dict:
    """
    List {entities} with filtering and pagination.
    """
    stmt = select({Model}).where(
        {Model}.tenant_id == tenant_id,
        {Model}.deleted_at.is_(None)
    )
    
    # Apply filters
    if filters.search:
        search_term = f"%{filters.search}%"
        stmt = stmt.where(
            {Model}.{searchable_field}.ilike(search_term)
        )
    
    if filters.{filter}:
        stmt = stmt.where({Model}.{filter} == filters.{filter})
    
    # Paginate
    paginator = QueryPaginator(
        query=stmt,
        schema={Entity}Response,
        db=db,
        page=page,
        limit=limit
    )
    
    return paginator.paginate()

def create_{entity}(
    db: Session,
    data: {Entity}Create,
    tenant_id: int,
    created_by: int
) -> {Entity}Response:
    """
    Create a new {entity}.
    
    Raises:
        HTTPException 409: Duplicate {entity}
    """
    # Check for duplicates if needed
    # ...
    
    {entity} = {Model}(
        **data.model_dump(),
        tenant_id=tenant_id,
        created_by=created_by
    )
    
    db.add({entity})
    db.commit()
    db.refresh({entity})
    
    return {Entity}Response.model_validate({entity})

# Continue with update, delete, bulk operations...
```

---

## Frontend Implementation

### File Structure

```
frontend/src/
├── routes/
│   └── _app/
│       ├── _.{feature}.tsx          # Main page
│       └── _.{feature}.{action}.tsx # Action pages
├── components/
│   └── {feature}/
│       ├── {feature}-list.tsx
│       ├── {feature}-detail.tsx
│       ├── {feature}-form.tsx
│       └── {feature}-filters.tsx
├── api/
│   └── {feature}-api.ts
└── types/
    └── {feature}.ts
```

### TypeScript Types

```typescript
// types/{feature}.ts

export interface {Entity} {
  id: number;
  {field}: string;
  {optionalField}?: string;
  tenantId: number;
  createdAt: string;
  updatedAt: string;
}

export type {Entity}Stage = '{value1}' | '{value2}' | '{value3}';

export interface {Entity}Filters {
  search?: string;
  {filter}?: string;
}

export interface {Entity}CreateRequest {
  {field}: string;
  {optionalField}?: string;
}
```

### API Service

```typescript
// api/{feature}-api.ts

import { apiClient } from '@/lib/api-client';
import type { {Entity}, {Entity}Filters, {Entity}CreateRequest } from '@/types/{feature}';

export const {feature}Api = {
  list: (filters: {Entity}Filters, page = 1, limit = 25) =>
    apiClient.get<PaginatedResponse<{Entity}>>('/api/v1/{feature}', {
      params: { ...filters, page, limit }
    }),
    
  get: (id: number) =>
    apiClient.get<{Entity}>(`/api/v1/{feature}/${id}`),
    
  create: (data: {Entity}CreateRequest) =>
    apiClient.post<{Entity}>('/api/v1/{feature}', data),
    
  update: (id: number, data: Partial<{Entity}CreateRequest>) =>
    apiClient.patch<{Entity}>(`/api/v1/{feature}/${id}`, data),
    
  delete: (id: number) =>
    apiClient.delete(`/api/v1/{feature}/${id}`),
};
```

### React Query Hooks

```typescript
// hooks/use-{feature}.ts

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { {feature}Api } from '@/api/{feature}-api';

export function use{Entities}(filters: {Entity}Filters) {
  return useQuery({
    queryKey: ['{feature}', filters],
    queryFn: () => {feature}Api.list(filters),
  });
}

export function use{Entity}(id: number) {
  return useQuery({
    queryKey: ['{feature}', id],
    queryFn: () => {feature}Api.get(id),
    enabled: !!id,
  });
}

export function useCreate{Entity}() {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: {feature}Api.create,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['{feature}'] });
    },
  });
}
```

---

## Auth & Security

### Endpoint Authorization

| Endpoint | Auth Dependency | Scope |
|----------|----------------|-------|
| `GET /api/v1/{feature}` | `get_auth_context` | Tenant members |
| `POST /api/v1/{feature}` | `get_auth_context` | Owner, Staff |
| `PATCH /api/v1/{feature}/{id}` | `get_auth_context` | Owner, Staff |
| `DELETE /api/v1/{feature}/{id}` | `get_auth_context` | Owner only |

### Data Access Rules

```python
# All queries MUST include tenant_id filter
stmt = select({Model}).where(
    {Model}.tenant_id == context.tenant_id,  # REQUIRED
    {Model}.deleted_at.is_(None)
)
```

### Input Validation

- All string inputs trimmed and validated for length
- Phone numbers normalized to E.164
- Emails validated and lowercased
- IDs validated as integers

---

## Testing Strategy

### Unit Tests

```python
# tests/unit/test_{feature}_services.py

def test_create_{entity}_success(db_session, mock_tenant):
    data = {Entity}Create({field}="{value}")
    result = create_{entity}(db_session, data, mock_tenant.id, 1)
    
    assert result.id is not None
    assert result.{field} == "{value}"

def test_create_{entity}_duplicate_fails(db_session, existing_{entity}):
    # Test duplicate handling
    pass
```

### Integration Tests

```python
# tests/integration/test_{feature}_api.py

def test_list_{entities}_requires_auth(client):
    response = client.get("/api/v1/{feature}")
    assert response.status_code == 401

def test_list_{entities}_tenant_scoped(authenticated_client, other_tenant_{entity}):
    response = authenticated_client.get("/api/v1/{feature}")
    # Should not see other tenant's data
    assert other_tenant_{entity}.id not in [e["id"] for e in response.json()["data"]["items"]]
```

### E2E Tests

```typescript
// cypress/e2e/{feature}.cy.ts

describe('{Feature}', () => {
  it('can create a new {entity}', () => {
    cy.visit('/{feature}');
    cy.get('[data-testid="add-{entity}"]').click();
    cy.get('[data-testid="{field}-input"]').type('{value}');
    cy.get('[data-testid="save-{entity}"]').click();
    cy.contains('{value}').should('be.visible');
  });
});
```

---

## Dependencies

### Backend

| Package | Version | Purpose |
|---------|---------|---------|
| {package} | {x.y.z} | {why needed} |

### Frontend

| Package | Version | Purpose |
|---------|---------|---------|
| {package} | {x.y.z} | {why needed} |

---

## Deployment Considerations

### Database Migration

- [ ] Migration tested on staging
- [ ] Rollback plan documented
- [ ] No downtime expected (additive changes only)

### Feature Flags

```typescript
// If using feature flags
const {FEATURE}_ENABLED = process.env.NEXT_PUBLIC_{FEATURE}_ENABLED === 'true';
```

### Monitoring

- Add logging for {critical operations}
- Add metrics for {performance-sensitive endpoints}

---

## Open Questions

> Technical questions needing architect/team input

1. **{Question}** - {Context and options}
2. **{Question}** - {Context and options}

---

## Appendix

### A. Database Schema Diagram

{ERD if complex}

### B. State Machine Diagram

{If entity has states}

### C. Sequence Diagrams

{For complex flows}

---

*End of EDD*
