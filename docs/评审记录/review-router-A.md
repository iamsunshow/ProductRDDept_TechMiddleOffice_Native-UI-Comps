# Router 应用路由 · 门禁 A 评审单（任务清单 #92 · 未评审组件补齐批）

> 组件 ID：`foundation.router` ｜ 设计规格：`design-spec/router-design-spec.html`
> 评审方式：🖊 AI 代评（用户 2026-09-04 总授权；2026-09-14「2.0的组件本次不开发，优先开发未评审的组件」指示接棒）
> 评审日期：2026-09-14 ｜ 组件库版本：v1.4.0 ｜ 终核：并入用户 C1.5 Demo 实机验收

## 评审清单

| # | 项 | 判定 | 说明 |
| - | -- | --- | --- |
| A1 | 组件边界（SCQA） | ✅ | 定位=应用内导航机制唯一出口（Tab 切换 + push/pop + 路由表集中声明 + 目标页宿主注入）；与 NavBar #17/Tabbar #19/Tabs #20/SideBar #18 划界=那些是导航 UI，Router 不含任何导航 UI、只被它们调用；与业务页构造划界=由宿主注入（provider / NavGraph）；与 Deep Link 划界=二期 |
| A2 | Token 零硬编码 | ✅ | 本组件为纯逻辑层（无视觉输出），无 token 依赖；占位页使用 <code>AppColor.bgPage</code>/<code>AppFont.sizeMd</code> 令牌，无字面量 |
| A3 | 决策投票表 | ✅ | P1-A 路由集中声明（iOS <code>Destination</code> 枚举 / Android <code>SecondaryRoutes</code> 常量）；P2-A 目标页由宿主注入（保证中台包零业务依赖、可独立编译）；P3-A 参数内嵌路由（<code>transaction_detail/{recordId}</code> + 可选年月）；P4-A 一期=Tab 切换+push/pop+兜底占位+Demo 4 段 |
| A4 | Demo 排查 4 组 | ✅ | D1 路由表总览（一级 5 Tab + 二级示例）/ D2 一级 Tab 切换请求 / D3 二级 push 请求 + 返回 / D4 未登记标题兜底占位。**采用内层路由状态机回显**，不真 push 进 Demo 宿主栈（避免污染组件库 Demo 导航栈） |
| A5 | 实现现状 | ✅ | iOS `ios/Foundation/Routing/AppRouter.swift`（195 行：provider 注入 + Tab(5) + Destination(18) + selectTab/open/openIncome/openExpense/push + NativePlaceholderViewController，已实现）；Android `android/foundation/routing/AppRouter.kt`（54 行：open(title)/push/pop/popUpToProfileRoot/selectTab）+ `Routes.kt`（47 行：MainDestination 5 + SecondaryRoutes 26 + 构造函数，已实现）；api.json 有 `foundation.router` 条目但缺 `reviewed`/`subcategory`。**双端已实现，缺口=门禁 A 评审 + Demo 展示页 + 状态收编** |
| A6 | 平台差异表 | ✅ | 表内放行：导航容器（UINavigationController/UITabBarController vs NavHostController）、目标页解析（协议注入返回 UIViewController? vs NavGraph 注册 Composable）、路由标识（枚举 vs 字符串常量）、Tab 状态保留（系统天然保留 vs 显式 saveState/restoreState）、入口签名（open(_,from:) vs open(title:)）。均语义一致，差异源于平台原生导航体系 |
| A7 | anti_goals 反目标 | ✅ | Deep Link/URL Scheme/推送唤起=二期；路由拦截器/登录守卫=二期；转场动画定制=二期；路由可视化调试面板=非一期目标 |

## 评审结论

| 项 | 内容 |
| -- | --- |
| 结论 | ✅ 通过（P1–P4 全 A，0 保留意见） |
| 用户签字 | （终核并入用户 C1.5 Demo 实机验收） |
| 下一步 | 双端 Demo（RouterShowcase / RouterDemo 4 段 1:1）→ api.json 补 reviewed+subcategory → demo 注册行 planned→reviewed → C1.5 验收 |
