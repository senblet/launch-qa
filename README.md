# launch-qa

A Claude Code skill that sends five simulated first-time users through your app
before you launch, merges what they hit into one ranked list, fixes it all in one
pass, and reruns the five to prove it.

The five users:

1. **The impatient one**: skims, clicks the first button, quits at the first error.
2. **The skeptic**: reads pricing, terms and privacy before signing up.
3. **The mobile user**: does everything on a 375px screen on slow 3G.
4. **The non-native English speaker**: only follows what the UI literally says.
5. **The breaker**: pastes junk into forms, hits back mid-flow, double-clicks everything.

Your first 100 real users will not tell you why they left. These five will.

## Install

```sh
npx skills add senblet/launch-qa
```

Or copy `skills/launch-qa/` into `~/.claude/skills/` (global) or
`.claude/skills/` in your project.

## Requirements

A browser MCP connected to Claude Code: [Playwright MCP](https://github.com/microsoft/playwright-mcp)
or [Chrome DevTools MCP](https://github.com/ChromeDevTools/chrome-devtools-mcp).
The personas walk the real app in a real browser; without one the skill stops.

## Use

Start your app, then:

```
/launch-qa http://localhost:3000, first success = user creates their first project
```

See [skills/launch-qa/SKILL.md](skills/launch-qa/SKILL.md) for the full procedure.

## Credit

Prompt idea from [@RoundtableSpace](https://x.com/RoundtableSpace/status/2111717667228770611).
