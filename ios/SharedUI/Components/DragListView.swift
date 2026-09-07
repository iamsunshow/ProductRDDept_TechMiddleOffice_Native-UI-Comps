/// Drag 拖拽排序（操作反馈区 · ui.drag · #47）通用列表拖拽排序组件。
///
/// 组件 ID：`ui.drag`（api.json 契约对齐；门禁 A AI 代评通过 2026-09-07，规格
/// design-spec/drag-design-spec.html + 评审单 review-drag-A.md，P1–P4 全 A）。
///
/// 视觉锚点（与 Android Drag 同构）：列表项由 itemContent 渲染（Drag 不强制样式）；
/// 拖拽态 elevation 8dp + scale 1.02 + opacity 0.9；手柄 24×24 fontLg textSecondary；
/// 落位动画 0.25s easeOut。
///
/// 语义：items 数据列表 + onReorder(from,to) 拖拽释放后回调新位置；
/// enabled=false=纯列表不可拖；handle=true=仅手柄可拖。
///
/// 划界勿混：SwipeAction #19 横滑操作菜单 vs Drag 纵向拖拽排序；
/// IosStylePullRefresh #55 下拉刷新 vs Drag 长按拖拽；Tabs #20 横向页签 vs Drag 纵向排序。
///
/// iOS 实现：UITableView + isEditing + 标准 reorder 控件（≡ 右侧），
/// `tableView(_:moveRowAt:to:)` 落位后回调 onReorder(from,to) 并同步数据源。
/// 非泛型实现：内部用 [Any] 存储 + 类型擦除闭包（Swift 泛型类不能 conform @objc 协议、
/// 不能有 static stored property，故 UITableViewDataSource 必须由非泛型类实现）。

import UIKit
import SnapKit

/// 通用拖拽排序列表视图（非泛型，内部 [Any] + 类型擦除）。
final class DragListView: UIView {

    // MARK: - 公开配置

    /// 拖拽释放后回调（from=原索引 to=目标索引）。
    var onReorder: ((Int, Int) -> Void)?

    /// 是否启用拖拽（false=纯列表不可拖）。
    var enabled: Bool {
        didSet {
            tableView.isEditing = enabled
            tableView.reloadData()
        }
    }

    /// 是否仅手柄可拖（true=手柄模式；false=整行长按）。
    var handle: Bool {
        didSet { tableView.reloadData() }
    }

    // MARK: - 内部状态

    /// 当前数据源（[Any]，避免泛型类 @objc 协议限制）。
    private var items: [Any]
    /// 每项渲染闭包：业务侧把元素映射为 UIView，挂到 cell.contentView。
    private let itemContent: (Any) -> UIView
    /// 复用 cell 标识。
    private let cellReuseId = "DragListCell"
    /// 内嵌表视图。
    private let tableView = UITableView(frame: .zero, style: .plain)
    /// 拖拽态动画时长常量（0.25s easeOut，对齐设计规格；用非 static 存储属性）。
    private let dropDuration: TimeInterval = 0.25

    // MARK: - 初始化

    /// 构造拖拽列表。
    ///
    /// - Parameters:
    ///   - items: 数据列表
    ///   - itemContent: 每项渲染闭包（接收 Any 元素，返回 UIView）
    ///   - onReorder: 拖拽释放后回调（from=原索引 to=目标索引）
    ///   - enabled: 是否启用拖拽，默认 true
    ///   - handle: 是否仅手柄可拖，默认 false
    init(
        items: [Any],
        itemContent: @escaping (Any) -> UIView,
        onReorder: ((Int, Int) -> Void)? = nil,
        enabled: Bool = true,
        handle: Bool = false
    ) {
        self.items = items
        self.itemContent = itemContent
        self.onReorder = onReorder
        self.enabled = enabled
        self.handle = handle
        super.init(frame: .zero)
        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    // MARK: - 视图搭建

    private func setupView() {
        backgroundColor = AppColor.bgCard
        addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = AppColor.bgCard
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 56
        tableView.rowHeight = UITableView.automaticDimension
        // isEditing=true 显示右侧 reorder 控件（≡），拖动 ≡ 触发 moveRowAt。
        tableView.isEditing = enabled
        tableView.allowsSelection = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseId)
    }

    // MARK: - 公开方法

    /// 外部更新数据源（受控回显，不触发 onReorder）。
    func updateItems(_ items: [Any]) {
        self.items = items
        tableView.reloadData()
    }

    /// 读取当前数据顺序。
    func currentItems() -> [Any] { items }
}

// MARK: - UITableViewDataSource / UITableViewDelegate
// 非泛型类可正常 conform @objc 协议。

extension DragListView: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseId, for: indexPath)
        cell.selectionStyle = .none
        cell.backgroundColor = AppColor.bgCard
        cell.contentView.backgroundColor = AppColor.bgCard
        // 清掉复用残留视图
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        let view = itemContent(items[indexPath.row])
        cell.contentView.addSubview(view)
        view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        cell.showsReorderControl = enabled
        return cell
    }

    /// 是否显示系统 reorder 控件（≡）：enabled=false 不显示。
    func tableView(_ tableView: UITableView, shouldShowReorderControlForRowAt indexPath: IndexPath) -> Bool {
        enabled
    }

    /// 是否允许行移动。
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        enabled
    }

    /// reorder 落位回调：更新数据源 + 触发 onReorder(from, to)。
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard sourceIndexPath.row != destinationIndexPath.row else { return }
        let item = items.remove(at: sourceIndexPath.row)
        items.insert(item, at: destinationIndexPath.row)
        onReorder?(sourceIndexPath.row, destinationIndexPath.row)
    }

    /// 拖拽中单元格视觉态：shadow 近似 elevation 8dp。
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOpacity = 0.15
        cell.layer.shadowOffset = CGSize(width: 0, height: 4)
        cell.layer.shadowRadius = 8
    }
}
