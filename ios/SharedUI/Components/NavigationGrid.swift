/// 导航入口网格：卡片壳 + 分区标题 + NavBar 图标网格。

import UIKit
import SnapKit

/// 通用导航入口网格卡片（NavBar 的卡片容器封装）。
final class NavigationGrid: UIView {
    /// 单个入口。
    struct Item {
        let title: String
        let symbolName: String
    }

    var onSelect: ((Int) -> Void)?

    private let titleLabel = UILabel()
    private let navBar = NavBar()

    /// 搭建卡片壳。
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        layer.cornerRadius = AppRadius.lg
        layer.borderWidth = 1 / UIScreen.main.scale
        layer.borderColor = AppColor.border.cgColor

        titleLabel.font = .systemFont(ofSize: AppFont.sizeMd, weight: .semibold)
        titleLabel.textColor = AppColor.textPrimary

        addSubview(titleLabel)
        addSubview(navBar)
        titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(AppSpace.lg)
        }
        navBar.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(AppSpace.md)
            make.leading.trailing.bottom.equalToSuperview().inset(AppSpace.lg)
            make.height.equalTo(72)
        }

        navBar.onSelect = { [weak self] index in
            self?.onSelect?(index)
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    /// 绑定分区标题与入口。
    ///
    /// - Parameters:
    ///   - title: 分区标题
    ///   - items: 入口列表（建议 4 个）
    func apply(title: String, items: [Item]) {
        titleLabel.text = title
        navBar.apply(items: items.map { NavBar.Item(title: $0.title, symbolName: $0.symbolName) })
    }
}
