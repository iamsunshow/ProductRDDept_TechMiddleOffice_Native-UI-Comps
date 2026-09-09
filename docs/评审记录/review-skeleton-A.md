# Skeleton 骨架屏 · 门禁 A 评审单（操作反馈区 #57）

> 组件 ID：`ui.skeleton` ｜ 设计规格：`design-spec/skeleton-design-spec.html`
> 评审方式：🖊 AI 代评（用户 2026-09-04 总授权"除特色组件外所有组件评审文档全部生成，中间任何询问直接通过"）
> 评审日期：2026-09-09 ｜ 终核：并入用户全批统一验收（C1.5 实机 Demo）

## 评审清单

| # | 项 | 判定 | 说明 |
| - | -- | --- | --- |
| A1 | 组件边界（SCQA） | ✅ | 定位=首屏/加载过渡期占位骨架（灰块模拟内容布局+shimmer 扫光）；与 InfiniteLoading #49（底部增量状态条）/Loading #50（全屏遮罩旋转指示器）/PullToRefresh #55（下拉触发刷新）/Empty #48（无数据空状态）/ResultPage #56（操作结果）划界清晰；anti_goals=自定义 shimmer 颜色/方向、切换动画、动态行数、Lottie |
| A2 | Token 零硬编码 | ✅ | 视觉全 token 化：骨架底色 gray100(#F3F4F6)+高亮 gray200(#E5E7EB)、行圆角 radiusSm(6)、头像 40×40 radiusFull、行高 12dp、标题宽 70% 副标题 40%、shimmer 1.5s linear infinite |
| A3 | 决策投票表 | ✅ | P1-A 原子块+包裹器双模式（SkeletonBlock 灵活+SkeletonRow 开箱即用）；P2-A linear-gradient 横向扫光（双端同构，CAGradientLayer/Brush.linearGradient）；P3-A iOS UIView+CAGradientLayer；P4-A Android Box+Brush.linearGradient |
| A4 | Demo 排查 4 组 | ✅ | D1 列表项骨架行（3 行 avatar+title+subtitle 2s 后切换）；D2 自定义骨架块组合（大块+小行模拟卡片）；D3 无头像骨架行（avatar=false）；D4 圆形骨架（radius=radiusFull 64×64） |
| A5 | 实现现状 | 🆕 | 全新立项，双端无旧实现。SkeletonBlock（原子块 width/height/radius）+ SkeletonRow（包裹器 loading/avatar/titleWidth/subtitle/subtitleWidth + content slot）双模式 |
| A6 | 平台差异表 | ✅ | 表内放行：shimmer 实现（CAGradientLayer vs Brush.linearGradient，视觉一致扫光）、骨架块圆角（layer.cornerRadius vs Modifier.clip） |
| A7 | anti_goals 反目标 | ✅ | 自定义 shimmer 颜色/速度/方向、切换动画、动态行数、Lottie 均登记二期 |

## 评审结论

| 项 | 内容 |
| -- | --- |
| 结论 | ✅ 通过（P1–P4 全 A，0 保留意见） |
| 用户签字 | （终核并入用户全批统一验收 2026-09-09） |
| 下一步 | 门禁 B api.json 契约登记 → 双端实现 → C1.5 demo 实机 |
