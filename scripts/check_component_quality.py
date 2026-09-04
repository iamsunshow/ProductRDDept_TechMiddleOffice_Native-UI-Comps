#!/usr/bin/env python3
"""组件质量门禁脚本（门禁 C1 防线①④ + A6/A7），多组件支持。

覆盖用例（用例 ID 对应《产研部-唯一权威手册》第二章模板；验收留痕见 `docs/组件进度.md`）：
- D6  token 硬编码扫描：实现文件禁写死十六进制色值，且必须引用设计 token
- A6  契约 schema 校验：api.json `ui.<id>` 的 props/events/visual_tokens 合法
- A7  双端命名对齐：双端 props/events 与 api.json 契约命名 100% 一致
- C1  用例映射核对：验收文档用例 ID（D1-D8/A1-A7）在双端测试代码中存在对应测试函数

用例 ID 保留位（脚本型，由本脚本对应函数执行、无需双端测试函数）：D6 / A6 / A7。
该保留位为 Cell 组件先例（`component-acceptance-cell.md` D6=Token 引用、A6=契约 schema、
A7=契约命名对齐），Image 验收文档编号已对齐（2026-09-03 C1 说明）。

用法：
    python3 scripts/check_component_quality.py                 # 校验 Cell（默认）
    python3 scripts/check_component_quality.py --component image   # 校验 Image
    python3 scripts/check_component_quality.py --list          # 列出已支持组件
退出码：0=通过；1=不通过（门禁拦截）。
"""

import argparse
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
API_JSON = ROOT / "docs" / "api.json"
DESIGN_TOKEN_JSON = ROOT / "docs" / "design-token.json"
COMPONENTS_DIR = ROOT / "docs" / "验收流程"
IOS_COMPONENTS = ROOT / "ios" / "SharedUI" / "Components"
ANDROID_COMPONENTS = ROOT / "android" / "sharedui" / "components"
IOS_TESTS = ROOT / "ios" / "Tests"
ANDROID_TESTS = ROOT / "android" / "components" / "src" / "test" / "java" / "com" / "zhiqihuayun" / "sharedui" / "components"

# 脚本型用例：由本脚本对应函数实现（无需双端测试函数）
SCRIPT_CASES = {
    "D6": "check_token_hardcoding",
    "A6": "check_contract_schema",
    "A7": "check_naming_alignment",
}

# 各组件配置。命名对齐字段说明：
# - android_params：Android 实现文件第 4 列参数名清单（正则提取，用于 A7）
# - android_exclude：Android 端不承诺的契约名（如 onLongPress）
# - ios_vars：iOS 实现文件 `var x:` 字段名清单（含事件闭包 var onX）
# - ios_exclude：iOS 端平台化省略的契约名（如 icon→iconSymbol、onClick→onTap、frame 布局类）
# - ios_extra：iOS 平台化新增名（如 iconSymbol）
# - ios_events：iOS 端必须存在的事件闭包子串（契约事件平台化映射）
COMPONENTS = {
    "cell": {
        "label": "Cell",
        "api_id": "ui.cell",
        "acceptance": COMPONENTS_DIR / "component-acceptance-cell.md",
        "ios_impl": IOS_COMPONENTS / "Cell.swift",
        "android_impl": ANDROID_COMPONENTS / "Cell.kt",
        "ios_test": IOS_TESTS / "CellTests.swift",
        "android_test": ANDROID_TESTS / "CellTest.kt",
        "props_required": {"title", "arrow", "disabled", "loading", "status"},
        "events_required": {"onClick"},
        "android_params": ("title", "subtitle", "icon", "value", "arrow", "disabled", "loading", "status", "showsDivider", "onClick"),
        "android_exclude": {"onLongPress"},
        "ios_vars": ("title", "subtitle", "iconSymbol", "value", "arrow", "disabled", "loading", "status"),
        "ios_exclude": {"icon", "onClick", "onLongPress"},
        "ios_extra": {"iconSymbol"},
        "ios_events": ("var onTap", "var onLongPress"),
    },
    "image": {
        "label": "Image",
        "api_id": "ui.image",
        "acceptance": COMPONENTS_DIR / "component-acceptance-image.md",
        "ios_impl": IOS_COMPONENTS / "Image.swift",
        "android_impl": ANDROID_COMPONENTS / "Image.kt",
        "ios_test": IOS_TESTS / "ImageTests.swift",
        "android_test": ANDROID_TESTS / "ImageTest.kt",
        "props_required": {"src"},
        "events_required": {"onTap", "onLoad", "onError"},
        "android_params": ("src", "fit", "position", "width", "height", "radius", "alt", "loadingContent", "errorContent", "onTap", "onLoad", "onError"),
        "android_exclude": set(),
        "ios_vars": ("src", "fit", "position", "radius", "alt", "loadingContent", "errorContent"),
        "ios_exclude": {"width", "height", "onTap", "onLoad", "onError"},  # width/height 经 frame 传入；事件闭包由 ios_events 独立校验（与 Cell onClick→onTap 同型）
        "ios_extra": set(),
        "ios_events": ("var onTap", "var onLoad", "var onError"),
    },
}

failures: list[str] = []


def fail(msg: str) -> None:
    failures.append(msg)
    print(f"  ✗ {msg}")


def check_token_hardcoding(cfg: dict) -> bool:
    """D6：实现文件禁写死色值，且引用设计 token。"""
    hex_color = re.compile(r"(?<![0-9A-Za-z_])0x[0-9A-Fa-f]{6,8}|#[0-9A-Fa-f]{6}\b")
    token_names = ("AppColor", "AppFont", "AppSpace", "AppRadius")
    ok = True
    for label, path in ((f"iOS {cfg['label']}.swift", cfg["ios_impl"]), (f"Android {cfg['label']}.kt", cfg["android_impl"])):
        if not path.exists():
            fail(f"D6 {label}: 文件缺失 {path}")
            ok = False
            continue
        src = path.read_text(encoding="utf-8")
        for m in hex_color.finditer(src):
            fail(f"D6 {label}: 硬编码色值 {m.group(0)} (L{src[:m.start()].count(chr(10)) + 1})")
            ok = False
        missing = [t for t in token_names if t not in src]
        if missing:
            fail(f"D6 {label}: 未引用设计 token {', '.join(missing)}")
            ok = False
    return ok


def _resolve_token(tokens: dict, path: str):
    """按点分路径（如 color.gray.4）在 design-token.json 中解析 token 值。"""
    node = tokens
    for key in path.split("."):
        if not isinstance(node, dict) or key not in node:
            return None
        node = node[key]
    return node


def check_contract_schema(cfg: dict) -> bool:
    """A6：api.json `ui.<id>` 契约 schema 合法。"""
    api = json.loads(API_JSON.read_text(encoding="utf-8"))
    comp = next((c for c in api["components"] if c["id"] == cfg["api_id"]), None)
    if comp is None:
        fail(f"A6: api.json 缺少组件 {cfg['api_id']}")
        return False
    props = {p[0].rstrip("?") for p in comp.get("props", [])}
    events = {e[0].rstrip("?") for e in comp.get("events", [])}
    ok = True
    if not cfg["props_required"].issubset(props):
        fail(f"A6: props 缺少契约字段 {cfg['props_required'] - props}")
        ok = False
    if not cfg["events_required"].issubset(events):
        fail(f"A6: events 缺少契约字段 {cfg['events_required'] - events}")
        ok = False
    tokens = json.loads(DESIGN_TOKEN_JSON.read_text(encoding="utf-8"))
    for vt in comp.get("visual_tokens", []):
        if _resolve_token(tokens, vt) is None:
            fail(f"A6: visual_tokens {vt} 不在 design-token.json")
            ok = False
    return ok


def check_naming_alignment(cfg: dict) -> bool:
    """A7：双端 props/events 命名与 api.json 契约 100% 一致。"""
    api = json.loads(API_JSON.read_text(encoding="utf-8"))
    comp = next(c for c in api["components"] if c["id"] == cfg["api_id"])
    contract_names = {p[0].rstrip("?") for p in comp.get("props", [])} | {
        e[0].rstrip("?") for e in comp.get("events", [])
    }
    ok = True
    # Android：Compose 参数名（平台不承诺项由 cfg['android_exclude'] 免除）
    android_src = cfg["android_impl"].read_text(encoding="utf-8")
    names = "|".join(cfg["android_params"])
    android_params = set(re.findall(rf"^\s{{4}}({names})\s*:", android_src, re.M))
    android_expected = contract_names - cfg["android_exclude"]
    if android_expected - android_params:
        fail(f"A7 Android: 缺失契约参数 {android_expected - android_params}")
        ok = False
    # iOS：`var x:` 属性名 + 事件闭包（平台化映射经 cfg['ios_exclude']/['ios_extra']）
    ios_src = cfg["ios_impl"].read_text(encoding="utf-8")
    ios_names = "|".join(cfg["ios_vars"])
    ios_fields = set(re.findall(rf"^\s{{4}}var ({ios_names})\s*:", ios_src, re.M))
    ios_expected = (contract_names - cfg["ios_exclude"]) | cfg["ios_extra"]
    if ios_expected - ios_fields:
        fail(f"A7 iOS: 缺失契约字段 {ios_expected - ios_fields}")
        ok = False
    for event in cfg["ios_events"]:
        if event not in ios_src:
            fail(f"A7 iOS: 缺失事件 {event.split()[-1]}")
            ok = False
    return ok


def check_case_mapping(cfg: dict) -> bool:
    """C1：验收文档用例 ID ↔ 实现一一对应（测试函数或本脚本函数）。"""
    text = cfg["acceptance"].read_text(encoding="utf-8")
    case_ids = sorted(set(re.findall(r"\b(D[1-8]|A[1-7])\b", text)))
    ok = True
    for case in case_ids:
        if case in SCRIPT_CASES:
            if SCRIPT_CASES[case] not in globals():
                fail(f"C1: 用例 {case} 缺脚本函数 {SCRIPT_CASES[case]}")
                ok = False
            continue
        ios_ok = bool(re.search(rf"func test_{case}_", cfg["ios_test"].read_text(encoding="utf-8")))
        android_ok = bool(re.search(rf"fun test_{case}_", cfg["android_test"].read_text(encoding="utf-8")))
        if not ios_ok:
            fail(f"C1 iOS: 用例 {case} 缺测试函数（test_{case}_*）")
            ok = False
        if not android_ok:
            fail(f"C1 Android: 用例 {case} 缺测试函数（test_{case}_*）")
            ok = False
    return ok


def run_component(cfg: dict) -> bool:
    print(f"组件质量门禁：{cfg['label']}（门禁 C1 防线 ①④ + A6/A7）")
    results = {
        "D6 token 硬编码扫描": check_token_hardcoding(cfg),
        "A6 契约 schema 校验": check_contract_schema(cfg),
        "A7 双端命名对齐": check_naming_alignment(cfg),
        "C1 用例映射核对": check_case_mapping(cfg),
    }
    print()
    for name, ok in results.items():
        print(f"  {'✅' if ok else '✗ FAIL'} {name}")
    return not failures


def main() -> int:
    parser = argparse.ArgumentParser(description="组件质量门禁脚本")
    parser.add_argument("--component", choices=list(COMPONENTS), default="cell",
                        help="要校验的组件（默认 cell）")
    parser.add_argument("--list", action="store_true", help="列出已支持组件")
    args = parser.parse_args()
    if args.list:
        for cid, cfg in COMPONENTS.items():
            print(f"  {cid:<6} {cfg['label']:<6} 契约 {cfg['api_id']}  验收 {cfg['acceptance'].name}")
        return 0
    ok = run_component(COMPONENTS[args.component])
    if failures:
        print(f"\n结果：不通过（{len(failures)} 项问题）")
        return 1
    print("\n结果：全部通过 ✅")
    return 0


if __name__ == "__main__":
    sys.exit(main())
