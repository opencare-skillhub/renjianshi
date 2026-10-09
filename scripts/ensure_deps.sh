#!/usr/bin/env bash
# ensure_deps.sh — 人间观察·插图版 依赖自检 + 自动安装
# 用法:  bash scripts/ensure_deps.sh        # 检查并按需自动安装
# 退出码: 0=关键项齐备  非0=有硬依赖缺失(见输出)
set -uo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VENV="$HOME/clawd/.venvs/imgtool"
PY="$VENV/bin/python"
ENVF="$HOME/.openclaw/.env"
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

OK=0; WARN=0; FAIL=0
ok(){   printf '  \033[32m✅\033[0m %s\n' "$*"; OK=$((OK+1)); }
warn(){ printf '  \033[33m⚠️ \033[0m %s\n' "$*"; WARN=$((WARN+1)); }
fail(){ printf '  \033[31m❌\033[0m %s\n' "$*"; FAIL=$((FAIL+1)); }
hdr(){  printf '\n%s\n' "$*"; }

echo "== 人间观察·插图版 · 依赖自检 =="

# 1) Python 环境 + 包（自动安装）
hdr "[1/6] Python 依赖"
if [ ! -x "$PY" ]; then
  warn "venv 不存在，创建：$VENV"
  python3 -m venv "$VENV" || fail "venv 创建失败"
fi
MISS=""
"$PY" -c "import httpx"       2>/dev/null || MISS="$MISS httpx"
"$PY" -c "import PIL, numpy"  2>/dev/null || MISS="$MISS pillow numpy"
"$PY" -c "import dotenv"      2>/dev/null || MISS="$MISS python-dotenv"
if [ -n "$MISS" ]; then
  echo "  → 安装:$MISS"
  "$PY" -m pip install -q $MISS 2>/dev/null || \
  "$PY" -m pip install -q -i https://pypi.tuna.tsinghua.edu.cn/simple $MISS 2>/dev/null
fi
if "$PY" -c "import httpx, PIL, numpy" 2>/dev/null; then ok "httpx / Pillow / numpy 就绪"; else fail "Python 依赖安装失败（手动：$PY -m pip install httpx pillow numpy python-dotenv）"; fi

# 2) 手绘风格库（handraw-style）：优先已装技能，否则用内置 vendor 数据
hdr "[2/6] 手绘风格库 handraw-style"
HS="$HOME/.agents/skills/handraw-style"
VENDOR="$SKILL_DIR/vendor/handraw-style-data"
if [ -f "$HS/skills/handdraw-style-prompter/references/styles.json" ]; then
  ok "已安装完整 handraw-style（含参考图，最佳）"
elif [ -f "$VENDOR/styles.json" ]; then
  warn "未装完整 handraw-style；使用内置精简数据（风格+配色+提示词可用，参考图不可用）"
  warn "  如需参考图：安装 handraw-style 技能到 $HS"
else
  fail "缺 handraw-style 技能，且内置数据缺失"
fi

# 3) 作图技能（可选）
hdr "[3/6] 作图技能 sn-image-base（可选）"
if [ -d "$HOME/.agents/skills/sn-image-base" ]; then
  ok "已安装 sn-image-base"
else
  warn "未装 sn-image-base（可选）；主路径用本技能 scripts/illustrate.py（自带 Qwen-Image 出图）"
fi

# 4) 生图后端环境变量
hdr "[4/6] 生图后端配置"
if grep -qE '^SN_IMAGE_GEN_API_KEY=' "$ENVF" 2>/dev/null; then
  ok "SN_IMAGE_GEN_API_KEY 已配置（$ENVF）"
else
  fail "缺 SN_IMAGE_GEN_API_KEY：在 $ENVF 写入 SN_IMAGE_GEN_API_KEY / SN_IMAGE_GEN_BASE_URL / SN_IMAGE_GEN_MODEL"
fi
grep -qE '^SN_IMAGE_GEN_BASE_URL=' "$ENVF" 2>/dev/null && ok "SN_IMAGE_GEN_BASE_URL 已配置" || warn "未设 SN_IMAGE_GEN_BASE_URL（默认 https://api.siliconflow.cn/v1）"

# 5) Chrome（出长图）
hdr "[5/6] 出图浏览器"
[ -x "$CHROME" ] && ok "Chrome 就绪" || fail "缺 Chrome：$CHROME"

# 6) 出图脚本
hdr "[6/6] 长图脚本"
[ -f "$HOME/clawd/scripts/html2png.sh" ] && ok "html2png.sh 就绪" || fail "缺 ~/clawd/scripts/html2png.sh"

hdr "== 结果：通过 $OK · 警告 $WARN · 失败 $FAIL =="
if [ "$FAIL" -eq 0 ]; then
  echo "关键依赖齐备，可以出图。"; exit 0
else
  echo "有硬依赖缺失，请按上面 ❌ 修复后重跑。"; exit 1
fi
