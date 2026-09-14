# SystemBars 系统栏 · 门禁 A 评审单（任务清单 #90 · 未评审组件补齐批）

> 组件 ID：`foundation.system-bars` ｜ 设计规格：`design-spec/system-bars-design-spec.html`
> 评审方式：🖊 AI 代评（用户 2026-09-04 总授权；2026-09-14「2.0的组件本次不开发，优先开发未评审的组件」指示接棒）
> 评审日期：2026-09-14 ｜ 组件库版本：v1.4.0 ｜ 终核：并入用户 C1.5 Demo 实机验收

## 评审清单

| # | 项 | 判定 | 说明 |
| - | -- | --- | --- |
| A1 | 组件边界（SCQA） | ✅ | 定位=按页声明系统栏外观（底色+图标明暗）；与 SafeArea #10 划界=安全区避让 vs 系统栏自身外观；与 NavBar #17 划界=页面内自绘导航条 vs 系统级状态栏；与 Sticky #12 划界=内容吸附 vs 系统栏外观 |
| A2 | Token 零硬编码 | ✅ | 默认底色取 <code>AppColor.bgCard</code>、沉浸色取 <code>AppColor.primary</code>，无字面量；Demo 亦用令牌 |
| A3 | 决策投票表 | ✅ | P1-A 双端对齐到「按页声明状态栏样式（底色+图标明暗）」；P2-A **iOS 新增轻量工具 <code>SystemBars</code>（Style 枚举 + 应用辅助）补独立出口**（现有仅 <code>StatusBarNavigationController</code> 容器委托，无组件级入口）；P3-A Android 依亮度自动判定 + iOS 显式声明；P4-A 一期=默认/沉浸/透明三态 + Demo 4 段 |
| A4 | Demo 排查 4 组 | ✅ | D1 默认态（白底深字）/ D2 沉浸态（绿底白字）/ D3 透明态（透明底深字）/ D4 联动切换（段内按钮切模式 + 实时回显当前模式） |
| A5 | 实现现状 | ✅（含缺口） | Android `android/foundation/design/SystemBars.kt`（<code>ConfigureSystemBars(statusBarColor, navigationBarColor)</code> + <code>transparentStatusBarColor()</code>，已实现）；iOS `ios/Foundation/SystemBars/StatusBarNavigationController.swift`（仅容器委托，**无组件级出口**）。api.json 现为 `ios: partial`。**缺口=iOS 需新增 <code>SystemBars.swift</code> 轻量工具后方可双端 1:1**（本轮实现，见 P2） |
| A6 | 平台差异表 | ✅ | 表内放行：状态栏背景色（iOS 系统不可设，由页面在安全区自绘等价视觉 / Android 直设）、图标明暗（iOS 显式 preferredStatusBarStyle / Android 依 luminance 自动）、导航栏（iOS 无对应 / Android navigationBarColor）、生效还原（iOS 容器委托自动 / Android DisposableEffect） |
| A7 | anti_goals 反目标 | ✅ | 随滚动渐变=二期；渐变/图片底=页面自绘；深色模式联动=二期；状态栏显隐 UI 开关=不做 |

## 评审结论

| 项 | 内容 |
| -- | --- |
| 结论 | ✅ 通过（P1–P4 全 A，0 保留意见；含 iOS 缺口补齐决策） |
| 用户签字 | （终核并入用户 C1.5 Demo 实机验收） |
| 下一步 | 实现 iOS `SystemBars.swift` 轻量工具 → 双端 Demo（SystemBarsShowcase / SystemBarsDemo 4 段 1:1）→ api.json ios partial→available + 补 reviewed → demo 注册行 planned→reviewed → C1.5 验收 |

> **⚠ 缺口补齐决策（需用户在 C1.5 时确认可见性）**：iOS 系统不提供状态栏背景色 API，故 D2「绿底白字」在 iOS 上由 Demo 页在状态栏安全区自绘绿色块实现等价视觉（观感与 Android 一致）；此差异已登记 §7 差异表，不视为缺陷。
