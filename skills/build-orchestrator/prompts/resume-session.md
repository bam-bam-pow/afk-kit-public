# Resume AFK Session

Use this prompt when continuing an interrupted session — either manually or via Ralph Loop restart.

---

```markdown
# Resume AFK Session

Read PROGRESS.md to understand current state.
Use the build-orchestrator skill for structure.

## Instructions
1. Check PROGRESS.md for completed/blocked/in-progress items
2. Check `git log --oneline -20` for committed work (including WIP checkpoints)
3. Check ralph-loop.log if it exists — note how many restarts have occurred
4. Review Claude task list for current statuses
5. If Linear is configured, check Linear for any external updates
6. Identify next task to work on
7. Continue from where the session left off
8. Follow all build-orchestrator protocols

## Important
- Do NOT re-do completed work — check PROGRESS.md and git history first
- If MORNING-BRIEFING.md exists, the build is complete — report status and stop
- Ralph Loop WIP commits (prefixed "wip: Ralph Loop checkpoint") are automatic
  restart points — the code in those commits is your previous work

If this is a Ralph Loop restart, you are seeing this prompt because a previous
Claude instance exited. Your previous work is in the files and git history.
Pick up where you left off.
```
