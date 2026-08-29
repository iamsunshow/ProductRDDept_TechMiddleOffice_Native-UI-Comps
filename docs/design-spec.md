# 设计规范（Design Specification）

> 双端视觉统一铁律。**唯一数据源 = `design-token/design_tokens.json`**。
> 所有颜色/间距/圆角/字号/阴影，双端一律读取 Token，禁止硬编码。
> 本文件说明 Token 结构、双端自动生成、平台差异白名单。

---

## 一、唯一数据源原则

- 唯一 Token 源文件：`design-token/design_tokens.json`（版本库内权威 JSON）。
- 脚本自动生成：
  - iOS：Swift 样式常量（`gen_token_ios`）
  - Android：xml/kt 样式资源（`gen_token_android`）
- **改一处，双端同步生效**；两端代码永不手写样式值。
- 新样式必须先加 Token，再在双端使用；禁止直接写死数值。

---

## 二、Token 结构与语义

当前 Token（与 `packages/design-tokens/tokens.json` 对齐，阶段二迁移后归入本仓）：

### 2.1 颜色 color

| Token | 值 | 用途 |
|-------|-----|------|
| `primary` | `#16A34A` | 主色（品牌/主要操作） |
| `primaryPressed` | `#15803D` | 主色按压态 |
| `primaryMuted` | `#DCFCE7` | 主色浅背景 |
| `income` | `#16A34A` | 收入/正向 |
| `expense` | `#DC2626` | 支出/负向 |
| `warning` | `#F59E0B` | 警示 |
| `textPrimary` | `#111827` | 主文本 |
| `textSecondary` | `#6B7280` | 次要文本 |
| `textInverse` | `#FFFFFF` | 反白文本（主色底上） |
| `border` | `#E5E7EB` | 边框/分割线 |
| `bgPage` | `#F9FAFB` | 页面背景 |
| `bgCard` | `#FFFFFF` | 卡片背景 |
| `success` | `#16A34A` | 成功态 |
| `error` | `#DC2626` | 错误态 |

### 2.2 字号 font.size 与字重 font.weight

| Token | 值 | 用途 |
|-------|-----|------|
| `sizeXs` | 12 | 辅助说明 |
| `sizeSm` | 14 | 正文次要 |
| `sizeMd` | 16 | 正文默认 |
| `sizeLg` | 18 | 小标题 |
| `sizeXl` | 22 | 标题 |
| `sizeDisplay` | 32 | 大屏数字/大标题 |
| `weightRegular` | 400 | 常规 |
| `weightMedium` | 500 | 中等 |
| `weightSemibold` | 600 | 半粗 |

### 2.3 圆角 radius

| Token | 值 | 用途 |
|-------|-----|------|
| `sm` | 6 | 小控件/标签 |
| `md` | 10 | 按钮/输入框 |
| `lg` | 14 | 卡片 |
| `full` | 999 | 圆形/胶囊 |

### 2.4 间距 space

| Token | 值 | 用途 |
|-------|-----|------|
| `xs` | 4 | 紧凑 |
| `sm` | 8 | 内边距小 |
| `md` | 12 | 默认间距 |
| `lg` | 16 | 元素间距 |
| `xl` | 24 | 区块间距 |

### 2.5 文本排版 text

| Token | 值 |
|-------|-----|
| `lineSpacing` | 8 |
| `paragraphSpacing` | 12 |
| `lineHeightMultiple` | 1.8 |

### 2.6 阴影 shadow（规范补充，尚未入 json 需补）

> ⚠️ `tokens.json` 当前**缺阴影**。阶段二迁移时应补：
> - `shadow/none`：无阴影
> - `shadow/sm`：`0 1 2 rgba(0,0,0,0.05)`
> - `shadow/md`：`0 2 6 rgba(0,0,0,0.08)`
> - `shadow/lg`：`0 8 20 rgba(0,0,0,0.12)`
>
> 补齐前禁止使用任意自定义阴影数值。

---

## 三、双端自动生成

- 生成脚本位于 `scripts/`：
  - `gen_token_ios`：读 tokens.json → 产出 `ios/Sources/**/DesignTokens.swift`
  - `gen_token_android`：读 tokens.json → 产出 `android/**/res/values/tokens.xml` + `Tokens.kt`
- CI 发版时自动重跑生成，保证两端始终与唯一源同步。
- 本地开发改动 Token 后必须重跑生成脚本，再提交。

---

## 四、平台差异白名单 platform-diff

允许的系统级原生差异（必须登记，禁止悄悄差异化）：

| 项 | iOS | Android | 备注 |
|----|-----|---------|------|
| 手势 | UIGesture | GestureDetector | 系统行为 |
| hover | 无 | 有 | Android 支持 hover 态 |
| 键盘 | 系统键盘 | IME | 系统行为 |
| 控件默认样式 | UIKit | Material | 需覆盖对齐 |

> 完整白名单维护在 `docs/design-token/platform-diff.md`。
> 白名单之外的视觉/行为差异一律禁止。

---

## 五、状态规范（双端统一）

每个组件必须支持以下状态（默认值可空白）：

1. **默认** default
2. **禁用** disabled
3. **加载** loading
4. **成功** success
5. **失败** error

> 各组件状态表现详见 `api-contract.md` 对应章节。

---

## 六、禁止行为

- ❌ 两端硬编码颜色/圆角/尺寸/字号/阴影。
- ❌ 私自改 Token 不跑生成脚本、不提交唯一源。
- ❌ 白名单之外的双端视觉差异。
- ❌ 用未登记 Token 的魔法数值。
