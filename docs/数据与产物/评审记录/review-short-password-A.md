# ShortPassword 短密码 · 门禁 A 评审单（任务清单 #39 · 全新立项）

> 组件 ID：`ui.short-password` ｜ 设计规格：`design-spec/short-password-design-spec.html`
> 评审方式：🖊 AI 代评（用户 2026-09-04 总授权"除特色组件外所有组件评审文档全部生成，中间任何询问直接通过"；数据录入区 #38 search-bar 收编后下一件，用户 2026-09-06 原话「通过，下一个组件吧」指示接棒启动）
> 评审日期：2026-09-06 ｜ 终核：并入用户 C1.5 Demo 实机验收

## 评审清单

| # | 项 | 判定 | 说明 |
| - | -- | --- | --- |
| A1 | 组件边界（SCQA） | ✅ | 定位=定长数字短密码/PIN 输入内容组件（length 定长 4~8 位默认 6，支付/交易/二次验证短密码场景）：展示=居中大字号掩码圆点（系统密文点=随字号，不绘灰底壳、无清除钮、无明文显隐切换）；输入=纯数字（键盘与粘贴均滤除非数字）、字符满 length=自动 onComplete 一次、满后拒收追加；半受控 value String?（nil=内部自持；外部赋值=仅回显不触发 onChange/onComplete）+ onChange 每字符 + onComplete(明文字符串) + disabled 40% 灰无回调 + placeholder（空态居中灰字）；真实校验/错误提示/重试/提交按钮/安全存储=宿主自理；与 Input #29 secure（任意长任意字符密文、灰底壳+清除钮+trailing、无满位回调=表单行语境）划界=基座惯例复用非扩展；与 NumberKeyboard #32（数字键盘=宿主组合件可组装）、分享界 PasswordInputField（业务库带显隐长密码=收编不动）、验证码分格 OTP（码类二期=anti_goals）划界 |
| A2 | Token 零硬编码 | ✅ | 密文点=系统掩码随字号 sizeXl(22)（两端字号一致=点径视觉对齐）；行高 min 48 对齐 FormFieldRow/Input 交互行基准（注释锚定）；placeholder=textSecondary sizeXl；disabled=40% 灰；位点序列水平居中；库内无 textTertiary token=placeholder 用 textSecondary（同 Input #29 惯例）；全部 token/注释锚定、无裸色值 |
| A3 | 决策投票表 | ✅ | P1-A 无壳居中大字系统掩码点（B 复用灰底壳=撞车 Input secure 淘汰/C 分格 OTP=码类形态与短密码语义不符=二期码组件候选淘汰）；P2-A 满 N 自动 onComplete 一次+满后拒收（B 内置确定钮=numberPad 无确定键且破坏掩码干净视觉淘汰/C 满位不回调=与「满即提」语义脱节淘汰）；P3-A 半受控 value String? nil=内部自持（B 受控必传=支付场景宿主回写负担淘汰/C 纯非受控=无法错误清空重输等外部驱动淘汰）；P4-A 一期 length+value+onChange+onComplete+disabled+placeholder+demo 四段（B 明文显隐切换/分格自动跳格=二期或码组件=C 内置校验错误浮层=宿主） |
| A4 | Demo 排查 4 组 | ✅ | D1 基础 6 位输入（掩码圆点随键入渐显+onChange 段内回显+满 6 自动 onComplete 回显「onComplete → 6 位已满，宿主执行校验」+「清空」按钮外部 value=""）；D2 定长 length=4+受控外部驱动（外部预填 4 位=回显满位但不触发 onComplete（证仅输入路径触发）+清空重输）；D3 禁用与粘贴过滤（disabled 40% 灰不可输入无回调+粘贴「ab3#9x」仅取数字按位截断并入）；D4 与 NumberKeyboard #32 组装+宿主校验流程（固定「123456」=正确：满位校验通过回显/错误=提示并自动清空重输=演示宿主外部清空接法） |
| A5 | 实现现状 | ✅ | 双端无 ShortPassword 近似件=全新立项：Input #29 secure（InputView.swift=UITextField secureTextEntry+Input.kt=BasicTextField PasswordVisualTransformation）=任意长密码基座先例=数字限定/定长/满位回调/居中大字展示为本次增量，壳惯例/掩码实现复用不复制；Android sharedui PasswordInputField=业务组件库带显隐切换通用长密码=业务收编不动；iOS 系统密码 AutoFill（strong password）为系统级二验场景不收编；api.json 无 ui.short-password 条目待门禁 B 立项登记；任务清单 #39 ⬜ 双端未实现 → 本次立项 📐 |
| A6 | 平台差异表 | ✅ | 表内放行：掩码渲染（iOS=UITextField secureTextEntry 系统点 vs Android=BasicTextField VisualTransformation 自绘点=点径随字号一致）、键盘（keyboardType .numberPad+delegate 数字过滤 vs KeyboardOptions KeyboardType.Number+filter 数字）、满位触发（值变化回调数==N vs filter 后 length==N）、状态回写（命令式 didSet vs 声明式 LaunchedEffect）、命名（ShortPasswordView.swift vs ShortPassword.kt）、无障碍（VoiceOver/TalkBack=系统级文本输入语意、掩码不播明文） |
| A7 | anti_goals 反目标 | ✅ | 明文显隐切换=一期不做（安全默认、同 Input #29 secure 无显隐惯例）；分格 OTP 逐格跳=短信验证码/码类输入=二期或另行码组件（与 #39 短密码语义区分登记）；内置「确定/提交」钮与校验错误弹层=宿主（numberPad 无确定键、校验=业务逻辑）；灰底壳+清除钮+trailing=Input secure 职责不混入；自动聚焦=宿主；全部登记不混入 |

## 评审结论

| 项 | 内容 |
| -- | --- |
| 结论 | ✅ 通过（P1–P4 全 A，0 保留意见） |
| 用户签字 | （终核并入用户 C1.5 Demo 实机验收） |
| 下一步 | 门禁 B api.json ui.short-password 双端契约登记 → 双端独立组件实现（ShortPasswordView.swift / ShortPassword.kt）→ Demo 双端 1:1 → C1.5 demo 实机 → C1 单测 → C2/D |
