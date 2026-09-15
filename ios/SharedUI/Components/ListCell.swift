/// 通用列表 Cell 基类。

import UIKit
import SnapKit

/// 约束 Cell 内边距与行高的基类。
///
/// 子类只需关注业务内容布局，无需重复设置选中样式与间距。
public class ListCell: UITableViewCell {

    /// 统一内边距。
    public static let horizontalInset: CGFloat = AppSpace.lg
    /// 统一行高。
    public static let rowHeight: CGFloat = 56

    /// 初始化基础样式。
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .white
        contentView.backgroundColor = .white
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }
}
