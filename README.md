# afk-kit

Two-process toolkit for AI-assisted feature development: **plan** artifacts, then **build** autonomously. Includes governance templates, overnight session orchestration, quality gates, and a learning feedback loop.

## Quick Start

```bash
# 1. Clone and install
git clone https://github.com/bam-bam-pow/afk-kit.git ~/afk-kit
cd ~/afk-kit
./setup.sh

# 2. (Optional) Bootstrap governance templates into your project
./setup.sh --target-project ~/my-project

# 3. Plan a feature (interactive Claude Code session)
afk-plan --feature "My Feature"

# 4. Build it overnight (autonomous session)
afk-build --manifest ~/.afk/prd-sessions/<session>/handoff-manifest.json
```

Or paste the contents of `KICKOFF.md` into Claude Code to bootstrap everything in one step.

## How It Works

### Process 1: `afk-plan`

Creates all planning artifacts through an interactive Claude Code session:

1. **Intake** — Conversational Q&A to understand the feature
2. **Research** — Web + internal doc synthesis
3. **Draft PRD** — Product Requirements Document
4. **Draft EDD** — Engineering Design Document
5. **Red Team** — Find contradictions and gaps
6. **Finalize** — Package with CLAUDE.md sprint section

Outputs a **handoff manifest** (JSON) that connects to Process 2.

### Process 2: `afk-build`

Sets up the full development environment and launches an autonomous Claude Code session:

1. **Pre-flight** — Validate manifest, check tools
2. **Git** — Clone/pull, create feature branch
3. **Docker** — Start PostgreSQL, Redis, app containers
4. **Dependencies** — Install backend + frontend packages
5. **Migrations** — Run database migrations
6. **CLAUDE.md** — Configure project with sprint section
7. **Session init** — Generate overnight prompt, create tracking artifacts
8. **Launch** — Start Claude Code in autonomous mode

### Overnight Session Structure

The build orchestrator runs in phases with quality gates between each:

| Phase | Work | Agent | Parallel? |
|-------|------|-------|-----------|
| 0 | Setup, task breakdown, architecture | opus | No — PAUSE after |
| 1 | Database/schema/migrations | opus | No |
| 2 | Core models, auth, base API | opus | Limited |
| 3 | Feature modules | opus | Yes |
| 4 | Frontend components | opus | Yes |
| 5 | Integration tests | opus | Yes |
| 6 | Summary generation | opus | No |

Quality gates (lint, typecheck, test) run after each phase. Max 2 fix attempts before escalating.

### Ralph Loop (Process Resilience)

Overnight builds run inside a [Ralph Loop](https://ghuntley.com/ralph/) — a restart wrapper that keeps the build alive. If Claude exits for any reason (context exhaustion, crash, timeout), the loop automatically:

1. Commits uncommitted work as a WIP checkpoint
2. Restarts Claude with the same prompt
3. Claude reads `PROGRESS.md` + git history and picks up where it left off

The loop stops when `MORNING-BRIEFING.md` exists (build complete), `.pause-requested` exists (user pause), or max iterations is reached (default: 20).

Use `--no-loop` to disable (not recommended for overnight builds).

## Governance Templates

Use `./setup.sh --target-project PATH` to bootstrap these into any project:

- **CONSTITUTION.md** — Core principles and non-negotiables for AI agents and humans
- **ADR_TEMPLATE.md** — Architecture Decision Record format
- **COMMIT_TEMPLATE.md** — Structured commit message format
- **CLAUDE.md** — Project-specific instructions for Claude Code
- **.overnight-config** — Session settings (gate strictness, models, timeout)

## CLI Reference

### afk-plan

```
afk-plan [--feature NAME] [--project-dir PATH] [--repo-url URL]
             [--branch NAME] [--stack fullstack|backend|frontend]
             [--docker-profile NAME] [--non-interactive] [--dry-run]
```

### afk-build

```
afk-build [--manifest PATH] [--session SLUG]
              [--skip-docker] [--skip-git] [--skip-deps] [--skip-migrate]
              [--dry-run] [--no-launch] [--non-interactive]
```

### setup.sh

```
./setup.sh [--target-project PATH]
```

## Repo Structure

```
afk-kit/
├── .gitignore
├── README.md
├── setup.sh                          # Installer + project bootstrapper
├── .mcp.json.template                # MCP server config template
├── KICKOFF.md                        # Bootstrap prompt for Claude Code
│
├── bin/
│   ├── afk-plan                      # Process 1: planning
│   └── afk-build                     # Process 2: building
│
├── lib/
│   ├── common.sh                     # Logging, ask(), slugify()
│   ├── git-helpers.sh                # Clone, branch, pull
│   ├── docker-helpers.sh             # Compose validate, up, health
│   └── manifest.sh                   # Handoff manifest R/W/validate
│
├── skills/
│   ├── prd-assistant/                # PRD creation workflow
│   │   ├── SKILL.md
│   │   └── templates/ (4 files)
│   ├── build-orchestrator/           # Overnight build management
│   │   ├── SKILL.md
│   │   ├── overnight-prompt-template.md
│   │   └── prompts/                  # Subagent, phase-0, resume templates
│   ├── qa-reviewer/                  # Visual QA with multi-agent review
│   │   └── SKILL.md
│   ├── quality-tracker/SKILL.md      # Type error logging
│   ├── corrections-log/SKILL.md      # Post-build learning
│   ├── session-monitor/SKILL.md      # Build monitoring
│   └── research-agent/SKILL.md       # Web research
│
├── templates/
│   ├── CLAUDE.md.template            # Starter CLAUDE.md
│   ├── CONSTITUTION.md               # Governance doc (templatized)
│   ├── ADR_TEMPLATE.md               # Decision records template
│   ├── COMMIT_TEMPLATE.md            # Commit message format
│   ├── overnight-config.template     # Session settings
│   ├── docker-compose.*.yml (3)      # Docker profiles
│   ├── Dockerfile.fastapi
│   └── Dockerfile.react-vite
│
├── learning/
│   └── QUALITY-PATTERNS.md           # Seed file for corrections learning
│
└── tests/fixtures/
    └── sample-manifest.json
```

## Skills

Skills are copied to `~/.afk/skills/` during setup and available to Claude Code sessions.

| Skill | Purpose |
|-------|---------|
| **prd-assistant** | Interactive PRD/EDD creation with design reference collection |
| **build-orchestrator** | Overnight session lifecycle, quality gates, complexity router, subagent coordination |
| **qa-reviewer** | Visual QA: screenshots + parallel Branding/CEO/CFO agent reviews |
| **quality-tracker** | Log type errors, lint fixes, test failures |
| **corrections-log** | Analyze post-build human corrections, extract patterns |
| **session-monitor** | Real-time session status, pause/resume/abort |
| **research-agent** | Web research for competitive analysis, best practices |

## Docker Profiles

| Profile | Services |
|---------|----------|
| `fastapi-react` | PostgreSQL + Redis + FastAPI + Vite |
| `fastapi-only` | PostgreSQL + Redis + FastAPI |
| `react-only` | Vite dev server |

## Handoff Manifest

The JSON contract between Process 1 and Process 2:

```json
{
  "version": "1.0",
  "feature": { "name": "...", "slug": "..." },
  "project": { "directory": "...", "repo_url": "...", "branch": "..." },
  "stack": { "has_backend": true, "has_frontend": true, "docker_profile": "fastapi-react" },
  "artifacts": { "session_dir": "...", "prd": "...", "edd": "...", "..." : "..." },
  "status": "ready_for_build"
}
```

## Design Decisions

- **Dual-mode input:** Every prompt has a CLI flag alternative via `ask()`. Scripts work interactively and non-interactively.
- **`--dry-run` everywhere:** Every mutating operation checks `$DRY_RUN` first.
- **Symlink install:** Updating the repo updates the commands.
- **Process 2 is pure shell:** No Claude involvement until the final launch step. Git, Docker, deps, migrations are deterministic.
- **Skills are portable:** Skill files work standalone or as part of the afk-kit workflow.
- **Quality gates between phases:** Never build on broken foundations. Lint, typecheck, test after every phase.
- **Use the best model:** Opus 4.6 (1M context) for everything. Better reasoning = fewer errors = faster builds.
- **Checkpoint aggressively:** Every completed unit of work gets committed and logged to PROGRESS.md.

## Requirements

- bash 4+
- python3 (for JSON handling)
- git
- docker + docker compose
- [Claude Code CLI](https://claude.ai/code) (`claude` command)
