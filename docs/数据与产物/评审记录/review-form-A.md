# Form 表单 · 门禁 A 评审单（任务清单 #28 · 全新立项）

> 组件 ID：`ui.form` ｜ 设计规格：`design-spec/form-design-spec.html`
> 评审方式：🖊 AI 代评（用户 2026-09-04 总授权"除特色组件外所有组件评审文档全部生成，中间任何询问直接通过"，数据录入区顺延三件批）
> 评审日期：2026-09-06 ｜ 终核：并入用户 C1.5 Demo 实机验收

## 评审清单

| # | 项 | 判定 | 说明 |
| - | -- | --- | --- |
| A1 | 组件边界（SCQA） | ✅ | 定位=表单布局容器（分组卡片 + FormFieldRow 字段行：label/必填星/help/error + 提交槽），具体输入控件=库内独立组件由宿主放入、校验算法宿主自理；与 Cell（列表导航行）/各字段录入件（Checkbox/Input/Radio 等独立组件）划界；anti_goals=rules 校验引擎/内置输入控件/自动必填判定/整页模板=二期或宿主职责 |
| A2 | Token 零硬编码 | ✅ | 行 min 高 48、label Md16、必填星 primary、help/error Sm12（次色/错误红）、卡圆角 lg + hairline 分隔（iOS 1/scale pt vs Android 0.5dp 表内放行）、label 超长折行 ≤45% 宽；全走 token 与注释锚定非魔法值 |
| A3 | 决策投票表 | ✅ | P1-A 表单布局容器（无字段渲染，B 引擎/C 通用容器淘汰）；P2-A FormFieldRow(label,required,help,error,content) 结构化字段行（错误槽独立/双向绑定淘汰）；P3-A 纯展示无状态（error/required 只进不出、宿主持校验结论）；P4-A 一期=分组卡片+字段行+错误行+提交槽+demo 四段（引擎/内置控件二期） |
| A4 | Demo 排查 4 组 | ✅ | D1 基础字段布局（label 左内容右+必填星+help+行分隔）；D2 校验错误渲染（行内红字、通过无错不占位）；D3 长 label 折行 + 无 label 内容全宽；D4 多分组卡片 + 提交按钮槽（宿主 Button） |
| A5 | 实现现状 | ✅ | 双端均未实现；api.json 无 ui.form 条目待立项登记；任务清单 #28 ⬜（本规格=立项入口）；数据录入区在它之前的已实现件（Address/CalendarCard/Cascader 全新收编 + foundation.calendar/Checkbox 等收编）不构成阻塞 |
| A6 | 平台差异表 | ✅ | 表内放行：字段内容嵌入槽（iOS contentView vs Android content lambda）、hairline 线宽（1/scale vs 0.5dp）、行容器（stack vs Column）、文字省略、尺寸数值 pt/dp 与数据模型命名（同全库先例） |
| A7 | anti_goals 反目标 | ✅ | rules 校验引擎、内置输入控件渲染、自动必填空值判定、整页表单模板、弹层/键盘=全部登记二期或宿主职责 |

## 评审结论

| 项 | 内容 |
| -- | --- |
| 结论 | ✅ 通过（P1–P4 全 A，0 保留意见） |
| 用户签字 | （终核并入用户 C1.5 Demo 实机验收 2026-09-06） |
| 下一步 | 门禁 B api.json 契约登记 → 双端独立组件实现（FormView.swift / Form.kt）→ Demo 双端 1:1 → C1.5 demo 实机 → C1 单测 → C2/D |
