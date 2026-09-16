# ShortcutBar 快捷栏 · 门禁 A 评审单（任务清单 #82 · 收编缺口补独立立项）

> 组件 ID：`ui.shortcut-bar` ｜ 设计规格：`design-spec/shortcut-bar-design-spec.html`
> 评审方式：🖊 AI 代评（用户 2026-09-04 总授权"除特色组件外所有组件评审文档全部生成，中间任何询问直接通过"）
> 评审日期：2026-09-16 ｜ 终核：等用户全批统一验收（C1.5 实机 Demo）
> 组件库基线：v2.0.8（2026-09-15 releaseDate，子仓 commit a04d1a2）

## 评审清单

| # | 项 | 判定 | 说明 |
| - | -- | --- | --- |
| A1 | 组件边界（SCQA） | ✅ | 定位=页面中部横向等分入口栏：图标 28 + 文字 12 + 行高 80 + ≤6 项等分 + >6 项横滑 + 点击回调 onTap(index)；与 Tabbar（底部跨页）/Tabs（页内页签）/NavBar（顶栏）/Grid（多列固定宫格无滚动）/SideBar（左侧目录）/FixedNav·HoverButton（悬浮）划界；anti_goals=自定义图标容器样式/角标 badge/拖拽排序/滑动指示器/title 分组/children 插槽化=登记二期 |
| A2 | Token 零硬编码 | ✅ | 行高 80（含 padding 12 + 图标 28 + gap 4 + 文字 16 + padding 12 ≈ 80）、入口宽 64~parent.width/n、图标 28 圆角 6 bgPrimaryMuted + icon primary 18 自绘、文字 sizeXs=12 Regular textPrimary 单行省略、白底 bgCard + 行底 hairline + 行内 gap=12；全走 token 与注释锚定非魔法值 |
| A3 | 决策投票表 | ✅ | P1-A 横向滚动入口栏独立组件（Grid 加滚动模式/children 插槽淘汰）；P2-A 声明式数据驱动 ShortcutBar(items)+ShortcutItem{icon,label,disabled?}（children 插槽/混合 API 淘汰）；P3-A 智能切换≤6 等分 >6 横滑（永远横滑/永远等分淘汰）；P4-A 一期=数据驱动+智能横滑+disabled+行高 80+demo 四段（自定义图标/角标/拖拽/指示器二期） |
| A4 | Demo 排查 4 组 | ✅ | D1 基础 4 项等分父宽+点击回 onTap(0~3) 段内回显；D2 等分 6 项满铺父宽无横滑+点击回 onTap(0~5)；D3 横滑 8 项+末项 disabled=true 灰显不可点+点击未禁用项回 onTap(0~6)；D4 受控 disabled 切换（外部按钮运行期切 disabled+段内回显当前 disabled 项） |
| A5 | 实现现状 | ✅ | 收编近似=Android 业务 DiscoverHomeScreen 自建私有 Row/Column 拼装（非库内独立组件）；iOS 业务 MoreViewController 用 Grid + 自定义入口组合（Grid 卡片壳+title 不适用于快捷入口）；api.json 已登记 ui.shortcut-bar（行 3707）待门禁 B 立项；任务清单 #82 ⬜ 待实现，本规格=补独立组件立项入口 |
| A6 | 平台差异表 | ✅ | 表内放行：横向滚动（iOS UICollectionView horizontal vs Android LazyRow horizontalArrangement）、按压反馈（iOS touchDown 灰底 vs Android ripple）、行底 hairline（iOS 1/scale pt vs Android 0.5dp）、文字省略（iOS lineBreakMode=.byTruncatingTail vs Android overflow=Ellipsis）、等分算法（iOS itemSize vs Android Modifier.width）为系统级原生差异；尺寸数值 pt/dp 与数据模型命名=表内放行（同全库先例） |
| A7 | anti_goals 反目标 | ✅ | 自定义图标容器样式/颜色覆盖、角标 badge（如"新"红点）、拖拽排序、滑动指示器（>6 项时显示当前位置点）、title 分组（与 Grid #8 职责重叠）、children 插槽化=全部登记二期；与 Grid（多列固定）/Tabbar（底部跨页）/Tabs（页内页签）/NavBar（顶栏）严格划界 |

## 评审结论

| 项 | 内容 |
| -- | --- |
| 结论 | ✅ 通过（P1–P4 全 A，0 保留意见） |
| 用户签字 | （终核等用户审查 2026-09-16） |
| 下一步 | 门禁 B api.json ui.shortcut-bar 契约登记 → 双端独立组件实现（ShortcutBarView.swift UICollectionView horizontal / ShortcutBar.kt LazyRow horizontalArrangement，业务 LedgerShortcutBar 语义对齐不强制迁移）→ Demo 双端 1:1 → C1.5 demo 实机 → C1 单测 → C2/D |

## 附录 A · KeepAccounts 业务回填

| 项 | 内容 |
| | --- |
| 业务组件 | LedgerShortcutBar（KeepAccounts 记账主页快捷入口栏） |
| 业务侧现状 | Android `apps/android/feature/ledger/ui/LedgerHomeScreen.kt` 自建私有 Row/Column 拼装 + DiscoverHomeScreen 横向入口栏同样自建；iOS `apps/ios/Feature/Ledger/Pages/LedgerHomeViewController.swift` navBarView 嵌入 + `MoreViewController.swift` 用 Grid 入口 |
| 业务待替 | 双端 LedgerShortcutBar 切库内 ShortcutBar（数据驱动 API 1:1） |
| 库侧立项 | ui.shortcut-bar 已登记 api.json 行 3707，本规格为门禁 B 实现入口 |
| 评估文档 | KeepAccounts 评估文档 §5 行 70（2026-09-16 真实状态核对 = 双端都缺非 partial） |