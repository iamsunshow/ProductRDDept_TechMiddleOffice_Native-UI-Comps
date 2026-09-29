/// NavBar 头部导航（ui.nav-bar，#17）。
///
/// 顶部单行头部导航条（收编升级为库内独立组件）。
/// 契约：标题严格水平居中（centerX 定位，不受返回槽/动作槽宽度影响）；
/// onBack=nil 时返回槽不渲染；右侧动作 text + 可选 color + onTap；
/// 内容高 44pt，宿主可高度约束覆盖；白底 bgCard + 行底 hairline（可关）；
/// 导航栈/inset 由宿主自理。
/// 对应 Android：NavBar(title, onBack?, rightAction?, showDivider, modifier)。
/// 版本：Native-UI-Comps ui-version v1.0.22（返回按钮改 Material ArrowBack 同款 24pt 图标 +
/// 48pt 热区贴左通用样式；颜色按背景亮度自适应浅色底 primary/深色底白）。
import UIKit
import SnapKit

/// 右侧导航动作数据（与 Android `NavBarAction` 同构）。
public struct NavBarAction {
    public let text: String
    public let color: UIColor?
    public let onTap: () -> Void

    public init(text: String, color: UIColor? = nil, onTap: @escaping () -> Void) {
        self.text = text
        self.color = color
        self.onTap = onTap
    }
}

/// 头部导航条。
public final class NavBar: UIView {
    public struct Metrics {
        public static let contentHeight: CGFloat = 44 // 行高 44pt（宿主可覆盖）
        public static let backArrowSize: CGFloat = 24 // Material ArrowBack 图标边长（Android ScreenTopBar 同款，v1.0.22 起通用样式）
        public static let backArrowStroke: CGFloat = 2 // 箭头线宽
        public static let backHitWidth: CGFloat = 48 // 返回热区宽（图标居中，中心距左 24pt）
        public static let actionTapInset: CGFloat = AppSpace.md // 右侧动作左右内边距
        public static let sideInset: CGFloat = AppSpace.lg
        public static let titleSideInset: CGFloat = AppSpace.md
    }

    /// 标题（可改，改后就地刷新）。
    public var title: String {
        didSet { titleLabel.text = title }
    }

    /// 返回回调；nil = 一级页不显示返回钮（标题严格居中）。
    public var onBack: (() -> Void)? {
        didSet {
            backClosure = onBack
            rebuildSides()
        }
    }

    /// 右侧动作；nil = 不显示。
    public var rightAction: NavBarAction? {
        didSet {
            actionClosure = rightAction?.onTap
            rebuildSides()
        }
    }

    private let titleLabel = UILabel()
    private let hairline = UIView()
    private var backButton: UIButton?
    private var actionButton: UIButton?
    private var backClosure: (() -> Void)?
    private var actionClosure: (() -> Void)?
    private let showDivider: Bool

    public init(title: String, onBack: (() -> Void)? = nil, rightAction: NavBarAction? = nil, showDivider: Bool = true) {
        self.title = title
        self.onBack = onBack
        self.rightAction = rightAction
        self.showDivider = showDivider
        self.backClosure = onBack
        self.actionClosure = rightAction?.onTap
        super.init(frame: .zero)
        backgroundColor = AppColor.bgCard
        setupTitle()
        setupHairline()
        rebuildSides()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    public override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: Metrics.contentHeight)
    }

    private func setupTitle() {
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: AppFont.sizeLg, weight: .semibold)
        titleLabel.textColor = AppColor.textPrimary
        titleLabel.textAlignment = .center
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.numberOfLines = 1
        // 长标题在左右槽位夹挤下允许压缩省略
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        addSubview(titleLabel)
    }

    private func setupHairline() {
        hairline.backgroundColor = AppColor.border
        hairline.isHidden = !showDivider
        addSubview(hairline)
        hairline.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(1 / UIScreen.main.scale)
        }
    }

    /// 依据 onBack/rightAction 重建左右槽位并刷新标题约束。
    private func rebuildSides() {
        backButton?.removeFromSuperview()
        backButton = nil
        actionButton?.removeFromSuperview()
        actionButton = nil

        if backClosure != nil {
            let button = UIButton(type: .system)
            // 返回按钮：Android ScreenTopBar（更多页/家庭账单页）同款通用样式，v1.0.22 写入组件库——
            // 48pt 热区贴左 + Material ArrowBack 24pt 图标居中（图标中心距左 24pt）；
            // 颜色按背景亮度自适应：浅色底 primary 绿、深色底白。
            let tint = (backgroundColor?.luminance ?? 1) > 0.5 ? AppColor.primary : .white
            let arrow = ArrowGlyphView(color: tint)
            arrow.isUserInteractionEnabled = false
            button.addSubview(arrow)
            arrow.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.centerY.equalToSuperview()
                make.width.equalTo(Metrics.backArrowSize)
                make.height.equalTo(Metrics.backArrowSize)
            }
            button.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
            addSubview(button)
            button.snp.makeConstraints { make in
                make.leading.equalToSuperview()
                make.centerY.equalToSuperview()
                make.width.equalTo(Metrics.backHitWidth)
                make.height.equalTo(Metrics.contentHeight)
            }
            backButton = button
        }

        if let right = rightAction {
            let button = UIButton(type: .system)
            button.setTitle(right.text, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: AppFont.sizeSm)
            button.setTitleColor(right.color ?? AppColor.textPrimary, for: .normal)
            button.contentHorizontalAlignment = .right
            button.contentEdgeInsets = UIEdgeInsets(top: 0, left: Metrics.actionTapInset, bottom: 0, right: Metrics.actionTapInset)
            button.addTarget(self, action: #selector(didTapAction), for: .touchUpInside)
            addSubview(button)
            button.snp.makeConstraints { make in
                make.trailing.equalToSuperview()
                make.centerY.equalToSuperview()
                make.width.greaterThanOrEqualTo(Metrics.contentHeight)
                make.height.equalTo(Metrics.contentHeight)
            }
            actionButton = button
        }

        refreshTitleConstraints()
    }

    /// 标题：整条中心定位；长标题时向两侧回退但不得侵入返回/动作热区。
    private func refreshTitleConstraints() {
        titleLabel.snp.remakeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            if let backButton {
                make.leading.greaterThanOrEqualTo(backButton.snp.trailing).offset(AppSpace.xs)
            } else {
                make.leading.greaterThanOrEqualToSuperview().offset(Metrics.titleSideInset)
            }
            if let actionButton {
                make.trailing.lessThanOrEqualTo(actionButton.snp.leading).offset(-AppSpace.xs)
            } else {
                make.trailing.lessThanOrEqualToSuperview().offset(-Metrics.titleSideInset)
            }
        }
    }

    @objc private func didTapBack() {
        backClosure?()
    }

    @objc private func didTapAction() {
        actionClosure?()
    }
}

/// 返回箭头矢量字形（Material ArrowBack 几何自绘，v1.0.22 起作为 NavBar 通用返回样式）。
///
/// 24×24pt 视口：chevron (12,4)→(4,12)→(12,20) + 横轴 (7.83,12)→(20,12)，线宽 2pt 圆头。
/// 与 Android NavBar Material Icons.AutoMirrored.Outlined.ArrowBack 1:1；几何中心=视口中心。
private final class ArrowGlyphView: UIView {
    private let strokeColor: UIColor

    init(color: UIColor) {
        self.strokeColor = color
        super.init(frame: .zero)
        backgroundColor = .clear
        isOpaque = false
        contentMode = .redraw
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override func draw(_ rect: CGRect) {
        let path = UIBezierPath()
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        path.lineWidth = NavBar.Metrics.backArrowStroke
        let w = bounds.width
        let h = bounds.height
        // chevron 两臂
        path.move(to: CGPoint(x: w * (12.0 / 24.0), y: h * (4.0 / 24.0)))
        path.addLine(to: CGPoint(x: w * (4.0 / 24.0), y: h * (12.0 / 24.0)))
        path.addLine(to: CGPoint(x: w * (12.0 / 24.0), y: h * (20.0 / 24.0)))
        // 横轴（箭杆）
        path.move(to: CGPoint(x: w * (7.83 / 24.0), y: h * (12.0 / 24.0)))
        path.addLine(to: CGPoint(x: w * (20.0 / 24.0), y: h * (12.0 / 24.0)))
        strokeColor.setStroke()
        path.stroke()
    }
}

/// 背景色亮度（0~1），用于返回箭头颜色自适应（浅色底 primary / 深色底白）。
private extension UIColor {
    var luminance: CGFloat {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return 0.299 * r + 0.587 * g + 0.114 * b
    }
}
