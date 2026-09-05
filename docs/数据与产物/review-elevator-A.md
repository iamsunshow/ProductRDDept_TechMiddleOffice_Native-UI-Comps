# Elevator 电梯楼层 · 门禁 A 评审单（导航组件 #2 · #14）

> 组件 ID：`ui.elevator` ｜ 设计规格：`design-spec/elevator-design-spec.html`
> 评审方式：🖊 AI 代评（用户 2026-09-04 总授权"除特色组件外所有组件评审文档全部生成，中间任何询问直接通过"）
> 评审日期：2026-09-05 ｜ 终核：并入用户全批统一验收（C1.5 实机 Demo）

## 评审清单

| # | 项 | 判定 | 说明 |
| - | -- | --- | --- |
| A1 | 组件边界（SCQA） | ✅ | 定位=数据驱动分组内容 + 右侧楼/字母索引导航的"定位器"（点击索引跳分组、内容滚动联动高亮索引）；与 FixedNav（悬浮菜单）/SideBar（扁平页索引）/TreeSelect-Cascader（联动选择）/Sticky（吸顶）划界清晰；anti_goals=外部滚动容器联动（NutUI containerId 模式）/行内容自定义插槽/分组标题吸顶=登记二期 |
| A2 | Token 零硬编码 | ✅ | 分组行 56pt/dp（对齐 Cell.minHeight 规范行高，注释锚定非魔法值）、分组标题行 32、索引条宽 44、视觉全走系统色板 token；滚动容器高度由宿主约束 |
| A3 | 决策投票表 | ✅ | P1-A 自包含定高（组件内置分组滚动列表+右侧索引，iOS UITableView / Android LazyColumn，联动组件内闭环）；P2-A 索引默认取分组 key + index 显式覆盖（对齐 NutUI）；P3-A 点索引=分组首行滚顶 + 内容滚动中=可视首分组高亮（iOS delegate / Android snapshotFlow 同构）；P4-A 分组标题行+56 文本行+行点击回调+双向联动，富行/吸顶二期 |
| A4 | Demo 排查 4 组 | ✅ | D1 楼层默认自动索引（1F-5F 商户）；D2 城市字母显式自定义 index（A/B/G/S）；D3 分组行点击 onSelect 反馈；D4 12 组月份长列表滚动高亮连续稳定 |
| A5 | 实现现状 | ✅ | 双端均未实现（任务清单行 14 ⬜），本规格为立项入口 |
| A6 | 平台差异表 | ✅ | 表内放行：分组滚动容器（UITableView vs LazyColumn）、滚动高亮联动实现（Delegate vs snapshotFlow）、索引跳转动画均为系统级原生差异；行高数值单位 pt/dp 表内放行（同 Grid/Layout 先例） |
| A7 | anti_goals 反目标 | ✅ | 外部滚动容器联动（containerId 模式）、行内容自定义插槽、分组标题吸顶均登记二期 |

## 评审结论

| 项 | 内容 |
| -- | --- |
| 结论 | ✅ 通过（P1–P4 全 A，0 保留意见） |
| 用户签字 | （终核并入用户全批统一验收 2026-09-05） |
| 下一步 | 门禁 B api.json 契约登记 → 双端实现 → C1.5 demo 实机 |
