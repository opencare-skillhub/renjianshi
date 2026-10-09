# Renjianshi · The Truth of Life (人间世)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
![Python](https://img.shields.io/badge/Python-3.10+-3776AB?logo=python&logoColor=white)
![Shell](https://img.shields.io/badge/Shell-Bash-4EAA25?logo=gnu-bash&logoColor=white)
![HTML5](https://img.shields.io/badge/HTML5-E34F26?logo=html5&logoColor=white)

**Languages**：[简体中文](README.md) · [English](README.en.md) · [Русский](README.ru.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [العربية](README.ar.md)

> **Renjianshi (renjian-guancha, "Observing the Human World")** — a writing skill centered on human warmth.

Of everything I have published, this is the **first skill centered not on "feeling like a tool," but on "feeling human."**
Before this one, skills solved "how to be faster, more stable, more reusable"; this one begins to solve **"how to truly empathize — to be a ferryman across the river, not a stranger on the far bank."**

**This is a milestone.**

---

## Why it matters

Families facing cancer have been pressed down by reality for too long — financially, informationally, by grief, by caregiving. What they lack is not more advice; what they lack is **being seen**.

What this skill does, through **observation** and **measured expression**:

- **Hold** the grief of cancer families — not avoiding it, not varnishing it; catching the emotion first;
- **Acknowledge** the suffering — admitting it is real, rather than telling people to "look on the bright side";
- Only then, gently pointing to — **where hope is, where sunlight is**;
- And finally encouraging **the inner light of each person**, and **mutual support**.

No slogans, no cheap reconciliation, no verdicts from on high. **Write the bitterness of reality calmly, then use contrast to let the light in.**

---

## Representative works

The illustrations below are chosen from the "**Orange Warmth**" (橙暖爱) template series (family-collection, healing hand-drawn oil pastels): mother & daughter, father & daughter, a family with a pet. They are not decoration, but **a concrete moment of the article** — remove the image, and that paragraph is missing a piece.

<table>
  <tr>
    <td width="50%"><img src="assets/gallery/橙暖爱/01-waiting-together.jpg" alt="In the waiting area, mother and daughter lean on each other"></td>
    <td width="50%"><img src="assets/gallery/橙暖爱/02-peeling-apple.jpg" alt="In the hospital ward, a daughter peels an apple for her father"></td>
  </tr>
  <tr>
    <td align="center"><sub>Waiting area · Leaning close is companionship</sub></td>
    <td align="center"><sub>Ward · The time it takes to peel an apple</sub></td>
  </tr>
  <tr>
    <td width="50%"><img src="assets/gallery/橙暖爱/03-together-on-phone.jpg" alt="Father and daughter look at photos on a phone together, laughing out loud"></td>
    <td width="50%"><img src="assets/gallery/橙暖爱/04-autumn-walk.jpg" alt="In autumn, a daughter walks arm in arm with her father, a small dog running ahead"></td>
  </tr>
  <tr>
    <td align="center"><sub>A mouthful of sweetness in the bitterness · Laughing out loud together</sub></td>
    <td align="center"><sub>Warm sunlight · Walking slowly, but walking forward</sub></td>
  </tr>
</table>

---

## Its stance (the soul — non-negotiable)

1. **A calm third-party position** — always the observer: no taking sides, no verdicts, no speaking for the people involved.
2. **Reality first, without dodging the "grim"** — most of reality is heavy, bitter, and helpless anyway. Present it as it is: no varnish, no chicken soup.
3. **The landing point leans toward "positive energy"** — but not slogan-style optimism; rather, **leaving a little warmth inside the cold tones**.
4. **Contrast carries the truest emotion** — life and death, cold and warmth, absurdity and tenderness, loss and what remains, set side by side; only then does emotion truly land.

> **The "dessert" technique**: life's plain taste is bitter, so sweetness is needed. **After writing the bitterness fully, always add a mouthful of "sweet"** —
> one concrete, tiny warmth (a bite of cake, a room of out-of-tune songs, a child's crooked candle drawing). Not shouting "it will get better," but **letting the sweetness be seen**.

Aim the sharp edge at **"structures"** (incentives, information gaps, cracks in systems), not at some "bad person" or a profession.

---

## What it produces

It turns complex topics (healthcare / life & death / caregiving / economics / love & marriage / portraits of ordinary people) into observational writing that is **calm + humane + literary + independent**.

| Output | Description |
|---|---|
| **Text edition** (default) | A hand-crafted **single HTML page + WeChat long image** (1080-px-wide PNG), not an ordinary reply |
| **Illustrated edition** | Text edition + 2–3 hand-drawn illustrations, merged into the same page's long image |
| **Template series** | Named presets like "Orange Warmth": one call reproduces the same look |

**Triggers**: `write a piece / observe this / your thoughts / talk about this phenomenon / write your feelings`;
for the illustrated edition add `illustrated / with images / add pictures`.
**Not for**: news reporting, marketing copy, factual summaries, quick Q&A, pure data reports.

---

## Directory

```
renjian-guancha/
├── SKILL.md                     # Main skill file (tone / skeleton / delivery / red lines / self-check)
├── README.md                    # This file
├── CONTRIBUTING.md              # Contribution guide (new style series / illustrated sets; incl. steps for AI agents)
├── assets/
│   ├── skeleton.html            # Starting HTML skeleton
│   └── gallery/                 # Illustrated sets per series (e.g. gallery/橙暖爱/)
├── references/
│   ├── themes.md                # Theme library: palette / fonts / layout tokens
│   ├── pipeline.md              # Image & delivery pipeline (HTML → PNG → WeChat)
│   ├── illustration.md          # Illustrated edition in full (style choice / placement / prompts / verification)
│   └── templates/               # Reusable template series (templates.json + <series>.md)
├── scripts/
│   ├── ensure_deps.sh           # Dependency check / install
│   ├── illustrate.py            # Image generation (multi-backend with fallback)
│   └── preset.py                # Template assembly / direct image generation
└── vendor/
    └── handraw-style-data/      # Bundled trimmed hand-drawn style data (fallback when handraw-style is absent)
```

---

## Quick start

```bash
# Dependency check (first use / new machine)
bash ~/.agents/skills/renjian-guancha/scripts/ensure_deps.sh
```

Just tell your assistant: **"Write a piece: …"** (make the topic specific, or let it observe on its own). The text edition is the default; say **"illustrated"** for images.

---

## Write it longer, together

The best part of this project should be continued by more people.

**PRs welcome — AI collaborators welcome.** Your contribution, along with your name, your prose and your voice, stays here,
and is put to use at the same time — read by the next family, carried forward by the next piece, lighting up hope.

- **PRs welcome** — add a **style template series**, an **illustrated set**, or just change one line into something more apt.
- **AI collaborators welcome** — [`CONTRIBUTING.md`](CONTRIBUTING.md) contains **"12 unambiguous steps for AI agents"**:
  any agent can follow them and create a new style series, draw a new set of illustrations. **This is intentional.**
- Released so far: **Orange Warmth** (healing warm tones · light through the bitterness), illustrations in [`assets/gallery/橙暖爱/`](assets/gallery/橙暖爱/).
  Want a new series? Just follow `CONTRIBUTING.md` and add one.

Before you start, please read the **three red lines** in `CONTRIBUTING.md`: no naming-and-blaming, no final verdicts, no words or seals in illustrations.

---

## Acknowledgments

**Thanks to Xiaoqiang (晓强), volunteer of the Xiaoyibao (小胰宝) community, for his ❤️ contribution.**

---

*Version v1.5.1 · 2026-10-09 · author: Minie (for Xiaoqiang)*
