# AnimatingNumbers 数字动画 · 门禁 A 评审单（信息展示区组件 #61 · 全新立项）

> 组件 ID：`ui.animating-numbers` ｜ 设计规格：`design-spec/animating-numbers-design-spec.html`
> 评审方式：🖊 AI 代评（用户 2026-09-04 总授权「除特色组件外所有组件评审文档全部生成，中间任何询问直接通过」）
> 评审日期：2026-09-14 ｜ 终核：并入用户 C1.5 Demo 实机验收
> 立项依据：用户 2026-09-14「继续开发组件库的组件吧」（库内常规待开发件归零后启动 v2.0 首件；Price #72 规格第 2 节已登记「数字动画=二期」即本件）

## 评审清单

| # | 项 | 判定 | 说明 |
| - | -- | --- | --- |
| A1 | 组件边界（SCQA） | ✅ | 定位=数值变化时以逐位滚动动画展示过渡过程的展示型组件，`value` 数值驱动；与 Price #72 划界=Price 静态排版（符号/前后缀/小数位）不含动画、本件只滚数字且不排货币符号（组合用法已写明）；与 CountDown #60 划界=CountDown 按时间戳自驱每秒刷新、本件值驱动一次性过渡；与 Progress #74/CircleProgress #58 划界=进度件以长度/角度表达比例；与 InputNumber #44 划界=纯展示不可交互；与 Skeleton #53 划界=骨架无真实数值；双端纯从零（全仓无 AnimatingNumbers 实现） |
| A2 | Token 零硬编码 | ✅ | 字号 medium=AppFont.sizeLg(18)（恰好对齐 NutUI base-size 18px）/ 窗口高 32 注释锚定（=交互行基准 48 的 2/3）；small=AppFont.sizeSm(14)/高 24；large=AppFont.sizeDisplay(32)/高 48；颜色默认 AppColor.textPrimary；圆角默认 4（NutUI 原值，注释锚定=库内最小档 AppRadius.sm 为 6，本件取 4 保持数位块紧凑）；字重 Semibold；等宽数字走平台特性（iOS monospacedDigit / Android FontFeature tnum）；全走 token 或注释锚定 |
| A3 | 决策投票表（ACE） | ✅ | P1-A 复用 Price size 三档 + medium 默认 18（B 裸 fontSize 淘汰=双端易漂移且与库内档位语言脱节）；P2-A 毫秒单位（B 浮点秒淘汰=两端都要乘 1000，与 Android tween/iOS DispatchTimeInterval 毫秒惯例不符）；P3-A 值变化时全体从 0 重滚（B 就近滚动淘汰=位数增减时位错位、tween 起点随值漂移难断言）；P4-A 分隔符静态渲染不参与滚动（B 参与滚动淘汰=无意义字形穿插） |
| A4 | Demo 排查 4 组 | ✅ | D1 基础用法（value=678.94）；D2 位数+千分位+自定义色（value=1578.94、length=8、thousands=true、color=danger）；D3 动态修改数据（按钮切 1578.94→88.80→12345.67 观察重滚）；D4 尺寸/外观档位（large 32/48；small 14/24 + backgroundColor 灰底块 + cornerRadius 4）；四段均双端 1:1 |
| A5 | 实现现状 | ✅ | iOS `SharedUI/Components` 无 AnimatingNumbersView.swift=未实现；Android `sharedui/components` 无 AnimatingNumbers.kt=未实现；api.json 无 `ui.animating-numbers` 条目待门禁 B 立项登记；Demo 双端注册行已存在占位（Android `MainActivity.kt` / iOS `DemoShowcases.swift` 的 AnimatingNumbers 行，待挂 demo 实体） |
| A6 | 平台差异表 | ✅ | 表内放行：滚动驱动器（iOS UIViewPropertyAnimator 驱动 transform vs Android Animatable+graphicsLayer，起止状态与时长语义相同）；缓动曲线（两端同为 cubic-bezier(0.4,0,0.2,1)= UICubicTimingParameters vs FastOutSlowInEasing）；等宽数字（monospacedDigit vs FontFeature tnum，结果一致）；窗口结构（UIView+clipsToBounds+竖排 UILabel vs Box+clipToBounds+Column，结构同构）；单位毫秒（一致）。门禁 B 落地按此实现（规格第 6 节同步） |
| A7 | anti_goals 反目标 | ✅ | 货币符号/前后缀/小数位格式化=归 Price #72（本件只滚数字，宿主可组合）；循环播放/定时刷新=归 CountDown #60 或宿主；数字字形自定义（字体替换）=二期；滚动结束回调=一期不提供（业务无需求，宿主可按 duration 自行计时） |

## 评审结论

| 项 | 内容 |
| -- | --- |
| 结论 | ✅ 通过（P1–P4 全选最优，0 保留意见） |
| 用户签字 | （终核并入用户 C1.5 Demo 实机验收） |
| 下一步 | 门禁 B api.json `ui.animating-numbers` 契约登记 → 双端独立组件实现（AnimatingNumbersView.swift / AnimatingNumbers.kt）→ Demo 双端 1:1 四段 → 编译验证 → C1.5 demo 实机 → C1 单测（B1~B6 断言）→ C2/D |
