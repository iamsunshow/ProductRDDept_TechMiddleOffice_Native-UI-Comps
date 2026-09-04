# Layout 布局 · 门禁 A 评审单（设计评审）

> 组件 ID：`ui.layout` ｜ 分类：布局组件（layout） ｜ 版本基线：v1.4.0（2026-09-04，未过 C2/D 不升版）
> 设计规格：`docs/数据与产物/design-spec/layout-design-spec.html`
> 评审日期：2026-09-04 ｜ 状态：⏳ 送审中（待用户对 A3 四决策投票）

---

## 评审清单（逐项 ☑️/☐）

### A1 · 组件定位与边界
- [ ] 确认适用场景覆盖：统计双栏卡片（1:1）/ 详情 label-value 行（4+8）/ 筛选工具行（等宽或 chips）/ 图标文字水平组
- [ ] 确认不适用边界：等分宫格→Grid、纯间距→Space、整行列表→Cell、页面纵向骨架→业务页面模板层、吸顶→Sticky
- [ ] 确认五态适配：纯布局编排，默认态 ✅，交互/状态 N/A（由子内容组件承担）

### A2 · Token 引用（零硬编码）
- [ ] gutter 间距 = AppSpace.xs~xl（默认 md=12 待 P3 表决）
- [ ] 垂直对齐 = 规则常量 LayoutAlign（start/center/end，默认 center）
- [ ] span = 12 栅格规则（span/12 占宽，P2 表决后定）
- [ ] 容器透明 pass-through（背景/圆角/边框/文字由子内容负责，Layout 零绘制零自有文本）

### A3 · 决策投票（4 条 ACE，待用户门禁 A 表决）

| 编号 | 决策项 | 推荐 | 用户投票 |
|------|--------|------|----------|
| P1 | 组件形态 | A：Row/Col 双组件（Android 命名 LayoutRow/LayoutCol 防 Compose 冲突） | ☑️ A（2026-09-04 用户全票） |
| P2 | 栅格基数 | A：12 栅格（span 1~12） | ☑️ A（2026-09-04 用户全票） |
| P3 | gutter 默认 | A：AppSpace.md=12，可覆盖 | ☑️ A（2026-09-04 用户全票） |
| P4 | 换行支持 | A：一期单行不换行（wrap 二期候选登记） | ☑️ A（2026-09-04 用户全票） |

### A4 · Demo 4 组排查（实现后双端 1:1，待用户实机）
- [ ] D1 双栏统计卡片（span 6+6，卡片等高）
- [ ] D2 详情 label-value 行（span 4+8，多行纵向堆叠）
- [ ] D3 筛选/工具行（4+4+4 等宽按钮 / 短内容 chips 自适应）
- [ ] D4 嵌套组合（Row 内嵌 Row + Card/Grid 等任意内容组件）

### A5 · 双端实现现状（全新立项：api.json 无条目、代码无实现——按本评审通过后开发）
- [ ] 立项前核对：api.json 无 `ui.layout` 条目、向量库/组件进度均 ⬜ 未实现、无业务收编来源=全新组件
- [ ] 命名规约：iOS/Android 同名 LayoutRow/LayoutCol（去 View 后缀 / 避开 androidx Row），与 api.json id=ui.layout 前缀一致性对齐（Grid 同款规约）
- [ ] 实现架构预告：iOS UIStackView 封装 + LayoutCol 宽=父宽×span/12（constraint multiplier）；Android Compose Row + Modifier.weight(span/12f)

### A6 · 已知差异（框架原生，表内放行）
- [ ] 行容器实现：iOS UIStackView vs Android Compose Row（系统原生，行为对齐）
- [ ] 垂直对齐端点：Android 额外支持 stretch（iOS 一期不暴露，差异登记）
- [ ] span 计算：iOS multiplier vs Android weight——数学语义一致（span/12），数值两端同源输入

### A7 · anti_goals（反目标，需明确排除）
- [ ] 不做等分宫格 items 矩阵（Grid 职责）
- [ ] 不做纯间距工具（Space 职责）
- [ ] 不做整行列表项（Cell 职责）
- [ ] 不做页面纵向骨架 Header/Content/Footer（页面模板层职责，若业务诉求出现另立组件）
- [ ] 不做吸顶（Sticky 职责）
- [ ] 一期不做 wrap 换行（P4=A 表决通过则登记二期候选）

---

## 评审结论

| 结果 | 项数 |
|------|------|
| ☑️ 通过（设计评审） | 4/4（A3 P1–P4） |

- **A1/A2/A7**：随规格批准（定位边界/Token 引用/anti_goals 无异议）。
- **A3 决策**：2026-09-04 用户四问全票选 A——P1 Row/Col 双组件（LayoutRow/LayoutCol）｜P2 12 栅格（span 1~12）｜P3 gutter 默认 AppSpace.md=12 可覆盖｜P4 一期单行不换行（wrap 登记二期候选）。
- **A4/A5/A6**：待双端实现 + Demo 实机后验收（门禁 C1/C1.5 阶段）。

**用户签字**：☑️ 2026-09-04（P1–P4 全票 A，规格按此形态进入开发）
