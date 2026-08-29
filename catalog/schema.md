# 组件元数据 Schema

每行一条 JSON（`catalog/components.jsonl`）。

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `id` | string | 是 | 稳定 ID，如 `ui.empty-state` |
| `name` | string | 是 | 显示名 |
| `category` | string | 是 | `basic` \| `foundation` \| `business` |
| `summary` | string | 是 | 一句话功能 |
| `description` | string | 否 | 详细描述（用于向量化检索，包含功能说明、设计要点） |
| `scenarios` | string[] | 否 | 典型应用场景（如「商品列表为空」「搜索无结果」） |
| `capabilities` | string[] | 是 | 检索标签 |
| `used_in_apps` | string[] | 否 | 跨 App 使用追踪（可手动标注；不填时由 `source_refs` 自动提取） |
| `visual_tokens` | string[] | 否 | 依赖 token 名 |
| `platforms` | object | 是 | 见下 |
| `apis` | string | 否 | 对外接口摘要 |
| `deps` | string[] | 否 | 依赖的 component id |
| `source_refs` | object | 否 | `{ ios?, android?, harmony?, weixin?, alipay?, note? }` — 路径中 `App/<名>` 自动提取为 `used_in_apps` |
| `variants` | string[] | 否 | 视觉/功能变体 |
| `anti_goals` | string[] | 否 | 不适用场景 |
| `search_text` | string | 是 | embedding 语料 |
| `embedding_ref` | string | 否 | 向量文件相对路径 |
| `status` | string | 是 | `draft` \| `stable` \| `deprecated` |
| `visual_refs` | string[] | 否 | 截图路径（一期可选） |

## platforms

```json
{
  "ios": { "state": "available", "note": "" },
  "android": { "state": "partial", "note": "能力弱于 iOS" },
  "harmony": { "state": "unavailable", "note": "" },
  "weixin": { "state": "unavailable", "note": "" },
  "alipay": { "state": "unavailable", "note": "" }
}
```

`state`: `available` | `partial` | `unavailable`

## 元数据够用性结论

- **一期够用**：上表支撑「说诉求 → 检索 → 拼装清单 → 按端改代码」
- **二期增强**：截图、多端真实实现路径、契约测试、版本 semver
- **向量化增强**：`description` + `scenarios` 字段丰富 embedding 语料，提升自然语言检索精度

## 向量化字段说明

embedding 语料（`search_text`）由以下字段拼接生成：

```
{id} {name} {summary} {description} {category} {capabilities...} {scenarios...} {industry_names...} {legacy_id}
```

| 字段 | 向量化贡献 | 说明 |
|------|-----------|------|
| `name` | 高 | 组件名是核心检索词 |
| `summary` | 高 | 一句话描述功能 |
| `description` | 中 | 详细功能说明，补充语义 |
| `scenarios` | 高 | 用户常以场景描述需求（如「空态」「选择日期」） |
| `capabilities` | 中 | 技术标签/别名 |
| `industry_names` | 中 | 业界通用名，跨库检索桥梁 |
