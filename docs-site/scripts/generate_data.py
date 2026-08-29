#!/usr/bin/env python3
"""Generate src/data/catalog.json for the Ant Design docs site."""

from __future__ import annotations

import json
import shutil
from pathlib import Path

DOCS_SITE = Path(__file__).resolve().parents[1]
TMO = DOCS_SITE.parent
CATALOG = TMO / "catalog" / "components.jsonl"
VIS_SRC = TMO / "catalog" / "visuals"
# 唯一 Token 源：组件库 design-token/tokens.json（迁移后统一收口，不再读业务 App 内 tokens）
TOKENS = TMO / "design-token" / "tokens.json"
# 版本日志唯一数据源：组件库根 CHANGELOG.md（官方文档「版本日志」页）
CHANGELOG = TMO / "CHANGELOG.md"
OUT_JSON = DOCS_SITE / "src" / "data" / "catalog.json"
OUT_VIS = DOCS_SITE / "public" / "visuals"

# 官方文档 meta：版本 / 平台 / 命名空间 / 仓库 / 快速引用信息
META = {
  "name": "Native-UI-Comps",
  "fullName": "OPC Native UI Components",
  "tagline": "记账产品线的原生双端组件库（iOS + Android），覆盖基础组件、底层能力与业务拼装",
  "version": "1.0.0",
  "namespaceAndroid": "com.zhiqihuayun",
  "groupAndroid": "com.zhiqihuayun:components",
  "spmProduct": "Native-UI-Comps",
  "repo": "ProductRDDept_TechMiddleOffice_Native-UI-Comps",
  "platforms": ["ios", "android", "harmony", "weixin", "alipay"],
  "sources": {
    "android": "android",
    "ios": "ios",
    "designToken": "design-token/tokens.json",
    "catalog": "catalog/components.jsonl",
  },
}

CAT_META = {
  "basic": {
    "title": "基础组件",
    "blurb": "高度可复用 UI；名称对齐 Ant / Apple 等业内称谓",
  },
  "foundation": {
    "title": "底层能力",
    "blurb": "换 App 仍可复用的路由/存储/主题/网络/金额格式等基建（不含域仓储）",
  },
  "business": {
    "title": "业务组件 / 业务拼装",
    "blurb": "域仓储、页级拼装、本 App 配置与脚手架；跨产品几乎无复用",
  },
}

# 组件 API 契约（props/events/demos/note）现收口于 catalog/components.jsonl 的每组件字段，
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
            version, date = line[4:].split("] - ")
            version = version.strip()
            # 过滤 CHANGELOG 顶部格式说明里的示例占位行
            if "版本号" in version or "VERSION" in version.upper():
                current = None
                continue
            current = {"version": version, "date": date.strip(), "groups": {}}
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
  OUT_VIS.mkdir(parents=True, exist_ok=True)
  OUT_JSON.parent.mkdir(parents=True, exist_ok=True)
  if VIS_SRC.exists():
    for p in VIS_SRC.glob("*.png"):
      shutil.copy2(p, OUT_VIS / p.name)

  comps = [json.loads(l) for l in CATALOG.read_text(encoding="utf-8").splitlines() if l.strip()]
  tokens = json.loads(TOKENS.read_text(encoding="utf-8")) if TOKENS.exists() else {}

  docs = []
  for c in comps:
    cid = c["id"]
    # props/events/demos/note now come straight from each catalog entry (single source of truth).
    contract = c
    vrefs = c.get("visual_refs") or []
    vfile = Path(vrefs[0]).name if vrefs else None
    if vfile and not (OUT_VIS / vfile).exists():
      vfile = None

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
      "image": f"/visuals/{vfile}" if vfile else None,
      "vector": emb,
    })

  index_path = TMO / "catalog" / "embeddings" / "index.json"
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
    "categoryOrder": ["basic", "foundation", "business"],
    "tokens": tokens,
    "components": docs,
    "platformState": platform_state,
    "changelog": changelog,
  }
  OUT_JSON.write_text(json.dumps(payload, ensure_ascii=False), encoding="utf-8")
  print(f"wrote {OUT_JSON} ({len(docs)} components)")


if __name__ == "__main__":
  main()
