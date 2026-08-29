/// 通用媒体列表行：左图标（首字块或系统图标）+ 标题 + 副标题 + 右侧数值。
///
/// 对标 Ant Design List.Item 的 media 变体，可承载任意"实体 + 摘要 + 状态值"的列表场景，
/// 不绑定任何业务实体。业务侧只需把自身数据映射为 `MediaListCellModel` 即可复用。

import UIKit
import SnapKit

/// 媒体列表行数据模型（业务无关）。
struct MediaListCellModel {
    /// 左侧图标文案（优先展示，如分类/实体的首字）；为空时回退到 `iconSymbol`。
    var iconText: String?
    /// 左侧系统图标（SF Symbol 名称）；`iconText` 为空时使用。
    var iconSymbol: String?
    /// 主标题。
    var title: String
    /// 副标题；为空时自动隐藏。
    var subtitle: String?
    /// 右侧数值文本；为空时整列右移对齐标题。
    var value: String?
    /// 右侧数值颜色。
    var valueColor: UIColor

    init(
        iconText: String? = nil,
        iconSymbol: String? = nil,
        title: String,
        subtitle: String? = nil,
        value: String? = nil,
        valueColor: UIColor = AppColor.textPrimary
    ) {
        self.iconText = iconText
        self.iconSymbol = iconSymbol
        self.title = title
        self.subtitle = subtitle
        self.value = value
        self.valueColor = valueColor
    }
}

/// 媒体列表行 Cell。
final class MediaListCell: ListCell {
    static let reuseId = "MediaListCell"

    private let iconView = UIView()
    private let iconLabel = UILabel()
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let noteLabel = UILabel()
    private let valueLabel = UILabel()

    /// 初始化 Cell 布局。
    ///
    /// - Parameters:
    ///   - style: Cell 样式
    ///   - reuseIdentifier: 复用标识
    /// - Returns: 无
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = AppColor.bgCard

        iconView.backgroundColor = AppColor.primaryMuted
        iconView.layer.cornerRadius = 18

        iconLabel.font = .systemFont(ofSize: AppFont.sizeSm, weight: .medium)
        iconLabel.textColor = AppColor.primary
        iconLabel.textAlignment = .center

        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = AppColor.primary

        titleLabel.font = .systemFont(ofSize: AppFont.sizeMd, weight: .medium)
        titleLabel.textColor = AppColor.textPrimary

        noteLabel.font = .systemFont(ofSize: AppFont.sizeXs)
        noteLabel.textColor = AppColor.textSecondary

        valueLabel.font = .systemFont(ofSize: AppFont.sizeMd, weight: .semibold)
        valueLabel.textAlignment = .right

        let textStack = UIStackView(arrangedSubviews: [titleLabel, noteLabel])
        textStack.axis = .vertical
        textStack.spacing = 2

        contentView.addSubview(iconView)
        iconView.addSubview(iconLabel)
        iconView.addSubview(iconImageView)
        contentView.addSubview(textStack)
        contentView.addSubview(valueLabel)

        iconView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(AppSpace.lg)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(36)
        }
        iconLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        iconImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(9)
        }
        textStack.snp.makeConstraints { make in
            make.leading.equalTo(iconView.snp.trailing).offset(AppSpace.md)
            make.centerY.equalToSuperview()
            make.trailing.lessThanOrEqualTo(valueLabel.snp.leading).offset(-AppSpace.sm)
        }
        valueLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(AppSpace.lg)
            make.centerY.equalToSuperview()
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    /// 用数据模型绑定 Cell。
    ///
    /// - Parameter model: 媒体列表行数据
    /// - Returns: 无
    func apply(_ model: MediaListCellModel) {
        titleLabel.text = model.title
        noteLabel.text = model.subtitle
        noteLabel.isHidden = (model.subtitle?.isEmpty ?? true)

        if let iconText = model.iconText, !iconText.isEmpty {
            iconLabel.text = String(iconText.prefix(1))
            iconImageView.image = nil
            iconLabel.isHidden = false
            iconImageView.isHidden = true
            iconView.isHidden = false
        } else if let symbol = model.iconSymbol {
            iconLabel.text = nil
            iconImageView.image = UIImage(systemName: symbol)
            iconLabel.isHidden = true
            iconImageView.isHidden = false
            iconView.isHidden = false
        } else {
            iconView.isHidden = true
        }

        if let value = model.value, !value.isEmpty {
            valueLabel.text = value
            valueLabel.textColor = model.valueColor
            valueLabel.isHidden = false
        } else {
            valueLabel.isHidden = true
        }
    }
}
