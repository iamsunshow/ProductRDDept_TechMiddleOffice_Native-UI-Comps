/// 通用空态视图，无业务依赖。

import UIKit
import SnapKit

/// 可复用空态组件。
///
/// 未设置文案时默认「暂无数据」；调用 `setMessage` 可覆盖为业务文案。
/// 可选设置图标 `setIcon`，图标居中于文案上方。
final class EmptyStateView: UIView {
    /// 列表空态默认文案。
    static let defaultMessage = "暂无数据"

    private let iconView = UIImageView()
    private let label = UILabel()
    private let stack = UIStackView()

    /// 初始化空态布局（默认「暂无数据」）。
    ///
    /// - Parameter frame: 初始 frame
    /// - Returns: 无
    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false

        iconView.isHidden = true
        iconView.tintColor = AppColor.textSecondary
        iconView.contentMode = .scaleAspectFit

        label.text = Self.defaultMessage
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = AppColor.textSecondary
        label.font = .systemFont(ofSize: AppFont.sizeMd)

        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = AppSpace.md
        stack.addArrangedSubview(iconView)
        stack.addArrangedSubview(label)
        addSubview(stack)
        stack.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(AppSpace.lg)
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    /// 设置空态提示文案；传空字符串则回退为默认「暂无数据」。
    ///
    /// - Parameter text: 展示文本
    /// - Returns: 无
    func setMessage(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        label.text = trimmed.isEmpty ? Self.defaultMessage : text
    }

    /// 设置空态图标（可选）；传 nil 隐藏图标。
    ///
    /// - Parameter image: 图标图片
    /// - Parameter size: 图标尺寸（pt），默认 48
    /// - Returns: 无
    func setIcon(_ image: UIImage?, size: CGFloat = 48) {
        iconView.image = image
        iconView.isHidden = (image == nil)
        iconView.snp.remakeConstraints { make in
            make.width.height.equalTo(size)
        }
    }
}
