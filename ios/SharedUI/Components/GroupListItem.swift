/// 通用列表行。

import UIKit
import SnapKit

/// 通用左文右值列表行。
///
/// 用于分组列表中的单行展示。
final class GroupListItem: UIControl {
    private let titleLabel = UILabel()
    private let valueLabel = UILabel()
    private let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
    private let badgeLabel = UILabel()

    /// 初始化列表行布局。
    ///
    /// - Parameter frame: 初始 frame
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white

        titleLabel.font = .systemFont(ofSize: AppFont.sizeMd)
        titleLabel.textColor = AppColor.textPrimary

        valueLabel.font = .systemFont(ofSize: AppFont.sizeSm)
        valueLabel.textColor = AppColor.textSecondary
        valueLabel.textAlignment = .right

        badgeLabel.font = .systemFont(ofSize: AppFont.sizeXs, weight: .medium)
        badgeLabel.textColor = AppColor.warning
        badgeLabel.isHidden = true

        chevron.tintColor = AppColor.textSecondary
        chevron.contentMode = .scaleAspectFit

        let right = UIStackView(arrangedSubviews: [badgeLabel, valueLabel, chevron])
        right.axis = .horizontal
        right.alignment = .center
        right.spacing = AppSpace.sm
        right.isUserInteractionEnabled = false

        let stack = UIStackView(arrangedSubviews: [titleLabel, right])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.isUserInteractionEnabled = false
        addSubview(stack)

        chevron.snp.makeConstraints { make in
            make.width.height.equalTo(12)
        }
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 14, left: AppSpace.lg, bottom: 14, right: AppSpace.lg))
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    /// 绑定行标题、右侧值与徽章。
    ///
    /// - Parameters:
    ///   - title: 左侧标题
    ///   - value: 右侧值，nil 或空时隐藏
    ///   - badge: 警告色徽章文案，nil 时隐藏
    ///   - showsChevron: 是否显示右箭头
    func apply(title: String, value: String?, badge: String? = nil, showsChevron: Bool = true) {
        titleLabel.text = title
        valueLabel.text = value
        valueLabel.isHidden = (value == nil || value?.isEmpty == true)
        badgeLabel.text = badge
        badgeLabel.isHidden = (badge == nil)
        chevron.isHidden = !showsChevron
    }
}
