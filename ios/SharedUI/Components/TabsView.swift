/// Tabs 选项卡（ui.tabs，#20）。
///
/// 页内顶部页签条：等分（2-5 项，文字 Sm 14pt 单行省略），半受控选中
/// （默认首启用项自管理 + 外部 selectedValue 驱动高亮 + 点击幂等），
/// 激活项底部 2pt 指示线（宽=当前项整宽，激活色覆盖默认主色）+ 禁用（40%）。
/// 条高默认 44pt（宿主可覆盖）；内容面板由宿主渲染，指示线即分界，不另加 hairline。
/// 对应 Android：Tabs(items, selectedValue?, activeColor?, onChange, modifier)。
/// 版本：Native-UI-Comps ui-version v1.4.0（本文件替换旧收编业务双 Tab，随 demo 徽标 v1.0）。
import UIKit
import SnapKit

/// 页签数据项（与 Android `TabItem` 同构）。
struct TabItem {
    let title: String
    let value: String
    let disabled: Bool

    init(title: String, value: String, disabled: Bool = false) {
        self.title = title
        self.value = value
        self.disabled = disabled
    }
}

/// 页签条。
final class TabsView: UIView {
    struct Metrics {
        static let barHeight: CGFloat = 44
        static let labelFontSize = AppFont.sizeSm // 14pt
        static let itemSideInset = AppSpace.xs
        static let indicatorHeight: CGFloat = 2
        // 指示线宽度 = 当前项整宽（等分格宽），激活项底部 2pt 激活色
    }

    /// 数据项（改后整体重建）。
    var items: [TabItem] {
        didSet { rebuildCells() }
    }

    /// 受控选中值；nil = 组件自管理。
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
    private var cells: [(control: UIControl, titleLabel: UILabel, indicator: UIView)] = []
    private var internalValue: String?
    private let onChange: ((String) -> Void)?
    private let enabledActiveColor: UIColor

    init(items: [TabItem], selectedValue: String? = nil, activeColor: UIColor? = nil, onChange: ((String) -> Void)? = nil) {
        self.items = items
        self.selectedValue = selectedValue
        self.onChange = onChange
        self.enabledActiveColor = activeColor ?? AppColor.primary
        super.init(frame: .zero)

        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .fill
        stack.spacing = 0
        addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        rebuildCells()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: Metrics.barHeight)
    }

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
            control.accessibilityIdentifier = "tabs-\(item.value)"
            control.addTarget(self, action: #selector(didPressDown(_:)), for: .touchDown)
            control.addTarget(self, action: #selector(didTapCell(_:)), for: .touchUpInside)
            control.addTarget(self, action: #selector(didPressUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel, .touchDragExit])
            stack.addArrangedSubview(control)

            let titleLabel = UILabel()
            titleLabel.text = item.title
            titleLabel.font = .systemFont(ofSize: Metrics.labelFontSize)
            titleLabel.textAlignment = .center
            titleLabel.lineBreakMode = .byTruncatingTail
            titleLabel.numberOfLines = 1
            titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            control.addSubview(titleLabel)
            titleLabel.snp.makeConstraints { make in
                make.centerX.centerY.equalToSuperview()
                make.leading.greaterThanOrEqualToSuperview().offset(Metrics.itemSideInset)
                make.trailing.lessThanOrEqualToSuperview().offset(-Metrics.itemSideInset)
            }

            // 底部指示线：整项宽，激活时激活色
            let indicator = UIView()
            control.addSubview(indicator)
            indicator.snp.makeConstraints { make in
                make.leading.trailing.bottom.equalToSuperview()
                make.height.equalTo(Metrics.indicatorHeight)
            }

            cells.append((control, titleLabel, indicator))
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
        guard let idx = cells.firstIndex(where: { $0.control === sender }) else { return }
        let item = items[idx]
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
            cell.titleLabel.font = .systemFont(ofSize: Metrics.labelFontSize, weight: active ? .semibold : .regular)
            cell.indicator.backgroundColor = active ? color : .clear
            cell.control.alpha = item.disabled ? 0.4 : 1
        }
    }
}
