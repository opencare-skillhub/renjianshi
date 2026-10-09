# 模板系列（风格 × 配色 × 提示词骨架 × 页面 token）

可复用的**具名系列**预设。出图/写页时直接套用，一次调用即复现同一观感。

| 系列 | 一句话 | 手绘风格 | 主题色 | 触发词 | 绘本 |
|---|---|---|---|---|---|
| [**橙暖爱**](橙暖爱.md) | 治愈暖调 · 苦里透光 | #196 油画棒治愈手绘 | 柿子橙 + 那不勒斯黄 | `橙暖爱 / 橙暖 / 暖爱` | [gallery/橙暖爱](../../assets/gallery/橙暖爱/) |

- 机读数据：`templates.json`（供 `scripts/preset.py` 使用）
- 命中所属触发词时，插图版**直接套用该系列**，不再临时选风格。

## 用法

```bash
PY=~/clawd/.venvs/imgtool/bin/python
# 打印组好的提示词
$PY ~/.agents/skills/renjian-guancha/scripts/preset.py --template 橙暖爱 --scene "母女俩在窗边分一个橘子"
# 直接出图（橙暖爱默认走 --hq / CPA gpt-image-2）
$PY ~/.agents/skills/renjian-guancha/scripts/preset.py --template 橙暖爱 --scene "…" --run --out /abs/x.png
```

## 新增系列

在 `templates.json` 加一项 + 在本目录加同名 `<系列>.md` + 在上一张索引表加一行 + 出样图放 `assets/gallery/<系列>/`。

> **完整字段表、验收清单、以及「给 AI 协作者的无歧义 12 步」** → 见仓库根 [`CONTRIBUTING.md`](../../CONTRIBUTING.md)。
> 换风格/换色时，`negative` 那一项保持与「橙暖爱」一致——它专门压模型的加字/签名/印章倾向。
