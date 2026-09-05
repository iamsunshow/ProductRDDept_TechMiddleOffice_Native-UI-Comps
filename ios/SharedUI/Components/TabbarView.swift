/// Tabbar 标签栏（ui.tabbar，#19）。
///
/// 页面底部一级主导航标签条：2-5 项等分（icon 字符 22pt + 文字 12pt），
/// 半受控选中（默认首启用项自管理 + 外部 selectedValue 驱动高亮 + 点击幂等），
/// 角标数字（高 16 圆角全主色白字 12pt，位于图标右上）+ 禁用（40%）+ 单行省略，
/// activeColor 可覆盖（默认主色），栏顶 hairline，栏高默认 56pt（宿主可覆盖）。
/// 对应 Android：Tabbar(items, selectedValue?, activeColor?, onChange, modifier)。
/// 版本：Native-UI-Comps ui-version v1.4.0（本文件为新组件初版，随 demo 徽标 v1.0）。
import UIKit
import SnapKit

/// 标签栏数据项（与 Android `TabBarItem` 同构）。
struct TabBarItem {
    let title: String
    let value: String
    let icon: String?
    let badge: Int?
    let disabled: Bool

    init(title: String, value: String, icon: String? = nil, badge: Int? = nil, disabled: Bool = false) {
        self.title = title
        self.value = value
        self.icon = icon
        self.badge = badge
        self.disabled = disabled
    }
}

/// 标签栏。
final class TabbarView: UIView {
    struct Metrics {
        static let barHeight: CGFloat = 56
        static let iconFontSize = AppFont.sizeXl // 22pt
        static let titleFontSize = AppFont.sizeXs // 12pt
        static let iconTitleGap = AppSpace.xs // 4pt
        static let itemSideInset = AppSpace.xs

        static let badgeHeight: CGFloat = 16
        static let badgeMinWidth: CGFloat = 16
        static let badgeFontSize = AppFont.sizeXs
        static let badgeHorizPadding: CGFloat = 3
        static let badgeCorner: CGFloat = badgeHeight / 2
        // 角标锚点：cell 水平中心 +14 / 顶 2（对齐 spec preview：left=50%+6、min-width 16 → 中心=50%+14）
        static let badgeCenterXOffset: CGFloat = 14
        static let badgeTop: CGFloat = 2
    }

    /// 数据项（改后整体重建）。
    var items: [TabBarItem] {
        didSet { rebuildCells() }
    }

    /// 受控选中值；nil = 组件自管理（点选后高亮跟随内部值）。
    var selectedValue: String? {
        didSet {
            guard selectedValue != oldValue else { return }
            refreshActive()
        }
    }

    /// 激活色覆盖（默认主色）。
    var activeColor: UIColor? {
        didSet { refreshActive() }
    }

    private let stack = UIStackView()
    private let hairline = UIView()
    private var cells: [(control: UIControl, iconLabel: UILabel?, titleLabel: UILabel, badgePill: UIView?)] = []
    private var internalValue: String?
    private let onChange: ((String) -> Void)?
    private let enabledActiveColor: UIColor

    init(items: [TabBarItem], selectedValue: String? = nil, activeColor: UIColor? = nil, onChange: ((String) -> Void)? = nil) {
        self.items = items
        self.selectedValue = selectedValue
        self.onChange = onChange
        self.enabledActiveColor = activeColor ?? AppColor.primary
        super.init(frame: .zero)
        backgroundColor = AppColor.bgCard

        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .fill
        stack.spacing = 0
        addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        hairline.backgroundColor = AppColor.border
        addSubview(hairline)
        hairline.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(1 / UIScreen.main.scale)
        }

        rebuildCells()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: Metrics.barHeight)
    }

    /// 有效选中：外部受控优先，否则内部自管理。
    private var effectiveValue: String? {
        selectedValue ?? internalValue
    }

    private func rebuildCells() {
        if let v = internalValue, !items.contains(where: { $0.value == v && !$0.disabled }) {
            internalValue = items.first(where: { !$0.disabled })?.value
        }
        if selectedValue == nil, internalValue == nil {
            internalValue = items.first(where: { !$0.disabled })?.value
        }
        for cell in cells {
            cell.control.removeFromSuperview()
        }
        cells.removeAll()

        for item in items {
            let control = UIControl()
            control.isEnabled = !item.disabled
            control.accessibilityIdentifier = "tabbar-\(item.value)"
            control.addTarget(self, action: #selector(didPressDown(_:)), for: .touchDown)
            control.addTarget(self, action: #selector(didTapCell(_:)), for: .touchUpInside)
            control.addTarget(self, action: #selector(didPressUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel, .touchDragExit])
            stack.addArrangedSubview(control)

            // 内容：icon（可选）+ 标题，垂直居中
            let contentStack = UIStackView()
            contentStack.axis = .vertical
            contentStack.alignment = .center
            contentStack.spacing = item.icon == nil ? 0 : Metrics.iconTitleGap
            contentStack.isUserInteractionEnabled = false
            control.addSubview(contentStack)

            var iconLabel: UILabel?
            if let icon = item.icon, !icon.isEmpty {
                let label = UILabel()
                label.text = icon
                label.font = .systemFont(ofSize: Metrics.iconFontSize)
                label.textAlignment = .center
                label.numberOfLines = 1
                contentStack.addArrangedSubview(label)
                iconLabel = label
            }

            let titleLabel = UILabel()
            titleLabel.text = item.title
            titleLabel.font = .systemFont(ofSize: Metrics.titleFontSize)
            titleLabel.textAlignment = .center
            titleLabel.lineBreakMode = .byTruncatingTail
            titleLabel.numberOfLines = 1
            titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            contentStack.addArrangedSubview(titleLabel)

            contentStack.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.centerY.equalToSuperview()
                make.leading.greaterThanOrEqualToSuperview().offset(Metrics.itemSideInset)
                make.trailing.lessThanOrEqualToSuperview().offset(-Metrics.itemSideInset)
            }

            // 角标（可选）：cell 水平中心 +14 / 顶 2，高 16 圆角全主色白字
            var badgePill: UIView?
            if let badge = item.badge, badge > 0 {
                let pill = UIView()
                pill.backgroundColor = AppColor.primary
                pill.layer.cornerRadius = Metrics.badgeCorner
                pill.clipsToBounds = true
                control.addSubview(pill)

                let label = UILabel()
                label.text = "\(badge)"
                label.font = .systemFont(ofSize: Metrics.badgeFontSize)
                label.textColor = .white
                label.textAlignment = .center
                pill.addSubview(label)
                label.snp.makeConstraints { make in
                    make.centerX.centerY.equalToSuperview()
                    make.leading.greaterThanOrEqualToSuperview().offset(Metrics.badgeHorizPadding)
                    make.trailing.lessThanOrEqualToSuperview().offset(-Metrics.badgeHorizPadding)
                }

                pill.snp.makeConstraints { make in
                    make.centerX.equalTo(control.snp.centerX).offset(Metrics.badgeCenterXOffset)
                    make.top.equalTo(control).offset(Metrics.badgeTop)
                    make.height.equalTo(Metrics.badgeHeight)
                    make.width.greaterThanOrEqualTo(Metrics.badgeMinWidth)
                }
                badgePill = pill
            }

            cells.append((control, iconLabel, titleLabel, badgePill))
        }
        refreshActive()
    }

    @objc private func didPressDown(_ sender: UIControl) {
        guard sender.isEnabled else { return }
        UIView.animate(withDuration: 0.1) { sender.alpha = 0.7 }
    }

    @objc private func didPressUp(_ sender: UIControl) {
        guard sender.isEnabled else { return }
        UIView.animate(withDuration: 0.1) { sender.alpha = 1 }
    }

    @objc private func didTapCell(_ sender: UIControl) {
        guard let cell = cells.first(where: { $0.control === sender }) else { return }
        let item = items[cells.firstIndex(where: { $0.control === sender }) ?? 0]
        guard !item.disabled else { return }
        guard item.value != effectiveValue else { return }
        if selectedValue == nil {
            internalValue = item.value
        }
        refreshActive()
        onChange?(item.value)
    }

    private func refreshActive() {
        let effective = effectiveValue
        let color = enabledActiveColor
        for cell in cells {
            let index = cells.firstIndex(where: { $0.control === cell.control }) ?? 0
            guard index < items.count else { continue }
            let item = items[index]
            let active = !item.disabled && item.value == effective
            cell.titleLabel.textColor = active ? color : AppColor.textSecondary
            cell.titleLabel.font = .systemFont(ofSize: Metrics.titleFontSize, weight: active ? .semibold : .regular)
            cell.iconLabel?.textColor = active ? color : AppColor.textSecondary
            // 禁用：整项透明度 40%（含图标/文字/角标）
            cell.control.alpha = item.disabled ? 0.4 : 1
        }
    }

    /// 供 Demo 受控场景复用的点击入口（等价于点击某个 value）。
    func select(value: String) {
        guard let item = items.first(where: { $0.value == value }), !item.disabled else { return }
        if selectedValue == nil {
            internalValue = item.value
        }
        refreshActive()
        onChange?(item.value)
    }
}
