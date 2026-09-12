import UIKit

// MARK: - 滚动关闭弹层通知（DropDown 弹层在页面滚动时自动消失，与 Android 同步）

extension Notification.Name {
    /// Demo 页面 scrollView 开始滚动时广播此通知，DropDown 弹层监听后自动 closePanel
    static let scrollViewDidScrollNotification = Notification.Name("scrollViewDidScrollNotification")
}

// MARK: - ChevronView（自绘等边三角形，双端统一 8pt 尺寸）

/// 自绘等边三角形箭头视图，替代 Unicode ▼ 字符和 Material ArrowDropDown 图标。
/// 固定 8×8pt 等边三角形，向下=收起、向上=展开，颜色可配置。
/// 与 Android DropDown/DropDownMenu 的 Icons.Default.ArrowDropDown + size(8.dp) 像素级对齐。
class ChevronView: UIView {
    var color: UIColor = .gray {
        didSet { setNeedsDisplay() }
    }
    var isUp: Bool = false {
        didSet { setNeedsDisplay() }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isUserInteractionEnabled = false
    }
    required init?(coder: NSCoder) { fatalError() }
    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        ctx.setFillColor(color.cgColor)
        let w = rect.width
        let h = rect.height
        let path = UIBezierPath()
        if isUp {
            // 向上三角：顶点在上方中心
            path.move(to: CGPoint(x: w / 2, y: 0))
            path.addLine(to: CGPoint(x: 0, y: h))
            path.addLine(to: CGPoint(x: w, y: h))
        } else {
            // 向下三角：顶点在下方中心
            path.move(to: CGPoint(x: w / 2, y: h))
            path.addLine(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: w, y: 0))
        }
        path.close()
        color.setFill()
        path.fill()
    }
}

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
    private let chevronView = ChevronView()
    private var panelView: UIView?
    private var tableView: UITableView?
    private var outsideTapRecognizer: UITapGestureRecognizer?
    private var outsideTapHost: UIView?

    /// 面板宽度模式：contentAdaptive=内容自适应（单列，对齐 Android）；matchAnchor=锚点宽（多列列宽）
    enum PanelWidthMode { case contentAdaptive, matchAnchor }

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
        // 横向 hugging 提至必需：防止标题与值标签等宽竞争时标题被拉伸、值文字停在标题旁
        // （用户 2026-09-12 反馈 D4「iOS 顺序排列」，Android 值恒居 chevron 左侧）
        titleLabel.setContentHuggingPriority(.required, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        valueLabel.font = .systemFont(ofSize: AppFont.sizeMd)
        valueLabel.textColor = AppColor.textPrimary
        valueLabel.textAlignment = .right
        valueLabel.lineBreakMode = .byTruncatingTail
        addSubview(valueLabel)
        valueLabel.translatesAutoresizingMaskIntoConstraints = false

        chevronView.color = AppColor.textSecondary.withAlphaComponent(0.5)
        addSubview(chevronView)
        chevronView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            triggerButton.topAnchor.constraint(equalTo: topAnchor),
            triggerButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            triggerButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            triggerButton.bottomAnchor.constraint(equalTo: bottomAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: AppSpace.md),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 80),

            chevronView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -AppSpace.md),
            chevronView.centerYAnchor.constraint(equalTo: centerYAnchor),
            chevronView.widthAnchor.constraint(equalToConstant: 8),
            chevronView.heightAnchor.constraint(equalToConstant: 8),

            // 值标签 leading 改「≥标题尾部」：标签被右侧 chevron 拉满，文字右对齐恒居箭头左侧（对齐 Android）
            valueLabel.trailingAnchor.constraint(equalTo: chevronView.leadingAnchor, constant: -4),
            valueLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            valueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: AppSpace.xs),
        ])
    }

    @objc private func triggerTapped() {
        guard !disabledStorage else { return }
        isExpanded ? closePanel() : openPanel()
    }

    func openPanel(anchor: UIView? = nil, widthMode: PanelWidthMode = .contentAdaptive) {
        isExpanded = true
        chevronView.isUp = true
        // 监听页面滚动——滚动时自动关闭弹层（与 Android 行为同步）
        NotificationCenter.default.addObserver(self, selector: #selector(closeOnScroll), name: .scrollViewDidScrollNotification, object: nil)
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
        // 双端统一：无选项分隔横线（Android DropdownMenu 无横线，用户 2026-09-12 反馈）
        tv.separatorStyle = .none
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
        // 防错位：面板只挂 window（旧实现 window 为 nil 时挂 self=44pt 触发行内部，面板会错位「跑到
        // 页面前面」，用户 2026-09-12 反馈 Demo1）；未上屏时不弹。
        guard let hostView = anchorView.window else { return }
        hostView.addSubview(panel)
        hostView.bringSubviewToFront(panel)
        panel.translatesAutoresizingMaskIntoConstraints = false
        let anchorFrame: CGRect
        if let anchor = anchor {
            // 多列（D2）：锚点=列按钮
            anchorFrame = anchor.convert(anchor.bounds, to: hostView)
        } else {
            // 单列（D1/D3/D4）：锚点=右侧「选中值文字+箭头」区域，面板从选中值文字下方弹出
            // （对齐 Android DropdownMenu 挂在右侧 Box；旧锚点=整行，面板出现在左侧标题下方）
            let btnFrame = triggerButton.convert(triggerButton.bounds, to: hostView)
            let shown = valueLabel.text ?? title
            let textWidth = (shown as NSString).size(withAttributes: [.font: UIFont.systemFont(ofSize: AppFont.sizeMd)]).width
            let rightInset = AppSpace.md + 8 + 4
            anchorFrame = CGRect(
                x: btnFrame.maxX - rightInset - textWidth,
                y: btnFrame.minY,
                width: textWidth + rightInset,
                height: btnFrame.height
            )
        }
        // 面板宽度模式：单列（D1/D3/D4）= 内容自适应（对齐 Android DropdownMenu）；多列（D2）= 列按钮宽
        // （matchAnchor，对齐 Android 列宽面板；v1.7.7 误将 D2 也收窄致文字截断）。
        let textFont = UIFont.systemFont(ofSize: AppFont.sizeMd)
        let maxOptionWidth = options.map { ($0.text as NSString).size(withAttributes: [.font: textFont]).width }.max() ?? 0
        let panelWidth: CGFloat
        if widthMode == .matchAnchor {
            panelWidth = anchorFrame.width
        } else {
            panelWidth = maxOptionWidth + AppSpace.md * 2 + 15
        }
        // 水平位置：左缘对齐锚点；右缘超出屏幕时左移收进安全边距
        var panelLeading = anchorFrame.minX
        let maxLeading = hostView.bounds.width - AppSpace.md - panelWidth
        if panelLeading > maxLeading { panelLeading = max(AppSpace.md, maxLeading) }
        NSLayoutConstraint.activate([
            panel.topAnchor.constraint(equalTo: hostView.topAnchor, constant: anchorFrame.maxY + 4),
            panel.leadingAnchor.constraint(equalTo: hostView.leadingAnchor, constant: panelLeading),
            panel.widthAnchor.constraint(equalToConstant: panelWidth),
            panel.heightAnchor.constraint(equalToConstant: height),
        ])
        panelView = panel
        tableView = tv

        // 点击面板外空白区域自动关闭（对齐 Android DropdownMenu；异步添加避免吞掉本次触发点击）
        let tap = UITapGestureRecognizer(target: self, action: #selector(outsideTapped(_:)))
        tap.cancelsTouchesInView = false
        tap.delegate = self
        DispatchQueue.main.async { [weak self] in
            guard let self = self, self.panelView === panel else { return }
            hostView.addGestureRecognizer(tap)
        }
        outsideTapRecognizer = tap
        outsideTapHost = hostView
    }

    @objc private func outsideTapped(_ tap: UITapGestureRecognizer) {
        guard let panel = panelView else { return }
        let loc = tap.location(in: panel)
        if !panel.point(inside: loc, with: nil) {
            closePanel()
        }
    }

    public func closePanel() {
        isExpanded = false
        chevronView.isUp = false
        NotificationCenter.default.removeObserver(self, name: .scrollViewDidScrollNotification, object: nil)
        if let tap = outsideTapRecognizer {
            outsideTapHost?.removeGestureRecognizer(tap)
        }
        outsideTapRecognizer = nil
        outsideTapHost = nil
        panelView?.removeFromSuperview()
        panelView = nil
        tableView = nil
    }

    @objc private func closeOnScroll() {
        closePanel()
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
        cell.selectionStyle = .none
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
            btn.setTitle(item.title, for: .normal)
            btn.titleLabel?.font = .systemFont(ofSize: AppFont.sizeMd)
            btn.setTitleColor(AppColor.textPrimary, for: .normal)
            // 双端统一 D2 列按钮底色=黑 4% 叠加（bgPage=F9FAFB 过浅，白卡上肉眼不可见=用户反馈「纯白」；台账 #63）
            btn.backgroundColor = UIColor.black.withAlphaComponent(0.04)
            btn.layer.cornerRadius = AppRadius.md
            btn.tag = i
            btn.addTarget(self, action: #selector(columnTapped(_:)), for: .touchUpInside)
            // 用自定义 chevronView 替代 Unicode ▼ 字符三角，与 DropDownView Demo1 统一尺寸 8pt
            let chevron = ChevronView()
            chevron.color = AppColor.textSecondary.withAlphaComponent(0.5)
            chevron.tag = 999
            btn.addSubview(chevron)
            chevron.translatesAutoresizingMaskIntoConstraints = false
            // 文字与箭头固定 4pt 间距：箭头紧跟 title 右缘（旧钉在按钮 trailing，间隙随列宽/文字长变化，
            // 用户 2026-09-12 反馈「时大时小」）
            NSLayoutConstraint.activate([
                chevron.leadingAnchor.constraint(equalTo: btn.titleLabel!.trailingAnchor, constant: 4),
                chevron.centerYAnchor.constraint(equalTo: btn.centerYAnchor),
                chevron.widthAnchor.constraint(equalToConstant: 8),
                chevron.heightAnchor.constraint(equalToConstant: 8),
            ])
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
            dropDowns[idx].openPanel(anchor: buttons[idx], widthMode: .matchAnchor)
            if let chevron = buttons[idx].viewWithTag(999) as? ChevronView {
                chevron.isUp = true
            }
            currentIndex = idx
        }
    }

    private func closeAll() {
        for (i, dd) in dropDowns.enumerated() {
            dd.closePanel()
            if let chevron = buttons[i].viewWithTag(999) as? ChevronView {
                chevron.isUp = false
            }
        }
        currentIndex = -1
    }
}

// MARK: - DropDownView 手势代理：面板外空白触摸才触发关闭（面板内选项点击不受影响）
extension DropDownView: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let panel = panelView else { return false }
        let loc = touch.location(in: panel)
        return !panel.point(inside: loc, with: nil)
    }
}
