#!/usr/bin/env python3
"""
业务库 TMO 采用率度量（自研率统计骨架）
====================================

指标定义（见 docs/验收流程/验收标准.md 第七节）：
- UI 代码量：业务库中 UI 相关源文件（Swift / Kotlin）的代码行数与文件数。
- TMO 引用：文件 import / 引用 TMO 组件库模块（iOS 模块名 / Android 包名前缀）视为"使用了组件库"。
- 自研候选：UI 文件中未引用 TMO 的 → 疑似自造轮子（可能应改为 TMO 组件）。
- 业务自研率 = 自研候选 UI 代码量 / 总 UI 代码量（目标持续下降）。

用法：
    python3 measure_adoption.py <业务库根目录> [--ext swift|kt] [--json] [--module-prefix 前缀...]

示例：
    python3 measure_adoption.py ../App/ --ext swift --module-prefix NativeUIComps TMO
    python3 measure_adoption.py ../App/ --ext kt --module-prefix com.xxx.ui

说明：
- 本脚本为可运行骨架；规则（UI 文件识别、模块前缀）按实际工程调整。
- 建议挂入 CI / 定期跑，输出进「TMO 降本度量报告」。
"""

import argparse
import json
import sys
from pathlib import Path

# 默认 TMO 模块标记（iOS 模块名 / Android 包名前缀），可通过 --module-prefix 覆盖
DEFAULT_MODULE_PREFIXES = ["NativeUIComps", "TMO", "com.xxx.ui"]


def is_ui_file(path: Path, ext: str) -> bool:
    """识别 UI 相关源文件（粗略启发式，可按工程细化）。"""
    if path.suffix != f".{ext}":
        return False
    try:
        head = path.read_text(encoding="utf-8", errors="ignore")[:4000]
    except OSError:
        return False
    if ext == "swift":
        markers = [": UIView", ": UIViewController", "SwiftUI.View", ": UIButton", ": UITableView"]
    else:  # kt
        markers = [": Activity", ": Fragment", "@Composable", ": View", ": ViewGroup", ": RecyclerView"]
    return any(m in head for m in markers)


def references_tmo(path: Path, prefixes: list[str]) -> bool:
    """文件内容是否引用 TMO 组件库模块。"""
    try:
        content = path.read_text(encoding="utf-8", errors="ignore")
    except OSError:
        return False
    return any(p in content for p in prefixes)


def scan(root: Path, ext: str, prefixes: list[str]) -> dict:
    stats = {
        "ui_files": 0,
        "ui_lines": 0,
        "tmo_ui_files": 0,
        "tmo_ui_lines": 0,
        "self_made_files": 0,
        "self_made_lines": 0,
        "self_made_samples": [],
    }
    for path in sorted(root.rglob("*")):
        if not is_ui_file(path, ext):
            continue
        lines = sum(1 for _ in path.open(encoding="utf-8", errors="ignore"))
        stats["ui_files"] += 1
        stats["ui_lines"] += lines
        if references_tmo(path, prefixes):
            stats["tmo_ui_files"] += 1
            stats["tmo_ui_lines"] += lines
        else:
            stats["self_made_files"] += 1
            stats["self_made_lines"] += lines
            if len(stats["self_made_samples"]) < 20:
                stats["self_made_samples"].append(str(path))
    stats["self_made_rate"] = (
        stats["self_made_lines"] / stats["ui_lines"] if stats["ui_lines"] else 0.0
    )
    stats["tmo_adoption_rate"] = 1.0 - stats["self_made_rate"]
    return stats


def main() -> int:
    parser = argparse.ArgumentParser(description="业务库 TMO 采用率度量（自研率统计）")
    parser.add_argument("root", type=Path, help="业务代码库根目录")
    parser.add_argument("--ext", choices=["swift", "kt"], default="swift", help="源文件后缀")
    parser.add_argument("--module-prefix", nargs="+", default=DEFAULT_MODULE_PREFIXES,
                        help="TMO 组件库模块名/包名前缀（用于判定是否引用组件库）")
    parser.add_argument("--json", action="store_true", help="输出 JSON")
    args = parser.parse_args()

    if not args.root.is_dir():
        print(f"错误：目录不存在 {args.root}", file=sys.stderr)
        return 1

    result = scan(args.root, args.ext, args.module_prefix)
    if args.json:
        print(json.dumps(result, ensure_ascii=False, indent=2))
    else:
        print(f"UI 源文件数：{result['ui_files']}（共 {result['ui_lines']} 行）")
        print(f"  引用 TMO：{result['tmo_ui_files']} 个文件 / {result['tmo_ui_lines']} 行")
        print(f"  疑似自研：{result['self_made_files']} 个文件 / {result['self_made_lines']} 行")
        print(f"  业务自研率：{result['self_made_rate']:.1%} ｜ TMO 采用率：{result['tmo_adoption_rate']:.1%}")
        if result["self_made_samples"]:
            print("疑似自研样本（前 20）：")
            for s in result["self_made_samples"]:
                print(f"  - {s}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
