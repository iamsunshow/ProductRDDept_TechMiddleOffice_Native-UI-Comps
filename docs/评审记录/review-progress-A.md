# Progress 进度条 · 门禁 A 评审单（信息展示区组件 #73 · 全新立项）

> 组件 ID：`ui.progress` ｜ 设计规格：`design-spec/progress-design-spec.html`
> 评审方式：🖊 AI 代评（用户 2026-09-04 总授权"除特色组件外所有组件评审文档全部生成，中间任何询问直接通过"）
> 评审日期：2026-09-11 ｜ 终核：并入用户 C1.5 Demo 实机验收

## 评审清单

| # | 项 | 判定 | 说明 |
| - | -- | --- | --- |
| A1 | 组件边界（SCQA） | ✅ | 定位=展示操作当前进度的横向进度条，填充宽度按百分比(0-100)自适应；与 CircleProgress #73（环形描边进度）划界=Progress 横向线性/矩形；与 Loading #60（不确定时长转圈）划界=Progress 有明确百分比；与 Skeleton #63（整页占位闪烁）划界=Progress 单条数值展示；与 Steps 步骤条划界=Progress 连续百分比线性/Steps 离散步骤节点；双端纯从零（全仓无 ProgressView.swift/Progress.kt） |
| A2 | Token 零硬编码 | ✅ | 轨道底色 gray6；填充色默认 primary；高度默认 8（无专用 token，参数默认值）；圆角=height/2 半圆；文字 AppFont.sizeSm/textPrimary；文字与条间距 AppSpace.sm；全走 token |
| A3 | 决策投票表（ACE） | ✅ | P1-A 0-100 clamp（B 不校验淘汰=越界溢出/C 0-1 小数淘汰=与 NutUI 惯例不符）；P2-C animated 参数开关默认 true（A 默认动画淘汰=不可关闭/B 无动画淘汰=动态更新生硬）；P3-A 右侧外部文字（B 条内嵌入淘汰=进度低时文字溢出/C 无文字淘汰=缺数值反馈）；P4-A 一期=基础/自定义颜色高度/百分比文字/动态进度+demo 四段（条纹/渐变/条内文字=二期） |
| A4 | Demo 排查 4 组 | ✅ | D1 基础进度条（percentage=30，默认 primary 填充）；D2 自定义颜色+高度（warn/12px + danger/4px 两条对照）；D3 百分比文字显示（showText=true，右侧显示 75%）；D4 动态进度（按钮驱动 percentage 递增，0→100 动画） |
| A5 | 实现现状 | ✅ | iOS SharedUI/Components 无 ProgressView=未实现；Android sharedui/components 无 Progress.kt=未实现；api.json 无 ui.progress 条目待门禁 B 立项登记；Demo 列表已登记 planned=true 待改 reviewed=true 挂 demo |
| A6 | 平台差异表 | ✅ | 表内放行：填充宽度更新（UIView.animate 0.3s vs animateFloatAsState tween 300 同曲线）、圆角裁切（layer.cornerRadius+clipsToBounds vs background RoundedCornerShape 遵安卓禁令）、百分比 clamp（min/max vs coerceIn 语义一致）、文字渲染（UILabel vs Text 同 token）；视觉一致放行 |
| A7 | anti_goals 反目标 | ✅ | 条纹样式(striped)=二期增量；条纹动画(animated stripe)=二期；渐变填充=二期；条内嵌入文字(textPosition inside)=二期；点击交互=Progress 纯展示，点击由宿主承载 |

## 评审结论

| 项 | 内容 |
| -- | --- |
| 结论 | ✅ 通过（P1–P4 全选最优，0 保留意见） |
| 用户签字 | （终核并入用户 C1.5 Demo 实机验收） |
| 下一步 | 门禁 B api.json ui.progress 契约登记 → 双端独立组件实现（ProgressView.swift / Progress.kt）→ Demo 双端 1:1 四段 → C1.5 demo 实机 → C1 单测 → C2/D |
