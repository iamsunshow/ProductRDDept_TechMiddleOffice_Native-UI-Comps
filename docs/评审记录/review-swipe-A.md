# Swipe 滑动 · 门禁 A 评审单（操作反馈区 #58）

> 组件 ID：`ui.swipe` ｜ 设计规格：`design-spec/swipe-design-spec.html`
> 评审方式：🖊 AI 代评（用户 2026-09-04 总授权"除特色组件外所有组件评审文档全部生成，中间任何询问直接通过"）
> 评审日期：2026-09-09 ｜ 终核：并入用户全批统一验收（C1.5 实机 Demo）

## 评审清单

| # | 项 | 判定 | 说明 |
| - | -- | --- | --- |
| A1 | 组件边界（SCQA） | ✅ | 定位=列表项横向滑动露出操作按钮（左右双向+自定义操作文本/颜色/回调）；与 Drag #47（长按拖拽排序 vs 横向滑动露操作）/ActionSheet #44（底部弹出遮罩 vs 列表项内嵌无遮罩）/Notify #52（全局短时浮层 vs 列表项持续）/Checkbox #25（点击勾选 vs 滑动露操作）/Switch #29（拨动二态 vs 滑动操作列表）划界清晰；anti_goals=自定义操作内容/阈值可配/嵌套 Swipe/上下滑/Lottie |
| A2 | Token 零硬编码 | ✅ | 视觉全 token 化：操作按钮宽 80dp、高度撑满主内容、文字 fontMd(16) 白色、主内容 bgCard 白底、primary(#16A34A)/danger(#DC2626)/warning(#F59E0B)/default(#6B7280) 四色、滑动动画 0.25s easeOut |
| A3 | 决策投票表 | ✅ | P1-A SwipeItem 包裹器（双向+自定义操作=与 NutUI/Vant SwipeAction 一致）；P2-A 手动偏移+动画（UIPanGestureRecognizer/detectHorizontalDragGestures 双端同构=阈值可控松手回弹）；P3-A iOS UIView+UIPanGestureRecognizer+手动 transform 偏移；P4-A Android Box+pointerInput(detectHorizontalDragGestures)+offset 动画 |
| A4 | Demo 排查 4 组 | ✅ | D1 基础右滑删除（actions=[删除 danger]）；D2 双向滑动（左滑标记 primary+右滑删除 danger）；D3 disabled 禁用（滑动无响应主内容可点）；D4 自定义多操作（置顶 warning+删除 danger 双按钮各 80dp） |
| A5 | 实现现状 | 🆕 | 全新立项，双端无旧实现。SwipeItem（横向滑动容器+主内容+左右操作列表）+ SwipeAction（text/color/onClick 数据结构） |
| A6 | 平台差异表 | ✅ | 表内放行：手势实现（UIPanGestureRecognizer vs detectHorizontalDragGestures，视觉一致=滑动露出操作）、动画实现（UIView.animate easeOut 0.25s vs animateFloatAsState tween 250ms，时长曲线一致）、操作按钮布局（UIView subview 绝对定位 vs Box Row 绝对定位） |
| A7 | anti_goals 反目标 | ✅ | 自定义操作按钮内容（图标/自定义视图）、滑动距离阈值可配、嵌套 Swipe、滑动方向自由（上下）、Lottie 均登记二期 |

## 评审结论

| 项 | 内容 |
| -- | --- |
| 结论 | ✅ 通过（P1–P4 全 A，0 保留意见） |
| 用户签字 | （终核并入用户全批统一验收 2026-09-09） |
| 下一步 | 门禁 B api.json ui.swipe 契约登记 → 双端实现 → C1.5 demo 实机 |
