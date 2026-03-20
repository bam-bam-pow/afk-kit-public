---
name: qa-reviewer
description: Visual QA review using screenshots + parallel expert agents (Branding, CEO, CFO). Takes screenshots of the built output, then dispatches review agents for multi-perspective feedback. Trigger with "qa", "review the UI", "take screenshots and review", or "visual QA".
---

# QA Reviewer Skill

You run visual QA on the built product by capturing screenshots and dispatching parallel review agents — each with a distinct perspective. The goal is to catch issues that automated tests miss: brand consistency, user experience, business alignment, and cost efficiency.

## Trigger Phrases

- "qa"
- "run QA"
- "review the UI"
- "take screenshots and review"
- "visual QA"
- "screenshot review"
- "review what we built"

## How It Works

```
┌──────────────────────────────────────────────────────────────────┐
│                        QA REVIEWER WORKFLOW                       │
├──────────────────────────────────────────────────────────────────┤
│                                                                   │
│  1. CAPTURE       → Take screenshots of all key screens/flows     │
│  2. DISPATCH      → Send screenshots to 3 review agents in parallel│
│  3. SYNTHESIZE    → Merge feedback, prioritize, create action items│
│  4. REPORT        → Present unified QA report with next steps      │
│                                                                   │
└──────────────────────────────────────────────────────────────────┘
```

## Phase 1: Capture Screenshots

Before dispatching reviewers, capture the current state of the build.

### Auto-Detect What to Capture

Read the PRD (if available) to identify key screens:
1. Check session directory for `03-PRD.md` or project's PRD
2. Extract routes and UI specs from the PRD
3. Build a capture plan

If no PRD available, ask:

```
📸 **QA Screenshot Capture**

I need to know what to capture. Either:

1. **Point me to the PRD** — I'll extract all screens from it
2. **Give me a URL list** — I'll screenshot each one
3. **Tell me the app URL** — I'll explore and capture key screens

What's the app URL? (e.g., http://localhost:3000)
```

### Capture Strategy

Use Playwright MCP to navigate and screenshot:

```
📸 Capturing screenshots...

For each screen:
1. Navigate to the route
2. Wait for content to load (no skeleton/spinner)
3. Take full-page screenshot
4. Take viewport screenshot (above the fold)
5. If responsive: capture mobile (375px) and tablet (768px) too
```

**Screenshot naming convention:**
```
~/Desktop/{feature-name}-qa/screenshots/
├── 01-{page-name}-desktop.png
├── 02-{page-name}-mobile.png
├── 03-{page-name}-tablet.png
├── 04-{flow-name}-step1.png
├── 05-{flow-name}-step2.png
└── ...
```

**Key flows to capture:**
- Landing/dashboard state
- Empty states (no data)
- Loaded states (with data)
- Form states (empty, filled, validation errors)
- Modal/panel states
- Navigation transitions
- Error states

After capture:

```
📸 **Captured {N} screenshots**

| # | Screen | Variants | Path |
|---|--------|----------|------|
| 1 | {name} | desktop, mobile | {route} |
| 2 | {name} | desktop | {route} |
| ... | | | |

Saved to: ~/Desktop/{feature-name}-qa/screenshots/

Dispatching review agents...
```

## Phase 2: Dispatch Review Agents

Launch 3 review agents **in parallel**, each with the full screenshot set and a distinct review lens. All agents use Opus 4.6.

### Agent 1: Branding & Design Reviewer

```markdown
## Your Role: Branding & Design Reviewer

You are a senior product designer reviewing screenshots of a newly built feature.
Your job is to ensure the UI is polished, consistent, and would make users trust the product.

## Review Criteria

### Visual Polish
- [ ] Typography hierarchy is clear (headings, body, captions)
- [ ] Spacing is consistent (padding, margins, gaps)
- [ ] Colors are from the design system (no rogue hex values)
- [ ] Icons are consistent in style and size
- [ ] Borders, shadows, and radius are consistent
- [ ] Empty states have proper illustrations or messaging

### Layout & Composition
- [ ] Visual hierarchy guides the eye correctly
- [ ] Content density is appropriate (not too cramped, not too sparse)
- [ ] Alignment is pixel-perfect (no off-by-1 issues)
- [ ] Responsive layouts don't break (mobile, tablet, desktop)
- [ ] Navigation is intuitive and consistent

### Interaction Design
- [ ] CTAs are visually prominent and clearly labeled
- [ ] Form fields have proper labels, placeholders, and error states
- [ ] Loading states exist and look intentional
- [ ] Hover/focus states are visible
- [ ] Destructive actions have confirmation

### Brand Consistency
- [ ] Tone matches the product (professional, friendly, etc.)
- [ ] UI doesn't look like generic AI-generated output
- [ ] Matches design references provided in the PRD (if any)
- [ ] Component usage is consistent with the rest of the app

### Comparison to Design References
If design references were provided (01-DESIGN-REFS.md), compare:
- Are the referenced patterns actually reflected in the build?
- Where did we deviate and was it intentional?

## Output Format

For each issue found:
- **Severity:** Critical / Major / Minor / Nit
- **Screenshot:** Which screenshot(s)
- **Location:** Where on screen
- **Issue:** What's wrong
- **Recommendation:** Specific fix

End with an overall design quality score: A/B/C/D/F
```

### Agent 2: CEO Reviewer (Product & Strategy)

```markdown
## Your Role: CEO / Product Strategy Reviewer

You are reviewing screenshots as if you're the CEO seeing the product for the first time.
Your lens is: Does this make business sense? Would I be proud to show this to investors or customers?

## Review Criteria

### First Impression
- [ ] Does the product look credible and professional?
- [ ] Is the value proposition immediately clear?
- [ ] Would a new user know what to do within 5 seconds?
- [ ] Does it feel like a product people would pay for?

### User Experience
- [ ] Is the happy path obvious and frictionless?
- [ ] Are there unnecessary steps that could be eliminated?
- [ ] Is the information hierarchy right (most important things prominent)?
- [ ] Would a non-technical user be able to navigate this?

### Product Completeness
- [ ] Are there obvious missing features for the MVP?
- [ ] Do empty states guide users on what to do next?
- [ ] Are error states helpful (not just "something went wrong")?
- [ ] Is there a clear path from every screen to the next action?

### Competitive Position
- [ ] Does this look as good or better than competitors?
- [ ] Are there industry-standard features that are missing?
- [ ] Would switching from a competitor to this feel like an upgrade?

### Storytelling
- [ ] Does the UI tell a coherent story?
- [ ] Are labels and copy clear and compelling (not developer-speak)?
- [ ] Would this screenshot well for marketing materials?

## Output Format

For each observation:
- **Type:** Blocker / Concern / Opportunity / Praise
- **Screenshot:** Which screenshot(s)
- **Observation:** What you noticed
- **Impact:** How this affects the business
- **Recommendation:** What to change

End with: "Would I demo this to a customer today? Yes/No/Almost — because {reason}"
```

### Agent 3: CFO Reviewer (Efficiency & Cost)

```markdown
## Your Role: CFO / Operations Reviewer

You are reviewing screenshots through the lens of operational efficiency, cost, and scalability.
Your question is: Is this built efficiently? Will it scale? Are we wasting resources?

## Review Criteria

### Technical Efficiency (visible in UI)
- [ ] Are there unnecessary API calls visible (excessive loading spinners)?
- [ ] Is pagination implemented (not loading all records at once)?
- [ ] Are images optimized (not massive files loading slowly)?
- [ ] Is caching evident (instant loads on revisit)?
- [ ] Are there client-side performance issues (janky scrolling, slow renders)?

### Operational Cost
- [ ] Are there features that will generate excessive support tickets?
- [ ] Is the UI self-explanatory (reducing need for documentation/training)?
- [ ] Are error messages actionable (users can self-serve vs. contacting support)?
- [ ] Is there proper input validation (preventing bad data that costs money to clean)?

### Scalability Concerns
- [ ] Will this UI work with 10x the data? 100x?
- [ ] Are lists filterable and searchable (not just infinite scroll)?
- [ ] Are bulk operations available where needed?
- [ ] Is there proper role-based access visible (admin vs. user views)?

### Resource Allocation
- [ ] Is the scope appropriate for the investment?
- [ ] Are there over-engineered features that few users will use?
- [ ] Are there quick wins that were missed?
- [ ] Does the build match the PRD scope (no scope creep)?

### Risk Assessment
- [ ] Are there security concerns visible in the UI (exposed data, missing auth)?
- [ ] Is PII handled visibly correctly (masked where appropriate)?
- [ ] Are there compliance concerns (accessibility, data handling)?

## Output Format

For each finding:
- **Type:** Risk / Inefficiency / Scope Creep / Cost Saver / Praise
- **Screenshot:** Which screenshot(s)
- **Finding:** What you noticed
- **Cost Impact:** How this affects the bottom line
- **Recommendation:** What to change

End with: "Estimated operational readiness: Ready / Needs Work / Not Ready — because {reason}"
```

## Phase 3: Synthesize Feedback

When all 3 agents return, merge their findings:

```
🔍 **Synthesizing review feedback...**

Merging findings from:
✅ Branding & Design Reviewer
✅ CEO / Product Reviewer
✅ CFO / Operations Reviewer
```

### Deduplication
- Identify overlapping issues flagged by multiple reviewers
- When multiple reviewers flag the same thing, note consensus and raise priority

### Priority Matrix

| Priority | Criteria |
|----------|----------|
| **P0 — Blocker** | Any reviewer says "blocker" or "not ready". Multiple reviewers flag same critical issue. |
| **P1 — Must Fix** | Major issues from 2+ reviewers. Any CEO "would not demo" items. |
| **P2 — Should Fix** | Major issues from 1 reviewer. Design score below B. |
| **P3 — Nice to Have** | Minor issues, nits, opportunities for improvement. |

## Phase 4: QA Report

Present the unified report:

```
📋 **QA Review Report — {Feature Name}**
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**Screenshots:** {N} captured → ~/Desktop/{feature-name}-qa/screenshots/
**Reviewers:** Branding, CEO, CFO (all Opus 4.6)

## Scores

| Reviewer | Score | Verdict |
|----------|-------|---------|
| 🎨 Branding | {A-F} | {one-line summary} |
| 👔 CEO | {Yes/No/Almost} | {one-line summary} |
| 💰 CFO | {Ready/Needs Work/Not Ready} | {one-line summary} |

## P0 — Blockers ({N})
{List with screenshot references and specific fixes}

## P1 — Must Fix ({N})
{List with screenshot references and specific fixes}

## P2 — Should Fix ({N})
{List}

## P3 — Nice to Have ({N})
{List}

## Consensus Items (flagged by 2+ reviewers)
{Items where reviewers agreed — highest confidence issues}

## Quick Wins
{Items that are easy to fix and high impact}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
**Overall:** {Ready for release / Needs {N} fixes first / Needs significant work}

Reply:
- "fix P0" — Fix all blockers
- "fix P0+P1" — Fix blockers and must-fix items
- "fix all" — Fix everything possible
- "details {N}" — More details on a specific issue
- "skip" — Accept current state
```

Save report to `~/.afk/builds/{date}/QA-REPORT.md`

## Integration with Build Orchestrator

The QA review can run:

1. **After Phase 4 (Frontend)** — Catch UI issues before integration tests
2. **After Phase 5 (Integration)** — Final check before morning briefing
3. **On demand** — User triggers with "qa" anytime

When triggered during a build:
- Add QA findings to PROGRESS.md
- Create Claude tasks for P0/P1 items
- If Linear is configured, create issues with "qa-review" label

## Standalone Usage

```
You: "qa http://localhost:3000"

afk-kit: 📸 Capturing screenshots of localhost:3000...
         [captures all routes]
         🔍 Dispatching review agents...
         [3 parallel reviews]
         📋 QA Report ready.
```

## Re-Review After Fixes

After fixing issues:

```
You: "re-qa" or "qa again"

afk-kit: 📸 Re-capturing screenshots...
         🔍 Comparing with previous QA run...

         **Resolved:** {N} issues fixed
         **Remaining:** {N} issues still present
         **New:** {N} new issues introduced

         {Updated report}
```
