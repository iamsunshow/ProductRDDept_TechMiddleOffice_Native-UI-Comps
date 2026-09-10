/// PullToRefresh 下拉刷新（UIKit 版，对齐 Android PullToRefresh.kt / api.json `ui.refresh`）。
///
/// 组件 ID：`ui.refresh` ｜ 任务清单 #55 ｜ 操作反馈区第十一件 ｜ TMO 组件库 v1.4.13
///
/// 定位：列表/可滚动内容下拉触发刷新的容器组件——用户在内容顶部下拉，露出刷新指示器（灰圈+文案），
/// 松手达到阈值触发 onRefresh 回调，业务完成后将 refreshing 设为 false 收起指示器。
///
/// 契约 props（与 api.json 100% 对齐）：
/// - refreshing: Bool（*必选*：true=显示刷新指示器（旋转中），false=收起）
/// - content: UIScrollView（*必选*：可滚动内容，宿主提供 UITableView/UICollectionView/UIScrollView）
/// - title: String（默认 "下拉刷新数据"：刷新文案）
/// - enabled: Bool（默认 true：是否允许下拉刷新）
///
/// 事件：
/// - onRefresh: () -> Void（下拉达到阈值松手时触发）
///
/// 设计规格（design-spec/refresh-design-spec.html）：
/// - 指示器：UIRefreshControl 系统原生，灰圈+文案，color=textSecondary
/// - 文案：textSecondary + sizeXs
/// - 触发阈值/动画：UIRefreshControl 系统处理
///
/// 用法：
/// ```swift
/// let tableView = UITableView()
/// let pullRefresh = PullRefreshView(content: tableView)
/// pullRefresh.onRefresh = { [weak self] in
///     self?.loadData()
///     self?.pullRefresh.refreshing = false  // 业务完成后收起
/// }
/// pullRefresh.refreshing = true  // 外部驱动刷新
/// ```

import UIKit
import SnapKit

/// 下拉刷新容器组件。
public final class PullRefreshView: UIView {

    // MARK: - Props

    /// 受控刷新状态：true=显示刷新指示器，false=收起。
    public var refreshing: Bool = false {
        didSet {
            guard refreshing != oldValue else { return }
            if refreshing {
                // UIRefreshControl.beginRefreshing() 在 scrollview 未被用户交互过时不显示指示器，
                // 需手动偏移 contentOffset 让指示器进入可视区域（iOS 已知行为根治）
                contentScrollView.layoutIfNeeded()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
                    guard let self = self, self.refreshing else { return }
                    let rcHeight = self.refreshControl.bounds.height
                    if rcHeight > 0 && self.contentScrollView.contentOffset.y == 0 {
                        self.contentScrollView.setContentOffset(
                            CGPoint(x: 0, y: -rcHeight), animated: true
                        )
                    }
                    self.refreshControl.beginRefreshing()
                }
            } else {
                refreshControl.endRefreshing()
                // 恢复 contentOffset（外部驱动结束后 scrollview 回到顶部）
                if contentScrollView.contentOffset.y < 0 {
                    contentScrollView.setContentOffset(.zero, animated: true)
                }
            }
        }
    }

    /// 刷新文案，默认 "下拉刷新数据"。
    public var title: String = "下拉刷新数据" {
        didSet { applyTitle() }
    }

    /// 是否允许下拉刷新，默认 true。false 时移除 refreshControl 真正禁用下拉手势。
    public var enabled: Bool = true {
        didSet {
            if enabled {
                contentScrollView.refreshControl = refreshControl
            } else {
                contentScrollView.refreshControl = nil
            }
        }
    }

    /// 下拉触发刷新回调。
    public var onRefresh: (() -> Void)?

    // MARK: - 子视图

    private let refreshControl = UIRefreshControl()
    private let contentScrollView: UIScrollView

    // MARK: - Init

    /// 初始化下拉刷新容器。
    /// - Parameter content: 可滚动内容（UITableView/UICollectionView/UIScrollView）。
    public init(content: UIScrollView) {
        self.contentScrollView = content
        super.init(frame: .zero)
        setupViews()
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupViews() {
        backgroundColor = .clear

        // 内容滚动视图
        addSubview(contentScrollView)
        contentScrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // 刷新控件
        refreshControl.tintColor = AppColor.textSecondary
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        contentScrollView.refreshControl = refreshControl

        applyTitle()
    }

    // MARK: - Actions

    @objc private func handleRefresh() {
        onRefresh?()
    }

    // MARK: - Private

    private func applyTitle() {
        refreshControl.attributedTitle = NSAttributedString(
            string: title,
            attributes: [
                .font: UIFont.systemFont(ofSize: AppFont.sizeXs),
                .foregroundColor: AppColor.textSecondary
            ]
        )
    }
}
