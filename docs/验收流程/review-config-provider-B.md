# TMO 组件库 · 评审意见单 · ConfigProvider 全局配置（门禁 B）

> 模板：`docs/验收流程/评审清单.md`。评审人直接在下方勾选 + 填备注，评审后在 `组件进度.md` 归档。

---

## 组件信息

| 项 | 值 |
|----|-----|
| 组件名 / id | 全局配置 ConfigProvider / `ui.config-provider`（历史 id：`foundation.config-provider`） |
| 分类（subcategory） | 基础组件 / `basics`（2026-09-03 门禁 B 定稿，与 icon/card/avatar 等基础组件一致） |
| 阶段 | ☐ 设计评审（门禁 A，✅ 已通过 2026-09-03）　✅ API 评审（门禁 B） |
| 评审人 | 用户（OPC 所有者） |
| 评审日期 | 2026-09-03 |
| 评审结论 | ✅ 通过（用户 2026-09-03「继续」确认） |
| 评审产物位置 | `docs/api.json` `ui.config-provider` 条目（契约单一数据源） |

---

## 二、API 评审清单（门禁 B）

> 验收方式：对照 `docs/api.json` `ui.config-provider` 条目逐项检查（契约已拟稿，本评审定稿）。

| # | 检查项 | 结论 |
|---|--------|------|
| 1 | `id` 命名规范（`ui.*`），与分类表一致（基础组件 / ConfigProvider 全局配置） | ✅ 通过　☐ 打回 |
| 2 | props：命名 / 类型 / 默认值双端 100% 对齐（primaryColor?/rounded?/compact?/locale?/children，默认值已声明） | ✅ 通过　☐ 打回 |
| 3 | events：回调名 / 签名双端一致（Provider 型无事件，events=[]） | ✅ 通过　☐ 打回 |
| 4 | 能力覆盖五态（Provider 型无视觉五态已标注 N/A，D 系列改配置生效测试） | ✅ 通过　☐ 打回 |
| 5 | `capabilities` / `scenarios` 已填（保证检索命中） | ✅ 通过　☐ 打回 |
| 6 | `visual_tokens` 已声明，token 已存在于 design-token.json（覆盖键为运行时动态，visual_tokens=[]） | ✅ 通过　☐ 打回 |
| 7 | `platforms` 状态与实现计划一致（双端 unavailable，门禁 A 通过 → 门禁 B 进行中） | ✅ 通过　☐ 打回 |
| 8 | api.json schema 校验通过（A6 校验脚本扩展至 config-provider） | ✅ 通过　☐ 打回 |

**评审结论（门禁 B）：** ✅ 通过，冻结契约，双端开始实现　☐ ❌ 打回，只改契约

**备注 / 修改意见：**
（2026-09-03 用户确认门禁 B 通过，契约冻结，进入双端实现阶段）

---

## 评审记录（归档用）

| 轮次 | 日期 | 阶段 | 结论 | 关键修改 |
|------|------|------|------|----------|
| 1 | 2026-09-03 | B | ✅ 通过 | subcategory 定稿 basics；platforms note 更新（门禁 A 已通过）；用户 2026-09-03 确认通过，契约冻结 |
