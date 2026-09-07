# HoverButton 悬浮按钮 · 门禁 A 评审单（导航组件 #4 · #16）

> 组件 ID：`ui.hover-button` ｜ 设计规格：`design-spec/hover-button-design-spec.html`
> 评审方式：🖊 AI 代评（用户 2026-09-04 总授权"除特色组件外所有组件评审文档全部生成，中间任何询问直接通过"）
> 评审日期：2026-09-05 ｜ 终核：并入用户全批统一验收（C1.5 实机 Demo）

## 评审清单

| # | 项 | 判定 | 说明 |
| - | -- | --- | --- |
| A1 | 组件边界（SCQA） | ✅ | 定位=页面边缘常驻的"单功能悬浮动作钮"（发布/扫码/记一笔等业务入口，常驻无滚动阈值自动显隐，点击交回 onTap）；与 FixedNav（多入口列表面板）/BackTop（滚动超阈值回顶）/Tabbar（底部主导航）/NavBar（顶部导航）划界清晰；anti_goals=动作组并入 FixedNav、自定义色板/插槽、拖拽、系统图标映射=登记二期 |
| A2 | Token 零硬编码 | ✅ | icon-only 圆钮 40 直径、胶囊高 40 + 水平 padding=AppSpace.lg + icon/text 间距 sm、圆角 full、主色底白字、icon 默认 "✚"(U+271A) 零图片；全走 token 与注释锚定非魔法值；复用 DesignTokens 视觉（BackTop 悬浮钮同族） |
| A3 | 决策投票表 | ✅ | P1-A 单钮常驻悬浮动作钮 + onTap（与 FixedNav/BackTop 划界，无浮层无滚动监听）；P2-A icon/text 声明式 + onTap 缺省不崩；P3-A 内容驱动形态判定（text 空=圆钮 40、text 非空=胶囊高 40 padding lg，无需 mode 枚举）；P4-A 一期=主色钮三形态 + onTap + 常驻 + 宿主定位 + demo 四段（含与 BackTop 共存划界），色板自定义/插槽/拖拽二期 |
| A4 | Demo 排查 4 组 | ✅ | D1 icon-only ✚ 圆钮右侧常驻（点计数回显）；D2 icon+text 胶囊左下（✎ 记一笔）；D3 纯文本长内容胶囊（"打开工具书"宽自适应、无 icon 位占位）；D4 与 BackTop 同容器共存（HoverButton 常驻点计数 vs BackTop 滚动超阈值出现回顶=悬浮族划界对照） |
| A5 | 实现现状 | ✅ | 双端均未实现（任务清单行 16 ⬜，api.json 无 ui.hover-button 条目待立项），本规格为立项入口 |
| A6 | 平台差异表 | ✅ | 表内放行：点击按压反馈（iOS touchDown 压暗 vs Android 一期无涟漪=组件库悬浮族惯例）、钮圆角随尺寸时机（layoutSubviews vs 固定 40 构造）为系统级原生差异；icon 单字符渲染、尺寸数值 pt/dp、默认 ✚ 字符=表内放行（同全库先例） |
| A7 | anti_goals 反目标 | ✅ | 动作组展开并入 FixedNav 语义、自定义色板/内容插槽、拖拽摆放+吸附、系统图标 Icon 映射均登记二期 |

## 评审结论

| 项 | 内容 |
| -- | --- |
| 结论 | ✅ 通过（P1–P4 全 A，0 保留意见） |
| 用户签字 | （终核并入用户全批统一验收 2026-09-05） |
| 下一步 | 双端实现 + Demo 双端 1:1 → api.json 契约登记（available，reviewed=false）→ C1.5 demo 实机 → C1 单测 → C2/D |
