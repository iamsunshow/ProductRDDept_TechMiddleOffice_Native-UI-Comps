# Storage 本地存储 · 门禁 A 评审单（任务清单 #93 · 未评审组件补齐批）

> 组件 ID：`foundation.storage` ｜ 设计规格：`design-spec/storage-design-spec.html`
> 评审方式：🖊 AI 代评（用户 2026-09-04 总授权；2026-09-14「2.0的组件本次不开发，优先开发未评审的组件」指示接棒）
> 评审日期：2026-09-14 ｜ 组件库版本：v1.4.0 ｜ 终核：并入用户 C1.5 Demo 实机验收

## 评审清单

| # | 项 | 判定 | 说明 |
| - | -- | --- | --- |
| A1 | 组件边界（SCQA） | ✅ | 定位=本地优先持久化**骨架**（建库/迁移/清空），表结构与迁移逻辑由宿主注入；与业务表划界=schema 归宿主；与 ConfigProvider/KV 配置划界=轻量配置走 UserDefaults/SharedPreferences，不走本组件；与网络缓存划界=二期；与字段加密划界=一期不做 |
| A2 | Token 零硬编码 | ✅ | 纯逻辑层（无视觉输出），无 token 依赖 |
| A3 | 决策投票表 | ✅ | P1-A 只做生命周期骨架、schema 由宿主注入（零业务依赖）；P2-A **一期补齐 Android 最小骨架（原生 <code>SQLiteOpenHelper</code>，零新依赖）**，与 iOS GRDB 骨架语义对齐；P3-A schema 注入各循平台惯例（iOS 全局静态 / Android 显式传参）；P4-A 一期=建库/迁移/清空 + Demo 4 段 |
| A4 | Demo 排查 4 组 | ✅ | D1 建库+写入 / D2 读取列表 / D3 删除单条 / D4 eraseAll 清空（用内置 <code>demo_note</code> 表演示「宿主注入 schema → 骨架建库迁移 → 业务读写 → 注销清空」全链路） |
| A5 | 实现现状 | ⚠ **双端不对等（本轮补齐）** | iOS `ios/Foundation/Storage/AppDatabase.swift`（GRDB，<code>AppDatabase.shared</code> + <code>DatabaseSchemaProvider</code> + <code>prepare()</code>/<code>eraseAll()</code>，已实现）；**Android 无任何实现**（全仓检索 <code>SQLiteOpenHelper/SharedPreferences/Room/AppDatabase</code> = 0 命中）。**⚠ 组件进度.md 原记「✅ 双端已实现（KV+加密统一接口）」与实际不符，本轮据实纠正为「iOS 已实现 / Android 本轮补齐」** |
| A6 | 平台差异表 | ✅ | 表内放行：SQLite 封装（GRDB vs SQLiteOpenHelper，底层同为 SQLite）、迁移表达（DatabaseMigrator vs version+migrations 列表，语义一致）、接入方式（全局静态 vs 显式传参，Android 需 Context）、存储目录（Application Support vs filesDir，同为应用私有持久目录）、线程模型（GRDB 队列自管 vs 调用方切 IO） |
| A7 | anti_goals 反目标 | ✅ | 字段级加密/密钥管理=一期不做（宿主按敏感信息规范自处理）；网络缓存/离线同步=二期；ORM 实体映射/代码生成=一期不做；迁移可视化工具=非目标 |

## 评审结论

| 项 | 内容 |
| -- | --- |
| 结论 | ✅ 通过（P1–P4 全 A，0 保留意见；含 Android 缺口补齐决策 + 组件进度记录纠正） |
| 用户签字 | （终核并入用户 C1.5 Demo 实机验收） |
| 下一步 | 新增 Android `AppDatabase.kt`（SQLiteOpenHelper 骨架）→ 双端 Demo（StorageShowcase / StorageDemo 4 段 1:1）→ api.json 补 reviewed+subcategory + note 记录 Android 补齐 → demo 注册行 planned→reviewed → C1.5 验收 |
