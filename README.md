# launch-qa

A Claude Code skill that sends six simulated first-time users through your app
before you launch, merges what they hit into one ranked list, fixes the bugs, proposes the copy and
flow changes for you to approve, and reruns the six to prove it.

The six users:

1. **The impatient one**: skims, clicks the first button, quits at the first error.
2. **The skeptic**: reads pricing, terms and privacy before signing up.
3. **The mobile user**: does everything on a 375px screen on slow 3G.
4. **The non-native English speaker**: only follows what the UI literally says.
5. **The breaker**: pastes junk into forms, hits back mid-flow, double-clicks everything.
6. **The returning user**: comes back the next day and checks the app remembered anything.

Your first 100 real users will not tell you why they left. These six will.

## Install

```sh
npx skills add senblet/launch-qa
```

Or copy `skills/launch-qa/` into `~/.claude/skills/` (global) or
`.claude/skills/` in your project.

## Requirements

Hard, the skill stops without them:

| Requirement | Install |
|---|---|
| A browser MCP: [Playwright](https://github.com/microsoft/playwright-mcp) or [Chrome DevTools](https://github.com/ChromeDevTools/chrome-devtools-mcp) | `claude mcp add playwright -- npx @playwright/mcp@latest`, then restart Claude Code |
| Node.js 18+ | `brew install node` |
| The app running and reachable from your machine | your project's dev command |

Soft, the skill runs without them and reports what it could not test:

- One test account per persona, or a resettable database. Otherwise personas run one at a time.
- HTTPS or localhost, if the app uses the camera, microphone, geolocation or clipboard.
- A typed or sample-input path for any step that needs a microphone or camera. Automated browsers have neither.
- Test-mode payments and a catch-all inbox, if the flow charges money or sends email.
- Network throttling in the browser tooling, for the mobile persona.

Check a project before running:

```sh
bash skills/launch-qa/scripts/check-requirements.sh http://localhost:3000
```

## Use

Start your app, then:

```
/launch-qa http://localhost:3000, first success = user creates their first project
```

See [skills/launch-qa/SKILL.md](skills/launch-qa/SKILL.md) for the full procedure.

## Credit

Prompt idea from [@RoundtableSpace](https://x.com/RoundtableSpace/status/2111717667228770611).
