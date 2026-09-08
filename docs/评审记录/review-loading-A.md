# Loading 加载中 · 门禁 A 评审单（操作反馈区 #50）

> 组件 ID：`ui.loading` ｜ 设计规格：`design-spec/loading-design-spec.html`
> 评审方式：🖊 AI 代评（用户 2026-09-04 总授权"除特色组件外所有组件评审文档全部生成，中间任何询问直接通过"）
> 评审日期：2026-09-08 ｜ 终核：并入用户全批统一验收（C1.5 实机 Demo）

## 评审清单

| # | 项 | 判定 | 说明 |
| - | -- | --- | --- |
| A1 | 组件边界（SCQA） | ✅ | 定位=全屏/区域遮罩加载指示器；与 InfiniteLoading #49（列表底部状态条）/CircleProgress #64（有进度值环形进度）/Progress #73（有进度值条形进度）/Skeleton #57（首屏占位骨架）/PullRefresh #55（下拉刷新）/Toast #59（轻提示）划界清晰；anti_goals=自包含遮罩/纯图标/Lottie 三方依赖/自定义 icon slot 二期 |
| A2 | Token 零硬编码 | ✅ | 视觉全 token 化：图标默认 sizeLg 18、文案 sizeSm 14、颜色 textSecondary、间距 spaceSm 8；circular=系统原生 UIActivityIndicatorView/CircularProgressIndicator；spinner=5 线自绘 scaleY 0.4↔1 交替延迟 1s；color/size/textSize/direction 全参数化可配 |
| A3 | 决策投票表 | ✅ | P1-A 纯加载指示器模式（不内置遮罩，宿主组合 Overlay #6 做全屏加载=与 NutUI Loading+Overlay 组合模式一致）；P2-A 双类型 circular（系统原生）+ spinner（5 线自绘）；P3-A iOS circular=UIActivityIndicatorView/spinner=CAShapeLayer+5 线 CABasicAnimation；P4-A 双类型+双方向+可选文案+color/size/textSize+Demo 4 组 |
| A4 | Demo 排查 4 组 | ✅ | D1 基础加载（circular 无文案）；D2 带文案（horizontal+vertical 双方向）；D3 spinner 类型+自定义颜色大小（color=primary size=32 textSize=sizeMd）；D4 全屏遮罩加载（Overlay+Loading vertical 组合，阻断交互） |
| A5 | 实现现状 | ✅ | 双端均未实现（任务清单行 50 ⬜，api.json 待立项），本规格为立项入口 |
| A6 | 平台差异表 | ✅ | 表内放行：circular 实现（UIActivityIndicatorView vs CircularProgressIndicator 系统级差异）、spinner 实现（CAShapeLayer vs Canvas 5 线交替，控制点 1:1 对齐）、文案渲染（UILabel vs Text）、方向排列（UIStackView vs Row/Column）、全屏遮罩（Overlay #6 统一承载） |
| A7 | anti_goals 反目标 | ✅ | 自包含遮罩模式（与 Overlay #6 职责重叠）、纯图标模式（缺文案基础体验）、Lottie 三方依赖（与库内零三方依赖原则冲突）、自定义 icon slot（双端一致性难保证）均登记二期 |

## 评审结论

| 项 | 内容 |
| -- | --- |
| 结论 | ✅ 通过（P1–P4 全 A，0 保留意见） |
| 用户签字 | （终核并入用户全批统一验收 2026-09-08） |
| 下一步 | 门禁 B api.json 契约登记 → 双端实现 → C1.5 demo 实机 |
