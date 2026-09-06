/// Range 区间选择（ui.range，#36）——数据录入区全新立项。
///
/// 组件 ID：`ui.range`（api.json 契约对齐；门禁 A AI 代评通过 2026-09-06，规格
/// design-spec/range-design-spec.html + 评审单 review-range-A.md，P1–P4 全 A）。
///
/// 横向双钮区间滑块：一条共用轨道 + start/end 两枚滑块（闭区间 start≤end 恒成立、可相等=
/// 零宽单点）、激活段高亮（start 中心~end 中心 primary）、点轨道空段=吸附最近滑块到点击值、
/// 拖动任一端连续调整（step 粒度吸附）、数值 Double 承载=宿主格式化单位展示。
///
/// 半受控（与 Android Range 同构）：
/// - `value: RangeValue?`=nil 内部自持且初始 [min,max]（「全选=不过滤」语义）；外部赋值
///   （含 clamp 后）=仅同步回显不触发 onChange；
/// - 点/拖=onChange 连续回调（每次 step 对齐后），宿主回写；
/// - start≤end 硬钳制（滑块不可越过对方）、可相等零宽单点；
/// - min/max 动态改=越界端自动 clamp 并回显（值域级变化=回调一次让宿主可同步）；
/// - disabled=整条灰、不可拖不可点无回调。
///
/// 视觉锚点（与 Android 同构）：行高 40（整条命中区）；轨道高 4 圆角，未激活段=textSecondary
/// (alpha 0.3)、激活段=primary；滑块钮白底圆形 20 + primary 描边 1.5（禁用=textSecondary
/// (alpha 0.4)）；端点贴边=钮中心贴轨道端点、半钮视觉溢出允许。无壳无刻度无数值气泡=宿主
/// 格式化单位（同 Checkbox/Radio 无壳先例）。
import UIKit

/// 区间值（start≤end）。
struct RangeValue: Equatable {
    var start: Double
    var end: Double
}

private func rangeClamp(_ v: Double, _ lo: Double, _ hi: Double) -> Double {
    Swift.min(Swift.max(v, lo), hi)
}

/// 区间滑轨视图（宽度由宿主约束填充，intrinsicContentSize 高 40）。
final class RangeView: UIView {

    var onChange: ((RangeValue) -> Void)?

    /// 半受控值：nil=内部自持；外部赋值（含 clamp 后）=同步回显不触发 onChange。
    var value: RangeValue? {
        didSet {
            if let value {
                applyExternal(value)
            }
        }
    }

    /// 值域下界（动态改=越界端自动 clamp 并回调一次）。
    var min: Double = 0 {
        didSet { clampToBounds() }
    }

    /// 值域上界（动态改=越界端自动 clamp 并回调一次）。
    var max: Double = 100 {
        didSet { clampToBounds() }
    }

    /// 吸附粒度（默认 1；>0 且 ≤(max−min)=参数注释断言）。
    var step: Double = 1

    /// 整条禁用：灰 40%、不可拖不可点无回调。
    var disabled: Bool = false {
        didSet {
            isUserInteractionEnabled = !disabled
            setNeedsDisplay()
        }
    }

    private enum Thumb {
        case start
        case end
    }

    private var internalStart: Double
    private var internalEnd: Double
    private var activeThumb: Thumb?

    init(
        value: RangeValue? = nil,
        min: Double = 0,
        max: Double = 100,
        step: Double = 1,
        disabled: Bool = false,
        onChange: ((RangeValue) -> Void)? = nil
    ) {
        let lo = Swift.min(min, max)
        let hi = Swift.max(min, max)
        if let value {
            var s = rangeClamp(value.start, lo, hi)
            var e = rangeClamp(value.end, lo, hi)
            if s > e { (s, e) = (e, s) }
            self.internalStart = s
            self.internalEnd = e
        } else {
            // 内部自持初始 [min, max]=「全选=不过滤」语义
            self.internalStart = lo
            self.internalEnd = hi
        }
        self.step = step
        self.onChange = onChange
        super.init(frame: .zero)
        backgroundColor = .clear
        self.min = lo
        self.max = hi
        self.disabled = disabled
        isUserInteractionEnabled = !disabled
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("RangeView 不支持 initWithCoder 解码，请使用 init(value:min:max:step:disabled:onChange:)。")
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: 40)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        setNeedsDisplay()
    }

    // MARK: - 触摸（点轨道吸附最近钮 / 拖动活动钮）

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard !disabled, let touch = touches.first, bounds.width > 0 else { return }
        let x = touch.location(in: self).x
        let thumb = nearestThumb(atX: x)
        activeThumb = thumb
        move(thumb: thumb, toX: x)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let thumb = activeThumb, !disabled, let touch = touches.first, bounds.width > 0 else { return }
        move(thumb: thumb, toX: touch.location(in: self).x)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        activeThumb = nil
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        activeThumb = nil
    }

    // MARK: - 行为

    /// 吸附/拖动目标滑块（距离点击值更近的一枚）。
    private func nearestThumb(atX x: CGFloat) -> Thumb {
        let v = snapped(xToValue(x))
        if abs(v - internalStart) <= abs(internalEnd - v) {
            return .start
        }
        return .end
    }

    private func move(thumb: Thumb, toX x: CGFloat) {
        var raw = snapped(xToValue(x))
        // 硬钳制：start≤end（滑块不可越过对方；可相等=零宽单点）
        if thumb == .start {
            raw = Swift.min(raw, internalEnd)
        } else {
            raw = Swift.max(raw, internalStart)
        }
        let current = thumb == .start ? internalStart : internalEnd
        guard abs(raw - current) > 0.000001 else { return }
        if thumb == .start {
            internalStart = raw
        } else {
            internalEnd = raw
        }
        setNeedsDisplay()
        onChange?(RangeValue(start: internalStart, end: internalEnd))
    }

    /// 外部 value 赋值=clamp 后仅回显（不触发 onChange）。
    private func applyExternal(_ value: RangeValue) {
        let s = rangeClamp(value.start, min, max)
        let e = rangeClamp(value.end, min, max)
        guard s != internalStart || e != internalEnd else { return }
        internalStart = s
        internalEnd = e
        setNeedsDisplay()
    }

    /// min/max 动态变化=越界端自动 clamp；实际发生 clamp=回调一次（值域级变化=宿主可同步）。
    private func clampToBounds() {
        let s = rangeClamp(internalStart, min, max)
        let e = rangeClamp(internalEnd, min, max)
        guard s != internalStart || e != internalEnd else { return }
        internalStart = s
        internalEnd = e
        setNeedsDisplay()
        onChange?(RangeValue(start: internalStart, end: internalEnd))
    }

    // MARK: - 几何换算

    /// x 像素 → 值（比例线性，越界 coerce 到 [min,max]）。
    private func xToValue(_ x: CGFloat) -> Double {
        guard bounds.width > 0 else { return min }
        let ratio = Swift.min(Swift.max(x / bounds.width, 0), 1)
        return min + Double(ratio) * (max - min)
    }

    /// 值 → x 像素比例（0~1）。
    private func ratio(of value: Double) -> Double {
        let span = max - min
        guard span > 0 else { return 0 }
        return Swift.min(Swift.max((value - min) / span, 0), 1)
    }

    /// 按 step 对齐到网格并 clamp 值域。
    private func snapped(_ value: Double) -> Double {
        guard step > 0 else { return rangeClamp(value, min, max) }
        let grid = min + ((value - min) / step).rounded() * step
        return rangeClamp(grid, min, max)
    }

    // MARK: - 绘制

    override func draw(_ rect: CGRect) {
        guard bounds.width > 0, bounds.height > 0 else { return }
        let width = bounds.width
        let centerY = bounds.height / 2
        let trackHeight: CGFloat = 4
        let topY = centerY - trackHeight / 2
        let inactive = AppColor.textSecondary.withAlphaComponent(0.3)
        let active = disabled ? AppColor.textSecondary.withAlphaComponent(0.4) : AppColor.primary

        // 轨道未激活段（全宽灰底）
        inactive.setFill()
        UIBezierPath(
            roundedRect: CGRect(x: 0, y: topY, width: width, height: trackHeight),
            cornerRadius: trackHeight / 2
        ).fill()

        // 激活段 start 中心 ~ end 中心（零宽单点=不画）
        let startX = CGFloat(ratio(of: internalStart)) * width
        let endX = CGFloat(ratio(of: internalEnd)) * width
        if endX - startX > 0.5 {
            active.setFill()
            UIBezierPath(
                roundedRect: CGRect(x: startX, y: topY, width: endX - startX, height: trackHeight),
                cornerRadius: trackHeight / 2
            ).fill()
        }

        // 滑块钮（白底圆形 20 + primary 描边 1.5；端点贴边半钮溢出允许）
        drawThumb(centerX: startX, centerY: centerY)
        drawThumb(centerX: endX, centerY: centerY)
    }

    private func drawThumb(centerX: CGFloat, centerY: CGFloat) {
        let radius: CGFloat = 10
        let rect = CGRect(x: centerX - radius, y: centerY - radius, width: radius * 2, height: radius * 2)
        UIColor.white.setFill()
        UIBezierPath(ovalIn: rect).fill()
        let stroke = disabled ? AppColor.textSecondary.withAlphaComponent(0.4) : AppColor.primary
        let ring = UIBezierPath(ovalIn: rect.insetBy(dx: 0.75, dy: 0.75))
        ring.lineWidth = 1.5
        stroke.setStroke()
        ring.stroke()
    }
}
