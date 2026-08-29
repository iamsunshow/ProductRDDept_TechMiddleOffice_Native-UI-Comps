#!/usr/bin/env python3
"""Search OPC component catalog by natural language query."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from embed import ROOT, INDEX, hash_embed, try_st_embed, load_components  # noqa: E402


def cosine(a, b) -> float:
    n = min(len(a), len(b))
    if n == 0:
        return 0.0
    return sum(a[i] * b[i] for i in range(n))


def load_vectors(index: dict) -> dict:
    out = {}
    for item in index.get("items", []):
        path = ROOT / item["path"]
        if not path.exists():
            continue
        data = json.loads(path.read_text(encoding="utf-8"))
        out[data["id"]] = data["vector"]
    return out


def main() -> int:
    parser = argparse.ArgumentParser(description="Search OPC components")
    parser.add_argument("query", help="natural language query")
    parser.add_argument("-k", type=int, default=8, help="top-k")
    parser.add_argument("--category", default="", help="filter category prefix")
    args = parser.parse_args()

    if not INDEX.exists():
        print("missing embeddings; run: python3 scripts/embed.py", file=sys.stderr)
        return 1

    index = json.loads(INDEX.read_text(encoding="utf-8"))
    comps = {c["id"]: c for c in load_components()}
    vectors = load_vectors(index)

    backend = index.get("backend", "")
    if backend.startswith("sentence-transformers"):
        qv_list = try_st_embed([args.query])
        qv = qv_list[0] if qv_list else hash_embed(args.query)
    else:
        qv = hash_embed(args.query)

    scored = []
    for cid, vec in vectors.items():
        c = comps.get(cid)
        if not c:
            continue
        if args.category and not c.get("category", "").startswith(args.category):
            continue
        scored.append((cosine(qv, vec), c))
    scored.sort(key=lambda x: x[0], reverse=True)

    for score, c in scored[: args.k]:
        plats = c.get("platforms", {})
        avail = ",".join(
            p for p, meta in plats.items() if meta.get("state") in ("available", "partial")
        )
        print(f"{score:.3f}\t{c['id']}\t{c['category']}\t{c['name']}\t[{avail}]")
        print(f"       {c['summary']}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
