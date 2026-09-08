# Notify 消息通知 · 门禁 A 评审单（操作反馈区 #52）

> 组件 ID：`ui.notify` ｜ 设计规格：`design-spec/notify-design-spec.html`
> 评审方式：🖊 AI 代评（用户 2026-09-04 总授权"除特色组件外所有组件评审文档全部生成，中间任何询问直接通过"）
> 评审日期：2026-09-08 ｜ 终核：并入用户全批统一验收（C1.5 实机 Demo）

## 评审清单

| # | 项 | 判定 | 说明 |
| - | -- | --- | --- |
| A1 | 组件边界（SCQA） | ✅ | 定位=顶部/底部全局消息通知浮层；与 NoticeBar #51（页面内嵌占位栏 vs Notify 全局浮层自动消失）/Toast #59（纯文本居中 vs 顶部底部带图标）/Dialog #46（阻断式 vs 非阻断）/Loading #50 划界清晰；anti_goals=自定义内容 slot/声明式 visible 模式/Toast 样式二期 |
| A2 | Token 零硬编码 | ✅ | 视觉全 token 化：默认高 40、背景 textPrimary、文本 textInverse sizeSm 14、内边距 spaceLg 16、distance 8、navHeight 57、duration 3000ms；backgroundColor/textColor/textSize/height/distance/navHeight/duration 全参数化可配 |
| A3 | 决策投票表 | ✅ | P1-A 命令式 API（Notify.show()/Notify.clear()）+全局浮层+自动消失+可关闭+左右图标 slot；P2-A 一期命令式+top/bottom+distance+navHeight+duration+closeable+leftIcon/rightIcon+type(primary/success/warning/danger)+Demo 4 组；P3-A iOS keyWindow 挂载 UIView+Timer；P4-A Android contentHost 挂载 Compose+LaunchedEffect |
| A4 | Demo 排查 4 组 | ✅ | D1 基础通知（top 位置+3s 自动消失）；D2 bottom 位置+自定义 duration；D3 type 类型变色（primary/success/warning/danger）；D4 可关闭+自定义图标 |
| A5 | 实现现状 | ✅ | 双端均未实现（任务清单行 52 ⬜，api.json 待立项），本规格为立项入口 |
| A6 | 平台差异表 | ✅ | 表内放行：挂载容器（keyWindow vs contentHost 系统级差异）、自动消失（Timer vs LaunchedEffect 系统级差异）、布局（UIView+UIStackView vs Compose Box+Row）、关闭按钮（UIButton vs Text+clickable）、navHeight 适配（safeArea+navHeight vs statusBar+actionBar） |
| A7 | anti_goals 反目标 | ✅ | 自定义内容 slot（二期补）、声明式 visible 模式（不符合命令式调用习惯）、Toast 样式（归 Toast）均登记二期 |

## 评审结论

| 项 | 内容 |
| -- | --- |
| 结论 | ✅ 通过（P1–P4 全 A，0 保留意见） |
| 用户签字 | （终核并入用户全批统一验收 2026-09-08） |
| 下一步 | 门禁 B api.json 契约登记 → 双端实现 → C1.5 demo 实机 |
