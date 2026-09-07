# Dialog 对话框 · 门禁 A 评审单（任务清单 #46 · iOS 缺口补全件）

> 组件 ID：`ui.dialog` ｜ 设计规格：`design-spec/dialog-design-spec.html`
> 评审方式：🖊 AI 代评（用户 2026-09-04 总授权；#45 Badge 收编后用户原话「通过，代码开发了吗，可以看demo了吗」指示接棒；Android 已有 AppDialog=iOS 缺口补全对齐件）
> 评审日期：2026-09-07 ｜ 终核：并入用户 C1.5 Demo 实机验收

## 评审清单

| # | 项 | 判定 | 说明 |
| - | -- | --- | --- |
| A1 | 组件边界（SCQA） | ✅ | 定位=居中弹出的模态对话框（标题+正文+操作按钮，用于确认/警示/告知）；与 ActionSheet #44（底部动作面板多选一）划界=Dialog 居中确认是/否；与 Toast #59（自动消失无按钮）划界=Dialog 需用户操作关闭；与 Popup #54（通用弹出层）划界=Dialog 专用居中对话框；iOS 缺口补全=对齐 Android 现有 AppDialog |
| A2 | Token 零硬编码 | ✅ | 卡片 radiusLg 14 bgCard；标题 fontMd SemiBold textPrimary；正文 fontSm textSecondary；按钮高 44 radius 10；Primary=primary底白字/Default=gray10底textPrimary/Destructive=textPrimary底danger字；全走 token |
| A3 | 决策投票表 | ✅ | P1-A iOS 对齐 Android 现有 AppDialog API（避免双端分裂）；P2-A Vertical通栏(默认)+Horizontal并排（与 Android 一致）；P3-A Primary/Default/Destructive 三样式（与 Android DialogAction.style 一致）；P4-A 支持 contentContent 自定义正文（与 Android contentContent 一致） |
| A4 | Demo 排查 4 组 | ✅ | D1 Vertical 通栏（确认删除+取消/删除destructive）；D2 Horizontal 并排（提示+取消/确定primary）；D3 多按钮 Vertical（用户协议+不同意/同意并继续primary）；D4 无标题单按钮（网络失败+知道了primary） |
| A5 | 实现现状 | ✅ | Android sharedui/components/CommonComponents.kt L419 已有 AppDialog（title/content/contentContent/actions/buttonLayout/onDismiss，DialogAction 三样式，Vertical/Horizontal 两布局）=已实现；iOS SharedUI/Components 无 Dialog 封装=未实现；本次=iOS 补全对齐 Android API，api.json ui.dialog 已存在待更新 source_refs + reviewed=true |
| A6 | 平台差异表 | ✅ | 表内放行：居中弹层机制（UIView 遮罩+addSubview vs Compose Dialog）、按钮渲染（UIButton vs AppButton）；API/视觉/布局完全对齐无差异 |
| A7 | anti_goals 反目标 | ✅ | 输入框表单=宿主自组或二期；底部弹出=ActionSheet #44；自动消失=Toast #59 |

## 评审结论

| 项 | 内容 |
| -- | --- |
| 结论 | ✅ 通过（P1–P4 全 A，0 保留意见） |
| 用户签字 | （终核并入用户 C1.5 Demo 实机验收） |
| 下一步 | 门禁 B：iOS 实现 DialogView.swift 对齐 Android AppDialog API → iOS DialogShowcase Demo 4 段 → 双端编译 → C1.5 |
