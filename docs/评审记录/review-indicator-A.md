# Indicator 指示器 · 门禁 A 评审单（任务清单 #69 · 全新立项）

> 组件 ID：`ui.indicator` ｜ 设计规格：`design-spec/indicator-design-spec.html`
> 评审方式：🖊 AI 代评（用户 2026-09-04 总授权"除特色组件外所有组件评审文档全部生成，中间任何询问直接通过"）
> 评审日期：2026-09-11 ｜ 终核：并入用户 C1.5 Demo 实机验收

## 评审清单

| # | 项 | 判定 | 说明 |
| - | -- | --- | --- |
| A1 | 组件边界（SCQA） | ✅ | 定位=页面位置指示器——圆点/数字形态标记当前页与总页数（纯展示型内容组件）；与 Carousel #59（轮播容器自带可选指示器）划界=Indicator 独立原子可被内嵌或独立使用；与 Pagination #71（可点击翻页器）划界=Indicator 纯展示不可点；与 Badge #45（角标徽标）划界=位置序列点非角标；与 Steps（流程节点强结构）划界=轻量圆点序列；双端纯从零（全仓无 IndicatorView/Indicator.kt） |
| A2 | Token 零硬编码 | ✅ | 圆点 6×6 radiusFull gray15；选中圆点 6×6 radiusFull primary；长条 15×6（size×2.5）radiusSm primary；数字胶囊 paddingH10 radiusFull primary 底白字 12 Semibold；间距 gap 8dp；全走 token |
| A3 | 决策投票表 | ✅ | P1-A showNumber 布尔切换圆点/数字两形态（B 枚举淘汰=参数冗余/C 多组件淘汰=维护成本高）；P2-C block 开关同时支持色变+长条（block=false 默认色变最简，block=true 长条更醒目，双模式覆盖轮播+引导页）；P3-B 横向+竖向 direction 参数（竖向场景存在=竖向轮播/分步表单侧边指示）；P4-A 一期=圆点/数字+横向/竖向+block长条+自定义色/大小/间距+demo四段（动画/点击=二期） |
| A4 | Demo 排查 4 组 | ✅ | D1 基础指示器（横向 5 点·第 2 高亮·色变）；D2 数字总页数（showNumber 胶囊「2/5」）；D3 竖向指示器（direction=vertical·4 点·第 2 高亮）；D4 自定义样式（block 长条+success 绿+size 8） |
| A5 | 实现现状 | ✅ | iOS SharedUI/Components 无 Indicator 封装=未实现；Android sharedui/components 无 Indicator=未实现；api.json 无 ui.indicator 条目待门禁 B 立项登记；任务清单 #69 ⬜→本规格=双端通用指示器立项入口 |
| A6 | 平台差异表 | ✅ | 表内放行：排布容器（UIStackView vs Row/Column）、圆角（layer.cornerRadius vs CircleShape/RoundedCornerShape）；长条形态与数字胶囊逻辑一致无差异 |
| A7 | anti_goals 反目标 | ✅ | 点击跳转=纯展示位置跳转由容器承载二期增量；动画过渡=二期增量一期静态切换；自定义渲染插槽=二期一期只做圆点/数字；自动跟随容器=不绑定容器 current/total 由调用方驱动解耦 |

## 评审结论

| 项 | 内容 |
| -- | --- |
| 结论 | ✅ 通过（P1–P4 全 A/C，0 保留意见） |
| 用户签字 | （终核并入用户 C1.5 Demo 实机验收） |
| 下一步 | 门禁 B api.json ui.indicator 契约登记 → 双端独立组件实现（IndicatorView.swift / Indicator.kt）→ Demo 双端 1:1 → C1.5 demo 实机 → C1 单测 → C2/D |
