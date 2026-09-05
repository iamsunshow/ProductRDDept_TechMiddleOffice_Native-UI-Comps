/// CascaderView 级联选择：通用多级数据选择视图（数据录入区首批三件之一）。
///
/// 组件 ID：`ui.cascader`（api.json 契约对齐；门禁 A AI 代评通过 2026-09-05，规格
/// design-spec/cascader-design-spec.html + 评审单 review-cascader-A.md，P1–P4 全 A）。
///
/// 一期语义（对标 Vant Cascader 收敛为库内设计语言）：
/// - [options]：宿主传入 通用多级 嵌套树数据（CascaderOption），结构=数据驱动（value+text+children+disabled）
/// - [result]：半受控选中结果（CascaderResult values/texts/text，text 各级「/」拼接）；外部变化按 values 回显定位
/// - [onChange]：选中叶子（无 children 节点）回调完整结果（含各级 value + 文案 + 拼接串）
/// - 交互：顶部路径 tab（已选各层，点击回退重选）+ 当前层列表逐级联动；到达叶子即完成
/// - 组件为内嵌内容视图：不含弹层/遮罩（宿主自理）；列表区高度由宿主约束，列表内部自动滚动
/// - 与 AddressView 划界：本组件=通用树形级联（分类/组织/任意多级），Address=地域专用三级（text 空格拼接）
///
/// 设计锚点（Token 注释锚定）：路径 tab 高 44pt/Sm=14，激活=primary Semibold + 底部 2pt 主色指示线
/// （同 Tabs 语义）；列表行高 44pt/Md=16，默认 textSecondary、选中 primary Semibold，选中显示 ✓；
/// 禁用节点=textSecondary 40% 透明度不可点。
///
/// 用法：
/// ```swift
/// let cascader = CascaderView(options: tree, onChange: { result in ... })
/// host.addSubview(cascader)
/// cascader.snp.makeConstraints { make in make.top.leading.trailing.equalToSuperview(); make.height.equalTo(300) }
/// cascader.result = CascaderResult(values: [...], texts: [...], text: "集团/产品线 A") // 编辑回显
/// ```
import UIKit
import SnapKit

/// 通用级联节点数据（与 Android `CascaderOption` 同构；children=nil/空=叶子）
struct CascaderOption {
    let value: String
    let text: String
    let children: [CascaderOption]?
    let disabled: Bool

    init(value: String, text: String, children: [CascaderOption]? = nil, disabled: Bool = false) {
        self.value = value
        self.text = text
        self.children = children
        self.disabled = disabled
    }

    var isLeaf: Bool { children?.isEmpty ?? true }
}

/// 级联选择结果（与 Android `CascaderResult` 同构）：text=各级 texts「/」拼接。
struct CascaderResult {
    let values: [String]
    let texts: [String]
    let text: String

    init(values: [String], texts: [String], text: String) {
        self.values = values
        self.texts = texts
        self.text = text
    }

    static func build(_ path: [CascaderOption]) -> CascaderResult {
        CascaderResult(
            values: path.map(\.value),
            texts: path.map(\.text),
            text: path.map(\.text).joined(separator: "/")
        )
    }
}

final class CascaderView: UIView, UITableViewDataSource, UITableViewDelegate {

    /// 组件内布局规格（与 Android 侧同数值不同单位；Token 对齐注释防魔法值误判）
    struct Metrics {
        /// 路径 tab 栏高（44pt，与 Android 44dp 同构，同库导航条高惯例）
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

    private let options: [CascaderOption]
    private let onChange: ((CascaderResult) -> Void)?

    // path=已展开层链（其节点必有 children）；chosen=已选中完整链（=path + 当前层已选子行，叶完成时末项为叶）。
    private var path: [CascaderOption] = []
    private var chosen: [CascaderOption] = []

    /// 半受控选中结果：外部驱动（初始预填/编辑回显/清空）按 values 重定位 path/chosen。
    var result: CascaderResult? {
        didSet { sync(from: result) }
    }

    private let chipsBar = UIView()
    private let chipsStack = UIStackView()
    private let listView = UITableView(frame: .zero, style: .plain)
    private var rows: [CascaderOption] = []

    // MARK: - init

    init(options: [CascaderOption], result: CascaderResult? = nil, onChange: ((CascaderResult) -> Void)? = nil) {
        self.options = options
        self.onChange = onChange
        super.init(frame: .zero)
        backgroundColor = AppColor.bgCard
        setupList()
        setupChipsBar()
        sync(from: result)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("CascaderView 不支持 initWithCoder 解码，请使用 init(options:result:onChange:)。")
    }

    // MARK: - 布局

    private func setupChipsBar() {
        chipsBar.backgroundColor = AppColor.bgCard
        chipsStack.axis = .horizontal
        // 等分 tab（spec .cc-tab flex:1，同 Tabs #20 指示线语义）：已选层+占位均分整条宽度
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
        listView.register(CascaderRowCell.self, forCellReuseIdentifier: CascaderRowCell.reuseID)
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

    // MARK: - 状态机（与 Android Cascader 同构）

    private func matchPath(_ values: [String]) -> [CascaderOption] {
        var level = options
        var matched: [CascaderOption] = []
        for value in values {
            guard let node = level.first(where: { $0.value == value }) else { break }
            matched.append(node)
            if node.isLeaf { break }
            level = node.children ?? []
        }
        return matched
    }

    /// path=已展开层链：末项若为叶子则不入 path。
    private func pathFrom(chain: [CascaderOption]) -> [CascaderOption] {
        guard let last = chain.last else { return [] }
        return last.isLeaf ? Array(chain.dropLast()) : chain
    }

    private func sync(from result: CascaderResult?) {
        let matched = result.map { matchPath($0.values) } ?? []
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

    private func selectRow(_ node: CascaderOption) {
        let newChosen = path + [node]
        chosen = newChosen
        if node.isLeaf {
            // 叶子=选择完成：回调完整结果（列表保持当前层并高亮该行）
            onChange?(CascaderResult.build(newChosen))
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
        let cell = tableView.dequeueReusableCell(withIdentifier: CascaderRowCell.reuseID, for: indexPath) as! CascaderRowCell
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

private final class CascaderRowCell: UITableViewCell {
    static let reuseID = "CascaderRowCell"

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
            make.height.equalTo(CascaderView.Metrics.hairline)
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("CascaderRowCell 不支持 initWithCoder")
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
