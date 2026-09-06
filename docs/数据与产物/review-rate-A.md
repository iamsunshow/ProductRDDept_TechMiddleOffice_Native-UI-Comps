# Rate 评分 · 门禁 A 评审单（任务清单 #37 · 全新立项）

> 组件 ID：`ui.rate` ｜ 设计规格：`design-spec/rate-design-spec.html`
> 评审方式：🖊 AI 代评（用户 2026-09-04 总授权"除特色组件外所有组件评审文档全部生成，中间任何询问直接通过"；数据录入区 #36 range 收编后下一件，用户 2026-09-06 原话「通过，继续下一个组件吧」指示接棒启动）
> 评审日期：2026-09-06 ｜ 终核：并入用户 C1.5 Demo 实机验收

## 评审清单

| # | 项 | 判定 | 说明 |
| - | -- | --- | --- |
| A1 | 组件边界（SCQA） | ✅ | 定位=行内 n 颗自绘五角星形整数评分点（默认 5）：值=已点亮整星数 Int 0~count（0=未评合法态）、点击某颗=点亮并回调、再点当前值同一颗=清空归 0（评价可取消=allowClear 语义）、横向滑动=连续点亮/收回松手定值、半受控 value+count+readonly（只读彩色展示评分）+disabled（灰 40%）+onChange、无 label/文案/提交=宿主自理；与 #35 RadioGroup（文本互斥一选一）、#31 Menu/#33 Picker（下拉大选项集）、#36 Range（连续数值区间）、#41 Switch（二元）、#30 InputNumber（数字步进回显）划界；业务订单评价/满意度调研/详情只读评分=复用宿主旁路 |
| A2 | Token 零硬编码 | ✅ | 星外接圆直径 22（内凹比 0.382=五角星黄金比，R_in=R×sin18°/sin54°≈8.4）、星间距 8（sm）、行高 40 整行命中（星 22 垂直居中）、点亮星 primary 填充、未点亮 textSecondary alpha0.3 描边空心、readonly 保持 primary 彩色、disabled 40% 灰=全走 token 与注释锚定非魔法值（sizeXl=22 对齐 Tabbar 图标基准） |
| A3 | 决策投票表 | ✅ | P1-A 整星行评价点+双端自绘五角星 path（B 字符★字形双端 fallback 不一致淘汰/C 系统 RatingBar 视觉脱节淘汰）；P2-A Int 0~count+count 可配默认 5（B 半星 Double 二期候选/C 固定 5 淘汰）；P3-A 半受控 value nil=内部自持 0、点/滑回调宿主回写、点当前值再点清空=0 回调、readonly/disabled 无回调 disabled 压过（B 纯受控繁重/C 不可取消体验差淘汰）；P4-A 一期=点击+横滑+清空+count+半受控+readonly+disabled+demo 四段 D1-D4（B 半星/气泡二期、C label 文案槽=宿主自理） |
| A4 | Demo 排查 4 组 | ✅ | D1 基础评分点选（5 星点第 3=3+点当前值清空=0 实时回显+外部重置 0 驱动不触发 onChange）；D2 滑动连选（横滑随位点亮/收回连续、松手回调定值、超左 0 超右 5）；D3 只读与禁用（readonly 4 星彩色点不动+禁用开关整行灰 40% 已评保留+外部驱动回显）；D4 自定义 count 与受控（count10 十分制+外部 value=7/重置 0=仅回显不触发 onChange，拖动上报宿主回写） |
| A5 | 实现现状 | ✅ | 双端均无 Rate/星级近似件=纯从零全新立项：iOS 无系统评分控件=UIBezierPath/CAShapeLayer 自绘星形；Android 库内无（系统 RatingBar 视觉脱离库内设计语言不使用）=Compose Canvas Path 自绘；字符 ★ 有双端字形渲染不一致风险（Android 默认字体缺实心字形 fallback）故不自绘不采用；api.json 无 ui.rate 条目待门禁 B 立项登记；任务清单 #37 ⬜ 双端未实现 → 本次立项 📐 |
| A6 | 平台差异表 | ✅ | 表内放行：手势实现机制（Tap+Pan vs Compose pointerInput awaitEachGesture 单自旋=Range #36 双 detector 串行教训）、状态回写（命令式 didSet 显式刷新 vs 声明式重组）、无涟漪一致、pt/dp 与命名（RateView/RateGlyphView vs Rate(count=…)）、无障碍（VoiceOver/TalkBack Adjustable 语意=系统 range 步进） |
| A7 | anti_goals 反目标 | ✅ | 半星 allowHalf（半星 path+半格命中）二期候选；size 参数化二期候选（一期固定 22 同钮点固定先例）；label/评分文案/提交动作=宿主与 Form 职责；震动/动画评分反馈=不做或宿主自理；全部登记不混入 |

## 评审结论

| 项 | 内容 |
| -- | --- |
| 结论 | ✅ 通过（P1–P4 全 A，0 保留意见） |
| 用户签字 | （终核并入用户 C1.5 Demo 实机验收 2026-09-06） |
| 下一步 | 门禁 B api.json ui.rate 双端契约登记 → 双端独立组件实现（RateView.swift / Rate.kt）→ Demo 双端 1:1 → C1.5 demo 实机 → C1 单测 → C2/D |
