# Changelog

Native-UI-Comps 组件库版本日志。本文件是官方文档「版本日志」页的唯一数据源，随每次发布一并更新。

格式遵循 [Keep a Changelog](https://keepachangelog.com/zh-CN/)：

```markdown
## [版本号] - YYYY-MM-DD
### Added / Changed / Fixed / Removed / Security
- 条目
```

***

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

