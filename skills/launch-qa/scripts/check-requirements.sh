#!/usr/bin/env bash
# Usage: check-requirements.sh <app-url>
# Exit 0 when every hard requirement is met, 1 otherwise.
url="${1:-}"
fail=0
ok()   { printf 'OK    %s\n' "$1"; }
miss() { printf 'MISS  %s\n      fix: %s\n' "$1" "$2"; fail=1; }

if command -v npx >/dev/null 2>&1; then ok "node/npx"; else
  miss "node/npx" "install Node.js 18+ (brew install node)"; fi

if command -v claude >/dev/null 2>&1; then
  if claude mcp list 2>/dev/null | grep -Eiq 'playwright|chrome-devtools'; then
    ok "browser MCP"
  else
    miss "browser MCP (Playwright or Chrome DevTools)" \
      "claude mcp add playwright -- npx @playwright/mcp@latest   # then restart Claude Code"
  fi
else
  printf 'SKIP  browser MCP (claude CLI not on PATH, check the session tool list instead)\n'
fi

if [ -z "$url" ]; then
  miss "app URL" "pass the URL of the running app as the first argument"
else
  code=$(curl -s -o /dev/null -w '%{http_code}' --max-time 10 -L "$url" || true)
  case "$code" in
    2??|3??) ok "app reachable at $url ($code)" ;;
    *) miss "app reachable at $url (got ${code:-no response})" "start the app, or check the URL and port" ;;
  esac
  case "$url" in
    https://*|http://localhost*|http://127.0.0.1*) ok "secure context (camera, mic, geolocation can work)" ;;
    *) printf 'WARN  %s is not a secure context: getUserMedia, geolocation and clipboard APIs will be blocked\n' "$url" ;;
  esac
fi

exit $fail
