import UIKit

/// Slider 滑块（数据录入组件 · ui.slider）：单值连续/分档滑块。
///
/// 视觉：水平轨道（灰底 + primary 激活段）+ 圆形 thumb 可拖拽；
/// 有 step 时吸附档位，无 step 时连续滑动。
/// 语义：value 受控当前值（min...max）；onChange 拖拽释放/点击回调；
/// disabled 整体 40% 灰不可拖。
public class SliderView: UIControl {

    public enum Metrics {
        public static let trackHeight: CGFloat = 4
        public static let thumbSize: CGFloat = 24
        public static let componentHeight: CGFloat = 44
    }

    public var value: Double {
        get { valueStorage }
        set { valueStorage = clamp(newValue); layoutThumb(); setNeedsLayout() }
    }

    public var min: Double
    public var max: Double
    public var step: Double?
    public var disabled: Bool {
        didSet { applyDisabled() }
    }

    public var onChange: ((Double) -> Void)?

    private var valueStorage: Double
    private var isDragging = false

    private let trackView = UIView()
    private let activeTrackView = UIView()
    private let thumbView = UIView()

    public init(
        value: Double = 0,
        min: Double = 0,
        max: Double = 100,
        step: Double? = nil,
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
        layoutThumb()
        applyDisabled()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) { fatalError() }

    public override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: Metrics.componentHeight)
    }

    private func buildUI() {
        backgroundColor = .clear
        isOpaque = false

        trackView.backgroundColor = AppColor.border
        trackView.layer.cornerRadius = Metrics.trackHeight / 2
        trackView.layer.masksToBounds = true
        addSubview(trackView)

        activeTrackView.backgroundColor = AppColor.primary
        activeTrackView.layer.cornerRadius = Metrics.trackHeight / 2
        activeTrackView.layer.masksToBounds = true
        addSubview(activeTrackView)

        thumbView.backgroundColor = .white
        thumbView.layer.cornerRadius = Metrics.thumbSize / 2
        thumbView.layer.masksToBounds = true
        thumbView.layer.shadowColor = UIColor.black.cgColor
        thumbView.layer.shadowOpacity = 0.15
        thumbView.layer.shadowRadius = 4
        thumbView.layer.shadowOffset = CGSize(width: 0, height: 2)
        addSubview(thumbView)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        let trackY = (bounds.height - Metrics.trackHeight) / 2
        trackView.frame = CGRect(x: 0, y: trackY, width: bounds.width, height: Metrics.trackHeight)

        let ratio = trackRatio()
        let activeWidth = bounds.width * ratio
        activeTrackView.frame = CGRect(x: 0, y: trackY, width: activeWidth, height: Metrics.trackHeight)

        let thumbX = activeWidth - Metrics.thumbSize / 2
        let thumbY = (bounds.height - Metrics.thumbSize) / 2
        thumbView.frame = CGRect(x: thumbX, y: thumbY, width: Metrics.thumbSize, height: Metrics.thumbSize)
    }

    private func trackRatio() -> CGFloat {
        let range = max - min
        guard range > 0 else { return 0 }
        return CGFloat((valueStorage - min) / range)
    }

    private func layoutThumb() {
        setNeedsLayout()
    }

    private func applyDisabled() {
        alpha = disabled ? 0.4 : 1.0
    }

    // MARK: - Touch handling

    public override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        guard !disabled else { return false }
        isDragging = true
        updateValue(at: touch.location(in: self))
        return true
    }

    public override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        guard isDragging else { return false }
        updateValue(at: touch.location(in: self))
        return true
    }

    public override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        isDragging = false
        if let touch = touch {
            updateValue(at: touch.location(in: self))
        }
        onChange?(valueStorage)
    }

    private func updateValue(at point: CGPoint) {
        let ratio = Swift.max(0, Swift.min(1, point.x / Swift.max(bounds.width, 1)))
        var newValue = min + Double(ratio) * (max - min)
        if let step = step, step > 0 {
            newValue = (newValue / step).rounded() * step
        }
        valueStorage = clamp(newValue)
        setNeedsLayout()
    }

    private func clamp(_ v: Double) -> Double {
        Swift.min(max, Swift.max(min, v))
    }
}
