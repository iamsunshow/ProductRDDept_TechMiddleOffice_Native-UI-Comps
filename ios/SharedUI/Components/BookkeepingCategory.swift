//
//  BookkeepingCategory.swift
//  TMONativeUIComps
//
//  记账分类数据契约类型（v2.0.10 修复）。
//
//  设计意图：
//  v2.0.2 commit `4dc7b19` iOS 对外 API public 化扫尾时，把 `CategoryPickerView` 类
//  改 `public`，但**漏 public 化参数类型 `BookkeepingCategory`** —— 导致任何按 public
//  API 调用 apply(categories: [BookkeepingCategory], ...) 或持有 onSelect:
//  ((BookkeepingCategory) -> Void)? 的代码都被 Swift 严格模式判为「public 属性/
//  方法用 internal 类型」而编译失败。v2.0.10 单独建本文件补齐，与 iOS 端记账业务契约 1:1
//  对齐（name = 分类名 / assetName = 图标资源名 / symbolName = SF Symbol 名）。
//
//  与 v2.0.9 demo 兜底的差异：
//  - `demo/ios/DemoApp/DemoMocks.swift` 之前定义了一个 internal `struct BookkeepingCategory`
//    让 demo 编译通过；本文件 public 后 demo 兜底必须删除，避免同一 module 内同名类型冲突。
//

import Foundation

/// 记账分类。
///
/// - Parameter name: 分类名（如 "餐饮"、"交通"）。
/// - Parameter assetName: 图标资源名（宿主 App 自定义资源路径）。
/// - Parameter symbolName: SF Symbol 系统图标名（兜底图标）。
public struct BookkeepingCategory: Equatable {
    public let name: String
    public let assetName: String
    public let symbolName: String

    public init(name: String, assetName: String, symbolName: String) {
        self.name = name
        self.assetName = assetName
        self.symbolName = symbolName
    }
}