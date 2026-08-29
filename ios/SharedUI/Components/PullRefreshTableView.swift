/// 下拉刷新列表（封装 UIRefreshControl，对标 Android IosStylePullRefresh）。

import UIKit
import SnapKit

/// 支持下拉刷新的 UITableView。
///
/// 语义对齐 Android `IosStylePullRefresh`：
/// 下拉顶开列表顶部露出灰圈刷新指示，松手触发 `onRefresh` 回调，
/// 业务侧完成后调用 `endRefreshing()` 收起。
final class PullRefreshTableView: UITableView {

    /// 下拉松手后的刷新回调。
    var onRefresh: (() -> Void)?

    /// 是否允许下拉刷新（默认 true）。
    var canPull: Bool = true {
        didSet { refreshControl?.isEnabled = canPull }
    }

    /// 刷新指示文案。
    var refreshTitle: String = "下拉刷新数据" {
        didSet { applyTitle() }
    }

    private let refresh = UIRefreshControl()

    /// 搭建下拉刷新列表。
    ///
    /// - Parameters:
    ///   - frame: 初始 frame
    ///   - style: 表格样式，默认 `.plain`
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        refresh.tintColor = AppColor.textSecondary
        refresh.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        applyTitle()
        refreshControl = refresh
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    /// 结束刷新动画并收起指示器。
    func endRefreshing() {
        refresh.endRefreshing()
    }

    /// 刷新指示器是否正在刷新。
    var isRefreshing: Bool { refresh.isRefreshing }

    /// 处理下拉松手事件。
    @objc private func handleRefresh() {
        onRefresh?()
    }

    /// 同步刷新文案到指示器。
    private func applyTitle() {
        refresh.attributedTitle = NSAttributedString(
            string: refreshTitle,
            attributes: [.font: UIFont.systemFont(ofSize: AppFont.sizeXs),
                         .foregroundColor: AppColor.textSecondary]
        )
    }
}
