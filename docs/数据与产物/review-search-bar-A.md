# SearchBar 搜索栏 · 门禁 A 评审单（任务清单 #38 · 全新立项）

> 组件 ID：`ui.search-bar` ｜ 设计规格：`design-spec/search-bar-design-spec.html`
> 评审方式：🖊 AI 代评（用户 2026-09-04 总授权"除特色组件外所有组件评审文档全部生成，中间任何询问直接通过"；数据录入区 #37 rate 收编后下一件，用户 2026-09-06 原话「通过，继续下一个组件」指示接棒启动）
> 评审日期：2026-09-06 ｜ 终核：并入用户 C1.5 Demo 实机验收

## 评审清单

| # | 项 | 判定 | 说明 |
| - | -- | --- | --- |
| A1 | 组件边界（SCQA） | ✅ | 定位=搜索输入壳（48 灰底 radius lg）+ 前置放大镜（自绘 glyph）+ 文本输入 + 非空清除钮 + 键盘「搜索」键 onSearch 触发 + trailing 尾槽（宿主搜索按钮第二路径）；半受控 value String?（nil=内部自持免回写）+ onTextChange 实时直通 + onSearch + placeholder + maxLength + disabled；真实检索/结果/历史/联想=宿主自理；与 Input #29（通用文本输入无检索语义=基座复用非扩展）、ShortPassword #39（掩码专用）、Picker #33/Menu #31/Cascader #24（选项选择）划界；业务首页搜索/列表过滤/通讯录检索=复用 |
| A2 | Token 零硬编码 | ✅ | 壳 48/radius lg/底 bgPage 无边框、壳内 padding lg、放大镜 14 textSecondary 灰、文本 Md16 textPrimary/placeholder textTertiary、清除钮 20 灰底(E5E7EB)白叉、间距 sm、disabled 40% 灰=全走 token/已收编 Input #29 壳 token 锚定（radiusLg=14 对齐 FormFieldRow min48） |
| A3 | 决策投票表 | ✅ | P1-A 灰底圆角壳+放大镜自绘（B 胶囊 shape 二期/C 系统 UISearchBar·Material SearchBar 视觉脱节淘汰）；P2-A onSearch=软键盘搜索键主触发一次回调+宿主 trailing 尾槽第二路径+清除钮清空回传空串（B 内置提交文字钮淘汰/C 无 onSearch 撞车 Input 淘汰）；P3-A 半受控 value String? nil=内部自持免回写（B 受控必传=搜索宿主回写负担重淘汰/C 纯非受控外部无法驱动淘汰）；P4-A 一期方形 radius lg 无胶囊+demo 四段 D1-D4（B 胶囊/自动聚焦/防抖一期膨胀=C 内置历史联想=浮层职责淘汰） |
| A4 | Demo 排查 4 组 | ✅ | D1 基础搜索输入（placeholder+onTextChange 实时回显+非空清除钮点击清空回传空串）；D2 键盘搜索键触发 onSearch（段内回显「搜索：xxx」+静态列表按词过滤演示宿主检索接法）；D3 禁用与外部驱动（disabled 40% 灰不可输入清除钮隐藏+外部 value 赋值仅回显不触发 onTextChange+重置清空）；D4 trailing 尾槽（宿主后置「搜索」按钮=与键盘搜索键双路径触发） |
| A5 | 实现现状 | ✅ | 双端均无 SearchBar 近似件=全新立项：iOS 系统 UISearchBar（独立 36 高白底+自动取消钮）不收编、Android 系统 Material SearchBar（Material 3 样式）视觉脱离库内设计语言不用；实现基座=已收编 Input #29（InputView.swift=UITextField+自绘清除钮+maxLength delegate / Input.kt=BasicTextField+KeyboardOptions imeAction Search+Canvas 清除钮）壳/清除钮/键盘/截断惯例复用不复制；api.json 无 ui.search-bar 条目待门禁 B 立项登记；任务清单 #38 ⬜ 双端未实现 → 本次立项 📐 |
| A6 | 平台差异表 | ✅ | 表内放行：文本输入基座（UITextField+delegate vs Compose BasicTextField+imeAction=同 Input #29 已登记先例）、清除钮自绘机制（path vs Canvas drawText）、状态回写（命令式 didSet vs 声明式 LaunchedEffect 联动）、聚焦（becomeFirstResponder vs FocusRequester 宿主按需=组件不抢焦）、pt/dp 与命名（SearchBarView.swift vs SearchBar.kt）、无障碍（VoiceOver/TalkBack 文本输入语意=系统级） |
| A7 | anti_goals 反目标 | ✅ | 胶囊 shape 参数=二期候选（一期固定方形 radius lg 同 Input 壳语言统一）；自动聚焦/防抖=宿主职责；历史/热词/联想/结果列表/空态/loading=宿主自理；语音/相机搜索=不做或宿主；全部登记不混入 |

## 评审结论

| 项 | 内容 |
| -- | --- |
| 结论 | ✅ 通过（P1–P4 全 A，0 保留意见） |
| 用户签字 | （终核并入用户 C1.5 Demo 实机验收） |
| 下一步 | 门禁 B api.json ui.search-bar 双端契约登记 → 双端独立组件实现（SearchBarView.swift / SearchBar.kt）→ Demo 双端 1:1 → C1.5 demo 实机 → C1 单测 → C2/D |
