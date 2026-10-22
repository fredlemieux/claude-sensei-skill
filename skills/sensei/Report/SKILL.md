---
name: sensei:report
description: Session report generation and knowledge gap management for Sensei Mode.
---

# Sensei Session Report

This sub-skill generates a learning report when Sensei Mode ends (toggled off or session end).

## Config

Read the active config via `../setup/read-config.sh`:

```bash
source "$(dirname "$0")/../setup/read-config.sh"
# Exports: SENSEI_STORAGE_DIR, SENSEI_LINK_STYLE, SENSEI_RETRIEVAL_DAYS
```

Reports and the gap file live under `$SENSEI_STORAGE_DIR`:

```
$SENSEI_STORAGE_DIR/
  reports/
    YYYY-MM-DD-session-report.md
  gaps.md
```

If `$SENSEI_STORAGE_DIR/reports/` doesn't exist, create it.

If no config exists, halt and tell the user to run `/sensei setup`.

### Link Style

The `SENSEI_LINK_STYLE` value controls how reports cross-link to each other and to source files:

- `plain` — standard Markdown `[text](path/or/url)`
- `obsidian` — `obsidian://open?vault=<vault>&file=<encoded path>` for files inside an Obsidian vault
- `logseq` — `[[page name]]` wiki-style refs

Default is `plain`. The skill never mutates files outside `$SENSEI_STORAGE_DIR`.

## Report Template

```markdown
# Sensei Session Report — {DATE}

## Session Overview
- Duration: {approximate time}
- Topics covered: {list of technical topics}
- Primary scaffolding level: {L1-L5, which was most used}
- Escalations: {count and topics where level was raised}

## What Went Well
{2-4 bullet points about demonstrated competence, self-corrections, successful explanations}

## Growth Areas
{2-4 bullet points about topics that needed more scaffolding, recurring patterns, conceptual gaps}

## Knowledge Gaps Detected
{New gaps discovered this session — these get written to persistent memory}
- [ ] {Domain}: {specific gap} — Context: {what revealed it}

## Independence Signals
{Topics where the developer needed no help or self-corrected}
- [x] {Domain}: {what they demonstrated}

## Recommended Practice
{1-3 specific exercises the developer could do without AI to strengthen weak areas}

## Sensei's Note
> {2-3 sentences of honest, direct reflection on the session. Not praise.
> Focus on the most important insight about their learning. What should
> they carry forward? Celebrate understanding, not output.}
```

## Knowledge Gap Management

### Writing Gaps to Memory

After generating the report, update `$SENSEI_STORAGE_DIR/gaps.md`:

```markdown
---
name: sensei_knowledge_gaps
description: Tracked knowledge gaps from Sensei Mode sessions for spaced retrieval and practice
---

## Active Gaps (will be revisited)

### {Domain} — {Category}
- {Specific gap} (detected {DATE})
  - Context: {what revealed it}
  - Last reviewed: {DATE or "never"}
  - Confidence: {low / medium / high}

## Closed Gaps (demonstrated competence)

### {Domain} — {Category}
- {What was mastered} (closed {DATE})
  - Evidence: {how they demonstrated it}
```

**Rules for gap management:**
1. New gaps from this session → add to Active Gaps.
2. If a gap already exists and they still struggled → update "Last reviewed", keep confidence or lower it.
3. If a gap already exists and they demonstrated competence unprompted → move to Closed Gaps with evidence.
4. A gap is only closed when the developer demonstrates competence **without prompting** — getting it right with help doesn't count.

## Gap Review Workflow (/sensei gaps)

When the user runs `/sensei gaps`:

1. Read `$SENSEI_STORAGE_DIR/gaps.md`.
2. Present a summary:
   ```
   ⛩️ SENSEI — Knowledge Gap Review

   Active Gaps (3):
   - TypeScript: discriminated unions (detected 2026-04-09, never reviewed) — LOW
   - Knex: window functions (detected 2026-04-09, never reviewed) — LOW
   - GraphQL: DataLoader pattern (detected 2026-04-09, never reviewed) — MEDIUM

   Overdue for Review (not seen in {SENSEI_RETRIEVAL_DAYS}+ days):
   - TypeScript: discriminated unions — 14 days since detected

   Closed This Month (2):
   - React Query: staleTime vs gcTime
   - Fastify: plugin registration order

   Want to work on any of these?
   ```
3. If the user picks one, enter Sensei mode focused on that topic with appropriate scaffolding level based on their last confidence rating.

## Celebration of Understanding

When closing a gap, acknowledge the understanding (not the count):

**Do this:**
> "You can now explain DataLoader without prompting. That's a real shift from two weeks ago when you couldn't describe the N+1 problem."

**Don't do this:**
> "Achievement unlocked! DataLoader mastery +1! You've closed 3 gaps this month!"
