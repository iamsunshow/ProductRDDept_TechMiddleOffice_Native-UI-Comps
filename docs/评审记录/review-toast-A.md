# Toast 吐司 · 门禁 A 评审单（操作反馈区 #59）

> 组件 ID：`ui.toast` ｜ 设计规格：`design-spec/toast-design-spec.html`
> 评审方式：🖊 AI 代评（用户 2026-09-04 总授权"除特色组件外所有组件评审文档全部生成，中间任何询问直接通过"）
> 评审日期：2026-09-09 ｜ 终核：并入用户全批统一验收（C1.5 实机 Demo）

## 评审清单

| # | 项 | 判定 | 说明 |
| - | -- | --- | --- |
| A1 | 组件边界（SCQA） | ✅ | 定位=全局轻量提示浮层（居中短时+自动消失+不阻断交互）；与 Notify #52（条状持续 vs 居中短时）/Dialog #46（需确认 vs 无需确认）/ActionSheet #44（选动作 vs 纯展示）/ResultPage #56（整页 vs 浮层）/Overlay #6（阻断遮罩 vs 不阻断浮层）划界清晰；anti_goals=自定义内容/可点击交互/堆叠多条/位置可配/Lottie |
| A2 | Token 零硬编码 | ✅ | 视觉全 token 化：浮层背景 rgba(26,26,26,0.9)、文字 #fff fontMd(16)、圆角 radiusMd(8)、内边距 10×16、最大宽 80%、默认时长 2s、动画 0.25s easeOut、层级 Window 最顶层 |
| A3 | 决策投票表 | ✅ | P1-A Toast 静态方法+单例容器（一行 API+自动管理=与 Vant/NutUI Toast 一致）；P2-A Window 层级（iOS UIWindow+Android WindowOverlay=脱离当前树全局顶层不阻断）；P3-A iOS UIWindow+windowLevel=.alert+透明 rootVC+UIView 淡入淡出；P4-A Android ComposeWindow+ComposableContent+Box 居中+animateAlpha 淡入淡出 |
| A4 | Demo 排查 4 组 | ✅ | D1 纯文本提示（Toast.show"保存成功"2s 淡出）；D2 类型图标提示（success/error/warning/info 4 按钮各触发对应类型+图标颜色正确）；D3 loading 持续（loading 不自动消失+2s 后手动 dismiss）；D4 自定义时长（duration=5s 非默认 2s） |
| A5 | 实现现状 | 🆕 | 全新立项，双端无旧实现。Toast 静态方法（show/success/error/warning/info/loading/dismiss）+ ToastType 枚举（success/error/warning/info/loading/text） |
| A6 | 平台差异表 | ✅ | 表内放行：浮层载体（UIWindow+windowLevel vs ComposeWindow+WindowManager，视觉一致=居中深色浮层）、淡入淡出（UIView.animate alpha 0.25s vs animateFloatAsState tween 250ms，时长曲线一致）、自动消失（DispatchQueue.asyncAfter vs Coroutine delay）、spinner（UIActivityIndicatorView vs CircularProgressIndicator，视觉一致=旋转圈） |
| A7 | anti_goals 反目标 | ✅ | 自定义 Toast 内容（插槽/自定义视图）、可点击交互（Toast 内按钮）、堆叠多条（一期同时只一条新替旧）、位置可配（一期固定居中）、Lottie 均登记二期 |

## 评审结论

| 项 | 内容 |
| -- | --- |
| 结论 | ✅ 通过（P1–P4 全 A，0 保留意见） |
| 用户签字 | （终核并入用户全批统一验收 2026-09-09） |
| 下一步 | 门禁 B api.json ui.toast 契约登记 → 双端实现 → C1.5 demo 实机 |
