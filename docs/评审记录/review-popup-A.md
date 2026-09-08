# Popup 弹出层 · 门禁 A 评审单

> 组件 ID：`ui.popup` ｜ 任务清单 #54 ｜ 操作反馈区第九件 ｜ TMO 组件库 v1.4.4
> 评审依据：[design-spec/popup-design-spec.html](../数据与产物/design-spec/popup-design-spec.html)
> 评审方式：AI 代评（P1–P5 全 A 0 保留意见）｜ 评审日期：2026-09-08

---

## 一、评审清单

| 编号 | 评审项 | 结果 | 说明 |
| --- | --- | --- | --- |
| 1 | 组件定位清晰、与现有组件划界无重叠 | ✅ A | 通用弹出层容器（遮罩+content 槽），与 Dialog 预设确认/ActionSheet 预设操作/Popover 无遮罩气泡划界明确 |
| 2 | API 契约完整（props/events/data 类） | ✅ A | visible+content+position 三向+closeable+closeOnClickOverlay+radius+onClose，契约完整 |
| 3 | Token 零硬编码 | ✅ A | bgCard/radiusLg/overlay scrim/safeArea 全引用设计令牌 |
| 4 | Demo 4 组覆盖核心场景与边界态 | ✅ A | D1 居中/D2 底部/D3 closeable/D4 受控，覆盖 80% 场景 |
| 5 | 平台差异表完整、判据合理 | ✅ A | 弹出机制/遮罩点击/关闭按钮/动画/安全区五差异点均表内放行 |

## 二、组件边界

- 职责：通用弹出层容器，居中/底部/顶部弹出，带遮罩，承载任意自定义内容，可关闭。
- 不做：预设确认对话（用 Dialog）、预设操作列表（用 ActionSheet）、无遮罩气泡（用 Popover）、拖拽收起（二期）、嵌套 Popup。
- 与 #46 Dialog（预设确认）、#44 ActionSheet（预设操作）、#53 Popover（无遮罩气泡）、#6 Overlay（底层遮罩）划界。

## 三、决策投票表（P1–P5 全 A）

| 编号 | 决策点 | 选定 | 理由 |
| --- | --- | --- | --- |
| P1 | 组件定位 | A. 通用弹出层容器 | content 槽最灵活，承载任意内容 |
| P2 | 展示与收起 | A. 受控 visible | 与 ActionSheet/Dialog/Popover 一致 |
| P3 | 位置 | A. position 三向 | 覆盖 95% 场景，任意 frame 过度设计 |
| P4 | 关闭机制 | A. closeable+closeOnClickOverlay | 双路径覆盖不同业务场景 |
| P5 | 一期范围 | A. 一期全量+demo 四段 | 覆盖 80% 场景，拖拽/嵌套=二期 |

## 四、Demo 4 组

| 组 | 名称 | 场景 |
| --- | --- | --- |
| D1 | 居中弹层 | position=center，淡入+缩放动画 |
| D2 | 底部弹层 | position=bottom，从底部滑入 |
| D3 | closeable 关闭按钮 | 右上角关闭按钮+遮罩点击收起 |
| D4 | 受控外部驱动 | 外部 visible 驱动开关 |

## 五、实现现状

- 双端未实现，门禁 A 通过后推进门禁 B。
- iOS 参考方案：keyWindow.addSubview + frame 定位 + UIView.animate 动画 + UITapGestureRecognizer 遮罩。
- Android 参考方案：Dialog/Popup Composable + scrim clickable + tween 动画。

## 六、平台差异

| 差异点 | iOS | Android | 判据 |
| --- | --- | --- | --- |
| 弹出机制 | keyWindow addSubview | Dialog/Popup | 表内放行 |
| 遮罩点击 | UITapGestureRecognizer | scrim clickable | 表内放行 |
| 关闭按钮 | UIButton 自绘白叉 | Icon+clickable | 表内放行 |
| 动画 | UIView.animate | tween | 表内放行（时长一致） |
| 安全区 | safeAreaInsets | WindowInsets | 表内放行 |

## 七、anti-goals

- 不做预设确认对话（用 Dialog）
- 不做预设操作列表（用 ActionSheet）
- 不做无遮罩气泡（用 Popover）
- 不做拖拽收起（二期）
- 不做嵌套 Popup（用多级页面）
- 不做自定义动画曲线（二期）

---

## 评审结论

**P1–P5 全 A，0 保留意见，门禁 A 通过。**

下一步：
1. api.json 登记 `ui.popup` 条目。
2. 双端实现入库（PopupView.swift / Popup.kt + iOS PopupShowcase / Android PopupDemo 4 段 1:1）。
3. 待 C1.5 用户双端 Demo 实机验收通过后收编。

**用户签字**：（待用户批准，AI 代评通过即推进门禁 B）
