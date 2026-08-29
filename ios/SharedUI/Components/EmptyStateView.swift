/// 通用空态视图，无业务依赖。

import UIKit
import SnapKit

/// 可复用空态组件。
///
/// 未设置文案时默认「暂无数据」；调用 `setMessage` 可覆盖为业务文案。
final class EmptyStateView: UIView {
    /// 列表空态默认文案。
    static let defaultMessage = "暂无数据"

    private let label = UILabel()

    /// 初始化空态布局（默认「暂无数据」）。
    ///
    /// - Parameter frame: 初始 frame
    /// - Returns: 无
    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        label.text = Self.defaultMessage
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = AppColor.textSecondary
        label.font = .systemFont(ofSize: AppFont.sizeMd)
        addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
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
}
