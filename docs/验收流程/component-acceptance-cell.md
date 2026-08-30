# 组件验收文档 · Cell 单元格

> 依据：`docs/验收流程/验收标准.md` 9.5 节。流程：设计细节+设计测试用例（阶段1，门禁A）→ API细节+API测试用例（阶段2，门禁B）→ 实现并执行测试（阶段3，门禁C1/C2）→ 发版 + 业务落地（门禁D）。
> 用例即代码：用例 ID（D1-D8 / A1-A7）与测试函数一一对应，命名如 `test_D1_defaultState`，CI 在门禁 C1 自动核对。

---

## 一、验收信息

| 项 | 值 |
|----|-----|
| 组件名 / id | Cell 单元格 / `ui.cell`（历史：`ui.list-item` → `ui.list-row`） |
| 分类（subcategory） | 基础组件（api.json subcategory=display，门禁 B 复核） |
| 推进顺序 | 列表第 #2 位（基础组件） |
| 状态 | 📐 设计中（A）→ 📋 API（B）→ 💻 实现（C）→ ✅ |
| 验收文档 | `docs/验收流程/component-acceptance-cell.md` |
| 设计规格页 | `docs/design-spec/cell-design-spec.html`（浏览器打开） |

---

## 二、① 设计细节（阶段 1 · 门禁 A 评审）

> 详细内容在 H5 设计规格页（真实渲染 + 尺寸标注），此处为索引与评审结论。

| 项 | 内容 |
|----|------|
| 组件用途 | 列表页最小行单元：左侧可选图标 + 中间标题（可副标题）+ 右侧值/箭头；适用设置页每行、个人中心信息行、明细页静态信息行；组合 Icon/Avatar/Badge（左）、Switch/Tag（右）。对标 NutUI Cell / Ant Design List.Item；**不是流水行**（用 ListItem） |
| 五态定义 | 默认（白底 16/400 标题）／禁用（gray.4 置灰、不可点、不透箭头）／加载（骨架 shimmer 占位）／成功（✓ + color.success）／失败（! + color.error） |
| 尺寸规格 | min-height 48px；水平内边距 `space.lg`=16；图标间距 `space.md`=12；标题 `sizeMd`16/400；右侧值 `sizeSm`14/`textSecondary`；分割线 1px `color.border`；分组圆角 `radius.md`=10；箭头 16×16 `gray.25` |
| 交互细节 | 点击整体可点、按下态背景 `gray.4` 松手恢复；`onClick`（参数=索引/数据）、`onLongPress` 可选（iOS 长按，Android 不承诺）；无弹窗层级（右侧 Popup 由业务承载） |
| 双端差异 | 触摸反馈 iOS UILongPress/Highlight vs Android Ripple = 平台原生差异，**已登记 `docs/平台差异.md`**；分割线/禁用态双端一致 |
| 与现有组件关系 | deps=[]（独立）；被 `ui.list`（列表容器）依赖；替代 iOS ListCell 近似实现（迁移后废弃）、补 Android 缺口 |
| 设计参考图 | `docs/design-spec/cell-design-spec.html`（02 节真实渲染，非截图） |

**设计评审（门禁 A）结论：** ☐ ✅ 通过　☐ ❌ 打回　备注：

---

## 三、② 设计测试用例（阶段 1 定义 · 阶段 3 执行）

> 覆盖五态渲染、尺寸/token 取值、交互反馈。门禁 C 执行，结果随 PR 提交。

| # | 用例 | 前置 | 步骤 | 预期 | 双端 | 结果 |
|---|------|------|------|------|------|------|
| D1 | 默认态渲染 | — | 渲染默认 Cell（标题+右侧值+图标+箭头） | 标题 16/400、右侧值 14/textSecondary、min-height 48px、水平 padding 16px、箭头 16×16 gray.25，尺寸与 token 一致 | iOS+Android | ☐ |
| D2 | 禁用态 | — | 渲染 disabled Cell | 置灰（gray.4）、不可点击、不透出箭头 | iOS+Android | ☐ |
| D3 | 加载态 | — | 渲染 loading Cell | 骨架占位（shimmer 动画）替换标题区 | iOS+Android | ☐ |
| D4 | 成功态 | — | 渲染 success Cell（如"已开启 ✓"） | ✓ 标识 + color.success 渲染 | iOS+Android | ☐ |
| D5 | 失败态 | — | 渲染 error Cell（如"同步失败 !"） | ! 标识 + color.error 渲染 | iOS+Android | ☐ |
| D6 | Token 引用 | 代码静态检查 | 扫描实现文件 | 颜色/尺寸全部引用 design-token.json，零硬编码 | 两端 CI | ☐ |
| D7 | 按下态 | — | 按压 Cell | 背景变 gray.4，松手恢复 | iOS+Android | ☐ |
| D8 | 分割线 | — | 相邻两行 | 1px color.border 分隔，无重叠 | iOS+Android | ☐ |

---

## 四、③ API 设计细节（阶段 2 · 门禁 B 评审）

> 完整契约在 `docs/api.json` + `docs/开发规则.md` 第八节，此处为评审索引。

| 能力面 | 字段 | 关键内容 |
|--------|------|----------|
| 属性 Props | `props` | 属性名 / 类型 / 默认值（双端 100% 对齐） |
| 事件 Events | `events` | 回调名 / 签名 |
| 方法 Methods | `methods` | 命令式接口（如有） |
| 能力标签 | `capabilities` | 检索标签 |
| 场景 | `scenarios` | 典型场景语料 |
| Token 依赖 | `visual_tokens` | token 名列表 |
| 组件关系 | `deps` | 依赖组件 id |
| 平台状态 | `platforms` | available / partial / unavailable |

**API 评审（门禁 B）结论：** ☐ ✅ 通过　☐ ❌ 打回　备注：

---

## 五、④ API 测试用例（阶段 2 定义 · 阶段 3 执行）

> 覆盖属性取值、事件回调、能力覆盖。门禁 C 执行，结果随 PR 提交。

| # | 用例 | 前置 | 步骤 | 预期 | 双端 | 结果 |
|---|------|------|------|------|------|------|
| A1 | 属性-默认值 | — | 不传 props 渲染 | 默认值生效（如 title 为空占位） | iOS+Android | ☐ |
| A2 | 属性-自定义 | — | 传入各 props | 渲染符合传入值，双端一致 | iOS+Android | ☐ |
| A3 | 事件-onClick | — | 点击 Cell | onClick 回调触发，参数正确（索引/数据） | iOS+Android | ☐ |
| A4 | 事件-禁用拦截 | — | 点击 disabled Cell | 回调不触发 | iOS+Android | ☐ |
| A5 | 能力-五态覆盖 | — | 切换各状态 | 与设计测试 D1-D5 对应，状态切换正确 | iOS+Android | ☐ |
| A6 | 契约-schema | api.json | 校验脚本 | props/events/methods 字段合法 | CI | ☐ |
| A7 | 契约-命名对齐 | api.json | 双端对照 | 双端 props/events 命名 100% 一致 | CI | ☐ |

---

## 六、验收记录

| 日期 | 门禁 | 结论 | 备注 |
|------|------|------|------|
| 2026-08-30 | A 设计评审 | 待评审 | 设计规格页 + 评审意见单 `docs/验收流程/review-cell-A.md` 已产出 |
|  | B API 评审 | 通过 / 打回 |  |
|  | C1 自测对齐（单测+快照+用例映射） | 通过 / 打回 |  |
|  | C2 CR + CI | 通过 / 打回 |  |
|  | 发版 | 版本号 / tag |  |
|  | D 业务落地 | 接入成功 / 回退 | 接入位置 / 代码量变化，见 `docs/usage-cell.md` |
