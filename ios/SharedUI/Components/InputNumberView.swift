/// InputNumberView 步进式数字输入（数据录入区 · ui.input-number · #30）。
///
/// 组件 ID：`ui.input-number`（api.json 契约对齐；门禁 A AI 代评通过 2026-09-06，规格
/// design-spec/input-number-design-spec.html + 评审单 review-input-number-A.md，P1–P4 全 A）。
///
/// 定位：**步进式数字输入内容组件（无弹层/无键盘拉起面）**——宿主传值，用户点 − / + 按 step
/// 增减，中段显示当前值；一期不做键盘直输/长按连续（=二期），键盘=Input（#29）职责。
///
/// 契约（半受控）：
/// - `value: Double? = nil`：nil/缺省=min 存在则 min、否则 0；外部重新赋值=同步刷新显示，
///   不触发 onChange（宿主驱动回显/重置）。
/// - `min/max`：到达边界对应按钮禁用（灰 40%），点边界按钮幂等无回调。
/// - `step` 默认 1；`precision` 默认 0：运算与展示按 precision 收敛（定点整数化防浮点尾差，
///   Double 宿主落库友好，金额大数精度=MoneyFormat/宿主策略）。
/// - `disabled`：整控件 40% 置灰不可点（优先级高于边界）。
/// - 每次有效增减触发 `onChange(newValue)`。
///
/// 设计锚点（Token 注释锚定）：整高 32pt；按钮宽 32pt 字号 Lg=18 主色；值区 min 宽 40pt
/// 字号 Md=16 主色 precision 位定点；壳=bgPage + hairline 边框 + radiusSm(6) 圆角裁剪；
/// 边界/禁用=textSecondary 40% 透明度不可点（同库内禁用先例）；点击按压瞬态 vs Android
/// ripple、按钮外侧圆角 vs Compose 圆角 shape=平台差异表内放行。
///
/// 用法：
/// ```swift
/// let stepper = InputNumberView(value: 1, min: 1, max: 99, onChange: { v in ... })
/// stepper.value = 5        // 外部重置回显（不触发 onChange）
/// stepper.disabled = true  // 整控件禁用
/// ```
import UIKit

/// 步进式数字输入（− 值 +）。
final class InputNumberView: UIView {

    enum Metrics {
        /// 整件高 / 按钮宽（32pt/32dp）
        static let buttonLength: CGFloat = 32
        /// 值区最小宽（40pt/40dp）
        static let valueMinWidth: CGFloat = 40
        /// 值区水平余白（合计 12pt，随值位数扩张）
        static let valueHorizontalPad: CGFloat = 6
        /// 小数位上限保护（定点因子防溢出）
        static let maxPrecision: Int = 6
        /// hairline（1/scale pt）
        static var hairline: CGFloat { 1 / UIScreen.main.scale }
    }

    // 只读配置（构造期传入；动态变化面=value/disabled）
    private let minValue: Double?
    private let maxValue: Double?
    private let stepValue: Double
    private let precisionDigits: Int

    private let minusButton = UIButton(type: .custom)
    private let plusButton = UIButton(type: .custom)
    private let valueLabel = UILabel()
    private var currentValue: Double
    private var userInteractionOff = false

    /// 当前值（Double，nil=启动由 min/0 决定）；外部赋值=回显刷新不触发 onChange。
    var value: Double? {
        didSet {
            if let value {
                currentValue = clampAndRound(value)
                refreshDisplay()
            }
        }
    }
    /// 整控件禁用（灰 40% 不可点；高于边界禁用）。
    var disabled: Bool {
        didSet { refreshDisplay() }
    }
    /// 有效增减回调。
    var onChange: ((Double) -> Void)?

    init(
        value: Double? = nil,
        min: Double? = nil,
        max: Double? = nil,
        step: Double = 1,
        precision: Int = 0,
        disabled: Bool = false,
        onChange: ((Double) -> Void)? = nil
    ) {
        self.minValue = min
        self.maxValue = max
        self.stepValue = step
        self.precisionDigits = min(max(precision, 0), Metrics.maxPrecision)
        self.disabled = disabled
        self.onChange = onChange
        let digits = max(
            Self.fractionDigits(of: step),
            max(Self.fractionDigits(of: min), Self.fractionDigits(of: max))
        )
        _ = digits
        let start: Double
        if let value {
            start = value
        } else if let min {
            start = min
        } else {
            start = 0
        }
        self.currentValue = Self.round(start, precision: precisionDigits)
        super.init(frame: .zero)
        backgroundColor = AppColor.bgPage
        layer.borderWidth = Metrics.hairline
        layer.borderColor = AppColor.border.cgColor
        layer.cornerRadius = AppRadius.sm
        clipsToBounds = true

        configureButton(minusButton, symbol: "−", action: #selector(minusTapped))
        configureButton(plusButton, symbol: "+", action: #selector(plusTapped))

        valueLabel.textAlignment = .center
        valueLabel.numberOfLines = 1
        addSubview(minusButton)
        addSubview(valueLabel)
        addSubview(plusButton)
        refreshDisplay()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("InputNumberView 不支持 initWithCoder 解码，请使用 init(value:min:max:step:precision:disabled:onChange:)。")
    }

    // MARK: - 布局

    override var intrinsicContentSize: CGSize {
        let valueWidth = Self.textWidth(
            Self.displayText(Self.round(currentValue, precision: precisionDigits),
                             precision: precisionDigits)
        )
        let vw = max(Metrics.valueMinWidth, valueWidth + Metrics.valueHorizontalPad * 2)
        return CGSize(width: Metrics.buttonLength * 2 + vw, height: Metrics.buttonLength)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let h = bounds.height
        let w = bounds.width
        guard w > 0, h > 0 else { return }
        minusButton.frame = CGRect(x: 0, y: 0, width: Metrics.buttonLength, height: h)
        let valueWidth = max(w - Metrics.buttonLength * 2, 0)
        valueLabel.frame = CGRect(x: Metrics.buttonLength, y: 0, width: valueWidth, height: h)
        plusButton.frame = CGRect(x: w - Metrics.buttonLength, y: 0, width: Metrics.buttonLength, height: h)
    }

    // MARK: - 点按

    @objc private func minusTapped() {
        guard !disabled else { return }
        step(direction: -1)
    }

    @objc private func plusTapped() {
        guard !disabled else { return }
        step(direction: 1)
    }

    private func step(direction: Int) {
        let f = Self.factor(precision: precisionDigits)
        var scaled = Int((currentValue * f).rounded())
        let delta = Int((stepValue * f).rounded()) * direction
        scaled += delta
        var next = Double(scaled) / f
        if let minValue {
            next = max(next, Self.round(minValue, precision: precisionDigits))
        }
        if let maxValue {
            next = min(next, Self.round(maxValue, precision: precisionDigits))
        }
        next = Self.round(next, precision: precisionDigits)
        // 幂等：点边界按钮（结果未变）不触发回调
        if next == currentValue { return }
        currentValue = next
        refreshDisplay()
        onChange?(next)
    }

    // MARK: - 定点运算（Double 宿主值 + 显式 precision）

    /// 展示/运算精度使用的定点因子（10^precision）。
    private static func factor(precision: Int) -> Double {
        pow(10, Double(precision))
    }

    /// 按 precision 四舍五入收敛（防浮点尾差）。
    private static func round(_ value: Double, precision: Int) -> Double {
        let f = factor(precision: precision)
        return (value * f).rounded() / f
    }

    /// 值按 precision 定点规整（固定小数位；尾部零保留，如 50.0）。
    private static func displayText(_ value: Double, precision: Int) -> String {
        let p = precision
        let f = factor(precision: p)
        var scaled = (value * f).rounded()
        let negative = scaled < 0
        scaled = abs(scaled)
        var digits = String(Int(scaled))
        if p > 0 {
            while digits.count <= p { digits = "0" + digits }
            let split = digits.index(digits.endIndex, offsetBy: -p)
            digits.insert(".", at: split)
        }
        return (negative ? "-" : "") + digits
    }

    private static func textWidth(_ text: String) -> CGFloat {
        let font = UIFont.systemFont(ofSize: AppFont.sizeMd)
        return (text as NSString).size(withAttributes: [.font: font]).width
    }

    /// 小数位数（值/步长文本表示中小数点后位数）。
    private static func fractionDigits(of value: Double?) -> Int {
        guard let value else { return 0 }
        let text = String(value)
        if let dot = text.firstIndex(of: ".") {
            return text.distance(from: text.index(after: dot), to: text.endIndex)
        }
        return 0
    }

    private func clampAndRound(_ raw: Double) -> Double {
        var v = raw
        if let minValue { v = max(v, Self.round(minValue, precision: precisionDigits)) }
        if let maxValue { v = min(v, Self.round(maxValue, precision: precisionDigits)) }
        return Self.round(v, precision: precisionDigits)
    }

    // MARK: - 显示刷新

    private func configureButton(_ button: UIButton, symbol: String, action: Selector) {
        button.setTitle(symbol, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: AppFont.sizeLg)
        button.addTarget(self, action: action, for: .touchUpInside)
    }

    private func refreshDisplay() {
        valueLabel.text = Self.displayText(currentValue, precision: precisionDigits)
        valueLabel.font = .systemFont(ofSize: AppFont.sizeMd)
        valueLabel.textColor = disabled
            ? AppColor.textSecondary.withAlphaComponent(0.4)
            : AppColor.primary
        let normal = disabled ? AppColor.textSecondary.withAlphaComponent(0.4) : AppColor.primary
        let boundary = disabled ? AppColor.textSecondary.withAlphaComponent(0.4) : AppColor.textSecondary.withAlphaComponent(0.4)
        minusButton.setTitleColor(canStep(direction: -1) ? normal : boundary, for: .normal)
        plusButton.setTitleColor(canStep(direction: 1) ? normal : boundary, for: .normal)
        isUserInteractionEnabled = !disabled
        invalidateIntrinsicContentSize()
    }

    /// 边界判定：未到边界可步进（disabled 前置已短路）。
    private func canStep(direction: Int) -> Bool {
        if disabled { return false }
        if direction < 0, let minValue {
            return currentValue > Self.round(minValue, precision: precisionDigits)
        }
        if direction > 0, let maxValue {
            return currentValue < Self.round(maxValue, precision: precisionDigits)
        }
        return true
    }
}
