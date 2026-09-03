# TMO 组件库 · 评审意见单 · Overlay 遮罩层（门禁 B）

> 模板：`docs/验收流程/评审清单.md`。评审人（用户）在下方勾选 → 冻结后双端实现不许改契约；改契约=重新回 B。

---

## 组件信息

| 项 | 值 |
|----|-----|
| 组件名 / id | 遮罩层 Overlay / `ui.overlay`（legacy_id 无，基础组件 #6） |
| 分类（subcategory） | basics（基础类 6/6 收官；门禁 A 已确认，门禁 B 写入 api.json subcategory=basics） |
| 阶段 | ☐ 设计评审（门禁 A，当前待用户拍板）　✅ API 评审（门禁 B，契约已按推荐决策写入） |
| 评审人 | 用户（OPC 所有者） |
| 评审日期 | 2026-09-04 |
| 评审结论 | ☐ ✅ 通过（冻结契约进入实现）　☐ ❌ 打回（只改契约不改代码） |
| 契约位置 | `docs/api.json` `ui.overlay` 条目（inserted at basics 尾 index=22；componentCount 30 → 31） |
| 验收文档 | `docs/验收流程/component-acceptance-overlay.md` |

---

## 一、API 评审清单（门禁 B，共 10 项）

| # | 检查项 | 结论 |
|---|--------|------|
| 1 | **id / category / subcategory**：`ui.overlay`（`category: ui`，subcategory=basics）符合组件分类 §3.1 #6 行；`legacy_id` 留空（无历史） | ☐ 通过　☐ 打回 |
| 2 | **Props（10 件）命名·类型·必选·默认值双端 100% 对齐**：`visible:boolean 必选` / `maskColor?:'default'\|'transparent'\|rgba`='default'` / `closeOnMaskClick?:boolean=true` / `clickThrough?:boolean=false` / `contentPosition?:'center'\|'top'\|'bottom'\|'left'\|'right'\|'top-left'\|'top-right'\|'bottom-left'\|'bottom-right'='center'` / `contentOffset?:{x:number,y:number}` / `contentRadius?:'sm'\|'md'\|'lg'\|number=0` / `animation?:boolean=true` / `dismissOnBackPress?:boolean=true（仅 Android 生效，iOS 读值忽略不报错）` / `content: slot 必选` = 10 props 与验收文档 A 系列 10 默认值完全一致 | ☐ 通过　☐ 打回 |
| 3 | **Events（2 件）签名清晰正交**：`onClose?: () => void`（遮罩点击关闭 / 返回键关闭统一回调）/ `onMaskClick?: () => void`（点击遮罩背景触发，先于 onClose；closeOnMaskClick=false 时仍触发但不关闭；clickThrough=true 时均不触发） | ☐ 通过　☐ 打回 |
| 4 | **Methods：无**（一期 MVP：visible 驱动声明式；保留未来 show/hide 命令扩展，不进 v1.4.0） | ☐ 通过　☐ 打回 |
| 5 | **决策落位 anti_goals**：P1=A 挂载方案 / P2=A 一期仅 fade 200ms（过渡动画 PATCH 扩展延迟）/ P3=A closeOnMaskClick 默认 true + clickThrough 独立 / P4=A 9 点 + offset 共 4 条全部写入 anti_goals，后续反回归 | ☐ 通过　☐ 打回 |
| 6 | **visual_tokens** 引用 token 存在：`radius.sm` / `radius.md` / `radius.lg` / `color.textPrimary`（默认遮罩色来源）全部在 design-token.json 中存在，零未知 token | ☐ 通过　☐ 打回 |
| 7 | **capabilities / scenarios / search_text / industry_names**：14 能力词 + 7 场景语料 / search_text 全文搜索命中 / industry_names=['Overlay','Mask','遮罩层','Modal','浮层'] 全部填写，向量化可用 | ☐ 通过　☐ 打回 |
| 8 | **demos 4 组与设计规格 §04 一致**：①默认遮罩+居中确认框②透明穿透+新手气泡③底部抽屉（contentPosition=bottom+radius=lg）④圆角卡片居中，4 条 demo 全部有 React 风格代码片段 | ☐ 通过　☐ 打回 |
| 9 | **api.json schema 合法**：python json.load ✅；componentCount 30→31 与数组长度一致；其余字段齐全（source_refs/deps/variants/anti_goals/apis/visual_refs/status/embedding_ref/industry_names/tier 全部存在） | ☐ 通过　☐ 打回 |
| 10 | **与验收文档 D/A 用例衔接**：A1–A7（API 测试用例）全部覆盖 10 props / 2 events / 位置 9+offset / 默认值正交 / 事件顺序；D1–D8（设计用例）无重叠无遗漏，A5=位置与 D3/D4 不冲突 | ☐ 通过　☐ 打回 |

**评审结论（门禁 B）：** ☐ ✅ 通过（冻结契约为准绳，启动 C1 双端实现 iOS `Overlay.swift` + Android `Overlay.kt`）　☐ ❌ 打回（只改 api.json + 评审单 + 验收文档 A/B 节，改完重走 B）

**备注 / 修改意见：**
（用户填写。若有改 props/events，本行写明变更点 + 重新编号 A1–A7 用例；变更后重新进入 C1 实现。）

---

## 评审记录（归档用）

| 轮次 | 日期 | 阶段 | 结论 | 关键修改 |
|------|------|------|------|----------|
| 1 | 2026-09-04 | A+B 契约拟定 | CodeBuddy 拟定 api.json 条目（props 10 events 2 deps[] subcategory=basics tier=core reviewed=False status=beta platforms ios+android=available）+ 本评审单；待用户先过 A（P1–P4 拍板）再冻结 B 契约 → 正式写入 api.json reviewed=True 并 C1 双端实现 |
| 2 | 2026-09-04 | A（用户拍板） | ☐ 通过 / ☐ 打回 |  |
| 3 | 2026-09-04 | B（用户表决） | ☐ 通过 / ☐ 打回 | 若 B 通过 → 正式 api.json reviewed=False（占位）→ C1 实现（v1.4.0 MINOR） |
