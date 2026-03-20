# AFK-Kit Kickoff

Paste this into Claude Code to bootstrap your project with afk-kit.

---

## Instructions

You are setting up a new project using the afk-kit framework. Follow these steps:

### Step 1: Install afk-kit

```bash
# Clone if not already present
if [ ! -d "$HOME/afk-kit" ]; then
  git clone https://github.com/bam-bam-pow/afk-kit.git ~/afk-kit
fi

# Run setup
cd ~/afk-kit && ./setup.sh
```

### Step 2: Bootstrap your project

```bash
cd ~/afk-kit
./setup.sh --target-project $PROJECT_DIR
```

This copies governance templates (CONSTITUTION.md, ADR template, commit format, CLAUDE.md, .overnight-config) into your project.

### Step 3: Customize governance files

Open the following files in your project and fill in the template variables:

1. **CONSTITUTION.md** — Replace `{OWNER_NAME}`, `{ORG_NAME}`, `{PROJECT_DIR}` with your values
2. **CLAUDE.md** — Replace `{PROJECT_NAME}`, `{STACK_DESCRIPTION}`, `{REPO_URL}` with your values
3. **.overnight-config** — Optionally set `LINEAR_PROJECT` if you want Linear integration

### Step 4: Plan your first feature

```bash
afk-plan --feature "Your Feature Name" --project-dir $PROJECT_DIR
```

This starts an interactive session to create:
- Product Requirements Document (PRD)
- Engineering Design Document (EDD)
- Conflict resolution patch
- CLAUDE.md sprint section
- Handoff manifest for the build phase

### Step 5: Build overnight

```bash
afk-build --manifest ~/.afk/prd-sessions/<your-session>/handoff-manifest.json
```

This sets up the dev environment (git, docker, deps, migrations) and launches Claude Code in autonomous mode with the build-orchestrator skill.

---

## Available Skills

After setup, these skills are available in `~/.afk/skills/`:

| Skill | Trigger | Purpose |
|-------|---------|---------|
| prd-assistant | "start PRD for {feature}" | Interactive PRD/EDD creation with design refs |
| build-orchestrator | "start build" | Overnight session management |
| qa-reviewer | "qa", "review the UI" | Screenshot capture + Branding/CEO/CFO review |
| quality-tracker | (automatic during builds) | Type error logging |
| corrections-log | "analyze my corrections" | Post-build learning |
| session-monitor | "status", "pause", "abort" | Build monitoring |
| research-agent | "research {topic}" | Web research |

## Quick Commands

```bash
# Check what's installed
ls ~/.afk/skills/

# Dry-run the plan process
afk-plan --feature "Test" --dry-run --non-interactive

# Dry-run the build process
afk-build --manifest tests/fixtures/sample-manifest.json --dry-run --no-launch --skip-docker --skip-git
```
