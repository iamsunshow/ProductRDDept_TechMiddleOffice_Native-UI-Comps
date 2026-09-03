# 组件验收文档 · Image 图片

> 依据：`docs/验收流程/验收标准.md` 9.6 节（五要素）。流程：设计细节+设计测试用例（阶段1，门禁A）→ API细节+API测试用例（阶段2，门禁B）→ 实现并执行测试（阶段3，门禁C1）→ Demo Showcase + 实机确认（阶段3.5，门禁C1.5）→ CR+CI（门禁C2）→ 发版 + 业务落地（门禁D）。
> 用例即代码：用例 ID（D1-D8 / A1-A7）与测试函数一一对应，命名如 `test_D1_defaultRenders`, CI 在门禁 C1 自动核对。
> 设计规格页：`docs/design-spec/image-design-spec.html`（浏览器打开）。

---

## 一、验收信息

| 项 | 值 |
|----|-----|
| 组件名 / id | 图片 Image / `ui.image`（历史：无 legacy） |
| 分类（subcategory） | 基础组件（api.json subcategory=display，门禁 B 定稿） |
| 推进顺序 | 列表第 #5 位（基础组件） |
| 状态 | 💻 实现中 · 门禁 C1 双端实现 + 自测（门禁 A ✅ 2026-09-03；门禁 B ✅ 2026-09-03 冻结 `ui.image`） |
| 验收文档 | `docs/验收流程/component-acceptance-image.md` |
| 设计规格页 | `docs/design-spec/image-design-spec.html` |
| 组件库版本 | v1.3.0（2026-09-03 发布；基线 v1.2.1） |

---

## 二、① 设计细节（阶段 1 · 门禁 A 评审）

> 详细内容在 H5 设计规格页（能力范围 / 五态 / fit 演示 / 尺寸标注），此处为索引与评审结论。

| 项 | 内容 |
|----|------|
| 组件用途 | 增强版图片容器：统一 API 渲染图片内容（本地资源 / 平台图像对象），提供对象填充模式（fit）、内容停靠（position）、加载中/失败占位、圆角裁剪与事件回调；对标 NutUI React Image（增强版 img）；不内置预览（属 #68 ImagePreview） |
| 五态定义 | 默认=正常渲染；禁用=**N/A**（图片无禁用语义，由外层容器控制）；加载=loading 占位（默认灰底+扫描+指示器，可自定义）；成功=加载完成即正常渲染（onLoad 触发，视觉同默认）；失败=error 占位（默认破图+「加载失败」，可自定义 + onError） |
| 尺寸规格 | 宽/高由业务传（默认撑满父容器）；radius 默认 0，可引 token 档位（sm 6 / md 10 / lg 14）或任意数值（=宽/2 即圆形）；占位色/字号/间距全部引用 design-token（见规格页 08） |
| 交互细节 | 可选 onTap（无默认按压反馈）；加载/失败占位在容器内切换不抖版；失败后重设 src 自动重载；hover/长按/3D Touch N/A 归外层 |
| 双端差异 | fit→contentMode（iOS）/ContentScale（Android）映射、圆角实现（cornerRadius+masksToBounds vs Modifier.clip）、src 定位（Asset Catalog vs @DrawableRes）、占位实现（UIView 切换 vs when(状态)）；登记 `docs/平台差异.md`（实现阶段补条目） |
| 与现有组件关系 | deps=[]（占位内置绘制，不依赖未完成 Icon/Loading）；被 Cell/Avatar/Card 等消费；预览归 ImagePreview #68 无重复 |
| 设计参考图 | `docs/design-spec/image-design-spec.html`（04 节 fit 五模式渲染 + 02 节五态渲染 + 03 节尺寸标注，非截图） |

**待决策点（门禁 A 评审拍板）**：P1 网络图 URL 加载（建议 B：一期仅本地，保持零三方依赖与双端一致）/ P2 lazy 懒加载（建议 B：一期 N/A 标注缺口）/ P3 圆形快捷（建议 A：radius=宽/2）/ P4 失败重试（建议 B：仅 onError，重试由业务改 src）。

**设计评审（门禁 A）结论：** ✅ 通过（2026-09-03 用户确认：冻结设计进入 API 阶段；P1=B URL 业务预下载 / P2=B lazy 一期 N/A / P3=A 圆形=radius=宽/2 / P4=B 失败仅 onError）　☐ ❌ 打回

---

## 三、② 设计测试用例（阶段 1 定义 · 阶段 3 执行）

> Image 为有视觉组件，D 系列按五态 + 尺寸/内容渲染断言。门禁 C 执行，结果随 PR 提交。

| # | 用例 | 前置 | 步骤 | 预期 | 双端 | 结果 |
|---|------|------|------|------|------|------|
| D1 | 默认渲染 | 提供标记图（如对角双色） | 本地 src 渲染，容器 120×90 | 图完整显示、容器尺寸=120×90、无圆角、无占位残留 | iOS+Android | ☐ |
| D2 | fit 模式全值 | 标记图宽高比≠容器 | 依次 fill/contain/cover/none/scale-down | 各模式几何符合语义：fill 拉伸铺满 / contain 完整显示留边 / cover 等比铺满裁边 / none 原始尺寸 / scale-down 不大于原图；渲染几何与「绘制 rect 纯函数」计算一致 | iOS+Android | ☐ |
| D3 | position 停靠 | fit=contain，容器>内容 | 依次 center/top/bottom/left/right | 内容停靠在指定侧，停靠点与计算一致；fit=fill/cover 时 position 无视觉影响 | iOS+Android | ☐ |
| D4 | 尺寸与圆角 | — | width/height 显式 + radius=md；radius=宽/2 | 圆角裁剪生效（四角不露图、角点像素为底）；圆形渲染完整 | iOS+Android | ☐ |
| D5 | 加载中占位 | 异步源（URL/延迟） | 加载期间观察 | 显示 loading 占位（默认样式；传自定义时显示自定义）；加载完成占位消失、onLoad 触发一次；loading 占位有可读语义（alt 兜底） | iOS+Android | ☐ |
| D6 | Token 引用 | 代码静态检查 | 扫描实现文件 | 颜色/尺寸全部引用 design-token.json，零硬编码（质量脚本保留位，无测试函数） | 两端 CI | ☐ |
| D7 | 加载失败占位 | 无效 src | 触发失败 | error 占位显示（默认破图+文案；自定义时自定义）、onError 触发一次；重设合法 src 后恢复渲染；失败占位有可读语义（原 A7「无障碍-占位语义」并入） | iOS+Android | ☐ |
| D8 | 点击与无障碍 | — | 点击图片 / 渲染后读无障碍 | onTap 回调触发（点击区域=容器内全部）；iOS accessibilityLabel=alt；Android contentDescription=alt | iOS+Android | ☐ |

> 五态说明：禁用 N/A（02 节有依据）不入 D 系列；成功态=D1/D5 加载完成段；D2-D4 几何断言采用「双端绘制几何纯函数 + 布局/像素双通道」防平台盲区（吸取 Cell token/整行两层均测不到行内对齐的教训——纯函数闭数学环，像素层闭视觉差异）。

---

## 四、③ API 设计细节（阶段 2 · 门禁 B 评审）

> 完整契约已录入 `docs/api.json` `ui.image`（subcategory=display，tier=core），此处为评审索引。门禁 A 决策已定稿（2026-09-03 用户拍板）：P1=B URL 业务侧预下载后传图对象（组件库零第三方图片加载依赖）/ P2=B lazy 一期 N/A / P3=A 圆形=radius=宽/2 / P4=B 失败仅 onError（重试由业务改 src）。

**属性 Props（9）**
| 属性 | 类型 | 必选/默认 | 说明 |
|------|------|-----------|------|
| `src` | string \| platform-image-object | 是 | 图片来源：本地资源名（iOS Asset Catalog / Android @DrawableRes）或平台图对象（UIImage / ImageBitmap\|Painter）；URL 归业务预下载（P1=B） |
| `fit?` | 'fill'\|'contain'\|'cover'\|'none'\|'scale-down' | 否，默认 'fill' | 对象填充模式（同 CSS object-fit） |
| `position?` | 'center'\|'top'\|'right'\|'bottom'\|'left' | 否，默认 'center' | 内容停靠（fit=none/contain 且容器大于内容时生效） |
| `width?` / `height?` | number | 否，默认撑满父容器 | 布局尺寸（逻辑 pt/dp，业务值非 token） |
| `radius?` | number \| 'sm'\|'md'\|'lg' | 否，默认 0 | 圆角：token 档位（6/10/14）或数值；=宽/2 即圆形（P3=A） |
| `alt?` | string | 否 | 无障碍描述（iOS accessibilityLabel / Android contentDescription） |
| `loadingContent?` / `errorContent?` | custom-content | 否 | 占位自定义内容（默认内置绘制，deps=[]） |

**事件 Events（3）**
| 事件 | 签名 | 说明 |
|------|------|------|
| `onTap?` | () => void | 点击图片（容器全部区域） |
| `onLoad?` | () => void | 加载完成（成功态） |
| `onError?` | () => void | 加载失败（触发失败占位；重试由业务改 src，P4=B） |

**方法 Methods**：无（NutUI 无实例方法）。
**anti_goals（已录入 api.json）**：URL 网络图不在本组件（P1=B）/ lazy 一期 N/A（P2=B）/ 不内置预览·裁剪·编辑·上传（预览独立组件）/ 无内置失败重试（P4=B）/ 占位不依赖未完成 Icon/Loading。

**API 评审（门禁 B）结论：** ✅ 通过（2026-09-03 用户表决冻结 `ui.image` 为准绳，props 9 + events 3，P1–P4 决策见上）　☐ ❌ 打回　备注：A6 schema + A7 命名对齐脚本验证随 C1 补齐（`scripts/check_component_quality.py`）

---

## 五、④ API 测试用例（阶段 2 定义 · 阶段 3 执行）

> 覆盖属性取值、事件回调、契约 schema。门禁 C 执行，结果随 PR 提交。

| # | 用例 | 前置 | 步骤 | 预期 | 双端 | 结果 |
|---|------|------|------|------|------|------|
| A1 | 属性-默认值 | — | 仅传 src 渲染 | 默认值生效：fit=fill、position=center、radius=0、loading/error 占位=默认样式 | iOS+Android | ☐ |
| A2 | 属性-自定义 | — | 传入 fit/position/width/height/radius/alt | 各项按传入值生效，双端一致 | iOS+Android | ☐ |
| A3 | 事件-回调 | — | 触发点击 / 加载成功 / 加载失败 | onTap/onLoad/onError 分别触发，回调签名正确、次数正确 | iOS+Android | ☐ |
| A6 | 契约-schema | api.json | 校验脚本 | props/events/methods 字段合法（质量脚本保留位，无测试函数） | CI | ☐ |
| A7 | 契约-命名对齐 | api.json | 双端对照 | 双端 props/events 命名 100% 一致（质量脚本保留位，无测试函数） | CI | ☐ |

> **编号说明（2026-09-03 C1）**：用例 ID 与 `scripts/check_component_quality.py` 的脚本保留位对齐（Cell 组件惯例）：**D6=Token 硬编码扫描、A6=契约 schema、A7=命名对齐** 三项由质量脚本自动执行、不要求双端测试函数；本组件 API 行为用例仅 A1–A3 三项（原表格第四/五行「契约-schema、契约-命名对齐」已分别上移为 A6/A7；原「token-零硬编码」并入 D6；原「无障碍-占位语义」并入 D5/D7 预期）。失败态测试 `test_D7_errorState` 等与点击/无障碍测试 `test_D8_tapEvent` 等双端同名。用例「结果」列 ☐ 为最终验收标记（含 C1.5 实机）；C1 单测层通过情况见「七、验收记录」C1 行（2026-09-03 ✅：Android Robolectric 全量绿 + 脚本门禁 4/4）。

---

## 六、⑤ 效果查看（Demo Showcase · 阶段 3.5 · 门禁 C1.5，实现后填写）

> 演示点：① 基础（本地图 + 显式尺寸 + radius 圆角/圆形头像）② fit 五模式同屏对比（同一图换 fit，可看清拉伸/裁剪/留白差异）③ loading/error 占位（模拟慢源与无效源，加载失败可点重载演示）④ 事件反馈（onTap 点击反馈条显示「点击了第 N 张」）。双端 demo 各一张卡片，场景一一对应。

| 端 | 操作 | 查看内容（演示点） |
|----|------|-------------------|
| Android | Android Studio 打开 `demo/android` 运行 app，首页 → Image 区 | ① ② ③ ④ |
| iOS | Xcode 打开 `demo/ios/ZhiqihuayunDemo.xcodeproj`，Demo 首页 → basic → Image 图片 | ① ② ③ ④ |

**实机确认（门禁 C1.5）结论：** ☐ ✅ 通过　☐ ❌ 打回　备注：

---

## 七、验收记录

| 日期 | 门禁 | 结论 | 备注（验证版本） |
|------|------|------|------|
| 2026-09-03 | A 设计评审 | ✅ 通过 | 评审单 `docs/验收流程/review-image-A.md`；设计规格 `image-design-spec.html`；组件库 v1.2.1 基线；P1=B URL 业务预下载 / P2=B lazy 一期 N/A / P3=A 圆形=radius=宽/2 / P4=B 失败仅 onError |
| 2026-09-03 | B API 评审 | ✅ 通过 | 用户表决冻结 `ui.image`（props 9 + events 3）为准绳；subcategory=display；契约 `docs/api.json` |
| 2026-09-03 | C1 自测对齐（单测+快照+用例映射） | ✅ 完成（C1 出口=单测全绿+脚本门禁全绿；C1.5 实机待办） | 双端实现（iOS Image.swift / Android Image.kt）+ 用例重排对齐脚本保留位；Android Robolectric 全量 50/50 绿（ImageTest 20 + CellTest 15 + ConfigProviderTest 15，含 Cell D5 回归修复）；质量门禁 Cell/Image 各 4/4；像素采样因 Robolectric 窗口捕获不产帧移除、几何以纯函数+实机 C1.5 覆盖；版本 bump v1.3.0 |
|  | C1.5 Demo Showcase + 实机确认 | 通过 / 打回 | 双端 demo + 用户实机确认 |
|  | C1.5 Demo Showcase + 实机确认 | 通过 / 打回 | 双端 demo + 用户实机确认 |
|  | C2 CR + CI | 通过 / 打回 |  |
|  | 发版 | 版本号 / tag |  |
|  | D 业务落地 | 接入成功 / 回退 | 接入位置 / 代码量变化，见 `docs/usage-image.md` |
