# Changelog

Native-UI-Comps 组件库版本日志。本文件是官方文档「版本日志」页的唯一数据源，随每次发布一并更新。

格式遵循 [Keep a Changelog](https://keepachangelog.com/zh-CN/)：

```markdown
## [版本号] - YYYY-MM-DD
### Added / Changed / Fixed / Removed / Security
- 条目
```

---

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
