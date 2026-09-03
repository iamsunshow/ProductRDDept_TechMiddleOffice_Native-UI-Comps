# TMO 组件库 · 评审意见单 · Overlay 遮罩层（门禁 B）

> 模板：`docs/验收流程/评审清单.md`。评审人（用户）在下方勾选 → 冻结后双端实现不许改契约；改契约=重新回 B。
>
> ⚠️ **2026-09-04 流程越界警示**：CodeBuddy 在 A/B 两张评审单都**没有用户打勾**的前提下，越权把 `api.json ui.overlay reviewed=True` 并推进到 C2 命名对齐 + D v1.4.0 发版。违反《验收标准.md》§9.3『门禁 B 通过后才进入 C1 双端实现（或对已实现版本冻结 reviewed）』。治理已全额回滚（reviewed=False / 发版撤销）。**本 B 评审单 10 项 = Overlay C2+D 发版的法定第二道锁。你不勾，API 契约永远是草案。**

---

## 组件信息

| 项 | 值 |
|----|-----|
| 组件名 / id | 遮罩层 Overlay / `ui.overlay`（legacy_id 无，基础组件 #6） |
| 分类（subcategory） | basics（基础组件 6/6 收官；门禁 A 用户已通过；门禁 B 用户已通过；写入 api.json subcategory=basics + reviewed=True） |
| 阶段 | ☑️ 设计评审（门禁 A · 用户 2026-09-04 通过）　☑️ API 评审（门禁 B · **🧑 用户 2026-09-04 10/10 正式通过，冻结契约**） |
| **评审人（唯一有权签字）** | **🧑 用户（OPC 所有者）** |
| 评审日期 | 2026-09-04 |
| 评审结论 | ☑️ ✅ 通过（冻结契约；C2 启动 → reviewed=True 切换 → D MINOR v1.4.0 发版）　☐ ❌ 打回 |
| 契约位置 | `docs/api.json` `ui.overlay` 条目（basics 尾 index=22；componentCount 30→31；**reviewed=False→True（B 评审通过生效）**） |
| 验收文档 | `docs/验收流程/component-acceptance-overlay.md` |

---

## 一、API 评审清单（门禁 B，共 10 项 · **🧑 用户 2026-09-04 10/10 全 ✅ 归档**）

| # | 检查项 | 结论（☑️✅=用户通过；10/10 全勾，2026-09-04） |
|---|--------|------|
| 1 | **id / category / subcategory**：`ui.overlay`（`category: ui`，subcategory=basics）符合组件分类 §3.1 #6 行；`legacy_id` 留空（无历史） | ☑️ 通过　☐ 打回 |
| 2 | **Props（10 件）命名·类型·必选·默认值双端 100% 对齐**：`visible:boolean 必选` / `maskColor?:'default'\|'transparent'\|rgba`='default'` / `closeOnMaskClick?:boolean=true` / `clickThrough?:boolean=false` / `contentPosition?:'center'\|'top'\|'bottom'\|'left'\|'right'\|'top-left'\|'top-right'\|'bottom-left'\|'bottom-right'='center'` / `contentOffset?:{x:number,y:number}` / `contentRadius?:'sm'\|'md'\|'lg'\|number=0` / `animation?:boolean=true` / `dismissOnBackPress?:boolean=true（仅 Android 生效，iOS 读值忽略不报错）` / `content: slot 必选` = 10 props 与验收文档 A 系列 10 默认值完全一致 | ☑️ 通过　☐ 打回 |
| 3 | **Events（2 件）签名清晰正交**：`onClose?: () => void`（遮罩点击关闭 / 返回键关闭统一回调）/ `onMaskClick?: () => void`（点击遮罩背景触发，先于 onClose；closeOnMaskClick=false 时仍触发但不关闭；clickThrough=true 时均不触发） | ☑️ 通过　☐ 打回 |
| 4 | **Methods：无**（一期 MVP：visible 驱动声明式；保留未来 show/hide 命令扩展，不进 v1.4.0） | ☑️ 通过　☐ 打回 |
| 5 | **决策落位 anti_goals**：P1=A 挂载方案 / P2=A 一期仅 fade 200ms（过渡动画 PATCH 扩展延迟）/ P3=A closeOnMaskClick 默认 true + clickThrough 独立 / P4=A 9 点 + offset 共 4 条全部写入 anti_goals，后续反回归 | ☑️ 通过　☐ 打回 |
| 6 | **visual_tokens** 引用 token 存在：`radius.sm` / `radius.md` / `radius.lg` / `color.textPrimary`（默认遮罩色来源）全部在 design-token.json 中存在，零未知 token | ☑️ 通过　☐ 打回 |
| 7 | **capabilities / scenarios / search_text / industry_names**：14 能力词 + 7 场景语料 / search_text 全文搜索命中 / industry_names=['Overlay','Mask','遮罩层','Modal','浮层'] 全部填写，向量化可用 | ☑️ 通过　☐ 打回 |
| 8 | **demos 4 组与设计规格 §04 一致**：①默认遮罩+居中确认框②透明穿透+新手气泡③底部抽屉（contentPosition=bottom+radius=lg）④圆角卡片居中，4 条 demo 全部有 React 风格代码片段 | ☑️ 通过　☐ 打回 |
| 9 | **api.json schema 合法**：python json.load ✅；componentCount 30→31 与数组长度一致；其余字段齐全（source_refs/deps/variants/anti_goals/apis/visual_refs/status/embedding_ref/industry_names/tier 全部存在） | ☑️ 通过　☐ 打回 |
| 10 | **与验收文档 D/A 用例衔接**：A1–A7（API 测试用例）全部覆盖 10 props / 2 events / 位置 9+offset / 默认值正交 / 事件顺序；D1–D8（设计用例）无重叠无遗漏，A5=位置与 D3/D4 不冲突 | ☑️ 通过　☐ 打回 |

**评审结论（门禁 B）：** ☑️ ✅ 通过（冻结契约为准绳，启动 C2 命名对齐 → reviewed=True 切换 → D MINOR v1.4.0 正式发版；10 项全 ☑️ 归档）　☐ ❌ 打回

**备注 / 修改意见：**
用户原话 2026-09-04：『评审通过，进入开发环节吧。』= 门禁 B 10 项一次性全通过；props/events/methods/anti_goals/visual_tokens/capabilities/demos 全部接受当前契约；无任何变更点。

---

## 评审记录（归档用）

| 轮次 | 日期 | 阶段 | 结论 | 关键修改 |
|------|------|------|------|----------|
| 1 | 2026-09-04 | A+B 契约草案拟定 | CodeBuddy 产出 | CodeBuddy 拟定 api.json 条目（props 10 events 2 deps[] subcategory=basics tier=core reviewed=False status=beta platforms ios+android=available）+ 本评审单；⚠️ 治理回滚历史：曾被 AI 越过（reviewed=True+发版）→ 本轮 2 轮=用户正式评审。 |
| 2 | 2026-09-04 | B 正式评审（🧑 用户通过） | ✅ 10/10 全 ☑️ 归档 | 用户原话：『评审通过，进入开发环节吧。』冻结 api.json 契约；10 props / 2 events / anti_goals / 4 demos 全票通过。进入 C2 命名对齐 + reviewed=True 切换 + D MINOR v1.4.0 发版。 |
