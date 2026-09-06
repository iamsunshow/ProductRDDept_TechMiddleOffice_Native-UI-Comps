# InputNumber 数字输入 · 门禁 A 评审单（任务清单 #30 · 全新立项）

> 组件 ID：`ui.input-number` ｜ 设计规格：`design-spec/input-number-design-spec.html`
> 评审方式：🖊 AI 代评（用户 2026-09-04 总授权"除特色组件外所有组件评审文档全部生成，中间任何询问直接通过"，数据录入区顺延三件批）
> 评审日期：2026-09-06 ｜ 终核：并入用户 C1.5 Demo 实机验收

## 评审清单

| # | 项 | 判定 | 说明 |
| - | -- | --- | --- |
| A1 | 组件边界（SCQA） | ✅ | 定位=步进式数字输入内容组件（− 值 +，无键盘/弹层）；与 Input（自由文本+键盘）/Range（滑杆）/MoneyFormat（大数金额精度）划界；anti_goals=键盘直输/长按连续加速/滑动手势=二期（随 Input 能力与手势机制立项） |
| A2 | Token 零硬编码 | ✅ | 整高 32、按钮 32、值区 min 宽 40、按钮字符 Lg18、值 Md16、precision 展示规整、边界/禁用 40% 灰（textTertiary）、按钮圆角 radiusSm；防浮点=定点（Decimal/BigDecimal）语义双端同构；全走 token 与注释锚定 |
| A3 | 决策投票表 | ✅ | P1-A 步进器（min/max/step/precision/disabled 半受控 value，B 值区键盘直输/C 长按滑动淘汰二期）；P2-A Number/Double 值 + 显式 precision 展示与对齐（字符串/整数专用淘汰）；P3-A 半受控 value（外部赋值同步刷新不触发 onChange、边界按钮幂等无回调）；P4-A 一期=步进+边界禁用+精度+禁用+demo 四段（键盘直输/长按二期） |
| A4 | Demo 排查 4 组 | ✅ | D1 基础整数步进（1~99 数量增减+边界灰）；D2 边界禁用（1~6 达界按钮灰禁幂等）；D3 小数精度（step 0.5 precision 1 规整无浮点尾差）；D4 整控件禁用 + 受控外部驱动（重置同步不触发 onChange） |
| A5 | 实现现状 | ✅ | 双端均未实现；api.json 无 ui.input-number 条目待立项登记；任务清单 #30 ⬜（本规格=立项入口） |
| A6 | 平台差异表 | ✅ | 表内放行：按压反馈（touchDown vs ripple）、定点运算宿主 API（Decimal vs BigDecimal，同算法）、按钮圆角 API、禁用机制（isUserInteractionEnabled vs enabled=false）、尺寸数值 pt/dp 与命名（同全库先例） |
| A7 | anti_goals 反目标 | ✅ | 值区键盘直输、长按连续/加速步进、滑动手势改值、弹层与键盘拉起=全部登记二期或宿主职责 |

## 评审结论

| 项 | 内容 |
| -- | --- |
| 结论 | ✅ 通过（P1–P4 全 A，0 保留意见） |
| 用户签字 | （终核并入用户 C1.5 Demo 实机验收 2026-09-06） |
| 下一步 | 门禁 B api.json 契约登记 → 双端独立组件实现（InputNumberView.swift / InputNumber.kt）→ Demo 双端 1:1 → C1.5 demo 实机 → C1 单测 → C2/D |
