/// 周期 Tab 切换：周 / 月 / 年。

import UIKit
import SnapKit

/// 周 / 月 / 年分段切换（TabsView 的特例）。
final class PeriodTabsView: UIView {
    var onChange: ((ChartsPeriod) -> Void)?

    private(set) var selected: ChartsPeriod = .month
    private var buttons: [ChartsPeriod: UIButton] = [:]

    /// 初始化三段分段控件。
    ///
    /// - Parameter frame: 初始 frame
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white

        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 0
        stack.distribution = .fillEqually
        stack.layer.cornerRadius = AppRadius.md
        stack.clipsToBounds = true
        stack.backgroundColor = AppColor.bgPage

        for period in ChartsPeriod.allCases {
            let button = UIButton(type: .system)
            button.setTitle(period.title, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: AppFont.sizeSm, weight: .semibold)
            button.tag = period.rawValue
            button.addTarget(self, action: #selector(tapped(_:)), for: .touchUpInside)
            buttons[period] = button
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

    /// 处理周期按钮点击。
    ///
    /// - Parameter sender: 被点击按钮
    @objc private func tapped(_ sender: UIButton) {
        guard let period = ChartsPeriod(rawValue: sender.tag), period != selected else { return }
        selected = period
        applySelection()
        onChange?(period)
    }

    /// 刷新选中样式。
    private func applySelection() {
        for (period, button) in buttons {
            let active = period == selected
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
