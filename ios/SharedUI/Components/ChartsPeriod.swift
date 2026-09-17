//
//  ChartsPeriod.swift
//  TMONativeUIComps
//
//  图表周期枚举（v1.0.10 修复）。
//
//  设计意图：
//  v1.0.2 commit `4dc7b19` iOS 对外 API public 化扫尾时，把 `PeriodTabsView` 类
//  改 `public`，但**漏 public 化参数类型 `ChartsPeriod`** —— 导致任何按 public
//  API 持有 onChange: ((ChartsPeriod) -> Void)? 的代码都被 Swift 严格模式判为
//  「public 属性用 internal 类型」而编译失败。v1.0.10 单独建本文件补齐。
//
//  与 v1.0.9 demo 兜底的差异：
//  - `demo/ios/DemoApp/DemoMocks.swift` 之前定义了一个 internal `enum ChartsPeriod`
//    让 demo 编译通过；本文件 public 后 demo 兜底必须删除，避免同一 module 内
//    同名类型冲突。
//

import Foundation

/// 图表统计周期。
public enum ChartsPeriod: Int, CaseIterable {
    /// 周
    case week
    /// 月
    case month
    /// 年
    case year

    /// 显示标题（"周" / "月" / "年"）。
    public var title: String {
        switch self {
        case .week: return "周"
        case .month: return "月"
        case .year: return "年"
        }
    }
}