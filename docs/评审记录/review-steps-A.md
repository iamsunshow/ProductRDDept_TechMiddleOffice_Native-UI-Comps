# Steps 步骤条 · 门禁 A 评审单（信息展示区组件 #75 · 全新立项）

> 组件 ID：`ui.steps` ｜ 设计规格：`design-spec/steps-design-spec.html`
> 评审方式：🖊 AI 代评（用户 2026-09-04 总授权"除特色组件外所有组件评审文档全部生成，中间任何询问直接通过"）
> 评审日期：2026-09-11 ｜ 终核：并入用户 C1.5 Demo 实机验收

## 评审清单

| # | 项 | 判定 | 说明 |
| - | -- | --- | --- |
| A1 | 组件边界（SCQA） | ✅ | 定位=展示含多个步骤的流程进度，已完成打勾/当前高亮/未开始置灰，横向或竖向排列；与 Tabs #78（页签切换内容面板）划界=Steps 展示流程进度只读为主；与 Collapse #65（纵向折叠内容）划界=Steps 无内容折叠；与 Pagination #71（数据分页翻页）划界=Steps 是业务流程节点+连线；与 Indicator #69（轮播小圆点）划界=Steps 是多步业务流程节点；双端纯从零（全仓无 StepsView.swift/Steps.kt） |
| A2 | Token 零硬编码 | ✅ | 步骤圆点 24×24 字号 sizeXs Medium；已完成 primary 填充+白对勾；当前白底+primary 描边 2px+primary 数字；未开始白底+gray6 描边 1px+gray25 数字；连线已完成段 primary 1px/未完成段 gray6 1px；标题 sizeSm 已完成/当前 textPrimary 未开始 textSecondary；描述 sizeXs textSecondary；圆点与标题间距 sm；全走 token |
| A3 | 决策投票表（ACE） | ✅ | P1-C 混合受控（current=-1=内部自管理/≥0=受控，A 纯受控淘汰=D1 样板多/B 纯非受控淘汰=D3 切换做不到）；P2-B 一期可点击已完成步骤回退（A 纯展示淘汰=交互性弱/C 任意跳转淘汰=不符合流程约束）；P3-A 默认对勾（B 数字不变淘汰=难以区分已完成/C 自定义图标槽淘汰=一期复杂度）；P4-A 一期=基础步骤条/横向+竖向/当前步骤高亮/自定义图标+demo 四段（动画/错误态/迷你=二期） |
| A4 | Demo 排查 4 组 | ✅ | D1 基础步骤条（横向 3 步当前第 2 步）；D2 横向+竖向（同屏对比方向）；D3 当前步骤高亮（第 3 步前两步已完成）；D4 自定义图标（每步自定义图标） |
| A5 | 实现现状 | ✅ | iOS SharedUI/Components 无 StepsView=未实现；Android sharedui/components 无 Steps.kt=未实现；api.json 无 ui.steps 条目待门禁 B 立项登记；Demo 列表已登记 planned=true 待改 reviewed=true 挂 demo |
| A6 | 平台差异表 | ✅ | 表内放行：状态管理（属性 -1 vs 参数 -1 语义一致）、步骤圆点（UIView+cornerRadius vs Box+CircleShape）、自定义图标（SF Symbols vs Material Icons 平台图标库差异语义对齐）、连线渲染（UIView 1px vs Spacer 1.dp）；视觉一致放行 |
| A7 | anti_goals 反目标 | ✅ | 步骤切换动画=二期增量（一期瞬切稳定优先）；错误态（error status）=二期；迷你尺寸（mini）=二期；垂直描边样式=二期；组件只做步骤展示不承载业务流程跳转逻辑 |

## 评审结论

| 项 | 内容 |
| -- | --- |
| 结论 | ✅ 通过（P1–P4 全选最优，0 保留意见） |
| 用户签字 | （终核并入用户 C1.5 Demo 实机验收） |
| 下一步 | 门禁 B api.json ui.steps 契约登记 → 双端独立组件实现（StepsView.swift / Steps.kt）→ Demo 双端 1:1 四段 → C1.5 demo 实机 → C1 单测 → C2/D |
