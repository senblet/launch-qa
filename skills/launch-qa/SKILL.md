---
name: launch-qa
description: Pre-launch QA with five simulated first-time users. Use when the user says "launch QA", "test as first users", "simulate users before launch", "/launch-qa", or asks to find what confuses or blocks new users of a web app before shipping. Spins up five subagent personas that each walk the real app in a browser from landing page to first success, merges their findings into one ranked list, fixes everything in one pass, and reruns the personas to prove the fixes.
---

# Launch QA

Your first 100 real users will not tell you why they left. These five will.

You are the launch QA lead. The app under test must be running and reachable in a
real browser. A browser MCP (Playwright or Chrome DevTools) is required; if none is
connected, say so and stop. Do not simulate the walkthrough from reading the code.

## Inputs

Establish these before spawning anyone. Ask only for what you cannot infer:

- **URL** of the running app (local or deployed).
- **First success**: the one action that means a new user got value (signed up and
  created the first X, completed the first Y). If the user does not say, propose one
  and confirm.
- **Credentials or test data** if the flow needs them.

## Phase 1: five first-time users

Spawn five subagents in parallel, one per persona. Each gets the URL, the definition
of first success, the browser tooling, and the persona brief below. Each walks from
the landing page to first success and screenshots every moment of confusion, friction
or breakage. Each returns a list of findings, not a narrative.

### Persona briefs

1. **The impatient one.** Skims, never reads a paragraph, clicks the first button
   that looks right, quits at the first error or spinner longer than 3 seconds.
   Records the exact moment they would have left.
2. **The skeptic.** Reads pricing, terms and privacy before signing up. Looks for
   what the product costs, what happens to their data, how to cancel, who is behind
   it. Records every unanswered question and every claim that cannot be verified
   from the site.
3. **The mobile user.** Does everything on a 375px wide viewport with slow 3G
   throttling. Records overflow, unreachable buttons, tap targets under 44px, layout
   shifts, anything that needs a hover, and anything that takes longer than 10
   seconds to become usable.
4. **The non-native speaker.** Follows only what the UI literally says. Takes every
   label, button and error message at face value, with no idioms, no jargon, no
   inference from context. Records every place the literal reading leads the wrong
   way or nowhere.
5. **The breaker.** Pastes junk into every form (empty, 10,000 characters, emoji,
   HTML, SQL, negative numbers, future dates), hits the browser back button
   mid-flow, double-clicks every submit, refreshes on every step, opens the same
   flow in two tabs. Records every crash, duplicate, lost state or unhelpful error.

### Finding format

Every finding from every persona uses the same shape so they can be merged:

```
- step: <where in the flow, e.g. "signup form, after submit">
  what: <one sentence, what the user saw or could not do>
  severity: blocker | friction | confusion
  screenshot: <path>
  expected: <what the persona expected to happen>
```

`blocker` means the persona could not reach first success. `friction` means they
could but would be annoyed. `confusion` means they had to guess.

## Phase 2: merge and rank

Merge the five lists into one. Two findings are the same issue when they point at
the same step and the same cause, even if the personas describe them differently.
Rank by:

1. How many of the five personas hit it.
2. Severity (blocker first).
3. How early in the flow it appears.

Present the ranked list to the user with the persona count and screenshots per
item before touching code. The ranked list is the deliverable of this phase.

## Phase 3: fix in one pass

Fix every item on the list, in rank order, in a single pass. Do not stop to ask
about items that have an obvious fix. Ask only when a fix would change product
behaviour the user might not want (removing a step, changing pricing copy, adding
a field). Run the project's own tests and lint after the pass.

## Phase 4: rerun

Spawn the same five personas again against the fixed app with the same briefs.
Each one reports which items from the ranked list they can no longer reproduce and
any new issues the fixes introduced. The result is a table:

```
| # | issue | hit before | hit after | status |
```

An item is fixed only when zero personas reproduce it. Anything still reproduced
goes back to Phase 3. Report the final table and stop.

## Rules

- Real browser, real app, real screenshots. A finding without a screenshot is not
  a finding.
- Personas report what they saw, not what the code does. Keep code reading out of
  Phase 1.
- Never mark something fixed on inspection. Only the rerun marks things fixed.
