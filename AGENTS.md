# Native-UI-Comps · 给 AI Agent 的接续指南

> 中台组件库：iOS（Swift）+ Android（Kotlin/Compose）双端通用组件，含 95 组件目录、五门禁验收流程、双端 Demo 工程。
> 本文件是 Agent 打开仓库的**自动加载入口**；做任何事前先读第 1 节导航，避免走错文档。

---

## 1. 入口导航（按需取用）

| 场景 | 看哪个 |
|------|--------|
| 全文档导航（哪些文件是干什么的） | `docs/README.md` |
| ★ 当前任务清单 + 进度（接续必读） | `docs/组件进度.md` |
| 评审流程完整定义（五阶段 + 门禁 A/B/C1/C1.5/C2/D） | `docs/验收流程/验收标准.md` |
| 开始做/验收一个组件 | `docs/验收流程/README.md` |
| 评审打勾单（门禁 A/B） | `docs/验收流程/评审清单.md` |
| 验收文档模板 | `docs/验收流程/验收模板.md` |
| ★ 双端 Demo 场景定义一致性门禁 | `scripts/check_demo_parity.py`（门禁 C1.5 第一步，必跑） |
| 命名 / 打包 / API 契约规则 | `docs/开发规则.md` |
| 样式 Token 铁律 | `docs/设计规范.md` |
| 代码放哪 / 版本 / 发版 | `docs/治理规范.md` |
| 组件分类表（95 个，完整度基准） | `docs/组件分类.md` |

---

## 2. 组件评审流程（一图速查）

```
读取组件列表（docs/组件进度.md，按顺序）
  → 🔗 依赖优先：deps 未完成则等待
  → ❓ 用得到？否 → ⏭【暂未使用】跳过（季度复查）
  → 阶段1 设计（H5 规格页 + 设计用例）────门禁 A────
  → 阶段2 API（api.json 契约 + API 用例）───门禁 B────
  → 阶段3 双端实现 + 测试（用例即代码）───门禁 C1───
  → 阶段3.5 Demo Showcase + 实机确认 ───门禁 C1.5───
  （先跑 scripts/check_demo_parity.py 双端场景定义 diff，再实机看效果）
  → 阶段4 CR + CI ───────────────门禁 C2───
  → 阶段5 发版 + 业务真实接入 ──────门禁 D─── → 验收完成 → 更新进度
```

**关键动作**：
- 每轮评审产出**评审意见单**：复制 `docs/验收流程/评审清单.md` 为 `review-<组件名>-A/B.md`，勾选留档。
- 每组件验收文档：复制 `docs/验收流程/验收模板.md` 为 `component-acceptance-<组件名>.md`，五要素（设计细节/设计测试/API细节/API测试/效果查看）缺一打回。
- **每过一道门禁就更新 `docs/组件进度.md`**，否则其他 Agent 无法接续。
- 验收产物一律 H5 页（设计规格 `docs/design-spec/*.html` / www 文档站），用户浏览器即可验收。

---

## 3. Demo 标准（双端 Demo 工程）

### 3.1 Demo 首页 = 组件列表（已定稿，勿改回平铺堆叠）

- 首页按「**分类 → 组件**」两级组织，分类与 `docs/组件分类.md` 一致。
- **已评审**组件（门禁 A/B/C1 通过）→ 可点击，进入该组件的独立 Demo 页。
- **未评审**组件 → 列表**置灰不可点**。
- **每评审通过一个组件，就把它加回 Demo**（评审前不加）。未评审的组件按钮保持置灰状态。

### 3.2 单组件 Demo 页

- 覆盖**五态**（默认/禁用/加载/成功/失败，N/A 标注）+ 主要 props 组合 + 关键事件回调。
- Provider 型组件（无五态，如 ConfigProvider）：用「配置生效对比」演示（覆盖前 vs 覆盖后）。
- 双端差异点（如长按不承诺）在 showcase 中用说明文案标注，作为实机确认项。

### 3.3 Demo 工程位置与运行

| 端 | 位置 | 运行 |
|----|------|------|
| iOS | `demo/ios`（xcodegen 生成） | `cd demo/ios && xcodegen generate && open *.xcodeproj`，Xcode 跑模拟器 |
| Android | `demo/android` | Android Studio 打开运行，或 `./gradlew :app:assembleDebug` |

- 各组件 Demo 入口与查看指引见对应 `docs/验收流程/component-acceptance-<组件名>.md` 的「效果查看」节。

---

## 4. 工程依赖（重要 · iOS 已本地化）

- iOS 依赖 **SnapKit / Charts / GRDB / Alamofire**（+ 传递依赖 swift-algorithms / swift-numerics）已全部 vendor 到 `ios/Vendor/`（本地 path 引用），**离线可构建**。
- `demo/ios/project.yml` 中 packages 一律用 `path: ../../ios/Vendor/xxx`，**勿改回远程 URL**（GitHub 网络不稳会导致 SPM 解析失败）。
- `ios/Package.swift` 仍保留远程 URL 声明（组件库对外发布的正式形态），仅 Demo 工程用本地 Vendor。

---

## 5. 当前进度（截至 2026-08-30）

| 组件 | 状态 | 下一步 |
|------|------|--------|
| Cell 单元格 | 门禁 A/B/C1/C1.5 全过，Demo 双端已加 | 发版（门禁 C2 待办） |
| ConfigProvider 全局配置 | 阶段 1 设计中，门禁 A 待评审 | 评审材料已产出，等用户评审 |
| 其余 93 组件 | 未开始（完整度 25.3%） | 按 `docs/组件进度.md` 顺序推进 |

> 完整进度、达成情况、每个组件的门禁状态一律以 `docs/组件进度.md` 为准。

---

## 6. 通用红线

- 改 `docs/api.json` / `design-token.json` / `ui-version.json`（唯一数据源）后必须重跑对应生成脚本，不得只改一处。
- 版本号以 `docs/ui-version.json` 为准，双端永远同版本，禁止手工改工程内版本。
- **汇报组件必须带版本号（强制，2026-09-01 新增）**：任何讨论/汇报/改动某个组件（如 Cell）时，必须先说明该组件当前所基于的组件库版本号（`docs/ui-version.json` 的 `version`，双端同版）。若本会话中改动过该组件，汇报时必须标注"已提升/基于的版本号 + 改动内容"，避免用户无法区分当前组件是哪个版本。版本号有变则同步更新 CHANGELOG 与 ui-version.json。
- 不更新唯一数据源 / 不更新进度文档 → 视为未完成。
