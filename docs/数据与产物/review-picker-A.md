# Picker 选择器 · 门禁 A 评审单（任务清单 #33 · 全新立项）

> 组件 ID：`ui.picker` ｜ 设计规格：`design-spec/picker-design-spec.html`
> 评审方式：🖊 AI 代评（用户 2026-09-04 总授权"除特色组件外所有组件评审文档全部生成，中间任何询问直接通过"，数据录入区 #33 顺延单件；用户 2026-09-06 原话「NumberKeyboard通过，继续下一个组件」指示推进）
> 评审日期：2026-09-06 ｜ 终核：并入用户 C1.5 Demo 实机验收

## 评审清单

| # | 项 | 判定 | 说明 |
| - | -- | --- | --- |
| A1 | 组件边界（SCQA） | ✅ | 定位=单列滚轮选择器内容块（工具栏 44 取消/标题/确定 + 滚轮 220=5 行×44，无遮罩无自绘浮层，宿主系统 sheet/页面卡片承载）；与 api.json ui.picker 现有契约（单列 options/value/onChange）对齐；与 #31 Menu 划界=Menu=菜单条驱动平铺下拉单选回显菜单栏、Picker=滚轮列选+确定确认语义；与 #24 Cascader 划界=级联多层下钻；与 #26/#27 日期选择器划界=专用日期组件不属本件；与 #34 picker-view 划界=picker-view=二期无工具栏纯多列滚轮基础件、Picker=带确认语义完整单列选择器；与业务 CategoryPicker（记账分类五列网格/BookkeepingCategory）划界=强业务收编件不动；anti_goals=遮罩/底部滑出容器/多列联动/循环滚轮/搜索=二期或宿主职责 |
| A2 | Token 零硬编码 | ✅ | 工具栏 44、滚轮行高 44/可视 220、文字 14（取消）/16（行、标题、确定）、灰 40% 禁用、hairline 分隔、primary 确定钮与选中行加粗、bgCard 底；全走 token 与注释锚定非魔法值 |
| A3 | 决策投票表 | ✅ | P1-A 嵌入内容块+宿主承载收敛（B 自带遮罩弹层淘汰=C 纯 picker-view 无确认语义不足）；P2-A options[PickerOption{value,text,disabled}]+受控 value（B 纯文案数组淘汰=C 泛型淘汰）；P3-A 受控 value+滚动临时可视态+确定提交/取消丢弃（B 半受控在确认语义下冗余/C 无回滚无门）；P4-A 一期=单列+工具栏+disabled+长列表+demo 四段（多列联动随 #34 二期/搜索循环轮滚二期或 N/A） |
| A4 | Demo 排查 4 组 | ✅ | D1 单列基础（确定 onChange/取消回滚）；D2 长列表+disabled 掠行不可停靠（自动吸附最近可用行）；D3 受控外部 value 回滚定位不触发 onChange；D4 宿主系统 sheet 承载完整内容块用法+回显 |
| A5 | 实现现状 | ✅ | iOS 有收编近似（OptionPickerSheetViewController=pageSheet 320pt UIPickerView 单列+顶栏取消/确定，options 纯 [String] + onConfirm(index)）→ 本规格=组件化升级（value/text 数据驱动+disabled+受控回滚）并保留宿主 sheet 承载用法；Android 无独立 Picker（sharedui 仅 MonthPickerSheet 日期专用轮盘）需从零实现；api.json 已有 ui.picker 条目（iOS available，props options/value/onChange，待门禁 B 补双端平台契约与 reviewed）；任务清单 #33 现为 ✅（已实现口径含 iOS 缺口件）→ 本次转 📐 重新立项；双端 demo 注册已留占位待接线 |
| A6 | 平台差异表 | ✅ | 表内放行：滚轮本体（UIPickerView 原生 vs 自绘 LazyColumn wheel）、滚动阻尼/惯性、disabled 掠行校正触发时机、工具栏承载（UINavigationBar item vs Row 文本钮）、弹层承载（iOS .pageSheet vs Android Dialog，宿主职责）、尺寸单位与命名（同全库先例） |
| A7 | anti_goals 反目标 | ✅ | 遮罩/底部滑出容器（随 Popup #54/Overlay 二期浮层机制）、多列/联动列选（随 #34 picker-view 二期基础件）、循环滚轮/搜索/虚拟长列表（二期或 N/A）、日期选择（#26/#27 专用）、级联（#24 Cascader）、业务分类网格（CategoryPicker 不动）=全部登记二期/他组件或宿主职责 |

## 评审结论

| 项 | 内容 |
| -- | --- |
| 结论 | ✅ 通过（P1–P4 全 A，0 保留意见） |
| 用户签字 | （终核并入用户 C1.5 Demo 实机验收 2026-09-06） |
| 下一步 | 门禁 B api.json ui.picker 双端契约登记 → 双端独立组件实现（PickerView.swift / Picker.kt）→ Demo 双端 1:1 → C1.5 demo 实机 → C1 单测 → C2/D |
