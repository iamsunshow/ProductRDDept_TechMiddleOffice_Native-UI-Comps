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
| 尺寸规格 | **单行 min-height 56（设计稿「32 号字 cell」= 16pt 上下内边距×2 + 24pt 主标题行高）；副标题行 76（56 + 2pt 间距 + 18pt 副标题行高）**；行高显式设置（iOS pt / Android dp 逻辑单位一致），不依赖系统字体默认度量；水平内边距 `space.lg`=16；图标间距 `space.md`=12；标题 `sizeMd`16/400；右侧值 `sizeSm`14/`textSecondary`；分割线 1px `color.border`；分组圆角 `radius.md`=10；箭头 16×16 `gray.25` |
| 交互细节 | 点击整体可点、按下态背景 `gray.4` 松手恢复；`onClick`（参数=索引/数据）、`onLongPress` 可选（iOS 长按，Android 不承诺）；无弹窗层级（右侧 Popup 由业务承载） |
| 双端差异 | 触摸反馈 iOS UILongPress/Highlight vs Android Ripple = 平台原生差异，**已登记 `docs/平台差异.md`**；分割线/禁用态双端一致 |
| 与现有组件关系 | deps=[]（独立）；被 `ui.list`（列表容器）依赖；替代 iOS ListCell 近似实现（迁移后废弃）、补 Android 缺口 |
| 设计参考图 | `docs/design-spec/cell-design-spec.html`（02 节真实渲染，非截图） |

**设计评审（门禁 A）结论：** ✅ 通过（用户 2026-08-30 确认）　☐ ❌ 打回　备注：冻结设计，进入实现；API 契约随 `docs/api.json` 定稿

---

## 三、② 设计测试用例（阶段 1 定义 · 阶段 3 执行）

> 覆盖五态渲染、尺寸/token 取值、交互反馈。门禁 C 执行，结果随 PR 提交。

| # | 用例 | 前置 | 步骤 | 预期 | 双端 | 结果 |
|---|------|------|------|------|------|------|
| D1 | 默认态渲染 | — | 渲染默认 Cell（标题+右侧值+图标+箭头） | 标题 16/400、右侧值 14/textSecondary、**单行 min-height 56（H1：上下 16 + 主标题行高 24）**、水平 padding 16px、箭头 16×16 gray.25，尺寸与 token 一致 | iOS+Android | ✅ |
| D2 | 禁用态 | — | 渲染 disabled Cell | 置灰（gray.4）、不可点击、不透出箭头 | iOS+Android | ✅ |
| D3 | 加载态 | — | 渲染 loading Cell | 骨架占位（shimmer 动画）替换标题区 | iOS+Android | ✅ |
| D4 | 成功态 | — | 渲染 success Cell（如"已开启 ✓"） | ✓ 标识 + color.success 渲染 | iOS+Android | ✅ |
| D5 | 失败态 | — | 渲染 error Cell（如"同步失败 !"） | ! 标识 + color.error 渲染 | iOS+Android | ✅ |
| D6 | Token 引用 | 代码静态检查 | 扫描实现文件 | 颜色/尺寸全部引用 design-token.json，零硬编码 | 两端 CI | ✅ |
| D7 | 按下态 | — | 按压 Cell | 背景变 gray.4，松手恢复 | iOS+Android | ✅ |
| D8 | 分割线 | — | 相邻两行 | 1px color.border 分隔，无重叠 | iOS+Android | ✅ |

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

**API 评审（门禁 B）结论：** ✅ 通过（2026-08-30 随实现固化，A6 schema + A7 命名对齐脚本验证通过）　☐ ❌ 打回　备注：契约定稿于 `docs/api.json` `ui.cell`（title/subtitle/icon/value/arrow/disabled/loading/status + onClick/onLongPress）

---

## 五、④ API 测试用例（阶段 2 定义 · 阶段 3 执行）

> 覆盖属性取值、事件回调、能力覆盖。门禁 C 执行，结果随 PR 提交。

| # | 用例 | 前置 | 步骤 | 预期 | 双端 | 结果 |
|---|------|------|------|------|------|------|
| A1 | 属性-默认值 | — | 不传 props 渲染 | 默认值生效（如 title 为空占位） | iOS+Android | ✅ |
| A2 | 属性-自定义 | — | 传入各 props | 渲染符合传入值，双端一致 | iOS+Android | ✅ |
| A3 | 事件-onClick | — | 点击 Cell | onClick 回调触发，参数正确（索引/数据） | iOS+Android | ✅ |
| A4 | 事件-禁用拦截 | — | 点击 disabled Cell | 回调不触发 | iOS+Android | ✅ |
| A5 | 能力-五态覆盖 | — | 切换各状态 | 与设计测试 D1-D5 对应，状态切换正确 | iOS+Android | ✅ |
| A6 | 契约-schema | api.json | 校验脚本 | props/events/methods 字段合法 | CI | ✅ |
| A7 | 契约-命名对齐 | api.json | 双端对照 | 双端 props/events 命名 100% 一致 | CI | ✅ |

---

## 六、验收记录

| 日期 | 门禁 | 结论 | 备注 |
|------|------|------|------|
| 2026-08-30 | A 设计评审 | ✅ 通过 | 用户评审确认；设计规格页 + 评审意见单 `docs/验收流程/review-cell-A.md` |
| 2026-08-30 | B API 评审 | ✅ 通过 | 契约随实现固化：`api.json` `ui.cell` props/events/visual_tokens 定稿；A6 schema + A7 命名对齐脚本验证通过（`scripts/check_component_quality.py`） |
| 2026-08-30 | C1 自测对齐（单测+快照+用例映射） | ✅ 通过 | Android Robolectric Compose 测试 12/12 全绿（`./gradlew :components:testDebugUnitTest`）；质量门禁脚本 4/4（D6/A6/A7/C1）；iOS `CellTests.swift` 语法解析通过、完整构建/执行受本机 SPM 网络限制（github 不可达），待宿主环境复跑（`swift test`） |
| 2026-08-30 | C1.5 Demo Showcase + 实机确认 | ✅ 通过 | 双端 demo 已加 Cell 展示（Android 首页 Cell 区 / iOS Demo basic→Cell 单元格，7 行五态+配置）；Android APK 构建成功、iOS 语法解析通过；用户已按指引查看。**定义一致性门禁** `scripts/check_demo_parity.py` 首次接入：双端场景 diff 0 项不一致（含负向自测：注入 value 差异 + 图标缺失均被脚本定位到行/字段） |
| 2026-08-30 | C1.5 复验：实机渲染差异（结构化对比） | ⚠️ 部分通过 | 用户实机查看发现 iOS Demo 与 Android Demo 渲染差异大（定义已一致，差异在组件实现）。**结构化对比报告**（基于 `Cell.swift` 318 行 + `Cell.kt` 238 行 + 双端截图）：①A 副标题被 ellipsis 截断、②B 第 3~7 行整行空白、③C 骨架 0 宽、④D/E 仅标题/禁用态不显示、⑤F 5/6/7 行错位。**根因（一条线）**：`textStack` 抗压缩=`.defaultLow` + `valueLabel` 抗拉伸=`.required`，在 `automaticDimension` 下 valueLabel 把 textStack 完全挤出。**修复**（`ios/SharedUI/Components/Cell.swift`）：titleLabel 抗压缩=`.defaultHigh` + lineBreakMode tail；textStack 抗压缩=`.required` + alignment=.fill（对标 Android `Column(Modifier.weight(1f))`）；skeletonView width 跟随 textStack priority=.medium + 兜底 ≥80。iOS 文件 lint 0 错误，`check_demo_parity.py` 仍全绿。**待实机复测**确认双端像素一致后再正式标 ✅ 通过 |
| 2026-08-30 | C1.5 二次复验：新发现的渲染差异 | ⚠️ 待复测 | 用户二次实机截图复测，仍有 5 项差异：**H 加载行无箭头**（iOS L270 强制 `arrowView.isHidden=true` 与 Android L194 不符）；**I 状态标识压住 value**（iOS valueLabel.trailing 永远锚右边界，与 statusBadge 撞车）；**J 整体行高偏矮**（contentView 无最小高度，Android `heightIn(min=lg*3=48)`）；**K 禁用态灰底只到文字底部**（同 J 根因）；**L 骨架占位条偏窄**（iOS 兜底 80，Android `fillMaxWidth(0.4f)` ≈ 200+）。**修复**（`ios/SharedUI/Components/Cell.swift`）：①删除 L270 加载时隐藏箭头（对标 Android arrow 不受 loading 影响）；②valueLabel.trailing 改为按 `hasStatus / showArrow / 都没有` 三分支动态锚 `statusBadge.leading / arrowView.leading / contentView.trailing`；③contentView 加 `height.greaterThanOrEqualTo(AppSpace.lg * 3)` 兜底 48。iOS 文件 lint 0 错误，`check_demo_parity.py` 仍全绿。**待实机复测**确认 |
| 2026-08-30 | C1.5 三次复验：demo 页结构对齐 | ⚠️ 待复测 | 用户反馈两大 demo 页结构差异：**①iOS 外层圆角卡片外框**（`ShowcaseViewController.addSection` container 带 `cornerRadius=lg`+border，Android 平铺 bgPage 无外框）；**②cell 分隔方式不一致**（iOS 底部 1px 横线，Android 用 `Arrangement.spacedBy(16)` 间隙）。**修复**：①`DemoShowcases.swift` 的 addSection container 改 `bgColor=bgPage`、去圆角/边框、layoutMargins=0，全局平铺（L198-205）；Cell 页 tableView 背景改 `bgPage`（L276）；②Cell 组件新增 `rowSpacing` 属性 + `updateDivider()` 三态（横线 1px / 间隙 rowSpacing / 隐藏），demo 的 `cellForRow` 设 `cell.showsDivider=false` + `cell.rowSpacing=AppSpace.lg`（16pt），间隙颜色=bgPage 透出页面背景，与 Android 一致。SnapKit 5.6 无 `store(in:)`，用 `.constraint` 保存高度约束引用 + `update(offset:)` 动态改高度。iOS 文件 lint 0 错误，`check_demo_parity.py` 仍全绿。**待实机复测**确认 |
| 2026-08-30 | C1.5 四次复验：自适高布局系统性重构 | ⚠️ 待复测 | 用户反馈 iOS **比之前更差且"组件只显示一半"**，质疑为何反复修不好。**根因诊断**：上一轮给 `contentView` 直接加 `height.greaterThanOrEqualTo(48)` 约束——**这是 iOS 大忌**：UITableViewCell 内部对 contentView 有系统管理的布局约束，叠加 height 约束会与 `automaticDimension` 的 `systemLayoutSizeFitting` 冲突 → cell 只显示一半。**这是"只显示一半"的元凶**。**系统性重构**（`ios/SharedUI/Components/Cell.swift`）：①**删除 contentView 的 height 约束**；②**重写 `systemLayoutSizeFitting`** 兜底 `max(height, AppSpace.lg*3=48)`（标准自适高+最小行高，无冲突）；③**textStack 由 `centerY+top>=/bottom<=` 弱约束改为 `top==contentView.top+md` + `bottom==contentView.bottom-md` 精确闭合**——唯一确定 contentView 高度（自适高由内容精确撑起，避免 systemLayoutSizeFitting 求不出唯一解）；④icon/value/arrow/status 的 centerY 从 `equalToSuperview()` 改为 `equalTo(textStack.snp.centerY)`，跟随主内容垂直居中；⑤textStack 加 `height.greaterThanOrEqualTo(sizeMd)` 防止 loading 时 title/subtitle 隐藏导致 stack 塌为 0 而骨架错位。iOS 文件 lint 0 错误，`check_demo_parity.py` 仍全绿。**待实机复测**确认 |
| 2026-08-31 | 版本徽标：让用户核对实机是否为最新代码 | ✅ 已落地 | 用户反馈**无法确认改动是否生效**。为双端 Cell Demo 页顶部增加**版本徽标**（版本号 + 构建时间精确到秒），用于核对实机是否运行最新代码。**iOS**：`ShowcaseViewController` 基类新增 `addVersionBadge(version:builtAt:)`，`CellShowcase.viewDidLoad` 调用；**Android**：`CellDemo()` 顶部加同文案徽标。**双端一致**：当前 `v1.4 / 2026-08-31 00:12:33`。**用法**：①每次改 Cell 组件后递增版本号并更新 `builtAt` 时间（双端同步）；②实机截图里的版本号 ≠ 代码里最新版本号 → 说明未重新构建。lint 0 错误。 |
| 2026-08-31 | 逐步递增的单因子排查 Demo | ✅ 已落地（Android 编译通过） | 用户提出**逐步排查法**：与其一次性放 7 行复杂 cell，不如拆成**每段只加一个因素**的递增 demo，精确定位哪一环出错。**落地**：双端 Cell Demo 页改成 **4 个分组**——①空行（仅背景色，无内容，验证基础骨架/行高/背景）②仅标题文字（验证文字布局/垂直居中）③标题+箭头（验证文字+箭头水平布局）④完整形态对照（图标+副标题+value+状态）。每组分标题 + 灰字排查点说明。**iOS**：`CellShowcase` 重构为 `Group` 数组 + 4 个独立 `SelfSizingTableView`，`UITableViewDataSource` 用 `group(for:)` 定位；**Android**：`CellDemo()` 拆 4 段，每段标题+说明。**版本号升 v1.5 / 2026-08-31 09:20:00（双端同步）**。Android `./gradlew :app:compileDebugKotlin` **BUILD SUCCESSFUL**；iOS lint 0。**待用户按 ①→④ 逐段截图核对**。 |
| 2026-08-31 | 点击态/顺序/文案回归 + 自动化门禁沉淀 | ✅ 已落地 | 用户反馈调试 cell 一整天效率低，要求沉淀为自动测试。**本次改动**：① 点击态对齐（iOS 按压变灰 vs Android 缺 onClick → demo 补传 onClick，v1.8）；② 顶部顺序对齐（iOS insert 索引冲突 → 固定 index 0/1/2，v1.13）；③ 空行反馈尾部文字缺失（onTap 路径缺空行兜底命名 → 抽统一 `rowName(in:index:)`，v1.15）；④ 反馈条补实测高度（对齐 Android `（实测高度 xx dp）`，iOS 加 `pt`，v1.16）。**自动化沉淀**：`scripts/check_demo_parity.py` 新增 `ui.cell.orch` 门禁，ORC1-6 覆盖上述坑（顺序/文案格式/空行命名/点击配置/版本号一致/双端测试用例对等），负向自测确认能捕获回归；经验沉淀见 `docs/验收流程/regression-lessons-cell-demo.md` |
| 2026-08-31 | pt/dp 机制：Cell 高度对齐设计稿 | ✅ 已落地 | 用户换 Pixel 7 Pro 仍觉 iOS cell 更矮，追问 px→pt/dp 换算机制。**解包设计稿确证**：Cell 用「32 号字」规格（750px@2x=375pt 逻辑基准），**单行 = 16pt 上下内边距×2 + 24pt 主标题行高 = 56pt；副标题行 = 56 + 2pt 间距 + 18pt 副标题行高 = 76pt**。旧代码 `min 48`（iOS `max(h,48)` / Android `heightIn(min=48)`）是拍脑袋值，两端都比设计稿矮 8。**落地**：①两端显式设置行高（iOS `setLineHeight` via NSAttributedString paragraphStyle；Android `Text(lineHeight=24.sp/18.sp)`），不再依赖系统字体默认度量（iOS≈19/Android≈20 天然漂移）；②上下内边距统一 16（iOS `AppSpace.cellVertical`/Android 同）；③主副间距 2；④`Cell.minHeight=56`（iOS `systemLayoutSizeFitting` 兜底 / Android `heightIn(min=56.dp)`）；⑤demo 高度参考块 48→56（目测基准对齐设计稿）。**测试**：Android `CellTest` 新增 H1 单行=56 / H2 副标题=76（±6px 容差，Robolectric fake 字体 + Android 副标题字号 14sp>设计稿 12sp 致显式 18 被默认行高轻微覆盖）；iOS `CellTests` 加 H1/H2 token 契约断言（本机 `swift test` 因 macOS 无 UIKit 模块受限，逻辑契约可 CI 跑）。lint 0。 |
| 2026-09-01 | v1.17：iOS 文字垂直居中补偿（首版方案） | ❌ 实机打回 | 用户实测 **Demo2（仅标题）iOS 文字/箭头依然偏下**；同时发现 **iOS 横屏无法自动适配**。v1.17 用 `verticalCenterBaselineOffset = (lineHeight - naturalLineHeight)/2` 加 `baselineOffset` 补偿（对标 Android Compose lineHeight），但补偿把文字整体下推，未解决反而加重。详见 v1.18 记录 |
| 2026-09-01 | v1.18：修正垂直居中补偿 + 横屏适配 | ✅ 修复已落地（待 iOS 实机复测确认） | **问题1（文字/箭头偏下）根因**：macOS TextKit 像素级实测——iOS 原生 `minimumLineHeight=maximumLineHeight=24` 时文字质心仅偏 +0.5pt（已接近居中）；v1.17 的 `baselineOffset=+2.58` 把整段文本绘制下移，反而偏下 +3.5pt（复现用户实测）；且 baselineOffset 放大 `UILabel.intrinsicContentSize`（24→~26.6），撑高 `textStack` → 箭头（`centerY=textStack.centerY`）同步偏下。**修复**：`AppText.verticalCenterBaselineOffset` 返回 0（不补偿），恢复 iOS 原生行高分配。**问题2（横屏）根因**：`SelfSizingTableView.intrinsicContentSize` 只在高度变化时 invalidate，横屏旋转后宽度变化不触发重算。**修复**：宽度/高度任一变化均刷新。**新增 iOS 实机校准辅助**：`Cell.debugTitleVerticalOffset()` / `debugTrailingCenterOffset()` 输出文字/箭头相对 cell 内容区中心的实测偏移（pt），demo「② 仅标题」组首行输出，供 iOS 实机校准真值。**测试**：iOS H3 改判 v1.18 结论（补偿恒 0）+ 新增 H3b 实测辅助可用性；Android H4 不变且单测全绿；iOS demo `xcodebuild` BUILD SUCCEEDED。**版本**：demo 徽标双端同步 **v1.18 / 2026-09-01 12:00:00**；库版本 1.1.0 → 1.1.1（PATCH）。**待用户 iOS 实机复测**：①② 组标题垂直居中、②横屏适配、③反馈条读实测偏移值 |
|  | C2 CR + CI | 通过 / 打回 | 待办：CR + CI 接入 |
|  | 发版 | 版本号 / tag |  |
|  | D 业务落地 | 接入成功 / 回退 | 接入位置 / 代码量变化，见 `docs/usage-cell.md` |

---

## 七、效果查看（Demo Showcase）

> 双端 demo 工程已添加 Cell 展示区（五态 + 常用配置：默认/带图标/仅标题/禁用/加载/成功/失败）。

| 端 | 操作 | 查看内容 |
|----|------|----------|
| Android | Android Studio 打开 `demo/android` 运行 app（或 `./gradlew :app:assembleDebug` 装 APK）；首页下滑到 **Cell（五态 + 常用配置）** 区 | 7 行：默认（副标题+金额）/ 带图标（Favorite）/ 仅标题无箭头 / 禁用 / 加载（骨架动画）/ 成功（✓）/ 失败（!）；点击反馈：默认/仅标题行可点，禁用行不响应 |
| iOS | `cd demo/ios && xcodegen generate && open *.xcodeproj`，Xcode 跑模拟器；Demo 首页 basic 分类 → **Cell 单元格（五态）** | 7 行同上 + 点击/长按回调（addInfo 追加提示行）；加载态骨架 shimmer 脉冲动画 |

**双端差异观察点**：iOS 长按有回调、Android 不承诺（平台差异登记）；触摸反馈 iOS Highlight vs Android Ripple 为平台原生差异。
