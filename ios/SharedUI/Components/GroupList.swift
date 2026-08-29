/// 通用分组列表容器。

import UIKit
import SnapKit

/// 圆角白底分组容器。
///
/// 垂直排列 `GroupListItem` 并在行间插入分隔线。
final class GroupList: UIView {
    private let stack = UIStackView()

    /// 初始化空分组容器。
    ///
    /// - Parameter frame: 初始 frame
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        layer.cornerRadius = AppRadius.lg
        clipsToBounds = true
        stack.axis = .vertical
        addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    /// 设置分组内的列表行（自动插入分隔线）。
    ///
    /// - Parameter rows: 列表行视图数组
    func setRows(_ rows: [GroupListItem]) {
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for (index, row) in rows.enumerated() {
            stack.addArrangedSubview(row)
            if index < rows.count - 1 {
                let wrap = UIView()
                let line = UIView()
                line.backgroundColor = AppColor.border
                wrap.addSubview(line)
                line.snp.makeConstraints { make in
                    make.leading.equalToSuperview().offset(AppSpace.lg)
                    make.trailing.equalToSuperview()
                    make.top.bottom.equalToSuperview()
                    make.height.equalTo(1 / UIScreen.main.scale)
                }
                stack.addArrangedSubview(wrap)
            }
        }
    }
}
