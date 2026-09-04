#!/usr/bin/env python3
"""Generate src/data/catalog.json for the Ant Design docs site."""

from __future__ import annotations

import json
from pathlib import Path

WWW = Path(__file__).resolve().parents[1]
TMO = WWW.parent
# 组件 metadata 单一数据源：docs/数据与产物/api.json（方案 B 由 catalog/components.jsonl 收敛而来）
API = TMO / "docs" / "api.json"
# 唯一 Token 源：组件库 docs/数据与产物/design-token.json（迁移后统一收口，不再读业务 App 内 tokens）
TOKENS = TMO / "docs" / "design-token.json"
# 版本日志唯一数据源：组件库根 CHANGELOG.md（官方文档「版本日志」页）
CHANGELOG = TMO / "CHANGELOG.md"
OUT_JSON = WWW / "src" / "data" / "catalog.json"

# 官方文档 meta：版本 / 平台 / 命名空间 / 仓库 / 快速引用信息
META = {
  "name": "Native-UI-Comps",
  "fullName": "OPC Native UI Components",
  "tagline": "记账产品线的原生双端组件库（iOS + Android）：UI 组件（按子类细分）+ 底层能力；业务组件由各 App 基于基础组件二次开发",
  "version": "1.0.0",
  "namespaceAndroid": "com.zhiqihuayun",
  "groupAndroid": "com.zhiqihuayun:components",
  "spmProduct": "Native-UI-Comps",
  "repo": "ProductRDDept_TechMiddleOffice_Native-UI-Comps",
  "platforms": ["ios", "android", "harmony", "weixin", "alipay"],
  "sources": {
    "android": "android",
    "ios": "ios",
    "designToken": "docs/数据与产物/design-token.json",
    "catalog": "docs/数据与产物/api.json",
  },
}

# 顶层两大类：UI 组件 / 底层能力（business 为业务层二次开发产物，不属于组件库）
CAT_META = {
  "ui": {
    "title": "UI 组件",
    "blurb": "高度可复用 UI；名称对齐 Ant / Apple / NutUI 等业内称谓，按子类细分",
  },
  "foundation": {
    "title": "底层能力",
    "blurb": "换 App 仍可复用的路由/存储/主题/网络/金额格式等基建（不含域仓储）",
  },
}

# UI 组件五子类（对齐 naming-pool.md 的 NutUI 分类）
SUB_CAT_META = {
  "ui": {
    "basics": {"title": "基础通用", "blurb": "Icon / Avatar / WebView / Card / Split 等通用原子"},
    "navigation": {"title": "导航", "blurb": "NavigationBar / Grid / ShortcutBar / SegmentedControl"},
    "input": {"title": "数据录入", "blurb": "DatePicker / Picker / GridPicker"},
    "display": {"title": "数据展示", "blurb": "List / Empty / LineChart / Progress 等展示"},
    "feedback": {"title": "操作反馈", "blurb": "Refresh 下拉刷新等"},
  },
}

# 组件 API 契约（props/events/demos/note）现收口于 docs/数据与产物/api.json 的每组件字段，
# 由 scripts/merge_contracts_into_catalog.py 从历史 CONTRACTS 并入。generate_data.py 不再持有第二份源。


_CHANGE_TYPES = ["Added", "Changed", "Deprecated", "Removed", "Fixed", "Security"]


def parse_changelog(text: str) -> list[dict]:
    """解析 CHANGELOG.md（Keep a Changelog 格式）为结构化版本日志。"""
    releases: list[dict] = []
    current: dict | None = None
    for raw in text.splitlines():
        line = raw.strip()
        if line.startswith("## ["):
            if current:
                releases.append(current)
            body = line[4:]
            # 兼容 Keep a Changelog 的 [Unreleased]（无 `] - 日期` 后缀）
            if "] - " in body:
                version, date = body.split("] - ")
                date = date.strip()
            else:
                version, date = body.split("]")[0], ""
            version = version.strip()
            # 过滤 CHANGELOG 顶部格式说明里的示例占位行
            if "版本号" in version or "VERSION" in version.upper():
                current = None
                continue
            current = {"version": version, "date": date, "groups": {}}
        elif current and line.startswith("### "):
            group = line[4:].strip()
            if group in _CHANGE_TYPES:
                current["groups"][group] = []
                current["_group"] = group
        elif current and line.startswith("- "):
            g = current.get("_group")
            if g and g in current["groups"]:
                current["groups"][g].append(line[2:].strip())
    if current:
        releases.append(current)
    return releases


def _extract_used_in_apps(comp: dict) -> list[str]:
    explicit = comp.get("used_in_apps")
    if explicit:
      return explicit
    apps: set[str] = set()
    source_refs = comp.get("source_refs") or {}
    if isinstance(source_refs, dict):
      for key, val in source_refs.items():
        if key == "note" or not isinstance(val, str):
          continue
        parts = val.replace("\\", "/").split("/")
        for i, part in enumerate(parts):
          if part == "App" and i + 1 < len(parts):
            apps.add(parts[i + 1])
            break
    if not apps and source_refs:
      apps.add("KeepAccounts")
    return sorted(apps)


def main() -> None:
  OUT_JSON.parent.mkdir(parents=True, exist_ok=True)

  api_data = json.loads(API.read_text(encoding="utf-8"))
  comps = api_data["components"]
  tokens = json.loads(TOKENS.read_text(encoding="utf-8")) if TOKENS.exists() else {}

  docs = []
  for c in comps:
    cid = c["id"]
    # props/events/demos/note now come straight from each catalog entry (single source of truth).
    contract = c

    emb = None
    emb_ref = c.get("embedding_ref")
    if emb_ref:
      emb_path = TMO / emb_ref
      if emb_path.exists():
        emb = json.loads(emb_path.read_text(encoding="utf-8")).get("vector")

    docs.append({
      "id": cid,
      "legacyId": c.get("legacy_id"),
      "name": c["name"],
      "category": c["category"],
      "subcategory": c.get("subcategory"),
      "summary": c["summary"],
      "industryNames": c.get("industry_names") or [],
      "searchText": c.get("search_text") or c["name"],
      "capabilities": c.get("capabilities") or [],
      "platforms": c.get("platforms") or {},
      "usedInApps": _extract_used_in_apps(c),
      "status": c.get("status", "stable"),
      "note": contract.get("note", ""),
      "props": contract.get("props", []),
      "events": contract.get("events", []),
      "demos": contract.get("demos", []),
      "image": None,
      "vector": emb,
    })

  index_path = TMO / "docs" / "embeddings" / "index.json"
  index = json.loads(index_path.read_text(encoding="utf-8")) if index_path.exists() else {}

  # 平台实现状态统计（用于首页/契约矩阵展示）
  platform_state = {p: {"available": 0, "partial": 0, "unavailable": 0} for p in META["platforms"]}
  for d in docs:
    for p, st in (d.get("platforms") or {}).items():
      if p in platform_state:
        platform_state[p][st.get("state", "unavailable")] += 1

  changelog = parse_changelog(CHANGELOG.read_text(encoding="utf-8")) if CHANGELOG.exists() else []
  for rel in changelog:
    rel.pop("_group", None)

  payload = {
    "meta": META,
    "backend": index.get("backend", "hash-v1"),
    "dim": index.get("dim", 256),
    "categories": CAT_META,
    "categoryOrder": ["ui", "foundation"],
    "subcategories": SUB_CAT_META,
    "tokens": tokens,
    "components": docs,
    "platformState": platform_state,
    "changelog": changelog,
  }
  OUT_JSON.write_text(json.dumps(payload, ensure_ascii=False), encoding="utf-8")
  print(f"wrote {OUT_JSON} ({len(docs)} components)")


if __name__ == "__main__":
  main()
