/// 通用列表行容器：左侧可选图标 + 中间标题（可副标题）+ 右侧值/箭头/状态标识。
///
/// 对标 NutUI Cell / Ant Design List.Item，支持五态（默认/禁用/加载/成功/失败）。
/// 业务侧把数据映射为 `CellModel` 即可复用；事件参数（数据+索引）由业务侧绑定透传。
///
/// - Note: 加载态标题区骨架占位；按下态背景 `gray.4`，松手恢复；行高最小 48（两行副标题自动增高）。

import UIKit
import SnapKit

/// Cell 状态标识。
enum CellStatus {
    /// 默认：右侧按 `arrow` 显示箭头。
    case normal
    /// 成功：右侧 ✓（success 色）。
    case success
    /// 失败：右侧 !（error 色）。
    case error
}

/// 列表行数据模型（业务无关）。
struct CellModel {
    /// 主标题（必填）。
    var title: String
    /// 副标题；为空自动隐藏（单行）。
    var subtitle: String?
    /// 左侧图标（SF Symbol 名称）。
    var iconSymbol: String?
    /// 右侧值文本。
    var value: String?
    /// 是否显示右侧箭头，默认 true。
    var arrow: Bool = true
    /// 禁用态：背景置灰、文字置灰、不透箭头、不可点。
    var disabled: Bool = false
    /// 加载态：标题区骨架占位。
    var loading: Bool = false
    /// 状态标识，默认 .normal。
    var status: CellStatus = .normal

    init(
        title: String,
        subtitle: String? = nil,
        iconSymbol: String? = nil,
        value: String? = nil,
        arrow: Bool = true,
        disabled: Bool = false,
        loading: Bool = false,
        status: CellStatus = .normal
    ) {
        self.title = title
        self.subtitle = subtitle
        self.iconSymbol = iconSymbol
        self.value = value
        self.arrow = arrow
        self.disabled = disabled
        self.loading = loading
        self.status = status
    }
}

/// 通用列表行 Cell。
final class Cell: UITableViewCell {
    static let reuseId = "Cell"

    /// 最小行高（48）。
    static let minHeight: CGFloat = AppSpace.lg * 3

    /// 点击回调（参数=数据+索引）。
    var onTap: ((_ item: Any?, _ index: Int) -> Void)?
    /// 长按回调（iOS 触发；Android 不承诺，平台差异见平台登记）。
    var onLongPress: ((_ item: Any?, _ index: Int) -> Void)?
    /// 是否显示底部 1px 分隔线（最后一行由业务置 false）。
    var showsDivider: Bool = true {
        didSet { divider.isHidden = !showsDivider }
    }

    private var boundItem: Any?
    private var boundIndex: Int = -1

    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let valueLabel = UILabel()
    private let arrowView = UIImageView()
    private let statusBadge = UIImageView()
    private let skeletonView = UIView()
    private let divider = UIView()
    private var textStack: UIStackView!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = AppColor.bgCard

        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = AppColor.textSecondary

        titleLabel.font = .systemFont(ofSize: AppFont.sizeMd)
        titleLabel.textColor = AppColor.textPrimary
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        subtitleLabel.font = .systemFont(ofSize: AppFont.sizeSm)
        subtitleLabel.textColor = AppColor.textSecondary
        subtitleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        valueLabel.font = .systemFont(ofSize: AppFont.sizeSm)
        valueLabel.textColor = AppColor.textSecondary
        valueLabel.textAlignment = .right
        valueLabel.setContentHuggingPriority(.required, for: .horizontal)

        arrowView.image = UIImage(systemName: "chevron.right")
        arrowView.tintColor = AppColor.gray25
        arrowView.contentMode = .scaleAspectFit
        arrowView.setContentHuggingPriority(.required, for: .horizontal)

        statusBadge.contentMode = .scaleAspectFit
        statusBadge.setContentHuggingPriority(.required, for: .horizontal)

        skeletonView.backgroundColor = AppColor.border
        skeletonView.layer.cornerRadius = AppRadius.sm
        skeletonView.isHidden = true

        divider.backgroundColor = AppColor.border

        textStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        textStack.axis = .vertical
        textStack.spacing = AppSpace.xs
        textStack.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        contentView.addSubview(iconView)
        contentView.addSubview(textStack)
        contentView.addSubview(valueLabel)
        contentView.addSubview(arrowView)
        contentView.addSubview(statusBadge)
        contentView.addSubview(skeletonView)
        contentView.addSubview(divider)

        iconView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(AppSpace.lg)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(AppSpace.xl)
        }
        arrowView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(AppSpace.lg)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(AppSpace.lg)
        }
        statusBadge.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(AppSpace.lg)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(AppSpace.xl)
        }
        divider.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(AppSpace.lg)
            make.trailing.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
        // 文本/骨架/右侧值的约束在 apply 中按 icon/arrow 显隐调整。
        skeletonView.snp.makeConstraints { make in
            make.leading.equalTo(textStack)
            make.centerY.equalTo(textStack)
            make.width.equalTo(textStack.snp.width)
            make.height.equalTo(AppFont.sizeMd)
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        addGestureRecognizer(longPress)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    /// 用数据模型绑定 Cell。
    ///
    /// - Parameter model: 列表行数据
    /// - Returns: 无
    func apply(_ model: CellModel) {
        boundItem = model
        titleLabel.text = model.title
        subtitleLabel.text = model.subtitle

        // 左侧图标：存在时文本列右移，否则从左边距起排。
        if let symbol = model.iconSymbol, !symbol.isEmpty {
            iconView.image = UIImage(systemName: symbol)
            iconView.isHidden = false
            textStack.snp.remakeConstraints { make in
                make.leading.equalTo(iconView.snp.trailing).offset(AppSpace.md)
                make.centerY.equalToSuperview()
                make.trailing.lessThanOrEqualTo(valueLabel.snp.leading).offset(-AppSpace.sm)
                make.top.greaterThanOrEqualToSuperview().offset(AppSpace.md)
                make.bottom.lessThanOrEqualToSuperview().offset(-AppSpace.md)
            }
        } else {
            iconView.image = nil
            iconView.isHidden = true
            textStack.snp.remakeConstraints { make in
                make.leading.equalToSuperview().offset(AppSpace.lg)
                make.centerY.equalToSuperview()
                make.trailing.lessThanOrEqualTo(valueLabel.snp.leading).offset(-AppSpace.sm)
                make.top.greaterThanOrEqualToSuperview().offset(AppSpace.md)
                make.bottom.lessThanOrEqualToSuperview().offset(-AppSpace.md)
            }
        }

        // 右侧值。
        if let value = model.value, !value.isEmpty {
            valueLabel.text = value
            valueLabel.isHidden = false
        } else {
            valueLabel.text = nil
            valueLabel.isHidden = true
        }

        // 状态标识：success/error 时替换箭头位。
        let hasStatus = model.status != .normal
        switch model.status {
        case .success:
            statusBadge.image = UIImage(systemName: "checkmark.circle.fill")
            statusBadge.tintColor = AppColor.success
        case .error:
            statusBadge.image = UIImage(systemName: "exclamationmark.circle.fill")
            statusBadge.tintColor = AppColor.error
        case .normal:
            statusBadge.image = nil
        }
        statusBadge.isHidden = !hasStatus

        // 箭头：arrow 且无状态标识且非禁用时显示；隐藏时值文本贴右。
        let showArrow = model.arrow && !hasStatus && !model.disabled
        arrowView.isHidden = !showArrow
        valueLabel.snp.remakeConstraints { make in
            make.trailing.equalTo(showArrow ? arrowView.snp.leading : self.contentView.snp.trailing)
                .offset(showArrow ? -AppSpace.sm : -AppSpace.lg)
            make.centerY.equalToSuperview()
            make.leading.greaterThanOrEqualTo(textStack.snp.trailing).offset(AppSpace.sm)
        }

        // 加载骨架。
        let loading = model.loading
        skeletonView.isHidden = !loading
        titleLabel.isHidden = loading
        subtitleLabel.isHidden = loading || (model.subtitle?.isEmpty ?? true)
        if loading {
            startSkeleton()
        } else {
            stopSkeleton()
        }

        // 禁用态：背景/文字置灰、不透标识、不可点。
        let disabled = model.disabled
        contentView.backgroundColor = disabled ? AppColor.gray4 : AppColor.bgCard
        titleLabel.textColor = disabled ? AppColor.gray25 : AppColor.textPrimary
        subtitleLabel.textColor = disabled ? AppColor.gray25 : AppColor.textSecondary
        valueLabel.textColor = disabled ? AppColor.gray25 : AppColor.textSecondary
        iconView.tintColor = disabled ? AppColor.gray25 : AppColor.textSecondary
        if disabled { statusBadge.isHidden = true }
        isUserInteractionEnabled = !disabled
    }

    /// 按下态反馈：背景 gray.4，松手恢复。
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        contentView.backgroundColor = highlighted ? AppColor.gray4 : AppColor.bgCard
    }

    @objc private func handleTap() {
        onTap?(boundItem, boundIndex)
    }

    @objc private func handleLongPress(_ recognizer: UILongPressGestureRecognizer) {
        guard recognizer.state == .began else { return }
        onLongPress?(boundItem, boundIndex)
    }

    private func startSkeleton() {
        stopSkeleton()
        let pulse = CABasicAnimation(keyPath: "opacity")
        pulse.fromValue = 1
        pulse.toValue = 0.35
        pulse.duration = 0.8
        pulse.autoreverses = true
        pulse.repeatCount = .infinity
        skeletonView.layer.add(pulse, forKey: "skeletonPulse")
    }

    private func stopSkeleton() {
        skeletonView.layer.removeAnimation(forKey: "skeletonPulse")
    }
}
