/// 通用进度列表行：名次 + 图标 + 名称/百分比 + 数值 + 矮进度条。
///
/// 对标 Ant Design List.Item + Progress 的组合形态，可承载"排行 / 占比 / 达成度"等场景，
/// 不绑定任何业务实体。业务侧只需把自身数据映射为 `ProgressListCellModel` 即可复用。

import UIKit
import SnapKit

/// 进度列表行数据模型（业务无关）。
struct ProgressListCellModel {
    /// 名次（从 1 起）。
    var rank: Int
    /// 左侧图标（SF Symbol 名称）；为空时用名称首字占位。
    var iconSymbol: String?
    /// 主名称。
    var name: String
    /// 数值文本（如金额、得分）。
    var value: String
    /// 进度占比（0...1）。
    var progress: Double
    /// 进度条与数值的强调色。
    var barColor: UIColor

    init(
        rank: Int,
        iconSymbol: String? = nil,
        name: String,
        value: String,
        progress: Double,
        barColor: UIColor = AppColor.primary
    ) {
        self.rank = rank
        self.iconSymbol = iconSymbol
        self.name = name
        self.value = value
        self.progress = progress
        self.barColor = barColor
    }
}

/// 进度列表行 Cell。
final class ProgressListCell: ListCell {
    static let reuseId = "ProgressListCell"

    private let rankLabel = UILabel()
    private let iconView = UIImageView()
    private let nameLabel = UILabel()
    private let percentLabel = UILabel()
    private let valueLabel = UILabel()
    private let barTrack = UIView()
    private let barFill = UIView()
    private var titleRow: UIStackView!

    /// 初始化 Cell 子视图与约束。
    ///
    /// - Parameters:
    ///   - style: Cell 样式
    ///   - reuseIdentifier: 复用标识
    /// - Returns: 无
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        rankLabel.font = .systemFont(ofSize: AppFont.sizeXs, weight: .bold)
        rankLabel.textAlignment = .center

        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = AppColor.primary

        nameLabel.font = .systemFont(ofSize: AppFont.sizeSm, weight: .medium)
        nameLabel.textColor = AppColor.textPrimary
        nameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        percentLabel.font = .systemFont(ofSize: AppFont.sizeXs)
        percentLabel.textColor = AppColor.textSecondary
        percentLabel.setContentHuggingPriority(.required, for: .horizontal)

        valueLabel.font = .systemFont(ofSize: AppFont.sizeSm, weight: .semibold)
        valueLabel.textAlignment = .right
        valueLabel.setContentHuggingPriority(.required, for: .horizontal)

        barTrack.backgroundColor = AppColor.primaryMuted
        barTrack.layer.cornerRadius = 2
        barFill.backgroundColor = AppColor.primary
        barFill.layer.cornerRadius = 2

        titleRow = UIStackView(arrangedSubviews: [nameLabel, percentLabel])
        titleRow.axis = .horizontal
        titleRow.alignment = .center
        titleRow.spacing = AppSpace.sm

        contentView.addSubview(rankLabel)
        contentView.addSubview(iconView)
        contentView.addSubview(titleRow)
        contentView.addSubview(valueLabel)
        contentView.addSubview(barTrack)
        barTrack.addSubview(barFill)

        rankLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(AppSpace.lg)
            make.top.equalToSuperview().offset(AppSpace.md)
            make.width.equalTo(20)
        }
        iconView.snp.makeConstraints { make in
            make.leading.equalTo(rankLabel.snp.trailing).offset(AppSpace.sm)
            make.centerY.equalTo(rankLabel)
            make.width.height.equalTo(20)
        }
        valueLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(AppSpace.lg)
            make.centerY.equalTo(rankLabel)
        }
        titleRow.snp.makeConstraints { make in
            make.leading.equalTo(iconView.snp.trailing).offset(AppSpace.sm)
            make.centerY.equalTo(rankLabel)
            make.trailing.lessThanOrEqualTo(valueLabel.snp.leading).offset(-AppSpace.sm)
        }
        barTrack.snp.makeConstraints { make in
            make.leading.equalTo(titleRow)
            make.trailing.equalToSuperview().inset(AppSpace.lg)
            make.top.equalTo(rankLabel.snp.bottom).offset(AppSpace.md)
            make.height.equalTo(4)
            make.bottom.equalToSuperview().inset(AppSpace.md)
        }
        barFill.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.01)
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    /// 用数据模型绑定 Cell。
    ///
    /// - Parameter model: 进度列表行数据
    /// - Returns: 无
    func apply(_ model: ProgressListCellModel) {
        rankLabel.text = "\(model.rank)"
        rankLabel.textColor = model.rank <= 3 ? AppColor.primary : AppColor.textSecondary

        if let symbol = model.iconSymbol {
            iconView.image = UIImage(systemName: symbol)
            iconView.isHidden = false
            titleRow.snp.remakeConstraints { make in
                make.leading.equalTo(iconView.snp.trailing).offset(AppSpace.sm)
                make.centerY.equalTo(rankLabel)
                make.trailing.lessThanOrEqualTo(valueLabel.snp.leading).offset(-AppSpace.sm)
            }
        } else {
            iconView.isHidden = true
            titleRow.snp.remakeConstraints { make in
                make.leading.equalTo(rankLabel.snp.trailing).offset(AppSpace.sm)
                make.centerY.equalTo(rankLabel)
                make.trailing.lessThanOrEqualTo(valueLabel.snp.leading).offset(-AppSpace.sm)
            }
        }

        nameLabel.text = model.name
        valueLabel.text = model.value
        valueLabel.textColor = model.barColor
        percentLabel.text = String(format: "%.1f%%", model.progress * 100)
        barFill.backgroundColor = model.barColor
        let ratio = max(0.02, min(model.progress, 1))
        barFill.snp.remakeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(ratio)
        }
    }
}
