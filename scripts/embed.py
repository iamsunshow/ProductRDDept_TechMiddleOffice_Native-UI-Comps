#!/usr/bin/env python3
"""Embed component search_text into catalog/embeddings/ and index.json."""

from __future__ import annotations

import hashlib
import json
import math
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CATALOG = ROOT / "catalog" / "components.jsonl"
EMB_DIR = ROOT / "catalog" / "embeddings"
INDEX = EMB_DIR / "index.json"
DIM = 256


def tokenize(text: str) -> list[str]:
    text = text.lower()
    return re.findall(r"[a-z0-9_]+|[\u4e00-\u9fff]", text)


def hash_embed(text: str, dim: int = DIM) -> list[float]:
    vec = [0.0] * dim
    toks = tokenize(text)
    if not toks:
        return vec
    for t in toks:
        h = int(hashlib.sha256(t.encode("utf-8")).hexdigest(), 16)
        idx = h % dim
        sign = 1.0 if (h >> 8) & 1 else -1.0
        vec[idx] += sign
    norm = math.sqrt(sum(v * v for v in vec)) or 1.0
    return [v / norm for v in vec]


def try_st_embed(texts: list[str]):
    try:
        from sentence_transformers import SentenceTransformer  # type: ignore
    except Exception:
        return None
    model = SentenceTransformer("sentence-transformers/all-MiniLM-L6-v2")
    arr = model.encode(texts, normalize_embeddings=True)
    return [row.tolist() for row in arr]


def load_components() -> list[dict]:
    rows = []
    with CATALOG.open(encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if line:
                rows.append(json.loads(line))
    return rows


def main() -> int:
    if not CATALOG.exists():
        print(f"missing {CATALOG}", file=sys.stderr)
        return 1
    comps = load_components()
    texts = []
    for c in comps:
        parts = [
            c.get("search_text") or "",
            c.get("description") or "",
            " ".join(c.get("scenarios") or []),
        ]
        texts.append(" ".join(p for p in parts if p).strip() or c["name"])
    vectors = try_st_embed(texts)
    backend = "sentence-transformers/all-MiniLM-L6-v2" if vectors else "hash-v1"
    if vectors is None:
        print("sentence-transformers unavailable; using deterministic hash-embed")
        vectors = [hash_embed(t) for t in texts]
    else:
        print("using sentence-transformers embeddings")

    EMB_DIR.mkdir(parents=True, exist_ok=True)
    index = {"backend": backend, "dim": len(vectors[0]), "items": []}
    for c, vec in zip(comps, vectors):
        rel = c.get("embedding_ref") or f"catalog/embeddings/{c['id'].replace('.', '_')}.json"
        path = ROOT / rel
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(json.dumps({"id": c["id"], "backend": backend, "vector": vec}, ensure_ascii=False), encoding="utf-8")
        index["items"].append({"id": c["id"], "path": rel})
        c["embedding_ref"] = rel

    with CATALOG.open("w", encoding="utf-8") as f:
        for c in comps:
            f.write(json.dumps(c, ensure_ascii=False) + "\n")

    INDEX.write_text(json.dumps(index, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"embedded {len(comps)} components → {EMB_DIR} ({backend})")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
