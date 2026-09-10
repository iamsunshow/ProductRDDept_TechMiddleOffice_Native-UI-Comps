# Pagination 分页 · 门禁 A 评审单（导航区组件 #71 · 全新立项）

> 组件 ID：`ui.pagination` ｜ 设计规格：`design-spec/pagination-design-spec.html`
> 评审方式：🖊 AI 代评（用户 2026-09-04 总授权"除特色组件外所有组件评审文档全部生成，中间任何询问直接通过"）
> 评审日期：2026-09-11 ｜ 终核：并入用户 C1.5 Demo 实机验收

## 评审清单

| # | 项 | 判定 | 说明 |
| - | -- | --- | --- |
| A1 | 组件边界（SCQA） | ✅ | 定位=受控页码驱动的分页器，数据分页翻页（同列表不同页数据）；与 Tabs #78（同屏页签切换不同面板，无翻页概念）划界=Pagination 数据分页翻页；与 InfiniteLoading #56（下拉触底自动加载，无显式页码）划界=Pagination 显式页码按钮翻页；与 BackTop #6（长页面回顶部）划界=Pagination 数据分页非滚动定位；与 Stepper #48（小范围数值增减无总页数）划界=Pagination 基于总页数跳页；双端纯从零（全仓无 PaginationView/Pagination.kt） |
| A2 | Token 零硬编码 | ✅ | 页码按钮 AppSpace.lg(36) 尺寸/AppFont.sizeSm/AppRadius.sm/textPrimary/primary；禁用态 gray25；上一页下一页 chevron textSecondary；省略号 gray25；简洁模式 AppFont.sizeSm/textPrimary/primary；按钮间距 AppSpace.xs(6)；容器 bgCard+radius.lg+border；全走 token |
| A3 | 决策投票表（ACE） | ✅ | P1-C 混合受控（currentValue>0=受控/0=内部自管理，A 纯受控淘汰=D1 样板多/B 纯非受控淘汰=D4 做不到）；P2-A 标准滑动窗口省略号（B 全量渲染淘汰=移动端按钮过密集不可点击）；P3-A 支持简洁模式 simple（B 只做按钮淘汰=简洁场景无方案）；P4-A 一期=基础翻页/简洁/省略号/自定义按钮数+demo 四段（跳页输入框/pageSize 选择器=二期） |
| A4 | Demo 排查 4 组 | ✅ | D1 基础分页（5 页全显无省略号，total=50/pageSize=10）；D2 简洁模式（x/y 文本翻页，mode=simple）；D3 显示省略号（10 页 itemSize=5，首尾+省略号折叠）；D4 自定义页码按钮数量（itemSize=3，3 按钮窗口+省略号） |
| A5 | 实现现状 | ✅ | iOS SharedUI/Components 无 PaginationView=未实现；Android sharedui/components 无 Pagination.kt=未实现；api.json 无 ui.pagination 条目待门禁 B 立项登记；Demo 列表已登记 reviewed=false 待改 reviewed=true/passed=true 挂 demo |
| A6 | 平台差异表 | ✅ | 表内放行：状态管理（属性 0 vs 参数 0 语义一致）、按钮横向排列（UIStackView vs Row spacedBy）、chevron（UIImage chevron.left/right vs Icons KeyboardArrowLeft/Right）、按钮选中态（backgroundColor=primary vs background(primary,shape)）、圆角裁切（layer.cornerRadius+clipsToBounds vs background(RoundedCornerShape) 遵安卓禁令）；视觉一致放行 |
| A7 | anti_goals 反目标 | ✅ | 跳页输入框=二期增量（一期按钮/省略号翻页优先）；自定义按钮渲染=二期；pageSize 选择器=二期；自定义翻页动画=二期；组件只做分页器不承载列表数据获取（数据层归业务） |

## 评审结论

| 项 | 内容 |
| -- | --- |
| 结论 | ✅ 通过（P1–P4 全选最优，0 保留意见） |
| 用户签字 | （终核并入用户 C1.5 Demo 实机验收） |
| 下一步 | 门禁 B api.json ui.pagination 契约登记 → 双端独立组件实现（PaginationView.swift / Pagination.kt）→ Demo 双端 1:1 四段 → C1.5 demo 实机 → C1 单测 → C2/D |
