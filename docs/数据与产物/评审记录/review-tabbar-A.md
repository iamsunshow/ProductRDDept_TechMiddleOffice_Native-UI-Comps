# Tabbar 标签栏 · 门禁 A 评审单（导航组件 #6 · #19）

> 组件 ID：`ui.tabbar` ｜ 设计规格：`design-spec/tabbar-design-spec.html`
> 评审方式：🖊 AI 代评（用户 2026-09-04 总授权"除特色组件外所有组件评审文档全部生成，中间任何询问直接通过"）
> 评审日期：2026-09-05 ｜ 终核：并入用户全批统一验收（C1.5 实机 Demo）

## 评审清单

| # | 项 | 判定 | 说明 |
| - | -- | --- | --- |
| A1 | 组件边界（SCQA） | ✅ | 定位=页面底部常驻横向 2–5 项一级主导航标签条（icon+文字，点击跨页切换+激活持久高亮+回传 onChange）；与 Tabs（页内顶部内容切换）/NavBar（顶部标题导航）/SideBar（左侧目录轨）/FixedNav（悬浮面板多入口）/HoverButton（悬浮单钮）/BackTop（滚动回顶）全部划界；anti_goals=页面容器/路由一体（宿主自理）、中间凸起按钮、自定义整项插槽、系统 Icon 映射、红点 dot、安全区自避让=登记二期 |
| A2 | Token 零硬编码 | ✅ | 栏高默认 56（≥48 宿主可覆盖，锚定行业 iOS UITabBar 49/Material 56）、icon 字符 22=sizeXl、icon–文字间距 xs、文字 Xs=12、激活主色加粗/默认次色、角标高 16 圆角 full、禁用 40% 透明度；全走 token 与注释锚定非魔法值；激活色默认 AppColor.primary 可 activeColor 覆盖（品牌色场景）；同 FixedNav/SideBar 导航激活同族基线 |
| A3 | 决策投票表 | ✅ | P1-A 纯底部标签条数据驱动（页面路由宿主自理，B/C 系统容器淘汰）；P2-A TabBarItem(title,value,icon?,badge?,disabled) 数据驱动（children/纯字符串淘汰）；P3-A 半受控选中（默认首启用项自管理 + selectedValue 外部驱动 + 幂等 + 禁用无动作）；P4-A 一期=等分标签条+icon+角标数字+禁用+单行省略+activeColor 覆盖+demo 四段（凸起按钮/插槽/dot/动画/安全区自避让二期） |
| A4 | Demo 排查 4 组 | ✅ | D1 基础 5 项选中持久高亮+切换幂等（计数回显）；D2 角标数字 3+禁用项置灰不可点；D3 纯文字项垂直居中+长标题省略+activeColor 红色覆盖；D4 受控外部驱动（栏外按钮跳转 tab 高亮同步、点已激活不触发回调） |
| A5 | 实现现状 | ✅ | 双端均未实现（任务清单行 19 ⬜，api.json 无 ui.tabbar 条目待立项），本规格为立项入口 |
| A6 | 平台差异表 | ✅ | 表内放行：点击按压反馈（iOS touchDown 压暗 vs Android 系统 ripple）、等分实现（UIStackView fillEqually vs Row weight 1f）、文字省略截断、栏顶 hairline（iOS 1/scale pt vs Android 0.5dp）为系统级原生差异；尺寸数值 pt/dp 与数据模型命名=表内放行（同全库先例） |
| A7 | anti_goals 反目标 | ✅ | 页面容器/路由一体、中间凸起大按钮、自定义整项插槽、系统 Icon 资源映射、红点 dot、切换动画、底部安全区自动避让=全部登记二期/宿主（安全区一期宿主叠 SafeArea 处理，同 FixedNav/HoverButton 位置宿主锚定先例） |

## 评审结论

| 项 | 内容 |
| -- | --- |
| 结论 | ✅ 通过（P1–P4 全 A，0 保留意见） |
| 用户签字 | （终核并入用户全批统一验收 2026-09-05） |
| 下一步 | 双端实现 + Demo 双端 1:1 → api.json 契约登记（available，reviewed=false）→ C1.5 demo 实机 → C1 单测 → C2/D |
