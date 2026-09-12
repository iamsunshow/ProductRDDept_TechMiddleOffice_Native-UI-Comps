import UIKit

/// Slider 滑块（数据录入组件 · ui.slider）：单值连续/分档滑块。
///
/// 视觉：水平轨道（灰底 + primary 激活段）+ 圆形 thumb 可拖拽；
/// 有 step 时吸附档位，无 step 时连续滑动。
/// 语义：value 受控当前值（min...max）；onChange 拖拽释放/点击回调；
/// disabled 整体 40% 灰不可拖。
///
/// 拖拽实现说明（v1.5.8 重写）：
/// 旧版用 UIControl.beginTracking/continueTracking/endTracking——
/// 嵌入 UIScrollView 时，ScrollView 默认 canCancelContentTouches=true，
/// 识别拖拽手势后调用 touchesCancelled 取消子视图 touch tracking，
/// 导致 Slider 在 Demo 页内不可拖动。改用 UIPanGestureRecognizer +
/// UITapGestureRecognizer：手势识别器优先级高于 touch tracking，不会被
/// ScrollView 取消；同时实现 UIGestureRecognizerDelegate 的
/// gestureRecognizerShouldRecognizeSimultaneouslyWith 返回 true，
/// 让 Slider 水平拖拽与 ScrollView 纵向滚动共存。
public class SliderView: UIControl, UIGestureRecognizerDelegate {

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
    /// 拖拽中暂存的起始 ratio（pan 手势开始时记录，配合平移量增量更新）。
    private var dragStartRatio: CGFloat = 0

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
        setupGestures()
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

    /// 安装手势识别器：拖拽（pan）+ 点击轨道跳转（tap）。
    /// 关键：delegate=self，gestureRecognizerShouldRecognizeSimultaneouslyWith 返回 true，
    /// 让 Slider 水平 pan 与父 ScrollView 纵向 pan 共存，避免被 ScrollView 拦截取消。
    private func setupGestures() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        pan.delegate = self
        addGestureRecognizer(pan)

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tap.delegate = self
        addGestureRecognizer(tap)
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
        // disabled 时禁用手势识别，防止拖拽
        gestureRecognizers?.forEach { $0.isEnabled = !disabled }
    }

    // MARK: - UIGestureRecognizerDelegate

    /// 允许 Slider 手势与父 ScrollView 滚动手势共存——
    /// 否则 ScrollView 识别到垂直 pan 时会取消 Slider 的水平 pan。
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                  shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer) -> Bool {
        true
    }

    // MARK: - 手势处理

    @objc private func handlePan(_ pan: UIPanGestureRecognizer) {
        guard !disabled else { return }
        switch pan.state {
        case .began:
            // 记录起始 ratio，后续按平移增量计算（更稳定，不依赖 bounds 宽度抖动）
            dragStartRatio = trackRatio()
            // 反馈 onChange 实时值？一期 onChange 仅在 end 触发，保持与旧版一致
        case .changed:
            let translation = pan.translation(in: self)
            let width = Swift.max(bounds.width, 1)
            let deltaRatio = translation.x / width
            let newRatio = Swift.max(0, Swift.min(1, dragStartRatio + deltaRatio))
            var newValue = min + Double(newRatio) * (max - min)
            if let step = step, step > 0 {
                newValue = (newValue / step).rounded() * step
            }
            valueStorage = clamp(newValue)
            setNeedsLayout()
        case .ended, .cancelled:
            onChange?(valueStorage)
        default:
            break
        }
    }

    @objc private func handleTap(_ tap: UITapGestureRecognizer) {
        guard !disabled else { return }
        // 点击轨道跳转到对应位置
        let location = tap.location(in: self)
        let width = Swift.max(bounds.width, 1)
        let ratio = Swift.max(0, Swift.min(1, location.x / width))
        var newValue = min + Double(ratio) * (max - min)
        if let step = step, step > 0 {
            newValue = (newValue / step).rounded() * step
        }
        valueStorage = clamp(newValue)
        setNeedsLayout()
        onChange?(valueStorage)
    }

    private func clamp(_ v: Double) -> Double {
        Swift.min(max, Swift.max(min, v))
    }
}
