# CountDown 倒计时 · 门禁 A 评审单（任务清单 #66 · 全新立项）

> 组件 ID：`ui.count-down` ｜ 设计规格：`design-spec/countdown-design-spec.html`
> 评审方式：🖊 AI 代评（用户 2026-09-04 总授权"除特色组件外所有组件评审文档全部生成，中间任何询问直接通过"；CountDown 属信息展示区常规组件，非特色组件，按授权直接通过）
> 评审日期：2026-09-10 ｜ 终核：并入用户 C1.5 Demo 实机验收

## 评审清单

| # | 项 | 判定 | 说明 |
| - | -- | --- | --- |
| A1 | 组件边界（SCQA） | ✅ | 定位=纯展示型倒计时数字组件（输入目标结束时间戳/剩余秒数，每秒重算并格式化显示，结束触发 onEnd）；与 Progress #64（进度比例）划界=CountDown 时间数字；与 Toast #59（短暂浮层）划界=CountDown 持久嵌入；与 Skeleton #67（加载占位）划界=CountDown 已加载内容中的倒计时；与 NoticeBar #51（横向滚动公告）划界=CountDown 固定位置时间递减；双端纯从零（全仓无 CountDownView/CountDown.kt） |
| A2 | Token 零硬编码 | ✅ | 数字主色 textPrimary、分隔符次级 textSecondary、结束态强调 error；字号 sizeLg（18）数字+sizeMd（16）辅助；间距 space.sm；圆角 radius.sm（二期单元格）；字重 Semibold+tabular-nums 等宽数字；全走 token，无魔法值 |
| A3 | 决策投票表（ACE） | ✅ | P1-C 同时支持 targetTime+remaining（targetTime 优先=绝对时间精度高不受暂停影响，A 单一淘汰=调用方算时间戳不友好，B 单一淘汰=相对秒自减漂移）；P2-A 每秒基于时间戳重算（手册"用整数秒计算避免浮点累积误差"，B 60fps 淘汰=杀鸡用牛刀，C 累积自减淘汰=误差累积）；P3-A 半受控 paused（声明式对齐 NutUI，恢复时 targetTime+=暂停时长保剩余连续，B 命令式淘汰=与 Compose 范式冲突，C 混流淘汰=语义不清）；P4-A 一期纯文本格式化+自定义格式+暂停/继续+onEnd+demo 四段（单元格样式/毫秒=二期） |
| A4 | Demo 排查 4 组 | ✅ | D1 基础倒计时（剩余 1 小时 HH:mm:ss）；D2 自定义格式（跨天长倒计时 DD 天 HH:mm:ss）；D3 暂停/继续（按钮外部驱动 paused，倒计时冻结/恢复）；D4 结束回调（短倒计时 5 秒，onEnd 触发宿主提示文案） |
| A5 | 实现现状 | ✅ | iOS SharedUI/Components 无 CountDownView=未实现；Android sharedui/components 无 CountDown=未实现；业务秒杀/验证码各自用 Handler+拼字符串未沉淀=双端纯从零；api.json 无 ui.count-down 条目待门禁 B 立项登记；任务清单 #66 ⬜→本规格=双端通用倒计时立项入口 |
| A6 | 平台差异表 | ✅ | 表内放行：计时驱动（Timer.scheduledTimer vs LaunchedEffect+delay，语义一致=每秒基于时间戳重算）；暂停实现（invalidate+存 pauseStart vs LaunchedEffect keyed by paused，算法同构保剩余连续）；等宽数字（monospacedDigitSystemFont vs tabular-nums，同视觉效果） |
| A7 | anti_goals 反目标 | ✅ | 数字单元格分隔样式=二期增量（一期纯文本）；毫秒级精度=二期（一期秒级）；自定义渲染插槽=二期（一期固定 Text/UILabel）；业务结束动作（跳转/提示）=宿主在 onEnd 处理，CountDown 纯展示 |

## 评审结论

| 项 | 内容 |
| -- | --- |
| 结论 | ✅ 通过（P1–P4 决策完整，0 保留意见） |
| 用户签字 | （终核并入用户 C1.5 Demo 实机验收） |
| 下一步 | 门禁 B api.json ui.count-down 契约登记 → 双端独立组件实现（CountDownView.swift / CountDown.kt）→ Demo 双端 1:1 → C1.5 demo 实机 → C1 单测补建 → C2/D |
