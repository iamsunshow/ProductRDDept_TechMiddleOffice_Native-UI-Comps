/// 通用 Tab 切换控件。

import UIKit
import SnapKit

/// 通用双 Tab 切换条。
final class TabsView: UIView {
    var onSelect: ((Int) -> Void)?

    private(set) var selectedIndex: Int = 0
    private let titles: [String]
    private var buttons: [UIButton] = []

    /// 搭建 Tab 切换条。
    ///
    /// - Parameters:
    ///   - titles: Tab 标题列表
    ///   - frame: 初始 frame
    init(titles: [String], frame: CGRect = .zero) {
        self.titles = titles
        super.init(frame: frame)
        backgroundColor = .white

        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 0
        stack.distribution = .fillEqually
        stack.layer.cornerRadius = AppRadius.md
        stack.clipsToBounds = true
        stack.backgroundColor = AppColor.bgPage

        for (index, title) in titles.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: AppFont.sizeSm, weight: .semibold)
            button.tag = index
            button.addTarget(self, action: #selector(tapped(_:)), for: .touchUpInside)
            buttons.append(button)
            stack.addArrangedSubview(button)
        }

        addSubview(stack)
        stack.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.bottom.equalToSuperview().inset(AppSpace.sm)
            make.width.equalTo(200)
            make.height.equalTo(32)
        }
        applySelection()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    /// 处理 Tab 点击。
    ///
    /// - Parameter sender: 被点击按钮
    @objc private func tapped(_ sender: UIButton) {
        guard sender.tag != selectedIndex else { return }
        selectedIndex = sender.tag
        applySelection()
        onSelect?(selectedIndex)
    }

    /// 刷新选中样式。
    private func applySelection() {
        for (index, button) in buttons.enumerated() {
            let active = index == selectedIndex
            if active {
                button.backgroundColor = AppColor.textPrimary
                button.setTitleColor(.white, for: .normal)
            } else {
                button.backgroundColor = .clear
                button.setTitleColor(AppColor.textSecondary, for: .normal)
            }
        }
    }
}
