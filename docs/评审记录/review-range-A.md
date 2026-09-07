# Range 区间选择 · 门禁 A 评审单（任务清单 #36 · 全新立项）

> 组件 ID：`ui.range` ｜ 设计规格：`design-spec/range-design-spec.html`
> 评审方式：🖊 AI 代评（用户 2026-09-04 总授权"除特色组件外所有组件评审文档全部生成，中间任何询问直接通过"；数据录入区 #36 顺延单件，用户 2026-09-06 原话「radio通过，继续下一个组件」指示接棒启动）
> 评审日期：2026-09-06 ｜ 终核：并入用户 C1.5 Demo 实机验收

## 评审清单

| # | 项 | 判定 | 说明 |
| - | -- | --- | --- |
| A1 | 组件边界（SCQA） | ✅ | 定位=横向双钮区间选择内容组件（单轨道+start/end 双钮、激活段高亮、闭区间 start≤end 恒成立可相等=零宽单点、点轨道吸附最近端、数值 Double 宿主格式化、无壳无刻度无气泡）；与 #30 InputNumber（步进单值无联动）、#35 RadioGroup / #31 Menu（离散档枚举）、#41 Switch（二元开关）、#37 Rate（整数评价点）、日期区间日历（非数值不走滑轨）、未来 Slider 单钮单值（另行立项）划界；业务报表金额区间=复用组件宿主旁路展示 |
| A2 | Token 零硬编码 | ✅ | 轨道高 4 圆角 full、未激活段 textSecondary alpha0.3、激活段 primary、钮白底圆形 20 primary 描边 1.5、行高 40（命中区整条）、禁用 40% 灰、端点贴边半钮溢出允许=全走 token 与注释锚定非魔法值 |
| A3 | 决策投票表 | ✅ | P1-A 双钮区间（B 单钮 Slider 无法表区间/C 系统 UISlider/SeekBar 均单钮视觉脱节淘汰）；P2-A Double 全域 RangeValue{start,end}+min/max/step（B 整数受限/C 泛型过度淘汰）；P3-A 半受控 value 可选 nil 内部自持初始 [min,max]、外部赋值（clamp 后）回显不触发 onChange、点/拖 onChange 连续宿主回写、start≤end 硬钳制、min/max 动态改越界自动 clamp、disabled 组级（B 纯受控/C 纯自管理淘汰）；P4-A 一期=横向区间双钮+step 吸附+点轨吸附+disabled+半受控+demo 四段 D1-D4（刻度 mark/数值气泡=二期候选；onDragStart/End/节流=宿主自理淘汰） |
| A4 | Demo 排查 4 组 | ✅ | D1 基础区间（0–100 step1 初始 25–75 拖动实时回显两端值+重置外部驱动）；D2 离散步进 step5+点轨道空段最近端吸附跳位；D3 值域与禁用（动态改 min 越界端自动 clamp 回显 start=end 单点合法+禁用开关 40% 灰不可交互）；D4 受控外部 value 驱动（预设 0–30/60–100 外部赋值仅同步点亮不触发 onChange，拖动上报宿主回写） |
| A5 | 实现现状 | ✅ | 双端均无 Range/Slider 近似件=纯从零全新立项：iOS 无系统双钮区间控件需自绘（CALayer 轨道+钮 + UIPanGestureRecognizer/UITapGestureRecognizer 几何换算）；Android 库内无（Material3 Slider 单钮且视觉脱离库内设计语言=不使用，Compose pointerInput 自绘+detectDragGestures/detectTapGestures）；api.json 无 ui.range 条目待门禁 B 立项登记；任务清单 #36 ⬜ 双端未实现 → 本次立项 📐 |
| A6 | 平台差异表 | ✅ | 表内放行：手势实现机制（UIPan/UIPan+Tap vs Compose pointerInput detect*）、状态回写（命令式 didSet 显式刷新 vs 声明式重组）、无按压涟漪两端一致、pt/dp 与命名（RangeView/RangeValue vs Range(value…) 同全库先例）、无障碍（VoiceOver/TalkBack 系统 range 步进语义） |
| A7 | anti_goals 反目标 | ✅ | 刻度 mark/数值气泡 tooltip/垂直方向/翻转滑轨=二期或不做；单值连续 Slider=另行立项不混入（Range 区间语义专用）；单位/刻度文案/格式化/区间必填校验=宿主与 Form 职责；拖动节流/手势冲突（宿主滚动手势并发）策略由 demo 宿主合理接线=全部登记不混入 |

## 评审结论

| 项 | 内容 |
| -- | --- |
| 结论 | ✅ 通过（P1–P4 全 A，0 保留意见） |
| 用户签字 | （终核并入用户 C1.5 Demo 实机验收 2026-09-06） |
| 下一步 | 门禁 B api.json ui.range 双端契约登记 → 双端独立组件实现（RangeView.swift / Range.kt）→ Demo 双端 1:1 → C1.5 demo 实机 → C1 单测 → C2/D |
