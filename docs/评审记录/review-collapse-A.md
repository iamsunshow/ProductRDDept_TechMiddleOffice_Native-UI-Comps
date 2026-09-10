# Collapse 折叠面板 · 门禁 A 评审单（信息展示区组件 #65 · 全新立项）

> 组件 ID：`ui.collapse` ｜ 设计规格：`design-spec/collapse-design-spec.html`
> 评审方式：🖊 AI 代评（用户 2026-09-04 总授权"除特色组件外所有组件评审文档全部生成，中间任何询问直接通过"）
> 评审日期：2026-09-10 ｜ 终核：并入用户 C1.5 Demo 实机验收

## 评审清单

| # | 项 | 判定 | 说明 |
| - | -- | --- | --- |
| A1 | 组件边界（SCQA） | ✅ | 定位=可折叠/展开的内容区域，点击标题展开/收起，用于将较长内容分组收纳；与 Tabs #78（横向页签切换）划界=Collapse 纵向折叠可多项同展；与 Cell #66（静态列表行）划界=Collapse 有展开/收起二态；与 NoticeBar #51（横向滚动公告）划界=Collapse 纵向分组折叠；双端纯从零（全仓无 CollapseView/Collapse.kt） |
| A2 | Token 零硬编码 | ✅ | 标题行高 cellVertical、左右 AppSpace.lg、字号 AppFont.sizeMd Medium、textPrimary；禁用态 textSecondary 灰；chevron 12×12 textSecondary；内容区 AppSpace.lg/AppFont.sizeSm/textSecondary；分隔线 border；面板 bgCard + radius.lg；全走 token |
| A3 | 决策投票表（ACE） | ✅ | P1-C 混合受控（activeKeys 非空=受控/空=内部自管理，A 纯受控淘汰=D1 样板多/B 纯非受控淘汰=D4 做不到）；P2-A 一期无动画瞬切（B 高度动画淘汰=iOS 自动布局踩坑风险高+双端曲线难一致）；P3-A 默认右侧 chevron 旋转（B 无图标淘汰=用户不知可点/C 自定义图标槽淘汰=二期）；P4-A 一期=基础折叠/手风琴/禁用/受控+demo 四段（嵌套折叠/动画=二期） |
| A4 | Demo 排查 4 组 | ✅ | D1 基础折叠（多项可同时展开）；D2 手风琴模式（只展一项，展新收旧）；D3 禁用项（标题置灰不可展）；D4 受控外部驱动（外部 activeKeys 控制展开态） |
| A5 | 实现现状 | ✅ | iOS SharedUI/Components 无 CollapseView=未实现；Android sharedui/components 无 Collapse.kt=未实现；api.json 无 ui.collapse 条目待门禁 B 立项登记；Demo 列表已登记 planned=true 待改 reviewed=true 挂 demo |
| A6 | 平台差异表 | ✅ | 表内放行：状态管理（属性 nil vs 参数 null 语义一致）、内容区显隐（isHidden/约束 vs if 条件组合）、chevron 旋转（CGAffineTransform vs Modifier.rotate）、圆角裁切（layer.cornerRadius+clipsToBounds vs background(RoundedCornerShape) 遵安卓禁令）；视觉一致放行 |
| A7 | anti_goals 反目标 | ✅ | 高度过渡动画=二期增量（一期瞬切稳定优先）；自定义图标槽=二期；嵌套折叠=二期；内置滚动=容器承载组件只负责折叠 |

## 评审结论

| 项 | 内容 |
| -- | --- |
| 结论 | ✅ 通过（P1–P4 全选最优，0 保留意见） |
| 用户签字 | （终核并入用户 C1.5 Demo 实机验收） |
| 下一步 | 门禁 B api.json ui.collapse 契约登记 → 双端独立组件实现（CollapseView.swift / Collapse.kt）→ Demo 双端 1:1 四段 → C1.5 demo 实机 → C1 单测 → C2/D |
