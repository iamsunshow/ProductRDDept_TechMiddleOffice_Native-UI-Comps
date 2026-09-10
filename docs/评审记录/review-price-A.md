# Price 价格 · 门禁 A 评审单（信息展示区组件 #72 · 全新立项）

> 组件 ID：`ui.price` ｜ 设计规格：`design-spec/price-design-spec.html`
> 评审方式：🖊 AI 代评（用户 2026-09-04 总授权"除特色组件外所有组件评审文档全部生成，中间任何询问直接通过"）
> 评审日期：2026-09-11 ｜ 终核：并入用户 C1.5 Demo 实机验收

## 评审清单

| # | 项 | 判定 | 说明 |
| - | -- | --- | --- |
| A1 | 组件边界（SCQA） | ✅ | 定位=商品/订单/账本等场景的金额展示，由「前缀+符号+整数+小数+后缀」组成的行内价格；与 Badge #64（提醒徽标）划界=Price 是金额数字本身无胶囊背景；与 Tag #37（状态标签）划界=Price 无背景胶囊；与 InputNumber #44（数字输入）划界=Price 纯展示不可编辑；与 CountDown #60（倒计时）划界=Price 静态金额（数字动画=二期）；双端纯从零（全仓无 PriceView/Price.kt） |
| A2 | Token 零硬编码 | ✅ | 价格主色 AppColor.error；整数 sizeXl(22) Bold；符号/小数 sizeSm(14) Semibold；size lg=sizeDisplay(32)/sizeLg(16)；size sm=sizeMd(16)/sizeXs(12)；前后缀 sizeXs + textSecondary；段间 AppSpace.xs(4)；全走 token |
| A3 | 决策投票表（ACE） | ✅ | P1-A price=number 数值驱动（B 字符串淘汰=组件做不了千分位/小数位）；P2-A thousands=true + decimal-places=2 默认（B 不格式化淘汰=金额可读性差）；P3-A 符号独立 symbolSize + symbolPosition front/after（B 同字号淘汰=符号突兀）；P4-A prefix/suffix 自定义文本（B 仅 symbol 淘汰=组合文案要业务外拼） |
| A4 | Demo 排查 4 组 | ✅ | D1 基础价格（price=199，默认两位小数、符号前置、danger 红）；D2 千分位+小数位（12345.678→12,345.68；decimal-places=0 无小数）；D3 符号大小/位置（size lg 大整数；after 后缀「元」；size sm）；D4 前缀/后缀（prefix「到手价」+ suffix「起」；suffix「/月」） |
| A5 | 实现现状 | ✅ | iOS SharedUI/Components 无 PriceView.swift=未实现；Android sharedui/components 无 Price.kt=未实现；api.json 无 ui.price 条目待门禁 B 立项登记；Demo 列表已登记 planned=true 待改 reviewed=true 挂 demo |
| A6 | 平台差异表 | ✅ | 表内放行：容器（UIStackView horizontal vs Row）、baseline 对齐（lastBaselineAnchor vs Alignment.Bottom）、千分位格式化（NumberFormatter vs 手动插逗号，结果一致）、price 类型（Double 一致）；视觉一致放行 |
| A7 | anti_goals 反目标 | ✅ | 数字滚动动画=二期增量（一期静态展示已够用）；自定义货币格式（地区/币种符号映射）=二期；可编辑=Price 纯展示不做输入；内置优惠划线价=二期（业务可叠加 Strikethrough） |

## 评审结论

| 项 | 内容 |
| -- | --- |
| 结论 | ✅ 通过（P1–P4 全选最优，0 保留意见） |
| 用户签字 | （终核并入用户 C1.5 Demo 实机验收） |
| 下一步 | 门禁 B api.json ui.price 契约登记 → 双端独立组件实现（PriceView.swift / Price.kt）→ Demo 双端 1:1 四段 → C1.5 demo 实机 → C1 单测 → C2/D |
