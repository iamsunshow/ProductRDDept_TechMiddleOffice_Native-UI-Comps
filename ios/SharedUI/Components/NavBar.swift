/// 快捷导航栏：图标 + 文案等分入口。

import UIKit
import SnapKit

/// 通用快捷导航栏（纯图标网格原子）。
final class NavBar: UIView {
    /// 单个导航入口。
    struct Item {
        let title: String
        let symbolName: String
    }

    var onSelect: ((Int) -> Void)?

    private let stack = UIStackView()

    /// 初始化空导航栏。
    override init(frame: CGRect) {
        super.init(frame: frame)

        stack.axis = .horizontal
        stack.distribution = .fillEqually
        // 规范 M1.2（ui-ledger-components 3.1/3.2）：内容区高 64，容器 padding 12/8/12/8，总高 12+64+12=88。
        // 使用 .center 对齐 + 显式高度约束，避免 UIControl 无 intrinsicSize 时 Auto Layout 高度歧义（曾导致导航被撑到页面中部）。
        stack.alignment = .center
        stack.spacing = 0
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    /// 绑定导航入口列表。
    ///
    /// - Parameter items: 入口列表
    func apply(items: [Item]) {
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for (index, item) in items.enumerated() {
            let button = makeItemButton(item, index: index)
            stack.addArrangedSubview(button)
            // 规范 3.2：单项高 64（占满内容区），显式约束保证高度确定
            button.snp.makeConstraints { make in
                make.height.equalTo(64)
            }
        }
    }

    /// 创建单个导航项按钮。
    private func makeItemButton(_ item: Item, index: Int) -> UIControl {
        let control = UIControl()
        control.tag = index
        control.addTarget(self, action: #selector(itemTapped(_:)), for: .touchUpInside)

        let icon = UIImageView(image: UIImage(systemName: item.symbolName))
        icon.tintColor = AppColor.primary
        icon.contentMode = .scaleAspectFit

        let label = UILabel()
        label.text = item.title
        label.font = .systemFont(ofSize: AppFont.sizeXs)
        label.textColor = AppColor.textPrimary
        label.textAlignment = .center

        let col = UIStackView(arrangedSubviews: [icon, label])
        col.axis = .vertical
        col.spacing = AppSpace.xs
        col.alignment = .center
        col.isUserInteractionEnabled = false

        control.addSubview(col)
        icon.snp.makeConstraints { make in
            make.width.height.equalTo(24)
        }
        col.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview()
            make.trailing.lessThanOrEqualToSuperview()
            make.top.greaterThanOrEqualToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
        }
        return control
    }

    @objc private func itemTapped(_ sender: UIControl) {
        onSelect?(sender.tag)
    }
}
