# Constitution

**Owner:** {OWNER_NAME}
**Organization:** {ORG_NAME}
**Version:** 1.0
**Last Updated:** YYYY-MM-DD

This constitution governs all projects built under {ORG_NAME}. It establishes principles, practices, and non-negotiables that AI agents (Claude Code, autonomous workflows) and human developers must follow.

---

## Core Principles

### I. Simplicity Over Sophistication

We build for a single user or small team first. We favor:
- **Local-first architecture** — SQLite over Postgres when single-user
- **Monoliths over microservices** — until there's a real scaling need
- **Context stuffing over RAG** — especially for zero-to-one products
- **Fewer dependencies** — every package is a liability

A new developer (or Claude) should understand the entire system in under an hour.

### II. AI-Native Development

Our apps are built *with* and *for* AI:
- **LLM integration is a first-class concern** — not bolted on
- **Structured outputs** — use JSON schemas, typed responses
- **Context-aware design** — data models should be LLM-friendly
- **Skills over prompts** — encapsulate domain knowledge in reusable skills

When building AI features, prefer Claude API with explicit system prompts over magical abstractions.

### III. Pythonic Pragmatism

For backend services, we follow Python best practices:
- **FastAPI** for APIs — async, typed, auto-documented
- **Pydantic** for data validation — models are contracts
- **SQLite + SQLAlchemy** for local persistence (or Postgres when needed)
- **Type hints everywhere** — code should be self-documenting
- **Virtual environments** — always isolate dependencies

We don't over-engineer. A 200-line script that works beats a 2000-line "proper" architecture that doesn't ship.

### IV. Documentation as Code (NON-NEGOTIABLE)

All projects maintain a `/docs` folder with:

```
/docs
├── README.md              # Index and navigation
├── decisions/             # ADRs (Architecture Decision Records)
│   └── 001-example.md
├── product/               # Business logic, domain concepts
│   └── domain.md
└── api/                   # Endpoint contracts, integrations
```

**ADR Format:**
```markdown
# [Number]. [Title]

**Status:** Proposed | Accepted | Deprecated | Superseded
**Date:** YYYY-MM-DD

## Context
[What is the issue? Why does this decision need to be made?]

## Decision
[What is the change being proposed?]

## Consequences
[What are the results? Trade-offs?]
```

Documentation is written for future-you and for LLMs to consume as context.

### V. Task-Based Commits (NON-NEGOTIABLE)

Every completed task requires its own commit with a structured message:

**Commit Message Format:**
```
[TYPE] Brief description

- What changed
- Why it changed (if not obvious)

Refs: #task-id or issue link
```

**Types:**
- `feat:` — New feature
- `fix:` — Bug fix
- `refactor:` — Code change that neither fixes nor adds
- `docs:` — Documentation only
- `test:` — Adding or updating tests
- `chore:` — Maintenance, dependencies, config

**Commit Frequency:**
- After every completed task
- Before switching task categories (e.g., API → UI)
- When abandoning a plan (with reasoning in commit message)
- Before any `git push`

### VI. Test the Happy Path

We don't aim for 100% coverage. We aim for confidence:
- **Integration tests for critical paths** — user flows that must not break
- **Unit tests for complex logic** — calculations, transformations, edge cases
- **Smoke tests for deployments** — does it start? does the main route work?

Tests should be fast, repeatable, and use fixtures/factories for data.

For Python: `pytest` with clear test names that describe behavior.

---

## Project Structure

### Standard Layout (Python/FastAPI)

```
{PROJECT_DIR}/
├── .claude/                    # Claude Code configuration
│   └── settings.json
├── app/
│   ├── __init__.py
│   ├── main.py                 # FastAPI app entry
│   ├── api/                    # Route handlers
│   ├── models/                 # SQLAlchemy/Pydantic models
│   ├── services/               # Business logic
│   ├── skills/                 # LLM skills/prompts
│   └── utils/                  # Helpers
├── docs/                       # Documentation (see Principle IV)
│   ├── decisions/
│   ├── product/
│   └── api/
├── tests/
│   ├── conftest.py             # Fixtures
│   ├── test_api/
│   └── test_services/
├── scripts/                    # One-off scripts, migrations
├── .env.example                # Environment template
├── requirements.txt            # Or pyproject.toml
├── README.md
└── CONSTITUTION.md             # This file
```

### For Claude Code / Autonomous Workflows

Include these files at project root:

- **`CLAUDE.md`** — Project-specific instructions for Claude Code
- **`@fix_plan.md`** — Current task list (for autonomous loops)
- **`specs/requirements.md`** — Feature specs in markdown

---

## Integrations & Tooling

### Required
| Tool | Purpose |
|------|---------|
| Git + GitHub | Version control, PRs |
| Claude Code tasks | Primary task tracking during sessions |
| Claude Code | AI-assisted development |
| pytest | Testing |

### Preferred
| Tool | Purpose |
|------|---------|
| Discord | Team communication (webhooks for notifications) |
| Google Workspace | Docs, Drive (source of truth for non-code) |

### Avoided
| Tool | Why |
|------|-----|
| Complex ORMs | SQLAlchemy is enough; no Django ORM magic |
| Heavy frameworks | No FastAPI alternatives without good reason |
| Premature abstractions | No factory patterns until needed |
| External state | Redis/etc. only when SQLite won't work |

---

## AI Agent Instructions

When Claude Code or an autonomous agent works on this project:

### Always
1. Read `CONSTITUTION.md` and `CLAUDE.md` first
2. Check `/docs/decisions` for prior architectural choices
3. Commit after completing each task
4. Update `/docs` when making architectural decisions
5. Run tests before marking tasks complete
6. Use type hints in all Python code

### Never
1. Install packages without checking if stdlib can do it
2. Create abstractions "for future flexibility"
3. Skip commits to batch changes
4. Leave `TODO` comments without tracked tasks
5. Use `print()` for logging (use `logging` module)
6. Hardcode secrets or API keys

### When Stuck
1. Document the blocker in the current commit
2. Create a decision record if it's architectural
3. Ask for clarification rather than guessing
4. Check if simpler approach exists

---

## Governance

### Hierarchy
1. **This Constitution** — supersedes all other guidelines
2. **Project CLAUDE.md** — project-specific overrides
3. **ADRs in /docs/decisions** — documented exceptions
4. **Code comments** — inline justifications

### Amendments
To change this constitution:
1. Create an ADR documenting the proposed change
2. Implement in one project as a trial
3. If successful, update this document
4. Note the change in the version history below

### Deviations
Any deviation from this constitution must be:
1. Documented in an ADR with clear reasoning
2. Approved (by {OWNER_NAME}, or self-approved with documentation)
3. Scoped to the specific project, not global

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | YYYY-MM-DD | Initial constitution |

---

## Quick Reference

**Starting a new project:**
```bash
mkdir {PROJECT_DIR} && cd {PROJECT_DIR}
git init
# Copy CONSTITUTION.md, create /docs structure
# Set up venv, requirements.txt
# Create CLAUDE.md with project-specific context
```

**Before every commit:**
- [ ] Tests pass
- [ ] Type hints present
- [ ] Commit message follows format
- [ ] No hardcoded secrets

**Before every PR:**
- [ ] ADR created if architectural decision made
- [ ] /docs updated if behavior changed
- [ ] Task tracked (Claude task or issue linked)
