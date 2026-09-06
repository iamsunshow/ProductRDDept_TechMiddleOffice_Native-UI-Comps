/// AddressView 地址选择：省市区地域三级选择视图（数据录入区首批三件之一）。
///
/// 组件 ID：`ui.address`（api.json 契约对齐；门禁 A AI 代评通过 2026-09-05，规格
/// design-spec/address-design-spec.html + 评审单 review-address-A.md，P1–P4 全 A）。
///
/// 一期语义（对标 Vant Area / NutUI Address 收敛为库内设计语言）：
/// - [options]：宿主传入 省→市→区 嵌套 region 数据（RegionOption），结构=数据驱动（value+text+children+disabled）
/// - [result]：半受控选中结果（AddressResult codes/names/text）；外部变化按 codes 回显定位
/// - [onChange]：选中叶子（无 children 节点）回调完整结果（含各级 code + 中文名 + 拼接地址串）
/// - 交互：顶部层级 tab（已选各层，点击回退重选）+ 当前层列表逐级联动；到达叶子即完成
/// - 组件为内嵌内容视图：不含弹层/遮罩（宿主自理，可装入自定义弹层或页面卡片）；
///   列表区高度由宿主约束（宿主设置本视图高度即可，列表内部自动滚动）
/// - 与 CascaderView 划界：本组件=地域专用固定"省→市→区"三级语义（直辖市数据自动两级收拢）
///
/// 设计锚点（Token 注释锚定）：层级 tab 高 44pt/Sm=14，激活=primary Semibold + 底部 2pt 主色指示线
/// （同 Tabs 语义）；列表行高 44pt/Md=16，默认 textSecondary、选中 primary Semibold，选中显示 ✓；
/// 禁用节点=textSecondary 40% 透明度不可点。
///
/// 用法：
/// ```swift
/// let address = AddressView(options: regions, onChange: { result in ... })
/// host.addSubview(address)
/// address.snp.makeConstraints { make in make.top.leading.trailing.equalToSuperview(); make.height.equalTo(300) }
/// address.result = AddressResult(codes: [...], names: [...], text: "上海市 徐汇区") // 编辑回显
/// ```
import UIKit
import SnapKit

/// 省市区节点数据（与 Android `RegionOption` 同构；children=nil/空=叶子）
struct RegionOption {
    let value: String
    let text: String
    let children: [RegionOption]?
    let disabled: Bool

    init(value: String, text: String, children: [RegionOption]? = nil, disabled: Bool = false) {
        self.value = value
        self.text = text
        self.children = children
        self.disabled = disabled
    }

    var isLeaf: Bool { children?.isEmpty ?? true }
}

/// 地址选择结果（与 Android `AddressResult` 同构）：text=各级 names 空格拼接。
struct AddressResult {
    let codes: [String]
    let names: [String]
    let text: String

    init(codes: [String], names: [String], text: String) {
        self.codes = codes
        self.names = names
        self.text = text
    }

    static func build(_ path: [RegionOption]) -> AddressResult {
        AddressResult(
            codes: path.map(\.value),
            names: path.map(\.text),
            text: path.map(\.text).joined(separator: " ")
        )
    }
}

final class AddressView: UIView, UITableViewDataSource, UITableViewDelegate {

    /// 组件内布局规格（与 Android 侧同数值不同单位；Token 对齐注释防魔法值误判）
    struct Metrics {
        /// 层级 tab 栏高（44pt，与 Android 44dp 同构，同库导航条高惯例）
        static let tabBarHeight: CGFloat = 44
        /// tab 文字容器高（42pt = tab 高 − 指示线 2pt）
        static let tabLabelHeight: CGFloat = 42
        /// 激活 tab 底部指示线高（2pt，同 Tabs #20 指示线语义）
        static let indicatorHeight: CGFloat = 2
        /// 列表行高（44pt，与 Android 44dp 同构）
        static let rowHeight: CGFloat = 44
        /// 行间 hairline（1/scale pt，与 Android 0.5dp 表内放行的系统级差异）
        static var hairline: CGFloat { 1 / UIScreen.main.scale }
        /// tab 占位文案（当前层级未选时）
        static let placeholder = "请选择"
    }

    private let options: [RegionOption]
    private let onChange: ((AddressResult) -> Void)?

    // path=已展开层链（其节点必有 children）；chosen=已选中完整链（=path + 当前层已选子行，叶完成时末项为叶）。
    private var path: [RegionOption] = []
    private var chosen: [RegionOption] = []

    /// 半受控选中结果：外部驱动（初始预填/编辑回显/清空）按 codes 重定位 path/chosen。
    var result: AddressResult? {
        didSet { sync(from: result) }
    }

    private let chipsBar = UIView()
    private let chipsStack = UIStackView()
    private let listView = UITableView(frame: .zero, style: .plain)
    private var rows: [RegionOption] = []

    // MARK: - init

    init(options: [RegionOption], result: AddressResult? = nil, onChange: ((AddressResult) -> Void)? = nil) {
        self.options = options
        self.onChange = onChange
        super.init(frame: .zero)
        backgroundColor = AppColor.bgCard
        // 必须先搭 chipsBar 再搭列表：setupList 中 hairline.top 锚定 chipsBar.snp.bottom，
        // 若 chipsBar 尚未 addSubview，激活该约束时两视图无共同祖先（"no common ancestor" 崩溃）。
        setupChipsBar()
        setupList()
        sync(from: result)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("AddressView 不支持 initWithCoder 解码，请使用 init(options:result:onChange:)。")
    }

    // MARK: - 布局

    private func setupChipsBar() {
        chipsBar.backgroundColor = AppColor.bgCard
        chipsStack.axis = .horizontal
        // 等分 tab（spec .ad-tab flex:1，同 Tabs #20 指示线语义）：已选层+占位均分整条宽度
        chipsStack.distribution = .fillEqually
        chipsStack.alignment = .fill
        chipsStack.spacing = 0
        addSubview(chipsBar)
        chipsBar.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(Metrics.tabBarHeight)
        }
        chipsBar.addSubview(chipsStack)
        chipsStack.snp.makeConstraints { make in
            make.edges.equalTo(chipsBar)
        }
    }

    private func setupList() {
        listView.dataSource = self
        listView.delegate = self
        listView.separatorStyle = .none
        listView.backgroundColor = AppColor.bgCard
        listView.register(AddressRowCell.self, forCellReuseIdentifier: AddressRowCell.reuseID)
        addSubview(listView)
        listView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
        }
        // 顶部 hairline（与 Android 分割线 1dp 同构的 1/scale pt）
        let hairline = UIView()
        hairline.backgroundColor = AppColor.border
        addSubview(hairline)
        hairline.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(Metrics.hairline)
            make.top.equalTo(chipsBar.snp.bottom)
        }
        listView.snp.makeConstraints { make in
            make.top.equalTo(hairline.snp.bottom)
        }
    }

    // MARK: - 状态机（与 Android Address 同构）

    private func matchRegionPath(_ codes: [String]) -> [RegionOption] {
        var level = options
        var matched: [RegionOption] = []
        for code in codes {
            guard let node = level.first(where: { $0.value == code }) else { break }
            matched.append(node)
            if node.isLeaf { break }
            level = node.children ?? []
        }
        return matched
    }

    /// path=已展开层链：末项若为叶子则不入 path。
    private func pathFrom(chain: [RegionOption]) -> [RegionOption] {
        guard let last = chain.last else { return [] }
        return last.isLeaf ? Array(chain.dropLast()) : chain
    }

    private func sync(from result: AddressResult?) {
        let matched = result.map { matchRegionPath($0.codes) } ?? []
        chosen = matched
        path = pathFrom(chain: matched)
        refresh()
    }

    private func rebaseTab(_ index: Int) {
        // 回退：点已选层 tab → path/chosen 截断到该层之前，重选该层
        guard index < path.count else { return }
        path = Array(path.prefix(index))
        chosen = path
        refresh()
    }

    private func selectRow(_ node: RegionOption) {
        let newChosen = path + [node]
        chosen = newChosen
        if node.isLeaf {
            // 叶子=选择完成：回调完整结果（列表保持当前层并高亮该行）
            onChange?(AddressResult.build(newChosen))
        } else {
            path = newChosen
        }
        refresh()
    }

    // MARK: - 渲染

    private func refresh() {
        rebuildChips()
        let currentLevel = path.last?.children ?? options
        rows = currentLevel
        listView.reloadData()
    }

    private var isDone: Bool { chosen.count == path.count + 1 }

    private func rebuildChips() {
        chipsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let tabTexts = isDone ? chosen.map(\.text) : path.map(\.text) + [Metrics.placeholder]
        let activeIndex = tabTexts.count - 1
        for (index, title) in tabTexts.enumerated() {
            let chip = makeChip(
                title: title,
                index: index,
                active: index == activeIndex,
                tappable: !isDone && index < path.count
            )
            chipsStack.addArrangedSubview(chip)
        }
        chipsStack.setNeedsLayout()
    }

    private func makeChip(title: String, index: Int, active: Bool, tappable: Bool) -> UIView {
        let chip = UIView()
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: AppFont.sizeSm, weight: active ? .semibold : .regular)
        label.textColor = active ? AppColor.primary : AppColor.textSecondary
        label.textAlignment = .center
        chip.addSubview(label)
        label.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.height.equalTo(Metrics.tabLabelHeight)
            make.leading.trailing.equalToSuperview().inset(AppSpace.sm)
        }
        let indicator = UIView()
        indicator.backgroundColor = active ? AppColor.primary : .clear
        chip.addSubview(indicator)
        // 指示线=整格宽（spec「当前层 tab 整宽」，同 Tabs #20 语义 / Android weight 整格一致）
        indicator.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom)
            make.height.equalTo(Metrics.indicatorHeight)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        if tappable {
            chip.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(chipTapped(_:)))
            chip.tag = index
            chip.addGestureRecognizer(tap)
        } else {
            chip.isUserInteractionEnabled = false
        }
        return chip
    }

    @objc private func chipTapped(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view else { return }
        rebaseTab(view.tag)
    }

    // MARK: - UITableViewDataSource / Delegate

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rows.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        Metrics.rowHeight
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AddressRowCell.reuseID, for: indexPath) as! AddressRowCell
        let node = rows[indexPath.row]
        let selected = isDone && chosen.last?.value == node.value
        cell.configure(
            text: node.text,
            selected: selected,
            disabled: node.disabled,
            hasChildren: !node.isLeaf
        )
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let node = rows[indexPath.row]
        guard !node.disabled else { return }
        selectRow(node)
    }
}

// MARK: - 行 Cell

private final class AddressRowCell: UITableViewCell {
    static let reuseID = "AddressRowCell"

    private let titleLabel = UILabel()
    private let accessoryLabel = UILabel()
    private let hairline = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = AppColor.bgCard
        contentView.addSubview(titleLabel)
        contentView.addSubview(accessoryLabel)
        contentView.addSubview(hairline)

        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(AppSpace.lg)
            make.centerY.equalToSuperview()
            make.trailing.lessThanOrEqualTo(accessoryLabel.snp.leading).offset(-AppSpace.sm)
        }
        accessoryLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-AppSpace.lg)
            make.centerY.equalToSuperview()
        }
        hairline.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(AppSpace.lg)
            make.trailing.bottom.equalToSuperview()
            make.height.equalTo(AddressView.Metrics.hairline)
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("AddressRowCell 不支持 initWithCoder")
    }

    func configure(text: String, selected: Bool, disabled: Bool, hasChildren: Bool) {
        titleLabel.text = text
        titleLabel.font = .systemFont(ofSize: AppFont.sizeMd, weight: selected ? .semibold : .regular)
        titleLabel.textColor = disabled
            ? AppColor.textSecondary.withAlphaComponent(0.4)
            : (selected ? AppColor.primary : AppColor.textSecondary)
        titleLabel.lineBreakMode = .byTruncatingTail
        accessoryLabel.font = .systemFont(ofSize: selected ? AppFont.sizeSm : AppFont.sizeMd)
        accessoryLabel.textColor = selected ? AppColor.primary : AppColor.textSecondary
        if selected {
            accessoryLabel.text = "✓"
        } else if hasChildren {
            accessoryLabel.text = "›"
        } else {
            accessoryLabel.text = nil
        }
        hairline.backgroundColor = AppColor.border
    }
}
