# 组件库治理与管理规范（component-governance）

> 本规范合并《双端（iOS/Android）原生UI组件库标准化管理技术规范（最终落地版）》与
> 《双端原生中台组件库最终落地方案（Submodule + SPM二进制 + Android二进制）》两份方案，
> 固化为可执行治理铁律。其他 Agent 读完本文件即可正确执行组件库的一切管理动作。
>
> 地位：**唯一权威治理文档**。凡与业务代码、OPC 主仓、发布流程相关的组件库动作，均以本文件为准。

---

## 一、目标与解决的历史痛点

- OPC 单仓混组件，导致 SPM 拉取业务源码、源码泄露风险。
- iOS/Android 版本混乱、双端视觉行为不一致。
- AI Agent 开发需切换多仓库、多窗口，成本高。
- 业务编译慢、源码依赖臃肿。
- 无统一文档、无统一变更溯源、无统一发版。

最终形态：**一套设计规范、一套 API 契约、一套版本号、一套发版流程、双端各自原生实现**。

---

## 二、仓库架构（定稿，不可随意变更）

### 2.1 双仓库物理隔离

- **仓库 A = 业务主仓（OPC）**：存放业务 App/代码/资源。通过 submodule 挂载组件库，**不存放任何组件源码**。
- **仓库 B = 中台组件独立仓（`ProductRDDept_TechMiddleOffice_Native-UI-Comps`）**：纯组件仓库，**无任何业务代码**，可对外分发、无泄露风险。

### 2.2 独立仓目录标准（强制统一）

```
Native-UI-Comps/
├── docs/                # 全局规范文档
│   ├── api-contract/    # 每个组件双端 API 契约
│   ├── design-token/    # 唯一 Token 源（json）
│   ├── platform-diff.md # 双端差异白名单
│   └── CHANGELOG.md
├── design-token/        # 唯一样式数据源 json
├── scripts/             # gen_token_ios / gen_token_android / version_sync
├── ios/                 # iOS SPM 组件库 + Demo
├── android/             # Android Library + Demo
├── ui-version.json      # 全局唯一版本号
├── Package.swift        # SPM 配置（iOS 二进制 binaryTarget）
└── .github/workflows/   # 统一 CI 发版流水线
```

> 本地对应目录：OPC 主仓内 `ProductRDDept/TechMiddleOffice/Native-UI-Comps/`（权威根）。阶段二完成后，该目录即成为独立仓的本地工作副本，经 submodule 挂载。

### 2.3 双端技术载体（定稿）

| 端 | 载体 | 分发方式 | 依赖管理 |
|----|------|----------|----------|
| iOS | SPM（Swift Package） | Git Tag 版本，**二进制 xcframework**（不下发源码） | `.package(url:..., from: "x.y.z")` |
| Android | Gradle Library | **AAR** + GitHub Packages Maven | `implementation("com.xxx.ui:xxx:x.y.z")` |

---

## 三、Submodule 挂载机制（重点）

### 3.1 挂载命令

OPC 主仓执行：

```bash
git submodule add git@github.com:iamsunshow/ProductRDDept_TechMiddleOffice_Native-UI-Comps.git ./ProductRDDept/TechMiddleOffice/Native-UI-Comps
```

### 3.2 本地开发目录结构（关键体验）

```
opc-main（OPC）/
 ├── ProductRDDept/
 │   ├── TechMiddleOffice/
 │   │   └── Native-UI-Comps/   # ← submodule 指向独立组件仓（权威根）
 │   └── App/  SAAS/  Traffic/ ...
```

**本地只打开 OPC 主工程即可同时读写业务代码与组件代码，无需切仓库。**

### 3.3 子模块变更的提交铁律（最重要）

> ⚠️ **子模块（Native-UI-Comps）的每一次变更，都必须单独 commit 到子模块自己的仓库，
> 绝不允许把子模块内容混进 OPC 主仓的提交里。**

正确流程（以改一个 iOS 组件为例）：

```bash
# 1. 进入子模块目录
cd ProductRDDept/TechMiddleOffice/Native-UI-Comps

# 2. 在子模块内做改动并单独提交到子模块仓库
git add .
git commit -m "fix(iOS): 修复 Button 禁用态样式"
git push origin main          # 推送到独立仓
git tag v1.0.1 && git push origin v1.0.1   # 需要发版时打 tag

# 3. 回到 OPC 主仓，只更新"子模块指针"（一个 commit，引用新版本）
cd ../..
git add ProductRDDept/TechMiddleOffice/Native-UI-Comps
git commit -m "chore: bump Native-UI-Comps to v1.0.1"
git push origin main
```

### 3.4 主仓看到的只是"指针"

- OPC 主仓里 `ProductRDDept/TechMiddleOffice/Native-UI-Comps` 是一个 gitlink（提交指针），不包含组件源码实体。
- 组件源码实体只存在于独立仓 `ProductRDDept_TechMiddleOffice_Native-UI-Comps.git`。
- 主仓更新子模块 = 更新指针 = 引用独立仓某个 commit/tag。

### 3.5 拉取/初始化子模块

```bash
git clone <OPC仓库>            # 克隆主仓
git submodule update --init --recursive   # 拉取子模块（首次）
git submodule update --recursive          # 后续同步子模块到指针版本
```

### 3.6 常见坑

- 忘 `git push` 子模块，导致主仓指针指向一个不存在的 commit → 别人拉取失败。**先推子模块，再推主仓**。
- 在主仓里直接改子模块目录并 `git add .` 提交 → 会把组件源码误传进主仓。**必须在子模块目录内单独 commit**。
- 两端代码变更都要进**独立仓**，不要只改本地。

---

## 四、唯一数据源（样式统一铁律）

- 所有颜色/间距/圆角/阴影/字号**不允许两端硬编码**。
- 唯一来源：`design-token/design_tokens.json`。
- 脚本自动生成 iOS Swift 样式常量 + Android xml/kt 样式资源。
- **改一处，双端同步生效**。

## 五、组件开发顺序（强制）

```
文档/Figma 先行 → Token 更新 → 双端并行开发 → Demo 更新 → 自测对齐 → 统一发版
```

- 禁止先写代码后补文档。
- 组件 **Props/参数/状态/回调函数名 100% 对齐**。
- 组件状态统一：**默认 / 禁用 / 加载 / 成功 / 失败**。
- 交互行为、弹窗层级、点击反馈双端统一。
- 系统级原生差异（手势/hover/键盘/控件样式）允许，但必须登记 `docs/design-token/platform-diff.md`。
- 不支持平台：空实现、不报错、不抛异常，对外文档标注"仅 iOS / 仅 Android"。

## 六、版本管理铁律（核心中的核心）

详见 `versioning.md`，要点：

- 全局唯一版本源：根目录 `ui-version.json`。业务工程/两端代码/CI **禁止手写版本号**。
- iOS、Android **永远同一版本号**（major/minor/patch 完全一致）。
- 一端变更、另一端即使无代码改动，也要同步升级版本。
- 语义化：patch=bug修复/微调样式；minor=新增组件/新增属性；major=不兼容API/大规模重构。

## 七、统一发版流程

### 7.1 发版前置（开发完成）

1. 更新 Token（如有样式变更）
2. 更新 API 契约文档
3. 更新 CHANGELOG.md
4. 双端 Demo 同步更新示例
5. 自测双端视觉、交互、状态一致性

### 7.2 正式发版

1. 修改 `ui-version.json` 新版本号
2. 执行 `scripts/version_sync` 同步全仓库版本
3. commit 所有变更（**子模块内单独提交**）
4. 打 Tag `vX.Y.Z`，推送触发 CI
5. 回到主仓更新子模块指针

### 7.3 CI 流水线自动执行

- 校验 Tag 与配置版本一致
- 重新自动生成双端 Token 资源
- iOS：编译 SPM + Demo 校验（**二进制不强制上传**，如需源码包则推送）
- Android：打包 AAR 上传 GitHub Packages Maven
- 自动生成 Release 日志
- **即使只有一端变更，CI 也会自动生成另一端空版本，保证双端版本对齐**

> 发版动作脚本统一由 `TechMiddleOffice/DevOpsDept/` 维护（见 A7）。

## 八、业务工程接入规范（禁止乱升级）

### 8.1 iOS 接入（SPM）

固定版本，禁止 `latest`、禁止动态模糊版本：

```swift
.package(url: "https://github.com/iamsunshow/ProductRDDept_TechMiddleOffice_Native-UI-Comps.git", from: "1.0.0")
```

### 8.2 Android 接入（Gradle）

```groovy
implementation("com.xxx.ui:xxx:1.0.0")
```

### 8.3 版本管控红线

- 禁止业务手动升级大版本（major）。
- 大版本升级统一由组件库团队（中台）通知。
- patch 小版本可按需静默升级。

## 九、迭代流程

| 场景 | 流程 |
|------|------|
| 新增组件 | Figma设计 → Token更新 → API文档定稿 → 双端并行开发 → Demo → 自测对齐 → 统一发版 |
| 修改组件 | 文档先改 → 双端同步改逻辑 → 同步 Demo → 统一发版 |
| Bug 修复 | 任意一端 Bug → 升级 patch 版本 → 两端同步版本号发版 |

## 十、禁止行为（团队红线）

- ❌ 禁止双端硬编码颜色、圆角、尺寸。
- ❌ 禁止两端版本号不一致。
- ❌ 禁止业务使用动态 `latest` 版本。
- ❌ 禁止改代码不改文档、不改日志。
- ❌ 禁止双端私自差异化修改组件 API。
- ❌ 禁止把子模块内容混进 OPC 主仓提交。
- ❌ 禁止在 OPC 主仓直接存放组件源码（须经独立仓）。

## 十一、术语

- **OPC 主仓**：业务主仓，挂 submodule。
- **独立仓 / 组件独立仓**：`ProductRDDept_TechMiddleOffice_Native-UI-Comps.git`。
- **子模块 / submodule**：OPC 主仓里的 gitlink 挂载点 `ProductRDDept/TechMiddleOffice/Native-UI-Comps`。
- **Native-UI-Comps**：组件库本地权威目录名（部门产物）。
- **仓库命名规范**：遵循中台技术部通用规范 `../../docs/repository-naming.md`：`{一级部门}_{二级部门}_{部门产物}`，部门间用 `_`，产物用 `-`。
