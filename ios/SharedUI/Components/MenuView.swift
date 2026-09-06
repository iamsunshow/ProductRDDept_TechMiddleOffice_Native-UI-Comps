/// MenuView 菜单：嵌入式下拉单选菜单（数据录入区 · 任务清单 #31 · ui.menu）。
///
/// 组件 ID：`ui.menu`（api.json 契约对齐；门禁 A AI 代评通过 2026-09-06，规格
/// design-spec/menu-design-spec.html，P1–P4 全 A）。基线：组件库 v1.4.0。
///
/// 一期语义（对标 NutUI Menu 收敛为库内设计语言，无遮罩/无悬浮浮层）：
/// - [columns]：宿主传入 ≤4 列 MenuColumn（key=稳定 id / title=列标题 / options=单选池），菜单栏等分排布
/// - [selectedValues]：半受控——外部按列 key 传入选中 option value 驱动回显（高亮+标题小字）；
///   nil/缺列=该列取 options 首个启用项；用户点选后组件内部自持
/// - [onChange]：(columnKey, optionValue) 用户点选选项回调并收起
/// - 交互：点列=展开内联面板（其余列自动收起）；点当前展开列=收起（幂等）；面板选项单选、点选即收起
/// - 禁用：列级 disabled=整列不可展开、灰 40%；选项级 disabled=面板行灰 40% 不可点
/// - 组件为内嵌内容视图：高度随展开态变化（收起 44pt / 展开 44+面板高 ≤220pt），
///   宿主纵向容器自然推挤下方内容；无弹层/遮罩（Popup 悬浮版二期）
/// - 与 Cascader/Address 划界：本组件=单层每列平铺单选（菜单栏回显选中值）；
///   多级级联/联动筛选/底部弹层选择=对应组件或宿主职责
///
/// 设计锚点（Token 注释锚定）：菜单栏高 44pt/Md=16 标题（激活列=primary Semibold）+ Xs=12 当前值
/// 次色小字（≤列 52% 单行省略）+ ▾/▴ 指示（激活主色、展开上翻）；面板行高 44pt、max 高 220pt
/// （=5 行，超出内部滚动）、行间 hairline；选中行=primary Semibold + ✓。
///
/// 用法：
/// ```swift
/// let menu = MenuView(columns: demoColumns, onChange: { key, value in ... })
/// host.addSubview(menu)
/// menu.snp.makeConstraints { make in make.top.leading.trailing.equalToSuperview() }
/// menu.selectedValues = ["time": "year"] // 编辑回显/外部驱动
/// ```
import UIKit
import SnapKit

/// 菜单选项（与 Android `MenuOption` 同构）
struct MenuOption {
    let value: String
    let text: String
    let disabled: Bool

    init(value: String, text: String, disabled: Bool = false) {
        self.value = value
        self.text = text
        self.disabled = disabled
    }
}

/// 菜单列（与 Android `MenuColumn` 同构）：title=列标题（常驻主文案）、options=该列单选池
struct MenuColumn {
    let key: String
    let title: String
    let options: [MenuOption]
    let disabled: Bool

    init(key: String, title: String, options: [MenuOption], disabled: Bool = false) {
        self.key = key
        self.title = title
        self.options = options
        self.disabled = disabled
    }
}

final class MenuView: UIView {

    /// 组件内布局规格（与 Android 侧同数值不同单位；Token 对齐注释防魔法值误判）
    struct Metrics {
        /// 菜单栏高（44pt，与 Android 44dp 同构，同库行高惯例）
        static let barHeight: CGFloat = 44
        /// 面板行高（44pt，与 Android 44dp 同构）
        static let rowHeight: CGFloat = 44
        /// 面板 max 高（220pt = 5 行，超出内部滚动）
        static let maxPanelHeight: CGFloat = 220
        /// 列间/行间 hairline（1/scale pt，与 Android 0.5dp 表内放行的系统级差异）
        static var hairline: CGFloat { 1 / UIScreen.main.scale }
    }

    private let columns: [MenuColumn]
    private let onChange: ((String, String) -> Void)?

    // 半受控选中值（列 key → option value）；内部点选自持，外部赋值驱动回显
    private var selected: [String: String] = [:]

    // 当前展开列 key（内部自管理，同时仅一列展开；nil=全部收起）
    private var activeColumnKey: String?

    private let barStack = UIStackView()
    private let panelScroll = UIScrollView()
    private let panelStack = UIStackView()
    private let panelHairline = UIView()
    /// 面板高度约束（收起=0；展开=min(行数,5)×44），配合"44+面板高"内链闭合决定组件高度
    private var panelHeightConstraint: Constraint?

    /// 半受控选中值：外部传入（编辑回显/重置筛选）→ 按列 key 匹配 option 值刷新回显，不触发 onChange。
    /// 每次整表赋值按规则重算各列选中值（含默认首启用项回落）。
    var selectedValues: [String: String]? {
        didSet { applyExternalSelection() }
    }

    /// 组件当前高度：收起=44+hairline；展开=44+hairline+面板高（≤220）。随展开态变化供宿主推挤内容。
    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: currentHeight)
    }

    private var currentHeight: CGFloat {
        Metrics.barHeight + Metrics.hairline + currentPanelHeight
    }

    private var currentPanelHeight: CGFloat {
        guard let key = activeColumnKey,
              let column = columns.first(where: { $0.key == key }) else { return 0 }
        return min(CGFloat(column.options.count) * Metrics.rowHeight, Metrics.maxPanelHeight)
    }

    // MARK: - init

    init(columns: [MenuColumn], selectedValues: [String: String]? = nil, onChange: ((String, String) -> Void)? = nil) {
        self.columns = columns
        self.onChange = onChange
        super.init(frame: .zero)
        backgroundColor = AppColor.bgCard
        setupLayout()
        applyExternalSelection()
        rebuildBar()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("MenuView 不支持 initWithCoder 解码，请使用 init(columns:selectedValues:onChange:)。")
    }

    // MARK: - 布局骨架（内链闭合：bar 44 + hairline + 面板(0~220) → 视图高随展开态变化）

    private func setupLayout() {
        barStack.axis = .horizontal
        barStack.distribution = .fillEqually
        barStack.alignment = .fill
        barStack.spacing = 0
        addSubview(barStack)
        barStack.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(Metrics.barHeight)
        }

        panelHairline.backgroundColor = AppColor.border
        addSubview(panelHairline)
        panelHairline.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(Metrics.hairline)
            make.top.equalTo(barStack.snp.bottom)
        }

        panelScroll.backgroundColor = AppColor.bgCard
        panelScroll.showsVerticalScrollIndicator = false
        panelStack.axis = .vertical
        panelStack.spacing = 0
        panelStack.alignment = .fill
        panelScroll.addSubview(panelStack)
        panelStack.snp.makeConstraints { make in
            make.edges.equalTo(panelScroll.contentLayoutGuide)
            make.width.equalTo(panelScroll.frameLayoutGuide)
        }
        addSubview(panelScroll)
        panelScroll.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(panelHairline.snp.bottom)
            make.bottom.equalToSuperview()
            panelHeightConstraint = make.height.equalTo(0).constraint
        }
    }

    // MARK: - 选中值解析

    /// 按"列 key → option value"解析一列的当前选中 option（无匹配/缺省=该列首个启用项）。
    private func resolveSelectedValue(for column: MenuColumn, from external: [String: String]?) -> String? {
        if let value = external?[column.key], column.options.contains(where: { $0.value == value }) {
            return value
        }
        return column.options.first(where: { !$0.disabled })?.value
    }

    private func applyExternalSelection() {
        var merged: [String: String] = [:]
        for column in columns {
            if let value = resolveSelectedValue(for: column, from: selectedValues) {
                merged[column.key] = value
            }
        }
        selected = merged
        rebuildBar()
    }

    /// 当前列在菜单栏展示的选中 option 文本。
    private func displayText(for column: MenuColumn) -> String? {
        guard let value = selected[column.key],
              let option = column.options.first(where: { $0.value == value }) else { return nil }
        return option.text
    }

    // MARK: - 菜单栏

    private func rebuildBar() {
        barStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for column in columns {
            barStack.addArrangedSubview(makeBarCell(column: column))
        }
    }

    private func makeBarCell(column: MenuColumn) -> UIButton {
        let cell = UIButton(type: .system)
        cell.backgroundColor = AppColor.bgCard
        let active = activeColumnKey == column.key
        let dimmed = column.disabled
        cell.isEnabled = !column.disabled

        let title = UILabel()
        title.text = column.title
        title.font = .systemFont(ofSize: AppFont.sizeMd, weight: active ? .semibold : .regular)
        title.textColor = dimmed
            ? AppColor.textSecondary.withAlphaComponent(0.4)
            : (active ? AppColor.primary : AppColor.textPrimary)
        title.lineBreakMode = .byTruncatingTail

        let value = UILabel()
        value.font = .systemFont(ofSize: AppFont.sizeXs)
        value.textColor = dimmed ? AppColor.textSecondary.withAlphaComponent(0.4) : AppColor.textSecondary
        value.text = displayText(for: column)
        value.lineBreakMode = .byTruncatingTail
        // 当前值小字≤列 52% 且优先被压缩：标题保满、小字先截断
        value.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        title.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let arrow = UILabel()
        arrow.text = dimmed ? "▾" : (active ? "▴" : "▾")
        arrow.font = .systemFont(ofSize: AppFont.sizeXs)
        arrow.textColor = dimmed
            ? AppColor.textSecondary.withAlphaComponent(0.4)
            : (active ? AppColor.primary : AppColor.textSecondary)

        let stack = UIStackView(arrangedSubviews: [title, value, arrow])
        stack.axis = .horizontal
        stack.spacing = AppSpace.sm / 2
        stack.alignment = .center
        stack.isUserInteractionEnabled = false
        cell.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().offset(AppSpace.xs)
            make.trailing.lessThanOrEqualToSuperview().offset(-AppSpace.xs)
        }
        // 点击按压反馈（touchDown 压暗瞬态，与 Android ripple 系统级差异放行）
        cell.addTarget(self, action: #selector(barPressDown(_:)), for: .touchDown)
        cell.addTarget(self, action: #selector(barPressUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        return cell
    }

    @objc private func barPressDown(_ sender: UIButton) {
        sender.alpha = 0.6
    }

    @objc private func barPressUp(_ sender: UIButton) {
        sender.alpha = 1
        guard let index = barStack.arrangedSubviews.firstIndex(of: sender), index < columns.count else { return }
        toggleColumn(columns[index])
    }

    private func toggleColumn(_ column: MenuColumn) {
        guard !column.disabled else { return }
        if activeColumnKey == column.key {
            collapse()
        } else {
            expand(column)
        }
    }

    // MARK: - 面板

    private func expand(_ column: MenuColumn) {
        activeColumnKey = column.key
        rebuildPanel(for: column)
        updatePanelHeight()
        rebuildBar()
    }

    private func collapse() {
        activeColumnKey = nil
        panelStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        updatePanelHeight()
        rebuildBar()
    }

    private func rebuildPanel(for column: MenuColumn) {
        panelStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for (index, option) in column.options.enumerated() {
            let isSelected = selected[column.key] == option.value
            let row = makeRow(option: option, selected: isSelected)
            row.tag = index
            panelStack.addArrangedSubview(row)
            row.snp.makeConstraints { make in make.height.equalTo(Metrics.rowHeight) }
        }
    }

    private func makeRow(option: MenuOption, selected: Bool) -> UIButton {
        let row = UIButton(type: .system)
        row.backgroundColor = AppColor.bgCard
        row.isEnabled = !option.disabled

        let label = UILabel()
        label.text = option.text
        label.font = .systemFont(ofSize: AppFont.sizeMd, weight: selected ? .semibold : .regular)
        label.textColor = option.disabled
            ? AppColor.textSecondary.withAlphaComponent(0.4)
            : (selected ? AppColor.primary : AppColor.textPrimary)
        label.lineBreakMode = .byTruncatingTail
        row.addSubview(label)
        label.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(AppSpace.lg)
            make.centerY.equalToSuperview()
            make.trailing.lessThanOrEqualToSuperview().offset(-AppSpace.xl)
        }

        if selected {
            let check = UILabel()
            check.text = "✓"
            check.font = .systemFont(ofSize: AppFont.sizeSm)
            check.textColor = AppColor.primary
            row.addSubview(check)
            check.snp.makeConstraints { make in
                make.trailing.equalToSuperview().offset(-AppSpace.lg)
                make.centerY.equalToSuperview()
            }
        }

        let hairline = UIView()
        hairline.backgroundColor = AppColor.border
        row.addSubview(hairline)
        hairline.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(AppSpace.lg)
            make.trailing.bottom.equalToSuperview()
            make.height.equalTo(Metrics.hairline)
        }

        row.addTarget(self, action: #selector(rowPressDown(_:)), for: .touchDown)
        row.addTarget(self, action: #selector(rowPressUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        return row
    }

    @objc private func rowPressDown(_ sender: UIButton) {
        sender.alpha = 0.6
    }

    @objc private func rowPressUp(_ sender: UIButton) {
        sender.alpha = 1
        guard let activeKey = activeColumnKey,
              let column = columns.first(where: { $0.key == activeKey }),
              let panelRows = panelStack.arrangedSubviews as? [UIButton],
              let index = panelRows.firstIndex(of: sender),
              index < column.options.count else { return }
        let option = column.options[index]
        guard !option.disabled else { return }
        selected[column.key] = option.value
        collapse()
        onChange?(column.key, option.value)
    }

    private func updatePanelHeight() {
        let rows = activeColumnKey.flatMap { key in columns.first(where: { $0.key == key })?.options.count } ?? 0
        let panelHeight = activeColumnKey == nil ? 0 : min(CGFloat(rows) * Metrics.rowHeight, Metrics.maxPanelHeight)
        panelScroll.isHidden = activeColumnKey == nil
        panelHeightConstraint?.update(offset: panelHeight)
        // 高度随展开态变化：通知宿主 AutoLayout/UIStackView 重算（intrinsic 失效触发下方内容推挤）
        invalidateIntrinsicContentSize()
        setNeedsLayout()
    }
}
