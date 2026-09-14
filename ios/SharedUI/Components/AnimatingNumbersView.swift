/// AnimatingNumbers 数字动画组件（UIKit 版，对齐 Android AnimatingNumbers）。
///
/// 数值变化时以「逐位滚动」动画展示数字过渡：每位数字是一个竖排 0~9 的定高滚动窗口，
/// value 驱动——挂载后等待 delay，再在 duration 内从 0 滚到目标字形。
/// length 控制最大位数（位数不足时整数部分前按位补 0），thousands 控制千分位分隔符
/// （分隔符静态渲染，不参与滚动）。
///
/// 用法：
/// ```swift
/// let num = AnimatingNumbersView(value: 678.94)
/// num.value = 1578.94
/// num.thousands = true
/// ```
///
/// 决策（与 design-spec/animating-numbers-design-spec.html 一致）：
/// - P1-A 复用 Price 尺寸语言三档：medium = AppFont.sizeLg(18)/窗口高 32、small = sizeSm(14)/24、large = sizeDisplay(32)/48
/// - P2-A delay/duration 统一毫秒（默认 300 / 1000，等价 NutUI 的 300ms / 1s）
/// - P3-A value 变化时全体从 0 重滚（位数增减不错位、行为可断言）
/// - P4-A 千分位分隔符与小数为静态渲染，不参与滚动
///
/// 边界（划界见规格第 2 节）：只滚数字，不做货币符号/前后缀/小数位格式化（归 Price #72）。

import UIKit

/// 数字动画尺寸档位：字号 + 数位窗口高。
enum AnimatingNumbersSize {
    /// 小号：14 / 24。
    case small
    /// 中号（默认）：18 / 32（窗口高 32 = 交互行基准 48 的 2/3，注释锚定）。
    case medium
    /// 大号：32 / 48。
    case large

    /// 字号。
    var fontSize: CGFloat {
        switch self {
        case .small: return AppFont.sizeSm       // 14
        case .medium: return AppFont.sizeLg      // 18（NutUI base-size）
        case .large: return AppFont.sizeDisplay  // 32
        }
    }

    /// 数位窗口高。
    var cellHeight: CGFloat {
        switch self {
        case .small: return 24
        case .medium: return 32
        case .large: return 48
        }
    }
}

/// 渲染令牌：一位可滚动数字 / 一个静态分隔符（小数点、千分位逗号、负号）。
enum AnimatingNumbersToken {
    case digit(Int)
    case separator(String)
}

/// 数位滚动列：竖排 0~9 定高字，仅暴露自身窗口高度供位移计算。
private final class AnimatingDigitColumn: UIView {
    private let labels: [UILabel]
    private let cellHeight: CGFloat

    init(labels: [UILabel], cellHeight: CGFloat) {
        self.labels = labels
        self.cellHeight = cellHeight
        super.init(frame: .zero)
        labels.forEach { addSubview($0) }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("AnimatingDigitColumn does not support NSCoder")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        var y: CGFloat = 0
        for label in labels {
            label.frame = CGRect(x: 0, y: y, width: bounds.width, height: cellHeight)
            y += cellHeight
        }
    }
}

/// 布局项：一位数字窗口（含滚动列）或一个静态分隔符标签。
private enum AnimatingNumberItem {
    case digit(window: UIView, column: UIView, digit: Int, width: CGFloat)
    case separator(label: UILabel, width: CGFloat)
}

final class AnimatingNumbersView: UIView {
    // MARK: - 配置属性

    /// 结束值（数值驱动；NaN/Infinity 等非法值 fallback 0，不崩溃）。
    var value: Double = 0 { didSet { rebuild() } }

    /// 最大展示位数（仅计数字位，不含小数点/千分位分隔符）；0=按实际位数，不足时整数部分前补 0。
    var length: Int = 0 { didSet { rebuild() } }

    /// 等待动画执行时间（毫秒，默认 300）。
    var delay: Int = 300 { didSet { rebuild() } }

    /// 动画执行时长（毫秒，默认 1000）。
    var duration: Int = 1000 { didSet { rebuild() } }

    /// 是否显示千位分隔符（分隔符静态渲染不滚动）。
    var thousands: Bool = false { didSet { rebuild() } }

    /// 尺寸档位（字号/窗口高），默认 .medium。
    var size: AnimatingNumbersSize = .medium { didSet { rebuild() } }

    /// 数字颜色，默认 textPrimary。
    var color: UIColor = AppColor.textPrimary { didSet { rebuild() } }

    /// 分隔符（小数点/千分位/负号）颜色，nil=跟随 color。
    var separatorColor: UIColor? { didSet { rebuild() } }

    /// 数位背景色（非透明时按 cornerRadius 圆角），默认透明。
    var backgroundColor2: UIColor = .clear { didSet { rebuild() } }

    /// 数位背景圆角，默认 4（NutUI 原值）。
    var cornerRadius: CGFloat = 4 { didSet { rebuild() } }

    // MARK: - 内部状态

    private var items: [AnimatingNumberItem] = []
    private var animators: [UIViewPropertyAnimator] = []
    /// 等宽数字（monospacedDigit）下数字宽 ≈ 0.62em，用于锁定数位宽，滚动时不抖动。
    private var digitWidth: CGFloat = 0
    private var totalWidth: CGFloat = 0

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    init(value: Double = 0) {
        self.value = value
        super.init(frame: .zero)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("AnimatingNumbersView does not support NSCoder")
    }

    deinit {
        animators.forEach { $0.stopAnimation(true) }
    }

    // MARK: - 布局

    private func setup() {
        backgroundColor = .clear
        clipsToBounds = false
        rebuild()
    }

    /// 透传内容固有尺寸（总宽 × 数位窗口高），便于在 UIStackView 等场景正确撑开。
    override var intrinsicContentSize: CGSize {
        CGSize(width: totalWidth, height: size.cellHeight)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let h = size.cellHeight
        var x: CGFloat = 0
        for item in items {
            switch item {
            case let .digit(window, _, _, width):
                window.frame = CGRect(x: x, y: 0, width: width, height: h)
                x += width
            case let .separator(label, width):
                let labelHeight = label.intrinsicContentSize.height
                label.frame = CGRect(x: x, y: (h - labelHeight) / 2, width: width, height: labelHeight)
                x += width
            }
        }
    }

    // MARK: - 渲染

    /// 按当前配置重建子视图并启动滚动动画。
    private func rebuild() {
        // 停掉在飞动画并复位。
        animators.forEach { $0.stopAnimation(true) }
        animators.removeAll()
        subviews.forEach { $0.removeFromSuperview() }
        items.removeAll()

        let tokens = Self.buildTokens(value: value, length: length, thousands: thousands)
        let h = size.cellHeight
        let font = UIFont.monospacedDigitSystemFont(ofSize: size.fontSize, weight: .semibold)
        let fontWeight = font
        digitWidth = (size.fontSize * 0.62).rounded()
        let sep = separatorColor ?? color

        var total: CGFloat = 0
        for token in tokens {
            switch token {
            case let .separator(text):
                let label = UILabel()
                label.text = text
                label.font = fontWeight
                label.textColor = sep
                label.textAlignment = .center
                let width = label.intrinsicContentSize.width
                addSubview(label)
                items.append(.separator(label: label, width: width))
                total += width

            case let .digit(digit):
                let window = UIView()
                window.backgroundColor = backgroundColor2
                window.layer.cornerRadius = cornerRadius
                window.layer.masksToBounds = true

                var labels: [UILabel] = []
                for d in 0...9 {
                    let label = UILabel()
                    label.text = "\(d)"
                    label.font = font
                    label.textColor = color
                    label.textAlignment = .center
                    labels.append(label)
                }
                let column = AnimatingDigitColumn(labels: labels, cellHeight: h)
                window.addSubview(column)
                // 滚动列顶部对齐窗口顶（可见区=第 1 格），transform 复位为 identity。
                column.transform = .identity
                column.bounds = CGRect(x: 0, y: 0, width: digitWidth, height: h * 10)
                column.center = CGPoint(x: digitWidth / 2, y: h * 5)

                addSubview(window)
                items.append(.digit(window: window, column: column, digit: digit, width: digitWidth))
                total += digitWidth
            }
        }
        totalWidth = total
        invalidateIntrinsicContentSize()
        setNeedsLayout()

        startAnimation()
    }

    /// 启动逐位滚动：先全体归零（显示 0），等待 delay 后在 duration 内滚到目标字形。
    private func startAnimation() {
        animators.forEach { $0.stopAnimation(true) }
        animators.removeAll()

        let h = size.cellHeight
        let afterDelay = Double(max(0, delay)) / 1000.0
        let dur = Double(max(0, duration)) / 1000.0
        // 与 Compose FastOutSlowInEasing 同曲线 cubic-bezier(0.4, 0, 0.2, 1)。
        let params = UICubicTimingParameters(
            controlPoint1: CGPoint(x: 0.4, y: 0.0),
            controlPoint2: CGPoint(x: 0.2, y: 1.0)
        )

        for item in items {
            guard case let .digit(_, column, digit, _) = item else {
                // 分隔符静态渲染，不参与滚动。
                continue
            }
            // 先归零（P3-A：value 变化时全体从 0 重滚）。
            column.transform = .identity
            let target = CGAffineTransform(translationX: 0, y: -CGFloat(digit) * h)
            if dur <= 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + afterDelay) { [weak column] in
                    column?.transform = target
                }
                continue
            }
            let animator = UIViewPropertyAnimator(duration: dur, timingParameters: params)
            // 弱捕获滚动列：动画闭包不持有 column，避免 self → animators → 闭包 → column → superview(self) 循环引用。
            animator.addAnimations { [weak column] in column?.transform = target }
            animator.startAnimation(afterDelay: afterDelay)
            animators.append(animator)
        }
    }

    // MARK: - 令牌构建

    /// 把数值展开为渲染令牌序列（与 Android buildAnimatingTokens 逐条对齐）。
    ///
    /// 规则：
    /// - 数值格式化 = 最短表示（88.0 → "88"、88.8 → "88.8"、12345.67 → "12345.67"），非法值 fallback "0"；
    /// - length 只计数字位：不足时在整数部分前补 0（value=12、length=4 → 0012）；
    /// - thousands 时整数部分每 3 位插一个静态逗号（不计入 length 补位）；
    /// - 负号按静态分隔符渲染。
    static func buildTokens(value: Double, length: Int, thousands: Bool) -> [AnimatingNumbersToken] {
        let plain = plainString(value)
        let negative = plain.hasPrefix("-")
        let unsigned = negative ? String(plain.dropFirst()) : plain

        let parts = unsigned.components(separatedBy: ".")
        var intPart = parts.first ?? "0"
        let decPart = parts.count > 1 ? parts[1] : ""

        let digitCount = intPart.count + decPart.count
        if length > digitCount {
            intPart = String(repeating: "0", count: length - digitCount) + intPart
        }

        var tokens: [AnimatingNumbersToken] = []
        if negative { tokens.append(.separator("-")) }

        let intChars = Array(intPart)
        for (idx, ch) in intChars.enumerated() {
            tokens.append(.digit(Int(String(ch)) ?? 0))
            let remaining = intChars.count - idx
            if thousands && remaining > 1 && remaining % 3 == 1 {
                tokens.append(.separator(","))
            }
        }

        if !decPart.isEmpty {
            tokens.append(.separator("."))
            for ch in decPart {
                tokens.append(.digit(Int(String(ch)) ?? 0))
            }
        }
        return tokens
    }

    /// 数值最短表示：NaN/Infinity → "0"，并去掉小数尾部多余的 0（88.0 → 88）。
    private static func plainString(_ value: Double) -> String {
        guard !value.isNaN, !value.isInfinite else { return "0" }
        let raw = String(value)
        if raw.contains("e") || raw.contains("E") {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.usesGroupingSeparator = false
            formatter.maximumFractionDigits = 20
            formatter.locale = Locale(identifier: "en_US_POSIX")
            let text = formatter.string(from: NSNumber(value: value)) ?? raw
            return stripTrailingZeros(text)
        }
        let stripped = stripTrailingZeros(raw)
        return stripped == "-0" ? "0" : stripped
    }

    private static func stripTrailingZeros(_ text: String) -> String {
        guard text.contains(".") else { return text }
        var result = text
        while result.hasSuffix("0") { result.removeLast() }
        if result.hasSuffix(".") { result.removeLast() }
        return result
    }
}
