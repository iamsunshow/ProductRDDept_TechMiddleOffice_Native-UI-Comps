# 组件验收文档 · ConfigProvider 全局配置

> 依据：`docs/验收流程/验收标准.md` 9.6 节（五要素）。流程：设计细节+设计测试用例（阶段1，门禁A）→ API细节+API测试用例（阶段2，门禁B）→ 实现并执行测试（阶段3，门禁C1）→ Demo Showcase + 实机确认（阶段3.5，门禁C1.5）→ CR+CI（门禁C2）→ 发版 + 业务落地（门禁D）。
> 用例即代码：用例 ID（D1-D8 / A1-A7）与测试函数一一对应，命名如 `test_D1_defaultBaseline`，CI 在门禁 C1 自动核对。
> 特殊性：Provider 型组件无视觉五态（默认/禁用/加载/成功/失败不适用），D 系列改为「配置生效测试」，见第二节。

---

## 一、验收信息

| 项 | 值 |
|----|-----|
| 组件名 / id | 全局配置 ConfigProvider / `ui.config-provider`（历史：`foundation.config-provider`） |
| 分类（subcategory） | 基础组件（api.json subcategory=basics，2026-09-03 门禁 B 定稿） |
| 推进顺序 | 列表第 #3 位（基础组件） |
| 状态 | ✅ 设计中（A，通过）→ 📋 API（B）→ 💻 实现（C）→ ✅ |
| 验收文档 | `docs/验收流程/component-acceptance-config-provider.md` |
| 设计规格页 | `docs/design-spec/config-provider-design-spec.html`（浏览器打开） |

---

## 二、① 设计细节（阶段 1 · 门禁 A 评审）

> 详细内容在 H5 设计规格页（覆盖示例 + 机制示意），此处为索引与评审结论。

| 项 | 内容 |
|----|------|
| 组件用途 | 为子树提供运行时全局配置（主题色/圆角/紧凑尺寸/语言），后代组件经上下文读取，免逐层透传；定位 = design-token.json 静态基准之上的运行时覆盖层。典型场景：品牌皮肤切换、紧凑模式（iPad/管理页密度）、局部区块圆角统一、多语言入口预留 |
| 五态定义 | **无五态**（Provider 型组件不产出视觉像素，「配置如何消费」由消费组件按 token 引用实现）；D 系列改为**配置生效测试**（覆盖前 vs 覆盖后） |
| 配置清单 | `primaryColor?`（主题色覆盖，影响 color.primary 系）／`rounded?`（圆角升一档：sm→md，md→lg）／`compact?`（间距降一档：md→sm，lg→md）／`locale?`（默认 'zh-CN'）／`children`（作用域） |
| 运行机制 | 覆盖 = 对「静态基准 + 父级配置」的叠加替换；未覆盖项完全沿用静态基准；嵌套时内层覆盖外层同名项、外层未覆盖项继承；design-token.json 与双端 AppTokens 静态常量**不被修改**，覆盖仅发生在读取解析层 |
| 双端差异 | 覆盖机制平台原生差异（iOS UIAppearance/环境对象 vs Android CompositionLocal），**已登记 `docs/平台差异.md`** |
| 与现有组件关系 | deps=[]（纯上下文组件，不依赖业务组件）；被全库消费组件依赖（读取配置）；与 `ui.cell` 等组件正交 |
| 设计参考图 | `docs/design-spec/config-provider-design-spec.html`（04 节覆盖前后对比渲染，非截图） |

**设计评审（门禁 A）结论：** ✅ 通过（用户 2026-09-03 确认）　☐ ❌ 打回　备注：冻结设计，进入 API 阶段；API 契约随 `docs/api.json` 定稿（subcategory 复核为 basics）

---

## 三、② 配置生效测试用例（阶段 1 定义 · 阶段 3 执行）

> Provider 型无五态，D 系列为「配置生效测试」：以消费组件（如 Cell 读取主色/间距/圆角）为观测点，验证覆盖前后渲染差异。门禁 C 执行，结果随 PR 提交。

| # | 用例 | 前置 | 步骤 | 预期 | 双端 | 结果 |
|---|------|------|------|------|------|------|
| D1 | 默认基准（零行为变化） | — | 不挂 Provider 渲染消费组件 | 与静态基准完全一致（design-token.json 取值），未挂 Provider 场景无任何行为变化 | iOS+Android | ☐ |
| D2 | 主题色覆盖 | — | 挂 `<ConfigProvider primaryColor="#4F46E5">` 渲染消费组件 | color.primary 系解析结果变为 #4F46E5，其余 token 不变 | iOS+Android | ☐ |
| D3 | 紧凑模式 | — | 挂 `<ConfigProvider compact>` 渲染消费组件 | 间距降一档（space.md→sm，lg→md），尺寸与档位一致 | iOS+Android | ☐ |
| D4 | 圆角模式 | — | 挂 `<ConfigProvider rounded>` 渲染消费组件 | 圆角升一档（radius.sm→md，md→lg） | iOS+Android | ☐ |
| D5 | 静态基准不被污染 | — | 覆盖后检查 design-token.json 与双端 AppTokens | 静态基准零改动，覆盖仅发生在读取解析层 | 两端 CI | ☐ |
| D6 | 嵌套优先级（内层覆盖 + 继承） | — | 嵌套两层 Provider（外层 primaryColor、内层 compact） | 内层覆盖外层同名项；外层未覆盖项（primaryColor）被继承 | iOS+Android | ☐ |
| D7 | 语言切换 | — | 挂 `<ConfigProvider locale="en-US">` | 组件内文案切换为英文 | iOS+Android | ☐ |
| D8 | 组合覆盖 | — | 同时挂 primaryColor + compact + rounded | 三项同时生效，互不干扰 | iOS+Android | ☐ |

---

## 四、③ API 设计细节（阶段 2 · 门禁 B 评审）

> 完整契约在 `docs/api.json` + `docs/开发规则.md` 第八节，此处为评审索引。

| 能力面 | 字段 | 关键内容 |
|--------|------|----------|
| 属性 Props | `props` | 属性名 / 类型 / 默认值（双端 100% 对齐） |
| 事件 Events | `events` | 回调名 / 签名（Provider 型为空） |
| 方法 Methods | `methods` | 命令式接口（如有） |
| 能力标签 | `capabilities` | 检索标签 |
| 场景 | `scenarios` | 典型场景语料 |
| Token 依赖 | `visual_tokens` | token 名列表（覆盖键为运行时非静态，visual_tokens=[]） |
| 组件关系 | `deps` | 依赖组件 id（=[]） |
| 平台状态 | `platforms` | available / partial / unavailable |

**API 评审（门禁 B）结论：** ☐ ✅ 通过　☐ ❌ 打回　备注：契约拟稿于 `docs/api.json` `ui.config-provider`（primaryColor/rounded/compact/locale/children），待门禁 B 评审后定稿

---

## 五、④ API 测试用例（阶段 2 定义 · 阶段 3 执行）

> 覆盖属性取值、作用域穿透、覆盖语义。门禁 C 执行，结果随 PR 提交。

| # | 用例 | 前置 | 步骤 | 预期 | 双端 | 结果 |
|---|------|------|------|------|------|------|
| A1 | 属性-默认值 | — | 不传 props 渲染 Provider | 默认值生效（rounded=false、compact=false、locale='zh-CN'） | iOS+Android | ☐ |
| A2 | 属性-自定义 | — | 传入各 props | 覆盖按传入值生效，双端一致 | iOS+Android | ☐ |
| A3 | 作用域-子树读取 | — | 在 Provider 内渲染后代组件 | 配置经上下文穿透，后代免逐层透传读取到 | iOS+Android | ☐ |
| A4 | 作用域-作用域外不受影响 | — | 在 Provider 外渲染同款组件 | 作用域外组件读取静态基准，不受覆盖影响 | iOS+Android | ☐ |
| A5 | 能力-覆盖语义 | — | 嵌套 Provider + 组合覆盖 | 与设计测试 D6/D8 对应，覆盖语义正确 | iOS+Android | ☐ |
| A6 | 契约-schema | api.json | 校验脚本 | props/events/methods 字段合法 | CI | ☐ |
| A7 | 契约-命名对齐 | api.json | 双端对照 | 双端 props 命名 100% 一致 | CI | ☐ |

---

## 六、⑤ 效果查看（Demo Showcase · 阶段 3.5 · 门禁 C1.5，实现后填写）

> Provider 型无五态，以**配置生效对比**演示：demo 中挂 `<ConfigProvider primaryColor="…" compact rounded>` 包裹一组消费组件（如 Cell 列表），覆盖前 vs 覆盖后同屏对比（主题色/间距/圆角档位变化）；嵌套 Provider 演示内层优先 + 继承。

| 端 | 操作 | 查看内容（演示点） |
|----|------|-------------------|
| Android | Android Studio 打开 `demo/android` 运行 app，首页 → ConfigProvider 区 | 覆盖前后对比 + 嵌套优先级 + 未覆盖项继承 |
| iOS | `cd demo/ios && xcodegen generate && open *.xcodeproj`，Demo 首页 → basic → ConfigProvider 全局配置 | 覆盖前后对比 + 嵌套优先级 + 未覆盖项继承 |

**双端差异观察点**：覆盖机制平台原生差异（iOS UIAppearance/环境对象 vs Android CompositionLocal），见 `平台差异.md`。

**实机确认（门禁 C1.5）结论：** ☐ ✅ 通过　☐ ❌ 打回　备注：

---

## 七、验收记录

| 日期 | 门禁 | 结论 | 备注 |
|------|------|------|------|
| 2026-09-03 | A 设计评审 | ✅ 通过 | 评审单 `docs/验收流程/review-config-provider-A.md` |
|  | B API 评审 | 通过 / 打回 | `api.json` `ui.config-provider` 定稿 |
|  | C1 自测对齐（单测+快照+用例映射） | 通过 / 打回 | 双端实现 + 测试执行 |
|  | C1.5 Demo Showcase + 实机确认 | 通过 / 打回 | 双端 demo 配置生效对比 + 用户实机确认 |
|  | C2 CR + CI | 通过 / 打回 | 待办：CR + CI 接入 |
|  | 发版 | 版本号 / tag |  |
|  | D 业务落地 | 接入成功 / 回退 | 接入位置 / 代码量变化，见 `docs/usage-config-provider.md` |
