/// Tag 标签组件（UIKit 版，对齐 Android Tag）。
///
/// 彩色标签，用于状态标识、分类标记、关键词展示。
/// 三种形态：filled（实心白字）/ outline（描边）/ light（浅色底深色字）。
/// 四种主题色：primary / success / warning / error。
/// 三种尺寸：sm / md / lg。可选关闭按钮。

import UIKit
import SnapKit

/// 标签主题色。
enum TagColor {
    case primary, success, warning, error

    var color: UIColor {
        switch self {
        case .primary: return AppColor.primary
        case .success: return AppColor.success
        case .warning: return AppColor.warning
        case .error: return AppColor.error
        }
    }
}

/// 标签形态。
enum TagVariant {
    /// 实心填充，白字。
    case filled
    /// 描边，深色字。
    case outline
    /// 浅色底，深色字。
    case light
}

/// 标签尺寸。
enum TagSize {
    case sm, md, lg

    var height: CGFloat {
        switch self {
        case .sm: return 20
        case .md: return 24
        case .lg: return 28
        }
    }

    var fontSize: CGFloat {
        switch self {
        case .sm: return 11
        case .md: return 12
        case .lg: return 14
        }
    }

    var paddingH: CGFloat {
        switch self {
        case .sm: return 6
        case .md: return 8
        case .lg: return 10
        }
    }

    var iconSize: CGFloat {
        switch self {
        case .sm: return 12
        case .md: return 14
        case .lg: return 16
        }
    }
}

/// 标签组件。
final class TagView: UIView {
    // MARK: - 配置

    var text: String = "" { didSet { updateAppearance() } }
    var tagColor: TagColor = .primary { didSet { updateAppearance() } }
    var variant: TagVariant = .filled { didSet { updateAppearance() } }
    var tagSize: TagSize = .sm { didSet { updateAppearance() } }
    var closable: Bool = false { didSet { updateAppearance() } }
    var onClose: (() -> Void)?

    // MARK: - 子视图

    private let label = UILabel()
    private let closeIcon = UIImageView()
    private let contentStack = UIStackView()

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = AppRadius.sm
        clipsToBounds = true

        // 内部用 UIStackView 水平排列 label + closeIcon，与 Android Compose Row 同构
        contentStack.axis = .horizontal
        contentStack.alignment = .center
        contentStack.spacing = 2
        addSubview(contentStack)
        contentStack.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(tagSize.paddingH)
            make.trailing.equalToSuperview().offset(-tagSize.paddingH)
            make.top.bottom.equalToSuperview()
        }

        label.textAlignment = .center
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        contentStack.addArrangedSubview(label)

        closeIcon.contentMode = .scaleAspectFit
        closeIcon.image = UIImage(systemName: "xmark")
        closeIcon.isUserInteractionEnabled = true
        closeIcon.setContentHuggingPriority(.required, for: .horizontal)
        closeIcon.setContentCompressionResistancePriority(.required, for: .horizontal)
        let tap = UITapGestureRecognizer(target: self, action: #selector(closeTapped))
        closeIcon.addGestureRecognizer(tap)
        contentStack.addArrangedSubview(closeIcon)

        updateAppearance()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("TagView does not support NSCoder") }

    /// 便捷初始化。
    convenience init(text: String, variant: TagVariant = .filled, color: TagColor = .primary, size: TagSize = .sm, closable: Bool = false) {
        self.init(frame: .zero)
        self.text = text
        self.variant = variant
        self.tagColor = color
        self.tagSize = size
        self.closable = closable
    }

    // MARK: - intrinsicContentSize

    override var intrinsicContentSize: CGSize {
        let labelW = label.intrinsicContentSize.width
        let iconW: CGFloat = closable ? tagSize.iconSize + 2 : 0
        let w = tagSize.paddingH * 2 + labelW + iconW
        return CGSize(width: w, height: tagSize.height)
    }

    // MARK: - 外观更新

    private func updateAppearance() {
        let c = tagColor.color
        label.text = text
        label.font = .systemFont(ofSize: tagSize.fontSize, weight: .medium)

        // closeIcon 尺寸约束（用 Snashot 约束而非 frame，避免 layoutSubviews 循环）
        closeIcon.snp.remakeConstraints { make in
            make.width.height.equalTo(tagSize.iconSize)
        }
        closeIcon.isHidden = !closable

        // contentStack 内边距随尺寸调整
        contentStack.snp.updateConstraints { make in
            make.leading.equalToSuperview().offset(tagSize.paddingH)
            make.trailing.equalToSuperview().offset(-tagSize.paddingH)
        }

        switch variant {
        case .filled:
            backgroundColor = c
            label.textColor = .white
            closeIcon.tintColor = .white
            layer.borderWidth = 0
        case .outline:
            backgroundColor = .clear
            label.textColor = c
            closeIcon.tintColor = c
            layer.borderWidth = 1
            layer.borderColor = c.cgColor
        case .light:
            backgroundColor = c.withAlphaComponent(0.1)
            label.textColor = c
            closeIcon.tintColor = c
            layer.borderWidth = 0
        }

        invalidateIntrinsicContentSize()
    }

    // MARK: - 点击

    @objc private func closeTapped() {
        onClose?()
    }
}
