# 收纳约定与迁移指引（Containment）

> 明确"哪类代码放哪、现在在哪、阶段二迁到哪"，杜绝组件库与业务代码混放。
> 其他 Agent 开发前先读本文件，避免在错误位置落代码。

---

## 一、三大物理位置（铁律）

| 位置 | 放什么 | 禁止放什么 |
|------|--------|-----------|
| `ProductRDDept/TechMiddleOffice/Native-UI-Comps/`（阶段二=独立仓） | 双端组件源码、Design Token、API 契约、版本源、生成脚本 | ❌ 业务代码、业务实体、业务 Repository |
| `ProductRDDept/TechMiddleOffice/` | 中台方案（catalog、docs-site、scripts 等非组件资产）；组件库治理由 Native-UI-Comps 承接 | ❌ 组件库源码（迁出中） |
| `ProductRDDept/TechMiddleOffice/DevOpsDept/`（A7 新增） | 发布/部署/运营/上线脚本、CI 流水线 | ❌ 业务代码、组件实现 |

---

## 二、迁移完成（B1/B1a/B2 已执行，2026-08-29）

### 2.1 迁移后现状

```
ProductRDDept/
├── TechMiddleOffice/           # 中台技术部
│   ├── Native-UI-Comps/        #   组件库权威根（自包含，monorepo）
│   │   ├── ios/                #     iOS 组件源码（SPM）
│   │   ├── android/            #     Android 组件源码（Gradle）
│   │   ├── design-token/       #     唯一 Token 源（tokens.json）
│   │   ├── shared/             #     跨平台资源（category-icons 等）
│   │   ├── adapters/           #     跨平台适配说明
│   │   ├── catalog/            #     组件台账（components.jsonl + embeddings + visuals）
│   │   ├── docs-site/          #     组件文档站（React+Vite+AntD）
│   │   ├── demo/               #     独立 Demo（demo/ios + demo/android）
│   │   ├── scripts/            #     生成/检索脚本
│   │   ├── docs/               #     组件库规范文档
│   │   └── ui-version.json     #     全局唯一版本源
│   ├── docs/                   #     中台通用规范（repository-naming 等）
│   └── DevOpsDept/             #     运维部（A7）
└── App/ SAAS/ Traffic/ docs/   # 业务与部门文档
```

### 2.2 迁移记录

| 原位置（TechMiddleOffice/） | 目标位置（Native-UI-Comps/） | 任务 | 状态 |
|------|------|------|------|
| `packages/ios/`（组件+foundation） | `ios/` | B1 | ✅ |
| `packages/android/` | `android/` | B1 | ✅ |
| `packages/design-tokens/` | `design-token/` | B1 | ✅ |
| `packages/shared/` | `shared/` | B1 | ✅ |
| `packages/adapters/` | `adapters/` | B1 | ✅ |
| `catalog/` | `catalog/` | B1a | ✅ |
| `docs-site/` | `docs-site/` | B1a | ✅ |
| `scripts/` | `scripts/` | B1a | ✅ |
| `demo/` | `demo/` | B2 | ✅ |

> `packages/`、`catalog/`、`docs-site/`、`scripts/`、`demo/` 已从 TechMiddleOffice 移除，全部归入 Native-UI-Comps。

---

## 三、代码分类（什么进组件库，什么留在业务）

| 分类 | 判定 | 归属 |
|------|------|------|
| `basic.*` | 高度可复用 UI 组件（Empty/List/Card/Grid/DatePicker…） | ✅ 组件库 |
| `foundation.*` | 不绑定业务域的基建（Router/Storage/HTTP/DesignTokens…） | ✅ 组件库 |
| `business.*` | 强业务绑定（Repository/AmountKeyboard/Fixtures/业务视图…） | ❌ 业务 App |

> 判定口诀：**能被两个以上不同业务复用的 → 组件库；只服务一个业务的 → 留业务。**

---

## 四、开发操作指引（给 AI Agent / 开发）

1. **新增组件**：先到 `Native-UI-Comps/docs/api-contract.md` 定契约 → 再进 `Native-UI-Comps/ios/` + `Native-UI-Comps/android/` 实现。
2. **改样式**：改 `Native-UI-Comps/design-token/design_tokens.json` → 跑 `scripts/gen_token_*` 重新生成双端。
3. **升版本**：改 `Native-UI-Comps/ui-version.json` → 跑 `scripts/version_sync` → 打 Tag 发版。
4. **发版/部署脚本**：统一归 `TechMiddleOffice/DevOpsDept/`，不要散落在各处。
5. **禁止**在业务目录遗留新组件代码；组件库代码一律落在 `Native-UI-Comps/`（`packages/` 已撤除）。

---

## 五、README 索引（导航）

- 组件库根/权威规范：`Native-UI-Comps/README.md`
- 治理规范：`Native-UI-Comps/docs/component-governance.md`
- 设计规范：`Native-UI-Comps/docs/design-spec.md`
- API 契约：`Native-UI-Comps/docs/api-contract.md`
- 版本规范：`Native-UI-Comps/docs/versioning.md`
- 仓库命名规范（中台通用）：`TechMiddleOffice/docs/repository-naming.md`
- 中台方案：`TechMiddleOffice/README.md`
- 运维部：`TechMiddleOffice/DevOpsDept/README.md`（A7）

---

## 六、命名规范（全局）

- 遵循中台技术部通用规范 `../repository-naming.md`（TechMiddleOffice 下所有产物通用）：仓库 = `{一级部门}_{二级部门}_{部门产物}`，部门间用 `_`，产物用 `-`。
- 例：`ProductRDDept_TechMiddleOffice_Native-UI-Comps`（一级部门 `ProductRDDept` `_` 二级部门 `TechMiddleOffice` `_` 部门产物 `Native-UI-Comps`）。
- 目录名沿用仓库的部门产物段（`Native-UI-Comps`）。
