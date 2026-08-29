/// 通用摘要卡片。

import UIKit
import SnapKit

/// 摘要卡片控件。
///
/// 展示标题、副标题、主数值与右侧辅助文案。
final class SummaryCardView: UIControl {
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let valueLabel = UILabel()
    private let accessoryLabel = UILabel()
    private let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))

    /// 初始化卡片布局。
    ///
    /// - Parameter frame: 初始 frame
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        layer.cornerRadius = AppRadius.lg
        layer.borderWidth = 1 / UIScreen.main.scale
        layer.borderColor = AppColor.border.cgColor
        clipsToBounds = true

        titleLabel.font = .systemFont(ofSize: AppFont.sizeMd, weight: .semibold)
        titleLabel.textColor = AppColor.textPrimary

        subtitleLabel.font = .systemFont(ofSize: AppFont.sizeXs)
        subtitleLabel.textColor = AppColor.textSecondary
        subtitleLabel.numberOfLines = 2

        valueLabel.font = .systemFont(ofSize: AppFont.sizeXl, weight: .semibold)
        valueLabel.textColor = AppColor.textPrimary

        accessoryLabel.font = .systemFont(ofSize: AppFont.sizeXs)
        accessoryLabel.textColor = AppColor.textSecondary
        accessoryLabel.textAlignment = .right

        chevron.tintColor = AppColor.textSecondary
        chevron.contentMode = .scaleAspectFit

        let top = UIStackView(arrangedSubviews: [titleLabel, UIView(), chevron])
        top.axis = .horizontal
        top.alignment = .center

        let bottom = UIStackView(arrangedSubviews: [valueLabel, accessoryLabel])
        bottom.axis = .horizontal
        bottom.alignment = .lastBaseline
        bottom.spacing = AppSpace.sm

        let stack = UIStackView(arrangedSubviews: [top, subtitleLabel, bottom])
        stack.axis = .vertical
        stack.spacing = AppSpace.sm
        stack.isUserInteractionEnabled = false
        addSubview(stack)

        chevron.snp.makeConstraints { make in
            make.width.height.equalTo(14)
        }
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(AppSpace.lg)
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    /// 绑定卡片展示内容。
    ///
    /// - Parameters:
    ///   - title: 主标题
    ///   - subtitle: 副标题
    ///   - value: 主数值文案
    ///   - valueColor: 主数值颜色
    ///   - accessory: 右侧辅助文案，nil 时隐藏
    func apply(title: String, subtitle: String, value: String, valueColor: UIColor, accessory: String?) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        valueLabel.text = value
        valueLabel.textColor = valueColor
        accessoryLabel.text = accessory
        accessoryLabel.isHidden = (accessory == nil)
    }
}
