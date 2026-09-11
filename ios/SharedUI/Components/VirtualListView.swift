/// VirtualList 虚拟列表组件（UIKit 版，对齐 Android VirtualList）。
///
/// 大数据量虚拟滚动列表：仅渲染可见区域 cell，支持分隔线、点击回调、空态。
/// 底层使用 UITableView（UIKit 内置 cell 复用），万级数据不卡顿。

import UIKit
import SnapKit

/// 虚拟列表数据源。
struct VirtualListItem {
    let title: String
    var subtitle: String?
}

/// 虚拟列表组件。
final class VirtualListView: UIView {
    // MARK: - 配置

    var items: [VirtualListItem] = [] { didSet { tableView.reloadData() } }
    var onItemClick: ((Int) -> Void)?
    var showSeparator: Bool = true { didSet { tableView.separatorStyle = showSeparator ? .singleLine : .none } }
    var emptyText: String = "暂无数据" { didSet { updateEmpty() } }

    // MARK: - 子视图

    private let tableView = UITableView()
    private let emptyLabel = UILabel()

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        backgroundColor = AppColor.bgPage

        // 空态
        emptyLabel.textAlignment = .center
        emptyLabel.textColor = AppColor.textSecondary
        emptyLabel.font = .systemFont(ofSize: AppFont.sizeSm)
        addSubview(emptyLabel)
        emptyLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        // 表格
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.separatorColor = AppColor.border
        tableView.backgroundColor = AppColor.bgPage
        addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        updateEmpty()
    }

    private func updateEmpty() {
        emptyLabel.text = emptyText
        emptyLabel.isHidden = !items.isEmpty
        tableView.isHidden = items.isEmpty
    }
}

// MARK: - UITableViewDataSource

extension VirtualListView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item = items[indexPath.row]

        cell.backgroundColor = AppColor.bgCard
        cell.selectionStyle = .none

        // 清除旧子视图
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }

        let titleLabel = UILabel()
        titleLabel.text = item.title
        titleLabel.textColor = AppColor.textPrimary
        titleLabel.font = .systemFont(ofSize: AppFont.sizeMd, weight: .medium)
        titleLabel.lineBreakMode = .byTruncatingTail
        cell.contentView.addSubview(titleLabel)

        if let subtitle = item.subtitle {
            let subtitleLabel = UILabel()
            subtitleLabel.text = subtitle
            subtitleLabel.textColor = AppColor.textSecondary
            subtitleLabel.font = .systemFont(ofSize: AppFont.sizeSm)
            subtitleLabel.lineBreakMode = .byTruncatingTail
            cell.contentView.addSubview(subtitleLabel)

            titleLabel.snp.makeConstraints { make in
                make.leading.equalToSuperview().offset(AppSpace.lg)
                make.trailing.equalToSuperview().offset(-AppSpace.lg)
                make.top.equalToSuperview().offset(AppSpace.sm + 2)
            }
            subtitleLabel.snp.makeConstraints { make in
                make.leading.equalTo(titleLabel)
                make.trailing.equalTo(titleLabel)
                make.top.equalTo(titleLabel.snp.bottom).offset(2)
                make.bottom.equalToSuperview().offset(-AppSpace.sm - 2)
            }
        } else {
            titleLabel.snp.makeConstraints { make in
                make.leading.equalToSuperview().offset(AppSpace.lg)
                make.trailing.equalToSuperview().offset(-AppSpace.lg)
                make.centerY.equalToSuperview()
            }
        }

        return cell
    }
}

// MARK: - UITableViewDelegate

extension VirtualListView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        items[indexPath.row].subtitle != nil ? 64 : 48
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        onItemClick?(indexPath.row)
    }
}
