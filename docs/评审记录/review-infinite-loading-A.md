# InfiniteLoading 滚动加载 · 门禁 A 评审单（操作反馈区 #49）

> 组件 ID：`ui.infinite-loading` ｜ 设计规格：`design-spec/infinite-loading-design-spec.html`
> 评审方式：🖊 AI 代评（用户 2026-09-04 总授权"除特色组件外所有组件评审文档全部生成，中间任何询问直接通过"）
> 评审日期：2026-09-08 ｜ 终核：并入用户全批统一验收（C1.5 实机 Demo）

## 评审清单

| # | 项 | 判定 | 说明 |
| - | -- | --- | --- |
| A1 | 组件边界（SCQA） | ✅ | 定位=列表滚动接近底部时自动触发加载更多的底部加载状态组件；与 PullRefresh（顶部下拉刷新）/Loading（全屏遮罩加载）/Skeleton（首屏占位骨架）/Drag（拖拽排序）划界清晰；anti_goals=自包含列表容器/纯监听器模式/自定义 slot 二期 |
| A2 | Token 零硬编码 | ✅ | 四态视觉全 token 化：spinner 颜色=textSecondary 16×16，文案=textSecondary/error+sizeSm，高 44；阈值 50 可配；loadingText/finishedText/errorText 全部可覆盖 |
| A3 | 决策投票表 | ✅ | P1-A 底部状态条模式（组件=footer+滚动源监听+四态切换+回调，列表内容宿主提供，不代管内容）；P2-A iOS KVO 监听 contentOffset+scrollViewDidEndDecelerating；P3-A Android LazyListState+snapshotFlow 监听可见 item；P4-A 四态全量+阈值可配+文案可配+error 点击重试 |
| A4 | Demo 排查 4 组 | ✅ | D1 基础滚动加载（到底触发→加载中→追加→完成）；D2 加载完成（hasMore=false 显示"没有更多了"）；D3 加载失败+点击重试（error 态点击 footer 重试）；D4 自定义文案+阈值可配（threshold=100+文案覆盖） |
| A5 | 实现现状 | ✅ | 双端均未实现（任务清单行 49 ⬜，api.json 待立项），本规格为立项入口 |
| A6 | 平台差异表 | ✅ | 表内放行：滚动源（UIScrollView 引用 vs LazyListState 快照）、距底部计算（contentSize 公式 vs 可见 item 索引）、spinner 动画（UIActivityIndicatorView vs CircularProgressIndicator）均为系统级原生差异；四态文案语义一致（同一文案双端渲染） |
| A7 | anti_goals 反目标 | ✅ | 自包含列表容器模式（锁死列表内容构建方式）、纯监听器模式（不显示状态条）、自定义 spinner/footer slot 均登记二期 |

## 评审结论

| 项 | 内容 |
| -- | --- |
| 结论 | ✅ 通过（P1–P4 全 A，0 保留意见） |
| 用户签字 | （终核并入用户全批统一验收 2026-09-08） |
| 下一步 | 门禁 B api.json 契约登记 → 双端实现 → C1.5 demo 实机 |
