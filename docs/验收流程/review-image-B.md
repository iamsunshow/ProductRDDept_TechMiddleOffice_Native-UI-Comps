# TMO 组件库 · 评审意见单 · Image 图片（门禁 B）

> 模板：`docs/验收流程/评审清单.md`。评审人直接在下方勾选 + 填备注，评审后在 `组件进度.md` 归档。

---

## 组件信息

| 项 | 值 |
|----|-----|
| 组件名 / id | 图片 Image / `ui.image`（legacy_id=ui.image，无历史 id） |
| 分类（subcategory） | display（与同为视觉容器的 Cell 一致；门禁 A 定稿） |
| 阶段 | ☐ 设计评审（门禁 A，✅ 已过）　☐ API 评审（门禁 B） |
| 评审人 | 用户（OPC 所有者） |
| 评审日期 | 2026-09-03 |
| 评审结论 | ✅ 通过（2026-09-03 用户表决冻结 `ui.image`） |
| 契约位置 | `docs/数据与产物/api.json` `ui.image` 条目（componentCount 30） |
| 验收文档 | `docs/验收流程/component-acceptance-image.md` |

---

## 一、API 评审清单（门禁 B）

> 验收方式：对照 `docs/数据与产物/api.json` `ui.image` 条目与验收文档 A 系列用例，逐项勾选。

| # | 检查项 | 结论 |
|---|--------|------|
| 1 | 属性 props 完整：src / fit（五值，默认 fill）/ position（五值，默认 center）/ width·height（默认撑满父容器）/ radius（token 档位或数值，0 默认）/ alt / loadingContent / errorContent，类型·必选·默认值双端 100% 对齐 | ✅ 通过 |
| 2 | 事件 events 签名清晰：onTap / onLoad（成功态）/ onError（失败态，P4=B 重试由业务改 src） | ✅ 通过 |
| 3 | 方法 methods：无（与 NutUI 一致，无实例方法） | ✅ 通过 |
| 4 | 决策落位：P1=B URL 归业务预下载 / P2=B lazy 一期 N/A / P3=A 圆形=radius=宽/2 / P4=B 无内置重试，全部写入 anti_goals | ✅ 通过 |
| 5 | 视觉 token 引用：visual_tokens 含 radius.sm/md/lg、color.gray.6/15/25、color.bgCard、font.sizeSm、space.sm 等（占位/圆角零硬编码） | ✅ 通过 |
| 6 | demos 覆盖典型场景：圆角头像（fit=cover+圆形）/ 封面缩略图（radius=md+占位+事件）/ 点击查看（contain+onTap） | ✅ 通过 |
| 7 | api.json schema 合法：python json.load 校验通过；componentCount=30 与实际一致；embedding_ref 留待 embedding 链路生成 | ✅ 通过 |
| 8 | API 测试用例（A 系列）齐全：A1 默认值 / A2 自定义 / A3 事件回调 / A6 契约 schema / A7 双端命名对齐（编号与验收文档一致：2026-09-03 C1 用例重排，token 零硬编码并入 D6、占位无障碍语义并入 D5/D7） | ✅ 通过 |
| 9 | 检索完备：capabilities（含双端与历史检索词）、search_text、industry_names（Image/img/图片）、legacy_id=ui.image | ✅ 通过 |
| 10 | 与验收文档 D 系列衔接：D1–D8 覆盖五态+尺寸/fit 几何，A 系列覆盖 API 面，无重叠无遗漏（禁用态 N/A 有依据） | ✅ 通过 |

**评审结论（门禁 B）：** ✅ 通过（2026-09-03 用户表决冻结 `ui.image` 为准绳，props 9 + events 3），冻结契约，进入实现阶段

**备注 / 修改意见：**（2026-09-03 用户表决）冻结 `ui.image` 契约为 C1 实现准绳；随即启动双端实现（iOS `Image.swift` / Android `Image.kt`，先抽公共部分再分别实现），按 C1 自测 D/A 用例，结果见验收文档「七、验收记录」C1 行（2026-09-03 ✅）。

---

## 评审记录（归档用）

| 轮次 | 日期 | 阶段 | 结论 | 关键修改 |
|------|------|------|------|----------|
| 1 | 2026-09-03 | A | ✅ 通过 | 用户确认设计 + P1–P4 拍板（P1=B URL 业务预下载 / P2=B lazy N/A / P3=A 圆形=宽/2 / P4=B 仅 onError）；subcategory 定稿 display |
| 2 | 2026-09-03 | B | ✅ 通过 | 用户表决冻结 `ui.image` 为准绳（props 9 / events 3 / subcategory=display / P1–P4 落 anti_goals），评审清单 10 项全过；进入 C1 双端实现（iOS Image.swift / Android Image.kt，先抽公共部分再分别实现，按 C1 自测 D/A 用例） |
