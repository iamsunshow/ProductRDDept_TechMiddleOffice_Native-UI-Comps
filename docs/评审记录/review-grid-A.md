# Grid 宫格 · 门禁 A 评审单（设计评审）

> 组件 ID：`ui.grid` ｜ 分类：布局组件（navigation） ｜ 版本基线：v1.4.0（组件 v2.0）
> 设计规格：`docs/数据与产物/design-spec/grid-design-spec.html`
> 评审日期：2026-09-04

---

## 评审清单（逐项 ☑️/☐）

### A1 · 组件定位与边界
- [x] 确认适用场景覆盖：首页快捷入口 / 发现页导航 / 功能菜单 / 图标+文字矩阵
- [x] 确认不适用边界：单块容器→Card、文字列表→Cell、滑动标签→Tabs
- [x] 确认五态适配：默认态+点击态 ✅，禁用/加载/成功/失败 N/A

### A2 · Token 引用（零硬编码）
- [x] 卡片背景色 = AppColor.bgCard
- [x] 卡片圆角 = AppRadius.lg (14)
- [x] 卡片边框 = AppColor.border
- [x] 内边距 = AppSpace.lg (16)
- [x] 标题间距 = AppSpace.md (12)
- [x] 图标颜色 = AppColor.primary
- [x] 文字字号 = AppFont.sizeXs (12)
- [x] 图标文字间距 = AppSpace.xs (4)

### A3 · 决策投票（4 条 ACE）

| 编号 | 决策项 | 推荐 | 用户投票 |
|------|--------|------|----------|
| P1 | 组件命名 | B：重命名为 Grid（非 NavigationGrid） | ✅（已按推荐实施，NavigationGrid 已废弃删除） |
| P2 | 图标尺寸统一 | A：统一 26 | ✅（双端 iconContainer 26，用户 Demo 验收确认） |
| P3 | 列数支持 | A：暴露 column prop，默认 4 | ✅（Demo 验收确认默认 4 列等分） |
| P4 | 分区标题 | A：title 可选 | ✅（D2 带标题/D1 无标题双端 Demo 验收确认） |

### A4 · Demo 4 组排查
- [x] D1 基础四宫格（4列1行，无标题）
- [x] D2 带标题分区（标题+4列网格）
- [x] D3 可点击交互（onSelect/onClick 回调验证）
- [x] D4 多分组网格（两个 Grid 垂直排列）

### A5 · 双端实现现状（已按独立组件化 v2.0 重构，NavigationGrid 已废弃删除）
- [x] iOS：Grid.swift 单文件独立 UIView（~200 行）：卡片壳（白底/圆角 lg/0.5px 边框/padding lg）+ 可选标题 + 等分网格；column/title/onSelect 三 API；iconContainer 26pt 圆角 6（primary）+ SF Symbol 白色 16pt；行高 72pt；按压态=灰底 alpha 回弹
- [x] Android：Grid.kt 单 Composable（~135 行）：同 API（column 默认 4/title 空串隐藏/onSelect 返回索引）；26dp 圆角 6（primary）+ AppIcon 16dp 白；行高 72dp；点击=默认 ripple
- [x] 双端 Demo 已 1:1 对齐（4 组排查 D1-D4，iOS GridShowcase / Android GridDemo，徽标 v2.0）；GridItem 数据类：iOS symbolName（SF Symbol）/ Android icon（AppIconName 枚举，双端映射一致）

### A6 · 已知差异（表内放行）
- [x] 图标容器尺寸已双端统一 26（P2 推荐 A 已按实现，用户 Demo 验收确认）
- [x] 回调参数：index vs id（门禁 B 决策，暂按 index 实现）
- [x] 边框线宽：iOS 1/scale pt vs Android 0.5dp（视觉等价，平台惯例，表内放行）
- [x] 按压反馈：iOS 灰底变暗 vs Android ripple（系统默认按压反馈差异，表内放行）

### A7 · anti_goals（反目标，需明确排除）
- [x] 不支持禁用态（由 data 层过滤）
- [x] 不支持加载态/骨架屏（归 Skeleton 组件）
- [x] 不支持拖拽排序（归 Drag 组件）
- [x] 不支持横向滚动（列数固定，超出等分）

---

## 评审结论

| 结果 | 项数 |
|------|------|
| ☑️ 通过 | 11/11 |
| ☐ 待确认 | 0/11 |

**用户签字**：🧑 用户 2026-09-04 原话『Grid已经通过了』（Demo 实机首轮即通过，4 组 1:1 零问题，覆盖 A4 全项）

**评审结果**：☑️ 通过（进入开发 / C1.5 Demo 实机已同步通过）
