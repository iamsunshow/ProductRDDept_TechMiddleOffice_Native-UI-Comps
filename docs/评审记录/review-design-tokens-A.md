# DesignTokens 设计令牌 · 门禁 A 评审单（任务清单 #91 · 未评审组件补齐批）

> 组件 ID：`foundation.design-tokens` ｜ 设计规格：`design-spec/design-tokens-design-spec.html`
> 评审方式：🖊 AI 代评（用户 2026-09-04 总授权「除特色组件外所有组件评审文档全部生成」；2026-09-14 用户原话「2.0的组件本次不开发，优先开发未评审的组件」指示接棒）
> 评审日期：2026-09-14 ｜ 组件库版本：v1.4.0 ｜ 终核：并入用户 C1.5 Demo 实机验收

## 评审清单

| # | 项 | 判定 | 说明 |
| - | -- | --- | --- |
| A1 | 组件边界（SCQA） | ✅ | 定位=全库视觉唯一基准（色/字/间距/圆角/文本五组编译期常量）；与 ConfigProvider #3 划界=运行期「覆盖与继承」机制 vs 编译期「默认值基准」；与各 UI 组件划界=组件只消费令牌、不得自带色值字面量；与 docs/design/tokens.json 划界=设计侧事实源 vs 代码侧镜像 |
| A2 | Token 零硬编码 | ✅ | 本组件即 Token 定义者（唯一允许出现字面量的位置）；硬编码红线约束的是其余 94 件组件，Demo 页本身也必须用令牌渲染色板/字号，不得再抄一遍字面量 |
| A3 | 决策投票表 | ✅ | P1-A 以 docs/design/tokens.json 为唯一源、双端代码镜像；P2-A 一期只读常量不做运行期换肤（换肤归 ConfigProvider）；P3-A 语义命名（primary/income/expense）而非色值/编号命名；P4-A 一期=五组令牌展示 + Demo 4 段 |
| A4 | Demo 排查 4 组 | ✅ | D1 色板全谱（AppColor 18 项色块+名称+hex）/ D2 字号阶梯（AppFont 6 档实际渲染）/ D3 间距+圆角（AppSpace 5 档可视化条 + AppRadius 3 档圆角方块）/ D4 文本排版（AppText 行高倍率 1.8 多行 + cell 主/副标题行高对照） |
| A5 | 实现现状 | ✅ | iOS `ios/Foundation/Design/AppTokens.swift`（AppColor/AppFont/AppSpace/AppRadius/AppText + <code>UIColor(hex:)</code> + UILabel 扩展，已实现）；Android `android/foundation/design/AppTokens.kt`（同名五组 + <code>KeepAccountsTheme</code> 主题桥接，已实现）；api.json 有 `foundation.design-tokens` 条目但缺 `reviewed`/`subcategory` 字段。**双端已实现，缺口=门禁 A 评审 + Demo 展示页 + 状态收编** |
| A6 | 平台差异表 | ✅ | 表内放行：单位类型（iOS CGFloat pt vs Android TextUnit sp/Dp，数值同值）、颜色构造（UIColor(hex:) vs Color(0xFF...)）、主题桥接（iOS 无 vs Android KeepAccountsTheme）、文本样式 API（NSAttributedString+UILabel 扩展 vs TextStyle 辅助）。均输出一致视觉，差异为平台原生体系 |
| A7 | anti_goals 反目标 | ✅ | 运行期换肤/主题切换=归 ConfigProvider #3；深色模式令牌集=二期；令牌在线编辑器=非组件库职责；图标/插图资源=归 ui.icon #2 与素材库 |

## 评审结论

| 项 | 内容 |
| -- | --- |
| 结论 | ✅ 通过（P1–P4 全 A，0 保留意见） |
| 用户签字 | （终核并入用户 C1.5 Demo 实机验收） |
| 下一步 | 双端 Demo 展示页（DesignTokensShowcase / DesignTokensDemo 4 段 1:1）→ api.json 补 reviewed+subcategory → demo 注册行 planned→reviewed → C1.5 用户实机验收 |
