#!/usr/bin/env python3
"""Merge per-component API contracts (props/events/demos/note) into catalog/components.jsonl.

Rationale: props/events/demos/note previously lived only in a hand-written CONTRACTS
dict inside docs-site/scripts/generate_data.py, i.e. a SECOND source of truth separate
from catalog/components.jsonl. This script folds that contract data into each component
entry so the catalog becomes the single source of truth, and generate_data.py can drop
its CONTRACTS dict.

Run once after each catalog change (idempotent: existing props/events/demos/note on a
component are left untouched unless --overwrite is given).
"""

from __future__ import annotations

import argparse
import json
import shutil
from pathlib import Path

TMO = Path(__file__).resolve().parents[1]
CATALOG = TMO / "catalog" / "components.jsonl"

# Reuse the same CONTRACTS data that generate_data.py currently holds, so the move is exact.
try:
    import sys
    sys.path.insert(0, str(TMO / "docs-site" / "scripts"))
    from generate_data import CONTRACTS
except Exception:  # pragma: no cover - fallback when running in a fresh checkout
    CONTRACTS = {}


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--overwrite",
        action="store_true",
        help="overwrite existing props/events/demos/note fields on each component",
    )
    args = parser.parse_args()

    if not CONTRACTS:
        print("error: could not load CONTRACTS from generate_data.py")
        return

    lines = CATALOG.read_text(encoding="utf-8").splitlines()
    if not lines:
        print("error: empty catalog")
        return

    # Backup before rewriting.
    bak = CATALOG.with_suffix(".jsonl.bak")
    shutil.copy2(CATALOG, bak)

    comps = [json.loads(l) for l in lines if l.strip()]
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

    CATALOG.write_text(
        "\n".join(json.dumps(c, ensure_ascii=False) for c in comps) + "\n",
        encoding="utf-8",
    )
    print(f"merged contract fields into {touched}/{len(comps)} components")
    print(f"backup: {bak}")


if __name__ == "__main__":
    main()
