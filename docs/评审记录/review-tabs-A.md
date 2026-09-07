# Tabs 选项卡 · 门禁 A 评审单（任务清单 #20 · 收编缺口补独立立项）

> 组件 ID：`ui.tabs` ｜ 设计规格：`design-spec/tabs-design-spec.html`
> 评审方式：🖊 AI 代评（用户 2026-09-04 总授权"除特色组件外所有组件评审文档全部生成，中间任何询问直接通过"）
> 评审日期：2026-09-05 ｜ 终核：并入用户全批统一验收（C1.5 实机 Demo）

## 评审清单

| # | 项 | 判定 | 说明 |
| - | -- | --- | --- |
| A1 | 组件边界（SCQA） | ✅ | 定位=页内顶部内容切换页签条（2–6 项等分，点选切换页内内容块 + 激活主色加粗 + 底部 2 主色指示线 + onChange）；内容面板由宿主渲染；与 Tabbar（底部跨页一级导航）/NavBar（顶部标题条）/SideBar（左目录轨）/Segmented（无内容面板语义）划界；anti_goals=横向滚动/滑动切换/内容面板内置/懒加载/icon 页签/dot/动画=登记二期 |
| A2 | Token 零硬编码 | ✅ | 条高 44、文字 Sm=14 激活主色加粗/默认次色、指示线 2 主色、禁用 40%、单行省略；全走 token 与注释锚定非魔法值；激活色默认 AppColor.primary 可 activeColor 覆盖（品牌色场景） |
| A3 | 决策投票表 | ✅ | P1-A 纯顶部页签条收编升级（内容面板宿主自理，B 内置容器与 C 系统 TabLayout/UISegmented 淘汰）；P2-A TabItem(title,value,disabled) 数据驱动（children/纯字符串淘汰）；P3-A 半受控选中（默认首启用自管理 + selectedValue 外部驱动 + 幂等 + 禁用无动作）；P4-A 一期=等分页签+主色激活指示线+禁用+单行省略+activeColor+demo 四段（滚动/滑动/懒加载/icon/dot/动画二期） |
| A4 | Demo 排查 4 组 | ✅ | D1 基础 3 页签（支出/收入/转账）选中持久+切换幂等（计数回显）；D2 禁用页签（全部=disabled 40% 不可点）；D3 长标题省略不破坏等分；D4 受控外部驱动（外部赋值 selectedValue → 高亮同步、点已激活不触发回调） |
| A5 | 实现现状 | ✅ | 收编近似=iOS TabsView/PeriodTabsView（SharedUI/Components，业务"周月年/双 Tab"切换，固定 200 宽居中 32 高胶囊形态，语义更近 Segmented #74）+ Android 未实现独立 Tabs；api.json 无 ui.tabs 条目待立项登记；任务清单 #20 ✅ 收编状态，本规格=补独立组件立项入口（iOS 旧收编 TabsView 组件化替换为独立 Tabs） |
| A6 | 平台差异表 | ✅ | 表内放行：点击按压反馈（iOS touchDown 压暗 vs Android 系统 ripple）、等分实现（UIStackView fillEqually vs Row weight 1f）、文字省略截断、指示线实现（iOS 2pt UIView vs Android 2dp Box offset）为系统级原生差异；尺寸数值 pt/dp 与数据模型命名=表内放行（同全库先例） |
| A7 | anti_goals 反目标 | ✅ | 横向滚动式 Tabs（>6 项）、滑动切换内容、内置内容面板容器、懒加载、icon 型页签、红点 dot、激活指示线横移动画=全部登记二期（内容面板=宿主渲染） |

## 评审结论

| 项 | 内容 |
| -- | --- |
| 结论 | ✅ 通过（P1–P4 全 A，0 保留意见） |
| 用户签字 | （终核并入用户全批统一验收 2026-09-05） |
| 下一步 | 门禁 B api.json 契约登记 → 双端独立组件实现（TabsView.swift 组件化替换旧收编 TabsView / Tabs.kt，Android 新建）→ Demo 双端 1:1 → C1.5 demo 实机 → C1 单测 → C2/D |
