# Changelog

Native-UI-Comps 组件库版本日志。本文件是官方文档「版本日志」页的唯一数据源，随每次发布一并更新。

格式遵循 [Keep a Changelog](https://keepachangelog.com/zh-CN/)：

```markdown
## [版本号] - YYYY-MM-DD
### Added / Changed / Fixed / Removed / Security
- 条目
```

---

## [Unreleased]

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

## [1.0.0] - 2026-08-29

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

## [0.9.0] - 2026-08-11

> 注：0.9.x 为迁移前 OPC monorepo 内的 `packages/*` 演进记录，供追溯；独立仓以 1.0.0 为起点。

### Added
- 双端组件库收敛为 `packages`（ios + android + design-token + shared）。
- 组件 catalog（`components.jsonl`）与 docs-site 检索站点雏形。
- iOS SPM 产物（Foundation / SharedUI）与 Android AAR（components）。
