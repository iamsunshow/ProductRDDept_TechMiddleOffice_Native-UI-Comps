# Space 间距 · 门禁 A 评审单（设计评审）

> 组件 ID：`ui.space` ｜ 分类：布局组件（layout）｜ 版本基线：v1.4.0（2026-09-04，未过 C2/D 不升版）
> 设计规格：`docs/数据与产物/design-spec/space-design-spec.html`
> 评审日期：2026-09-04 ｜ 状态：⏳ 送审中（待用户对 A3 四决策投票）

---

## 评审清单（逐项 ☑️/☐）

### A1 · 组件定位与边界
- [ ] 确认适用场景覆盖：icon+文字工具组 / chip 标签组 / 区块卡片显式间隔 / 详情与表单纵向条目堆叠 / 图标文字单元组
- [ ] 确认不适用边界：比例分栏→Layout、等分宫格→Grid、单点间距→AppSpace token 直用、分隔线→Divider、整行列表→Cell
- [ ] 确认五态适配：纯间距编排，默认态 ✅，交互/状态 N/A（由子内容组件承担）

### A2 · Token 引用（零硬编码）
- [ ] size 间距 = AppSpace.xs~xl（4/8/12/16/24，默认 sm=8 待 P3 表决）
- [ ] direction = 规则常量（horizontal/vertical，默认 horizontal）
- [ ] 子项对齐 = 一期固定（横向顶部 / 纵向起始侧）
- [ ] 容器透明 pass-through（背景/圆角/边框/文字由子内容负责，Space 零绘制零自有文本）

### A3 · 决策投票（4 条 ACE，待用户门禁 A 表决）

| 编号 | 决策项 | 推荐 | 用户投票 |
|------|--------|------|----------|
| P1 | 方向支持 | A：单组件 + direction 双向（horizontal/vertical） | ⏳ |
| P2 | size 档位模型 | A：AppSpace 五档枚举（xs/sm/md/lg/xl） | ⏳ |
| P3 | size 默认值 | A：AppSpace.sm=8（Ant 对齐，紧凑组默认即用） | ⏳ |
| P4 | 一期范围裁剪 | A：仅 direction+size（wrap/split 登记二期候选） | ⏳ |

### A4 · Demo 4 组排查（实现后双端 1:1，待用户实机）
- [ ] D1 水平 icon+文字 工具组（size=sm，记一笔/扫一扫/账单/设置）
- [ ] D2 chip 标签组（sm）+ 区块双卡间隔（xl=24）
- [ ] D3 垂直条目堆叠（vertical size=md，详情行 ×4）
- [ ] D4 方向对照与嵌套（同内容 horizontal vs vertical + Card 内 h/v 混合）

### A5 · 双端实现现状（全新立项：api.json 无条目、代码无实现——按本评审通过后开发）
- [ ] 立项前核对：api.json 无 `ui.space` 条目、向量库/组件进度均 ⬜ 未实现、无业务收编来源=全新组件
- [ ] 命名规约：双端同名 `Space`（iOS 去 View 后缀无冲突；Compose 无同名内置、避开 Spacer）
- [ ] 实现架构预告：iOS UIStackView 封装（axis=direction、spacing=size 档位）；Android Compose Row/Column（direction 分支）+ Arrangement.spacedBy(size)

### A6 · 已知差异（框架原生，表内放行）
- [ ] 容器实现：iOS UIStackView vs Android Compose Row|Column（系统原生，行为对齐）
- [ ] 子项对齐端点：iOS StackView 默认 alignment vs Compose Top/Start（一期固定，center/拉伸二期）
- [ ] size 计算：pt vs dp（同取 design-token.json 单源数值，两端一致）

### A7 · anti_goals（反目标，需明确排除）
- [ ] 不做比例分栏/栅格（Layout 职责）
- [ ] 不做等分宫格 items 矩阵（Grid 职责）
- [ ] 不做单点间距（margin/padding 用 AppSpace token 直排）
- [ ] 不做 split 分隔符（一期；Divider 文本模式可近似，二期候选登记）
- [ ] 不做 wrap 折行（一期；chips 流式独立场景二期论证）
- [ ] 不拉伸子项对齐（center/两端铺满二期候选）

---

## 评审结论

| 结果 | 项数 |
|------|------|
| ⏳ 送审中 | 待用户对 A3 P1–P4 表决 |

- **A1/A2/A7**：随规格批准（定位边界/Token 引用/anti_goals 无异议）。
- **A3 决策**：待用户四问表决（P1 方向支持 / P2 size 档位模型 / P3 size 默认 / P4 一期范围裁剪）。
- **A4/A5/A6**：待门禁 A 通过后双端实现 + Demo 实机验收（门禁 C1/C1.5 阶段）。

**用户签字**：⏳ 待 2026-09-04 门禁 A 表决
