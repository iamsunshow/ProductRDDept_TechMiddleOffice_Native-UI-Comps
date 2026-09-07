# Switch 开关 · 门禁 A 评审单（任务清单 #41 · 全新立项）

> 组件 ID：`ui.switch` ｜ 设计规格：`design-spec/switch-design-spec.html`
> 评审方式：🖊 AI 代评（用户 2026-09-04 总授权"除特色组件外所有组件评审文档全部生成，中间任何询问直接通过"，数据录入区 #41 顺延单件；用户 2026-09-06 原话「继续」在 #40 Signature 收编后指示接棒启动）
> 评审日期：2026-09-06 ｜ 终核：并入用户 C1.5 Demo 实机验收

## 评审清单

| # | 项 | 判定 | 说明 |
| - | -- | --- | --- |
| A1 | 组件边界（SCQA） | ✅ | 定位=通用二元即时开关（轨道+滑块自绘核组件、无内置 label=宿主嵌 FormFieldRow #28/Cell 行尾）；与 #25 Checkbox 划界=Switch 二元点按翻转持久开关 vs Checkbox 方形复选可多选可取消；与 #35 Radio 划界=二元即时 vs 圆形排他几选一；与 Range #36（连续区间）/ InputNumber #30（步进单值）/ Picker #33·Menu #31（下拉承载层）/ Tabbar·Tabs·Segmented #74（分段页签）划界；anti_goals=loading 异步提交/自定义配色尺寸参数/拖拽滑动手势=二期或宿主职责，label 内置行=FormFieldRow/Cell 职责，三态半选=Checkbox indeterminate 范畴 |
| A2 | Token 零硬编码 | ✅ | 轨道 48×28 radiusFull（48 宽=交互行基准注释锚定、28=20 滑块+上下内衬 4 spaceXs）、on=primary 填充、off=textSecondary 30% 浅灰、滑块白色 20（对齐 CheckboxGlyph/RadioGlyph 20）、轨内衬 4 行程 20、动画 0.18s、disabled alpha 0.4；全走 token 与注释锚定非魔法值 |
| A3 | 决策投票表 | ✅ | P1-A 纯开/关核组件（B label 行组件职责重叠淘汰/C 系统控件视觉脱节淘汰）；P2-A checked Bool 半受控（B "on"/"off" String 徒增映射淘汰/C 三态=Checkbox 范畴淘汰）；P3-A 半受控 nil 内部自持初始 off 点按翻转回调、外部赋值回显不触发 onChange、on→off/off→on 均回调、disabled 不可点（B 纯受控过度/C 无外部驱动门淘汰）；P4-A 一期=核组件+动画 0.18s+disabled+demo 四段（loading/配色尺寸参数/拖拽二期或宿主） |
| A4 | Demo 排查 4 组 | ✅ | D1 基础开/关（默认 off→点按翻转 primary+滑块右移动画回显）；D2 行尾嵌用（FormFieldRow/Cell trailing+初始 checked=true 回显）；D3 disabled（on/off 双灰锁+外部使能按钮）；D4 受控外部 checked 驱动回显（外部打开/关闭不触发 onChange） |
| A5 | 实现现状 | ✅ | 双端均无 Switch 近似件=纯从零全新立项：iOS 无库内开关控件需新建（系统 UISwitch 尺寸/轨道色定制弱不符库 token 语言不用）；Android 库内无开关组件（Material3 Material Switch 视觉/主题不符库内设计语言=不使用）；api.json 无 ui.switch 条目待门禁 B 立项登记；任务清单 #41 ⬜ 双端未实现 → 本次立项 📐 |
| A6 | 平台差异表 | ✅ | 表内放行：轨道/滑块绘制（UIView layer vs Compose Box）、动画 API（UIView.animate vs animateDpAsState/animateColorAsState tween180）、点击命中机制、状态回写（命令式显式刷新 vs 声明式重组）、无障碍；尺寸单位与命名（同全库先例） |
| A7 | anti_goals 反目标 | ✅ | loading/延迟提交=宿主·按钮职责；activeColor/轨道自定义色/thumb 与轨道尺寸参数/拖拽滑动手势=二期；label 内置行组件=FormFieldRow/Cell 职责；三态半选=Checkbox indeterminate；系统控件复用=不做=全部登记不混入 |

## 评审结论

| 项 | 内容 |
| -- | --- |
| 结论 | ✅ 通过（P1–P4 全 A，0 保留意见） |
| 用户签字 | （终核并入用户 C1.5 Demo 实机验收 2026-09-06） |
| 下一步 | 门禁 B api.json ui.switch 双端契约登记 → 双端独立组件实现（SwitchView.swift / Switch.kt）→ Demo 双端 1:1 → C1.5 demo 实机 → C1 单测 → C2/D |
