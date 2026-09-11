# 信息展示区六组件 · 门禁 A 评审单（Tag/Segmented/Table/Tour/ImagePreview/VirtualList）

> 组件 ID：`ui.tag` / `ui.segmented` / `ui.table` / `ui.tour` / `ui.image-preview` / `ui.virtual-list`
> 评审方式：AI 代评（用户 2026-09-04 总授权）
> 评审日期：2026-09-11 ｜ 终核：并入用户 C1.5 Demo 实机验收

## 一、Tag 标签（#78 ui.tag）

| # | 项 | 判定 | 说明 |
| - | -- | --- | --- |
| A1 | 组件边界 | ✅ | 彩色标签=状态标识/分类标记；与 Badge 划界=Tag 独立标签非锚点附属；双端从零 |
| A2 | Token 零硬编码 | ✅ | 颜色 AppColor.primary/success/warning/error；圆角 AppRadius.sm；全走 token |
| A3 | 决策投票 | ✅ | P1-A 三形态 filled/outline/light；P2-A 四色；P3-A 三尺寸 sm/md/lg；P4-A 可选关闭 |
| A4 | Demo 4 组 | ✅ | D1 三形态 / D2 四色 / D3 三尺寸 / D4 可关闭 |
| A5 | 实现现状 | ✅ | iOS TagView.swift + Android Tag.kt 双端新建；Demo 双端 4 段 1:1 |
| A6 | 平台差异 | ✅ | 关闭图标（SF Symbols vs Material Icons）；视觉一致放行 |
| A7 | 反目标 | ✅ | 动画过渡=二期；自定义形状=二期 |

## 二、Segmented 分段选择器（#74 ui.segmented）

| # | 项 | 判定 | 说明 |
| - | -- | --- | --- |
| A1 | 组件边界 | ✅ | 胶囊式分段控件=页内互斥切换；泛化自 SegmentControl/PeriodTabsView |
| A2 | Token 零硬编码 | ✅ | 轨道 bgPage；选中 textPrimary；字号 sizeSm SemiBold；圆角 AppRadius.md |
| A3 | 决策投票 | ✅ | P1-A 等分填充；P2-B 支持禁用项；P3-B 固定宽度+通栏 |
| A4 | Demo 4 组 | ✅ | D1 基础 3 项 / D2 固定宽度 / D3 禁用项 / D4 通栏 |
| A5 | 实现现状 | ✅ | iOS SegmentedView.swift + Android Segmented.kt 双端新建；Demo 双端 4 段 1:1 |
| A6 | 平台差异 | ✅ | 选中块形状（UIView vs Compose Shape）；视觉一致放行 |
| A7 | 反目标 | ✅ | 滑动动画=二期；图标+文字混合=二期 |

## 三、Table 表格（#77 ui.table）

| # | 项 | 判定 | 说明 |
| - | -- | --- | --- |
| A1 | 组件边界 | ✅ | 数据表格=行列布局；与 List 划界=Table 多列+表头 |
| A2 | Token 零硬编码 | ✅ | 边框 border；文字 textPrimary/textSecondary；圆角 AppRadius.lg |
| A3 | 决策投票 | ✅ | P1-A 静态表格；P2-B 斑马纹；P3-B 自定义列宽+对齐 |
| A4 | Demo 4 组 | ✅ | D1 基础 3 列 4 行 / D2 斑马纹 / D3 自定义列宽+对齐 / D4 表头吸顶样式 |
| A5 | 实现现状 | ✅ | iOS TableView.swift + Android Table.kt 双端新建；Demo 双端 4 段 1:1 |
| A6 | 平台差异 | ✅ | 横向滚动（UIScrollView vs horizontalScroll）；视觉一致放行 |
| A7 | 反目标 | ✅ | 真实吸顶=二期；可编辑单元格=二期；排序筛选=二期 |

## 四、Tour 引导（#79 ui.tour）

| # | 项 | 判定 | 说明 |
| - | -- | --- | --- |
| A1 | 组件边界 | ✅ | 步骤式引导浮层=遮罩+中央卡片；与 Overlay 划界=Tour 多步引导 |
| A2 | Token 零硬编码 | ✅ | 遮罩 Black 70%；卡片 bgCard+AppRadius.lg；按钮 primary/bgPage |
| A3 | 决策投票 | ✅ | P1-A 中央卡片；P2-B 支持跳过；P3-A 基础遮罩+卡片+步骤切换 |
| A4 | Demo 4 组 | ✅ | D1 基础 3 步 / D2 隐藏跳过 / D3 单步 / D4 自定义遮罩色 |
| A5 | 实现现状 | ✅ | iOS TourView.swift + Android Tour.kt 双端新建；Demo 双端 4 段 1:1 |
| A6 | 平台差异 | ✅ | 遮罩实现（UIView vs Compose Box）；视觉一致放行 |
| A7 | 反目标 | ✅ | 高亮挖孔=二期；箭头指向=二期 |

## 五、ImagePreview 图片预览（#68 ui.image-preview）

| # | 项 | 判定 | 说明 |
| - | -- | --- | --- |
| A1 | 组件边界 | ✅ | 全屏图片预览=多图横滑+指示器；与 Image 划界=全屏多图画廊 |
| A2 | Token 零硬编码 | ✅ | 背景 Black；指示器 White/White 40%；字号 sizeDisplay/sizeSm |
| A3 | 决策投票 | ✅ | P1-A HorizontalPager/UIScrollView；P2-B 圆点+页码；P3-A 占位色块 |
| A4 | Demo 4 组 | ✅ | D1 基础 3 张 / D2 指定初始页 / D3 隐藏指示器 / D4 单图 |
| A5 | 实现现状 | ✅ | iOS ImagePreviewView.swift + Android ImagePreview.kt 双端新建；Demo 双端 4 段 1:1 |
| A6 | 平台差异 | ✅ | 横滑容器（UIPageViewController vs HorizontalPager）；视觉一致放行 |
| A7 | 反目标 | ✅ | 双指缩放=二期；拖拽关闭=二期；真实图片加载=二期 |

## 六、VirtualList 虚拟列表（#81 ui.virtual-list）

| # | 项 | 判定 | 说明 |
| - | -- | --- | --- |
| A1 | 组件边界 | ✅ | 大数据量虚拟滚动=仅渲染可见区域；与 List 划界=专注大数据量虚拟化 |
| A2 | Token 零硬编码 | ✅ | 背景 bgPage/bgCard；文字 textPrimary/textSecondary；分隔线 0.5dp |
| A3 | 决策投票 | ✅ | P1-A LazyColumn/UITableView；P2-B 固定行高+自适应；P3-A 分隔线+空态 |
| A4 | Demo 4 组 | ✅ | D1 基础 100 条 / D2 双行副标题 / D3 无分隔线 / D4 空态 |
| A5 | 实现现状 | ✅ | iOS VirtualListView.swift + Android VirtualList.kt 双端新建；Demo 双端 4 段 1:1 |
| A6 | 平台差异 | ✅ | 虚拟化容器（LazyColumn vs UITableView）；视觉一致放行 |
| A7 | 反目标 | ✅ | 下拉刷新=二期；上拉加载=二期；滑动删除=二期 |

## 评审结论

| 项 | 内容 |
| -- | --- |
| 结论 | ✅ 六组件全部通过（P1-P4 全选最优，0 保留意见） |
| 用户签字 | （终核并入用户 C1.5 Demo 实机验收） |
| 下一步 | 门禁 B api.json 契约登记 → 双端实现入库 → Demo 双端 1:1 → C1.5 demo 实机 → C1 单测 → C2/D |
