#!/usr/bin/env python3
"""双端 Demo 场景定义一致性门禁（门禁 C1 防线：demo 还原度第一层）。

目的：双端 Demo 页的「场景定义」必须一一对应，防止出现「iOS 写了副标题但
Android 没写 / 一端是禁用态另一端是正常态 / 行数不一致」这类低级错误。
这是「视觉还原度」的第一道防线：定义一致是还原度一致的必要条件。

校验原理：
  1. 从 iOS demo 源码（DemoShowcases.swift）解析出各组件 Demo 的场景表；
  2. 从 Android demo 源码（MainActivity.kt）解析出对应组件 Demo 的场景表；
  3. 归一化（平台字段名 → 语义字段）后逐行逐字段 diff；
  4. 任何不一致即报错并定位到「组件 / 行号 / 字段 / 双端值」。

归一化字段（跨平台语义）：
  title         主标题
  subtitle      副标题（空 = 无）
  value         右侧值文本
  arrow         是否显示右侧箭头
  disabled      禁用态
  loading       加载态
  status        normal / success / error
  has_icon      该行是否显式设置了图标（true/false）

不纳入本脚本的范围（职责划分）：
  - showsDivider 等「组件能力差异」由 check_component_quality.py 的 A6/A7
    契约校验负责，本脚本只保证 demo 场景定义在组件能力内对齐。

用法：
    python3 scripts/check_demo_parity.py            # 校验所有已登记组件
    python3 scripts/check_demo_parity.py --list     # 列出已登记组件

退出码：0=通过；1=不通过（门禁拦截）。
"""

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
IOS_DEMO = ROOT / "demo" / "ios" / "DemoApp" / "DemoShowcases.swift"
ANDROID_DEMO = ROOT / "demo" / "android" / "app" / "src" / "main" / "java" / "com" / "zhiqihuayun" / "demo" / "MainActivity.kt"
IOS_CELL_TEST = ROOT / "ios" / "Tests" / "CellTests.swift"
ANDROID_CELL_TEST = ROOT / "android" / "components" / "src" / "test" / "java" / "com" / "zhiqihuayun" / "sharedui" / "components" / "CellTest.kt"

failures: list[str] = []


def fail(msg: str) -> None:
    failures.append(msg)
    print(f"  ✗ {msg}")


# ---------------------------------------------------------------------------
# 平台字段名 → 归一化字段 的映射
# ---------------------------------------------------------------------------
# iOS 用 `key: value`，Android 用 `key = value`。归一化统一用「语义字段」。
_NORMALIZED_FIELDS = ("title", "subtitle", "value", "arrow", "disabled",
                      "loading", "status", "has_icon")

# status 的归一化值映射：iOS 用 .success，Android 用 CellStatus.Success
_STATUS_MAP = {
    ".success": "success", "CellStatus.Success": "success",
    ".error": "error", "CellStatus.Error": "error",
    ".normal": "normal", "CellStatus.Normal": "normal",
    "CellStatus.Normal": "normal",
}


def _norm_status(raw: str) -> str:
    raw = raw.strip()
    return _STATUS_MAP.get(raw, raw)


# ---------------------------------------------------------------------------
# iOS demo 解析：解析 `CellModel(...)` 调用序列
# ---------------------------------------------------------------------------
_IOS_CALL = re.compile(r"CellModel\s*\(([^()]*)\)")


def _parse_kv_ios(body: str) -> dict:
    """解析 iOS 参数 `key: value`（value 含字符串/布尔/SF Symbol 名）。"""
    fields: dict[str, str] = {}
    # 用逗号分隔参数，但需跳过字符串内的逗号
    for m in re.finditer(r"(\w+)\s*:\s*(\"[^\"]*\"|[^,]+)", body):
        key, val = m.group(1), m.group(2).strip()
        if val.startswith('"') and val.endswith('"'):
            val = val[1:-1]
        fields[key] = val
    return fields


def _parse_ios_cell_rows() -> list[dict]:
    src = IOS_DEMO.read_text(encoding="utf-8")
    rows: list[dict] = []
    for i, m in enumerate(_IOS_CALL.finditer(src)):
        body = m.group(1)
        if body.strip() == "":
            continue
        kv = _parse_kv_ios(body)
        row = {
            "line": src[:m.start()].count("\n") + 1,
            "title": kv.get("title", ""),
            "subtitle": kv.get("subtitle", ""),
            "value": kv.get("value", ""),
            "arrow": None if "arrow" not in kv else kv["arrow"].lower() == "true",
            "disabled": None if "disabled" not in kv else kv["disabled"].lower() == "true",
            "loading": None if "loading" not in kv else kv["loading"].lower() == "true",
            "status": _norm_status(kv.get("status", "")),
            "has_icon": "iconSymbol" in kv,
        }
        rows.append(row)
    return rows


# ---------------------------------------------------------------------------
# Android demo 解析：解析 `Cell(...)` 调用序列（多行跨行）
# ---------------------------------------------------------------------------
def _split_top_level(text: str, sep: str) -> list[str]:
    """按顶层分隔符切分：跳过引号内与括号内的 sep（处理含逗号的字符串）。"""
    parts: list[str] = []
    buf: list[str] = []
    depth = 0
    in_str = False
    i = 0
    while i < len(text):
        c = text[i]
        if c == '"' and text[i - 1] != "\\" if i > 0 else c == '"':
            in_str = not in_str
            buf.append(c)
            i += 1
            continue
        if not in_str and c in "([{":
            depth += 1
            buf.append(c)
        elif not in_str and c in ")]}":
            depth -= 1
            buf.append(c)
        elif not in_str and depth == 0 and text.startswith(sep, i):
            parts.append("".join(buf).strip())
            buf = []
            i += len(sep)
            continue
        else:
            buf.append(c)
        i += 1
    if buf:
        parts.append("".join(buf).strip())
    return parts


def _parse_android_cell_rows() -> list[dict]:
    src = ANDROID_DEMO.read_text(encoding="utf-8")
    rows: list[dict] = []
    # 用括号深度切出每个 `Cell(...)` 的完整 body（含跨行）
    for m in re.finditer(r"\bCell\s*\(", src):
        start = m.end()
        depth = 1
        i = start
        while i < len(src) and depth > 0:
            c = src[i]
            if c == '"':
                i += 1
                while i < len(src) and src[i] != '"':
                    i += 1
            elif c == "(":
                depth += 1
            elif c == ")":
                depth -= 1
            i += 1
        body = src[start:i - 1]
        # 顶层按逗号切参数，跳过引号与括号内的逗号
        kv: dict[str, str] = {}
        for param in _split_top_level(body, ","):
            km = re.match(r"(\w+)\s*=\s*(.+)", param.strip())
            if not km:
                continue
            key, val = km.group(1), km.group(2).strip()
            if val.startswith('"') and val.endswith('"'):
                val = val[1:-1]
            kv[key] = val
        row = {
            "line": src[:m.start()].count("\n") + 1,
            "title": kv.get("title", ""),
            "subtitle": kv.get("subtitle", ""),
            "value": kv.get("value", ""),
            "arrow": None if "arrow" not in kv else kv["arrow"].lower() == "true",
            "disabled": None if "disabled" not in kv else kv["disabled"].lower() == "true",
            "loading": None if "loading" not in kv else kv["loading"].lower() == "true",
            "status": _norm_status(kv.get("status", "")),
            "has_icon": "icon" in kv and "rememberVectorPainter" in kv["icon"],
        }
        rows.append(row)
    return rows


def _parse_android_cell_bodies() -> list[tuple[str, int]]:
    """返回每个 `Cell(...)` 的 (完整 body, 起始行号)，跨行兼容，供编排层检查用。"""
    src = ANDROID_DEMO.read_text(encoding="utf-8")
    out: list[tuple[str, int]] = []
    for m in re.finditer(r"\bCell\s*\(", src):
        start = m.end()
        depth = 1
        i = start
        while i < len(src) and depth > 0:
            c = src[i]
            if c == '"':
                i += 1
                while i < len(src) and src[i] != '"':
                    i += 1
            elif c == "(":
                depth += 1
            elif c == ")":
                depth -= 1
            i += 1
        body = src[start:i - 1]
        line = src[:m.start()].count("\n") + 1
        out.append((body, line))
    return out


# ---------------------------------------------------------------------------
# diff
# ---------------------------------------------------------------------------
def _norm(v):
    """None（未显式声明）按默认值归一化，便于跨端比较。"""
    return v if v is not None else False


def check_cell_parity() -> bool:
    """双端 ui.cell Demo 场景定义一致性。"""
    if not IOS_DEMO.exists():
        fail(f"iOS demo 文件缺失: {IOS_DEMO}")
        return False
    if not ANDROID_DEMO.exists():
        fail(f"Android demo 文件缺失: {ANDROID_DEMO}")
        return False

    ios_rows = _parse_ios_cell_rows()
    android_rows = _parse_android_cell_rows()
    ok = True

    if len(ios_rows) != len(android_rows):
        fail(f"ui.cell: 行数不一致 iOS={len(ios_rows)} Android={len(android_rows)}")
        ok = False

    n = max(len(ios_rows), len(android_rows))
    for idx in range(n):
        label = f"ui.cell 第{idx + 1}行"
        ios_row = ios_rows[idx] if idx < len(ios_rows) else None
        and_row = android_rows[idx] if idx < len(android_rows) else None
        if ios_row is None or and_row is None:
            missing = "Android" if ios_row is not None else "iOS"
            fail(f"{label}: {missing} 侧缺失该行")
            ok = False
            continue
        for field in _NORMALIZED_FIELDS:
            iv = _norm(ios_row[field])
            av = _norm(and_row[field])
            # title 是定位主键，单独作为锚点，也纳入 diff
            if iv != av:
                fail(f"{label} 字段[{field}] 不一致: iOS({ios_row['line']})={iv!r}  Android({and_row['line']})={av!r}")
                ok = False
    return ok


# ---------------------------------------------------------------------------
# demo 编排层一致性：把「今天调试 cell 一天踩的坑」固化成可自动门禁，
# 防止回归，降低双端对齐的沟通成本。
#
# 覆盖的回归点（均映射到已修复的 bug）：
#   ORC1 顶部元素顺序（iOS insert(at:) 索引冲突 → v1.13 修复）
#   ORC2 反馈文案带实测高度（iOS 缺高度 → v1.16 修复）
#   ORC3 空行有兜底命名，不出现「点击了：」后无字（iOS → v1.15 修复）
#   ORC4 可点击 cell 传了 onClick/onTap，禁用 cell 不传（Android 点击态缺失 → 修复）
#   ORC5 双端版本号一致（addVersionBadge vs Cell 组件 v1.x）
# ---------------------------------------------------------------------------

def check_demo_orchestration() -> bool:
    """双端 demo 编排层回归门禁（ORC 系列）。"""
    ok = True
    ios_src = IOS_DEMO.read_text(encoding="utf-8")
    and_src = ANDROID_DEMO.read_text(encoding="utf-8")

    # ---- ORC1 顶部元素顺序 ----
    # iOS：三个 helper 的 insert 索引必须满足 徽标(0) < 参考块(1) < 反馈条(2)，
    #      且 viewDidLoad 中先 addHeightReference 后 addFeedbackBar。
    ios_ref_index = re.search(r"insertArrangedSubview\(stack, at:\s*(\d+)\)", ios_src)
    ios_fb_index = re.search(r"insertArrangedSubview\(label, at:\s*(?:min\(\s*)?(\d+)", ios_src)
    ios_badge_index = re.search(r"insertArrangedSubview\(badge, at:\s*(\d+)\)", ios_src)
    if ios_badge_index and ios_ref_index and ios_fb_index:
        b, r, f = (int(m.group(1)) for m in (ios_badge_index, ios_ref_index, ios_fb_index))
        if not (b < r < f):
            fail(f"ui.cell ORC1 顶部顺序: iOS insert 索引应为 徽标({b}) < 参考块({r}) < 反馈条({f})，请检查 insertArrangedSubview at:")
            ok = False
    else:
        fail("ui.cell ORC1: iOS 未找到 addVersionBadge/addHeightReference/addFeedbackBar 的 insert 索引")
        ok = False
    # viewDidLoad 内先 addHeightReference 后 addFeedbackBar
    vdl = ios_src[ios_src.index("final class CellShowcase"):]
    ref_pos = vdl.find("addHeightReference()")
    fb_pos = vdl.find("addFeedbackBar()")
    if ref_pos == -1 or fb_pos == -1 or ref_pos > fb_pos:
        fail("ui.cell ORC1: iOS viewDidLoad 应先 addHeightReference() 后 addFeedbackBar()（参考块在上、反馈条在下）")
        ok = False
    # Android：高度参考文字与色块须出现在 clickInfo 反馈条之前
    ref_text_pos = and_src.find("高度参考")
    click_info_pos = and_src.find("点击任意 cell 查看按压变色")
    if ref_text_pos == -1 or click_info_pos == -1 or ref_text_pos > click_info_pos:
        fail("ui.cell ORC1: Android 顶部顺序应为 徽标→高度参考→反馈条（'高度参考'须在'点击任意 cell'之前）")
        ok = False

    # ---- ORC2 反馈文案带实测高度 ----
    ios_ht = "（实测高度" in ios_src and "pt）" in ios_src
    and_ht = "（实测高度" in and_src and "dp）" in and_src
    if not ios_ht:
        fail("ui.cell ORC2: iOS 反馈条应带实测高度文案（含'（实测高度 … pt）'）")
        ok = False
    if not and_ht:
        fail("ui.cell ORC2: Android 反馈条应带实测高度文案（含'（实测高度 … dp）'）")
        ok = False

    # ---- ORC3 空行兜底命名 ----
    # iOS：rowName 里空行要拼「空行-N」，绝不返回空串（否则反馈条只剩「点击了：」）
    if "空行-" not in ios_src:
        fail("ui.cell ORC3: iOS rowName 需对空行做兜底命名（'空行-N'），防止反馈条'点击了：'后无字")
        ok = False
    # Android：空行 label 应显式传非空名（如 ① 空行-1），而不是直接用空 title
    if "空行-1" not in and_src or 'Cell(title = ""' not in and_src:
        fail("ui.cell ORC3: Android 空行 cell 应显式命名（'空行-1'）并保留空 title，确保反馈有可读行名")
        ok = False

    # ---- ORC4 可点击 cell 传 onClick/onTap ----
    # Android：禁用/加载态 Cell 不带 onClick；其它 Cell 必须带 onClick（否则点击态失效，v1.8 修复点）。
    # 复用括号深度解析，兼容跨行 Cell(...)。
    and_cells = _parse_android_cell_bodies()
    for body, line in and_cells:
        is_inert = ("disabled = true" in body) or ("loading = true" in body)
        if is_inert:
            if "onClick" in body:
                fail(f"ui.cell ORC4: Android 禁用/加载态 Cell 不应带 onClick（L{line}）")
                ok = False
        elif "onClick" not in body:
            fail(f"ui.cell ORC4: Android 存在未传 onClick 的可点击 Cell（L{line}，点击态将失效，v1.8 修复点）")
            ok = False

    # ---- ORC5 双端版本号一致 ----
    ios_ver = re.search(r'addVersionBadge\(version:\s*"([^"]+)"', ios_src)
    and_ver = re.search(r'"Cell 组件\s*(v[\d.]+)"', and_src)
    if ios_ver and and_ver:
        # iOS 版本形如 v1.16；Android 取 v1.16
        if ios_ver.group(1).strip() != and_ver.group(1).strip():
            fail(f"ui.cell ORC5: 版本号不一致 iOS={ios_ver.group(1)!r} Android={and_ver.group(1)!r}")
            ok = False
    else:
        fail("ui.cell ORC5: 未提取到双端版本号（iOS addVersionBadge / Android 'Cell 组件 vX.Y'）")
        ok = False

    # ---- ORC6 双端组件测试用例对等性 ----
    # 防止「一端加了用例另一端漏」——今天两端不一致的根因往往就是单端改动。
    # 提取两端 Cell 测试的用例 ID（Android `fun test_Dx/Ax_...`，iOS `func test_Dx/Ax_...`）。
    # 仅对 D/A 系列强制对等（与 regression-lessons 文档 ORC6 描述一致）；
    # H 系列为平台特有用例，命名不对等是**设计使然**，不纳入对等门禁：
    #   - iOS H3/H3b：token 层断言「v1.18 起不补偿」+ 实测辅助可用性（iOS 特有 baselineOffset 概念）；
    #   - Android H4：Robolectric 渲染层断言「title 节点垂直中心 ≈ cell-root 中心」（Android 无补偿函数，等价契约由渲染断言承载）。
    ios_tests_src = IOS_CELL_TEST.read_text(encoding="utf-8")
    and_tests_src = ANDROID_CELL_TEST.read_text(encoding="utf-8")
    _ids = lambda src: {
        m for m in re.findall(r"\b(?:func|fun)\s+test_([A-Za-z0-9_]+)\s*\(", src)
        if m.split("_", 1)[0] in ("D", "A")
    }
    ios_ids = _ids(ios_tests_src)
    and_ids = _ids(and_tests_src)
    if ios_ids != and_ids:
        only_ios = ios_ids - and_ids
        only_and = and_ids - ios_ids
        if only_ios:
            fail(f"ui.cell ORC6: iOS 有而 Android 缺失的 D/A 测试用例: {sorted(only_ios)}")
        if only_and:
            fail(f"ui.cell ORC6: Android 有而 iOS 缺失的 D/A 测试用例: {sorted(only_and)}")
        ok = False

    return ok


COMPONENT_CHECKS = {
    "ui.cell": check_cell_parity,
    "ui.cell.orch": check_demo_orchestration,
}


def main() -> int:
    print("双端 Demo 场景定义一致性门禁")
    if "--list" in sys.argv:
        for cid in COMPONENT_CHECKS:
            print(f"  - {cid}")
        return 0
    results = {}
    for cid, fn in COMPONENT_CHECKS.items():
        results[cid] = fn()
    print()
    for cid, ok in results.items():
        print(f"  {'✅' if ok else '✗ FAIL'} {cid}")
    if failures:
        print(f"\n结果：不通过（{len(failures)} 项不一致）")
        return 1
    print("\n结果：全部通过 ✅")
    return 0


if __name__ == "__main__":
    sys.exit(main())
