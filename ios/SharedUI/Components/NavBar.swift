/// NavBar 头部导航（ui.nav-bar，#17）。
///
/// 顶部单行头部导航条（收编升级为库内独立组件）。
/// 契约：标题居中单行省略；onBack=nil 时返回槽不占位、标题严格水平居中；
/// 右侧动作 text + 可选 color + onTap；内容高 44pt，宿主可高度约束覆盖；
/// 白底 bgCard + 行底 hairline；导航栈/inset 由宿主自理。
/// 对应 Android：NavBar(title, onBack?, rightAction?, modifier)。
/// 版本：Native-UI-Comps ui-version v1.4.0（本文件为新组件初版，随 demo 徽标 v1.0）。
import UIKit
import SnapKit

/// 右侧导航动作数据（与 Android `NavBarAction` 同构）。
struct NavBarAction {
    let text: String
    let color: UIColor?
    let onTap: () -> Void

    init(text: String, color: UIColor? = nil, onTap: @escaping () -> Void) {
        self.text = text
        self.color = color
        self.onTap = onTap
    }
}

/// 头部导航条。
final class NavBar: UIView {
    struct Metrics {
        static let contentHeight: CGFloat = 44 // 行高 44pt（宿主可覆盖）
        static let backGlyph = "←"
        static let backHitWidth: CGFloat = 44 // 返回热区宽 ≥40pt
        static let backGlyphInset: CGFloat = AppSpace.sm // ← 距左 8pt
        static let actionTapInset: CGFloat = AppSpace.md // 右侧动作左右内边距
        static let sideInset: CGFloat = AppSpace.lg
        static let titleSideInset: CGFloat = AppSpace.md
    }

    /// 标题（可改，改后就地刷新）。
    var title: String {
        didSet { titleLabel.text = title }
    }

    /// 返回回调；nil = 一级页不显示返回钮（标题严格居中）。
    var onBack: (() -> Void)? {
        didSet {
            backClosure = onBack
            rebuildSides()
        }
    }

    /// 右侧动作；nil = 不显示。
    var rightAction: NavBarAction? {
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

    init(title: String, onBack: (() -> Void)? = nil, rightAction: NavBarAction? = nil) {
        self.title = title
        self.onBack = onBack
        self.rightAction = rightAction
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

    override var intrinsicContentSize: CGSize {
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
            button.setTitle(Metrics.backGlyph, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: AppFont.sizeXl)
            button.setTitleColor(AppColor.primary, for: .normal)
            button.contentHorizontalAlignment = .left
            button.contentEdgeInsets = UIEdgeInsets(top: 0, left: Metrics.backGlyphInset, bottom: 0, right: 0)
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
