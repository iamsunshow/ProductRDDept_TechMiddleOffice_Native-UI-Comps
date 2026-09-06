import UIKit

/// Rate 评分（ui.rate，#37）——数据录入区全新立项（规格 rate-design-spec.html，门禁 A P1–P4 全 A）。
///
/// 行内 n 颗自绘五角星整数评分点（默认 5）：
/// - 值=已点亮整星数 Int 0~count（0=未评合法态）；点击第 k 颗=点亮到该颗并回调 k；
/// - 再点当前值同一颗=清空归 0（评价可取消=allowClear 语义）；
/// - 横向滑动=随手指连续点亮/收回（拖出组件左缘=熄灭归 0）、松手一次性定值回调；
/// - 半受控：`value` 可选（nil=内部自持初始 0），外部赋值（含 clamp 0~count）=仅同步回显
///   不触发 onChange；点/滑定值=onChange 一次性回调、宿主回写；
/// - readonly=只读彩色展示评分、不可交互无回调；disabled=灰星不可交互无回调（与 readonly
///   并存 disabled 压过）；count 可配（>0）。
/// - 无 label/文案/提交=宿主自理。
///
/// 视觉锚点（Token 零硬编码原则，锚定规格文档）：星外接圆直径 22（=AppFont.sizeXl 基准）、
/// 五角星内凹比 0.382（R_in=R×sin18°/sin54°）、星间距 8（=AppSpace.sm）、行高 40（整行命中）、
/// 点亮星=primary 填充、未点亮星=textSecondary(alpha0.3) 1.5 空心描边、readonly 保色不降、
/// disabled=点亮星 textSecondary(alpha0.4) 灰填 / 未点亮 alpha0.2 描边。
///
/// 手势：UITouch 点/滑统一按 x→index 换算（星宽 22+间距 8=30pt 一档），无涟漪无按压缩放；
/// 可交互仅 readonly 与 disabled 均 false 时（isUserInteractionEnabled 关闭）。
///
/// 基线：组件库 v1.4.0（2026-09-06，未过 C2/D 不升版）。
final class RateView: UIView {

    var onChange: ((Int) -> Void)?

    var count: Int {
        didSet {
            invalidateIntrinsicContentSize()
            syncFromExternal()
        }
    }
    /// 半受控：nil=内部自持初始 0；外部赋值（含 clamp）=仅同步回显不触发 onChange。
    var value: Int? {
        didSet { syncFromExternal() }
    }
    var readonly: Bool {
        didSet { refreshInteraction(); setNeedsDisplay() }
    }
    var disabled: Bool {
        didSet { refreshInteraction(); setNeedsDisplay() }
    }

    /// 当前视觉点亮颗数（0~count，含点/滑预览）。
    private var filled = 0
    /// 单次手势起点时已点亮颗数（「点当前值同一颗=清空」判定基准）。
    private var gestureOrigin = 0
    /// 手势起点横坐标（tap 与 drag 判定基准）。
    private var gestureStartX: CGFloat = 0
    private var gestureMoved = false

    private let cell: CGFloat = 30 // 星 22 + 间距 8
    private static let starDiameter: CGFloat = 22
    private static let starRadius: CGFloat = starDiameter / 2
    private static let innerRatio: CGFloat = 0.382
    private static let rowHeight: CGFloat = 40
    private static let hollowWidth: CGFloat = 1.5
    private static let tapSlop: CGFloat = 8

    init(
        count: Int = 5,
        value: Int? = nil,
        readonly: Bool = false,
        disabled: Bool = false,
        onChange: ((Int) -> Void)? = nil
    ) {
        self.count = count
        self.value = value
        self.readonly = readonly
        self.disabled = disabled
        self.onChange = onChange
        super.init(frame: .zero)
        refreshInteraction()
        syncFromExternal()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        let width = CGFloat(max(0, count - 1)) * cell + Self.starDiameter
        return CGSize(width: width, height: Self.rowHeight)
    }

    // MARK: - 点/滑手势

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        gestureOrigin = filled
        gestureStartX = touch.location(in: self).x
        gestureMoved = false
        filled = valueAt(x: gestureStartX)
        setNeedsDisplay()
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let x = touch.location(in: self).x
        if abs(x - gestureStartX) > Self.tapSlop {
            gestureMoved = true
        }
        let v = valueAt(x: x)
        if v != filled {
            filled = v
            setNeedsDisplay()
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        finishGesture()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        filled = gestureOrigin
        setNeedsDisplay()
    }

    private func finishGesture() {
        let current = filled
        // tap（几乎无位移）落在「当前已点亮」的同一颗上=清空归 0（评价可取消）；
        // 拖动=直接取当前预览值（可能回到原值=幂等无回调）。
        let next = (!gestureMoved && current == gestureOrigin && current > 0) ? 0 : current
        if next != filled {
            filled = next
            setNeedsDisplay()
        }
        if next != gestureOrigin {
            onChange?(next)
        }
    }

    /// x→整星点亮数：星 i 区域（x∈[i*30, (i+1)*30)）→ i+1；x<0（拖出左缘）=0。
    private func valueAt(x: CGFloat) -> Int {
        guard x >= 0 else { return 0 }
        let idx = Int(x / cell)
        return min(count, max(1, idx + 1))
    }

    private func clampValue(_ v: Int) -> Int {
        max(0, min(count, v))
    }

    private func syncFromExternal() {
        filled = clampValue(value ?? 0)
        setNeedsDisplay()
    }

    private func refreshInteraction() {
        isUserInteractionEnabled = !(readonly || disabled)
    }

    // MARK: - 绘制五角星

    override func draw(_ rect: CGRect) {
        guard count > 0 else { return }
        let centerY = bounds.midY
        for i in 0..<count {
            let on = i < filled
            let cx = CGFloat(i) * cell + Self.starRadius
            let color: UIColor = starColor(on: on)
            let path = Self.starPath(centerX: cx, centerY: centerY, radius: Self.starRadius)
            color.setFill()
            if on {
                path.fill()
            } else {
                color.setStroke()
                path.lineWidth = Self.hollowWidth
                path.lineJoinStyle = .round
                path.stroke()
            }
        }
    }

    private func starColor(on: Bool) -> UIColor {
        if on {
            return disabled
                ? AppColor.textSecondary.withAlphaComponent(0.4)
                : AppColor.primary
        }
        return disabled
            ? AppColor.textSecondary.withAlphaComponent(0.2)
            : AppColor.textSecondary.withAlphaComponent(0.3)
    }

    /// 五角星 path：外接圆半径 R、内接圆半径 R×0.382，起点顶点朝上（-90°）、每步 36°。
    /// 与 Android Rate.kt 同坐标算法（iOS/Compose 的 y 均向下=公式一致）。
    private static func starPath(centerX cx: CGFloat, centerY cy: CGFloat, radius R: CGFloat) -> UIBezierPath {
        let inner = R * innerRatio
        let path = UIBezierPath()
        var angle = -90.0
        for k in 0..<10 {
            let r = (k % 2 == 0) ? R : inner
            let rad = angle * Double.pi / 180
            let x = cx + r * CGFloat(cos(rad))
            let y = cy + r * CGFloat(sin(rad))
            if k == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
            angle += 36
        }
        path.close()
        return path
    }
}
