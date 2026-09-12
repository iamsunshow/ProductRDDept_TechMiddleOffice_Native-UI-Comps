import UIKit

// MARK: - DropDownOption

/// DropDown 选项数据模型
public struct DropDownOption: Equatable {
    public let value: String
    public let text: String
    public init(value: String, text: String) {
        self.value = value
        self.text = text
    }
}

// MARK: - DropDownView

/// DropDown 下拉菜单（导航组件 · ui.dropdown）：单列下拉选择器。
///
/// 视觉：触发按钮高 44 灰底圆角，右侧 chevron 指示；点击展开浮层面板（UITableView），
/// 选中项 primary 高亮 + ✓；点选项即收起。
/// 语义：value 受控选中值；onChange 选中回调；disabled 整体 40% 灰不可点。
public class DropDownView: UIView, UITableViewDelegate, UITableViewDataSource {

    public enum Metrics {
        public static let triggerHeight: CGFloat = 44
        public static let panelRowHeight: CGFloat = 44
        public static let panelMaxHeight: CGFloat = 264 // 6 行
    }

    public var title: String { didSet { titleLabel.text = title } }
    public var options: [DropDownOption] { didSet { tableView?.reloadData() } }

    public var value: String {
        get { valueStorage }
        set { valueStorage = newValue; syncDisplay() }
    }

    public var onChange: ((String) -> Void)?

    public var disabled: Bool {
        get { disabledStorage }
        set { disabledStorage = newValue; applyDisabled() }
    }

    private var valueStorage = ""
    private var disabledStorage = false
    private var isExpanded = false

    private let triggerButton = UIButton(type: .custom)
    private let titleLabel = UILabel()
    private let valueLabel = UILabel()
    private let chevronLabel = UILabel()
    private var panelView: UIView?
    private var tableView: UITableView?

    public init(
        title: String = "请选择",
        options: [DropDownOption],
        value: String = "",
        disabled: Bool = false,
        onChange: ((String) -> Void)? = nil
    ) {
        self.title = title
        self.options = options
        self.valueStorage = value
        self.disabledStorage = disabled
        self.onChange = onChange
        super.init(frame: .zero)
        buildUI()
        syncDisplay()
        applyDisabled()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) { fatalError() }

    public override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: Metrics.triggerHeight)
    }

    private func buildUI() {
        backgroundColor = .clear

        triggerButton.backgroundColor = AppColor.bgPage
        triggerButton.layer.cornerRadius = AppRadius.md
        triggerButton.addTarget(self, action: #selector(triggerTapped), for: .touchUpInside)
        addSubview(triggerButton)
        triggerButton.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.font = .systemFont(ofSize: AppFont.sizeSm)
        titleLabel.textColor = AppColor.textSecondary
        titleLabel.text = title
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        valueLabel.font = .systemFont(ofSize: AppFont.sizeMd)
        valueLabel.textColor = AppColor.textPrimary
        valueLabel.textAlignment = .right
        valueLabel.lineBreakMode = .byTruncatingTail
        addSubview(valueLabel)
        valueLabel.translatesAutoresizingMaskIntoConstraints = false

        chevronLabel.font = .systemFont(ofSize: 12)
        chevronLabel.textColor = AppColor.textSecondary.withAlphaComponent(0.5)
        chevronLabel.text = "▼"
        chevronLabel.textAlignment = .center
        addSubview(chevronLabel)
        chevronLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            triggerButton.topAnchor.constraint(equalTo: topAnchor),
            triggerButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            triggerButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            triggerButton.bottomAnchor.constraint(equalTo: bottomAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: AppSpace.md),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 80),

            chevronLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -AppSpace.md),
            chevronLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            chevronLabel.widthAnchor.constraint(equalToConstant: 16),

            valueLabel.trailingAnchor.constraint(equalTo: chevronLabel.leadingAnchor, constant: -AppSpace.xs),
            valueLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            valueLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: AppSpace.xs),
        ])
    }

    @objc private func triggerTapped() {
        guard !disabledStorage else { return }
        isExpanded ? closePanel() : openPanel()
    }

    func openPanel(anchor: UIView? = nil) {
        isExpanded = true
        chevronLabel.text = "▲"
        let panel = UIView()
        panel.backgroundColor = AppColor.bgCard
        panel.layer.cornerRadius = AppRadius.md
        panel.layer.shadowColor = UIColor.black.cgColor
        panel.layer.shadowOpacity = 0.12
        panel.layer.shadowRadius = 8
        panel.layer.shadowOffset = CGSize(width: 0, height: 4)
        panel.clipsToBounds = true

        let rows = min(options.count, 6)
        let height = CGFloat(rows) * Metrics.panelRowHeight

        let tv = UITableView(frame: .zero, style: .plain)
        tv.dataSource = self
        tv.delegate = self
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tv.rowHeight = Metrics.panelRowHeight
        tv.separatorInset = UIEdgeInsets(top: 0, left: AppSpace.md, bottom: 0, right: AppSpace.md)
        tv.isScrollEnabled = options.count > 6
        panel.addSubview(tv)
        tv.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tv.topAnchor.constraint(equalTo: panel.topAnchor),
            tv.leadingAnchor.constraint(equalTo: panel.leadingAnchor),
            tv.trailingAnchor.constraint(equalTo: panel.trailingAnchor),
            tv.bottomAnchor.constraint(equalTo: panel.bottomAnchor),
        ])

        let anchorView = anchor ?? triggerButton
        let hostView: UIView
        if let window = anchorView.window {
            hostView = window
        } else {
            hostView = self
        }
        hostView.addSubview(panel)
        panel.translatesAutoresizingMaskIntoConstraints = false
        let anchorFrame = anchorView.convert(anchorView.bounds, to: hostView)
        NSLayoutConstraint.activate([
            panel.topAnchor.constraint(equalTo: hostView.topAnchor, constant: anchorFrame.maxY + 4),
            panel.leadingAnchor.constraint(equalTo: hostView.leadingAnchor, constant: anchorFrame.minX),
            panel.widthAnchor.constraint(equalToConstant: anchorFrame.width),
            panel.heightAnchor.constraint(equalToConstant: height),
        ])
        panelView = panel
        tableView = tv
    }

    public func closePanel() {
        isExpanded = false
        chevronLabel.text = "▼"
        panelView?.removeFromSuperview()
        panelView = nil
        tableView = nil
    }

    private func syncDisplay() {
        if let opt = options.first(where: { $0.value == valueStorage }) {
            valueLabel.text = opt.text
        } else {
            valueLabel.text = title
            valueLabel.textColor = AppColor.textSecondary.withAlphaComponent(0.5)
        }
    }

    private func applyDisabled() {
        alpha = disabledStorage ? 0.4 : 1.0
        triggerButton.isEnabled = !disabledStorage
    }

    // MARK: - UITableView

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        options.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        guard indexPath.row < options.count else { return cell }
        let opt = options[indexPath.row]
        cell.textLabel?.text = opt.text
        cell.textLabel?.font = .systemFont(ofSize: AppFont.sizeMd)
        let selected = (opt.value == valueStorage)
        cell.textLabel?.textColor = selected ? AppColor.primary : AppColor.textPrimary
        cell.accessoryType = selected ? .checkmark : .none
        cell.tintColor = AppColor.primary
        cell.backgroundColor = .clear
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < options.count else { return }
        let opt = options[indexPath.row]
        valueStorage = opt.value
        onChange?(opt.value)
        syncDisplay()
        closePanel()
        tableView.deselectRow(at: indexPath, animated: false)
    }
}

// MARK: - DropDownMenuItem

/// DropDownMenu 菜单项数据模型
public struct DropDownMenuItem {
    public let title: String
    public let options: [DropDownOption]
    public var value: String

    public init(title: String, options: [DropDownOption], value: String = "") {
        self.title = title
        self.options = options
        self.value = value
    }
}

// MARK: - DropDownMenuView

/// DropDownMenu 下拉菜单容器（导航组件 · ui.dropdown-menu）：管理多个下拉列。
///
/// 视觉：水平按钮栏（等分）+ 展开浮层面板；同时只展开一列，切换时自动关闭前一列。
/// 语义：items 数据源；onChange(index, value) 选中回调。
public class DropDownMenuView: UIView {

    public var items: [DropDownMenuItem] { didSet { rebuild() } }
    public var onChange: ((Int, String) -> Void)?

    private var buttons: [UIButton] = []
    private var dropDowns: [DropDownView] = []
    private let barStack = UIStackView()
    private var currentIndex = -1

    public init(items: [DropDownMenuItem], onChange: ((Int, String) -> Void)? = nil) {
        self.items = items
        self.onChange = onChange
        super.init(frame: .zero)
        buildUI()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) { fatalError() }

    public override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: DropDownView.Metrics.triggerHeight)
    }

    private func buildUI() {
        backgroundColor = .clear
        barStack.axis = .horizontal
        barStack.distribution = .fillEqually
        barStack.spacing = AppSpace.xs
        addSubview(barStack)
        barStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            barStack.topAnchor.constraint(equalTo: topAnchor),
            barStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            barStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            barStack.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        rebuild()
    }

    private func rebuild() {
        buttons.forEach { $0.removeFromSuperview() }
        buttons.removeAll()
        dropDowns.forEach { $0.removeFromSuperview() }
        dropDowns.removeAll()

        for (i, item) in items.enumerated() {
            let btn = UIButton(type: .system)
            btn.setTitle(item.title + " ▼", for: .normal)
            btn.titleLabel?.font = .systemFont(ofSize: AppFont.sizeMd)
            btn.setTitleColor(AppColor.textPrimary, for: .normal)
            btn.backgroundColor = AppColor.bgPage
            btn.layer.cornerRadius = AppRadius.md
            btn.tag = i
            btn.addTarget(self, action: #selector(columnTapped(_:)), for: .touchUpInside)
            barStack.addArrangedSubview(btn)
            buttons.append(btn)

            let dd = DropDownView(title: item.title, options: item.options, value: item.value)
            dd.isHidden = true
            dd.onChange = { [weak self] value in
                guard let self = self else { return }
                self.items[i].value = value
                self.onChange?(i, value)
                self.closeAll()
            }
            addSubview(dd)
            dd.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                dd.topAnchor.constraint(equalTo: barStack.bottomAnchor, constant: 4),
                dd.leadingAnchor.constraint(equalTo: leadingAnchor),
                dd.trailingAnchor.constraint(equalTo: trailingAnchor),
            ])
            dropDowns.append(dd)
        }
    }

    @objc private func columnTapped(_ sender: UIButton) {
        let idx = sender.tag
        if currentIndex == idx {
            closeAll()
        } else {
            closeAll()
            dropDowns[idx].openPanel(anchor: buttons[idx])
            buttons[idx].setTitle(items[idx].title + " ▲", for: .normal)
            currentIndex = idx
        }
    }

    private func closeAll() {
        for (i, dd) in dropDowns.enumerated() {
            dd.closePanel()
            buttons[i].setTitle(items[i].title + " ▼", for: .normal)
        }
        currentIndex = -1
    }
}
