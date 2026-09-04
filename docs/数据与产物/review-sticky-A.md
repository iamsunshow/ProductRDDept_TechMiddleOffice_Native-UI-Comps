# Sticky 粘性布局 · 门禁 A 评审单（设计评审）

> 组件 ID：`ui.sticky` ｜ 分类：布局组件（layout）｜ 版本基线：v1.4.0（2026-09-04，未过 C2/D 不升版）
> 设计规格：`docs/数据与产物/design-spec/sticky-design-spec.html`
> 评审日期：2026-09-04 ｜ 状态：🖊 AI 代评通过（用户 2026-09-04 指令"中间任何询问直接通过"总授权代评，P1–P4 推荐全 A；最终复核并入用户总验收）

---

## 评审清单（逐项 ☑️/☐）

### A1 · 组件定位与边界
- [x] 确认适用场景覆盖：分组列表组标题吸顶 / 筛选排序条吸顶 / 表头吸顶 / 长表单章节标题
- [x] 确认不适用边界：悬浮操作→BackTop/HoverButton、底部固定栏→页面级 bottomBar、侧边导航→SideBar、单屏不滚动布局
- [x] 确认五态适配：默认态 ✅（随流排布）+ 吸顶态 ✅（钉顶）；交互/加载/失败 N/A

### A2 · Token 引用（零硬编码）
- [x] 吸顶条视觉由内容组件自带（Sticky 行为容器零视觉 token）
- [x] offset 显式传参（默认 0），z 序浮于内容之上（规则常量）
- [x] 吸顶态视觉不变式一期（无额外 token/状态样式）

### A3 · 决策投票（4 条 ACE，2026-09-04 AI 代评全票 A）

| 编号 | 决策项 | 推荐 | 代评投票 |
|------|--------|------|----------|
| P1 | 一期形态 | A：单吸顶行封装（列表原生 stickyHeader + 通用滚动 pinned 双路径） | ✅ A |
| P2 | 承载滚动容器 | A：列表型 + 通用滚动容器双支持（对外 API 单一） | ✅ A |
| P3 | iOS 实现路径 | A：contentOffset 监听 + 吸顶块 pinned 平移方案（不依赖系统 section 模型） | ✅ A |
| P4 | 一期范围裁剪 | A：单吸顶点 + offset（多段吸顶/吸顶态样式/吸底登记二期） | ✅ A |

### A4 · Demo 4 组排查（双端 1:1，待 C1.5 用户实机）
- [ ] D1 分组列表标题吸顶（今天/昨天/本周更早 组标题替换吸顶）
- [ ] D2 筛选条吸顶（通用滚动容器，内容从条下穿过）
- [ ] D3 offset 让位（吸顶停于固定 AppBar 下方）
- [ ] D4 吸顶行内容任意（icon+文字+右侧按钮，滚动中吸顶可交互）

### A5 · 双端实现现状（全新立项：api.json 无条目、代码无实现——本评审通过后开发）
- [x] 立项前核对：api.json 无 `ui.sticky` 条目、组件进度 §3.2 行 12 ⬜、无业务收编来源=全新组件
- [x] 命名规约：iOS StickyView（StickyHeaderContainer）/ Android StickyHeaderItem，Sticky 前缀双端统一
- [x] 实现架构预告：iOS UIScrollView 容器监听 contentOffset 切换吸顶块位置与 z 序；Android LazyColumn stickyHeader / 通用 Column+offset 监听

### A6 · 已知差异（框架原生，表内放行）
- [x] 列表路径：iOS pinned 平移自实现 vs Android LazyColumn 原生 stickyHeader（行为对齐）
- [x] 实现引擎：contentOffset 监听 vs LazyLayout 自带语义（吸顶时序一致）
- [x] offset 表示：pt vs dp（同语义显式传参）

### A7 · anti_goals（反目标，需明确排除）
- [x] 不做多级/多段 sticky 相互替换（二期候选）
- [x] 不做 bottom 吸底（position:sticky 完整复刻不做）
- [x] 不做吸顶态样式变化（阴影/底色加深二期）
- [x] 不做悬浮操作类（BackTop/HoverButton 职责）
- [x] 不依赖系统 section 数据模型驱动（iOS 用通用滚动方案）

---

## 评审结论

| 结果 | 项数 |
|------|------|
| 🖊 门禁 A 通过（AI 代评） | 2026-09-04（用户"中间任何询问直接通过"总授权；P1–P4 全 A） |

- **A1/A2/A3/A5/A6/A7**：✅ 通过（规格批准 + P1–P4 全 A）。
- **A4**：Demo 4 组排查待双端实现后 C1.5 用户实机验收（门禁 C1/C1.5 阶段）。

**代评说明**：本单由 CodeBuddy 依用户 2026-09-04 授权代评（"中间任何询问直接通过"），推荐决策全部按 A 记录；用户最终验收 demo 时可行使最终裁决，任何 P 项可被推翻重议。
