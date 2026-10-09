#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""illustrate.py — 人间观察·插图版 生图器（多后端 + 自动回退 + 高质量触发）

后端与顺序:
  - 默认(auto):  qwen(SiliconFlow) → cpa:gpt-image-1.5 → openrouter:gpt-5-image-mini → openrouter:gemini-2.5-flash-image
  - --hq / --quality high:  cpa:gpt-image-2 → openrouter:gemini-3-pro-image → …-preview → nano-banana-2.1
  - --backend qwen|cpa|openrouter 可强制单一后端

用法:
  illustrate.py --prompt "<提示词>" --out /abs/x.png [--size 1664x928] [--hq] [--backend auto]
                [--or-key K] [--proxy http://127.0.0.1:7890] [--negative "..."] [--seed N] [--env ~/.openclaw/.env]

要点:
  - Qwen-Image 宽度必须 <2048（用 1664x928 / 1328x1328）。
  - OpenRouter 需走代理（默认 127.0.0.1:7890），直连会被地域封(403)。
  - 高质量触发词（供上层技能识别）: 高质量 / 高清 / 精细 / 精美 / HQ / pro。
"""
import argparse
import base64
import json
import os
import sys
import urllib.request
from pathlib import Path

DEFAULT_NEG = ("文字, 汉字, 中文字, 英文字母, 数字, 日期, 星期, 签名, 落款, 印章, 水印, "
               "logo, 标题, 商标, 货币文字, 日历数字, 任何可读的字符")
DEFAULT_SIZE = "1664x928"
QWEN_MODEL = "Qwen/Qwen-Image"
OR_DEFAULT_PROXY = "http://127.0.0.1:7890"

# CPA（cpa.hybridsam.dev/v1）—— 已实测可用的图像模型
CPA_BASE = "https://cpa.hybridsam.dev/v1"
CPA_CHEAP = ["gpt-image-1.5"]        # 默认链
CPA_HQ = ["gpt-image-2"]             # 高质量链

# OpenRouter 图像模型（按费用从低到高）
OR_CHEAP = ["openai/gpt-5-image-mini", "google/gemini-2.5-flash-image"]
# 高质量优先 gemini-3-pro-image（本 key 实测可用）；nano-banana-2.1 本 key 会报 “API key not valid”，仅作末位兜底
OR_HQ = ["google/gemini-3-pro-image", "google/gemini-3-pro-image-preview", "google/gemini-nano-banana-2.1"]


def load_env(env_path: str):
    p = Path(os.path.expanduser(env_path))
    if not p.exists():
        return
    for line in p.read_text(encoding="utf-8", errors="ignore").splitlines():
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        k, v = line.split("=", 1)
        os.environ.setdefault(k.strip(), v.strip().strip('"').strip("'"))


def find_or_key(cli_key: str | None) -> str:
    if cli_key:
        return cli_key
    for env in ("OPENROUTER_API_KEY", "OPENROUTER_KEY", "OR_API_KEY"):
        if os.environ.get(env):
            return os.environ[env].strip()
    # 兜底：从 openclaw.json 的 openrouter provider 里取
    for cfg in (Path.home() / ".openclaw/openclaw.json",):
        try:
            d = json.loads(cfg.read_text())
            for name, p in d.get("models", {}).get("providers", {}).items():
                if "openrouter" in name.lower() and p.get("apiKey", "").startswith("sk-or-"):
                    return p["apiKey"].strip()
        except Exception:
            pass
    return ""


def save_bytes(data: bytes, out: Path):
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_bytes(data)
    print(f"OK {out} {out.stat().st_size}")


def save_from_payload(payload: dict, out: Path) -> bool:
    if payload.get("images"):
        urllib.request.urlretrieve(payload["images"][-1]["url"], str(out))
        print(f"OK {out} {out.stat().st_size}")
        return True
    for item in payload.get("data") or []:
        b = item.get("b64_json")
        if b:
            if b.startswith("data:"):
                b = b.split(",", 1)[1]
            save_bytes(base64.b64decode(b), out)
            return True
        if item.get("url"):
            urllib.request.urlretrieve(item["url"], str(out))
            print(f"OK {out} {out.stat().st_size}")
            return True
    return False


def gen_qwen(prompt, out, size, neg, seed, timeout) -> bool:
    try:
        import httpx
    except ImportError:
        print("  [qwen] 缺 httpx", file=sys.stderr); return False
    key = os.environ.get("SN_IMAGE_GEN_API_KEY", "").strip()
    base = os.environ.get("SN_IMAGE_GEN_BASE_URL", "https://api.siliconflow.cn/v1").strip().rstrip("/")
    if not key:
        print("  [qwen] 缺 SN_IMAGE_GEN_API_KEY", file=sys.stderr); return False
    body = {"model": os.environ.get("SN_IMAGE_GEN_MODEL", QWEN_MODEL), "prompt": prompt, "n": 1,
            "size": size, "response_format": "b64_json", "negative_prompt": neg}
    if seed is not None:
        body["seed"] = seed
    try:
        r = httpx.post(f"{base}/images/generations",
                       headers={"Authorization": f"Bearer {key}"}, json=body, timeout=timeout)
        if r.status_code != 200:
            print(f"  [qwen] HTTP {r.status_code}: {r.text[:160]}", file=sys.stderr); return False
        return save_from_payload(r.json(), out)
    except Exception as e:
        print(f"  [qwen] err {str(e)[:120]}", file=sys.stderr); return False


def gen_cpa(prompt, out, model, size, timeout) -> bool:
    try:
        import httpx
    except ImportError:
        print("  [cpa] 缺 httpx", file=sys.stderr); return False
    key = os.environ.get("CPA_API_KEY", "").strip()
    if not key:
        print("  [cpa] 缺 CPA_API_KEY", file=sys.stderr); return False
    def _try(sz):
        body = {"model": model, "prompt": prompt, "n": 1, "size": sz, "response_format": "b64_json"}
        r = httpx.post(f"{CPA_BASE}/images/generations",
                       headers={"Authorization": f"Bearer {key}"}, json=body, timeout=timeout)
        return r
    try:
        r = _try(size)
        if r.status_code != 200 and "size" in r.text.lower():
            r = _try("1024x1024")   # CPA 的 gpt-image 系常只认自身档位
        if r.status_code != 200:
            print(f"  [cpa:{model}] HTTP {r.status_code}: {r.text[:160]}", file=sys.stderr); return False
        return save_from_payload(r.json(), out)
    except Exception as e:
        print(f"  [cpa:{model}] err {str(e)[:120]}", file=sys.stderr); return False


def gen_openrouter(prompt, out, model, or_key, proxy, timeout) -> bool:
    try:
        import httpx
    except ImportError:
        print("  [or] 缺 httpx", file=sys.stderr); return False
    if not or_key:
        print("  [or] 缺 OpenRouter key", file=sys.stderr); return False
    # 强制把“无文字”要求写进提示词（OR 图模型不一定支持 negative）
    p = prompt + " 严禁出现任何文字、汉字、字母、数字、签名、印章、水印、logo。"
    body = {"model": model,
            "messages": [{"role": "user", "content": p}],
            "modalities": ["image", "text"]}
    try:
        with httpx.Client(proxy=proxy, timeout=timeout) as c:
            r = c.post("https://openrouter.ai/api/v1/chat/completions",
                       headers={"Authorization": f"Bearer {or_key}", "Content-Type": "application/json"},
                       json=body)
        if r.status_code != 200:
            print(f"  [or:{model}] HTTP {r.status_code}: {r.text[:160]}", file=sys.stderr); return False
        d = r.json()
        if d.get("error"):
            print(f"  [or:{model}] err {json.dumps(d['error'])[:160]}", file=sys.stderr); return False
        msg = (d.get("choices") or [{}])[0].get("message", {})
        for img in msg.get("images") or []:
            u = (img.get("image_url") or {}).get("url", "")
            if u.startswith("data:"):
                save_bytes(base64.b64decode(u.split(",", 1)[1]), out); return True
            if u.startswith("http"):
                urllib.request.urlretrieve(u, str(out)); print(f"OK {out} {out.stat().st_size}"); return True
        print(f"  [or:{model}] 无图片字段", file=sys.stderr); return False
    except Exception as e:
        print(f"  [or:{model}] err {str(e)[:120]}", file=sys.stderr); return False


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--prompt", required=True)
    ap.add_argument("--out", required=True)
    ap.add_argument("--size", default=DEFAULT_SIZE)
    ap.add_argument("--negative", default=DEFAULT_NEG)
    ap.add_argument("--backend", default="auto", choices=["auto", "qwen", "cpa", "openrouter"])
    ap.add_argument("--hq", action="store_true", help="高质量：用最新 Nano Banana")
    ap.add_argument("--quality", default="", help="high/高质量/hq 等价于 --hq")
    ap.add_argument("--or-key", default=None)
    ap.add_argument("--proxy", default=os.environ.get("OR_PROXY", OR_DEFAULT_PROXY))
    ap.add_argument("--seed", type=int, default=None)
    ap.add_argument("--env", default="~/.openclaw/.env")
    ap.add_argument("--timeout", type=float, default=300.0)
    args = ap.parse_args()

    load_env(args.env)
    hq = args.hq or args.quality.lower() in ("high", "hq", "高质量", "高清", "精美", "pro")
    out = Path(args.out).expanduser()
    or_key = find_or_key(args.or_key)

    # 组装候选链
    if args.backend == "qwen":
        chain = [("qwen", None)]
    elif args.backend == "cpa":
        chain = [("cpa", m) for m in (CPA_HQ if hq else CPA_CHEAP)]
    elif args.backend == "openrouter":
        chain = [("or", m) for m in (OR_HQ if hq else OR_CHEAP)]
    else:  # auto
        if hq:
            chain = [("cpa", m) for m in CPA_HQ] + [("or", m) for m in OR_HQ]
        else:
            chain = [("qwen", None)] + [("cpa", m) for m in CPA_CHEAP] + [("or", m) for m in OR_CHEAP]

    print(f"[illustrate] hq={hq} chain={chain}")
    for kind, model in chain:
        if kind == "qwen":
            if gen_qwen(args.prompt, out, args.size, args.negative, args.seed, args.timeout):
                return 0
        elif kind == "cpa":
            if gen_cpa(args.prompt, out, model, args.size, args.timeout):
                return 0
        else:
            if gen_openrouter(args.prompt, out, model, or_key, args.proxy, args.timeout):
                return 0
    print("ERR: 所有后端均失败", file=sys.stderr)
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
