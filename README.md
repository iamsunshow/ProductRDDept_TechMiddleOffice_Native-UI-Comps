# Native-UI-Comps · 中台原生 UI 组件库

组件库专属目录，位于中台 `TechMiddleOffice/` 之下、与其平级、完全解耦。

> 本目录是**组件库权威根**，也是未来独立 Git 仓库 `ProductRDDept_TechMiddleOffice_Native-UI-Comps.git` 的本地对应。
> 所有组件库相关代码、文档、Token、脚本、版本只允许沉淀在这里，禁止混入 `TechMiddleOffice/` 其他方案或业务目录。

---

## 一、目录结构（强制统一，见 `docs/component-governance.md`）

```
Native-UI-Comps/
├── docs/                 # 全局规范文档（本目录权威）
│   ├── api-contract/     # 每个组件双端 API 契约
│   ├── design-token/     # 唯一 Token 源（json）+ 平台差异白名单
│   └── design-spec.md / api-contract.md / versioning.md / component-governance.md
├── design-token/         # 唯一样式数据源 json（实际 Token 源，tokens.json）
├── ios/                  # iOS 组件库源码（SharedUI 组件 + Foundation 基建，SPM）
├── android/              # Android 组件库源码（sharedui/foundation/components，Gradle）
├── demo/                 # 独立 Demo 运行环境（monorepo）
│   ├── ios/              #   iOS Demo（XcodeGen，引用 ../ios 源码）
│   └── android/          #   Android Demo（Gradle app，includeBuild ../android）
├── catalog/              # 组件台账（components.jsonl + embeddings + visuals）
├── docs-site/            # 组件文档站（React+Vite+AntD，展示 catalog）
├── scripts/              # 生成/检索脚本（embed.py / search.py / gen_token_*）
├── adapters/             # 跨平台适配说明（iOS/Android/Harmony/小程序）
├── shared/               # 跨平台资源（category-icons 等）
├── ui-version.json       # 全局唯一版本号
├── Package.swift         # SPM 入口（iOS，位于 ios/ 下）
└── .github/workflows/    # 统一 CI 发版流水线
```

## 二、核心原则（详见各规范文档）

| 原则 | 一句话 | 文档 |
|------|--------|------|
| 唯一数据源 | 颜色/间距/圆角/字号/阴影只来自 Design Token，禁止硬编码 | `docs/design-spec.md` |
| 双端对齐 | 组件 Props/参数/状态/回调 100% 对齐 | `docs/api-contract.md` |
| 版本唯一 | 双端永远同一版本号，以 `ui-version.json` 为准 | `docs/versioning.md` |
| 治理铁律 | 变更独立提交、统一发版、禁止乱升级 | `docs/component-governance.md` |
| 运维归口 | 发布/部署/上线脚本由 `TechMiddleOffice/DevOpsDept/` 统一维护 | DevOpsDept README |

## 三、独立 Git 仓库

- 仓库地址：`https://github.com/iamsunshow/ProductRDDept_TechMiddleOffice_Native-UI-Comps.git`
- 命名遵循中台技术部通用规范 `../docs/repository-naming.md`：一级部门 `ProductRDDept` `_` 二级部门 `TechMiddleOffice` `_` 部门产物 `Native-UI-Comps`
- 阶段二将把本目录抽为该独立仓，OPC 用 submodule 挂载。

## 四、本目录现状

- 阶段一（规范沉淀）：✅ A1~A7 完成，规范文档落位于 `docs/`。
- 阶段二（代码迁移）：✅ B1 完成——组件源码、catalog、docs-site、scripts、demo 已全部迁入本目录，形成**自包含组件库仓**（monorepo：iOS + Android + 目录 + 文档站 + Demo）。
- 阶段二（独立仓）：进行中——B3 起将本目录抽为独立 Git 仓库，OPC 用 submodule 挂载。
- App 侧：KeepAccounts iOS 仍以 XcodeGen 引用 `Native-UI-Comps/ios`（暂排除冲突），B5 改 SPM 后移除。

> 详细任务进度见 `../../../TASKS.md`。
