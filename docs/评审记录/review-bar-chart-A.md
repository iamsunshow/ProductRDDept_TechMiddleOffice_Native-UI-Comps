# BarChart 条形图 · 门禁 A 评审单（任务清单 #97 · 业务展示补全）

> 组件 ID：`ui.bar-chart` ｜ 设计规格：`design-spec/bar-chart-design-spec.html`
> 评审方式：🖊 AI 代评（用户 2026-09-04 总授权"除特色组件外所有组件评审文档全部生成，中间任何询问直接通过"）
> 评审日期：2026-09-16 ｜ 终核：等用户全批统一验收（C1.5 实机 Demo）
> 组件库基线：v1.0.8（2026-09-15 releaseDate，子仓 commit a04d1a2）

## 评审清单

| # | 项 | 判定 | 说明 |
| - | -- | --- | --- |
| A1 | 组件边界（SCQA） | ✅ | 定位=横向条形图独立组件（双端均缺全新立项）：items=[BarItem{label,value}] + warnThreshold=0.8 / dangerThreshold=1.0 三态颜色 + 0.3s 过渡；与 LineChart #96（折线）/PieChart（业务二期）/Progress #74（横条进度）/ProgressCircle #83（圆环）/Price #72（静态排版）划界；anti_goals=纵向柱状/堆叠柱状/分组柱状/饼图/自定义颜色/点击回调 onSelect/滚动超长=登记二期 |
| A2 | Token 零硬编码 | ✅ | 行高 24dp（label 区域 64dp 宽 + 轨道 16dp 高 + 数值标签 48dp 宽 + 间隔 10dp）、条高 16dp 圆角 4dp strokeCap=Round、轨道色 bgGrayLight=F3F4F6、填充色 primary=16A34A/warning=F59E0B/error=DC2626 三态阈值自动切换、类别标签 64dp 宽 sizeXs=12 textSecondary 右对齐、数值标签 48dp 宽 sizeSm=14 Semibold textPrimary 左对齐、动画 0.3s ease-out 过渡；全走 token 与注释锚定非魔法值 |
| A3 | 决策投票表 | ✅ | P1-A 横向条形图独立组件双端从零 Canvas 自绘（LineChart 加条形模式/children 插槽淘汰；与 LineChart #96 同策略不引入第三方库）；P2-A 声明式数据驱动 BarChart(items: [BarItem], warnThreshold?=0.8, dangerThreshold?=1.0)（双 API/children 淘汰）；P3-A 一期仅横向（业务 AssetTypeBarChart 当前形态；竖向柱状/双向登记二期）；P4-A 一期=数据驱动横向条形+数值标签+阈值三态+0.3s 过渡+demo 四段（堆叠/分组/点击交互/滚动超长二期） |
| A4 | Demo 排查 4 组 | ✅ | D1 基础 5 类别 items=[餐饮,交通,购物,娱乐,其他] value=[800,500,1200,300,600] 按 maxValue=1200 比例填充 primary 绿+数值标签；D2 阈值切换 value=[240,180,320,100,200] maxValue=320 触发 warning orange + value 320=100% 触发 error red；D3 7 类别 Top 排行 items=7 项 value=[1000,800,...,200] 降序+primary 绿；D4 0.3s 过渡 外部按钮「重置动画」运行期重设 value 触发 0.3s ease-out 过渡 |
| A5 | 实现现状 | ✅ | 收编近似=iOS 业务依赖第三方库 Charts/DGCharts BarChartView（非库内独立组件）；Android 业务 AssetTypeBarChart 自建 Canvas drawRoundRect 拼装（非库内独立组件）；api.json 无 ui.bar-chart 条目（本批门禁 B 立项登记）；任务清单 #97 ⬜ 待实现，本规格=补独立组件立项入口（组件进度.md §3.7 行 382 已登记 v2.0 todo） |
| A6 | 平台差异表 | ✅ | 表内放行：绘制方式（iOS UIView draw(_:) UIBezierPath roundedRect+UIColor.setFill vs Android Compose Canvas drawRoundRect topLeft/size/cornerRadius/style=Fill）、动画（iOS UIView.animate withDuration 0.3s curveEaseOut+layer transform vs Android animateFloatAsState+tween(300,FastOutSlowInEasing)）、行布局（iOS UIStackView spacing=10 vs Android Column verticalArrangement spacedBy(10.dp)）、标签字体（iOS UIFont.system(size:12,weight:.regular)+right vs Android Text sizeXs=12+textAlign=End）、数值字体（iOS UIFont(size:14,weight:.semibold) vs Android Text sizeSm=14+FontWeight.SemiBold）为系统级原生差异；尺寸数值 pt/dp 与数据模型命名=表内放行（同全库先例）；**特别说明**：iOS 业务现状依赖第三方库 Charts/DGCharts BarChartView，本规格=双端从零 Canvas 自绘不引入第三方库，与 LineChart #96 同策略（评估文档 §5 修正段已澄清 iOS 是 Vendor/Charts 第三方库非库侧实现） |
| A7 | anti_goals 反目标 | ✅ | 纵向柱状图、堆叠柱状（多系列堆叠）、分组柱状（多系列分组）、饼图/环形分布（业务二期独立组件）、自定义颜色覆盖（color 参数替代阈值）、交互（点击条形回调 onSelect(index)）、滚动超长列表（>10 项）=全部登记二期；与 LineChart #96（折线）/PieChart（业务二期）/Progress #74（横条进度）/ProgressCircle #83（圆环）/Price #72（静态排版）严格划界 |

## 评审结论

| 项 | 内容 |
| -- | --- |
| 结论 | ✅ 通过（P1–P4 全 A，0 保留意见） |
| 用户签字 | （终核等用户审查 2026-09-16） |
| 下一步 | 门禁 B api.json ui.bar-chart 契约登记（新条目）→ 双端独立组件实现（BarChartView.swift UIView draw(_:)+UIBezierPath roundedRect+UIView.animate / BarChart.kt Compose Canvas drawRoundRect+animateFloatAsState，业务 AssetTypeBarChart 语义对齐不强制迁移）→ Demo 双端 1:1 → C1.5 demo 实机 → C1 单测 → C2/D |

## 附录 A · KeepAccounts 业务回填

| 项 | 内容 |
| | --- |
| 业务组件 | AssetTypeBarChart（KeepAccounts 记账资产页面资产类型条形图） |
| 业务侧现状 | Android `apps/android/feature/assets/ui/AssetsScreen.kt` 自建 Canvas drawRoundRect 拼装；iOS `apps/ios/Feature/Assets/Pages/AssetsViewController.swift` 现状依赖第三方库 Charts/DGCharts BarChartView（v1.7.5 库侧 LineChartView 已含 BarChart 同库组件） |
| 业务待替 | Android AssetTypeBarChart 切库内 BarChart（Canvas 自绘不引第三方库）；iOS 业务现状=第三方库，库内 BarChart 上线后业务可选择性迁移（库侧保持） |
| 库侧立项 | ui.bar-chart api.json 无条目（本批门禁 B 立项登记）；组件进度.md §3.7 行 382 已登记 v2.0 todo |
| 评估文档 | KeepAccounts 评估文档 §5 行 73（2026-09-16 真实状态核对 = iOS 是 Vendor/Charts 第三方库非库侧实现；库侧 BarChart 双端都缺） |