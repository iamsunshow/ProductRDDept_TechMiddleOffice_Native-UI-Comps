import UIKit

/// Signature 签名（ui.signature，#40）——数据录入区全新立项（规格 signature-design-spec.html，门禁 A P1–P4 全 A）。
///
/// 内容级手写签名画板：横长白底圆角画板（宽宿主填充、高默认 96pt=2×48 表单交互行基准注释锚定、
/// bgCard 白底 + hairline 描边 + radiusLg 圆角对齐 Input #29 壳语言）+ 底缘引导线（hairline、
/// 左右留 AppSpace.lg、距底 AppSpace.lg）+ 手指/笔自绘圆头笔画（线帽 round、strokeWidth 默认 2、
/// strokeColor 默认 textPrimary=参数可调）+ 空态水印（placeholder 默认「请在此区域签名」
/// textSecondary 30% sizeMd 画板居中、首笔落下即隐藏、nil/空=无水印）。
///
/// 状态模型：签名=异步笔迹流（非表单值）=**无受控文本 value**。
/// - `onInkChange(Bool hasInk)`：首笔落下（空→非空）=true 一次性回调；`clear()` 清空（非空→空）=false
///   一次性回调（=驱动宿主「提交」钮可用态）；其余笔迹过程不重复回调。
/// - `clear()`=命令式（宿主「重新签名」钮调用）；disabled 期间忽略（=签署提交后锁定语义）。
/// - `disabled`=整板 40% 灰（含已有笔迹）、不采笔、无任何回调。
/// - 签名图导出=宿主截取组件渲染（UIGraphicsImageRenderer + drawHierarchy，组件不内置图形对象返回）。
///
/// 采集=UIView 触摸三件套（touchesBegan/Moved/Ended）换算 bounds 坐标追加 stroke 点集、draw(_:) 逐 path
/// 描圆头（同 Android pointerInput awaitEachGesture 采集 1:1）；clipsToBounds=笔画越界裁剪于圆角板内。
///
/// 规格：docs/数据与产物/design-spec/signature-design-spec.html（门禁 A，P1–P4 全 A）。
/// 基线：组件库 v1.4.0（2026-09-06，未过 C2/D 不升版）。
final class SignatureView: UIView {

    // MARK: - 度量（Token 注释锚定）
    struct Metrics {
        /// 高默认 96=2×48 表单交互行基准注释锚定（height 参数可调；无空间行高档 Token）
        static let defaultHeight: CGFloat = 96
        /// 笔画线宽默认 2（组件级集中常量，参数可调）
        static let defaultStrokeWidth: CGFloat = 2
        /// 边框/引导线 hairline（1/scale pt，与 Android 0.5dp 表内放行的系统级差异）
        static var hairline: CGFloat { 1 / UIScreen.main.scale }
        /// 引导线左右留/距底 = AppSpace.lg
        static let lineInset: CGFloat = AppSpace.lg
    }

    // MARK: - 对外参数
    /// onInkChange(Boolean hasInk)：首笔落 true/clear 清空回 false（驱动宿主「提交」钮可用态）
    var onInkChange: ((Bool) -> Void)?
    /// 空态水印文案（nil/空=无水印）；默认「请在此区域签名」
    var placeholder: String? = "请在此区域签名" { didSet { setNeedsDisplay() } }
    /// 笔画线宽（默认 2）
    var strokeWidth: CGFloat = Metrics.defaultStrokeWidth { didSet { setNeedsDisplay() } }
    /// 笔画颜色（默认 textPrimary）
    var strokeColor: UIColor = AppColor.textPrimary { didSet { setNeedsDisplay() } }
    /// 画板高（默认 96=2×48 交互行基准；宽=宿主填充）
    var boardHeight: CGFloat = Metrics.defaultHeight { didSet { invalidateIntrinsicContentSize() } }
    /// disabled=整板 40% 灰不可绘（签署提交后锁定）
    var disabled: Bool = false { didSet { refreshEnabled() } }

    // MARK: - 私有状态
    private struct InkStroke {
        var points: [CGPoint] = []
    }
    private var strokes: [InkStroke] = []

    // MARK: - 生命周期
    init(
        onInkChange: ((Bool) -> Void)? = nil,
        placeholder: String? = "请在此区域签名",
        strokeWidth: CGFloat = Metrics.defaultStrokeWidth,
        strokeColor: UIColor = AppColor.textPrimary,
        boardHeight: CGFloat = Metrics.defaultHeight,
        disabled: Bool = false
    ) {
        self.onInkChange = onInkChange
        self.placeholder = placeholder
        self.strokeWidth = strokeWidth
        self.strokeColor = strokeColor
        self.boardHeight = boardHeight
        self.disabled = disabled
        super.init(frame: .zero)
        commonInit()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: boardHeight)
    }

    private func commonInit() {
        backgroundColor = AppColor.bgCard // 白底=签名纸直觉（区别于表单 Input 灰底壳）
        layer.cornerRadius = AppRadius.lg // 对齐 Input #29 壳语言 radiusLg
        layer.borderWidth = Metrics.hairline
        layer.borderColor = AppColor.border.cgColor
        clipsToBounds = true // 圆角裁剪 + 笔画越界不外溢
        refreshEnabled()
    }

    // MARK: - 命令式 API
    /// 清空画板并回 onInkChange(false)；无笔迹=幂等不回调；disabled（签署锁定）=忽略。
    func clear() {
        guard !disabled, !strokes.isEmpty else { return }
        strokes.removeAll()
        onInkChange?(false)
        setNeedsDisplay()
    }

    private func refreshEnabled() {
        alpha = disabled ? 0.4 : 1 // 整板 40% 灰（同 Input #29 惯例=签署锁定）
        isUserInteractionEnabled = !disabled
        setNeedsDisplay()
    }

    // MARK: - 触摸采集（自绘离散 stroke 点集；与 Android pointerInput awaitEachGesture 1:1）
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !disabled, let point = touches.first?.location(in: self) else { return }
        if strokes.isEmpty { onInkChange?(true) } // 首笔落下（空→非空）一次性回调
        strokes.append(InkStroke(points: [point]))
        setNeedsDisplay()
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !disabled, var last = strokes.popLast() else { return }
        last.points.append(touches.first?.location(in: self) ?? last.points.last ?? .zero)
        strokes.append(last)
        setNeedsDisplay()
    }

    // MARK: - 绘制
    override func draw(_ rect: CGRect) {
        guard bounds.width > 0, bounds.height > 0 else { return }

        // 1. 底缘引导线：hairline、左右留 AppSpace.lg、距底 AppSpace.lg（同 Android Canvas drawLine 1:1）
        let guideY = bounds.height - Metrics.lineInset
        let guide = UIBezierPath()
        guide.move(to: CGPoint(x: Metrics.lineInset, y: guideY))
        guide.addLine(to: CGPoint(x: bounds.width - Metrics.lineInset, y: guideY))
        guide.lineWidth = Metrics.hairline
        guide.lineCapStyle = .round
        AppColor.border.setStroke()
        guide.stroke()

        // 2. 空态水印：无笔迹且 placeholder 非空=textSecondary 30% sizeMd 画板居中（首笔落下即消失）
        if strokes.isEmpty, let placeholder, !placeholder.isEmpty {
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: AppFont.sizeMd, weight: .regular),
                .foregroundColor: AppColor.textSecondary.withAlphaComponent(0.3)
            ]
            let size = (placeholder as NSString).size(withAttributes: attrs)
            (placeholder as NSString).draw(
                at: CGPoint(x: (bounds.width - size.width) / 2, y: (bounds.height - size.height) / 2),
                withAttributes: attrs
            )
        }

        // 3. 笔画：逐 stroke 点集直连绘制（线帽 round=签名顺滑直觉；与 Android drawPath 1:1）
        guard !strokes.isEmpty else { return }
        for seg in strokes where seg.points.count >= 2 {
            let path = UIBezierPath()
            path.move(to: seg.points[0])
            for i in 1..<seg.points.count {
                path.addLine(to: seg.points[i])
            }
            path.lineWidth = strokeWidth
            path.lineCapStyle = .round
            path.lineJoinStyle = .round
            strokeColor.setStroke()
            path.stroke()
        }
    }
}
