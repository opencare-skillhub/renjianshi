#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""preset.py — 按「模板系列」组装提示词，可选直接出图。

用法:
  preset.py --template 橙暖爱 --scene "母女俩在窗边分一个橘子"
  preset.py --template 橙暖爱 --scene "…" --run --out /abs/x.png [--size 1664x928] [--no-hq]

模板数据: references/templates/templates.json
出图脚本: scripts/illustrate.py（自动带上模板的主题色/风格/负面词）
"""
import argparse
import json
import subprocess
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
TPL = HERE.parent / "references" / "templates" / "templates.json"
ILLUS = HERE / "illustrate.py"


def load():
    return json.loads(TPL.read_text(encoding="utf-8"))


def build_prompt(t: dict, scene: str) -> str:
    return (
        f"风格名称：{t['style_name']}。参考风格：{t['reference']}。"
        f"核心风格特征：{t['traits']}。主题色：{t['colors']}。"
        f"画面：{scene}"
        + ("" if scene.rstrip().endswith("。") else "。")
        + "画面中严禁出现任何文字、汉字、字母、数字、日期、签名、落款、印章、水印、logo。"
        + t.get("suffix", "")
    )


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--template", required=True)
    ap.add_argument("--scene", required=True)
    ap.add_argument("--run", action="store_true")
    ap.add_argument("--out", default="")
    ap.add_argument("--size", default="1664x928")
    ap.add_argument("--no-hq", action="store_true")
    ap.add_argument("--list", action="store_true")
    args = ap.parse_args()

    data = load()
    if args.template not in data:
        print(f"未知模板：{args.template}；可用：{list(data)}", file=sys.stderr)
        return 2
    t = data[args.template]
    prompt = build_prompt(t, args.scene)
    print(prompt)

    if args.run:
        if not args.out:
            print("ERR: --run 需要 --out", file=sys.stderr)
            return 2
        cmd = [sys.executable, str(ILLUS), "--prompt", prompt, "--out", args.out,
               "--size", args.size, "--negative", t.get("negative", "")]
        hq = t.get("hq_default", True) and not args.no_hq
        if hq:
            cmd.append("--hq")
        if t.get("backend"):
            cmd += ["--backend", t["backend"]]
        print(">>", " ".join(cmd[:4]), "…", file=sys.stderr)
        return subprocess.call(cmd)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
