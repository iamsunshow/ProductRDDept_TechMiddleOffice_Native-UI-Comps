# Native-UI-Comps · TMO 组件库（中台原生 UI 组件库）

> **TMO = TechMiddleOffice**。无特殊说明时，「TMO组件库」即指本目录（`Native-UI-Comps`，组件库权威根）。

组件库专属目录，位于中台 `TechMiddleOffice/` 之下、与其平级、完全解耦。

> 本目录是**组件库权威根**，也是未来独立 Git 仓库 `ProductRDDept_TechMiddleOffice_Native-UI-Comps.git` 的本地对应。
> 所有组件库相关代码、文档、Token、脚本、版本只允许沉淀在这里，禁止混入 `TechMiddleOffice/` 其他方案或业务目录。

---

## 一、目录结构（强制统一，导航与规范入口见 `docs/README.md`）

> **命名约定**：人工阅读的文档一律中文命名（`组件进度.md`、`平台差异.md` 等）；
> 机器消费的数据源 / 脚本产物保留英文名并统一收在 `docs/数据与产物/` 与 `vector-store/`（`api.json`、`design-token.json`、`ui-version.json`、`*.html`），避免编码/路径问题。

```
Native-UI-Comps/
├── docs/                 # 文档目录=3 篇人读文档 + 1 个数据目录（先看 docs/README.md）
│   ├── README.md             #   ★先看：文档地图=规范入口=数据文件说明
│   ├── 组件进度.md            #   ★必读：组件完善进度+分类口径+双端一致性（1.1 节）+验收归档
│   ├── 平台差异.md            #   双端平台差异白名单（系统级原生差异登记表）
│   └── 数据与产物/            #   程序直读/脚本生成=不要打开阅读
│       ├── api.json          #   组件 metadata 单一数据源（命名/契约/状态）【机器读取】
│       ├── design-token.json #   唯一样式数据源（颜色/字号/圆角/间距）【机器读取】
│       ├── ui-version.json   #   全局唯一版本号【发版脚本读取】
│       └── design-spec/      #   设计规格 H5 页（门禁 A 输入资产=浏览器验收）
├── vector-store/         # 向量检索索引（独立于 docs=embed.py 生成/search.py 读取）
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
├── www/                  # 组件文档站（React+Vite+AntD，构建时读 docs/数据与产物/api.json 生成）
│   └── scripts/generate_data.py
├── scripts/              # 工具脚本
│   ├── embed.py          #   生成检索向量
│   ├── search.py         #   自然语言搜组件
│   ├── merge_contracts_into_catalog.py  # API契约并入 docs/数据与产物/api.json
│   ├── measure_adoption.py              # 业务接入自研率度量（验收门禁 D）
│   └── gen_component_audit.py           # 双端 API 对齐审计
├── shared/               # 跨平台共享资源（category-icons 分类图标）
└── CHANGELOG.md          # 版本日志（www「版本日志」页数据源）
```

## 二、核心原则（详见各规范文档）

| 原则 | 一句话 | 文档 |
|------|--------|------|
| 唯一数据源 | 颜色/间距/圆角/字号/阴影只来自 Design Token，禁止硬编码 | `docs/数据与产物/design-token.json` + `docs/README.md` |
| 双端对齐 | 组件 Props/参数/状态/回调 100% 对齐 | `docs/README.md`（正文在产研部唯一手册） |
| 版本唯一 | 双端永远同一版本号，以 `ui-version.json` 为准 | `docs/数据与产物/ui-version.json` |
| 治理铁律 | 变更独立提交、统一发版、禁止乱升级 | `docs/README.md`（正文在产研部唯一手册） |
| 组件规则 | 命名/沟通语言/特色组件打包/业务库不造轮子 | `docs/README.md`（正文在产研部唯一手册） |
| 分类基准 | 组件分类口径（NutUI React 4.x + 完整度指标） | `docs/组件进度.md` 第 1.1 节 |
| 验收标准 | 设计先行/API check/测试门禁/CR/业务自研率度量 | 《产研部-唯一权威手册》第二章 |
| 运维归口 | 发布/部署/上线脚本由 `TechMiddleOffice/DevOpsDept/` 统一维护 | DevOpsDept README |

## 三、独立 Git 仓库

- 仓库地址：`https://github.com/iamsunshow/ProductRDDept_TechMiddleOffice_Native-UI-Comps.git`
- 命名遵循中台技术部通用仓库命名规范（见 `TechMiddleOffice/README.md`）：一级部门 `ProductRDDept` `_` 二级部门 `TechMiddleOffice` `_` 部门产物 `Native-UI-Comps`
- ✅ B3 完成：本目录已是该独立仓，OPC 通过 submodule 挂载（见 OPC `.gitmodules`）。

## 四、本目录现状

- 阶段一（规范沉淀）：✅ A1~A7 完成，规范文档落位于 `docs/`。
- 阶段二（代码迁移）：✅ B1 完成——组件源码、catalog、docs-site、scripts、demo 已全部迁入本目录，形成**自包含组件库仓**（monorepo：iOS + Android + 目录 + 文档站 + Demo）。
- 阶段二（独立仓）：✅ B3 完成——本目录已抽为独立 Git 仓库，OPC 以 submodule 挂载。
- 阶段二（API 契约收口 + 目录收敛）：✅ 组件 metadata 已收口为 `docs/数据与产物/api.json`（含 API 契约 props/events/demos/note），样式数据收口为 `docs/数据与产物/design-token.json`，版本号收口为 `docs/数据与产物/ui-version.json`；`catalog/`、`design-token/` 目录已并入 `docs/`，`docs-site/` 已更名 `www/`，文档站构建时读 `docs/数据与产物/api.json` 生成，不再维护多份数据源。
- App 侧：KeepAccounts iOS 仍以 XcodeGen 引用 `Native-UI-Comps/ios`（暂排除冲突），B5 改 SPM 后移除。

> 详细任务进度见 `../../../TASKS.md`。
