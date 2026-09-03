# Changelog

Native-UI-Comps 组件库版本日志。本文件是官方文档「版本日志」页的唯一数据源，随每次发布一并更新。

格式遵循 [Keep a Changelog](https://keepachangelog.com/zh-CN/)：

```markdown
## [版本号] - YYYY-MM-DD
### Added / Changed / Fixed / Removed / Security
- 条目
```

***

## \[1.1.11] - 2026-09-03

补录 Button v1.0 三轮发布后漏掉的 4 轮 bugfix 版本递增（治理规范 §6.5 合规补齐）。

### Changed

- **iOS ButtonShowcase 版本徽标**：`addVersionBadge(componentName: "Button", version: "v1.0", builtAt: "2026-09-02 19:00:00")` → `version: "v1.4"`，`builtAt` → `2026-09-03 09:05:00`。对应 4 轮 bugfix 徽标步长（每轮 +0.1）：

  - v1.1：iOS Demo `addFeedbackBar` `insertArrangedSubview(at: 2)` 越界 → `min(2, contentStack.arrangedSubviews.count)` 防越界。

  - v1.2：Android AppButton Box 显式补 `.background(container, shape)`（计算了 `container` 却没写 modifier，导致 Demo1 按钮透明只显文字）；secondary 样式背景由透明改 `AppColor.bgCard` 对齐 iOS。

  - v1.3：iOS AppButton `setLoading(true)` 分支补 `updateBackground()`，原只 setTitle 不置灰 → 双端 Demo3/Demo4 loading 态顺序一致（iOS 原顺序正确绿灰白灰，Android 全灰；修完双端同序）。

  - v1.4：Android Demo 子页面补 `statusBarsPadding()` + 自定义返回按钮行 + 内容区大标题组件名，修复返回按钮撞状态栏 + 缺大标题 + 标题在 title bar 不在内容区。

- **Android ButtonDemo 版本徽标**：`text = "Button 组件 v1.0"` → `"Button 组件 v1.4"`。

- **ui-version.json**：组件库版本 1.1.10 → 1.1.11（demo 代码改动同样触发版本递增，见治理规范 §6.5 / 开发规则 §1.5）。

## \[1.1.10] - 2026-09-03

Icon v1.1 iOS SF Symbol 多色渲染修复（monochrome 强制单色轮廓）+ Demo 徽标 v1.1→v1.2。

### Fixed

- **iOS AppIcon SF Symbol 强制单色渲染**：`iphone.gen3` 等多色符号默认保留内部屏幕渐变/Home Indicator 颜色细节，`tintColor` 仅作用于轮廓，导致 Demo ①/④ 手机图标 iOS 有内部颜色 vs Android 纯白色（与 Android SfApproxIcons ColorFilter.tint 语义不一致）。修复：`UIImage(systemName: name.sfSymbol, withConfiguration: .preferringMonochrome())`，8 图标全程仅受 tintColor 控制。

### Changed

- **iOS IconShowcase 版本徽标**：`version: "v1.1"` → `version: "v1.2"`，`builtAt` → `2026-09-03 08:30:00`。

- **Android IconDemo 版本徽标**：`text = "Icon 组件 v1.1"` → `"Icon 组件 v1.2"`。

- **ui-version.json**：组件库版本 1.1.9 → 1.1.10。

## \[1.1.9] - 2026-09-03

Icon Demo 双端徽标版本同步 v1.0→v1.1（组件级版本必升）。

### Changed

- **iOS IconShowcase 版本徽标**：`addVersionBadge(version: "v1.0")` → `version: "v1.1"`，`builtAt` 2026-09-02 → 2026-09-03 08:00:00。

- **Android IconDemo 版本徽标**：`text = "Icon 组件 v1.0"` → `"Icon 组件 v1.1"`。

- **ui-version.json**：组件库版本 1.1.8 → 1.1.9（demo 代码改动同样触发版本递增，见治理规范 §6.5）。

## \[1.1.8] - 2026-09-03

Icon v1.0 iOS bugfix：SF Symbol 名错误 + Demo ② 间距 + .pbxproj 编译引用。

### Fixed

- **iOS AppIconName.smartphone SF Symbol 名修复**：`"smartphone"` 非系统 SF Symbol（`UIImage(systemName:)` 返回 nil）→ 改为 `"iphone.gen3"`（iOS 16+ 存在的手机造型符号，与 demo deploymentTarget iOS 16 一致）。修复 Demo ① 基础形态第 7 列、Demo ④ 全形态网格每行第 7 列（smartphone）图标空白。

- **iOS IconShowcase Demo ② 尺寸因子间距对齐 Android**：UIStackView `spacing = AppSpace.xl`（24pt 固定）→ `distribution = .equalSpacing`；容器 leading/trailing inset `lg(16pt)` → `xl(24pt)`。Android 用 `Arrangement.SpaceEvenly`（子视图间 + 两端空白自动均分），`.equalSpacing` 是 UIStackView 对应语义近似。

- **iOS Demo .pbxproj 手动补 AppIcon.swift 4 处编译引用**：PBXBuildFile / PBXFileReference / PBXGroup(Components) / PBXSourcesBuildPhase 四处。xcodegen 未安装，新建 AppIcon.swift 后 .pbxproj 未更新，导致 Xcode 编译期 6 处 `Cannot find 'AppIconName'/'AppIcon' in scope`。

### Changed

- **ui-version.json**：组件库版本 1.1.7 → 1.1.8。

## \[1.1.7] - 2026-09-02

Icon 组件 v1.0 新增：双端 AppIcon 代码落地 + API 契约完善 + 双端 Demo。

### Added

- **Icon 组件（ui.icon）正式纳入组件库**：中台基础图标组件，封装 iOS SF Symbols / Android SfApproxIcons 矢量，统一双端图标使用方式。8 个通用图标（list/chart/plus/safari/person/arrowDown/smartphone/mail），支持自定义尺寸与着色（对标 NutUI Icon / Ant Design Icon）。

- **iOS AppIcon.swift 新增**：AppIconName 枚举 8 个图标映射 SF Symbol 系统名；AppIcon 类（UIImageView）封装 SF Symbols + 工厂方法 `make(name/size/color)` + `setColor()` 着色更新。

- **Android AppIcon.kt 新增**：AppIconName 枚举 8 个图标（与 iOS 同名）映射 SfApproxIcons ImageVector；AppIcon Composable 封装 Image + ColorFilter.tint + ContentScale.Fit；`sfSymbolName()` 供跨端文档参考。

- **api.json ui.icon 契约完善**：platforms.ios state unavailable→available；source\_refs 双端（iOS AppIcon.swift + Android AppIcon.kt）；props 3 项（name/size/color）、demos 4 项（列表图标/主色加号/红色邮箱/全图标网格）、anti\_goals 3 项（不做品牌图标/图标字体/动效图标）、visual\_tokens 4 项、deps 引用 foundation.design-tokens、industry\_names 新增 AppIcon。

- **iOS IconShowcase Demo**：4 组递增单因子排查（① 基础形态 8 图标默认尺寸 24pt → ② 尺寸因子 list × 16/24/32/48pt → ③ 着色因子 person × 4 色 → ④ 全形态网格 8 图标 × 3 色），版本徽标 Icon v1.0。

- **Android IconDemo**：与 iOS IconShowcase 一一对应的 4 组排查，版本徽标 Icon v1.0。

### Changed

- **DemoShowcases.swift**：ui.icon 条目 reviewed=false → true，create=nil → `{ IconShowcase() }`。

- **MainActivity.kt**：Icon 条目 reviewed=false → true，demo=nil → `{ IconDemo() }`；新增 AppIcon / AppIconName import。

- **ui-version.json**：组件库版本 1.1.6 → 1.1.7（双端 iOS / Android 永远同版本，禁止手工改工程内版本）。

## \[1.1.6] - 2026-09-02

Button 组件 v1.0 新增：双端代码对齐 + API 契约 + 设计令牌 + 双端 Demo。

### Added

- **Button 组件（ui.button）正式纳入组件库**：中台基础按钮，48pt 高、圆角 lg、三样式（primary/secondary/destructive），统一登录/注册/弹窗/表单等主操作按钮视觉（对标 NutUI Button / Ant Design Button）。

- **api.json 新增 ui.button 契约**：props 7 项（text/onClick/style/fontSize/height/enabled/loading）、events 1 项（onClick）、demos 5 项（主操作/次要操作/破坏性操作/加载态/禁用态）、status=stable、anti\_goals 3 项（不做图标按钮/FAB/按钮组）、source\_refs 双端源码路径、visual\_tokens 8 项；componentCount 27→28。

- **design-token.json 新增 buttonDisabled**：`#9CA3AF`（灰阶 400 区间，介于 gray15 `#BFBFBF` 与 gray25 `#8C8C8C` 之间），用于按钮禁用/加载态填充色，与 AppTokens.swift / AppTokens.kt 已有定义对齐。

- **iOS ButtonShowcase Demo**：4 组递增单因子排查（① 基础形态仅 Primary → ② style 三样式对照 → ③ loading+disabled 状态 → ④ 三样式×三状态全形态组合），点击反馈条就地更新，版本徽标 Button v1.0。

- **Android ButtonDemo**：与 iOS ButtonShowcase 一一对应的 4 组排查，版本徽标 Button v1.0。

- **DemoShowcases.swift addVersionBadge 泛化**：新增 `componentName` 参数（默认 "Cell"），支持 Button 等其他组件复用版本徽标方法，现有 CellShowcase 调用无需改动。

### Changed

- **iOS AppButton.swift**：禁用/加载态填充色由硬编码 `UIColor(hex: 0x9CA3AF)` 改为设计令牌 `AppColor.buttonDisabled`。

- **Android AppButton.kt**：新增 `loading` 参数（对齐 iOS `setLoading`）；禁用/加载态填充色改用 `AppColor.buttonDisabled` 令牌；secondary 样式背景色由透明改 `AppColor.bgCard` 对齐 iOS 实现。

- **DemoShowcases.swift**：ui.button 条目 reviewed=false → true，create=nil → `{ ButtonShowcase() }`。

- **MainActivity.kt**：ui.button 条目 reviewed=false → true，demo=nil → `{ ButtonDemo() }`。

- **ui-version.json**：组件库版本 1.1.5 → 1.1.6（双端 iOS / Android 永远同版本，禁止手工改工程内版本）。

## \[1.1.5] - 2026-09-02

Cell v1.31 恢复诊断色到设计令牌色 + 补录 v1.30–v1.30c Demo4 三项未入库修复 + 根治 SwiftPM 缓存漂移。

### Fixed

- **iOS Cell 移除 v1.29 诊断色（9 处 systemColor 赋值 + 1 处 tableView 背景）**：按「组件分色排查法」第 6 步收尾流程，Demo4 4 项问题定位修复完毕后移除临时诊断色。还原：`backgroundColor & contentView.backgroundColor` → `AppColor.bgCard`；`iconView / titleLabel / subtitleLabel / valueLabel / arrowView / statusBadge / textStack.backgroundColor` → 透明（不设值）；`skeletonView.backgroundColor` → `AppColor.border`（与 Android 骨架灰底一致）；`tableView.backgroundColor`（Demo 页面内）→ `AppColor.bgPage`。

- **iOS Cell setHighlighted 禁用态错位修复**：`model.disabled` 为 true 时，`apply()` 已把 `contentView.backgroundColor = AppColor.gray4`（置灰语义）；之前 `setHighlighted` 无条件在松手恢复为蓝（诊断蓝 / bgCard），导致「禁用 cell 按住变灰 → 松手变白」视觉错位；本版补 `guard !model.disabled else { return }`，禁用态全程保持 gray4。

- **【补录 v1.30】iOS Demo4 行 1/2 底部无内边距**：`rowSpacing=16pt` 的 divider 间隙占据 contentView 底部 16pt bgPage 色，`hasSubtitle` 分支 `textStack.bottom = contentView.bottom - cellVertical` 恰好落在灰色间隙区（视觉上蓝色内边距=0），与 top 不对称。修复：两处 bottom `-cellVertical` → `-(cellVertical + rowSpacing)`（完整形态与「无 icon+副标题」两分支同步）。

- **【补录 v1.30】Android Demo4 行 6 loading 态箭头未右对齐**：loading 分支 `SkeletonTitle()` 按 `fillMaxWidth(0.4f)` 显示固有宽度，Row 尾部 arrow 紧贴骨架右侧。修复：外包 `Box(Modifier.weight(1f))`，撑满中间剩余空间，箭头被推到整行最右（与正常态 `Column(weight(1f))` 对称）。

- **【补录 v1.30c】Android Demo4 行 4 Error 图标与 iOS 不一致**：Material Icons 标准集无「圆+!」向量（仅有 `Warning`=三角!、`Cancel`=圆×），而 iOS 使用 SF Symbols `exclamationmark.circle.fill`（红圆+白!）。v1.30b 曾误入 `ImageVector.Builder + VectorConfig + SolidColor` 组合（Compose 无此 API），导致 `:android:components:compileDebugKotlin` 编译失败。v1.30c 修复为 Compose Canvas 直接绘制 `ErrorCircleBadge()`：drawCircle 红填充 + drawRect 白竖条 + drawRect 白圆点（24×24dp 视窗按短边缩放），颜色直接取 `AppColor.error` 设计令牌；双端令牌已核对：iOS `UIColor(hex: 0xDC2626)` ≡ Android `Color(0xFFDC2626)`，与 Success 色 `0x16A34A` 配对一致。

- **【根治】ios/Package.swift SwiftPM 依赖缓存漂移**：4 条依赖（Alamofire 5.9.1 / GRDB.swift 6.29.3 / Charts 4.1.0 / SnapKit 5.6.0）由 `.package(url:, exact:)` 远程 URL 改为 `.package(path: "Vendor/…")` 本地路径；`targets.dependencies` 中 GRDB 引用由 `package: "GRDB.swift"` → `package: "GRDB"`（本地路径依赖以子包自身 Package.swift 的 `name:` 字段为引用键，GRDB 自身 `name="GRDB"` 非目录名）；`targets.exclude` 移除 `"Vendor"`（远程+本地两份冲突时需要屏蔽，改纯本地后必须解除屏蔽以便 SwiftPM 直接扫描 Vendor 下 manifest）；Vendor 内部依赖链闭合：Charts → `../swift-algorithms` → `../swift-numerics` 均为相对本地路径引用，不产生任何远程 checkout。根治目的：终结 2026-08-30 起反复出现的「Charts/Package.swift:25 Extra arguments at positions #3, #4 / Reference to member 'produ' cannot be resolved」——根因是 SwiftPM 读取 `.build/checkouts/Charts` 下远程缓存脏 manifest，本地 Vendor 修复从未生效。

### Changed

- **双端 Demo 版本徽标**：v1.30 → v1.31。

- **ui-version.json**：组件库版本 1.1.4 → 1.1.5（双端 iOS / Android 永远同版本，禁止手工改工程内版本）。

## \[1.1.4] - 2026-09-02

Cell v1.28 修复无箭头无状态时 valueLabel trailing 锚点错误导致文字消失。

### Fixed

- **iOS Cell 无箭头无状态时文字消失**：v1.27 Demo2 改 `arrow: false` 后文字消失，Demo3（有箭头）正常。根因：`apply()` 中 valueLabel 的 trailing 锚点逻辑——当 `showArrow=false` 且 `hasStatus=false` 时，`valueTrailingTarget=contentView`，用 `.snp.leading` 锚点导致 `valueLabel.trailing = contentView.leading - lg`（左边外），进而 `textStack.trailing <= valueLabel.leading - sm` 变负数，textStack 宽度为负，文字被压缩消失。修复：拆分为三分支（有状态贴 statusBadge.leading / 有箭头贴 arrowView\.leading / 都没有贴 `contentView.trailing - lg`），消除 `.snp.leading` 方向错误。此 bug 一直潜伏，v1.27 之前所有 Demo 都带箭头（arrow 默认 true）从未触发。

### Changed

- **iOS Demo 版本徽标**：v1.27 → v1.28。

## \[1.1.3] - 2026-09-02

Cell v1.26 修复横屏 contentView 没充满 cell（safeArea inset 导致）+ Demo2 箭头配置修正。

### Fixed

- **iOS Cell 横屏 contentView 没充满 cell**：`UITableViewCell.insetsContentViewsToSafeArea` 默认 true（iOS 11+），横屏时 iPhone X+ 系列 safeArea 左右各 44pt，系统把 contentView inset 到 safeArea 内，cell 两侧（safeArea 外）露出 `cell.backgroundColor`，形成"白色块点击不变灰"现象（区块在 contentView 外不受 setHighlighted 影响）。竖屏 safeArea 左右=0 故无此问题。v1.26 诊断色（cell=红/contentView=蓝/tableView=紫）确认区块为红色=cell 自身背景。修复：重写 `layoutSubviews`，在 `super.layoutSubviews()` 后强制 `contentView.frame = bounds`，让 contentView 充满 cell 覆盖红色背景。内容子视图仍受 leading/trailing offset 约束在 safeArea 内，不被刘海遮挡。

- **iOS Demo2 箭头配置 bug**：`CellModel.arrow` 默认 true，Demo2「仅标题文字」未显式设 `arrow: false`，导致 Demo2 与 Demo3 配置完全一致（都带箭头），失去「纯标题无箭头」对照价值。修正：Demo2 显式 `arrow: false`，标题改「② 仅标题文字（无箭头）」，与 Demo3「标题+箭头」形成真正的单因子对照。

### Changed

- **iOS Cell 移除诊断色**：v1.25-v1.26 为排查横屏问题临时设 cell/contentView/textStack/titleLabel/tableView 为红/蓝/黄/橙/紫诊断色，本版恢复 `AppColor.bgCard` / `AppColor.bgPage`。

- **iOS Demo 版本徽标**：v1.25 → v1.27。

## \[1.1.2] - 2026-09-01

Cell v1.24 修复横屏"绿色块"问题（debug 副作用）+ 仅标题分支行高对齐设计稿。

### Fixed

- **iOS Cell 横屏"绿色块"问题**：v1.23 为排查横屏白色块临时将 `backgroundColor` / `contentView.backgroundColor` 设为 `.systemGreen`，暴露了 cell 56pt 内 textStack 只占 \~19pt、上下空白 \~24pt 的 layout 真相（横屏 cell 宽度变宽，绿色空白横向铺满变明显）。本版改回 `AppColor.bgCard`，绿色块变白色，视觉恢复正常。**非横屏特有 layout bug**，divider 始终在 cell 内部底部 16pt（bgPage 间隙色，不透明），不受影响。

### Changed

- **iOS Cell 仅标题分支行高对齐设计稿**：`apply()` 中仅标题分支（hasSubtitle=false）也调用 `titleLabel.setLineHeight(AppText.cellTitleLineHeight, fontSize: AppFont.sizeMd)`，让 textStack 行高 = 24pt（设计稿 cellTitleLineHeight）。v1.20 曾注释"仅标题不设 attributedText 让 UILabel 原生垂直居中"，但实测发现行高退化到系统默认 \~19pt，导致 cell 内部上下空白 \~24pt（偏离设计稿 cellVertical=16pt）。设行高 24pt 后 textStack 24pt，centerY 居中到 divider 上方可见区（0-40pt），上下空白各 8pt（divider 占下方 16pt，故可见区上下内边距折半为 8pt，符合设计稿逻辑）。

- **iOS Demo 版本徽标**：v1.23 → v1.24。

## \[1.1.1] - 2026-09-01

修正 v1.1.0 的错误垂直居中补偿：iOS 原生 `minimumLineHeight = maximumLineHeight` 撑行高时文字已接近居中，v1.1.0 额外加的 `baselineOffset` 补偿反而把文字整体下推（且放大 `UILabel.intrinsicContentSize`，撑高 textStack → 箭头同步偏下）。本版移除补偿，恢复原生行高分配，对齐 Android Compose 视觉。

### Fixed

- **iOS Cell 文字/箭头垂直居中（v1.18 修正）**：`AppText.verticalCenterBaselineOffset` 由 `(lineHeight - naturalLineHeight)/2` 改为返回 `0`（不补偿）。依据：macOS TextKit 像素级实测 + iOS 用户实测双重确认——原生 min/max 行高下文字质心偏差仅 +0.5pt，叠加补偿后 +3.5pt（偏下，复现用户实测）。同时 `baselineOffset` 会增大 `UILabel.intrinsicContentSize`，撑高 `textStack`（箭头 `centerY` 锚定它）导致箭头同步偏下，移除补偿一并解决。

- **iOS Demo 横屏不适配**：`SelfSizingTableView.intrinsicContentSize` 原只在高度变化时 invalidate，横屏旋转后宽度变化不触发重算，cell 不随屏幕宽度自适应。现宽度/高度任一变化均刷新。

- **iOS 垂直居中实测辅助**：新增 `Cell.debugTitleVerticalOffset()` / `debugTrailingCenterOffset()`，demo「② 仅标题」组输出标题/箭头相对 cell 内容区中心的实测偏移（pt），供 iOS 实机校准真值（替代纯数学推导）。

### Changed

- **iOS** **`CellTests`** **H3**：断言改为 v1.18 校准结论（补偿值恒为 0，行高契约 24/18 + 单行 56 不变）。

- **新增 iOS** **`CellTests`** **H3b**：实测辅助方法可用性断言（返回有限值）。

## \[1.1.0] - 2026-09-01

修复 Cell 单行标题在行内文字未垂直居中（iOS 平台独有，Android Compose `lineHeight` 天然居中）。

### Fixed

- **iOS Cell 标题行内文字垂直居中**：`AppText.setLineHeight` 使用 `minimumLineHeight/maximumLineHeight` 撑行高时，额外行高由系统按字体度量分配，不保证行内文字居中（用户实测 Demo2 标题偏上/偏下）。新增 `AppText.verticalCenterBaselineOffset(lineHeight:fontSize:font:)` 计算基线补偿，以 `baselineOffset` 下移半个额外高度，使文字在行高内视觉居中，对齐 Android Compose `lineHeight` 行为。

- 双端行高契约保持一致（单行 56 / 副标题 76），本次仅修正行高内文字垂直位置，不改动行高数值。

### Added

- **iOS** **`CellTests`** **H3**：断言 `verticalCenterBaselineOffset` 使「文字中心 = 行高中点」，固化行内垂直居中契约（token 层）。

- **Android** **`CellTest`** **H4**：渲染层断言单行标题节点垂直中心 ≈ cell-root 中心，防回归（Robolectric 可跑）。

## \[Unreleased]

### Removed

- **视觉资产淘汰（svg/截图 → H5 规格页）**：删除 `docs/design-spec/svg/`（27 个 SVG 设计图）、`docs/visuals/` 与 `www/public/visuals/`（组件截图）；`api.json` 移除 `visual_refs` 字段；删除生成脚本 `generate_design_svgs.py`、`build_design_gallery.py`、`migrate_taxonomy_names.py`。设计规格统一以 H5 规格页为准（`docs/design-spec/cell-design-spec.html` 等）。

- **一次性迁移产物清理**：删除 `docs/id-migration.json`（分类改名迁移已完成，历史在 git 可查）。

### Changed

- **验收流程收拢**：验收四件套移入 `docs/验收流程/`（`验收标准.md` / `flow.html` / `验收模板.md` / `评审清单.md`），新增 `docs/验收流程/README.md` 流程索引。

- **规范文档合并（8 → 3）**：`component-rules.md` + `api-contract.md` + `component-schema.md` → `docs/开发规则.md`；`design-spec.md` + `design-token-README.md` → `docs/设计规范.md`；`component-governance.md` + `versioning.md` + `containment.md` → `docs/治理规范.md`。新增 `docs/README.md` 目录导航与 `docs/平台差异.md`（补齐历史悬空引用）。

- **文档中文命名**：docs 内人工阅读文档统一中文命名（`开发规则.md`/`设计规范.md`/`治理规范.md`/`组件分类.md`/`组件进度.md`/`平台差异.md`/`组件审计.md`/`验收流程/` 等），机器消费数据源（`*.json`/`embeddings/`/`*.html`）保留英文。

- **验收标准增强**：五阶段 + 门禁 A/B/C1/C2/D（依赖优先、用例即代码、快照比对、业务落地验证、季度复查/回归清单）。

- **目录收敛（方案 B）**：组件 metadata 收口为 `docs/api.json`（由 `catalog/components.jsonl` 转换，含命名/作用/API 契约 props/events/demos/平台状态/设计 token）；样式数据收口为 `docs/design-token.json`（原 `design-token/tokens.json`）；版本号收口为 `docs/ui-version.json`（原根目录）。

- **目录更名**：`docs-site/` → `www/`（组件文档站，构建时读 `docs/api.json` 生成）；`catalog/`、`design-token/` 目录并入 `docs/`，旧目录删除。

- **组件分类重构**：顶层两大类 `ui`（UI 组件）/ `foundation`（底层能力）；`ui` 新增 `subcategory` 五子类（基础通用 `basics` / 导航 `navigation` / 数据录入 `input` / 数据展示 `display` / 操作反馈 `feedback`，对齐 NutUI 分类）。

- **业务组件剥离**：原 `business.*` 9 个组件移出组件库 `components`（`componentCount` 36 → 27），登记于 api.json 顶层 `businessExtensions`（标注 `tier: business-extension`，为继承基础组件二次开发的业务层产物），不再进入 catalog / embeddings / audit。

- **ID 迁移**：`basic.*` → `ui.*`（如 `basic.empty` → `ui.empty`），`legacy_id` 记录旧值；迁移已完成，迁移表已随 2026-08-30 清理删除（历史在 git 中可查）。

## \[1.0.0] - 2026-08-29

首次以独立组件库仓库发布。完成从 OPC monorepo 到独立仓库 + submodule 的拆分，命名空间统一为 `com.zhiqihuayun.*`。

### Changed

- **命名空间统一**：Android 端 `com.tmo.*` → `com.zhiqihuayun.*`。

  - namespace / groupId：`com.tmo` → `com.zhiqihuayun`

  - 包路径：`com.tmo.foundation.*` → `com.zhiqihuayun.foundation.*`，`com.tmo.sharedui.*` → `com.zhiqihuayun.sharedui.*`

  - 工程名：`tmo-android` → `zhiqihuayun-android`，`tmo-demo-android` → `zhiqihuayun-demo-android`

  - 依赖坐标：`com.tmo:components` → `com.zhiqihuayun:components`

  - iOS Demo：`TMODemo` → `ZhiqihuayunDemo`（bundle id 已为 `com.zhiqihuayun.demo`）

- **仓库拆分**：`packages/*` 迁移为 `Native-UI-Comps` 独立仓（ios / android / shared / design-token / adapters / docs-site），OPC 以 submodule 挂载。

- **文档升级**：docs-site 升级为官方组件库文档（首页 / 使用指南 / 双端契约 / 版本日志 / 设计规范）。

### Added

- 官方文档站正式发布：新增首页、使用指南、双端平台契约矩阵、版本日志页面。

- `com.zhiqihuayun` 命名空间下的统一构建配置。

### Fixed

- 清理 Android 构建产物（`.class` / `.flat` / `.len`）入仓问题，独立仓只保留源码与配置。

## \[0.9.0] - 2026-08-11

> 注：0.9.x 为迁移前 OPC monorepo 内的 `packages/*` 演进记录，供追溯；独立仓以 1.0.0 为起点。

### Added

- 双端组件库收敛为 `packages`（ios + android + design-token + shared）。

- 组件 catalog（`components.jsonl`）与 docs-site 检索站点雏形。

- iOS SPM 产物（Foundation / SharedUI）与 Android AAR（components）。

