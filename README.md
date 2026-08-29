# Native-UI-Comps · 中台原生 UI 组件库

组件库专属目录，位于中台 `TechMiddleOffice/` 之下、与其平级、完全解耦。

> 本目录是**组件库权威根**，也是未来独立 Git 仓库 `ProductRDDept_TechMiddleOffice_Native-UI-Comps.git` 的本地对应。
> 所有组件库相关代码、文档、Token、脚本、版本只允许沉淀在这里，禁止混入 `TechMiddleOffice/` 其他方案或业务目录。

---

## 一、目录结构（强制统一，见 `docs/component-governance.md`）

```
Native-UI-Comps/
├── docs/                 # 全局规范文档（Markdown）
│   ├── api-contract.md   #   双端 API 契约规范
│   ├── design-spec.md    #   设计规范（Token 使用铁律）
│   ├── versioning.md     #   版本治理
│   ├── component-governance.md
│   └── containment.md    #   目录约束
├── design-token/         # 唯一样式数据源 tokens.json（颜色/字号/圆角/间距/行距）
├── ios/                  # iOS 组件库源码（SPM）
│   ├── Package.swift
│   ├── SharedUI/Components/  #   UI 组件
│   └── Foundation/           #   基建（Design/Network/Routing/Storage/SystemBars/Util）
├── android/              # Android 组件库源码（Gradle 多模块）
│   ├── settings.gradle.kts   #   rootProject = zhiqihuayun-android
│   ├── sharedui/components/  #   UI 组件源码
│   ├── components/           #   Gradle 模块（编译入口）
│   └── foundation/           #   基建（design/network/routing/util）
├── demo/                 # 独立 Demo 运行环境（monorepo）
│   ├── ios/              #   iOS Demo（XcodeGen，引用 ../ios 源码）
│   └── android/          #   Android Demo（Gradle app，includeBuild ../android）
├── catalog/              # 组件台账 + 单一 metadata 源
│   ├── components.jsonl  #   每组件：命名/作用/能力/API契约(props,events,demos)/平台状态/设计token
│   ├── embeddings/       #   向量检索索引
│   └── visuals/          #   组件截图
├── docs-site/            # 组件文档站（React+Vite+AntD，构建时读 catalog 生成）
│   └── scripts/generate_data.py
├── scripts/              # 工具脚本
│   ├── embed.py          #   生成检索向量
│   ├── search.py         #   自然语言搜组件
│   ├── merge_contracts_into_catalog.py  # API契约并入 catalog
│   └── migrate_taxonomy_names.py        # 分类体系迁移
├── shared/               # 跨平台共享资源（category-icons 分类图标）
├── ui-version.json       # 全局唯一版本号
└── CHANGELOG.md          # 版本日志（docs-site「版本日志」页数据源）
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
- ✅ B3 完成：本目录已是该独立仓，OPC 通过 submodule 挂载（见 OPC `.gitmodules`）。

## 四、本目录现状

- 阶段一（规范沉淀）：✅ A1~A7 完成，规范文档落位于 `docs/`。
- 阶段二（代码迁移）：✅ B1 完成——组件源码、catalog、docs-site、scripts、demo 已全部迁入本目录，形成**自包含组件库仓**（monorepo：iOS + Android + 目录 + 文档站 + Demo）。
- 阶段二（独立仓）：✅ B3 完成——本目录已抽为独立 Git 仓库，OPC 以 submodule 挂载。
- 阶段二（API 契约收口）：✅ 组件 API 契约（props/events/demos/note）已并入 `catalog/components.jsonl`，docs-site 构建时读取，不再维护第二份源。
- App 侧：KeepAccounts iOS 仍以 XcodeGen 引用 `Native-UI-Comps/ios`（暂排除冲突），B5 改 SPM 后移除。

> 详细任务进度见 `../../../TASKS.md`。
