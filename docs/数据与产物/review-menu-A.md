# Menu 菜单 · 门禁 A 评审单（任务清单 #31 · 全新立项）

> 组件 ID：`ui.menu` ｜ 设计规格：`design-spec/menu-design-spec.html`
> 评审方式：🖊 AI 代评（用户 2026-09-04 总授权"除特色组件外所有组件评审文档全部生成，中间任何询问直接通过"，数据录入区顺延三件批）
> 评审日期：2026-09-06 ｜ 终核：并入用户 C1.5 Demo 实机验收

## 评审清单

| # | 项 | 判定 | 说明 |
| - | -- | --- | --- |
| A1 | 组件边界（SCQA） | ✅ | 定位=嵌入式下拉单选菜单（菜单栏 ≤4 列 + 展开态内联面板随组件高增长，宿主纵向流推挤下方；无遮罩无浮层）；与 Cascader（多层级联）/Picker（常驻单列选择）/OptionPicker Modal（底部 sheet）/SideBar（目录轨）划界；anti_goals=遮罩悬浮浮层/多级子菜单/联动筛选=二期或宿主业务 |
| A2 | Token 零硬编码 | ✅ | 栏高 44、面板行高 44、面板 max 220（5 行内滚）、列文字 Md16、选中值小字 Sm12、▾ 12、选中 primary 加粗/禁用 40% 灰、hairline 分隔；全走 token 与注释锚定非魔法值 |
| A3 | 决策投票表 | ✅ | P1-A 嵌入式下拉单选（无浮层收敛，B 悬浮遮罩/C Modal 复用淘汰登记二期）；P2-A MenuColumn(key,title,options)+MenuOption(value,text,disabled) 列数组数据驱动（扁平字符串/级联树淘汰）；P3-A 半受控（activeColumnKey 内部自管理 + selectedValues 外部回显 + onChange(columnKey,optionValue)）；P4-A 一期=≤4 列+内联面板（选中/禁用/滚动）+回显+demo 四段（悬浮遮罩/多级/联动二期） |
| A4 | Demo 排查 4 组 | ✅ | D1 单列基础（选中回显菜单栏+收起幂等）；D2 多列展开切换（4 列互斥展开各自独立选中值）；D3 长列表 max220 内滚 + disabled 行灰禁；D4 受控外部驱动（外部 selectedValues 回显多列标题/高亮不触发 onChange） |
| A5 | 实现现状 | ✅ | 双端均未实现；api.json 无 ui.menu 条目待立项登记；任务清单 #31 ⬜（本规格=立项入口）；嵌入式展开=无浮层依赖（Popup #54 未实现不阻塞） |
| A6 | 平台差异表 | ✅ | 表内放行：按压反馈（touchDown vs ripple）、等分横滑、面板滚动、高度推挤机制（iOS intrinsicContentSize 变化 vs Android Column State 驱动）、文字省略、尺寸数值 pt/dp 与命名（同全库先例） |
| A7 | anti_goals 反目标 | ✅ | 遮罩悬浮浮层（随 Popup/浮层机制二期）、多级子菜单（级联语义错位）、联动筛选结果面板（宿主业务）=全部登记二期或宿主职责 |

## 评审结论

| 项 | 内容 |
| -- | --- |
| 结论 | ✅ 通过（P1–P4 全 A，0 保留意见） |
| 用户签字 | （终核并入用户 C1.5 Demo 实机验收 2026-09-06） |
| 下一步 | 门禁 B api.json 契约登记 → 双端独立组件实现（MenuView.swift / Menu.kt）→ Demo 双端 1:1 → C1.5 demo 实机 → C1 单测 → C2/D |
