# FixedNav 悬浮导航 · 门禁 A 评审单（导航组件 #3 · #15）

> 组件 ID：`ui.fixed-nav` ｜ 设计规格：`design-spec/fixed-nav-design-spec.html`
> 评审方式：🖊 AI 代评（用户 2026-09-04 总授权"除特色组件外所有组件评审文档全部生成，中间任何询问直接通过"）
> 评审日期：2026-09-05 ｜ 终核：并入用户全批统一验收（C1.5 实机 Demo）

## 评审清单

| # | 项 | 判定 | 说明 |
| - | -- | --- | --- |
| A1 | 组件边界（SCQA） | ✅ | 定位=页面边缘常驻悬浮入口钮 + 展开导航项列表的"快捷导航器"（收起胶囊钮→点击弹出钮旁列表面板→点项回传自动收起）；与 BackTop（单功能回顶）/HoverButton（单钮自定义无列表）/Tabbar（底部主导航）划界清晰；anti_goals=拖拽 Drag/自定义按钮面板插槽/Icon 系统映射/面板长列表滚动=登记二期 |
| A2 | Token 零硬编码 | ✅ | 钮高 40pt/dp（对齐 BackTop 悬浮钮）、面板行高 44、行图标位 20、num 角标 16 全走 token 与注释锚定非魔法值；面板=卡片壳（bgCard/圆角 md/边框/投影）复用 DesignTokens 视觉 |
| A3 | 决策投票表 | ✅ | P1-A 收起胶囊钮 + 点钮弹出面板（展开态钮文字切 active-text）+ 点项/点钮/点外收起（对齐 NutUI active 双向控制）；P2-A FixedNavItem(key/text/icon?/num?) + type 左右 + 文案自定义 + onSelect 自动收起；P3-A 纯内容视图+宿主锚定"悬浮"（BackTop 同款宿主定位先例，type 只定面板展开方向）；P4-A 一期=钮+面板竖排行≤7（图标位/文本/num/分割线）+开合/点外收起+type+文案自定义，插槽/Icon 映射/Drag 二期 |
| A4 | Demo 排查 4 组 | ✅ | D1 右侧基本（"快速导航"展开 4 项带 num 角标，钮文字切"收起导航"）；D2 左侧 type=left（"更多工具"3 项）；D3 无图标无角标长文本（图标位隐藏不占位）；D4 多次开合 + 点面板外收起状态机稳定 |
| A5 | 实现现状 | ✅ | 双端均未实现（任务清单行 15 ⬜，api.json 无条目待立项），本规格为立项入口 |
| A6 | 平台差异表 | ✅ | 表内放行：展开/收起动画（UIView animate vs animate*AsState）、点面板外收起（宿主 tap vs Compose pointerInput）、钮胶囊实现（UIButton vs Surface）均为系统级原生差异；尺寸数值 pt/dp 表内放行（同 Grid/Layout/Elevator 先例） |
| A7 | anti_goals 反目标 | ✅ | 拖拽定位 Drag、自定义按钮/面板插槽、行图标系统 Icon 映射、面板长列表(>7)滚动均登记二期 |

## 评审结论

| 项 | 内容 |
| -- | --- |
| 结论 | ✅ 通过（P1–P4 全 A，0 保留意见） |
| 用户签字 | （终核并入用户全批统一验收 2026-09-05） |
| 下一步 | 双端实现 + Demo 双端 1:1 → api.json 契约登记（available，reviewed=false）→ C1.5 demo 实机 → C1 单测 → C2/D |
