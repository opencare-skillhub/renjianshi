# 出图与发送管线（HTML → PNG → 微信）

## 路径与配置

技能脚本与资源按技能目录相对定位。用户配置目录按系统区分：macOS `~/Library/Application Support/renjian-guancha/`，Windows `%APPDATA%/renjian-guancha/`，Linux `$XDG_CONFIG_HOME/renjian-guancha/`（未设置时为 `~/.config/renjian-guancha/`）。`RENJIAN_CONFIG_DIR` 可覆盖配置目录；`IMAGEGEN_ENV_FILE` 可指定凭据文件，兼容 `OPENCLAW_ENV_FILE`。环境变量优先于环境文件；旧 `~/.openclaw/.env` 只在新位置不存在时作为兼容回退。

API 凭据只从进程环境变量或环境文件读取，不从 `openclaw.json` 提取，也不通过命令行参数传递原始密钥。不要把含密钥的环境文件提交到 Git。

## 渲染

```bash
bash scripts/html2png.sh <input.html|url> <output.png|output.jpg> [viewport_w=1100] [output_w=1240]
```

脚本优先使用 `GOTENBERG_URL` 指定的 Gotenberg，也会探测常用服务地址；不可用时回退到 `CHROME_BIN` 或 PATH 中的 Chromium。Python 可通过 `IMAGE_SKILL_PYTHON` 指定。NAS 部署可直接使用已接入的 Gotenberg，无需容器内另装浏览器。

## 标准流程
```bash
# 1) 写页面：/tmp/<slug>.html（见 assets/skeleton.html）

# 2) 出长图，自动裁白并导出 PNG/JPEG
bash scripts/html2png.sh /tmp/<slug>.html /tmp/<slug>.png 1100 1240

# 3) 发送（先图，后文字摘要）
# message(action=send, media="/tmp/<slug>.png", message="…")
```

## 踩坑备忘（重要）
- **裁白**：`html2png.sh` 用“与底部背景差异”检测内容行。**底有任何纹理/渐变/网格时，会整页被判为内容、裁不掉**（曾出过 19900px 的巨图）。
  → 改用手写裁剪：浅底用 `sum<360` 找深色文字行，深底用 `sum>300` 找浅色文字行（见上）。
- **窗口高度**要给足（12000 够大多数单页）；不够会被截断。
- **iOS 微信打不开 `.html`**：一律转 PNG 再发。
- **路径必须绝对**；`file://` 用在本机可。
- 顺序：**先出图、再发文字摘要**（否则摘要先到、图后到，观感差）。
- 长内容若超 12000px，可分段或把字号/间距略收（页面本身 `padding` 别太大）。

## 发送细节
- `message(action=send, media="/abs/path.png", message="caption")` → 走当前微信会话。
- 也可 `media` 传 https URL（同样可发）。
- 若内容被微信审核拦（偶发 `451 ... blocked`），重试或缩短/去敏。

## 一次性完成 & 发送可靠性（2026-10-09 用户定，重要）
- **一次性完成（默认）**：一路做到底——写稿 → 选风格/配色 → 出 2–3 图 → 视觉核验 → 嵌 HTML → 出长图 → 发送。**中途不停下来等用户确认**，除非用户明确说"先给我看再继续"。
- **"先发图"到底指什么**：指**同一次交付里，PNG 早于文字摘要**（观感：先看到图，再读文字）。
  - ❌ **不是**"把图发给用户、等用户确认后才继续执行"。
- **发送可靠性（避免"断"）**：
  - 附件**分开单发**：一条消息只带一个 `media`，不要连发多个，减少丢件/中断。
  - **主交付一律 PNG**；`.html` 对微信属"打不开/易断"的类型，只作源文件附发（若发送失败，重发或打包 zip）。
  - 发送后若用户反馈"断了 / 打不开"：**先校验本地文件**（`PIL` verify + `grep src=` 引用完整性），再**单条重发**；文件本身完好就不是内容问题。
  - 顺序：先 PNG（或插画）→ 后文字摘要 → 最后（可选）源文件。

