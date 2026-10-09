#!/usr/bin/env bash
# 人间世 · 基线同步（baseline -> git + skills）
# 用法：bash sync.sh
# 基线目录 = 本脚本所在目录（唯一真源）。改完这里的任何文件，跑一次即双向落地：
#   1) 镜像到 ~/.agents/skills/renjian-guancha（供技能加载）
#   2) commit + push 到 GitHub 仓库 renjianshi
set -euo pipefail

BASE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS="${HOME}/.agents/skills/renjian-guancha"
REMOTE="git@github.com:opencare-skillhub/renjianshi.git"
BRANCH="main"
LOCK="${TMPDIR:-/tmp}/renjianshi-sync.lock"

# 并发保护：同一时刻只允许一个同步进程
if ! mkdir "$LOCK" 2>/dev/null; then
  echo "[sync] another run in progress, skipped"
  exit 0
fi
trap 'rmdir "$LOCK" 2>/dev/null || true' EXIT

echo "[sync] baseline: $BASE"

# 1) 镜像到 skills 目录（排除 git 元数据与系统垃圾）
mkdir -p "$SKILLS"
rsync -a --delete \
  --exclude '.git/' \
  --exclude '.DS_Store' \
  "$BASE/" "$SKILLS/"
echo "[sync] skills  <-  $SKILLS"

# 2) git 提交并推送
cd "$BASE"
git add -A
if git diff --cached --quiet; then
  echo "[sync] git: no changes to commit"
else
  git commit -m "sync: $(date '+%Y-%m-%d %H:%M:%S')" >/dev/null
  echo "[sync] git: committed"
fi
git push origin "$BRANCH"
echo "[sync] git: pushed -> $REMOTE ($BRANCH)"
echo "[sync] done"
