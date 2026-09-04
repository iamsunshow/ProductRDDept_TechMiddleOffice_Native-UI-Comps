#!/usr/bin/env python3
"""Merge per-component API contracts (props/events/demos/note) into docs/数据与产物/api.json.

Historical rationale: props/events/demos/note previously lived only in a hand-written
CONTRACTS dict inside generate_data.py, a SECOND source of truth separate from the
catalog. 方案 B 后组件 metadata 收口为 docs/数据与产物/api.json（由 catalog/components.jsonl 收敛而来），
本脚本保留为幂等工具：将 CONTRACTS 并入每个组件条目，使 api.json 成为唯一数据源。

Run once after each api.json change (idempotent: existing props/events/demos/note on a
component are left untouched unless --overwrite is given).
"""

from __future__ import annotations

import argparse
import json
import shutil
from pathlib import Path

TMO = Path(__file__).resolve().parents[1]
API = TMO / "docs" / "api.json"

# NOTE: 组件 API 契约（props/events/demos/note）已在历史迁移中并入 api.json，
# 本脚本仅保留为幂等的合并工具（供新增组件时按需回填），CONTRACTS 已随
# generate_data.py 的改版移除，因此这里不再引用外部 CONTRACTS。
CONTRACTS: dict = {}


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--overwrite",
        action="store_true",
        help="overwrite existing props/events/demos/note fields on each component",
    )
    args = parser.parse_args()

    if not CONTRACTS:
        print(
            "note: 契约已收口于 docs/数据与产物/api.json；无独立 CONTRACTS 源可合并，直接校验/api.json 完整性。"
        )
    if not API.exists():
        print("error: missing docs/数据与产物/api.json")
        return

    api_data = json.loads(API.read_text(encoding="utf-8"))
    comps = api_data.get("components", [])
    if not comps:
        print("error: empty components in api.json")
        return

    # Backup before rewriting.
    bak = API.with_suffix(".json.bak")
    shutil.copy2(API, bak)

    touched = 0
    for comp in comps:
        cid = comp["id"]
        contract = CONTRACTS.get(cid)
        if contract is None:
            continue
        changed = False
        for field in ("props", "events", "demos", "note"):
            if field not in contract:
                continue
            if field in comp and not args.overwrite:
                continue  # already merged; keep existing unless --overwrite
            comp[field] = contract[field]
            changed = True
        if changed:
            touched += 1

    api_data["components"] = comps
    api_data["componentCount"] = len(comps)
    API.write_text(json.dumps(api_data, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"checked {len(comps)} components in docs/数据与产物/api.json (touched: {touched})")
    print(f"backup: {bak}")


if __name__ == "__main__":
    main()
