---
name: launch-qa
description: Pre-launch QA with simulated first-time users. Use when the user says "launch QA", "test as first users", "simulate users before launch", "QA de lanzamiento", "prueba como primeros usuarios", "test come primi utenti", "/launch-qa", or asks to find what confuses or blocks new users of a web app before shipping. Spawns subagent personas that each walk the real app in a browser from landing page to first success, merges their findings into one ranked list, fixes bugs, proposes product changes, and reruns the personas to prove the fixes.
---

# Launch QA

Your first 100 real users will not tell you why they left. These six will.

You are the launch QA lead. Do not simulate the walkthrough from reading the code.

## Requirements

Hard requirements. If any is missing, report it with its fix and stop:

- **A browser MCP** connected to this session: Playwright or Chrome DevTools. Check
  the session's tool list, not just the config; a server added mid-session needs a
  restart before its tools exist. Fix:
  `claude mcp add playwright -- npx @playwright/mcp@latest`, then restart.
- **Node.js 18+**, which both browser MCPs run on.
- **The app running** and reachable at a URL from this machine.

Soft requirements. If any is missing, continue, and every persona report names
what it could not test because of it:

- **Isolated test data.** A way to create one account per persona, or a database
  that can be reset. Without it, run personas one after another instead of in
  parallel.
- **A secure context** (HTTPS or localhost) when the app uses the camera,
  microphone, geolocation or clipboard. Browsers block those APIs elsewhere.
- **A non-hardware path for hardware inputs.** Automated browsers have no real
  microphone or camera. Chromium's fake devices give `getUserMedia` a stream, but
  speech recognition on that stream usually returns nothing. Look for a typed or
  sample-input path in the app and use it; report the hardware step itself as
  untested.
- **Sandboxed side effects.** Payments in test mode, email to a catch-all inbox,
  paid third-party APIs the user has agreed to pay for. Ask before running if the
  flow charges money or messages real people.
- **Network throttling** in the browser tooling, for the mobile persona.

Run the bundled check first; it covers the hard requirements and the secure
context:

```sh
bash <this skill's directory>/scripts/check-requirements.sh <app-url>
```

## Phase 0: preflight

Do this yourself, before spawning anyone.

1. **Inputs.** Get the URL of the running app and the definition of **first
   success**: the one action that means a new user got value (signed up and created
   the first X, completed the first Y). If the user does not say, propose one and
   confirm. Get credentials or test data if the flow needs them.
2. **Walk the happy path once.** Open the app in the browser and go from landing
   page to first success the intended way. Write down the steps as a numbered list
   with the URL and the control used at each step. This list is what the personas
   deviate from; without it the impatient persona quits at the landing page and
   reports nothing.
3. **Isolate the personas.** Each persona needs its own browser context and its own
   account or test data. Shared sessions collide: one persona's logout kills
   another's session, and the breaker's duplicate submits pollute the skeptic's
   view. If the app has one shared backend state, run the breaker after the others
   finish, or against a separate database.
4. **Record what cannot be tested.** From the soft requirements: no throttling, no
   real microphone or camera, shared data, side effects skipped. Hand that list to
   every persona so its report says what was actually tested instead of claiming
   a 3G run or a voice recording that never happened.

## Phase 1: first-time users

Spawn the personas in parallel, one subagent each. Each gets the URL, the first
success definition, the happy path steps, its own credentials, the browser tooling
notes and its persona brief. Each walks from the landing page to first success and
screenshots every moment of confusion, friction or breakage. Each stops at first
success; the job is to reach it the way that persona would, not to explore the app.
Each returns a list of findings, not a narrative.

### Persona briefs

1. **The impatient one.** Skims, never reads a paragraph, clicks the first button
   that looks right, quits at the first error or spinner longer than 3 seconds.
   Records the exact moment they would have left, then keeps going so the rest of
   the flow is covered, marking everything after that point as "would not have
   seen this".
2. **The skeptic.** Reads pricing, terms and privacy before signing up. Looks for
   what the product costs, what happens to their data, how to cancel, who is behind
   it. Records every unanswered question and every claim that cannot be verified
   from the site.
3. **The mobile user.** Does everything on a 375px wide viewport. Throttles to slow
   3G when the tooling allows it and says so in the report either way. Records
   overflow, unreachable buttons, tap targets under 44px, layout shifts, anything
   that needs a hover, and anything that takes longer than 10 seconds to become
   usable.
4. **The non-native speaker.** Follows only what the UI literally says. Takes every
   label, button and error message at face value, with no idioms, no jargon, no
   inference from context. Records every place the literal reading leads the wrong
   way or nowhere.
5. **The breaker.** Pastes junk into every form (empty, 10,000 characters, emoji,
   HTML, SQL, negative numbers, future dates), hits the browser back button
   mid-flow, double-clicks every submit, refreshes on every step, opens the same
   flow in two tabs. Records every crash, duplicate, lost state or unhelpful error.
6. **The returning user.** Reaches first success once, closes the browser, comes
   back the next day (new context, same account, cookies kept). Records whether
   the app remembers who they are and where they were, whether what they created
   is still there, and whether the second visit lands on something useful or on
   the onboarding again.

### Finding format

Every finding from every persona uses the same shape so they can be merged:

```
- step: <happy path step number, or "off path: <where>">
  what: <one sentence, what the user saw or could not do>
  severity: blocker | friction | confusion
  kind: bug | copy | flow
  screenshot: <path>
  expected: <what the persona expected to happen>
```

`blocker` means the persona could not reach first success. `friction` means they
could but would be annoyed. `confusion` means they had to guess.

`bug` means the app did something wrong (error, crash, lost data, broken layout).
`copy` means the words were the problem. `flow` means the steps were the problem.

## Phase 2: merge and rank

Merge the lists into one. Two findings are the same issue when they point at the
same step and the same cause, even if the personas describe them differently.
Rank by:

1. Severity: blocker, then friction, then confusion.
2. Within a severity, how many personas hit it.
3. Within that, how early in the flow it appears.

Severity comes before count on purpose. A broken signup and a slightly off font can
both hit six of six; only one of them loses the user.

Present the ranked list to the user with severity, kind, persona count and
screenshots per item. The ranked list is the deliverable of this phase.

## Phase 3: fix and propose

Split the list by kind.

- **Bugs**: fix every one in a single pass, in rank order, without asking. Run the
  project's own tests and lint after the pass.
- **Copy and flow**: do not change them unasked. The lead did not build this
  product and does not know which confirmation step is legally required or which
  pricing sentence was negotiated. Present each as a one-line proposal with the
  concrete change, let the user approve or strike items, then apply the approved
  ones in a second pass.

## Phase 4: rerun

Spawn the same personas again against the fixed app with the same briefs, fresh
contexts and fresh accounts. Each reports which items from the ranked list it can
no longer reproduce and any new issues the fixes introduced. The result is a table:

```
| # | issue | severity | kind | hit before | hit after | status |
```

An item is fixed only when zero personas reproduce it. Anything still reproduced
goes back to Phase 3. Items the user struck in Phase 3 are listed as "declined",
not as fixed. Report the final table and stop.

## Rules

- Real browser, real app, real screenshots. A finding without a screenshot is not
  a finding.
- Personas report what they saw, not what the code does. Keep code reading out of
  Phase 1.
- A persona says what it could not test (no throttling, no second tab) instead of
  reporting as if it had.
- Never mark something fixed on inspection. Only the rerun marks things fixed.
