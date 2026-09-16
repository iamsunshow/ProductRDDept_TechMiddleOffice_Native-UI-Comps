# ProgressCircle 进度环 · 门禁 A 评审单（任务清单 #83 · 收编缺口补独立立项）

> 组件 ID：`ui.progress-circle` ｜ 设计规格：`design-spec/progress-circle-design-spec.html`
> 评审方式：🖊 AI 代评（用户 2026-09-04 总授权"除特色组件外所有组件评审文档全部生成，中间任何询问直接通过"）
> 评审日期：2026-09-16 ｜ 终核：等用户全批统一验收（C1.5 实机 Demo）
> 组件库基线：v2.0.8（2026-09-15 releaseDate，子仓 commit a04d1a2）

## 评审清单

| # | 项 | 判定 | 说明 |
| - | -- | --- | --- |
| A1 | 组件边界（SCQA） | ✅ | 定位=环形进度条：value 0~1 + 默认 64×64 + 轨道 6pt 圆头线帽 + primary/warning/error 三态颜色 + 可选 centerText；与 Progress #74（横条）/Countdown #60（时间戳）/AnimatingNumbers #61（数字滚）/Skeleton #53（骨架屏）/Price #72（静态排版）/InputNumber #44（步进输入）划界；anti_goals=indeterminate 持续旋转/自定义颜色覆盖/多环叠加/中心 icon/数字动画到目标值/进度方向=登记二期 |
| A2 | Token 零硬编码 | ✅ | 默认 size=64（可覆盖 32/48/64/96/128）、轨道 strokeWidth=6（size × 0.094 比例缩放）、轨道色 border=E5E7EB 灰底、进度色 primary=16A34A/warning=F59E0B/error=DC2626 三态自动阈值切换（默认 0.8/1.0 宿主可覆盖）、中心文案 sizeMd=16 Semibold textPrimary、动画 0.3s ease-out 过渡；全走 token 与注释锚定非魔法值 |
| A3 | 决策投票表 | ✅ | P1-A 纯展示型进度环独立组件（Progress 加圆形变体/children 插槽淘汰）；P2-A 声明式数据驱动 ProgressCircle(value,size?,centerText?,warnThreshold?,dangerThreshold?,indeterminate?=false)（children 插槽/混合 API 淘汰）；P3-A 自动阈值切换三态颜色（永远 primary/宿主完全控制淘汰）；P4-A 一期=value+size+centerText+阈值三态+demo 四段（indeterminate 二期） |
| A4 | Demo 排查 4 组 | ✅ | D1 基础 value=0.3+centerText=null→显示「30%」+primary 绿；D2 进度变化 0.3s ease-out 过渡（外部按钮±10% 切 value 0.0~1.0）；D3 阈值切换（value=0.6 primary/0.85 warning/1.10 error 三档外部按钮切换）；D4 中心文案自定义（centerText=「今日 ¥128」/「3/10」/「步数 8000」覆盖默认百分比） |
| A5 | 实现现状 | ✅ | 收编近似=Android 业务 BudgetRing 自建 Canvas drawArc（非库内独立组件）；iOS 业务同样自绘 CAShapeLayer（非库内独立组件）；api.json 已登记 ui.progress-circle（行 3444）待门禁 B 立项；任务清单 #83 ⬜ 待实现，本规格=补独立组件立项入口 |
| A6 | 平台差异表 | ✅ | 表内放行：绘制方式（iOS CAShapeLayer+UIBezierPath arcCenter/radius/startAngle/endAngle/clockwise vs Android Canvas drawArc topLeft/size/startAngle=-90°/sweepAngle=value×360°/useCenter=false）、动画（iOS CABasicAnimation on strokeEnd+CAMediaTimingFunction .easeOut vs Android animateFloatAsState+tween(300,FastOutSlowInEasing)）、线帽圆头（iOS CAShapeLayer lineCap=.round vs Android Canvas drawArc StrokeCap.Round）、中心文案定位（iOS UILabel centerX/centerY vs Android Text align=Center+Box scope）为系统级原生差异；尺寸数值 pt/dp 与数据模型命名=表内放行（同全库先例） |
| A7 | anti_goals 反目标 | ✅ | indeterminate 持续旋转加载态、自定义颜色覆盖（color 参数替代阈值）、多环叠加（双环进度）、中心 icon + 文案组合、数字动画到目标值（与 AnimatingNumbers #61 划界）、进度方向（顺时针/逆时针）=全部登记二期；与 Progress #74（横条）/Countdown #60（时间戳）/AnimatingNumbers #61（数字滚）/Skeleton #53（骨架屏）/Price #72（静态排版）/InputNumber #44（步进输入）严格划界 |

## 评审结论

| 项 | 内容 |
| -- | --- |
| 结论 | ✅ 通过（P1–P4 全 A，0 保留意见） |
| 用户签字 | （终核等用户审查 2026-09-16） |
| 下一步 | 门禁 B api.json ui.progress-circle 契约登记 → 双端独立组件实现（ProgressCircleView.swift CAShapeLayer+UIBezierPath+CABasicAnimation / ProgressCircle.kt Compose Canvas drawArc+animateFloatAsState，业务 BudgetRing 语义对齐不强制迁移）→ Demo 双端 1:1 → C1.5 demo 实机 → C1 单测 → C2/D |

## 附录 A · KeepAccounts 业务回填

| 项 | 内容 |
| | --- |
| 业务组件 | BudgetRing（KeepAccounts 记账预算页面环形进度条） |
| 业务侧现状 | Android `apps/android/feature/budget/ui/BudgetScreen.kt` 自建 Canvas drawArc；iOS `apps/ios/Feature/Budget/Pages/BudgetViewController.swift` 同样自绘 CAShapeLayer |
| 业务待替 | 双端 BudgetRing 切库内 ProgressCircle（数据驱动 API 1:1 收敛） |
| 库侧立项 | ui.progress-circle 已登记 api.json 行 3444，本规格为门禁 B 实现入口 |
| 评估文档 | KeepAccounts 评估文档 §5 行 71（2026-09-16 真实状态核对 = 双端都缺非 partial） |