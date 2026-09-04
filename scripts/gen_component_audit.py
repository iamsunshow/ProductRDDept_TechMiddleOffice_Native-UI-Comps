#!/usr/bin/env python3
"""（2026-09-04 起=组件审计台账已并入 docs/组件进度.md 第 1.1 节=本脚本仅供另生成历史快照）从 docs/数据与产物/api.json 生成 docs/组件审计.md（双端一致性对照列表）。

数据源唯一：docs/数据与产物/api.json。展示每组件：名称 / 分类 / 描述 / iOS 命名 / Android 命名 /
使用场景 / 双端一致性标记。命名与 API 一致性判定基于 source_refs 源码命名与
props/events 契约，缺失端标注「—（未实现）」，暴露双端不一致与数据缺口。
"""

from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
API = ROOT / "docs" / "api.json"
OUT = ROOT / "docs" / "组件审计.md"

CAT_CN = {
    "ui": "UI 组件",
    "foundation": "底层能力",
}

SUB_CAT_CN = {
    "basics": "基础通用",
    "navigation": "导航",
    "input": "数据录入",
    "display": "数据展示",
    "feedback": "操作反馈",
}


def file_stem(p: str | None) -> str:
    if not p:
        return "—"
    return p.split("/")[-1]


def naming_consistent(ios: str, andr: str) -> str:
    """双端命名一致性：均实现时按源码名语义判定；单端/双端缺失标注未实现。"""
    if ios == "—" and andr == "—":
        return "—（双端均未实现）"
    if ios == "—" or andr == "—":
        return "—（另一端未实现）"
    # 归一化：去扩展名、去 View/Control/ViewController 等端侧后缀、小写
    def norm(name: str) -> set[str]:
        stem = name.split(".")[0].lstrip("*")
        for suf in ("View", "ViewController", "Control", "TableView", "Cell", "Picker"):
            if stem.endswith(suf):
                stem = stem[: -len(suf)]
        return {w for w in stem.lower().replace("-", "_").split("_") if w}

    a, b = norm(ios), norm(andr)
    # Android 聚合文件（CommonComponents/ProfileListGroup 等）承载多个组件 → 视为待拆分
    if andr in ("CommonComponents.kt", "ProfileListGroup.kt", "ProfileAvatarComponents.kt"):
        return "⚠️ 埋于聚合文件，命名未独立"
    return "✅ 一致" if a == b else "❌ 不一致"


def main() -> None:
    api = json.loads(API.read_text(encoding="utf-8"))
    comps = api["components"]
    comps.sort(key=lambda c: (c["category"], c.get("subcategory", ""), c["id"]))

    rows = []
    for c in comps:
        sr = c.get("source_refs", {})
        ios = sr.get("ios")
        andr = sr.get("android")
        state = "✅ 双端" if (ios and andr) else ("⚠️ 仅 iOS" if ios else ("⚠️ 仅 Android" if andr else "❌ 均未实现"))
        rows.append({
            "name": c.get("name") or c["id"],
            "cat": (
                f"{CAT_CN.get(c['category'], c['category'])} / {SUB_CAT_CN.get(c['subcategory'], c.get('subcategory', ''))}"
                if c.get("subcategory")
                else f"{CAT_CN.get(c['category'], c['category'])}"
            ),
            "desc": (c.get("description") or c.get("summary") or "").strip().replace("|", "\\|").replace("\n", " "),
            "ios": file_stem(ios),
            "andr": file_stem(andr),
            "naming": naming_consistent(file_stem(ios), file_stem(andr)),
            "scenario": "；".join(c.get("scenarios") or ["—"]).replace("|", "\\|"),
            "state": state,
        })

    with OUT.open("w", encoding="utf-8") as f:
        f.write("# 组件双端一致性对照表\n\n")
        f.write(f"> 数据源：`docs/数据与产物/api.json`（{api.get('componentCount', len(comps))} 个组件）· 生成时间 {api.get('updatedAt','')}\n\n")
        f.write("> 目的：审查双端（iOS / Android）代码独立前提下，**组件命名、API 契约**是否保持一致；并暴露单端缺失与数据缺口。\n\n")
        f.write("## 一览\n\n")
        f.write("| 组件名称 | 分类 | 组件描述 | iOS 命名 | Android 命名 | 命名一致 | 使用场景 | 双端状态 |\n")
        f.write("|---------|------|----------|----------|--------------|----------|----------|----------|\n")
        for r in rows:
            f.write(
                f"| {r['name']} | {r['cat']} | {r['desc']} | `{r['ios']}` | `{r['andr']}` "
                f"| {r['naming']} | {r['scenario']} | {r['state']} |\n"
            )

        # 汇总统计
        both = sum(1 for r in rows if "双端" in r["state"] and "仅" not in r["state"])
        ios_only = sum(1 for r in rows if "仅 iOS" in r["state"])
        and_only = sum(1 for r in rows if "仅 Android" in r["state"])
        none = sum(1 for r in rows if "均未实现" in r["state"])
        naming_bad = sum(1 for r in rows if r["naming"].startswith("❌"))
        naming_agg = sum(1 for r in rows if "聚合文件" in r["naming"])

        f.write("\n## 统计\n\n")
        f.write(f"- 双端实现：**{both}** ｜ 仅 iOS：**{ios_only}** ｜ 仅 Android：**{and_only}** ｜ 双端均未实现：**{none}**\n")
        f.write(f"- 双端命名明确不一致：**{naming_bad}** ｜ 命名埋于聚合文件（未独立）：**{naming_agg}**\n")
        f.write("\n## 待办（由本表暴露）\n\n")
        f.write("1. **双端命名对齐**：对 ❌ 不一致组件统一命名（含 iOS/Android 类名、Swift/Kotlin 文件）。\n")
        f.write("2. **单端补全**：⚠️ 仅 iOS / 仅 Android 组件在另一端落地，保持命名与 API 一致。\n")
        f.write("3. **聚合文件拆分**：Android 的 `CommonComponents.kt` / `ProfileListGroup.kt` / `ProfileAvatarComponents.kt` 承载多组件，按组件独立文件。\n")
        f.write("4. **API 契约补全**：多个组件 `apis` / `props` / `events` 为空，需在 `docs/数据与产物/api.json` 补齐，作为双端 API 一致性基准。\n")

    print(f"generated {OUT} ({len(rows)} components)")


if __name__ == "__main__":
    main()
