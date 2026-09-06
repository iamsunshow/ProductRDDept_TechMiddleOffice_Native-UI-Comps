# Checkbox 复选 · 门禁 A 评审单（任务清单 #25 · 全新立项）

> 组件 ID：`ui.checkbox` ｜ 设计规格：`design-spec/checkbox-design-spec.html`
> 评审方式：🖊 AI 代评（用户 2026-09-04 总授权"除特色组件外所有组件评审文档全部生成，中间任何询问直接通过"，数据录入区缺口补齐批）
> 评审日期：2026-09-06 ｜ 终核：并入用户 C1.5 Demo 实机验收

## 评审清单

| # | 项 | 判定 | 说明 |
| - | -- | --- | --- |
| A1 | 组件边界（SCQA） | ✅ | 定位=通用复选双形态（单只 Checkbox + CheckboxGroup 垂直多选列表，方形圆角勾选框 20 + label 后置）；与协议行 AgreementCheckRow（业务收编富文本行，圆形 12dp 场景专用=职责边界不混入）/ 开关 Switch 类（二元即时拨动）/ 单选 Radio（排他）=划界；富文本=协议行职责 |
| A2 | Token 零硬编码 | ✅ | 勾选框 20、圆角 6、未选描边 1.5 textTertiary、选中底 primary+白勾 13、label Md16 间距 8、组行距 4+上下 padding 10、禁用 textTertiary 40% 灰；全走 token 与注释锚定 |
| A3 | 决策投票表 | ✅ | P1-A 单只+组双形态通用复选（B 仅组淘汰/C 复用协议行圆形淘汰）；P2-A CheckboxOption(value,label,disabled)+selected Set 数据驱动（字符串数组/嵌套树淘汰）；P3-A 半受控 selected 可选传（外部赋值同步刷新不触发 onChange、nil 内部自持）；P4-A 一期=方框+label+组多选+disabled（已选禁用保留勾）+外部驱动 demo 四段（indeterminate 半选/嵌套分组/动画二期） |
| A4 | Demo 排查 4 组 | ✅ | D1 单只基础（未选→点选→取消段内回显）；D2 Group 多选（4 项独立勾选集合回显）；D3 disabled（项级灰禁不可点+已选禁用灰勾保留）；D4 受控外部驱动（外部重置/全选同步勾选不触发 onChange） |
| A5 | 实现现状 | ✅ | iOS SharedUI/Components 无 Checkbox 文件=未实现；Android foundation/design/AgreementCheckbox.kt 仅有业务收编 AgreementCheckRow（协议行，非通用复选）；api.json 无 ui.checkbox 条目待立项登记；任务清单 #25 ✅缺口（iOS 未实现独立 Checkbox）→ 本规格=双端通用组件立项入口 |
| A6 | 平台差异表 | ✅ | 表内放行：勾绘制（✓ 字符 vs ImageVector）、按压反馈（touchDown vs ripple）、命中区机制、状态回写（iOS 命令式宿主回写 vs Android 声明式自动重组）、文字省略、无障碍（VoiceOver vs TalkBack）；pt/dp 与命名同全库先例 |
| A7 | anti_goals 反目标 | ✅ | indeterminate 半选、嵌套分组、勾选动画、横向 wrap 排列=二期或不做；label 富文本/变色、圆形协议视觉=AgreementCheckRow 职责不混入本组件 |

## 评审结论

| 项 | 内容 |
| -- | --- |
| 结论 | ✅ 通过（P1–P4 全 A，0 保留意见） |
| 用户签字 | （终核并入用户 C1.5 Demo 实机验收 2026-09-06） |
| 下一步 | 门禁 B api.json 契约登记 → 双端独立组件实现（CheckboxView.swift / Checkbox.kt）→ Demo 双端 1:1 → C1.5 demo 实机 → C1 单测 → C2/D |
