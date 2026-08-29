import UIKit
import SnapKit

// MARK: - Demo List

final class DemoListViewController: UITableViewController {

    struct ComponentItem {
        let id: String
        let category: String
        let name: String
        let create: () -> UIViewController
    }

    private let items: [ComponentItem] = [
        ComponentItem(id: "foundation.design-tokens", category: "foundation", name: "Design Tokens 设计令牌") { DesignTokensShowcase() },
        ComponentItem(id: "foundation.money-format", category: "foundation", name: "MoneyFormatter 金额格式化") { MoneyFormatterShowcase() },
        ComponentItem(id: "foundation.calendar", category: "foundation", name: "CalendarFormatter 月份工具") { CalendarFormatterShowcase() },
        ComponentItem(id: "foundation.storage", category: "foundation", name: "AppDatabase 本地存储") { StorageShowcase() },
        ComponentItem(id: "foundation.http-client", category: "foundation", name: "MockAPIClient 网络客户端") { NetworkShowcase() },
        ComponentItem(id: "basic.empty", category: "basic", name: "EmptyStateView 空态") { EmptyStateShowcase() },
        ComponentItem(id: "basic.date-picker", category: "basic", name: "DatePickerSheet 日期选择") { DatePickerShowcase() },
        ComponentItem(id: "basic.date-picker-month", category: "basic", name: "MonthPicker 月份选择") { MonthPickerShowcase() },
        ComponentItem(id: "basic.date-picker-year", category: "basic", name: "YearPicker 年份选择") { YearPickerShowcase() },
        ComponentItem(id: "basic.picker", category: "basic", name: "OptionPicker 选项滚轮") { OptionPickerShowcase() },
        ComponentItem(id: "basic.list-item", category: "basic", name: "GroupListItem 列表行") { GroupListItemShowcase() },
        ComponentItem(id: "basic.list", category: "basic", name: "GroupList 分组列表") { GroupListShowcase() },
        ComponentItem(id: "basic.grid", category: "basic", name: "NavigationGrid 导航网格") { GridShowcase() },
        ComponentItem(id: "basic.card", category: "basic", name: "SummaryCard 摘要卡") { CardShowcase() },
        ComponentItem(id: "basic.line-chart", category: "basic", name: "TrendChart 折线图") { TrendChartShowcase() },
        ComponentItem(id: "basic.navbar", category: "basic", name: "NavBar 快捷导航") { NavBarShowcase() },
        ComponentItem(id: "basic.tabs", category: "basic", name: "Tabs 切换") { TabsShowcase() },
        ComponentItem(id: "basic.refresh", category: "basic", name: "PullRefreshTableView 下拉刷新") { RefreshShowcase() },
        ComponentItem(id: "basic.webview", category: "basic", name: "WebContent H5 容器") { WebViewShowcase() },
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "TMO Component Demo"
        view.backgroundColor = AppColor.bgPage
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.separatorStyle = .none
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item = items[indexPath.row]
        var config = cell.defaultContentConfiguration()
        config.text = item.name
        config.secondaryText = item.category.uppercased()
        config.secondaryTextProperties.color = item.category == "foundation" ? AppColor.primary : AppColor.textSecondary
        config.textProperties.font = .systemFont(ofSize: AppFont.sizeMd, weight: .medium)
        cell.contentConfiguration = config
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = .white
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = items[indexPath.row].create()
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - Showcase Base

class ShowcaseViewController: UIViewController {
    let scrollView = UIScrollView()
    let contentStack = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColor.bgPage
        scrollView.alwaysBounceVertical = true
        contentStack.axis = .vertical
        contentStack.spacing = AppSpace.lg
        contentStack.alignment = .fill

        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        contentStack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(AppSpace.lg)
            make.bottom.equalToSuperview().offset(-AppSpace.xl)
            make.leading.trailing.equalToSuperview().inset(AppSpace.lg)
            make.width.equalTo(scrollView).offset(-AppSpace.lg * 2)
        }
    }

    func addSection(title: String, _ block: (UIView) -> Void) {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: AppFont.sizeMd, weight: .semibold)
        titleLabel.textColor = AppColor.textPrimary
        contentStack.addArrangedSubview(titleLabel)

        let container = UIView()
        container.backgroundColor = .white
        container.layer.cornerRadius = AppRadius.lg
        container.layer.borderWidth = 1 / UIScreen.main.scale
        container.layer.borderColor = AppColor.border.cgColor
        container.layoutMargins = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        contentStack.addArrangedSubview(container)

        block(container)
    }

    func addInfo(_ text: String) {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: AppFont.sizeXs)
        label.textColor = AppColor.textSecondary
        label.numberOfLines = 0
        contentStack.addArrangedSubview(label)
    }

    func makeContainer() -> UIView {
        let container = UIView()
        container.backgroundColor = .white
        container.layer.cornerRadius = AppRadius.lg
        container.layer.borderWidth = 1 / UIScreen.main.scale
        container.layer.borderColor = AppColor.border.cgColor
        return container
    }
}

// MARK: - Foundation Showcases

final class DesignTokensShowcase: ShowcaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Design Tokens"

        addSection(title: "颜色") { container in
            let colors: [(String, UIColor)] = [
                ("primary", AppColor.primary),
                ("income", AppColor.income),
                ("expense", AppColor.expense),
                ("warning", AppColor.warning),
                ("textPrimary", AppColor.textPrimary),
                ("textSecondary", AppColor.textSecondary),
                ("border", AppColor.border),
                ("bgPage", AppColor.bgPage),
                ("bgCard", AppColor.bgCard),
            ]
            var lastView: UIView? = nil
            for (name, color) in colors {
                let swatch = UIView()
                swatch.backgroundColor = color
                swatch.layer.cornerRadius = AppRadius.sm
                let label = UILabel()
                label.text = name
                label.font = .systemFont(ofSize: AppFont.sizeXs)
                label.textColor = AppColor.textPrimary
                let row = UIStackView(arrangedSubviews: [swatch, label])
                row.axis = .horizontal
                row.spacing = AppSpace.sm
                row.alignment = .center
                container.addSubview(row)
                row.snp.makeConstraints { make in
                    make.leading.trailing.equalToSuperview().inset(AppSpace.md)
                    if let last = lastView {
                        make.top.equalTo(last.snp.bottom).offset(AppSpace.sm)
                    } else {
                        make.top.equalToSuperview().offset(AppSpace.md)
                    }
                }
                swatch.snp.makeConstraints { make in make.width.height.equalTo(24) }
                lastView = row
            }
            lastView?.snp.makeConstraints { make in make.bottom.equalToSuperview().offset(-AppSpace.md) }
        }

        addSection(title: "字号") { container in
            let sizes: [(String, CGFloat)] = [
                ("sizeXs 12", AppFont.sizeXs), ("sizeSm 14", AppFont.sizeSm),
                ("sizeMd 16", AppFont.sizeMd), ("sizeLg 18", AppFont.sizeLg),
                ("sizeXl 22", AppFont.sizeXl), ("sizeDisplay 32", AppFont.sizeDisplay),
            ]
            var lastView: UIView? = nil
            for (name, size) in sizes {
                let label = UILabel()
                label.text = name
                label.font = .systemFont(ofSize: size)
                label.textColor = AppColor.textPrimary
                container.addSubview(label)
                label.snp.makeConstraints { make in
                    make.leading.trailing.equalToSuperview().inset(AppSpace.md)
                    if let last = lastView {
                        make.top.equalTo(last.snp.bottom).offset(AppSpace.sm)
                    } else {
                        make.top.equalToSuperview().offset(AppSpace.md)
                    }
                }
                lastView = label
            }
            lastView?.snp.makeConstraints { make in make.bottom.equalToSuperview().offset(-AppSpace.md) }
        }
    }
}

final class MoneyFormatterShowcase: ShowcaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "MoneyFormatter"
        addSection(title: "格式化") { container in
            let testCases: [(String, String)] = [
                ("string(38.5)", MoneyFormatter.string(from: 38.5)),
                ("string(1121)", MoneyFormatter.string(from: 1121)),
                ("currency(99.9)", MoneyFormatter.currency(from: 99.9)),
                ("signed(50, 收入)", MoneyFormatter.signed(from: 50, isIncome: true)),
                ("signed(50, 支出)", MoneyFormatter.signed(from: 50, isIncome: false)),
            ]
            var lastView: UIView? = nil
            for (input, output) in testCases {
                let label = UILabel()
                label.text = "\(input) → \(output)"
                label.font = .monospacedSystemFont(ofSize: AppFont.sizeSm, weight: .regular)
                label.textColor = AppColor.textPrimary
                container.addSubview(label)
                label.snp.makeConstraints { make in
                    make.leading.trailing.equalToSuperview().inset(AppSpace.md)
                    if let last = lastView {
                        make.top.equalTo(last.snp.bottom).offset(AppSpace.sm)
                    } else {
                        make.top.equalToSuperview().offset(AppSpace.md)
                    }
                }
                lastView = label
            }
            lastView?.snp.makeConstraints { make in make.bottom.equalToSuperview().offset(-AppSpace.md) }
        }
    }
}

final class CalendarFormatterShowcase: ShowcaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "CalendarFormatter"
        addSection(title: "当前月份") { container in
            let comps = CalendarFormatter.components()
            let label = UILabel()
            label.text = "当前: \(comps.year)年\(comps.month)月"
            label.font = .systemFont(ofSize: AppFont.sizeMd, weight: .medium)
            label.textColor = AppColor.textPrimary
            container.addSubview(label)
            label.snp.makeConstraints { make in make.edges.equalToSuperview().inset(AppSpace.md) }
        }
        addSection(title: "月份区间") { container in
            let interval = CalendarFormatter.interval(year: 2026, month: 8)
            let label = UILabel()
            label.text = "2026年8月: \(interval.start) ~ \(interval.end)"
            label.font = .systemFont(ofSize: AppFont.sizeSm)
            label.textColor = AppColor.textPrimary
            label.numberOfLines = 0
            container.addSubview(label)
            label.snp.makeConstraints { make in make.edges.equalToSuperview().inset(AppSpace.md) }
        }
    }
}

// MARK: - Basic Showcases

final class EmptyStateShowcase: ShowcaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "EmptyStateView"
        addSection(title: "默认空态") { container in
            let empty = EmptyStateView()
            container.addSubview(empty)
            empty.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.width.equalTo(200)
                make.height.equalTo(100)
            }
        }
        addSection(title: "自定义文案") { container in
            let empty = EmptyStateView()
            empty.setMessage("还没有账单记录\n点击 + 开始记账")
            container.addSubview(empty)
            empty.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.width.equalTo(250)
                make.height.equalTo(100)
            }
        }
    }
}

final class DatePickerShowcase: ShowcaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "DatePickerSheet"
        addSection(title: "日期选择器") { container in
            let button = UIButton(type: .system)
            button.setTitle("打开日期选择器", for: .normal)
            button.addTarget(self, action: #selector(openPicker), for: .touchUpInside)
            container.addSubview(button)
            button.snp.makeConstraints { make in make.edges.equalTo(container.layoutMarginsGuide) }
        }
    }

    @objc private func openPicker() {
        let picker = DatePickerSheetViewController(date: Date())
        picker.onConfirm = { date in
            self.addInfo("已选日期: \(DateFormatters.dateTimeLabel(date))")
        }
        present(picker, animated: true)
    }
}

final class MonthPickerShowcase: ShowcaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "MonthPicker"
        addSection(title: "月份选择器") { container in
            let button = UIButton(type: .system)
            button.setTitle("打开月份选择器", for: .normal)
            button.addTarget(self, action: #selector(openPicker), for: .touchUpInside)
            container.addSubview(button)
            button.snp.makeConstraints { make in make.edges.equalTo(container.layoutMarginsGuide) }
        }
    }

    @objc private func openPicker() {
        let comps = CalendarFormatter.components()
        let picker = MonthPickerViewController(year: comps.year, month: comps.month)
        picker.onConfirm = { year, month in
            self.addInfo("已选: \(year)年\(month)月")
        }
        present(picker, animated: true)
    }
}

final class YearPickerShowcase: ShowcaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "YearPicker"
        addSection(title: "年份选择器") { container in
            let button = UIButton(type: .system)
            button.setTitle("打开年份选择器", for: .normal)
            button.addTarget(self, action: #selector(openPicker), for: .touchUpInside)
            container.addSubview(button)
            button.snp.makeConstraints { make in make.edges.equalTo(container.layoutMarginsGuide) }
        }
    }

    @objc private func openPicker() {
        let comps = CalendarFormatter.components()
        let picker = YearPickerViewController(year: comps.year)
        picker.onConfirm = { year in
            self.addInfo("已选年份: \(year)")
        }
        present(picker, animated: true)
    }
}

final class OptionPickerShowcase: ShowcaseViewController {
    private let options = ["全部", "仅支出", "仅收入", "本月", "本年"]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "OptionPicker"
        addSection(title: "选项滚轮") { container in
            let button = UIButton(type: .system)
            button.setTitle("打开选项滚轮", for: .normal)
            button.addTarget(self, action: #selector(openPicker), for: .touchUpInside)
            container.addSubview(button)
            button.snp.makeConstraints { make in make.edges.equalTo(container.layoutMarginsGuide) }
        }
    }

    @objc private func openPicker() {
        let picker = OptionPickerSheetViewController(title: "筛选", options: options, selectedIndex: 0)
        picker.onConfirm = { [weak self] index in
            guard let self else { return }
            self.addInfo("已选: \(self.options[index])")
        }
        present(picker, animated: true)
    }
}

final class GroupListItemShowcase: ShowcaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "GroupListItem"
        addSection(title: "各种行样式") { container in
            let rows: [(String, String?, String?, Bool)] = [
                ("预算设置", "每月 ¥3000", nil, true),
                ("我的资产", "¥128,500.00", nil, true),
                ("家庭账单", nil, "新", true),
                ("帮助与反馈", nil, nil, false),
                ("关于", "v0.1.0", nil, false),
            ]
            var lastView: UIView? = nil
            for (title, value, badge, chevron) in rows {
                let row = GroupListItem()
                row.apply(title: title, value: value, badge: badge, showsChevron: chevron)
                container.addSubview(row)
                row.snp.makeConstraints { make in
                    make.leading.trailing.equalToSuperview()
                    if let last = lastView {
                        make.top.equalTo(last.snp.bottom)
                    } else {
                        make.top.equalToSuperview().offset(AppSpace.md)
                    }
                }
                lastView = row
            }
            lastView?.snp.makeConstraints { make in make.bottom.equalToSuperview().offset(-AppSpace.md) }
        }
    }
}

final class GroupListShowcase: ShowcaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "GroupList"
        addSection(title: "分组列表") { container in
            let group = GroupList()
            let r1 = GroupListItem()
            r1.apply(title: "本月预算", value: "¥3,000.00")
            let r2 = GroupListItem()
            r2.apply(title: "已使用", value: "¥1,250.00")
            let r3 = GroupListItem()
            r3.apply(title: "剩余", value: "¥1,750.00")
            group.setRows([r1, r2, r3])
            container.addSubview(group)
            group.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview().inset(AppSpace.md)
                make.top.bottom.equalToSuperview().inset(AppSpace.md)
            }
        }
    }
}

final class GridShowcase: ShowcaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "NavigationGrid"
        addSection(title: "九宫格入口") { container in
            let grid = NavigationGrid()
            grid.apply(title: "常用服务", items: [
                .init(title: "分类", symbolName: "tag"),
                .init(title: "预算", symbolName: "chart.pie"),
                .init(title: "账单", symbolName: "doc.text"),
                .init(title: "设置", symbolName: "gearshape"),
            ])
            grid.onSelect = { index in
                let titles = ["分类", "预算", "账单", "设置"]
                self.addInfo("点击了: \(titles[index])")
            }
            container.addSubview(grid)
            grid.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview().inset(AppSpace.md)
                make.top.bottom.equalToSuperview().inset(AppSpace.md)
            }
        }
    }
}

final class CardShowcase: ShowcaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "SummaryCard"
        addSection(title: "支出卡") { container in
            let card = SummaryCardView()
            card.apply(title: "本月支出", subtitle: "2026年8月", value: "¥3,850.00", valueColor: AppColor.expense, accessory: "预算 ¥5,000")
            container.addSubview(card)
            card.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview().inset(AppSpace.md)
                make.top.bottom.equalToSuperview().inset(AppSpace.md)
            }
        }
        addSection(title: "收入卡") { container in
            let card = SummaryCardView()
            card.apply(title: "本月收入", subtitle: "工资 + 理财", value: "¥12,000.00", valueColor: AppColor.primary, accessory: nil)
            container.addSubview(card)
            card.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview().inset(AppSpace.md)
                make.top.bottom.equalToSuperview().inset(AppSpace.md)
            }
        }
    }
}

final class TrendChartShowcase: ShowcaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "TrendChart"
        addSection(title: "支出 vs 收入趋势") { container in
            let chart = TrendChartView()
            let expense = (0..<7).map { ChartPoint(label: "W\($0+1)", amount: Double([320, 180, 450, 280, 520, 390, 210][$0])) }
            let income = (0..<7).map { ChartPoint(label: "W\($0+1)", amount: Double([1500, 0, 1500, 200, 1500, 0, 1500][$0])) }
            chart.apply(expensePoints: expense, incomePoints: income)
            container.addSubview(chart)
            chart.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview().inset(AppSpace.md)
                make.top.bottom.equalToSuperview().inset(AppSpace.md)
            }
        }
        addSection(title: "空态") { container in
            let chart = TrendChartView()
            chart.apply(expensePoints: [], incomePoints: [])
            container.addSubview(chart)
            chart.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview().inset(AppSpace.md)
                make.top.bottom.equalToSuperview().inset(AppSpace.md)
                make.height.equalTo(140)
            }
        }
    }
}

final class NavBarShowcase: ShowcaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "NavBar"
        addSection(title: "快捷导航栏") { container in
            let nav = NavBar()
            let items: [NavBar.Item] = [
                .init(title: "账单", symbolName: "doc.text"),
                .init(title: "预算", symbolName: "chart.pie"),
                .init(title: "资产", symbolName: "building.columns"),
                .init(title: "家庭", symbolName: "person.2"),
                .init(title: "更多", symbolName: "ellipsis.circle"),
            ]
            nav.apply(items: items)
            nav.onSelect = { index in
                let titles = ["账单", "预算", "资产", "家庭", "更多"]
                self.addInfo("点击了: \(titles[index])")
            }
            container.addSubview(nav)
            nav.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview()
                make.height.equalTo(64)
                make.top.bottom.equalToSuperview()
            }
        }
    }
}

final class TabsShowcase: ShowcaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Tabs"
        addSection(title: "支出/收入切换") { container in
            let sv = TabsView(titles: ["支出", "收入"])
            sv.onSelect = { index in self.addInfo("切换到: \(index == 0 ? "支出" : "收入")") }
            container.addSubview(sv)
            sv.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview().inset(AppSpace.md)
                make.top.bottom.equalToSuperview().inset(AppSpace.md)
            }
        }
    }
}

// MARK: - Refresh Showcase

final class RefreshShowcase: ShowcaseViewController, UITableViewDataSource {
    private var rows = (1...12).map { "初始数据第 \($0) 条" }
    private let tableView = PullRefreshTableView(frame: .zero, style: .plain)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "PullRefreshTableView"

        addSection(title: "下拉刷新列表") { container in
            tableView.backgroundColor = .white
            tableView.separatorStyle = .none
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "row")
            tableView.dataSource = self
            tableView.onRefresh = { [weak self] in
                guard let self else { return }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                    guard let self else { return }
                    self.rows = (1...12).map { "刷新后第 \($0) 条 · \(Date().timeIntervalSince1970)" }
                    self.tableView.reloadData()
                    self.tableView.endRefreshing()
                    self.addInfo("刷新完成（模拟 1s 网络延迟）")
                }
            }
            container.addSubview(tableView)
            tableView.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview().inset(AppSpace.md)
                make.top.bottom.equalToSuperview().inset(AppSpace.md)
                make.height.equalTo(420)
            }
        }

        addInfo("下拉列表顶部露出灰圈刷新指示，松手触发 onRefresh；业务完成后调用 endRefreshing() 收起。")
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { rows.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "row", for: indexPath)
        cell.textLabel?.text = rows[indexPath.row]
        cell.textLabel?.font = .systemFont(ofSize: AppFont.sizeSm)
        return cell
    }
}

// MARK: - Foundation Showcases (Storage & Network)

final class StorageShowcase: ShowcaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "AppDatabase"

        addSection(title: "建库与迁移") { container in
            let label = UILabel()
            label.text = "准备中…"
            label.font = .systemFont(ofSize: AppFont.sizeSm)
            label.textColor = AppColor.textPrimary
            label.numberOfLines = 0
            container.addSubview(label)
            label.snp.makeConstraints { make in make.edges.equalToSuperview().inset(AppSpace.md) }

            DispatchQueue.global().async { [weak self] in
                do {
                    try AppDatabase.shared.prepare()
                    let baseDir = try FileManager.default.url(
                        for: .applicationSupportDirectory, in: .userDomainMask,
                        appropriateFor: nil, create: true
                    )
                    let dbURL = baseDir.appendingPathComponent("KeepAccounts", isDirectory: true)
                        .appendingPathComponent("ledger.sqlite")
                    DispatchQueue.main.async { [weak self] in
                        label.text = "数据库就绪\n\(dbURL.path)"
                        self?.addInfo("已注册迁移：transactions / budgets / asset_accounts / category_budgets")
                    }
                } catch {
                    DispatchQueue.main.async {
                        label.text = "建库失败：\(error.localizedDescription)"
                    }
                }
            }
        }
    }
}

final class NetworkShowcase: ShowcaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "MockAPIClient"

        addSection(title: "GET /health") { container in
            let button = UIButton(type: .system)
            button.setTitle("发起请求", for: .normal)
            button.addTarget(self, action: #selector(fireHealth), for: .touchUpInside)
            container.addSubview(button)
            button.snp.makeConstraints { make in make.edges.equalTo(container.layoutMarginsGuide) }
        }

        addInfo("当前基址为 Mock（https://mock.keep-accounts.local），真实环境需替换 APIEnvironment 注入。")
    }

    @objc private func fireHealth() {
        let task = Task {
            do {
                let health = try await MockAPIClient.shared.getHealth()
                addInfo("成功：\(health.status) · \(health.service)")
            } catch {
                addInfo("失败：\(error.localizedDescription)")
            }
        }
        addInfo("已发起请求…")
        _ = task
    }
}

final class WebViewShowcase: ShowcaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "WebContent"
        addSection(title: "打开 H5 页面") { container in
            let button = UIButton(type: .system)
            button.setTitle("打开示例网页", for: .normal)
            button.addTarget(self, action: #selector(openWeb), for: .touchUpInside)
            container.addSubview(button)
            button.snp.makeConstraints { make in make.edges.equalTo(container.layoutMarginsGuide) }
        }
    }

    @objc private func openWeb() {
        let vc = WebContentViewController(title: "示例", url: URL(string: "https://www.apple.com")!)
        navigationController?.pushViewController(vc, animated: true)
    }
}