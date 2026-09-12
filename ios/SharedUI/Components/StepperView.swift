import UIKit

/// Stepper 步进器（数据录入组件 · ui.stepper）：数值增减步进器。
///
/// 视觉：[−] 按钮 + 数值标签 + [+] 按钮，高 32，按钮 32×32 圆角；
/// 到达 min/max 时对应按钮灰显不可点。
/// 语义：value 受控当前值；onChange 步进回调；disabled 整体 40% 灰。
public class StepperView: UIView {

    public enum Metrics {
        public static let buttonSize: CGFloat = 32
        public static let componentHeight: CGFloat = 32
        public static let labelMinWidth: CGFloat = 40
    }

    public var value: Double {
        get { valueStorage }
        set { valueStorage = clamp(newValue); updateLabel(); updateButtonStates() }
    }

    public var min: Double
    public var max: Double
    public var step: Double
    public var disabled: Bool {
        didSet { applyDisabled() }
    }

    public var onChange: ((Double) -> Void)?

    private var valueStorage: Double
    private let minusButton = UIButton(type: .system)
    private let plusButton = UIButton(type: .system)
    private let valueLabel = UILabel()

    public init(
        value: Double = 0,
        min: Double = 0,
        max: Double = 100,
        step: Double = 1,
        disabled: Bool = false,
        onChange: ((Double) -> Void)? = nil
    ) {
        self.valueStorage = value
        self.min = min
        self.max = max
        self.step = step
        self.disabled = disabled
        self.onChange = onChange
        super.init(frame: .zero)
        buildUI()
        updateLabel()
        updateButtonStates()
        applyDisabled()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) { fatalError() }

    public override var intrinsicContentSize: CGSize {
        CGSize(width: Metrics.buttonSize * 2 + Metrics.labelMinWidth + AppSpace.xs * 2,
               height: Metrics.componentHeight)
    }

    private func buildUI() {
        backgroundColor = .clear

        configureButton(minusButton, title: "−", action: #selector(doDecrement))
        configureButton(plusButton, title: "+", action: #selector(doIncrement))

        valueLabel.font = .systemFont(ofSize: AppFont.sizeMd, weight: .medium)
        valueLabel.textColor = AppColor.textPrimary
        valueLabel.textAlignment = .center
        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.minimumScaleFactor = 0.7
        addSubview(valueLabel)

        minusButton.translatesAutoresizingMaskIntoConstraints = false
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            minusButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            minusButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            minusButton.widthAnchor.constraint(equalToConstant: Metrics.buttonSize),
            minusButton.heightAnchor.constraint(equalToConstant: Metrics.buttonSize),

            plusButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            plusButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            plusButton.widthAnchor.constraint(equalToConstant: Metrics.buttonSize),
            plusButton.heightAnchor.constraint(equalToConstant: Metrics.buttonSize),

            valueLabel.leadingAnchor.constraint(equalTo: minusButton.trailingAnchor, constant: AppSpace.xs),
            valueLabel.trailingAnchor.constraint(equalTo: plusButton.leadingAnchor, constant: -AppSpace.xs),
            valueLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            valueLabel.heightAnchor.constraint(equalToConstant: Metrics.componentHeight),
        ])
    }

    private func configureButton(_ btn: UIButton, title: String, action: Selector) {
        btn.setTitle(title, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: AppFont.sizeLg, weight: .medium)
        btn.setTitleColor(AppColor.textPrimary, for: .normal)
        btn.backgroundColor = AppColor.bgPage
        btn.layer.cornerRadius = AppRadius.sm
        btn.addTarget(self, action: action, for: .touchUpInside)
        addSubview(btn)
    }

    @objc private func doDecrement() {
        guard !disabled else { return }
        let newVal = clamp(valueStorage - step)
        if newVal != valueStorage {
            valueStorage = newVal
            updateLabel()
            updateButtonStates()
            onChange?(valueStorage)
        }
    }

    @objc private func doIncrement() {
        guard !disabled else { return }
        let newVal = clamp(valueStorage + step)
        if newVal != valueStorage {
            valueStorage = newVal
            updateLabel()
            updateButtonStates()
            onChange?(valueStorage)
        }
    }

    private func updateLabel() {
        if step == step.rounded() && step >= 1 {
            valueLabel.text = "\(Int(valueStorage))"
        } else {
            valueLabel.text = String(format: "%.1f", valueStorage)
        }
    }

    private func updateButtonStates() {
        minusButton.isEnabled = !disabled && valueStorage > min
        plusButton.isEnabled = !disabled && valueStorage < max
        minusButton.alpha = minusButton.isEnabled ? 1.0 : 0.4
        plusButton.alpha = plusButton.isEnabled ? 1.0 : 0.4
    }

    private func applyDisabled() {
        alpha = disabled ? 0.4 : 1.0
        minusButton.isEnabled = !disabled && valueStorage > min
        plusButton.isEnabled = !disabled && valueStorage < max
    }

    private func clamp(_ v: Double) -> Double {
        Swift.min(max, Swift.max(min, v))
    }
}
