#!/usr/bin/env bash
set -euo pipefail
SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IN="${1:?usage: html2png.sh <input.html|url> [out.png|out.jpg] [viewport_w=1100] [out_w=1240]}"
OUT="${2:-}"
VW="${3:-1100}"
OW="${4:-1240}"
PY="${IMAGE_SKILL_PYTHON:-}"
if [ -z "$PY" ]; then
  [ -x "$SKILL_DIR/.venv/bin/python" ] && PY="$SKILL_DIR/.venv/bin/python"
fi
if [ -n "$PY" ] && [ ! -x "$PY" ]; then PY="$(command -v "$PY" 2>/dev/null || true)"; fi
if [ -z "$PY" ]; then PY="$(command -v python3 2>/dev/null || true)"; fi
[ -n "$PY" ] && [ -x "$PY" ] || { echo 'html2png: Python 3 unavailable; set IMAGE_SKILL_PYTHON.' >&2; exit 127; }
PYVER="$("$PY" -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')"
SITE="$SKILL_DIR/.venv/lib/python$PYVER/site-packages"
if [ -d "$SITE" ]; then export PYTHONPATH="$SITE${PYTHONPATH:+:$PYTHONPATH}"; fi
"$PY" -c 'import PIL, numpy' >/dev/null 2>&1 || { echo "html2png: Pillow/numpy unavailable for Python $PYVER; run ensure_deps.sh in the matching runtime." >&2; exit 127; }
[ -n "$OUT" ] || OUT="/tmp/$(basename "${IN%.*}")-$(date +%s).png"
mkdir -p "$(dirname "$OUT")"
TMPDIR_RENDER="$(mktemp -d "${TMPDIR:-/tmp}/html2png.XXXXXX")"
SHOT="$TMPDIR_RENDER/source.png"
trap 'rm -f "$SHOT"; rmdir "$TMPDIR_RENDER" 2>/dev/null || true' EXIT

BASE="${GOTENBERG_URL:-}"
if [ -z "$BASE" ]; then
  for candidate in http://gotenberg:3000 http://127.0.0.1:3980; do
    if curl --noproxy '*' -fsS --max-time 3 "$candidate/health" >/dev/null 2>&1; then
      BASE="$candidate"; break
    fi
  done
fi
if [ -n "$BASE" ]; then
  case "$IN" in
    http://*|https://*)
      ENDPOINT="$BASE/forms/chromium/screenshot/url"
      curl --noproxy '*' -fsS --show-error --max-time "${GOTENBERG_TIMEOUT:-180}" \
        -X POST "$ENDPOINT" -F "url=$IN" -F "width=$VW" -F 'height=15000' \
        -F 'format=png' -F 'clip=false' -o "$SHOT"
      ;;
    *)
      INPUT_ABS="$(cd "$(dirname "$IN")" && pwd)/$(basename "$IN")"
      ENDPOINT="$BASE/forms/chromium/screenshot/html"
      args=(--noproxy '*' -fsS --show-error --max-time "${GOTENBERG_TIMEOUT:-180}" -X POST "$ENDPOINT"
        -F "files=@$INPUT_ABS;filename=index.html" -F "width=$VW" -F 'height=15000' -F 'format=png' -F 'clip=false' -o "$SHOT")
      INPUT_DIR="$(dirname "$INPUT_ABS")"
      while IFS= read -r -d '' asset; do
        [ "$asset" = "$INPUT_ABS" ] && continue
        case "${asset##*.}" in
          css|png|jpg|jpeg|webp|gif|svg|js|woff|woff2|ttf|otf)
            args+=( -F "files=@$asset;filename=$(basename "$asset")" ) ;;
        esac
      done < <(find "$INPUT_DIR" -maxdepth 1 -type f -print0)
      curl "${args[@]}"
      ;;
  esac
  echo "html2png: rendered with Gotenberg ($BASE)"
else
  CHROME="${CHROME_BIN:-}"
  if [ -z "$CHROME" ]; then
    for candidate in chromium chromium-browser google-chrome google-chrome-stable; do
      CHROME="$(command -v "$candidate" 2>/dev/null || true)"
      [ -n "$CHROME" ] && break
    done
  fi
  [ -x "$CHROME" ] || { echo 'html2png: Gotenberg is unreachable and Chromium is unavailable.' >&2; exit 127; }
  case "$IN" in http://*|https://*) URL="$IN" ;; *) URL="file://$(cd "$(dirname "$IN")" && pwd)/$(basename "$IN")" ;; esac
  "$CHROME" --headless=new --disable-gpu --hide-scrollbars --force-device-scale-factor=2 \
    --window-size="${VW},15000" --virtual-time-budget=7000 --screenshot="$SHOT" "$URL" >/dev/null 2>&1
  echo 'html2png: rendered with local Chromium'
fi
"$PY" - "$SHOT" "$OUT" "$OW" <<'PY'
import sys
import numpy as np
from PIL import Image
shot, out, ow = sys.argv[1], sys.argv[2], int(sys.argv[3])
im = Image.open(shot).convert('RGB')
a = np.asarray(im).astype(int); h, w, _ = a.shape
margin = max(6, w // 40)
bgrow = (np.median(a[:, :margin, :], axis=1) + np.median(a[:, w-margin:, :], axis=1)) / 2.0
diff = np.abs(a - bgrow[:, None, :]).sum(axis=2)
mask = (diff > 40).sum(axis=1) >= 3
rows = np.where(mask)[0]
top = max(0, int(rows.min()) - 40) if len(rows) else 0
bottom = min(h, int(rows.max()) + 60) if len(rows) else h
crop = im.crop((0, top, w, bottom)).resize((ow, int((bottom-top) * ow / w)), Image.Resampling.LANCZOS)
if out.lower().endswith(('.jpg', '.jpeg')):
    crop.save(out, 'JPEG', quality=90, optimize=True)
else:
    crop.save(out, 'PNG', optimize=True)
print(f'{out} {crop.size[0]}x{crop.size[1]}')
PY
