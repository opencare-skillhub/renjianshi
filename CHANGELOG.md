# 更新日志 · CHANGELOG

版本号写在 `SKILL.md` 的 `metadata.version`。**改动 `SKILL.md` 或 `references/` 的实质内容时，同时在这里记一条**（只改版本头不记日志，等于没记）。

## v1.5.2 · 2026-10-12

- 新增跨平台配置目录与环境文件解析，支持 Linux/XDG、macOS、Windows，以及显式路径覆盖。
- OpenRouter 密钥不再从 `openclaw.json` 发现，命令行不接受原始密钥参数。
- 新增长图 Gotenberg 优先、Chromium 回退的 PNG/JPEG 渲染脚本。
- 依赖检查支持 Linux 容器，并可复用同 Python 版本的 venv 包目录。

## v1.5.1 · 2026-10-09

- 新增 **LICENSE（MIT）**，各语言 README 顶部加 MIT 许可标识 + 开发语言标识（Python / Shell / HTML5）。
- 新增 **5 个语言版本 README**：English / Русский / 日本語 / 한국어 / العربية，全部含语言切换导航。
- README 里程碑表述改为「感同身受，做引渡人，而不是对岸的人」；贡献寄语（名字、文采与表达一起留下，被应用，点亮希望）写入 README 与 CONTRIBUTING。
- 各语言 README 末尾新增「感谢」：小胰宝社区志愿者晓强的 ❤️ 贡献。

## v1.5.0 · 2026-10-09
- 新增 `CONTRIBUTING.md`：欢迎 PR；给出「风格模版系列」的完整字段表、PR 验收清单，以及
  **「给 AI agent 的无歧义 12 步」**——让任何 agent 都能照着它自己造一个新系列。
- 新增「人文绘本」贡献约定：一个系列下的一组图，放 `assets/gallery/<系列>/`。
- `references/templates/README.md`：索引表加「绘本」列，补用法与「新增系列」指引。
- 图片资产重组：`assets/readme/` → `assets/gallery/橙暖爱/`，与绘本约定对齐。
- `SKILL.md` §14：补齐新增系列 / 绘本的落点，指向 `CONTRIBUTING.md`。

## v1.4.1 · 2026-10-09
- 插图版（§13）与模板系列（§14）成型；首发仓库 `opencare-skillhub/renjianshi`。
