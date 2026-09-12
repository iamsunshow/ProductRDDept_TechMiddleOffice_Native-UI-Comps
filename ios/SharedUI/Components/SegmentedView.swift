/// Segmented 分段选择器组件（UIKit 版，对齐 Android Segmented）。
///
/// 胶囊式分段控件：等分选项横向排列，选中项填充背景色，圆角轨道。
/// 泛化自 PeriodTabsView：支持任意选项数 / 禁用项 / 自定义宽度 / fillMaxWidth。

import UIKit
import SnapKit

/// 分段选择器项。
struct SegmentedItem {
    let label: String
    var enabled: Bool = true
}

/// 分段选择器。
final class SegmentedView: UIView {
    // MARK: - 配置

    var options: [SegmentedItem] = [] { didSet { rebuild() } }
    var selectedIndex: Int = 0 { didSet { applySelection() } }
    var onSelect: ((Int) -> Void)?
    /// 固定宽度（nil 时撑满父容器）。
    var trackWidth: CGFloat? = 200 { didSet { updateWidthConstraint() } }

    // MARK: - 子视图

    private let track = UIStackView()
    private var buttons: [UIButton] = []
    private var widthConstraint: Constraint?

    // MARK: - 固有尺寸

    override var intrinsicContentSize: CGSize {
        let w = trackWidth ?? (UIScreen.main.bounds.width - AppSpace.lg * 2)
        return CGSize(width: w, height: 32 + AppSpace.sm * 2)
    }

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)

        setContentHuggingPriority(.required, for: .horizontal)

        track.axis = .horizontal
        track.spacing = 0
        track.distribution = .fillEqually
        track.layer.cornerRadius = AppRadius.md
        track.clipsToBounds = true
        track.backgroundColor = AppColor.bgPage

        addSubview(track)
        track.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.bottom.equalToSuperview().inset(AppSpace.sm)
            widthConstraint = make.width.equalTo(200).constraint
            make.height.equalTo(32)
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("SegmentedView does not support NSCoder") }

    // MARK: - 宽度更新

    private func updateWidthConstraint() {
        if let w = trackWidth {
            widthConstraint?.update(offset: w)
        } else {
            widthConstraint?.update(offset: UIScreen.main.bounds.width - AppSpace.lg * 2)
        }
        invalidateIntrinsicContentSize()
    }

    // MARK: - 重建

    private func rebuild() {
        buttons.forEach { $0.removeFromSuperview() }
        buttons.removeAll()

        for (index, item) in options.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(item.label, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: AppFont.sizeSm, weight: .semibold)
            button.titleLabel?.lineBreakMode = .byTruncatingTail
            button.tag = index
            button.isEnabled = item.enabled
            button.addTarget(self, action: #selector(tapped(_:)), for: .touchUpInside)
            buttons.append(button)
            track.addArrangedSubview(button)
        }
        applySelection()
    }

    // MARK: - 选中态

    private func applySelection() {
        for (index, button) in buttons.enumerated() {
            let selected = index == selectedIndex
            button.backgroundColor = selected ? AppColor.textPrimary : .clear
            button.setTitleColor(selected ? .white : (button.isEnabled ? AppColor.textSecondary : AppColor.textSecondary.withAlphaComponent(0.4)), for: .normal)
            // 圆角：仅首末项外侧带圆角。
            button.layer.cornerRadius = 0
            button.layer.maskedCorners = []
            if selected {
                let r: CGFloat = AppRadius.md
                switch (index, options.count) {
                case (0, _):
                    button.layer.cornerRadius = r
                    button.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
                case let (i, c) where i == c - 1:
                    button.layer.cornerRadius = r
                    button.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
                default:
                    button.layer.cornerRadius = 0
                    button.layer.maskedCorners = []
                }
                button.layer.masksToBounds = true
            }
        }
    }

    // MARK: - 点击

    @objc private func tapped(_ sender: UIButton) {
        let idx = sender.tag
        guard idx != selectedIndex, options[idx].enabled else { return }
        selectedIndex = idx
        applySelection()
        onSelect?(idx)
    }
}
