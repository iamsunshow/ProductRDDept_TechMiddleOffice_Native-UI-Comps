/// Price 价格组件（UIKit 版，对齐 Android Price）。
///
/// 商品/订单/账本等场景的金额展示——由「前缀文本 + 货币符号 + 整数部分 + 小数部分 + 后缀文本」
/// 组成的行内价格。price 数值驱动，支持 decimalPlaces 小数位、thousands 千分位、
/// symbol 货币符号及大小/位置（front/after）、prefix/suffix 自定义前后缀、
/// size 尺寸档位（small/medium/large）、color 价格主色。
///
/// 用法：
/// ```swift
/// let price = PriceView(price: 199)
/// // 或配置属性
/// price.decimalPlaces = 0
/// price.symbol = "元"
/// price.symbolPosition = .after
/// ```
///
/// 决策（与设计规格 price-design-spec.html 一致）：
/// - P1-A price=Double 数值驱动，千分位/小数位由组件统一格式化
/// - P2-A thousands=true + decimalPlaces=2 默认
/// - P3-A 符号独立 symbolSize + symbolPosition front/after
/// - P4-A prefix/suffix 自定义前后缀文本（textSecondary、小字号）

import UIKit
import SnapKit

/// 价格尺寸档位。
enum PriceSize {
    case small
    case medium
    case large

    /// 整数部分字号。
    var integerFontSize: CGFloat {
        switch self {
        case .small: return AppFont.sizeMd   // 16
        case .medium: return AppFont.sizeXl  // 22
        case .large: return AppFont.sizeDisplay // 32
        }
    }

    /// 符号/小数部分字号。
    var symbolFontSize: CGFloat {
        switch self {
        case .small: return AppFont.sizeXs  // 12
        case .medium: return AppFont.sizeSm // 14
        case .large: return AppFont.sizeLg  // 16
        }
    }
}

/// 货币符号位置。
enum PriceSymbolPosition {
    /// 前置：符号在数字左侧（如 ¥199）。
    case front
    /// 后置：符号在数字右侧（如 199元）。
    case after
}

final class PriceView: UIView {
    // MARK: - 配置属性

    /// 价格数值，默认 0。
    var price: Double = 0 { didSet { render() } }

    /// 货币符号，默认 "¥"；空字符串则不显示符号。
    var symbol: String = "¥" { didSet { render() } }

    /// 小数位数，默认 2；0 表示不显示小数部分。
    var decimalPlaces: Int = 2 { didSet { render() } }

    /// 是否显示千分位分隔符，默认 true。
    var thousands: Bool = true { didSet { render() } }

    /// 价格尺寸档位，默认 .medium。
    var size: PriceSize = .medium { didSet { render() } }

    /// 货币符号位置，默认 .front（前置）。
    var symbolPosition: PriceSymbolPosition = .front { didSet { render() } }

    /// 价格主色（符号 + 整数 + 小数），默认 danger 红。
    var color: UIColor = AppColor.error { didSet { render() } }

    /// 前缀文本（textSecondary、小字号），默认空。
    var prefix: String = "" { didSet { render() } }

    /// 后缀文本（textSecondary、小字号），默认空。
    var suffix: String = "" { didSet { render() } }

    // MARK: - 子视图

    /// 行内容器：prefix / 符号 / 整数 / 小数 / suffix 按顺序排列。
    private let stack: UIStackView = {
        let s = UIStackView()
        s.axis = .horizontal
        s.alignment = .lastBaseline
        s.spacing = AppSpace.xs
        return s
    }()

    private let prefixLabel = UILabel()
    private let symbolLabel = UILabel()
    private let integerLabel = UILabel()
    private let decimalLabel = UILabel()
    private let suffixLabel = UILabel()

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    init(price: Double = 0) {
        self.price = price
        super.init(frame: .zero)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("PriceView does not support NSCoder")
    }

    private func setup() {
        addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        render()
    }

    // MARK: - 格式化

    /// 将 price 按 decimalPlaces 四舍五入后拆分为「整数部分 + 小数部分」字符串。
    private func splitParts() -> (integer: String, decimal: String) {
        let places = max(0, decimalPlaces)
        let factor = pow(10.0, Double(places))
        // 四舍五入到指定位数。
        let rounded = (price * factor).rounded() / factor
        // NumberFormatter 统一处理千分位与小数位。
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = thousands
        formatter.groupingSeparator = ","
        formatter.minimumFractionDigits = places
        formatter.maximumFractionDigits = places
        let formatted = formatter.string(from: NSNumber(value: rounded)) ?? "\(rounded)"

        if places == 0 {
            return (formatted, "")
        }
        // 按小数点拆分（地区无关，formatter 内部 decimalSeparator 固定为 "."）。
        let sep = formatter.decimalSeparator ?? "."
        if let range = formatted.range(of: sep) {
            let intPart = String(formatted[formatted.startIndex..<range.lowerBound])
            let decPart = String(formatted[range.upperBound...])
            return (intPart, decPart)
        }
        return (formatted, "")
    }

    // MARK: - 渲染

    private func render() {
        // 清空已排列子视图，按当前配置重建。
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let parts = splitParts()
        let intFont = UIFont.systemFont(ofSize: size.integerFontSize, weight: .bold)
        let symFont = UIFont.systemFont(ofSize: size.symbolFontSize, weight: .semibold)

        // 前缀文本。
        if !prefix.isEmpty {
            prefixLabel.text = prefix
            prefixLabel.font = .systemFont(ofSize: AppFont.sizeXs)
            prefixLabel.textColor = AppColor.textSecondary
            stack.addArrangedSubview(prefixLabel)
        }

        // 符号（前置）。
        if !symbol.isEmpty && symbolPosition == .front {
            symbolLabel.text = symbol
            symbolLabel.font = symFont
            symbolLabel.textColor = color
            stack.addArrangedSubview(symbolLabel)
        }

        // 整数部分。
        integerLabel.text = parts.integer
        integerLabel.font = intFont
        integerLabel.textColor = color
        stack.addArrangedSubview(integerLabel)

        // 小数部分。
        if !parts.decimal.isEmpty {
            decimalLabel.text = "." + parts.decimal
            decimalLabel.font = symFont
            decimalLabel.textColor = color
            stack.addArrangedSubview(decimalLabel)
        }

        // 符号（后置）。
        if !symbol.isEmpty && symbolPosition == .after {
            symbolLabel.text = symbol
            symbolLabel.font = symFont
            symbolLabel.textColor = color
            stack.addArrangedSubview(symbolLabel)
        }

        // 后缀文本。
        if !suffix.isEmpty {
            suffixLabel.text = suffix
            suffixLabel.font = .systemFont(ofSize: AppFont.sizeXs)
            suffixLabel.textColor = AppColor.textSecondary
            stack.addArrangedSubview(suffixLabel)
        }
    }
}
