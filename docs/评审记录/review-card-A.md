# Card 摘要卡片 · 门禁 A 评审单（任务清单 #85 · 未评审组件补齐批）

> 组件 ID：`ui.card` ｜ 设计规格：`design-spec/card-design-spec.html`
> 评审方式：🖊 AI 代评（用户 2026-09-04 总授权；2026-09-14「2.0的组件本次不开发，优先开发未评审的组件」指示接棒）
> 评审日期：2026-09-14 ｜ 组件库版本：v1.4.0 ｜ 终核：并入用户 C1.5 Demo 实机验收

## 评审清单

| # | 项 | 判定 | 说明 |
| - | -- | --- | --- |
| A1 | 组件边界（SCQA） | ✅ | 定位=通用摘要卡片容器（壳 + 标题行含右箭头 + 副标题 + 数值行含辅助文案），整卡可点；与 Cell 划界=行 vs 块（Card 含大号数值区）；与 Price #72 划界=数值文本控件 vs 卡片容器（组合关系）；与 Grid #8/Layout #9 划界=排布归它们；与业务专用卡划界=Card 不含业务字段 |
| A2 | Token 零硬编码 | ⚠ **发现 1 处硬编码（本轮整治）** | Android 全量使用令牌（<code>AppColor.bgCard</code>/<code>AppRadius.lg</code>/<code>AppSpace</code>/<code>AppFont</code>）；**iOS <code>SummaryCardView</code> 壳底色硬编码 <code>.white</code>**（第 21 行），应在本轮 Demo 阶段改为 <code>AppColor.bgCard</code>；其余（圆角/边框色/字号/间距）均已用令牌 |
| A3 | 决策投票表 | ✅ | P1-A 数据驱动（非内容槽；内容槽=二期）；P2-A 右箭头常显（对齐既有双端实现，一期不改契约）；P3-A 数值着色由调用方传 <code>valueColor</code>（组件保持业务无关，同 MoneyFormat P3）；P4-A 一期=基础/辅助文案/数值着色/可点击 + Demo 4 段 |
| A4 | Demo 排查 4 组 | ✅ | D1 基础（标题+副标题+数值）/ D2 带辅助文案（accessory 基线右靠）/ D3 数值着色（expense 红 / income 绿）/ D4 可点击（onClick 段内回显） |
| A5 | 实现现状 | ✅ | Android `android/sharedui/components/SummaryCardView.kt`（Composable 参数驱动，已实现）；iOS `ios/SharedUI/Components/SummaryCardView.swift`（UIControl + <code>apply(...)</code>，已实现）。api.json `ui.card` 已是 `reviewed=true`（2026-09-03 记账批次 v1.0）但 **demo 列表未挂展示页**（`planned=true` 灰标）。**缺口=Door A 规格/评审单（本轮补）+ Demo 展示页 + demo 注册行状态收编** |
| A6 | 平台差异表 | ✅ | 表内放行：边框线宽（iOS 1/scale pt vs Android 0.5dp）、点击反馈（iOS 无内建按压 vs Android ripple）、基线对齐（<code>.lastBaseline</code> vs <code>Alignment.Bottom</code>）。**待整治**：iOS 壳底色硬编码 <code>.white</code> → 应改 <code>AppColor.bgCard</code>（本轮修） |
| A7 | anti_goals 反目标 | ✅ | 自由内容槽=二期；多数值列/迷你图表=二期；角标/红点=归 Tabbar/Cell；骨架屏/加载态=二期 |

## 评审结论

| 项 | 内容 |
| -- | --- |
| 结论 | ✅ 通过（P1–P4 全 A，0 保留意见；含 1 处硬编码整治项） |
| 用户签字 | （终核并入用户 C1.5 Demo 实机验收） |
| 下一步 | 修正 iOS <code>SummaryCardView</code> 壳底色为 <code>AppColor.bgCard</code> → 双端 Demo（CardShowcase / CardDemo 4 段 1:1）→ api.json 补 subcategory/note → demo 注册行 planned→reviewed → C1.5 验收 |
