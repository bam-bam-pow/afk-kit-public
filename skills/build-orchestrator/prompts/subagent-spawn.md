# Subagent Spawn Template

Use this template when spawning subagents for parallel task execution during an AFK build session.

---

```markdown
Task: [TASK_NAME]
Agent: model:[sonnet|opus] color:[green|blue|yellow|purple]

## Instructions
[SPECIFIC_TASK_DESCRIPTION]

## Context
- Claude Task: [TASK_ID]
- Related files: [LIST_FILES]
- Dependencies: [LIST_DEPS - use Context7]

## Required Behaviors
1. Mark Claude task as in-progress immediately
2. If Linear is configured: update issue [ISSUE_ID] to "In Progress"
3. Use Context7 for: [SPECIFIC_DEPENDENCIES]
4. Check .claude/skills/ before implementation
5. Follow build-orchestrator error protocol on any block

## Deliverables
- [ ] [Deliverable 1]
- [ ] [Deliverable 2]
- [ ] Tests for new functionality

## Quality Requirements
- Lint passes
- Types check
- Tests pass

## On Completion
1. Mark Claude task as complete
2. If Linear is configured: update issue to "Done" with implementation notes
3. PROGRESS.md: Add to "## Completed" with commit hash
4. Commit: `feat([scope]): [description]`
```

---

## Agent Assignments (All Opus 4.6)

All agents use Opus 4.6 (1M context) by default. Better reasoning = fewer errors = faster builds.

| Agent | Task Type |
|-------|-----------|
| `model:opus color:purple` | Architecture, complex problems, summaries |
| `model:opus color:green` | Features, components, CRUD |
| `model:opus color:blue` | Database, migrations, core API |
| `model:opus color:yellow` | Tests, polish, integration |
