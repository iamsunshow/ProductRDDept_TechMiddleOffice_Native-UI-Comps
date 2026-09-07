# Drag 拖拽排序 · 门禁 A 评审单（任务清单 #47 · 全新立项）

> 组件 ID：`ui.drag` ｜ 设计规格：`design-spec/drag-design-spec.html`
> 评审方式：🖊 AI 代评（用户 2026-09-04 总授权；#45 Badge 收编后用户原话「通过，继续下个组件」指示接棒）
> 评审日期：2026-09-07 ｜ 终核：并入用户 C1.5 Demo 实机验收

## 评审清单

| # | 项 | 判定 | 说明 |
| - | -- | --- | --- |
| A1 | 组件边界（SCQA） | ✅ | 定位=长按列表项可拖拽重新排序（用于收藏管理/章节排序/字段排序）；与 SwipeAction #19（侧滑操作菜单）划界=Drag 纵向拖拽排序 vs Swipe 横滑操作；与 IosStylePullRefresh #55（下拉刷新）划界=Drag 长按拖拽 vs PullRefresh 下拉刷新；与 Tabs #20（页签切换）划界=Drag 纵向排序 vs Tabs 横向页签；双端纯从零 |
| A2 | Token 零硬编码 | ✅ | 拖拽态 elevation8+scale1.02+opacity0.9；手柄 24×24 fontLg textSecondary；动画 0.25s easeOut；全走 token |
| A3 | 决策投票表 | ✅ | P1-C 两种触发方式（handle 参数切换：false=整行长按 / true=仅手柄拖）；P2-A iOS UITableView+dragDelegate / Android LazyColumn+pointerInput（最轻量避免旧体系）；P3-A 仅释放后回调 onReorder(from,to)（一期最简，实时回调=二期）；P4-A 一期=基础拖拽排序+handle+enabled+onReorder+demo4段 |
| A4 | Demo 排查 4 组 | ✅ | D1 基础拖拽排序（3 项长按拖拽）；D2 handle 手柄模式（仅手柄可拖）；D3 disabled 禁用拖拽（纯列表不可拖）；D4 实时回调（拖拽后 Toast 显示新顺序） |
| A5 | 实现现状 | ✅ | iOS SharedUI/Components 无 Drag 封装=未实现；Android sharedui/components 无 Drag=未实现；api.json 无 ui.drag 条目待门禁 B 立项登记；双端纯从零 |
| A6 | 平台差异表 | ✅ | 表内放行：拖拽机制（UITableView drag delegate vs LazyColumn+pointerInput detectDragGesturesAfterLongPress）、落位动画（reloadData/moveRow vs animateItemPlacement，均 0.25s easeOut 视觉一致） |
| A7 | anti_goals 反目标 | ✅ | 跨列表拖拽=二期；多选批量拖拽=二期；网格拖拽=二期；拖拽中实时回调=二期 |

## 评审结论

| 项 | 内容 |
| -- | --- |
| 结论 | ✅ 通过（P1–P4 全 A/C，0 保留意见） |
| 用户签字 | （终核并入用户 C1.5 Demo 实机验收） |
| 下一步 | 门禁 B：api.json ui.drag 契约登记 → iOS DragListView.swift（UITableView+drag delegate）+ Android Drag.kt（LazyColumn+pointerInput）→ Demo 双端 1:1 → C1.5 |
