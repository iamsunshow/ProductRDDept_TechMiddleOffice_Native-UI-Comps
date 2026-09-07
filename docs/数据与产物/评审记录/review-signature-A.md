# Signature 签名 · 门禁 A 评审单（任务清单 #40 · 全新立项）

> 组件 ID：`ui.signature` ｜ 设计规格：`design-spec/signature-design-spec.html`
> 评审方式：🖊 AI 代评（用户 2026-09-04 总授权"除特色组件外所有组件评审文档全部生成，中间任何询问直接通过"；数据录入区 #39 short-password 收编后下一件，用户 2026-09-06 原话「通过，继续吧」指示接棒启动）
> 评审日期：2026-09-06 ｜ 终核：并入用户 C1.5 Demo 实机验收

## 评审清单

| # | 项 | 判定 | 说明 |
| - | -- | --- | --- |
| A1 | 组件边界（SCQA） | ✅ | 定位=手写签名画板内容组件（数据录入区 #40，全新立项）：内容级横长白底画板（宽宿主填充、高默认 96=2×48 表单交互行基准注释锚定、bgCard+hairline+radiusLg 圆角对齐 Input #29 壳语言）+ 手指/笔自绘圆头笔画（strokeWidth 默认 2/strokeColor 默认 textPrimary 参数可调）+ 空态水印「请在此区域签名」（textSecondary 30% 居中、首笔落下即消失、nil=无水印）+ 底缘引导线；事件 onInkChange(Boolean hasInk)（首笔落 true/清空 false=驱动宿主提交钮可用态）+ clear() 命令式（宿主重签钮调、禁用态忽略）+ disabled 整板 40% 灰不可绘无回调；签名图导出=宿主截取组件渲染（iOS UIGraphicsImageRenderer / Android view.draw 至 Bitmap=跨端同构=组件不内置图形对象）；页面/弹层承载、上传保存防篡改、空签名/锁定业务校验=宿主自理；与 Input #29/textarea #42（键盘文本）、ShortPassword #39/NumberKeyboard #32（数字密码键盘系）、Popup #54/Overlay #6（承载）划界；iOS PencilKit（PKDrawing 生态样式不可统一）/Android 无原生=不收编 |
| A2 | Token 零硬编码 | ✅ | 白底=bgCard、描边/引导线=hairline、圆角=radiusLg（对齐 Input 壳语言）；水印=textSecondary alpha 30% sizeMd（同 Radio/Checkbox 未选中态惯例、库内无 textTertiary token）；禁用=40% 灰（同 Input #29 惯例）；板高默认 96=2×48 交互行基准注释锚定；线宽默认 2/水印文案=组件级集中常量注释锚定；无裸色值/尺寸 |
| A3 | 决策投票表 | ✅ | P1-A 内容级白底自绘画板（B PencilKit=生态样式不可统一双端无法 1:1 淘汰/C 整壳签名组件=壳与动作职责混入宿主淘汰）；P2-A 双端自绘离散 stroke 数组线帽 round（B 贝塞尔插值=两端难像素 1:1 且收益低二期候选/C 原始点集宿主渲染=契约分散淘汰）；P3-A onInkChange+clear() 命令式无受控表单值（签名=异步笔迹流非表单值，B 内置图形对象导出=UIImage vs Bitmap 类型跨端无法统一契约断裂淘汰/C 板内清除钮=与表单区「重签」钮重复破坏白板简洁淘汰）；P4-A 一期 height+placeholder+strokeWidth+strokeColor+disabled+onInkChange+clear()+demo 四段（B 撤销栈/压感/水印多行=膨胀二期/C 内置上传保存失败态=宿主安全职责淘汰） |
| A4 | Demo 排查 4 组 | ✅ | D1 基础签名与重签（空态水印→绘制跟手→onInkChange 段内回显「未签名/已签名」→「重新签名」宿主 clear()）；D2 导出收编（「生成签名图」=宿主 UIGraphicsImageRenderer/view.draw(Bitmap)=段内缩略展示=证宿主可拿矢量签名图）；D3 参数变体（strokeWidth=1/2/4 三块板 1:1 对比+strokeColor 变体=宿主可调深浅粗细）；D4 禁用锁定与空笔迹提交流（「提交锁定」disabled=true 整板 40% 灰不可绘；空板点提交=宿主以 onInkChange(false) 禁用钮并提示「请先签名」） |
| A5 | 实现现状 | ✅ | 双端无 Signature 近似件=全新立项：iOS SharedUI 全量扫描无 signature/手写签名；Android sharedui/components 无签名件、三方库不采用；iOS 系统 PencilKit（PKCanvasView=画布/导出为 PKDrawing 生态且样式不可控）/Android 无原生对应=不收编；api.json 无 ui.signature 条目待门禁 B 立项登记；任务清单 #40 ⬜ 双端未实现 → 本次立项 📐 |
| A6 | 平台差异表 | ✅ | 表内放行：笔画采集（iOS=UIView 子类 UITouch began/moved/ended 换算 bounds 坐标追加 UIBezierPath 数组 draw(_:) 逐 path vs Android=Compose Canvas+pointerInput awaitEachGesture down 起 stroke/drag 采点/up 收 Path 数组重组）、禁用（触摸直接 return vs pointerInput key 含 disabled=false 不启手势=均加 alpha 0.4）、导出（宿主 UIGraphicsImageRenderer.drawHierarchy vs view.draw(canvas) 至 Bitmap）、清除（removeAll+setNeedsDisplay vs mutableStateListOf clear）、圆角壳（layer.cornerRadius+masksToBounds vs clip(RoundedCornerShape)+border hairline）、命名（SignatureView.swift vs Signature.kt）、无障碍（VoiceOver accessibilityLabel 水印/已签名 vs TalkBack contentDescription） |
| A7 | anti_goals 反目标 | ✅ | 内置笔画撤销/重做与压感=编辑器职责（重签=宿主 clear() 已覆盖）二期候选；水印多行文案参数=一期膨胀；PencilKit 生态件与 Android 三方签名库=样式契约无法统一不收编；板内清除钮/整壳签名组件（自带提交栏）=壳与动作职责混入宿主；图形对象导出 API=截组件渲染跨端同构故宿主自理；签名上传/保存/失败态=宿主安全职责；全部登记不混入 |

## 评审结论

| 项 | 内容 |
| -- | --- |
| 结论 | ✅ 通过（P1–P4 全 A，0 保留意见） |
| 用户签字 | （终核并入用户 C1.5 Demo 实机验收） |
| 下一步 | 门禁 B api.json ui.signature 双端契约登记 → 双端独立组件实现（SignatureView.swift / Signature.kt）→ Demo 双端 1:1 → C1.5 demo 实机 → C1 单测 → C2/D |
