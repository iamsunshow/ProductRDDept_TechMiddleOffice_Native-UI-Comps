/// ElevatorView 电梯楼层：数据驱动分组内容 + 右侧楼/字母索引导航的"定位器"。
///
/// 组件 ID：`ui.elevator`（api.json 契约对齐，门禁 A AI 代评通过 2026-09-05，
/// 用户"除特色组件外所有组件评审文档全部生成，中间任何询问直接通过"总授权；
/// P1–P4 全 A：自包含定高 + 索引自动/显式 + 双向联动 + 行点击可选）。
///
/// 一期语义（对标 NutUI React Elevator 电梯楼层）：
/// - [floors]：分组数据 [(key: 分组标题, items: 组内文本行)]
/// - [index]：右侧索引；nil=自动取各分组 key
/// - [onSelect]：分组行点击回调 (分组序号, 组内行号, 名称)；nil=不响应行点击
/// - 交互：点右侧索引 → 对应分组首行滚到可视顶部；内容滚动 → 可视首分组高亮索引
/// - 分组标题行（高 32pt）=普通行随内容滚动（不吸顶，见 anti_goal 二期）；内容行高 56pt=规范行高
/// - 滚动容器高度由宿主约束（组件不强代管布局上下文）
///
/// 用法：
/// ```swift
/// let elevator = ElevatorView(floors: [
///     ElevatorFloor(key: "1F", items: ["星巴克", "瑞幸"]),
///     ElevatorFloor(key: "2F", items: ["优衣库"]),
/// ])
/// host.addSubview(elevator)
/// elevator.snp.makeConstraints { make in
///     make.leading.trailing.equalToSuperview()
///     make.top.equalToSuperview().offset(AppSpace.lg)
///     make.height.equalTo(300)
/// }
/// ```
import UIKit
import SnapKit

/// 电梯楼层分组数据（与 Android `ElevatorFloor` 同构）
struct ElevatorFloor {
    let key: String
    let items: [String]
    init(key: String, items: [String]) {
        self.key = key
        self.items = items
    }
}

final class ElevatorView: UIView, UITableViewDataSource, UITableViewDelegate {

    /// 组件内布局规格（与 Android 侧同数值不同单位；Token 对齐注释防魔法值误判）
    struct Metrics {
        /// 分组标题行高（32pt，与 Android 32dp 同构）
        static let headerHeight: CGFloat = 32
        /// 分组内容行高（56pt，对齐 Cell.minHeight 同库规范行高）
        static let rowHeight: CGFloat = 56
        /// 右侧索引条宽（44pt，与 Android 44dp 同构）
        static let indexBarWidth: CGFloat = 44
    }

    /// 扁平行类型：分组标题行 / 内容行（无 UITableView section=标题不吸顶，双端同构）
    private enum RowKind {
        case header(floor: Int, key: String)
        case item(floor: Int, row: Int, name: String)

        var floor: Int {
            switch self {
            case .header(let f, _), .item(let f, _, _): return f
            }
        }
    }

    private let floors: [ElevatorFloor]
    private let indexKeys: [String]
    private let onSelect: ((_ floor: Int, _ row: Int, _ name: String) -> Void)?

    private var rows: [RowKind] = []
    /// floor → 该分组 header 所在 rows 下标
    private var headerRowIndexOfFloor: [Int: Int] = [:]
    private var indexButtonOfKey: [String: UIButton] = [:]

    private let tableView = UITableView(frame: .zero, style: .plain)
    private let indexArea = UIView()
    private var currentFloor = 0

    // MARK: - init

    init(floors: [ElevatorFloor],
         index: [String]? = nil,
         onSelect: ((_ floor: Int, _ row: Int, _ name: String) -> Void)? = nil) {
        self.floors = floors
        self.indexKeys = index ?? floors.map(\.key)
        self.onSelect = onSelect
        super.init(frame: .zero)
        backgroundColor = .clear
        rebuildRows()
        setupList()
        setupIndexBar()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("ElevatorView 不支持 initWithCoder 解码，请使用 init(floors:index:onSelect:)。")
    }

    /// 构建扁平行序列 + floor→header 行下标映射
    private func rebuildRows() {
        rows.removeAll()
        headerRowIndexOfFloor.removeAll()
        for (floor, group) in floors.enumerated() {
            headerRowIndexOfFloor[floor] = rows.count
            rows.append(.header(floor: floor, key: group.key))
            for (row, name) in group.items.enumerated() {
                rows.append(.item(floor: floor, row: row, name: name))
            }
        }
    }

    // MARK: - 布局

    private func setupList() {
        tableView.register(ElevatorRowCell.self, forCellReuseIdentifier: ElevatorRowCell.reuseID)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        addSubview(tableView)
        addSubview(indexArea)
        tableView.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview()
            make.trailing.equalTo(indexArea.snp.leading)
        }
        indexArea.snp.makeConstraints { make in
            make.top.trailing.bottom.equalToSuperview()
            make.width.equalTo(Metrics.indexBarWidth)
        }
    }

    private func setupIndexBar() {
        indexArea.backgroundColor = .clear
        indexButtonOfKey.removeAll()

        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.alignment = .fill
        stack.spacing = AppSpace.xs
        indexArea.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(AppSpace.xs)
            make.leading.trailing.equalToSuperview().inset(AppSpace.xs)
        }

        for key in indexKeys {
            let button = UIButton(type: .system)
            button.setTitle(key, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: AppFont.sizeXs, weight: .regular)
            button.titleLabel?.textAlignment = .center
            button.setTitleColor(AppColor.textSecondary, for: .normal)
            button.tintColor = .clear
            button.addTarget(self, action: #selector(didTapIndex(_:)), for: .touchUpInside)
            stack.addArrangedSubview(button)
            indexButtonOfKey[key] = button
        }
        updateIndexHighlight(animated: false)
    }

    @objc private func didTapIndex(_ sender: UIButton) {
        guard let key = sender.title(for: .normal),
              let floor = floors.firstIndex(where: { $0.key == key }),
              let headerRow = headerRowIndexOfFloor[floor] else { return }
        tableView.scrollToRow(at: IndexPath(row: headerRow, section: 0), at: .top, animated: true)
    }

    /// 滚动联动高亮：可视首行所在分组即当前分组
    private func updateCurrentFloorIfNeeded() {
        guard let first = tableView.indexPathsForVisibleRows?.first, first.row < rows.count else { return }
        let floor = rows[first.row].floor
        guard floor != currentFloor else { return }
        currentFloor = floor
        updateIndexHighlight(animated: false)
    }

    private func updateIndexHighlight(animated: Bool) {
        guard let currentKey = floors[safe: currentFloor]?.key else { return }
        for (key, button) in indexButtonOfKey {
            let isCurrent = key == currentKey
            let final: (UIColor, UIFont) = isCurrent
                ? (AppColor.primary, .systemFont(ofSize: AppFont.sizeXs, weight: .bold))
                : (AppColor.textSecondary, .systemFont(ofSize: AppFont.sizeXs, weight: .regular))
            if animated {
                UIView.animate(withDuration: 0.15) {
                    button.setTitleColor(final.0, for: .normal)
                    button.titleLabel?.font = final.1
                }
            } else {
                button.setTitleColor(final.0, for: .normal)
                button.titleLabel?.font = final.1
            }
        }
    }

    // MARK: - UITableViewDataSource / Delegate

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rows.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch rows[indexPath.row] {
        case .header: return Metrics.headerHeight
        case .item: return Metrics.rowHeight
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ElevatorRowCell.reuseID, for: indexPath) as! ElevatorRowCell
        switch rows[indexPath.row] {
        case .header(_, let key):
            cell.configureHeader(key)
        case .item(_, _, let name):
            cell.configureItem(name)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard case .item(let floor, let row, let name) = rows[indexPath.row] else { return }
        onSelect?(floor, row, name)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateCurrentFloorIfNeeded()
    }
}

// MARK: - 行 Cell

private final class ElevatorRowCell: UITableViewCell {

    static let reuseID = "ElevatorRowCell"

    private let titleLabel = UILabel()
    /// 分组标题底色（仅 header 模式显示）
    private let headerBg = UIView()
    /// 内容行底部细分割线（header 模式隐藏，与 Android 行为同构）
    private let divider = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        contentView.addSubview(headerBg)
        headerBg.snp.makeConstraints { make in make.edges.equalToSuperview() }

        contentView.addSubview(titleLabel)
        titleLabel.numberOfLines = 1
        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(AppSpace.lg)
            make.centerY.equalToSuperview()
        }

        contentView.addSubview(divider)
        divider.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("ElevatorRowCell 不支持 initWithCoder 解码。")
    }

    func configureHeader(_ key: String) {
        headerBg.backgroundColor = AppColor.primaryMuted
        titleLabel.text = key
        titleLabel.font = .systemFont(ofSize: AppFont.sizeXs, weight: .semibold)
        titleLabel.textColor = AppColor.primaryPressed
        divider.isHidden = true
    }

    func configureItem(_ name: String) {
        headerBg.backgroundColor = .clear
        titleLabel.text = name
        titleLabel.font = .systemFont(ofSize: AppFont.sizeSm)
        titleLabel.textColor = AppColor.textPrimary
        divider.isHidden = false
    }
}

// MARK: - 数组越界安全访问

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
