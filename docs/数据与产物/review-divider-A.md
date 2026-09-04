# Divider 分割线 · 门禁 A 评审单（设计评审）

> 组件 ID：`ui.divider` ｜ 分类：布局组件（layout） ｜ 版本基线：v1.4.0
> 设计规格：`docs/数据与产物/design-spec/divider-design-spec.html`
> 评审日期：2026-09-04

---

## 评审清单（逐项 ☑️/☐）

### A1 · 组件定位与边界
- [ ] 确认适用场景覆盖：列表/表单分隔 / 带文本分区 / 行内垂直分隔 / 虚线分隔
- [ ] 确认不适用边界：Cell 内置分隔线不归此管、卡片边框→Card、间距→Space
- [ ] 确认五态适配：仅默认态 ✅，其余 N/A（纯展示组件）

### A2 · Token 引用（零硬编码）
- [ ] 线条颜色 = AppColor.border
- [ ] hairline = 1/scale pt (iOS) / 0.5dp (Android)
- [ ] 文本字号 = AppFont.sizeXs (12)
- [ ] 文本颜色 = AppColor.textSecondary
- [ ] 文本间距 = AppSpace.sm (8)
- [ ] 上下外边距 = AppSpace.sm (8)

### A3 · 决策投票（4 条 ACE）

| 编号 | 决策项 | 推荐 | 用户投票 |
|------|--------|------|----------|
| P1 | hairline 默认值 | A：默认 true（0.5px 细线） | ☐ |
| P2 | 虚线支持 | A：支持 dashed prop，默认 false | ☐ |
| P3 | 文本位置 | A：支持 left/center/right | ☐ |
| P4 | 垂直方向 | A：支持 horizontal + vertical | ☐ |

### A4 · Demo 4 组排查
- [ ] D1 基础分割线（默认 hairline，无文本）
- [ ] D2 虚线 + 粗线（dashed=true / hairline=false）
- [ ] D3 带文本分割线（left / center / right 三位置）
- [ ] D4 垂直分割线（行内分隔）

### A5 · 双端实现现状
- [ ] iOS：无独立 Divider 组件（需新建 Divider.swift）
- [ ] Android：内联 HorizontalDivider（CommonComponents/ProfileListGroup），无独立组件（需新建 Divider.kt）
- [ ] 双端 Demo 占位已有（iOS reviewed=false create:nil / Android 无 demo lambda）

### A6 · 已知差异（待表决）
- [ ] hairline 实现：iOS 1/scale pt vs Android 0.5dp（平台惯例，建议保留）
- [ ] 虚线实现：iOS CAShapeLayer vs Android PathEffect（平台 API 差异，视觉一致）
- [ ] 架构差异：iOS UIView vs Android Composable（平台惯例，保留）

### A7 · anti_goals（反目标，需明确排除）
- [ ] 不支持点击交互（Divider 为纯展示）
- [ ] 不支持动画/过渡效果
- [ ] 不支持自定义颜色（统一 AppColor.border）
- [ ] 不支持自定义角度（仅 horizontal/vertical）

---

## 评审结论

| 结果 | 项数 |
|------|------|
| ☑️ 通过 | /11 |
| ☐ 待确认 | /11 |

**用户签字**：________________

**评审结果**：☐ 通过（进入门禁 B） / ☐ 打回（修改后重新评审）
