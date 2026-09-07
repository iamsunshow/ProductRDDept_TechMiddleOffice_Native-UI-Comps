# Input 输入 · 门禁 A 评审单（任务清单 #29 · 全新立项）

> 组件 ID：`ui.input` ｜ 设计规格：`design-spec/input-design-spec.html`
> 评审方式：🖊 AI 代评（用户 2026-09-04 总授权"除特色组件外所有组件评审文档全部生成，中间任何询问直接通过"，数据录入区缺口补齐批）
> 评审日期：2026-09-06 ｜ 终核：并入用户 C1.5 Demo 实机验收

## 评审清单

| # | 项 | 判定 | 说明 |
| - | -- | --- | --- |
| A1 | 组件边界（SCQA） | ✅ | 定位=通用单行文本输入内容组件（受控 value，壳+placeholder+清除钮+尾槽+键盘+掩码+禁用）；与 Form #28（label/必填/错误=FormFieldRow 职责，Input 只做内容）/ InputNumber #30（步进无键盘）/ TextArea 多行 / 搜索框 =划界；键盘避让=宿主职责；业务专用登录输入=Android 收编 AppInputField 家族先例 |
| A2 | Token 零硬编码 | ✅ | 壳 48 对齐 Form 行高、圆角 lg、底 bgPage、内距 md、文本 Md16、placeholder textTertiary、清除钮 20 圆灰底白叉 14、尾槽间距 sm、禁用 40% 灰；全走 token 与注释锚定 |
| A3 | 决策投票表 | ✅ | P1-A 通用内容组件（B Form 绑定重复淘汰/C 多端专用不收敛淘汰）；P2-A String value+onTextChange 直通（细粒度事件/双向绑定淘汰）；P3-A 受控 value 必传（nil 自持/纯自管理淘汰=宿主需全量文本）；P4-A 一期=壳+placeholder+clearable+trailing+keyboard 四值+secure 掩码+disabled+maxLength 输入截断+demo 四段（显隐切换/字数计数/前后缀/TextArea/搜索二期） |
| A4 | Demo 排查 4 组 | ✅ | D1 基础输入（placeholder 空态→真实键盘键入段内回显）；D2 清除钮+尾部动作槽（验证码 number 键盘 maxLength 6）；D3 disabled 整壳灰禁 + secure 密文掩码（回调原文）；D4 受控外部驱动（外部预填/清空同步刷新不触发编辑回调） |
| A5 | 实现现状 | ✅ | iOS SharedUI/Components 无输入组件=未实现；Android sharedui/components/CommonComponents.kt 业务收编 AppInputField/PhoneInputField/EmailInputField/PasswordInputField 系列（BasicTextField 52dp 灰底 radius lg 清除钮+尾槽+keyboardType+掩码=新组件视觉前身）；api.json 无 ui.input 条目待立项登记；任务清单 #29 ✅缺口→本规格=双端通用组件立项入口 |
| A6 | 平台差异表 | ✅ | 表内放行：编辑内核（UITextField vs BasicTextField）、键盘四值映射（UIKeyboardType vs KeyboardType）、掩码实现（isSecureTextEntry vs PasswordVisualTransformation）、清除钮图标、禁用机制、受控状态回写（命令式 vs 声明式）、键盘避让宿主实现；pt/dp 与命名同全库先例 |
| A7 | anti_goals 反目标 | ✅ | secure 显隐切换、字数计数、前后缀 icon、多行 TextArea、搜索形态=二期或对应组件；label/必填星/校验错误=FormFieldRow 职责不混入（壳不变红） |

## 评审结论

| 项 | 内容 |
| -- | --- |
| 结论 | ✅ 通过（P1–P4 全 A，0 保留意见） |
| 用户签字 | （终核并入用户 C1.5 Demo 实机验收 2026-09-06） |
| 下一步 | 门禁 B api.json 契约登记 → 双端独立组件实现（InputView.swift / Input.kt）→ Demo 双端 1:1 → C1.5 demo 实机 → C1 单测 → C2/D |
