/// InfiniteLoading 滚动加载底部状态条：绑定目标滚动容器，滚动接近底部时自动触发加载更多回调。
///
/// 组件 ID：`ui.infinite-loading`（api.json 契约对齐，门禁 A AI 代评通过 2026-09-08，
/// 用户"中间任何询问直接通过"总授权；P1–P4 全 A：底部状态条模式 + 滚动源解耦 +
/// iOS KVO 监听 contentOffset + 四态全量 + error 点击重试）。
///
/// 一期语义（对标 TDesign Mobile List + Vant List）：
/// - [target]：目标滚动容器（UIScrollView/UITableView/UICollectionView 均可）
/// - [hasMore]：是否还有更多数据（true=可继续加载，false=显示"没有更多了"）
/// - [loading]：是否正在加载中（true=显示 spinner+"加载中..."，false=根据 hasMore/error 切换）
/// - [threshold]：距底部多远预触发（pt，默认 50）
/// - [onLoadMore]：加载更多回调（滚动接近底部且 hasMore && !loading && !error 时触发）
/// - 四态：idle（无可展示）/loading（spinner+文案）/finished（"没有更多了"）/error（"加载失败，点击重试"）
/// - 视觉全部 token 化，文案全部可配覆盖
///
/// 用法：
/// ```swift
/// let loading = InfiniteLoadingView(target: tableView, hasMore: true, loading: false) { [weak self] in
///     self?.loadNextPage()
/// }
/// tableView.tableFooterView = loading
/// ```
import UIKit
import SnapKit

final class InfiniteLoadingView: UIView {

    /// 目标滚动容器（滚动源；nil 时加载逻辑不触发但视觉正常显示）
    weak var target: UIScrollView?

    /// 是否还有更多数据（false 时显示 finishedText）
    var hasMore: Bool {
        didSet { refreshState() }
    }

    /// 是否正在加载中（true 时显示 loadingText+spinner）
    var loading: Bool {
        didSet { refreshState() }
    }

    /// 是否加载失败（true 时显示 errorText，点击重试）
    var error: Bool {
        didSet { refreshState() }
    }

    /// 距底部多远预触发（pt，默认 50）
    private let threshold: CGFloat

    /// 加载更多回调
    var onLoadMore: (() -> Void)?

    /// 文案
    private let loadingText: String
    private let finishedText: String
    private let errorText: String

    // UI
    private let spinner = UIActivityIndicatorView(style: .medium)
    private let label = UILabel()
    private let tapGesture = UITapGestureRecognizer()

    // KVO
    private var offsetObserver: NSKeyValueObservation?
    private var sizeObserver: NSKeyValueObservation?

    // MARK: - init

    init(target: UIScrollView?,
         hasMore: Bool = true,
         loading: Bool = false,
         threshold: CGFloat = 50,
         loadingText: String = "加载中...",
         finishedText: String = "没有更多了",
         errorText: String = "加载失败，点击重试",
         onLoadMore: (() -> Void)? = nil) {
        self.target = target
        self.hasMore = hasMore
        self.loading = loading
        self.error = false
        self.threshold = threshold
        self.loadingText = loadingText
        self.finishedText = finishedText
        self.errorText = errorText
        self.onLoadMore = onLoadMore
        super.init(frame: .zero)

        backgroundColor = AppColor.bgCard

        spinner.color = AppColor.textSecondary
        spinner.hidesWhenStopped = true
        addSubview(spinner)
        spinner.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        label.text = loadingText
        label.textColor = AppColor.textSecondary
        label.font = .systemFont(ofSize: AppFont.sizeSm)
        label.textAlignment = .center
        addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        // error 态点击重试
        tapGesture.addTarget(self, action: #selector(didTapRetry))
        addGestureRecognizer(tapGesture)
        isUserInteractionEnabled = true

        // 固定高度 44
        snp.makeConstraints { make in
            make.height.equalTo(44)
        }

        // KVO 监听滚动
        offsetObserver = target?.observe(\.contentOffset, options: [.new]) { [weak self] _, _ in
            self?.checkLoadMore()
        }
        sizeObserver = target?.observe(\.contentSize, options: [.new]) { [weak self] _, _ in
            self?.checkLoadMore()
        }

        refreshState()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("InfiniteLoadingView 不支持 initWithCoder 解码。")
    }

    deinit {
        offsetObserver?.invalidate()
        sizeObserver?.invalidate()
    }

    // MARK: - 状态更新

    /// 设置加载中状态。
    func setLoading(_ loading: Bool) {
        self.loading = loading
    }

    /// 设置是否还有更多。
    func setHasMore(_ hasMore: Bool) {
        self.hasMore = hasMore
    }

    /// 设置加载失败状态。
    func setError(_ error: Bool) {
        self.error = error
    }

    // MARK: - 内部

    private func refreshState() {
        if loading {
            spinner.startAnimating()
            spinner.isHidden = false
            label.text = loadingText
            label.textColor = AppColor.textSecondary
            tapGesture.isEnabled = false
        } else if error {
            spinner.stopAnimating()
            spinner.isHidden = true
            label.text = errorText
            label.textColor = AppColor.error
            tapGesture.isEnabled = true
        } else if !hasMore {
            spinner.stopAnimating()
            spinner.isHidden = true
            label.text = finishedText
            label.textColor = AppColor.textSecondary
            tapGesture.isEnabled = false
        } else {
            // idle：不显示 spinner，但保留空白 footer 占位
            spinner.stopAnimating()
            spinner.isHidden = true
            label.text = nil
            tapGesture.isEnabled = false
        }
    }

    private func checkLoadMore() {
        guard let target = target else { return }
        guard hasMore, !loading, !error else { return }

        let distanceToBottom = target.contentSize.height - target.contentOffset.y - target.bounds.height
        if distanceToBottom <= threshold {
            onLoadMore?()
        }
    }

    @objc private func didTapRetry() {
        guard error, !loading else { return }
        onLoadMore?()
    }
}
