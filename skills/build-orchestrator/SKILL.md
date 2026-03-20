---
name: build-orchestrator
description: Orchestrates autonomous AFK development sessions with Claude Code. Use when user says "start build", "overnight build", "kick off the build", "begin AFK session", or "start AFK session". Manages session lifecycle, quality gates, subagent coordination, task tracking, and artifact generation. Works with checkpoint/resume handling and morning summary generation.
---

# Build Orchestrator Skill

You are the build orchestrator for autonomous Claude Code AFK sessions. Your job is to initialize, monitor, and manage development builds with proper error handling, checkpointing, and quality gates.

## Task Tracking

**Primary: Claude Code tasks.** Use Claude's built-in task system (`TodoWrite`) to create, track, and complete tasks throughout the session. Every phase and sub-task should be a Claude task with status updates as you work.

**Optional: Linear.** If `LINEAR_PROJECT` is set in `.overnight-config`, also create Linear epics and issues to mirror task state. This gives persistent cross-session visibility. When Linear is not configured, Claude tasks + PROGRESS.md are sufficient.

## Core Principles

1. **Assume failure** — Design for recovery, not perfection
2. **Checkpoint aggressively** — Every completed unit of work gets recorded
3. **Use the best model** — Opus 4.6 for everything
4. **Gate between phases** — Never proceed with broken foundations
5. **Document decisions** — Morning-you needs to understand night-Claude's choices

## Trigger Phrases

Activate this skill when user says:
- "start overnight build for {project}"
- "start build"
- "kick off the build"
- "begin AFK session"
- "start AFK session"
- "overnight build"

## Phase Structure (Claude Opus 4.6)

All phases use Opus 4.6 (1M context) by default. Better reasoning = fewer errors = faster builds.

| Phase | Work Type | Agent | Parallelizable |
|-------|-----------|-------|----------------|
| 0 | Setup, task breakdown, architecture | opus | No — PAUSE after |
| 1 | Database/schema/migrations | opus | No |
| 2 | Core models, auth, base API | opus | Limited |
| 3 | Feature modules | opus | Yes |
| 4 | Frontend components | opus | Yes |
| 5 | Integration tests | opus | Yes |
| 6 | Summary generation | opus | No |

**Critical**: Phase 0 must PAUSE for human review before proceeding.

## Complexity Router

Before starting a build, assess the task complexity to determine the right process:

| Tier | Estimated Files | Process | Quality Gates |
|------|----------------|---------|---------------|
| **Iterate** | 1-5 | Change → lint → targeted test → commit | Lint only |
| **Quick** | 1-9 | Implement → typecheck → affected tests → commit → PR | TypeScript, affected tests |
| **Build** | 10-50 | Explore → TDD → smoke test → review → PR | Migration safety, integration, smoke test |
| **Full** | 50+ | Explore → architecture → HUMAN REVIEW → implement → test → release | Full test suite, backward compat |

**Escalation triggers** (override file count — always bump to at least Build tier):
- New database migration
- External API integration
- Auth/authorization changes
- New module or package creation
- Changes to user model or login flow → always **Full**

## Pre-Flight Checklist

Before starting ANY build, verify these in order:

1. **Project Directory Exists**
   ```bash
   ls $PROJECT_DIR/CLAUDE.md  # or specified project
   ```

2. **PRD Available**
   - Ask user: "Which PRD should I use? (filename or Google Drive link)"
   - If Drive link, use Google Drive MCP to fetch

3. **Engineering Spec Available**
   - Ask user: "Which engineering spec? (filename or Google Drive link)"
   - If Drive link, use Google Drive MCP to fetch

4. **Quality Patterns Loaded**
   ```bash
   cat ~/.afk/learning/QUALITY-PATTERNS.md 2>/dev/null || echo "No patterns yet"
   ```

5. **Create Session Directory**
   ```bash
   SESSION_DIR=~/.afk/builds/$(date +%Y-%m-%d)
   mkdir -p $SESSION_DIR
   ```

6. **Check for Linear** (optional)
   ```bash
   grep -q "^LINEAR_PROJECT=" .overnight-config 2>/dev/null && echo "Linear enabled"
   ```

## Session Initialization

### Step 1: Create Task Breakdown

Parse the PRD into discrete tasks and create Claude tasks for each phase:

```
Phase 0: Setup & architecture review
Phase 1: Database schema & migrations
Phase 2: Core API & auth
Phase 3: Feature A, Feature B, Feature C (parallel)
Phase 4: Component A, Component B, Component C (parallel)
Phase 5: Integration tests & polish
Phase 6: Morning summary
```

Mark dependencies between tasks (e.g., Phase 1 blocks Phase 2).

**If Linear is configured**, also create:
```
Epic: "{Project Name} - Overnight Build {Date}"
Labels: overnight-build, automated
```

With dependent issues mirroring the Claude task structure:
```
Epic: [Project] - Overnight Build [Date]
├── [Setup] Initialize (blocks all)
├── [Phase 1] Database (blocked by Setup)
├── [Phase 2] Core API (blocked by Phase 1)
├── [Phase 3] Features (blocked by Phase 2) ← parallelize
├── [Phase 4] Frontend (blocked by Phase 3) ← parallelize
└── [Phase 5] Integration (blocked by Phase 4)
```

### Step 2: Initialize Artifacts

Create these files in session directory:

**PROGRESS.md:**
```markdown
# Overnight Session Progress

**Project**: {name}
**Started**: {ISO timestamp}
**Status**: In Progress

## Completed
(none yet)

## In Progress
- [ ] Phase 0: Setup

## Blocked
(none yet)

## Session Log
| Time | Event | Details |
|------|-------|---------|
| {time} | Session started | |
```

**SKIPPED.md:**
```markdown
# Skipped Items - {Date}

> Items deferred during build. Review and prioritize.

## Skipped Tasks
| Task | Reason | Priority |
|------|--------|----------|

## Deferred Decisions

## Technical Debt Created
| File | Issue | Risk |
|------|-------|------|
```

**TYPE-ERRORS.md:**
```markdown
# Type Errors Fixed - {Date}

| Time | File | Error | Category | Fix |
|------|------|-------|----------|-----|
```

### Step 3: Start Claude Code Session

```bash
cd $PROJECT_DIR

# Create combined context file
cat CLAUDE.md > /tmp/build-context.md
echo -e "\n\n---\n\n# Quality Patterns\n" >> /tmp/build-context.md
cat ~/.afk/learning/QUALITY-PATTERNS.md >> /tmp/build-context.md 2>/dev/null

# Start Claude Code in AFK mode
claude --dangerously-skip-permissions \
  --print "$(cat /tmp/overnight-prompt.md)" \
  2>&1 | tee $SESSION_DIR/session.log &

echo $! > $SESSION_DIR/claude.pid
```

### Step 4: Confirm to User

```
Build started: {Project Name}

Session: ~/.afk/builds/{date}/
Tasks: {count} created

Commands:
  status  — Current progress
  skipped — Deferred items
  errors  — Type errors fixed
  pause   — Stop gracefully
  logs    — Tail output

First update in 30 minutes.
```

## Quality Gates

Run after each phase:

```bash
# Gate check sequence
npm run lint --fix    # Auto-fix what's possible
npm run typecheck     # Types must pass
npm test              # Tests must pass
```

**Max 2 fix attempts per gate.** On gate failure after 2 attempts:
1. Log to PROGRESS.md under "## Blocked"
2. Mark the Claude task as blocked
3. If Linear is configured, create issue with label "blocked"
4. Commit WIP with error context: `git commit -m "wip: [task] - blocked on [error]"`
5. Continue to next independent task

## Subagent Spawning

When spawning subagents for parallel work, always include:

```markdown
## Your Task
[specific task]

## Required Behaviors
- Mark Claude task as in-progress, then complete when done
- If Linear is configured: update issue status
- Use Context7 for 3rd party dependencies
- Check .claude/skills/ before implementation
- Follow build-orchestrator error protocol
- Update PROGRESS.md on completion

## Quality Requirements
- Pass lint, typecheck, tests
- Commit with descriptive message
```

Use these agent assignments (all Opus 4.6 by default):
- `model:opus color:purple` — Architecture, complex problems, summaries
- `model:opus color:green` — Features, components, CRUD
- `model:opus color:blue` — Database, migrations, core API
- `model:opus color:yellow` — Tests, polish, integration

See `prompts/subagent-spawn.md` for the full template.

## Error Handling Protocol

```
On blocking error:
1. Commit: git add -A && git commit -m "wip: [task] - blocked on [error]"
2. Update PROGRESS.md - move to Blocked with error details
3. Mark Claude task as blocked
4. If Linear is configured, create issue with "blocked" label
5. Continue with next independent task
```

## Monitoring Loop

Every 15 minutes while build is running:

1. **Check PROGRESS.md** for updates
2. **Check SKIPPED.md** for new entries
3. **Review Claude task list** for blocked items
4. **Count type errors** in TYPE-ERRORS.md

## Alert Conditions

Send immediate alert when:

1. **3+ tasks blocked**
2. **Session idle 30+ minutes**
3. **Build complete**

## User Commands

### `status`
Show current session state from PROGRESS.md and Claude task list

### `skipped`
Show contents of SKIPPED.md

### `errors`
Show contents of TYPE-ERRORS.md

### `pause`
```bash
# Signal graceful shutdown
touch $SESSION_DIR/.pause-requested
# Claude should check for this file between tasks
```

### `resume`
```bash
rm $SESSION_DIR/.pause-requested
# Restart Claude Code from checkpoint
```

### `abort`
```bash
kill $(cat $SESSION_DIR/claude.pid)
# Commit WIP
cd $PROJECT_DIR && git add -A && git commit -m "wip: build aborted by user"
```

### `logs`
```bash
tail -50 $SESSION_DIR/session.log
```

## End of Session

When build completes (all phases done OR 3+ blocked):

1. **Generate MORNING-BRIEFING.md**
2. **Mark all Claude tasks** with final status
3. **If Linear is configured**, update all tickets to final status
4. **Create PR** if not exists
5. **Send completion message**
6. **Clean up** PID file

Generate `MORNING_SUMMARY.md` when:
- All tasks complete, OR
- 3+ tasks blocked, OR
- Session exceeds 8 hours

## Ralph Loop Resilience

Overnight builds run inside a **Ralph Loop** — a restart wrapper that keeps the build alive.
If Claude exits for any reason (context exhaustion, crash, timeout, API error), the loop:

1. Commits any uncommitted work as a WIP checkpoint
2. Logs the restart to `ralph-loop.log` and `PROGRESS.md`
3. Waits 5 seconds (avoids rapid-fire loops on immediate crashes)
4. Restarts Claude with the exact same overnight prompt
5. Claude reads PROGRESS.md + git history and picks up where it left off

**The loop stops when:**
- `MORNING-BRIEFING.md` exists → build complete
- `.pause-requested` exists → user paused
- `.abort-requested` exists → user aborted
- Max iterations reached (default: 20, configurable via `--max-iterations`)

**On every restart, Claude MUST:**
1. Read PROGRESS.md to see what's done
2. Check git log for committed work
3. Skip completed phases
4. Resume from the last incomplete task
5. NOT re-do completed work

**Single-shot mode:** Use `--no-loop` to disable the Ralph Loop (not recommended for overnight builds).

## Error Recovery

If Claude Code crashes inside the Ralph Loop:
1. Loop commits any uncommitted work as WIP checkpoint
2. Loop logs restart to ralph-loop.log
3. Loop restarts Claude with same prompt
4. Claude reads PROGRESS.md and resumes from last incomplete task

## Prompt Templates

See the `prompts/` directory for ready-to-use templates:
- `prompts/subagent-spawn.md` — Spawning parallel task agents
- `prompts/phase-0-only.md` — Daytime setup before overnight run
- `prompts/resume-session.md` — Continuing interrupted sessions

## Decision Documentation

For architectural decisions made during a session:

```markdown
# ADR-NNN: [Title]

## Status
Accepted (by overnight-claude)

## Context
[Why needed]

## Decision
[What was decided]

## Consequences
[Impacts]

## Review Required
[ ] Confirm alignment with project goals
```

Store in `/docs/decisions/`.
