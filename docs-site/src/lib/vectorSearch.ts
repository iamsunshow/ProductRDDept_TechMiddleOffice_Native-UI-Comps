import { sha256 } from "js-sha256";

const DIM = 256;

function tokenize(text: string): string[] {
  const lower = text.toLowerCase();
  return lower.match(/[a-z0-9_]+|[\u4e00-\u9fff]/g) ?? [];
}

/** Same algorithm as TechMiddleOffice/scripts/embed.py hash-v1 */
export function hashEmbed(text: string, dim = DIM): number[] {
  const vec = new Array(dim).fill(0);
  const toks = tokenize(text);
  if (!toks.length) return vec;
  for (const t of toks) {
    const hex = sha256(t);
    // BigInt from first 16 hex chars is enough for index/sign
    const h = BigInt("0x" + hex.slice(0, 16));
    const idx = Number(h % BigInt(dim));
    const sign = Number((h >> 8n) & 1n) === 1 ? 1 : -1;
    vec[idx] += sign;
  }
  const norm = Math.sqrt(vec.reduce((s, v) => s + v * v, 0)) || 1;
  return vec.map((v) => v / norm);
}

export function cosine(a: number[], b: number[]): number {
  const n = Math.min(a.length, b.length);
  let s = 0;
  for (let i = 0; i < n; i++) s += a[i] * b[i];
  return s;
}

export type SearchHit = { id: string; score: number };

export function vectorSearch(
  query: string,
  items: { id: string; vector?: number[] | null }[],
  k = 20,
): SearchHit[] {
  const q = query.trim();
  if (!q) return [];
  const qv = hashEmbed(q);
  const scored: SearchHit[] = [];
  for (const item of items) {
    if (!item.vector || !item.vector.length) continue;
    scored.push({ id: item.id, score: cosine(qv, item.vector) });
  }
  scored.sort((a, b) => b.score - a.score);
  return scored.slice(0, k);
}
