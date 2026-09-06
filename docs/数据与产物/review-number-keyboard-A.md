# NumberKeyboard 数字键盘 · 门禁 A 评审单（任务清单 #32 · 全新立项）

> 组件 ID：`ui.number-keyboard` ｜ 设计规格：`design-spec/number-keyboard-design-spec.html`
> 评审方式：🖊 AI 代评（用户 2026-09-04 总授权"除特色组件外所有组件评审文档全部生成，中间任何询问直接通过"，数据录入区 #32 顺延单件）
> 评审日期：2026-09-06 ｜ 终核：并入用户 C1.5 Demo 实机验收

## 评审清单

| # | 项 | 判定 | 说明 |
| - | -- | --- | --- |
| A1 | 组件边界（SCQA） | ✅ | 定位=内嵌式数字键盘面板（4 行×4 列键格=3 数字列+右列确认竖条，固定高 208，纯事件回调无自带遮罩/浮层）；与业务 AmountKeyboard（business.amount-keyboard，记账金额强业务）划界=本组件通用裸键格无金额语义；与 Input #29 划界=Input=系统键盘输入控件、NumberKeyboard=自绘键盘面板（宿主组合显隐）；anti_goals=遮罩/底部弹层/滑入动画/乱序/长按连删/振动/键盘持值=二期或宿主职责 |
| A2 | Token 零硬编码 | ✅ | 行高 52×4=208、键字号 22（sizeXl 数字）/14（sizeSm 删除）/16（Md 确认）、灰 40% 禁用、hairline 网格线、primary 确认列白字、白底 bgCard；全走 token 与注释锚定非魔法值 |
| A3 | 决策投票表 | ✅ | P1-A 内嵌键盘面板无浮层收敛（B 自带遮罩弹层/ C 复用业务 AmountKeyboard 淘汰登记）；P2-A 固定键格+showDot/extraKey 少量开关（B 键矩阵数据驱动过度、C 无事件分类淘汰）；P3-A 纯事件驱动键盘零状态（onInput/onDelete/onConfirm，值在宿主，disabled/confirmDisabled 外部受控；B 半受控持值/C 受控拼串淘汰）；P4-A 一期=键格+开关+confirmText+demo 四段（遮罩弹层/乱序/连删/振动二期） |
| A4 | Demo 排查 4 组 | ✅ | D1 金额录入（底行首格 .、空值确认灰）；D2 短信验证码（showDot=false 首格空占位灰、宿主限 6 位联动 confirmDisabled）；D3 身份证（extraKey=X 底键上屏、限 18 位）；D4 禁用态+外部驱动（disabled 整键盘灰、confirmDisabled 独立控制确认列） |
| A5 | 实现现状 | ✅ | 双端均未实现；api.json 无 ui.number-keyboard 条目待立项登记；任务清单 #32 ⬜（本规格=立项入口）；双端 demo 注册已留占位（iOS DemoComponent ui.number-keyboard reviewed:false / Android DemoComponent("NumberKeyboard 数字键盘")）待接线；固定键格=无弹层依赖（Popup #54 未实现不阻塞） |
| A6 | 平台差异表 | ✅ | 表内放行：按压反馈（touchDown vs ripple）、键格实现（UIStackView vs Row weight）、高度机制（intrinsicContentSize vs 固定高）、文字渲染、hairline 线宽（iOS 1/scale pt vs Android 0.5dp）、pt/dp 与命名（同全库先例） |
| A7 | anti_goals 反目标 | ✅ | 遮罩/底部弹层/滑入动画（随 Popup #54/Overlay #6 组合二期）、乱序 randomKey/长按连删/振动（二期）、键盘持值或金额语义（值宿主自理、金额=业务 AmountKeyboard）=全部登记二期或宿主职责 |

## 评审结论

| 项 | 内容 |
| -- | --- |
| 结论 | ✅ 通过（P1–P4 全 A，0 保留意见） |
| 用户签字 | （终核并入用户 C1.5 Demo 实机验收 2026-09-06） |
| 下一步 | 门禁 B api.json 契约登记 → 双端独立组件实现（NumberKeyboardView.swift / NumberKeyboard.kt）→ Demo 双端 1:1 → C1.5 demo 实机 → C1 单测 → C2/D |
