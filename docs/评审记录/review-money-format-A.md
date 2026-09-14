# MoneyFormat 金额格式化 · 门禁 A 评审单（任务清单 #95 · 未评审组件补齐批）

> 组件 ID：`foundation.money-format` ｜ 设计规格：`design-spec/money-format-design-spec.html`
> 评审方式：🖊 AI 代评（用户 2026-09-04 总授权「除特色组件外所有组件评审文档全部生成」；2026-09-14 用户原话「2.0的组件本次不开发，优先开发未评审的组件」指示接棒）
> 评审日期：2026-09-14 ｜ 组件库版本：v1.4.0 ｜ 终核：并入用户 C1.5 Demo 实机验收

## 评审清单

| # | 项 | 判定 | 说明 |
| - | -- | --- | --- |
| A1 | 组件边界（SCQA） | ✅ | 定位=对外展示金额的唯一格式化出口（两位小数 / 可选 ¥ / 可选收支正负号）；与 DateFormatters 划界=金额 vs 日期；与 InputNumber #30 划界=纯展示函数 vs 可编辑输入控件；与 Price #72 划界=无样式字符串工具 vs 带样式价格控件；与业务计算划界=只格式化算好的数值，不做算术 |
| A2 | Token 零硬编码 | ✅ | 本组件为纯字符串工具，不产生任何视觉输出，无 token 依赖（无字号/颜色）；货币符号 <code>¥</code> 为产品常量非样式 token |
| A3 | 决策投票表 | ✅ | P1-A 固定两位小数（全局规范，避免账目错位）；P2-A 无千分位（对齐现有双端实现与产品稿）；P3-A 收支语义由 <code>isIncome</code> 参数映射（组件保持业务无关，颜色归消费方）；P4-A 一期=string+currency+signed+demo4段 |
| A4 | Demo 排查 4 组 | ✅ | D1 基础两位小数（string）/ D2 货币符号（currency）/ D3 收支正负号（signed 收入+支出）/ D4 边界值（0 / 负数 / 大额 / 超两位小数四舍五入） |
| A5 | 实现现状 | ✅ | iOS `ios/Foundation/Util/Formatters.swift`（<code>enum MoneyFormatter</code>，已实现）；Android `android/foundation/util/MoneyFormatter.kt`（<code>object MoneyFormatter</code>，已实现）；api.json 有 `foundation.money-format` 条目但缺 `reviewed`/`subcategory` 字段。**双端已实现，缺口=门禁 A 评审 + Demo 展示页 + 状态收编** |
| A6 | 平台差异表 | ✅ | 表内放行：格式化实现（iOS NumberFormatter(en_US_POSIX, min=max=2, groupingSeparator="") vs Android String.format(Locale.US, "%.2f")，输出逐字符一致）、兜底路径（iOS NumberFormatter 失败回退 String(format:) / Android 无兜底）。**差异风险已登记**：第三位为 5 的舍入策略双端可能不同（半偶 vs 半进位），一期以「日常金额两位以内」为界不强制统一，C1 单测须断言并登记 `diff-api.json` |
| A7 | anti_goals 反目标 | ✅ | 多币种/汇率=业务计算非格式化；千分位=产品稿明确不做；万/亿单位=二期口径未定；金额计算=不做算术 |

## 评审结论

| 项 | 内容 |
| -- | --- |
| 结论 | ✅ 通过（P1–P4 全 A，0 保留意见） |
| 用户签字 | （终核并入用户 C1.5 Demo 实机验收） |
| 下一步 | 双端 Demo 展示页（MoneyFormatShowcase / MoneyFormatDemo 4 段 1:1）→ api.json 补 reviewed+subcategory → demo 注册行 planned→reviewed → C1.5 用户实机验收 |
