# SafeArea 安全区 · 门禁 A 评审单（设计评审）

> 组件 ID：`ui.safe-area` ｜ 分类：布局组件（layout）｜ 版本基线：v1.4.0（2026-09-04，未过 C2/D 不升版）
> 设计规格：`docs/数据与产物/design-spec/safe-area-design-spec.html`
> 评审日期：2026-09-04 ｜ 状态：🖊 AI 代评通过（用户 2026-09-04 指令"中间任何询问直接通过"总授权代评，P1–P4 推荐全 A；最终复核并入用户总验收）

---

## 评审清单（逐项 ☑️/☐）

### A1 · 组件定位与边界
- [x] 确认适用场景覆盖：页面级避让 / 沉浸式 header 内容 / 底部操作条不贴手势区 / 横屏圆角避让 / 安全区与栏外观分离
- [x] 确认不适用边界：系统栏颜色明暗→SystemBars、键盘避让→二期候选、安全区内排版→页面布局组件
- [x] 确认五态适配：纯适配容器，默认态 ✅，交互/状态 N/A（内容组件承担）

### A2 · Token 引用（零硬编码）
- [x] 避让数值 = 系统实时 insets（iOS safeAreaInsets / Android WindowInsets.safeDrawing），无自定义常量
- [x] edges 裁剪入口 = 枚举集合（top/bottom/left/right 默认全边）
- [x] 容器透明 pass-through（零绘制零背景）

### A3 · 决策投票（4 条 ACE，2026-09-04 AI 代评全票 A）

| 编号 | 决策项 | 推荐 | 代评投票 |
|------|--------|------|----------|
| P1 | 组件形态 | A：容器式 SafeArea{content}（自动避让） | ✅ A |
| P2 | 避让边模型 | A：四边可配 top/bottom/left/right（默认全边） | ✅ A |
| P3 | Android insets 源 | A：WindowInsets.safeDrawing（聚合 statusBars+navigationBars+displayCutout） | ✅ A |
| P4 | 一期范围裁剪 | A：仅容器式避让（键盘/动画/注入登记二期） | ✅ A |

### A4 · Demo 4 组排查（双端 1:1，待 C1.5 用户实机）
- [ ] D1 顶部避让对照（SafeArea 内 vs 无避让压状态栏）
- [ ] D2 底部操作条避让（不贴 Home Indicator）
- [ ] D3 沉浸式页面四边避让（深色 header 全屏出血）
- [ ] D4 边裁剪（仅 top / 仅 bottom）

### A5 · 双端实现现状（全新立项：api.json 无条目、代码无实现——本评审通过后开发）
- [x] 立项前核对：api.json 无 `ui.safe-area` 条目、组件进度 §3.2 行 10 ⬜、无业务收编来源=全新组件
- [x] 命名规约：iOS 需规避 UIKit 既有 SafeArea 相关类名冲突（候选 SafeAreaView）；Android SafeArea（Compose 无内置同名）
- [x] 实现架构预告：iOS UIView 容器按 safeAreaLayoutGuide 约束四边；Android Box + Modifier.windowInsetsPadding(WindowInsets.safeDrawing.only(edges))

### A6 · 已知差异（框架原生，表内放行）
- [x] 数据源：iOS safeAreaInsets vs Android WindowInsets.safeDrawing（系统原生，数值语义对齐）
- [x] 容器：iOS safeAreaLayoutGuide 约束 vs Compose windowInsetsPadding Modifier
- [x] edges 表示：OptionSet vs Set<枚举>（一一对应）

### A7 · anti_goals（反目标，需明确排除）
- [x] 不做系统栏颜色/图标明暗（SystemBars 职责）
- [x] 不做键盘避让 imePadding（二期候选）
- [x] 不做 insets 取值函数单 API（容器一期足够）
- [x] 不自定义任何避让数值（全取系统实时值）
- [x] 不做旋转/转场动画适配

---

## 评审结论

| 结果 | 项数 |
|------|------|
| 🖊 门禁 A 通过（AI 代评） | 2026-09-04（用户"中间任何询问直接通过"总授权；P1–P4 全 A） |

- **A1/A2/A3/A5/A6/A7**：✅ 通过（规格批准 + P1–P4 全 A）。
- **A4**：Demo 4 组排查待双端实现后 C1.5 用户实机验收（门禁 C1/C1.5 阶段）。

**代评说明**：本单由 CodeBuddy 依用户 2026-09-04 授权代评（"中间任何询问直接通过"），推荐决策全部按 A 记录；用户最终验收 demo 时可行使最终裁决，任何 P 项可被推翻重议。
