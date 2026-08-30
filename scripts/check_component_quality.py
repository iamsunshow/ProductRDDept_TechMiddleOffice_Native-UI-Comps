#!/usr/bin/env python3
"""组件质量门禁脚本（门禁 C1 防线①④ + A6/A7）。

覆盖用例（与 `docs/验收流程/component-acceptance-cell.md` 用例 ID 对应）：
- D6  token 硬编码扫描：Cell 实现文件禁写死十六进制色值，且必须引用设计 token
- A6  契约 schema 校验：api.json `ui.cell` 的 props/events/visual_tokens 合法
- A7  双端命名对齐：双端 props/events 与 api.json 契约命名 100% 一致
- C1  用例映射核对：验收文档用例 ID（D1-D8/A1-A7）在双端测试代码中存在对应测试函数

用法：
    python3 scripts/check_component_quality.py          # 校验 Cell 组件
    python3 scripts/check_component_quality.py --list   # 支持扩展其他组件（预留）
退出码：0=通过；1=不通过（门禁拦截）。
"""

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
API_JSON = ROOT / "docs" / "api.json"
DESIGN_TOKEN_JSON = ROOT / "docs" / "design-token.json"
ACCEPTANCE = ROOT / "docs" / "验收流程" / "component-acceptance-cell.md"
IOS_CELL = ROOT / "ios" / "SharedUI" / "Components" / "Cell.swift"
ANDROID_CELL = ROOT / "android" / "sharedui" / "components" / "Cell.kt"
IOS_TEST = ROOT / "ios" / "Tests" / "CellTests.swift"
ANDROID_TEST = ROOT / "android" / "components" / "src" / "test" / "java" / "com" / "zhiqihuayun" / "sharedui" / "components" / "CellTest.kt"

COMPONENT_ID = "ui.cell"
# 实现文件内允许的字面量（非设计 token）：UI 常量（1px 分隔线）、动画参数、布局比例
ALLOWED_LITERALS = (
    "1",          # 1px 分隔线厚度
    "0.35", "0.8", "800",  # 骨架动画透明度/时长
    "0.4",        # 骨架占位宽度比例
    "0.35f", "0.8f", "800L",  # Kotlin 形式
    "0.4f",
    "1f", "0f",
)

failures: list[str] = []


def fail(msg: str) -> None:
    failures.append(msg)
    print(f"  ✗ {msg}")


def check_token_hardcoding() -> bool:
    """D6：实现文件禁写死色值，且引用设计 token。"""
    hex_color = re.compile(r"(?<![0-9A-Za-z_])0x[0-9A-Fa-f]{6,8}|#[0-9A-Fa-f]{6}\b")
    token_names = ("AppColor", "AppFont", "AppSpace", "AppRadius")
    ok = True
    for label, path in (("iOS Cell.swift", IOS_CELL), ("Android Cell.kt", ANDROID_CELL)):
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


def check_contract_schema() -> bool:
    """A6：api.json `ui.cell` 契约 schema 合法。"""
    api = json.loads(API_JSON.read_text(encoding="utf-8"))
    comp = next((c for c in api["components"] if c["id"] == COMPONENT_ID), None)
    if comp is None:
        fail(f"A6: api.json 缺少组件 {COMPONENT_ID}")
        return False
    props = {p[0] for p in comp.get("props", [])}
    events = {e[0] for e in comp.get("events", [])}
    ok = True
    if "title" not in props:
        fail("A6: props 缺少必填 title")
        ok = False
    required = {"title", "arrow", "disabled", "loading", "status"}
    if not required.issubset(props):
        fail(f"A6: props 缺少契约字段 {required - props}")
        ok = False
    if "onClick" not in events:
        fail("A6: events 缺少 onClick")
        ok = False
    tokens = json.loads(DESIGN_TOKEN_JSON.read_text(encoding="utf-8"))
    for vt in comp.get("visual_tokens", []):
        if _resolve_token(tokens, vt) is None:
            fail(f"A6: visual_tokens {vt} 不在 design-token.json")
            ok = False
    return ok


def check_naming_alignment() -> bool:
    """A7：双端 props/events 命名与 api.json 契约 100% 一致。"""
    api = json.loads(API_JSON.read_text(encoding="utf-8"))
    comp = next(c for c in api["components"] if c["id"] == COMPONENT_ID)
    contract_names = {p[0].rstrip("?") for p in comp.get("props", [])} | {
        e[0].rstrip("?") for e in comp.get("events", [])
    }
    ok = True
    # Android：Compose 参数名（onLongPress 不承诺，平台差异已登记）
    android_src = ANDROID_CELL.read_text(encoding="utf-8")
    android_params = set(re.findall(r"^\s{4}(title|subtitle|icon|value|arrow|disabled|loading|status|showsDivider|onClick)\s*:", android_src, re.M))
    android_expected = contract_names - {"onLongPress"}
    if android_expected - android_params:
        fail(f"A7 Android: 缺失契约参数 {android_expected - android_params}")
        ok = False
    # iOS：CellModel 属性名 + 事件闭包（onClick→onTap、icon→iconSymbol 平台化映射）
    ios_src = IOS_CELL.read_text(encoding="utf-8")
    ios_fields = set(re.findall(r"^\s{4}var (title|subtitle|iconSymbol|value|arrow|disabled|loading|status)\s*:", ios_src, re.M))
    ios_expected = (contract_names - {"icon", "onClick", "onLongPress"}) | {"iconSymbol"}
    if ios_expected - ios_fields:
        fail(f"A7 iOS: 缺失契约字段 {ios_expected - ios_fields}")
        ok = False
    for event in ("var onTap", "var onLongPress"):
        if event not in ios_src:
            fail(f"A7 iOS: 缺失事件 {event.split()[-1]}（契约 onClick→onTap 平台化）")
            ok = False
    return ok


# 脚本型用例：由本脚本对应函数实现（无需双端测试函数）
SCRIPT_CASES = {
    "D6": "check_token_hardcoding",
    "A6": "check_contract_schema",
    "A7": "check_naming_alignment",
}


def check_case_mapping() -> bool:
    """C1：验收文档用例 ID ↔ 实现一一对应（测试函数或本脚本函数）。"""
    text = ACCEPTANCE.read_text(encoding="utf-8")
    case_ids = sorted(set(re.findall(r"\b(D[1-8]|A[1-7])\b", text)))
    ok = True
    for case in case_ids:
        if case in SCRIPT_CASES:
            if SCRIPT_CASES[case] not in globals():
                fail(f"C1: 用例 {case} 缺脚本函数 {SCRIPT_CASES[case]}")
                ok = False
            continue
        ios_ok = bool(re.search(rf"func test_{case}_", IOS_TEST.read_text(encoding="utf-8")))
        android_ok = bool(re.search(rf"fun test_{case}_", ANDROID_TEST.read_text(encoding="utf-8")))
        if not ios_ok:
            fail(f"C1 iOS: 用例 {case} 缺测试函数（test_{case}_*）")
            ok = False
        if not android_ok:
            fail(f"C1 Android: 用例 {case} 缺测试函数（test_{case}_*）")
            ok = False
    return ok


def main() -> int:
    print("组件质量门禁：Cell（门禁 C1 防线 ①④ + A6/A7）")
    results = {
        "D6 token 硬编码扫描": check_token_hardcoding(),
        "A6 契约 schema 校验": check_contract_schema(),
        "A7 双端命名对齐": check_naming_alignment(),
        "C1 用例映射核对": check_case_mapping(),
    }
    print()
    for name, ok in results.items():
        print(f"  {'✅' if ok else '✗ FAIL'} {name}")
    if failures:
        print(f"\n结果：不通过（{len(failures)} 项问题）")
        return 1
    print("\n结果：全部通过 ✅")
    return 0


if __name__ == "__main__":
    sys.exit(main())
