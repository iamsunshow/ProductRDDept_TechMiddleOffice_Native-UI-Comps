# Lottie 动画 · 门禁 A 评审单（信息展示区组件 #70 · 全新立项）

> 组件 ID：`ui.lottie` ｜ 设计规格：`design-spec/lottie-design-spec.html`
> 评审方式：🖊 AI 代评（用户 2026-09-04 总授权"除特色组件外所有组件评审文档全部生成，中间任何询问直接通过"）
> 评审日期：2026-09-11 ｜ 终核：并入用户 C1.5 Demo 实机验收

## 评审清单

| # | 项 | 判定 | 说明 |
| - | -- | --- | --- |
| A1 | 组件边界（SCQA） | ✅ | 定位=渲染 Lottie/Bodymovin JSON 动画的容器组件，输入 source/autoplay/loop/speed/size，提供 play/pause/stop 控制与 onComplete 回调，用于启动引导/空状态动效/加载动画/微交互；与 Loading #50（通用加载旋转图标无外部动画源）划界=Lottie 播放设计师生成 JSON 动画文件；与 Empty #1（静态占位）划界=Empty 可嵌 Lottie 增强动效；与 Image #22（静态图）划界=Lottie 帧动画按时间轴逐帧渲染；双端纯从零（全仓无 LottieView/Lottie.kt） |
| A2 | Token 零硬编码 | ✅ | 占位旋转图标主色 AppColor.primary 28×28；动画名称 AppFont.sizeXs/textSecondary；状态标签 primary/primaryMuted；占位卡片圆角 AppRadius.sm；全走 token |
| A3 | 决策投票表（ACE） | ✅ | P1-C source 字符串占位（A 仅本地 JSON 淘汰=需平台文件加载适配/B 仅远程 URL 淘汰=离线不可用，C 一期零三方依赖+API 契约与二期一致）；P2-A autoplay=true loop=true（与 NutUI/lottie-react 默认一致，D1 零配置即播，B 淘汰=样板多）；P3-A 命令式 play/pause/stop + 声明式 autoplay 双模（B 纯声明式淘汰=命令式场景啰嗦）；P4-A 一期占位渲染+全 API+demo 四段（真实 Lottie 渲染=二期） |
| A4 | Demo 排查 4 组 | ✅ | D1 基础动画（autoplay 自动播放）；D2 循环播放（loop=true 持续循环）；D3 控制播放暂停（按钮调 play/pause/stop 切换）；D4 自定义尺寸（80×80 小尺寸展示） |
| A5 | 实现现状 | ✅ | iOS SharedUI/Components 无 LottieView=未实现；Android sharedui/components 无 Lottie.kt=未实现；api.json 无 ui.lottie 条目待门禁 B 立项登记；Demo 列表已登记 planned=true 待改 reviewed=true 挂 demo（iOS 第 126 行/Android 第 341 行） |
| A6 | 平台差异表 | ✅ | 表内放行：状态管理（属性 isPlaying vs remember mutableStateOf 语义一致）、占位渲染（UIActivityIndicatorView vs CircularProgressIndicator 平台原生指示器视觉一致）、尺寸控制（frame 约束 vs Modifier.size）、圆角裁切（layer.cornerRadius+clipsToBounds vs background(RoundedCornerShape) 遵安卓禁令）；视觉一致放行 |
| A7 | anti_goals 反目标 | ✅ | Lottie 库集成（真实 JSON 渲染）=二期增量（一期占位渲染优先编译稳定+API 契约先行）；segments 片段播放=二期；direction 反向播放=二期；远程 URL 下载+缓存=二期；一期不引三方依赖 |

## 评审结论

| 项 | 内容 |
| -- | --- |
| 结论 | ✅ 通过（P1–P4 全选最优，0 保留意见） |
| 用户签字 | （终核并入用户 C1.5 Demo 实机验收） |
| 下一步 | 门禁 B api.json ui.lottie 契约登记 → 双端独立组件实现（LottieView.swift / Lottie.kt）→ Demo 双端 1:1 四段 → C1.5 demo 实机 → C1 单测 → C2/D |
