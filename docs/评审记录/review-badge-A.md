# Badge 徽标 · 门禁 A 评审单（任务清单 #45 · 全新立项）

> 组件 ID：`ui.badge` ｜ 设计规格：`design-spec/badge-design-spec.html`
> 评审方式：🖊 AI 代评（用户 2026-09-04 总授权"除特色组件外所有组件评审文档全部生成，中间任何询问直接通过"，操作反馈区 #44 ActionSheet 收编后用户原话「继续下一个组件的评审和开发」指示接棒）
> 评审日期：2026-09-07 ｜ 终核：并入用户 C1.5 Demo 实机验收

## 评审清单

| # | 项 | 判定 | 说明 |
| - | -- | --- | --- |
| A1 | 组件边界（SCQA） | ✅ | 定位=展示在图标/头像/容器右上角的数字或圆点提醒（纯展示型内容组件）；与 Tag #15（行内标签流式布局）划界=Badge 锚点浮层；与 NoticeBar #51（横向公告条）划界=Badge 角标；与 Toast #59（居中短暂浮层）划界=Badge 持久角标；双端纯从零（全仓无 BadgeView/Badge.kt） |
| A2 | Token 零硬编码 | ✅ | 圆点 8×8 radiusFull danger；数字徽标 minWidth18 height18 paddingH6 radiusFull danger 底白字 11 Semibold；文本徽标 height18 paddingH8；锚点默认 top-4/right-4；全走 token |
| A3 | 决策投票表 | ✅ | P1-A 单一 content 参数自动推断形态（count/text/dot 三参数覆盖圆点/数字/文本，B 显式 type 淘汰=参数冗余/C 三组件淘汰=维护成本高）；P2-B wrapper 模式（宿主嵌套 Badge{content}，定位内部化，A 独立组件淘汰=使用方需写绝对定位/C Modifier 扩展淘汰=iOS 无等效）；P3-A count=0 不渲染（B 灰0淘汰=视觉噪音/C 圆点淘汰=语义不清）；P4-A 一期=圆点/数字/文本+maxCount+color+offset+wrapper+demo四段（动画/滚动=二期） |
| A4 | Demo 排查 4 组 | ✅ | D1 数字徽标锚点（邮箱图标右上角「3」）；D2 超上限 99+（铃铛右上角「99+」）；D3 圆点形态（聊天图标右上角红点）；D4 文本徽标+色变（星标右上角「新」+success 绿/primary 蓝变体） |
| A5 | 实现现状 | ✅ | iOS SharedUI/Components 无 Badge 封装=未实现；Android sharedui/components 无 Badge=未实现；业务角标宿主自绘未沉淀=双端纯从零；api.json 无 ui.badge 条目待门禁 B 立项登记；任务清单 #45 ⬜→本规格=双端通用徽标立项入口 |
| A6 | 平台差异表 | ✅ | 表内放行：锚点布局（UIStackView subview vs Box+offset）、圆角（layer.cornerRadius vs RoundedCornerShape 50）；数字截断逻辑一致无差异 |
| A7 | anti_goals 反目标 | ✅ | 动画弹出/数字滚动=二期增量；点击交互=Badge 纯展示点击宿主承载；自定义形状=二期；内置宿主图标=Badge 只负责徽标本体宿主内容调用方提供 |

## 评审结论

| 项 | 内容 |
| -- | --- |
| 结论 | ✅ 通过（P1–P4 全 A，0 保留意见） |
| 用户签字 | （终核并入用户 C1.5 Demo 实机验收） |
| 下一步 | 门禁 B api.json ui.badge 契约登记 → 双端独立组件实现（BadgeView.swift / Badge.kt）→ Demo 双端 1:1 → C1.5 demo 实机 → C1 单测 → C2/D |
