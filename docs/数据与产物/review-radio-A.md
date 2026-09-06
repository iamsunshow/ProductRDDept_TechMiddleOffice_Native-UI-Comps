# Radio 单选 · 门禁 A 评审单（任务清单 #35 · 全新立项）

> 组件 ID：`ui.radio` ｜ 设计规格：`design-spec/radio-design-spec.html`
> 评审方式：🖊 AI 代评（用户 2026-09-04 总授权"除特色组件外所有组件评审文档全部生成，中间任何询问直接通过"，数据录入区 #35 顺延单件；用户 2026-09-06 原话「radio吧」在 #33 Picker 收编后指示选型推进）
> 评审日期：2026-09-06 ｜ 终核：并入用户 C1.5 Demo 实机验收

## 评审清单

| # | 项 | 判定 | 说明 |
| - | -- | --- | --- |
| A1 | 组件边界（SCQA） | ✅ | 定位=通用排他单选标记（单只 Radio + RadioGroup 垂直排他单选列表，options 数据驱动一选一）；与 #25 Checkbox 划界=Radio 圆形排他点选即确定/点击已选忽略、Checkbox 方形复选可多选可取消；与 Switch 开关（二元即时）、Picker #33/Menu #31（下拉选填）、Segmented #74（页签类高频切换）、业务协议行（AgreementCheckRow）划界；anti_goals=整项卡片 icon+标题+副文案/横向换行/圆点动画=二期或宿主职责，toggle 取消=Checkbox 语义不混入 |
| A2 | Token 零硬编码 | ✅ | 单选点 20 圆形（外圈描边 1.5 textSecondary 30%（同 Checkbox 惯例）、选中外圈 primary+中心实心点 8）、label Md16 间距 8、组行间距 4+行 padding 10、禁用 40% 灰、选中 label 加粗；全走 token 与注释锚定非魔法值 |
| A3 | 决策投票表 | ✅ | P1-A 单只+组双形态（B 仅组无单只/C 套系统控件视觉脱节淘汰）；P2-A RadioOption{value,label,disabled}+value String? 唯一选中（B 纯文案淘汰=C 卡片结构二期）；P3-A 半受控 value nil 内部自持初始未选=合法态点选即确定、外部赋值回显不触发 onChange、点已选行幂等忽略（B 纯受控过度/C 无外部驱动门淘汰）；P4-A 一期=单只+组+disabled+半受控+demo 四段（整项卡片二期/横向排列与动画不做） |
| A4 | Demo 排查 4 组 | ✅ | D1 单只（未选→点选置 true→外部取消回显）；D2 Group 排他单选（男/女切换+value 回显）；D3 disabled（项级禁用不可点+已选禁用灰点保留）；D4 受控外部 value 驱动回显（重置/选 English）不触发 onChange |
| A5 | 实现现状 | ✅ | 双端均无 Radio 近似件=纯从零全新立项：iOS 无系统单选控件需自绘（CALayer/CAShapeLayer 圆点）；Android 库内无单选组件（Material3 系统 RadioButton 视觉/主题不符库内设计语言=不使用，Compose Canvas drawCircle 自绘）；api.json 无 ui.radio 条目待门禁 B 立项登记；任务清单 #35 ⬜ 双端未实现 → 本次立项 📐 |
| A6 | 平台差异表 | ✅ | 表内放行：圆点绘制（CALayer vs Canvas）、按压反馈（压暗瞬态 vs ripple/无涟漪）、命中区机制、状态回写（命令式显式刷新 vs 声明式重组）、单行省略、无障碍；尺寸单位与命名（同全库先例） |
| A7 | anti_goals 反目标 | ✅ | 整项卡片单选（图标+标题+副文案）/横向换行排列/圆点动画=二期或不做；点击已选中 toggle 取消=Checkbox 语义（Radio 幂等忽略）；富文本 label=协议行/宿主职责；必选校验=Form 宿主职责=全部登记不混入 |

## 评审结论

| 项 | 内容 |
| -- | --- |
| 结论 | ✅ 通过（P1–P4 全 A，0 保留意见） |
| 用户签字 | （终核并入用户 C1.5 Demo 实机验收 2026-09-06） |
| 下一步 | 门禁 B api.json ui.radio 双端契约登记 → 双端独立组件实现（RadioView.swift / Radio.kt）→ Demo 双端 1:1 → C1.5 demo 实机 → C1 单测 → C2/D |
