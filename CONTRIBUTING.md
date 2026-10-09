# 贡献指南 · Contributing

欢迎 PR，欢迎 AI 协作者。

你的贡献，和你的名字、文采与表达，会一起留在这里，同时又被应用——被更多读者读到，点亮希望。

这个项目想做的事很小，也很具体：**把「冷静的人文观察」变成可复制、可延续的作品**——
文字有骨架，插图有系列，苦里透光的那一口甜，能被稳定地写出来、画出来。

所以这里特别欢迎两种贡献：**新的风格模版系列** 和 **新的人文绘本（插图合集）**。
**人写的、AI agent 写的，都一样欢迎。** 只要你守住下面三条底线。

---

## 你可以贡献什么

| 类型 | 说明 | 落点 |
|---|---|---|
| **新增风格模版系列** | 一套「风格 × 配色 × 提示词骨架 × 页面 token」预设 | `references/templates/` |
| **新增人文绘本** | 同一系列下的一组插图（如「橙暖爱」→ 家庭陪伴 22 张） | `assets/gallery/<系列>/` |
| 主题 / 版式 token | 新的配色、字体栈、版式 | `references/themes.md` |
| 文档 / 错字 / 流程改进 | — | 任意 |

---

## 三条底线（务必遵守）

1. **不点名指控**具体个人、机构、职业。用「某个 / 这套结构」指代，把锋芒对准**结构**。
2. **医疗 / 法律 / 数据不下定论**，不替代医嘱；数字标来源与边界；不确定就写「存疑」。
3. **不出现真实患者可识别信息**；插画一律**无字、无数字、无签名印章**。

> 拿不准就把问题交回读者，别替读者下最终结论。这不是保守，这是这个项目的语气。

---

## 新增一个「风格模版系列」

### 要产出的三样东西

1. `references/templates/templates.json` 里新增一项（**机读**，供 `scripts/preset.py` 用）
2. `references/templates/<系列名>.md`（**人读**，六节固定结构）
3. `references/templates/README.md` 索引表加一行

### `templates.json` 字段表

| 字段 | 必填 | 说明 | 例（橙暖爱） |
|---|---|---|---|
| `name_zh` | ✅ | 系列名，2–4 字，有画面感 | `橙暖爱` |
| `desc` | ✅ | 一句话定位，用 `·` 分隔 | `治愈暖调 · 苦里透光 · 母女 / 陪伴 / 医患照料` |
| `mood` | ✅ | 情绪内核（读者该感到什么） | `温暖、治愈、安静、有希望…` |
| `style_name` | ✅ | 手绘风格全名 | `Oil-Pastel Healing Illustration（油画棒治愈手绘）` |
| `reference` | ✅ | 风格短名（画面提示用） | `油画棒治愈手绘` |
| `traits` | ✅ | 风格特征关键词 | `粗颗粒、蜡质色块、奶油高饱和、拙朴人物、笔触温暖松软` |
| `colors` | ✅ | 主题色（一组，非单色） | `柿子橙 (Persimmon Orange) 与 那不勒斯黄 (Naples Yellow)` |
| `suffix` | ✅ | 画面收尾（底 / 留白 / 气质） | `纯净底，大量留白，温暖安静。` |
| `negative` | ✅ | 负面词，**直接复用「橙暖爱」的，不要改** | 见 `templates.json` |
| `hq_default` | ✅ | 是否默认走高质量档 | `true` |
| `backend` | ✅ | 出图后端 | `"cpa"` |
| `html_tokens` | ✅ | 13 个颜色 + 1 个 `body_bg` 渐变 | 见 `templates.json` |
| `scenes_seen` | 建议 | 4–6 条可用场景，要具体到「人的细节」 | `化疗大厅：一排椅子一半晒着太阳` |

> **`negative` 为什么不能改**：它压的是 Qwen-Image / gpt-image 这类模型的「加字、加签名、加印章」倾向。
> 换掉它，插画就会开始自己写字——这是插图版最常翻的车。

---

## AI 协作者快速协议（给 agent 的无歧义步骤）

> 如果你是一个 AI agent，被要求「新增一个风格模版系列」，按下面 12 步执行，不要跳步、不要凭感觉改字段名。

1. 先读 `references/templates/templates.json` 与 `references/templates/橙暖爱.md`，它们是**范本**。
2. 定 `name_zh`（2–4 字）+ `desc`（一句话，`·` 分隔）+ `mood`（一个情绪词为核心）。
3. **选风格 + 选色**：优先从 `vendor/handraw-style-data/styles.json`（#001–#279）与 `colors.json`（C-01–C-36）里
   **开放式**挑「1 个风格 + 1 组主题色」；若本机装了 `handraw-style` 技能，用它更全的库。
   **禁止关键词映射**（不要「看到母女就套暖色」这种机械对应），要按这篇的情绪内核选。
4. 填 `style_name / reference / traits / colors / suffix`（写法照 橙暖爱）。
5. `negative`：**原样复制**橙暖爱的值。
6. `hq_default` = `true`，`backend` = `"cpa"`。
7. `html_tokens`：填 13 个颜色 + `body_bg` 渐变；**色板必须与该系列图片主题色同向**（页面配色 = 图片配色）。
8. `scenes_seen`：写 4–6 条具体场景。
9. 写 `<系列名>.md`，六节：**一句话 / 定向 / 手绘风格 / 提示词骨架 / 出图 / 页面主题 / 已用题材**。
10. 出 3–4 张样图验收：
    ```bash
    PY=~/clawd/.venvs/imgtool/bin/python
    $PY ~/.agents/skills/renjian-guancha/scripts/preset.py \
        --template <系列> --scene "<具体场景>" --run --out /abs/01-x.png
    ```
    逐张**视觉核验**：有字 / 有印章 / 跑题 → 换意象 + 重申负面词，**重出那一张**。
11. 样图放 `assets/gallery/<系列>/`，在 `<系列名>.md` 里用相对路径引用。
12. 在 `references/templates/README.md` 的索引表补一行。

### PR 前验收清单（逐条打勾）

- [ ] `python scripts/preset.py --template <系列> --scene "测试"` 能打印完整提示词、不报错
- [ ] 样图**同一风格 + 同一组色**，成系列感（不是三张各画各的）
- [ ] 每张图咬住一个**具体场景**（把图挪走，那段就缺一块），不是通用配图
- [ ] 图里**无字、无数字、无签名 / 印章 / 水印 / logo**
- [ ] `html_tokens` 与图片主题色同向
- [ ] 三条底线没破
- [ ] `<系列名>.md` 六个小节齐全，且**没有把内部术语当成读者可见标题**

---

## 新增一本「人文绘本」

一本**绘本** = 同一系列下的一组插图，讲同一类关系或同一种处境。

- 放 `assets/gallery/<系列>/`，文件名用**序号 + ASCII 短名**（如 `01-waiting-together.jpg`；
  中文名在 URL 里会编码，别用）。
- 出图参数与已用题材写进对应 `<系列名>.md` 的「已用题材」。
- 建议一次**至少 6 张、覆盖 2–3 组关系**（如 母女 / 父女 / 一家人·宠物），保持风格一致。
- 参考已发布的 [`assets/gallery/橙暖爱/`](assets/gallery/橙暖爱/)（源自「一家人 · 陪伴合集」22 张）。

---

## 怎么提 PR

```bash
# 1) fork 后克隆，或直接在分支上改
git clone git@github.com:opencare-skillhub/renjianshi.git
git checkout -b feat/template-<系列名>

# 2) 改动 + 自测（见上面清单）
# 3) 提交
git add -A && git commit -m "feat(templates): 新增系列 <系列名>"
git push origin feat/template-<系列名>
# 4) 开 PR 到 opcare-skillhub/renjianshi:main，说明：情绪内核 / 选了什么风格与色 / 样图
```

一个 PR 只做一件事，便于 review。有疑问直接在 PR 里问，不用客气。
