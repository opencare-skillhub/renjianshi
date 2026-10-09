# 主题库（为内容选皮，别复用同一套）

> 字体栈统一（可微调）：
> `--serif: "Songti SC","Noto Serif SC","Source Han Serif SC",Georgia,serif;`
> 拉丁标题/数字可用 `"Fraunces"`（Google Fonts，离线时回退 serif）。
> 版式通用：`.page{max-width:820px;margin:auto;padding:72px 30px}`；`line-height:2.0`；
> 头部居中 + 细双线 `.rule`；段号用 Latin 序号；结尾一个 `.close` 卡。

---

## 1. 冷钢 + 余温（社会/结构/经济题材）——「冷的是计价器，暖的是人」
```css
--bg:#131720; --card:#1A1F29; --line:#2A313D; --line2:#3A4353;
--text:#E9EBE6; --muted:#9BA2AB; --faint:#6D747E;
--steel:#7C97B4; --ember:#C57F4C; --red:#C2564B;
```
底可叠 `radial-gradient(rgba(124,151,180,.10),transparent)` + 一点 ember 暖晕。

## 2. 夜话（婚恋 / 内省 / 深夜独白）
```css
--bg:#111116; --card:#1C1C26; --line:#2E2E3C; --line2:#3C3C4E;
--text:#ECE6D8; --muted:#9C9789; --faint:#6E6A5F;
--gold:#D9A441; --rose:#CB8080; --teal:#6FAE99;
```

## 3. 晨光（病房 / 照护 / 温柔观察）——透气、留白多
```css
--bg:#F4F1E9; --card:#FBF9F3; --ink:#2A2C28; --ink2:#42453E;
--muted:#726F66; --line:#E4DECF; --line2:#D4CBB6;
--sage:#5B7A6E; --ochre:#C08A4A; --rose:#B87A72;
```

## 4. 雨后（哀伤 / 安放 / 希望萌芽）
```css
--bg:#EDF0EA; --card:#F8FAF5; --ink:#2B322C; --ink2:#414840;
--muted:#6E7268; --line:#D9DED4; --line2:#C6CFC4;
--deep:#3E5B52; --water:#5E8A86; --ochre:#BE8A4E; --rose:#AF7C74;
```

## 5. 亚麻（哀伤 / 尊严 / 庄重）
```css
--bg:#F3EEE5; --card:#FFFDF9; --ink:#23262C; --ink2:#3B3F47;
--muted:#6C6A63; --line:#E3DBCB; --line2:#D2C7B2;
--slate:#3E5C6B; --terra:#B06A4A; --sage:#7E9078;
```

## 6. 灯橙（照护 / 黑暗里的一盏灯）
```css
--bg:#191410; --card:#221B14; --line:#3A2E22; --line2:#4C3A26;
--text:#EFE6D4; --muted:#B09A7C; --faint:#7E6B52;
--amber:#E0A44B; --amber2:#F0C070; --ember:#CB7C4A; --teal:#7FA894;
```
底叠顶部大 `radial-gradient(rgba(224,164,75,.20),transparent 60%)` 做“灯光”。

## 7. 电影感（人物 / 命运 / 影评式）
```css
--bg:#0D0C0B; --card:#1A1613; --line:#2C2620; --line2:#3E352C;
--text:#EDE6D6; --muted:#9C9384; --faint:#6E6659;
--gold:#C9A24B; --rose:#C8664E; --teal:#5E8B84;
```
顶部聚光 `radial-gradient(rgba(201,162,75,.10),transparent)`。

## 8. 金石（器 / 传统文化 / 拓本）
```css
--paper:#F4EEE2; --ink:#241C10; --ink2:#3A2E1C;
--line:#D8CBB0; --line2:#E4DAC4; --muted:#6E6250;
--gold:#A9762F; --gold2:#C9A24B; --patina:#4E7A6A; --cinnabar:#B23A2E;
```
宣纸底 + 铜金 + 朱砂点睛；可加“朱文印”方块。

---

## 通用版式小件
- 头部：`.eyebrow`（字距 .5em 的点睛小标）→ `h1`（大号衬线）→ `.sub` → `.rule` 双细线 → `.meta`。
- 引言/警句：`.pull`（左侧 3px 竖线 + 大号衬线）。
- 段号：`.k .no`（Latin 序数字，主打色，略透明）。
- 双面/多面：`.coins` 两卡（顶边不同色）。
- 要点：`.list .it`（编号 + 摘要）。
- 收束：`.close`（细边框卡 + 主色提示），**只写真话，不写金句**。
