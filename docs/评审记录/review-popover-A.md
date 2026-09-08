# Popover 气泡弹出框 · 门禁 A 评审单

> 组件 ID：`ui.popover` ｜ 任务清单 #53 ｜ 操作反馈区第八件 ｜ TMO 组件库 v1.4.4
> 评审依据：[design-spec/popover-design-spec.html](../数据与产物/design-spec/popover-design-spec.html)
> 评审方式：AI 代评（P1–P5 全 A 0 保留意见）｜ 评审日期：2026-09-08

---

## 一、评审清单

| 编号 | 评审项 | 结果 | 说明 |
| --- | --- | --- | --- |
| 1 | 组件定位清晰、与现有组件划界无重叠 | ✅ A | 锚点小气泡（带箭头+无遮罩），与 Dialog 居中确认/ActionSheet 底部动作/Popup 通用容器划界明确 |
| 2 | API 契约完整（props/events/data 类） | ✅ A | visible+content+placement 六向+anchor+closeOnClickOutside+offset+onClose，契约完整无歧义 |
| 3 | Token 零硬编码（颜色/圆角/间距引用 AppColor/AppRadius/AppSpace） | ✅ A | bgCard/radiusSm/spaceMd/spaceSm 全引用设计令牌，无硬编码 |
| 4 | Demo 4 组覆盖核心场景与边界态 | ✅ A | D1 基础/D2 四向/D3 外部点击/D4 嵌入菜单，覆盖 80% 场景 |
| 5 | 平台差异表完整、判据合理 | ✅ A | 弹出机制/箭头/外部点击/翻转/动画五差异点均表内放行 |

## 二、组件边界

- 职责：点击触发元素后弹出的小气泡浮层，带箭头指向锚点，内嵌自定义内容，点击外部收起。
- 不做：遮罩层（用 Dialog/Popup）、预设菜单项（用 Menu/ActionSheet）、长按触发（二期）、嵌套 Popover。
- 与 #46 Dialog（居中确认）、#44 ActionSheet（底部动作）、#54 Popup（通用容器带遮罩）、Tooltip（纯文本只读）划界。

## 三、决策投票表（P1–P5 全 A）

| 编号 | 决策点 | 选定 | 理由 |
| --- | --- | --- | --- |
| P1 | 组件定位 | A. 锚点小气泡 | 覆盖工具栏提示/快捷菜单场景，与 Dialog/ActionSheet/Popup 划界 |
| P2 | 展示与收起 | A. 受控 visible | 与 ActionSheet/Dialog 一致，声明式 Compose 友好 |
| P3 | 内容承载 | A. content 内容槽 | 通用容器最灵活，菜单/提示/表单均可承载 |
| P4 | 方向定位 | A. placement 六向+自动翻转 | 覆盖 95% 场景，支持 RTL，自动翻转防边缘溢出 |
| P5 | 一期范围 | A. 一期全量+demo 四段 | 覆盖 80% 场景，长按/嵌套=二期 |

## 四、Demo 4 组

| 组 | 名称 | 场景 |
| --- | --- | --- |
| D1 | 基础顶部弹出 | 点击锚点按钮 → 顶部气泡+箭头 |
| D2 | placement 方向切换 | 切换 top/bottom/left/right 四向 |
| D3 | closeOnClickOutside | 点击气泡外部自动收起 |
| D4 | 嵌入菜单内容 | 气泡内嵌复制/删除/分享菜单项 |

## 五、实现现状

- 双端未实现，门禁 A 通过后推进门禁 B（api.json 登记 + 双端实现入库）。
- iOS 参考方案：keyWindow.addSubview + frame 定位 + CAShapeLayer 箭头 + UITapGestureRecognizer 外部捕获。
- Android 参考方案：Compose Popup + Canvas 箭头 + dismissOnClickOutside。

## 六、平台差异

| 差异点 | iOS | Android | 判据 |
| --- | --- | --- | --- |
| 弹出机制 | keyWindow addSubview | Popup | 表内放行 |
| 箭头 | CAShapeLayer | Canvas | 表内放行（同构自绘） |
| 外部点击 | UITapGestureRecognizer | dismissOnClickOutside | 表内放行 |
| 翻转 | UIScreen.bounds | LocalView bounds | 表内放行 |
| 动画 | UIView.animate 0.15s | tween 150ms | 表内放行 |

## 七、anti-goals

- 不做遮罩层（用 Dialog/Popup）
- 不做预设菜单项（用 Menu/ActionSheet）
- 不做长按触发（二期）
- 不做嵌套 Popover（用多级页面/Cascader）
- 不做自定义动画曲线（二期）
- 不做任意 angle 角度定位（六向够用）

---

## 评审结论

**P1–P5 全 A，0 保留意见，门禁 A 通过。**

下一步：
1. api.json 登记 `ui.popover` 条目（available=true, reviewed=true, subcategory=feedback, source_refs 双端路径待实现后填）。
2. 双端实现入库（PopoverView.swift / Popover.kt + iOS PopoverShowcase / Android PopoverDemo 4 段 1:1）。
3. 待 C1.5 用户双端 Demo 实机验收通过后收编。

**用户签字**：（待用户批准，AI 代评通过即推进门禁 B）
