# PullToRefresh 下拉刷新 · 门禁 A 评审单（操作反馈区 #55）

> 组件 ID：`ui.refresh` ｜ 设计规格：`design-spec/refresh-design-spec.html`
> 评审方式：🖊 AI 代评（用户 2026-09-04 总授权"除特色组件外所有组件评审文档全部生成，中间任何询问直接通过"）
> 评审日期：2026-09-09 ｜ 终核：并入用户全批统一验收（C1.5 实机 Demo）

## 评审清单

| # | 项 | 判定 | 说明 |
| - | -- | --- | --- |
| A1 | 组件边界（SCQA） | ✅ | 定位=列表/可滚动内容下拉触发刷新的容器组件；与 InfiniteLoading #49（底部自动加载）/Loading #50（全屏遮罩加载）/Skeleton #57（首屏骨架占位）/Drag #47（拖拽排序）/Swipe #58（侧滑操作）划界清晰；anti_goals=自定义头部/多类型指示器/刷新成功提示二期 |
| A2 | Token 零硬编码 | ✅ | 视觉全 token 化：指示器圆圈 22×22 strokeWidth=2 color=textSecondary；文案 textSecondary+sizeSm(14)；背景 bgCard；阈值 72dp、maxPull=threshold×1.6、hold=64dp、收起动画 tween 220ms；阻尼系数 0.55 |
| A3 | 决策投票表 | ✅ | P1-A 内容包裹器模式（不代管内容，宿主提供滚动容器）；P2-A iOS 风格顶开模式（灰圈+文案，非浮层）；P3-A iOS UIRefreshControl 系统原生（浮层，系统级差异放行）；P4-A Android NestedScrollConnection 顶开模式（复用现有 IosStylePullRefresh） |
| A4 | Demo 排查 4 组 | ✅ | D1 基础下拉刷新（10 行列表，下拉触发 2s 后结束）；D2 自定义文案（title="正在刷新最新数据"）；D3 禁用下拉（enabled=false）；D4 外部驱动刷新（按钮控制 refreshing） |
| A5 | 实现现状 | 🟡 | 双端已有旧实现（iOS PullRefreshTableView=UITableView 子类；Android IosStylePullRefresh=Compose wrapper），但 API 与 api.json 契约不一致（旧实现用 endRefreshing() 命令式，api.json 要求 refreshing 受控），需重构适配 |
| A6 | 平台差异表 | ✅ | 表内放行：指示器实现（UIRefreshControl 浮层 vs 自定义顶开）、下拉阻尼（系统 vs 0.55）、收起动画（系统 vs tween 220ms）—— 均为系统级原生差异，视觉一致（灰圈+文案） |
| A7 | anti_goals 反目标 | ✅ | 自定义头部样式、多类型指示器、刷新成功提示、下拉同时加载更多均登记二期 |

## 评审结论

| 项 | 内容 |
| -- | --- |
| 结论 | ✅ 通过（P1–P4 全 A，0 保留意见） |
| 用户签字 | （终核并入用户全批统一验收 2026-09-09） |
| 下一步 | 门禁 B api.json 契约登记 → 双端实现重构（适配 refreshing 受控）→ C1.5 demo 实机 |
