---
name: session-monitor
description: Monitors running Claude Code sessions and provides status updates. Handles commands like "status", "skipped", "errors", "logs", and "pause". Always active during builds.
---

# Session Monitor Skill

You monitor active build sessions and respond to status queries.

## Commands

### `status`
Show current session status.

**Response format:**
```
🔨 Build Status: {Project Name}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Phase: {current}/{total} — {phase name}
Progress: {progress bar} {percent}%

✅ Completed: {n} tasks
⏳ In Progress: {n} tasks
⏸️ Skipped: {n} items
❌ Blocked: {n} issues

Last activity: {time} ago
Session duration: {Xh Ym}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Commands: skipped | errors | pause | logs
```

**Implementation:**
```bash
SESSION_DIR=~/.afk/builds/$(date +%Y-%m-%d)

# Parse PROGRESS.md for status
COMPLETED=$(grep -c "^\- \[x\]" $SESSION_DIR/PROGRESS.md 2>/dev/null || echo 0)
IN_PROGRESS=$(grep -c "^\- \[ \]" $SESSION_DIR/PROGRESS.md 2>/dev/null || echo 0)
SKIPPED=$(grep -c "^|" $SESSION_DIR/SKIPPED.md 2>/dev/null | tail -1 || echo 0)
BLOCKED=$(grep -c "blocked" $SESSION_DIR/PROGRESS.md 2>/dev/null || echo 0)

# Check if session is running
if [ -f $SESSION_DIR/claude.pid ]; then
  PID=$(cat $SESSION_DIR/claude.pid)
  if ps -p $PID > /dev/null 2>&1; then
    STATUS="🏃 Running"
  else
    STATUS="⏹️ Stopped"
  fi
else
  STATUS="⏹️ No active session"
fi
```

---

### `skipped`
Show all skipped items from SKIPPED.md.

**Response format:**
```
⏸️ Skipped Items ({count})

Tasks:
1. {task} — {reason}
2. {task} — {reason}

Decisions Needed:
• {decision}: {options}

Tech Debt:
• {file}: {issue}

Reply "details {n}" for more on a specific item.
```

**Implementation:**
```bash
cat ~/.afk/builds/$(date +%Y-%m-%d)/SKIPPED.md
```

---

### `errors`
Show type errors fixed during build.

**Response format:**
```
🔧 Type Errors Fixed ({count})

By category:
• frontend-backend-sync: {n}
• null-safety: {n}
• import-export: {n}

Recent:
{last 5 errors from TYPE-ERRORS.md}

Reply "errors all" for full list.
```

**Implementation:**
```bash
ERRORS_FILE=~/.afk/builds/$(date +%Y-%m-%d)/TYPE-ERRORS.md

# Count by category
grep -E "^\|" $ERRORS_FILE | cut -d'|' -f5 | sort | uniq -c | sort -rn

# Last 5
tail -5 $ERRORS_FILE
```

---

### `logs`
Tail the session log.

**Response format:**
```
📜 Session Log (last 30 lines)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
{log output}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Reply "logs {n}" for more lines
```

**Implementation:**
```bash
tail -30 ~/.afk/builds/$(date +%Y-%m-%d)/session.log
```

---

### `pause`
Request graceful pause after current task.

**Response:**
```
⏸️ Pause requested

Claude will stop after completing the current task.
Progress will be saved to PROGRESS.md.

Reply "resume" to continue later.
```

**Implementation:**
```bash
SESSION_DIR=~/.afk/builds/$(date +%Y-%m-%d)
touch $SESSION_DIR/.pause-requested
```

---

### `resume`
Resume a paused session.

**Response:**
```
▶️ Resuming build...

Reading checkpoint from PROGRESS.md...
{summary of where we left off}

Starting Claude Code...
```

**Implementation:**
```bash
SESSION_DIR=~/.afk/builds/$(date +%Y-%m-%d)
rm -f $SESSION_DIR/.pause-requested
# Restart Claude Code with checkpoint context
```

---

### `abort`
Emergency stop. Commits WIP and kills session.

**Requires confirmation:**
```
⚠️ Abort requested

This will:
1. Signal the Ralph Loop to stop
2. Kill the Claude Code process
3. Commit all changes as WIP
4. End the session

Reply "confirm abort" to proceed or "cancel"
```

**On confirm:**
```bash
SESSION_DIR=~/.afk/builds/$(date +%Y-%m-%d)

# Signal Ralph Loop to stop (it checks this between iterations)
touch $SESSION_DIR/.abort-requested

# Also kill the process directly
PID=$(cat $SESSION_DIR/claude.pid)
kill $PID 2>/dev/null

# Commit WIP
cd $PROJECT_DIR
git add -A
git commit -m "wip: build aborted by user at $(date +%H:%M)"

# Update status
echo "ABORTED" >> $SESSION_DIR/PROGRESS.md
```

---

### `loop`
Show Ralph Loop status.

**Response:**
```
🔄 Ralph Loop Status

Iterations: {current} / {max}
Mode: Running / Paused / Complete / Aborted
Last restart: {time} (exit code {N})

Recent loop events:
{last 5 lines from ralph-loop.log}

Reply "loop log" for full loop history
```

**Implementation:**
```bash
SESSION_DIR=~/.afk/builds/$(date +%Y-%m-%d)
cat $SESSION_DIR/ralph-loop.log | tail -5
```

---

### `linear` (optional — requires Linear MCP)
Show Linear ticket status for current build. Only available when `LINEAR_PROJECT` is set in `.overnight-config`.

**Response (if configured):**
```
Linear Status: {Epic Name}

Done: {n} tickets
In Progress: {n} tickets
Blocked: {n} tickets
Todo: {n} tickets

Blocked:
  {ticket-id}: {title} — {blocker reason}

Reply "linear {ticket-id}" for details
```

**Response (if not configured):**
```
Linear is not configured. Task tracking uses Claude tasks + PROGRESS.md.
Set LINEAR_PROJECT in .overnight-config to enable.
```

---

### `pr`
Show PR status for current build.

**Response:**
```
🔀 Pull Request

Branch: feature/my-feature
Status: {Open | Draft | Ready}
Commits: {n}
Changed files: {n}

URL: {github url}

Checks:
✅ Lint
✅ TypeCheck  
⏳ Tests (running)
```

---

### `summary`
Generate/show morning briefing.

**Response:**
```
☀️ Morning Briefing: {Project} - {Date}

## Overview
Duration: {time}
Result: {completed}/{total} phases

## Completed
{list}

## Skipped
{list with reasons}

## Blocked
{list with blockers}

## Decisions Needed
{list}

## Next Steps
1. Review PR: {url}
2. Resolve blockers: {list}
3. Run "analyze my corrections" after your fixes

Full briefing: ~/.afk/builds/{date}/MORNING-BRIEFING.md
```

---

## Proactive Notifications

Send without being asked when:

### Phase Complete
```
✅ Phase {n} complete: {name}

Duration: {time}
Tasks: {completed}
Errors fixed: {count}

Starting Phase {n+1}: {name}
```

### Blocker Detected
```
⚠️ Blocker: {task name}

Error: {short description}
Tried: {what was attempted}

Actions:
• Logged to SKIPPED.md
* Marked Claude task as blocked
* If Linear configured: created issue
* Moving to next task

Reply "details" for full error
```

### Idle Warning (30 min no activity)
```
⏰ Session appears idle

Last activity: {time}
Last task: {name}
Status: {what's happening}

Possible causes:
• Waiting for long operation
• Stuck on complex task
• Process crashed

Reply "logs" to check, "abort" to stop
```

### Session Complete
```
🎉 Build complete!

Duration: {time}
Phases: {n}/{total}

Summary:
✅ {n} tasks done
⏸️ {n} skipped
❌ {n} blocked

PR ready for review.
Reply "summary" for full briefing
```

---

## Health Checks

Every 5 minutes, verify:

1. **Process alive:**
   ```bash
   ps -p $(cat ~/.afk/builds/$(date +%Y-%m-%d)/claude.pid) > /dev/null
   ```

2. **Disk space:**
   ```bash
   df -h ~ | awk 'NR==2 {print $5}' | tr -d '%'  # Alert if > 90%
   ```

3. **Log growing:**
   ```bash
   # Compare log size to 5 min ago
   ```

4. **No crash indicators:**
   ```bash
   grep -i "error\|crash\|fatal" ~/.afk/builds/$(date +%Y-%m-%d)/session.log | tail -1
   ```
