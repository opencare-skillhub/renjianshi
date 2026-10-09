# 内置风格数据（vendor）

本目录是 `handraw-style`（手绘技能）的**精简可用子集**，用于在未安装完整 handraw-style 技能时，
仍能完成"**选手绘风格 + 选主题色 + 组提示词**"这一步（插图版必需）。

- `styles.json` —— 279 个风格条目（number / group / reference / generation_name / traits）
- `colors.json` —— 36 个主题色（C-01–C-36）
- `model_capabilities.json` —— 各生图模型的风格激活能力表
- `layouts.json` —— 排版图型（海报/信息图用，可选）
- `handdraw-style-prompter.SKILL.md` —— 上游提示词规则（节选）

**未包含**：`images/`（约 37MB 的参考图）。因此**依赖"参考图"的风格激活不可用**；
纯文字提示词路径（name + traits）不受影响。若已安装完整 `handraw-style` 技能，优先用它。
