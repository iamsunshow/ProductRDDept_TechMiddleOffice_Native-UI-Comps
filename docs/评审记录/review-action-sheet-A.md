# ActionSheet 动作面板 · 门禁 A 评审单（任务清单 #44 · 全新立项）

> 组件 ID：`ui.action-sheet` ｜ 设计规格：`design-spec/action-sheet-design-spec.html`
> 评审方式：🖊 AI 代评（用户 2026-09-04 总授权"除特色组件外所有组件评审文档全部生成，中间任何询问直接通过"，数据录入区 #43 收编后用户原话「继续下一个组件」指示接棒；操作反馈区首件）
> 评审日期：2026-09-07 ｜ 终核：并入用户 C1.5 Demo 实机验收

## 评审清单

| # | 项 | 判定 | 说明 |
| - | -- | --- | --- |
| A1 | 组件边界（SCQA） | ✅ | 定位=底部弹出的动作选择面板（受控 visible + 操作列表 + 取消按钮）；与 Dialog #46（居中确认对话=是/否）划界=ActionSheet 多选一动作底部弹出；与 Picker #33（滚轮数据驱动选值）划界=ActionSheet 动作按钮点选；与 Menu #31（页内嵌入展开）划界=ActionSheet 底部弹出遮罩；与 Popup #54（通用弹出层未实现）划界=ActionSheet 专用底部动作面板；双端纯从零 |
| A2 | Token 零硬编码 | ✅ | 面板白底 bgPage、圆角 radiusLg 14dp、操作项高 56=行高基准、标题 fontMd textSecondary、操作项 fontLg textPrimary、destructive=danger 色、disabled=alpha 0.4、分隔线 hairline 0.5dp、间距条 8dp bgPage、遮罩 black 45%；全走 token |
| A3 | 决策投票表 | ✅ | P1-A 底部动作面板（B 居中对话框淘汰=Dialog #46 职责/C 顶部横滑淘汰）；P2-A 受控 visible 必传（B 内部自持淘汰=生命周期不可控/C 指令式淘汰=声明式不友好，与 DatePicker/Picker 一致）；P3-A onSelect(index)+onCancel()（B 逐项独立 onClick 淘汰=数据驱动不灵活/C item 回传淘汰=index 更简洁与 Picker 一致）；P4-A 一期=title+description+操作列表+destructive+disabled+取消+遮罩收起+demo 四段（图标/自定义内容/多选/滑动收起=二期） |
| A4 | Demo 排查 4 组 | ✅ | D1 基础动作面板（title"分享到"+3 操作项+取消，点操作项收起回调 index）；D2 destructive 危险动作（title"文件操作"+重命名/移动/删除红色+取消）；D3 disabled 项级禁用（title"选择操作"+编辑/分享(禁用灰)/复制+取消，禁用项点击不收起不回调）；D4 无标题+受控外部驱动（无 title 行直接操作项列表+拍照/从相册+取消，外部 visible 驱动开关） |
| A5 | 实现现状 | ✅ | iOS SharedUI/Components（52 组件）无 ActionSheet/UIActionSheet 封装=未实现；Android sharedui/components（47 组件）无 ActionSheet=未实现；业务分享/删除场景宿主直拼 UIAlertController/AlertDialog 未沉淀=双端纯从零；api.json 无 ui.action-sheet 条目待门禁 B 立项登记；任务清单 #44 ⬜→本规格=双端通用动作面板立项入口 |
| A6 | 平台差异表 | ✅ | 表内放行：弹出机制（UIView animate 滑入 vs ModalBottomSheet）、遮罩点击（UITapGestureRecognizer vs scrim clickable）、安全区（safeAreaInsets vs WindowInsets）、动画曲线（UIView easeOut 0.25 vs tween 250ms 时长一致）、分隔线（1/scale pt vs 0.5dp 同 Divider #1 先例）；pt/dp 与命名同全库先例 |
| A7 | anti_goals 反目标 | ✅ | 图标操作项=二期增量（一期纯文本覆盖 80%）；自定义操作项内容=宿主用 Dialog #46 或 Popup #54；多选确认=ActionSheet 选一动作即收起（多选=Checkbox #25+Dialog 确认）；滑动收起=二期增量（一期点击遮罩/取消已够用）；嵌套子菜单=复杂场景用 Cascader #24 或多级页面导航 |

## 评审结论

| 项 | 内容 |
| -- | --- |
| 结论 | ✅ 通过（P1–P4 全 A，0 保留意见） |
| 用户签字 | （终核并入用户 C1.5 Demo 实机验收） |
| 下一步 | 门禁 B api.json ui.action-sheet 契约登记 → 双端独立组件实现（ActionSheetView.swift / ActionSheet.kt）→ Demo 双端 1:1 → C1.5 demo 实机 → C1 单测 → C2/D |
