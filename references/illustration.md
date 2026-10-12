# 插图版管线（人间观察 · 插图版）

> 文字版 = 冷冷静静写完 + 精雕 HTML + 长图。
> **插图版 = 文字版 + 2–3 张手绘插画**，插画钉在文章的"情绪 / 隐喻最强"处，全部并进同一页 HTML，再出长图。
> 触发：用户说"插图版 / 配图版 / 出图版 / 加上图 / 来几张画"；否则默认文字版。

---

## 依赖与安装（插图版第一次用前先跑一次）

插图版依赖**两类**外部件（技能包**不自带**大件）：

| 依赖 | 必需? | 体积 | 说明 |
|---|---|---|---|
| Python 包 `httpx` / `Pillow` / `numpy` / `python-dotenv` | ✅ | 小 | 出图 + 出长图 |
| Gotenberg 或 Chromium | ✅ | 独立服务或系统已装 | `scripts/html2png.sh` 渲染 |
| `scripts/html2png.sh` | ✅ | 小 | 出 PNG/JPEG 长图（Gotenberg 优先，Chromium 回退） |
| 生图凭据 | ✅ | — | 进程环境变量或配置目录中的 `imagegen.env`；可用 `IMAGEGEN_ENV_FILE` 指定 |
| 手绘技能 `handraw-style` | ⭕ 推荐 | **76MB** | 风格库 + 参考图；**未装时用本技能内置的精简数据**（`vendor/handraw-style-data/`，风格+配色+提示词够用，仅缺"参考图"） |
| 作图技能 `sn-image-base` | ⭕ 可选 | 428KB | 备用出图通道；**主路径是本技能自带 `scripts/illustrate.py`** |

**自动自检 + 安装（一条命令）**：先进入技能目录，再运行：
```bash
cd "<已安装的 renjian-guancha 技能目录>"
bash scripts/ensure_deps.sh
```
- 会自动：创建 venv、`pip install` 缺的 Python 包；
- 会检查：内置 `handraw-style` 数据、Gotenberg/Chromium、`html2png.sh` 和生图环境配置；
- 输出「✅ / ⚠️ / ❌」清单；有 ❌ 就按提示补齐后重跑。

> 结论：**只装这一个技能包也能跑插图版**（内置了风格数据 + 出图器）；`handraw-style` 是"锦上添花"（给参考图）。

---

## 0. 调用哪两个技能

| 环节 | 技能 | 作用 |
|---|---|---|
| **选手绘风格 + 出提示词** | `handraw-style`（手绘技能） | 风格库 #001–#279 + 主题色 C-01–C-36；`article-illustration-planner` 规划插点，`handdraw-style-prompter` 生成双语提示词 |
| **真正出图** | `sn-image-base`（作图技能） | `sn-image-generate` → SiliconFlow `Qwen/Qwen-Image` |

> 本模块**不重造轮子**：风格一律走 `handraw-style`，出图一律走 `sn-image-base`；本模块只负责**把两者按"人间观察"的气质拧紧**。

---

## 1. 核心目标：把"风格 ↔ 主题"拧紧（用户 2026-10-09 反馈）

上一版（生日与确诊日）问题：**图好看，但和图外的主题"接得松"**。插图版必须做到"图和文是一体的"，五条硬规则：

1. **风格由情绪内核反推，不做关键词映射。**
   禁止"一见生死→某号、一见温情→某号"的机械对照。先写出这篇文章的**情感内核一句话**（如"生与死其实是同一枚硬币"），再据此在**全库**里开放式选风格。
2. **一文一风格、一组主题色。**
   2–3 张图**共用同一个手绘风格 + 同一组主题色**，形成系列感；不要三张各画各的。
3. **一图一隐喻，且必须咬住具体段落。**
   每张插画承载文章的**一个具体隐喻或一处"人的细节"**（不是通用配图）。图与它旁边那段话，语义必须对得上——把图挪走，那段会"缺一块"。
4. **图片配色 = 页面配色。**
   图的主色，直接取自该篇 HTML 的 `--warm/--cool/--accent`；页面与插画同一冷暖方向，视觉才连成一体。
5. **留白与"无字"。**
   手绘风留白大、无标题、无签名、无印章（Qwen-Image 爱加字，必须用负面词压制，见 §4）。

---

## 2. 插点怎么选（2–3 张）

按六段式骨架，通常钉这三处（可按题材裁剪）：
- **A. 摊开之后** —— 全景 / 账本 / 事实摆完之后，用一张图"把议题看成一个画面"。
- **B. 核心隐喻处** —— 文章那句最像"诗眼"的比喻（同一枚硬币 / 一片人海 / 一叶纸船），配一张。
- **C. 甜点处** —— 收束前的"一口甜"（一口蛋糕、一屋子跑调的歌、孩子画的歪蜡烛），用图托住暖的落点。

原则：**少而准**。2 张够用就别硬凑 3 张；宁缺毋滥。

---

## 3. 尺寸与参数（重要，绕开 Qwen-Image 的坑）

- Qwen-Image 在 SiliconFlow 上**宽度必须 < 2048**；`sn-image-base` 默认 2K 预设会算出 2048 被拒。
- **统一用支持尺寸**：
  - 横版（正文配图，推荐）：`1664x928`（≈16:9）
  - 方版：`1328x1328`
  - 竖版：`928x1664`
- 因此**不要用 `sn_agent_runner.py` 的 2K/4K 预设**，直接用 `scripts/illustrate.py`（本技能自带，见 §5）。

---

## 4. 提示词骨架（中文优先，Qwen-Image 中文更听话）

```
风格名称：<generation_name>（<风格中文意译>）。参考风格：<reference 作者/风格名>。
核心风格特征：<从 handraw-style 取该风格 traits 里"正向可见"的部分>。
主题色：<color name_zh (name_en)>。
画面：<这句是灵魂——只写该篇的具体隐喻 / 人的细节，不写通用场景>。
画面中严禁出现任何文字、汉字、字母、数字、日期、签名、落款、印章、水印、logo。
纯净白底，大量留白，笔触温柔，安静克制。
```

- **负面词（必须带）**：`文字, 汉字, 中文字, 英文字母, 数字, 日期, 星期, 签名, 落款, 印章, 水印, logo, 标题, 商标, 任何可读的字符`。
- 提示词里**严禁出现编号**（#088 / C-21 / SC-021 等），Qwen-Image 会把编号当文字画上去。
- 意象要**避开必然引字的东西**：日历（会画日期数字）、货币/硬币（会画 "JAPAN"/面额）、书本（会画书名）、招牌。改用品类等价物：日历→日与月；硬币→花与烛。

> **若有命中模板系列**（如"橙暖爱"）：别临时组词，直接用 `scripts/preset.py --template <系列> --scene "…"`，风格/配色/负面词/出图参数都按该系列走。系列清单见 `references/templates/`。

> **人物关系/年龄要写死（2026-10-09 教训）**：画"家属 × 患者"这类关系时，模型常把人物画得过于年轻。**必须在提示词开头加"人物设定锚点"**，如：
> `人物设定（务必遵守）：女儿是一位三十多岁的成年女性、家属；父亲是一位六七十岁、头发花白的年迈患者。两人是成年家属照顾年迈病人的关系。`
> 关系（父女/母女/医护×患者）与年龄一并写死，出图才对得上。

---

## 5. 出图脚本（多后端 + 自动回退 + 高质量触发）

```bash
cd "<已安装的 renjian-guancha 技能目录>"
PY=.venv/bin/python
$PY scripts/illustrate.py \
  --prompt "<按 §4 组好的中文提示词>" --out /abs/01-xxx.png --size 1664x928
# 高质量：加 --hq（或 --quality high）
$PY .../illustrate.py --prompt "..." --out /abs/02-xxx.png --hq
```

**后端与顺序（`--backend auto` 默认）**
| 场景 | 顺序 |
|---|---|
| 默认（省钱快） | **Qwen(SiliconFlow)** → **CPA `gpt-image-1.5`** → `openai/gpt-5-image-mini` → `google/gemini-2.5-flash-image`（后两个走 OpenRouter） |
| **高质量**（`--hq`） | **CPA `gpt-image-2`** → `google/gemini-3-pro-image` → `…-preview` → `google/gemini-nano-banana-2.1` |

- **任一后端失败自动回退到下一个**（含 Qwen 下载被截断、CPA 尺寸被拒的情况）。
- 可 `--backend qwen|cpa|openrouter` 强制单通道。
- **高质量触发词**（供上层识别）：`高质量 / 高清 / 精细 / 精美 / HQ / pro`。
- **CPA 后端** 的 `CPA_API_KEY` 从进程环境变量或配置环境文件读取。
- **OpenRouter 后端** 的 key 从 `OPENROUTER_API_KEY`（或兼容变量）读取；代理地址通过 `OR_PROXY` 或 `--proxy` 配置。
- Qwen 后端从进程环境变量或配置环境文件读取 `SN_IMAGE_GEN_*`；自动带负面词。
- 脚本不读取 `openclaw.json`，也不接受命令行密钥参数；环境文件优先使用 `IMAGEGEN_ENV_FILE` 指定位置，默认跨平台配置目录为 `renjian-guancha/imagegen.env`。
- 费用参考（OpenRouter image_output，由低到高）：`gpt-5-image-mini` 最低 → `gemini-2.5-flash-image` / `gemini-3.1-flash-lite-image` → `gpt-5-image` → `gemini-3.1-flash-image` → `gemini-3-pro-image` 最高。
- ⚠️ `google/gemini-nano-banana-2.1` 本机 key 实测报 “API key not valid”，仅作末位兜底；高质量首选 `gemini-3-pro-image` / CPA `gpt-image-2`。


---

## 6. 嵌入 HTML

在 §2 选定的段落之后插入（沿用页面已有主题变量）：

```html
<figure class="fig">
  <img src="illustrations/<slug>/01-xxx.png" alt="<一句客观的图注替代文字>">
  <figcaption><段号>、<作品式小标题>——<图与文的接点一句话></figcaption>
</figure>
```
配套 CSS（放进页面 `<style>`）：
```css
.fig{margin:26px 0 8px;text-align:center}
.fig img{width:100%;border-radius:16px;border:1px solid var(--line);background:#fff;
  box-shadow:0 6px 22px rgba(60,50,40,.06)}
.fig figcaption{margin-top:11px;font-size:12.5px;color:var(--faint);letter-spacing:.05em}
```

---

## 7. 出长图

```bash
bash scripts/html2png.sh <html> <out.png|out.jpg> 1100 1240
```
- **裁白已修**（2026-10-08）：`html2png.sh` 现按"逐行左右页边距中位色"判背景，对纸纹/渐变底免疫，不会再留大片空白。
- 旧法（若脚本不可用）见 `pipeline.md` 的"深色文字行"手写裁剪。
- iOS 微信打不开 `.html`，**一律发 PNG**；先生成图、再发文字摘要。

---

## 8. 完成后自检（在文字版 §7 之外，追加）

- [ ] 这篇是**文字版**还是**插图版**？（用户没说就默认文字版）
- [ ] 2–3 张图是否**共用同一风格 + 同一组主题色**？
- [ ] 每张图是否**咬住一个具体段落**？（把图挪走，那段是否"缺一块"？）
- [ ] 图片主色是否 = 页面 `--warm/--cool` 同色系？
- [ ] 有没有文字/数字/签名/印章混进画面？（Qwen-Image 高发；出图后**必过一遍视觉核验**）
- [ ] 提示词里有没有混入编号（# / C- / SC-）？
- [ ] 尺寸是否用了 1664x928 / 1328x1328（**没用 2K 预设**）？
- [ ] 长图底部无空白、无被裁切？

---

## 9. 视觉核验（出图后必做）

本机 `image` 工具常缺视觉模型；用 SiliconFlow 视觉模型自检：
```bash
# 单张图提问：主体是什么？有无文字/数字/签名/印章？
# 模型：Qwen/Qwen3-VL-8B-Instruct（一次一张，多图会串）
```
发现引字 / 印章 / 跑题 → 换意象 + 强负面词，**重出那张**。
