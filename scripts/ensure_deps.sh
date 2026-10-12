#!/usr/bin/env bash
# Cross-platform dependency and renderer check for renjian-guancha.
set -uo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VENV="${RENJIAN_IMAGE_VENV:-$SKILL_DIR/.venv}"
PY="$VENV/bin/python"
if [ "$(uname -s 2>/dev/null || true)" = "Darwin" ]; then
  DEFAULT_CONFIG_DIR="$HOME/Library/Application Support/renjian-guancha"
elif [[ "$(uname -s 2>/dev/null || true)" == MINGW* || "$(uname -s 2>/dev/null || true)" == MSYS* ]]; then
  DEFAULT_CONFIG_DIR="${APPDATA:-$HOME/AppData/Roaming}/renjian-guancha"
else
  DEFAULT_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/renjian-guancha"
fi
CONFIG_DIR="${RENJIAN_CONFIG_DIR:-$DEFAULT_CONFIG_DIR}"
ENVF="${IMAGEGEN_ENV_FILE:-${OPENCLAW_ENV_FILE:-$CONFIG_DIR/imagegen.env}}"
OK=0; WARN=0; FAIL=0
ok(){ printf '  ✅ %s\n' "$*"; OK=$((OK+1)); }
warn(){ printf '  ⚠️ %s\n' "$*"; WARN=$((WARN+1)); }
fail(){ printf '  ❌ %s\n' "$*"; FAIL=$((FAIL+1)); }

if [ ! -f "$ENVF" ] && [ -f "$HOME/.openclaw/.env" ]; then
  ENVF="$HOME/.openclaw/.env"
  warn 'using legacy ~/.openclaw/.env; migrate to IMAGEGEN_ENV_FILE or the XDG config directory'
fi
echo '== renjian-guancha dependency check =='

if [ ! -x "$PY" ] || ! "$PY" -c 'import sys' >/dev/null 2>&1; then
  PYTHON="$(command -v python3 2>/dev/null || true)"
  if [ -n "$PYTHON" ] && "$PYTHON" -m venv "$VENV" >/dev/null 2>&1; then
    PY="$VENV/bin/python"
  elif [ -n "$PYTHON" ]; then
    PY="$PYTHON"
    warn "could not create venv at $VENV; checking system Python"
  else
    fail 'Python 3 unavailable'; exit 1
  fi
fi

PYTHONPATH_EXTRA=""
if ! "$PY" -c 'import httpx, PIL, numpy' >/dev/null 2>&1; then
  VERSION="$("$PY" -c 'import sys; print(f"python{sys.version_info.major}.{sys.version_info.minor}")' 2>/dev/null || true)"
  SITE="$VENV/lib/$VERSION/site-packages"
  if [ -d "$SITE" ]; then PYTHONPATH_EXTRA="$SITE"; fi
fi
if PYTHONPATH="$PYTHONPATH_EXTRA${PYTHONPATH:+:$PYTHONPATH}" "$PY" -c 'import httpx, PIL, numpy' >/dev/null 2>&1; then
  ok 'httpx / Pillow / numpy available'
elif "$PY" -m pip --version >/dev/null 2>&1; then
  if "$PY" -m pip install -q httpx pillow numpy python-dotenv; then
    ok 'installed httpx / Pillow / numpy / python-dotenv'
  else
    fail "package installation failed; run $PY -m pip install httpx pillow numpy python-dotenv"
  fi
else
  fail "Python packages missing and pip is unavailable for $PY"
fi

if [ -f "$SKILL_DIR/vendor/handraw-style-data/styles.json" ]; then
  ok 'bundled handdraw style data available'
else
  warn 'bundled handdraw style data missing'
fi

if [ -f "$ENVF" ]; then
  ok "credentials env file found: $ENVF"
else
  warn "no env file found at $ENVF; process environment variables can still provide credentials"
fi
if [ -n "${SN_IMAGE_GEN_API_KEY:-}" ] || grep -qE '^SN_IMAGE_GEN_API_KEY=' "$ENVF" 2>/dev/null; then
  ok 'SiliconFlow image key is configured'
else
  warn 'SN_IMAGE_GEN_API_KEY not configured (CPA or OpenRouter may still be available)'
fi

if [ -n "${GOTENBERG_URL:-}" ]; then
  ok "Gotenberg URL configured: $GOTENBERG_URL"
elif command -v curl >/dev/null 2>&1 && { curl --noproxy '*' -fsS --max-time 2 http://gotenberg:3000/health >/dev/null 2>&1 || curl --noproxy '*' -fsS --max-time 2 http://127.0.0.1:3980/health >/dev/null 2>&1; }; then
  ok 'Gotenberg reachable'
else
  CHROME="${CHROME_BIN:-}"
  if [ -z "$CHROME" ]; then
    for candidate in chromium chromium-browser google-chrome google-chrome-stable; do
      CHROME="$(command -v "$candidate" 2>/dev/null || true)"
      [ -n "$CHROME" ] && break
    done
  fi
  [ -x "$CHROME" ] && ok "local Chromium available: $CHROME" || warn 'Gotenberg and local Chromium not detected; HTML rendering will need one of them'
fi

echo "== Result: $OK passed · $WARN warnings · $FAIL failures =="
[ "$FAIL" -eq 0 ]
