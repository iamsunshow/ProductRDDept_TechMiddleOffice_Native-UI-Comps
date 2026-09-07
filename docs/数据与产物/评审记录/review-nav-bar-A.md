# NavBar 头部导航 · 门禁 A 评审单（任务清单 #17 · 收编缺口补独立立项）

> 组件 ID：`ui.nav-bar` ｜ 设计规格：`design-spec/nav-bar-design-spec.html`
> 评审方式：🖊 AI 代评（用户 2026-09-04 总授权"除特色组件外所有组件评审文档全部生成，中间任何询问直接通过"）
> 评审日期：2026-09-05 ｜ 终核：并入用户全批统一验收（C1.5 实机 Demo）

## 评审清单

| # | 项 | 判定 | 说明 |
| - | -- | --- | --- |
| A1 | 组件边界（SCQA） | ✅ | 定位=页面顶部单行头部导航条：可选返回钮 + 居中标题 + 可选右侧动作，onBack/onAction 回传；页面内容与导航栈/转场宿主自理；与 Tabbar（底部跨页）/Tabs（页内页签）/SideBar/FixedNav/HoverButton 划界；anti_goals=沉浸透明/双动作/大标题/插槽化复合头/系统导航栈容器联动/状态栏 inset 内置=登记二期 |
| A2 | Token 零硬编码 | ✅ | 内容行高 44（对齐 iOS UINavigationBar 标准 44 / Android ScreenTopBar 现状 44，宿主可覆盖）、标题 Lg=18 Semibold textPrimary 单行省略、返回字形 22=sizeXl 主色 primary、右动作文字 sizeSm=14、白底 bgCard + 行底 hairline；全走 token 与注释锚定非魔法值 |
| A3 | 决策投票表 | ✅ | P1-A 纯顶部导航条收编升级（ScreenTopBar 业务近似→库内独立组件，同 Grid v2.0 NavigationGrid→Grid 先例；系统容器/复合功能头淘汰）；P2-A 声明式单参数 NavBar(title, onBack?, rightAction?)（children 插槽/全配置对象淘汰）；P3-A 命令式无状态语义（点击即回调，顶栏无选中态无需受控幂等；自动 pop 导航栈宿主自理）；P4-A 一期=title+返回+右单动作+长标题省略+白底 hairline+demo 四段（沉浸/双动作/大标题/插槽/inset 内置二期） |
| A4 | Demo 排查 4 组 | ✅ | D1 基础返回+标题（onBack 回调计数回显）；D2 一级页无返回（onBack=nil 返回位不占宽标题纯居中）；D3 右侧动作保存（onAction 回调计数回显、与返回计数分开）；D4 长标题单行省略+短标题对照组 |
| A5 | 实现现状 | ✅ | 收编近似=Android ScreenTopBar（sharedui/components/CommonComponents.kt 页面内嵌 scaffold 共享件，非独立组件）+ iOS 无独立 NavBar（业务用系统 UINavigationBar）；api.json 无 ui.nav-bar 条目待立项登记；任务清单 #17 ✅ 收编状态，本规格=补独立组件立项入口 |
| A6 | 平台差异表 | ✅ | 表内放行：点击按压反馈（iOS touchDown 压暗 vs Android 系统 ripple）、行底 hairline（iOS 1/scale pt vs Android 0.5dp）、文字省略截断、标题严格居中实现（UIStackView 等宽占位/centerX vs Box align(Center)/weight 对称占位）为系统级原生差异；尺寸数值 pt/dp 与数据模型命名=表内放行（同全库先例） |
| A7 | anti_goals 反目标 | ✅ | 沉浸透明渐变、左右双动作、多行/大标题、插槽化复合功能头、系统导航栈容器联动（自动 pop/finish）、状态栏 inset 组件内内置=全部登记二期/宿主（inset 宿主叠 SafeArea，同 Tabbar 底部安全区宿主处理先例） |

## 评审结论

| 项 | 内容 |
| -- | --- |
| 结论 | ✅ 通过（P1–P4 全 A，0 保留意见） |
| 用户签字 | （终核并入用户全批统一验收 2026-09-05） |
| 下一步 | 门禁 B api.json 契约登记 → 双端独立组件实现（NavBar.swift / NavBar.kt，业务 ScreenTopBar 语义对齐不强制迁移）→ Demo 双端 1:1 → C1.5 demo 实机 → C1 单测 → C2/D |
