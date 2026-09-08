# NoticeBar 公告栏 · 门禁 A 评审单（操作反馈区 #51）

> 组件 ID：`ui.notice-bar` ｜ 设计规格：`design-spec/notice-bar-design-spec.html`
> 评审方式：🖊 AI 代评（用户 2026-09-04 总授权"除特色组件外所有组件评审文档全部生成，中间任何询问直接通过"）
> 评审日期：2026-09-08 ｜ 终核：并入用户全批统一验收（C1.5 实机 Demo）

## 评审清单

| # | 项 | 判定 | 说明 |
| - | -- | --- | --- |
| A1 | 组件边界（SCQA） | ✅ | 定位=顶部/内嵌公告栏；与 Toast #59（轻提示自动消失）/Notify #52（顶部全局短时浮层 vs NoticeBar 页面内嵌占位）/Dialog #46（弹窗）/Loading #50（加载指示）划界清晰；anti_goals=浮层模式/autoClose 倒计时圆环/action 按钮/tag 信息标/description 副文本二期 |
| A2 | Token 零硬编码 | ✅ | 视觉全 token 化：默认高 40、背景 #FFF7ED、文本 textPrimary sizeSm 14、图标 16×16、间距 spaceSm 8、圆角 radiusSm 6、速度 50px/s、停留 1000ms；backgroundColor/textColor/textSize/height/speed/delay/duration 全参数化可配 |
| A3 | 决策投票表 | ✅ | P1-A 双方向（horizontal/vertical）+可关闭+左右图标 slot 页面内嵌占位；P2-A 一期 horizontal+vertical+closeable+leftIcon/rightIcon+speed/delay/duration+Demo 4 组（二期补 autoClose 圆环/action 按钮/tag/description）；P3-A iOS CADisplayLink 驱动 UILabel frame.origin.x；P4-A Android LaunchedEffect+animateScrollTo |
| A4 | Demo 排查 4 组 | ✅ | D1 基础横向滚动（horizontal 跑马灯）；D2 纵向多条轮播（vertical+list）；D3 可关闭（closeable=true 右侧 ×+onClose）；D4 自定义左右图标+自定义配色 |
| A5 | 实现现状 | ✅ | 双端均未实现（任务清单行 51 ⬜，api.json 待立项），本规格为立项入口 |
| A6 | 平台差异表 | ✅ | 表内放行：horizontal 滚动（CADisplayLink vs animateScrollTo 系统级差异）、vertical 滚动（Timer+CATransition vs LaunchedEffect+LazyColumn）、容器布局（UIView+UIStackView vs Box+Row/Column）、关闭按钮（UIButton vs Text+clickable）、图标 slot（UIView? vs @Composable） |
| A7 | anti_goals 反目标 | ✅ | autoClose 倒计时圆环（UI 复杂度高，一期无强需求）、action 操作按钮（二期补）、tag 信息标（二期补）、description 副文本（二期补）均登记二期 |

## 评审结论

| 项 | 内容 |
| -- | --- |
| 结论 | ✅ 通过（P1–P4 全 A，0 保留意见） |
| 用户签字 | （终核并入用户全批统一验收 2026-09-08） |
| 下一步 | 门禁 B api.json 契约登记 → 双端实现 → C1.5 demo 实机 |
