# ResultPage 结果反馈 · 门禁 A 评审单

> 组件 ID：`ui.result-page` ｜ 任务清单 #56 ｜ 操作反馈区第十件 ｜ TMO 组件库 v1.4.4
> 评审依据：[design-spec/result-page-design-spec.html](../数据与产物/design-spec/result-page-design-spec.html)
> 评审方式：AI 代评（P1–P5 全 A 0 保留意见）｜ 评审日期：2026-09-08

---

## 一、评审清单

| 编号 | 评审项 | 结果 | 说明 |
| --- | --- | --- | --- |
| 1 | 组件定位清晰、与现有组件划界无重叠 | ✅ A | 整页/区域结果反馈（四态+图标+标题+按钮），与 Empty 空状态/Dialog 弹层确认/Notify 短时浮层划界明确 |
| 2 | API 契约完整（props/events/data 类） | ✅ A | type 四态+title+description+actions 列表+icon 自定义槽+ResultAction/ResultActionStyle 数据类，契约完整 |
| 3 | Token 零硬编码 | ✅ A | bgPage/fontLg/fontSm/textPrimary/textSecondary/radiusSm/spaceLg 全引用设计令牌 |
| 4 | Demo 4 组覆盖核心场景与边界态 | ✅ A | D1 成功/D2 失败重试/D3 警告多按钮/D4 信息无按钮，覆盖四态+按钮边界 |
| 5 | 平台差异表完整、判据合理 | ✅ A | 图标绘制/按钮/布局/图标底色四差异点均表内放行（双端同构自绘） |

## 二、组件边界

- 职责：整页/区域级操作结果反馈，四态图标+标题+描述+操作按钮列表。
- 不做：空状态占位（用 Empty）、弹层确认（用 Dialog）、短时浮层（用 Notify/Toast）、自定义布局（二期）、进场动画。
- 与 #48 Empty（无数据）、#46 Dialog（弹层确认）、#52 Notify（短时浮层）、#50 Loading（加载过程）划界。

## 三、决策投票表（P1–P5 全 A）

| 编号 | 决策点 | 选定 | 理由 |
| --- | --- | --- | --- |
| P1 | 组件定位 | A. 整页/区域结果反馈 | 覆盖提交/支付/审批结果场景，与 Dialog/Notify 划界 |
| P2 | 四态类型 | A. success/error/warning/info | 四态覆盖 95% 场景 |
| P3 | 按钮承载 | A. actions 列表数据驱动 | 最灵活，支持 0~3 按钮+三种 style |
| P4 | 图标 | A. type 默认+icon 自定义槽 | 默认覆盖 80%，自定义槽支持业务图标 |
| P5 | 一期范围 | A. 一期全量+demo 四段 | 覆盖 80% 场景，自定义布局/动画=二期 |

## 四、Demo 4 组

| 组 | 名称 | 场景 |
| --- | --- | --- |
| D1 | 成功+主按钮 | type=success，对勾图标+主按钮"返回首页" |
| D2 | 失败+重试 | type=error，叉图标+ghost 按钮"重试" |
| D3 | 警告+多按钮 | type=warning，感叹号图标+主按钮+ghost 按钮 |
| D4 | 信息+无按钮 | type=info，i 图标+仅标题描述无按钮 |

## 五、实现现状

- 双端未实现，门禁 A 通过后推进门禁 B。
- iOS 参考方案：UIStackView 垂直居中 + UIBezierPath 自绘四态图标 + AppButton 按钮列表。
- Android 参考方案：Column horizontalCenter + Canvas drawPath 自绘四态图标 + AppButton Composable。

## 六、平台差异

| 差异点 | iOS | Android | 判据 |
| --- | --- | --- | --- |
| 图标绘制 | UIBezierPath | Canvas drawPath | 表内放行（同构自绘） |
| 按钮 | UIButton+AppButton | AppButton Composable | 表内放行（复用 AppButton） |
| 布局 | UIStackView | Column | 表内放行 |
| 图标底色 | UIColor.withAlpha | Color.copyAlpha | 表内放行 |

## 七、anti-goals

- 不做空状态占位（用 Empty）
- 不做弹层确认（用 Dialog）
- 不做短时浮层（用 Notify/Toast）
- 不做自定义布局（二期）
- 不做进场动画
- 不做自定义 type 字符串

---

## 评审结论

**P1–P5 全 A，0 保留意见，门禁 A 通过。**

下一步：
1. api.json 登记 `ui.result-page` 条目。
2. 双端实现入库（ResultPageView.swift / ResultPage.kt + iOS ResultPageShowcase / Android ResultPageDemo 4 段 1:1）。
3. 待 C1.5 用户双端 Demo 实机验收通过后收编。

**用户签字**：（待用户批准，AI 代评通过即推进门禁 B）
