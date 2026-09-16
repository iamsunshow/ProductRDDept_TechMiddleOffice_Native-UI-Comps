# LineChart Android · 门禁 A 评审单（任务清单 #96 · 业务展示补全）

> 组件 ID：`ui.line-chart`（Android 端补全，iOS 已 v1.7.5 收编）｜ 设计规格：`design-spec/line-chart-android-design-spec.html`
> 评审方式：🖊 AI 代评（用户 2026-09-04 总授权"除特色组件外所有组件评审文档全部生成，中间任何询问直接通过"）
> 评审日期：2026-09-16 ｜ 终核：等用户全批统一验收（C1.5 实机 Demo）
> 组件库基线：v2.0.8（2026-09-15 releaseDate，子仓 commit a04d1a2）

## 评审清单

| # | 项 | 判定 | 说明 |
| - | -- | --- | --- |
| A1 | 组件边界（SCQA） | ✅ | 定位=Android 端折线图独立组件（iOS 已 v1.7.5 收编基于 DGCharts/Charts 第三方库）：单/双折线 + 数据点 + 网格 + xLabels/yLabels + fixedYMin/Max；与 BarChart #97（条形图）/PieChart（业务二期）/AnimatingNumbers #61（数字滚）/Price #72（静态排版）/Countdown #60（时间戳自驱）/Progress #74/ProgressCircle #83（比例表达）划界；anti_goals=曲线/区域填充/多系列≥3/滚动缩放/tooltip/高频实时=登记二期 |
| A2 | Token 零硬编码 | ✅ | 默认 200dp 高（与 iOS inset spaceTop/Bottom=0.1 同构）、网格 0.5dp border=E5E7EB 横线 4 条、折线 strokeWidth=2dp primary=16A34A 圆头线帽（strokeCap=Round）、数据点彩圆 3dp + 白洞 1.5dp strokeWidth=1.5、Y 轴自适应 + 0.1 padding（fixedYMin/Max 可覆盖）、X 轴等分域 (i+0.5)/count（xLabels 可覆盖）、x/y 标签 sizeXs=12 textSecondary、双系列 series1 primary + series2 紫=8B5CF6；全走 token 与注释锚定非魔法值 |
| A3 | 决策投票表 | ✅ | P1-A Android 端独立组件双端 1:1 Canvas 自绘（引入 MPAndroidChart/children 插槽淘汰）；P2-A 声明式数据驱动 LineChart(values,data?,xLabels?,yLabels?,fixedYMin?,fixedYMax?)（双 API/children 淘汰）；P3-A 默认自适应+fixedYMin/Max 可覆盖（永远自适应/永远 fixed 淘汰）；P4-A 一期=数据驱动单/双折线+数据点+网格+labels+fixedYMin/Max+demo 四段（曲线/区域填充/多系列/滚动缩放/tooltip 二期） |
| A4 | Demo 排查 4 组 | ✅ | D1 单系列基础 values=[3,5,4,7,9,8,6]+data=null→单折线 primary 绿+7 圆点+4 网格+自适应 Y 轴；D2 双系列对比 values=[收入]+data=[支出] 双折线（series1 primary + series2 紫）+各自圆点；D3 xLabels 月份 values=12 个月+xLabels=[1月...12月]→底部对齐 X 标签 sizeXs textSecondary；D4 fixedYMin/Max 锁死基线 外部按钮「锁基线 0~100/自动」切换 |
| A5 | 实现现状 | ✅ | iOS LineChartView v1.7.5 已收编（基于 DGCharts/Charts 第三方库，业务展示区 #381 ✅，api.json 行 3617 已登记 reviewed=true）；Android 当前无独立 LineChart（业务 DualLineChart 自建 Canvas drawLine）；本规格=Android 端补全，与 iOS 同库同绘图语言双端 1:1 同构（iOS 是 Vendor 第三方库非库侧实现已澄清，Android 端 Canvas 自绘不引入第三方库=无版本依赖）；api.json ui.line-chart Android 端已登记 |
| A6 | 平台差异表 | ✅ | 表内放行：绘图引擎（iOS DGCharts/Charts 第三方库 vs Android Compose Canvas drawLine 自绘不引第三方库）、数据点（iOS ChartDataEntry + MarkerView vs Android drawCircle cx/cy/radius）、网格（iOS gridConfig vs Android Canvas drawLine 4 横线）、Y 轴（iOS DGCharts leftAxis spaceTop/Bottom=0.1 vs Android yFor() 函数 domain+0.1 padding）、坐标转换（iOS CGFloat vs Android Dp+Float）为系统级/选择路径差异；尺寸数值 pt/dp 与数据模型命名=表内放行（同全库先例）；**特别说明**：iOS 是 Vendor/Charts 第三方库非库侧实现已澄清，本规格 Android 端按 Canvas 自绘=与 iOS 视觉效果 1:1 同构但实现路径不同 |
| A7 | anti_goals 反目标 | ✅ | 曲线（贝塞尔插值）、区域填充（折线下渐变填充）、多系列 ≥3、滚动/缩放/平移交互、数据点 tooltip/MarkerView、堆叠/对比柱状混合、高频实时刷新=全部登记二期；与 BarChart #97（条形图）/PieChart（业务二期）/AnimatingNumbers #61（数字滚）/Price #72（静态排版）/Countdown #60（时间戳自驱）/Progress #74/ProgressCircle #83（比例表达）严格划界 |

## 评审结论

| 项 | 内容 |
| -- | --- |
| 结论 | ✅ 通过（P1–P4 全 A，0 保留意见） |
| 用户签字 | （终核等用户审查 2026-09-16） |
| 下一步 | 门禁 B api.json ui.line-chart 契约登记 → Android 端独立组件实现（LineChart.kt Compose Canvas drawLine+drawCircle+yFor()+xLabels/yLabels，与 iOS LineChartView v1.7.5 视觉 1:1 同构但 Canvas 自绘不引第三方库）→ Demo 双端 1:1 → C1.5 demo 实机 → C1 单测 → C2/D |

## 附录 A · KeepAccounts 业务回填

| 项 | 内容 |
| | --- |
| 业务组件 | DualLineChart（KeepAccounts 记账报表页双折线对比图） |
| 业务侧现状 | Android `apps/android/feature/report/ui/ReportScreen.kt` 自建 Canvas drawLine 双折线；iOS `apps/ios/Feature/Report/Pages/ReportViewController.swift` 现状依赖第三方库 Charts/DGCharts（v1.7.5 LineChartView） |
| 业务待替 | Android DualLineChart 切库内 LineChart（Canvas 自绘不引第三方库）；iOS 现状 LineChartView 库侧已是 DGCharts 第三方库，业务无需切换（库侧保持） |
| 库侧立项 | ui.line-chart api.json 行 3617 已登记 reviewed=true（iOS）；本规格=Android 端补全独立组件入口 |
| 评估文档 | KeepAccounts 评估文档 §5 行 72（2026-09-16 真实状态核对 = iOS 是 Vendor/Charts 第三方库非库侧实现；库侧 TrendChart 双端都缺） |