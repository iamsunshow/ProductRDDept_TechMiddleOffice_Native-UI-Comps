//
//  ChartPoint.swift
//  TMONativeUIComps
//
//  趋势折线图数据点（对标 Android TrendChartView.kt ChartPoint）。
//
//  设计意图（v1.0.10 修复 · 2026-09-16）：
//  TrendChartView v1.0.2 public 化时只 public 了类本身，漏 public 化参数类型
//  `ChartPoint` —— 导致任何按 public API 调用 apply(expensePoints: [ChartPoint], ...)
//  的代码（含 demo 与宿主 App）都被 Swift 严格模式判为「public 方法用 internal 类型」
//  而编译失败。v1.0.10 单独建本文件补齐，与 Android `data class ChartPoint(label, amount)`
//  字段 1:1 对齐（label: X 轴标签 / amount: 数值），保证双端契约一致。
//
//  与 v1.0.9 demo 兜底的差异：
//  - `demo/ios/DemoApp/DemoMocks.swift` 之前定义了一个 internal `struct ChartPoint`
//    让 demo 编译通过；本文件 public 后 demo 兜底必须删除，避免同一 module 内同名类型冲突。
//

import Foundation

/// 趋势折线图数据点。
///
/// - Parameter label: X 轴标签（如 "1 月"、"周一"）。
/// - Parameter amount: 数值。
public struct ChartPoint: Equatable {
    public let label: String
    public let amount: Double

    public init(label: String, amount: Double) {
        self.label = label
        self.amount = amount
    }
}