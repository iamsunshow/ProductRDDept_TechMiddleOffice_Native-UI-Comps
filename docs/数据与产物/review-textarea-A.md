# TextArea 文本域 · 门禁 A 评审单（任务清单 #42 · 全新立项）

> 组件 ID：`ui.textarea` ｜ 设计规格：`design-spec/textarea-design-spec.html`
> 评审方式：🖊 AI 代评（用户 2026-09-04 总授权"除特色组件外所有组件评审文档全部生成，中间任何询问直接通过"，数据录入区按序接棒；#41 Switch 收编后用户原话「继续下一个组件」指示启动）
> 评审日期：2026-09-06 ｜ 终核：并入用户 C1.5 Demo 实机验收

## 评审清单

| # | 项 | 判定 | 说明 |
| - | -- | --- | --- |
| A1 | 组件边界（SCQA） | ✅ | 定位=通用多行文本输入内容组件（受控 value，灰底圆角壳+placeholder 顶部左+rows 可视行+内部滚动+maxLength 截断+disabled）；与 Input #29（单行文本域=同壳语言两形态）/ Form #28（label/必填/错误=FormFieldRow 职责，TextArea 只做内容壳不变红）/ 富文本 / 搜索 =划界；字数统计/键盘收起=宿主；业务备注/简介类宿主直拼系统控件场景为前身=双端纯从零 |
| A2 | Token 零硬编码 | ✅ | 壳 bgPage、圆角 lg、内距 md 四向、文本 Md16 textPrimary、行高 24=cellTitleLineHeight 库 token、整件高=rows×24+24（默认 3 行=96=2×48 交互行基准同 Signature 注释锚定）、placeholder textSecondary（库内无 textTertiary token=同 Input #29 实现惯例）、禁用 40% 灰；全走 token 与注释锚定 |
| A3 | 决策投票表 | ✅ | P1-A 通用多行文本域内容组件（B Form 绑定重复淘汰/C 富文本专项淘汰）；P2-A String value+onTextChange 直通同 Input（分段事件/绑定对象淘汰）；P3-A 受控 value 必传（nil 自持/纯自管理淘汰=宿主需全量文本做字数与提交）；P4-A 一期=rows 可视行+内部滚动+placeholder+受控+maxLength 输入截断+disabled+demo 四段（autoGrow/字数角标二期，富文本淘汰） |
| A4 | Demo 排查 4 组 | ✅ | D1 基础多行输入（placeholder 空态→真实键盘键入多行+回车换行段内回显，行高 24 顶部对齐）；D2 受控外部赋值+长文内部滚动（预填 50 行可视 3 行内滚 0 次 onTextChange+读当前值+清空）；D3 maxLength 截断（键入/粘贴只收前 N）+disabled 整壳灰不可交互；D4 宿主表单组装（FormFieldRow label+必填星+rows=4 高 120+空提交宿主 error 红字+实时字数宿主读 value=壳不变红） |
| A5 | 实现现状 | ✅ | iOS SharedUI/Components（52 组件）无 textarea/UITextView 封装=未实现；Android sharedui/components（45 组件）无 textarea=未实现；业务备注/简介场景宿主直拼系统控件未沉淀=双端纯从零；api.json 无 ui.textarea 条目待门禁 B 立项登记；任务清单 #42 ⬜→本规格=双端通用多行文本域立项入口 |
| A6 | 平台差异表 | ✅ | 表内放行：编辑内核（UITextView vs BasicTextField 多行）、placeholder 自绘（UILabel 叠放 vs decorationBox）、行高排版 API（NSMutableParagraphStyle vs lineHeight 24sp）、内部滚动（scrollEnabled vs verticalScroll）、回车语义（多行换行）、禁用机制（isEditable/isSelectable vs enabled）、受控状态回写（命令式 vs 声明式）、键盘收起宿主；pt/dp 与命名同全库先例 |
| A7 | anti_goals 反目标 | ✅ | 富文本/格式文本、autoGrow 自动增高、字数统计角标、工具栏（emoji/@/附件）=二期或宿主；label/必填星/校验错误=FormFieldRow 职责不混入（壳不变红）；清除钮/secure 掩码/尾槽/键盘类型=Input #29 单行形态不混入 |

## 评审结论

| 项 | 内容 |
| -- | --- |
| 结论 | ✅ 通过（P1–P4 全 A，0 保留意见） |
| 用户签字 | （终核并入用户 C1.5 Demo 实机验收 2026-09-06） |
| 下一步 | 门禁 B api.json ui.textarea 契约登记 → 双端独立组件实现（TextAreaView.swift / TextArea.kt）→ Demo 双端 1:1 → C1.5 demo 实机 → C1 单测 → C2/D |
