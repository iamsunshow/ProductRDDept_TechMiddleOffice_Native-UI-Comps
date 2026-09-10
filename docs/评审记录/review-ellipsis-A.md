# Ellipsis 文本省略 · 门禁 A 评审单（任务清单 #67 · 全新立项）

> 组件 ID：`ui.ellipsis` ｜ 设计规格：`design-spec/ellipsis-design-spec.html`
> 评审方式：🖊 AI 代评（用户 2026-09-04 总授权"除特色组件外所有组件评审文档全部生成，中间任何询问直接通过"，信息展示区 #63 Empty 收官后用户指示接棒开发信息展示区剩余组件）
> 评审日期：2026-09-10 ｜ 终核：并入用户 C1.5 Demo 实机验收

## 评审清单

| # | 项 | 判定 | 说明 |
| - | -- | --- | --- |
| A1 | 组件边界（SCQA） | ✅ | 定位=文本超出指定行数自动截断显示省略号+点击展开/收起（纯展示型文本截断组件）；与 TextArea #30（多行输入）划界=Ellipsis 不可编辑；与 Cell #21（列表行容器）划界=Ellipsis 专注单段文本截断；与 NoticeBar #51（横向滚动公告条）划界=Ellipsis 纵向截断静态展示；与 Tooltip #76（浮层提示）划界=Ellipsis 行内展开非浮层；双端纯从零（全仓无 EllipsisView/Ellipsis.kt） |
| A2 | Token 零硬编码 | ✅ | 正文 sizeMd 16sp/pt textPrimary；展开收起按钮 sizeSm 14sp/pt primary Medium；行高 lineHeightMultiple 1.8 倍；容器 bgPage 背景；内边距水平 xl 24 / 垂直 md 12；段间距 lg 16；全走 token |
| A3 | 决策投票表 | ✅ | P1-A 半受控 expanded（nil=内部自持零配置/非 nil=外部驱动受控，B 全受控淘汰=强制使用方管理 state 增加样板/C 全非受控淘汰=受控场景缺失）；P2-A 一期只做尾部 tail（B 中间+头部淘汰=Android Compose overflow 仅尾部=跨端不一致风险高）；P3-A 点击文本整体切换（B 仅点按钮淘汰=点击区域小易误触/C 不内置淘汰=使用方增加成本）；P4-A 一期=content+rows+direction(仅tail)+expandText/collapseText+半受控expanded+onExpandChange+demo四段（动画/多方向/disabled=二期） |
| A4 | Demo 排查 4 组 | ✅ | D1 基础单行省略+点击展开/收起（rows=1 长文本截断+展开/收起切换）；D2 多行省略（rows=3 长文本截断+展开）；D3 自定义展开收起文案（expandText="查看全部"/collapseText="收起内容"）；D4 受控外部驱动 expanded（外部按钮控制展开态+onExpandChange 回调） |
| A5 | 实现现状 | ✅ | iOS SharedUI/Components 无 Ellipsis 封装=未实现；Android sharedui/components 无 Ellipsis=未实现；api.json 无 ui.ellipsis 条目待门禁 B 立项登记；任务清单 #67 ⬜→本规格=双端通用文本省略立项入口 |
| A6 | 平台差异表 | ✅ | 表内放行：文本截断（UILabel numberOfLines+lineBreakMode=.byTruncatingTail vs Text maxLines+overflow=TextOverflow.Ellipsis）、展开态切换（numberOfLines=0 vs maxLines=Int.MAX_VALUE）、点击交互（UITapGestureRecognizer vs Modifier.clickable）；省略方向双端均原生支持尾部无差异 |
| A7 | anti_goals 反目标 | ✅ | 中间省略/头部省略=二期（Android Compose overflow 仅尾部=跨端不一致）；展开收起动画=二期增量；disabled 禁用态=二期；文本编辑=Ellipsis 纯展示编辑由 TextArea/Input 承载；自定义省略符号=一期用系统默认「…」二期增量 |

## 评审结论

| 项 | 内容 |
| -- | --- |
| 结论 | ✅ 通过（P1–P4 全 A，0 保留意见） |
| 用户签字 | （终核并入用户 C1.5 Demo 实机验收） |
| 下一步 | 门禁 B api.json ui.ellipsis 契约登记 → 双端独立组件实现（EllipsisView.swift / Ellipsis.kt）→ Demo 双端 1:1 → C1.5 demo 实机 → C1 单测 → C2/D |
