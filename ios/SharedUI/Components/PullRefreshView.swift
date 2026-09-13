/// PullToRefresh 下拉刷新（UIKit 版，对齐 Android PullToRefresh.kt / api.json `ui.refresh`）。
///
/// 组件 ID：`ui.refresh` ｜ 任务清单 #55 ｜ 操作反馈区第十一件 ｜ TMO 组件库 v1.9.28
///
/// 定位：列表/可滚动内容下拉触发刷新的容器组件——用户在内容顶部下拉，顶开内容露出刷新指示器
/// （圆环+文案），松手达到阈值触发 onRefresh 回调，业务完成后将 refreshing 设为 false 收起指示器。
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
/// 设计规格（docs/数据与产物/design-spec/refresh-design-spec.html）：
/// - 指示器：圆环，22×22，strokeWidth = 2，color = textSecondary
///   - 下拉中=进度环（弧长 = 下拉距离 / threshold × 360°，起点 12 点方向，圆头线帽，不旋转）
///   - 刷新中=270° 缺口圆环绕圆心旋转（0.8s/圈线性）
/// - 文案：textSecondary + sizeSm（14），与圆环间距 6，下拉 > 15% 阈值或刷新中显示
/// - 下拉顶开高度 threshold=56pt、刷新停留 hold=48pt（与 Android 同参数）
/// - 手势/触发：仍由 UIRefreshControl 系统处理（与 Android NestedScrollConnection 语义对齐）
///
/// v1.9.28：指示器由「UIRefreshControl 系统菊花 + attributedTitle」改为自绘 RefreshIndicatorView
/// （圆环 + 文案）。根因=系统菊花与 Android 指示器形状不同（Android 侧曾用 8 圆点模拟菊花），
/// 双端 loading icon 不一致（用户 2026-09-13 反馈）。自绘后双端几何参数逐字同构，视觉 1:1。
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
///
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
                    self.updateIndicatorLayout()
                }
            } else {
                refreshControl.endRefreshing()
                // 恢复 contentOffset（外部驱动结束后 scrollview 回到顶部）
                if contentScrollView.contentOffset.y < 0 {
                    contentScrollView.setContentOffset(.zero, animated: true)
                }
                updateIndicatorLayout()
            }
        }
    }

    /// 刷新文案，默认 "下拉刷新数据"。
    public var title: String = "下拉刷新数据" {
        didSet { indicator.title = title }
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
    /// 自绘刷新指示器（圆环+文案，与 Android `RefreshRingIndicator` 同构）。
    private let indicator = RefreshIndicatorView()

    // MARK: - 常量（与 Android PullToRefresh.kt 同参数）

    /// 下拉顶开高度：进度环满圈（progress=1）对应的下拉距离。
    private let threshold: CGFloat = 56
    /// 刷新停留高度：refreshing=true 时指示器至少停留的高度。
    private let hold: CGFloat = 48

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

    deinit {
        contentScrollView.removeObserver(
            self, forKeyPath: #keyPath(UIScrollView.contentOffset)
        )
    }

    // MARK: - Setup

    private func setupViews() {
        backgroundColor = .clear

        // 内容滚动视图
        addSubview(contentScrollView)
        contentScrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // 刷新控件只保留「下拉手势 + 阈值触发」能力，视觉交给自绘指示器：
        // tintColor=.clear 隐藏系统菊花（形状与 Android 圆环不一致，v1.9.28 起不再使用）
        refreshControl.tintColor = .clear
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        contentScrollView.refreshControl = refreshControl
        contentScrollView.addObserver(
            self, forKeyPath: #keyPath(UIScrollView.contentOffset), options: [.new], context: nil
        )

        // 顶开模式：指示器覆盖在内容上方，占满露出的空白区（背景 bgCard 与 Android 一致）
        indicator.isUserInteractionEnabled = false
        indicator.backgroundColor = AppColor.bgCard
        indicator.title = title
        indicator.isHidden = true
        addSubview(indicator)
    }

    // MARK: - Layout

    public override func layoutSubviews() {
        super.layoutSubviews()
        updateIndicatorLayout()
    }

    /// 按当前 contentOffset 计算露出高度与下拉进度，刷新指示器。
    ///
    /// 对齐 Android PullToRefresh.kt：露出高度 = 下拉距离（刷新中至少 hold），
    /// 指示器在该区域内垂直+水平居中；下拉进度 > 15% 或刷新中才显示文案。
    private func updateIndicatorLayout() {
        let pulled = max(0, -contentScrollView.contentOffset.y)
        let height = refreshing ? max(pulled, hold) : pulled
        guard height > 0.5 else {
            indicator.isHidden = true
            return
        }
        indicator.isHidden = false
        indicator.frame = CGRect(x: 0, y: 0, width: bounds.width, height: height)

        let pullProgress = min(1, pulled / threshold)
        indicator.progress = pullProgress
        // 与 Android 判据一致：刷新中，或已拉满阈值（progress >= 1）= 270° 缺口环旋转态
        indicator.spinning = refreshing || pullProgress >= 1
        indicator.titleVisible = refreshing || pullProgress > 0.15
    }

    // MARK: - KVO

    public override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey: Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        guard keyPath == #keyPath(UIScrollView.contentOffset) else { return }
        updateIndicatorLayout()
    }

    // MARK: - Actions

    @objc private func handleRefresh() {
        onRefresh?()
    }
}

/// 刷新指示器：圆环 + 文案（垂直居中），与 Android `RefreshRingIndicator` 逐参数同构。
///
/// - 下拉中：圆环按 `progress`（0..1）增长为进度环，恒 0° 不旋转
/// - 刷新中：270° 缺口圆环绕圆心旋转（0.8s/圈线性）
private final class RefreshIndicatorView: UIView {

    // MARK: - 尺寸常量（与 Android 22.dp / 2.dp / 6.dp 1:1）

    private let ringSize: CGFloat = 22
    private let ringStroke: CGFloat = 2
    private let ringTitleSpacing: CGFloat = 6

    // MARK: - 子视图

    private let ringView = UIView()
    private let ringLayer = CAShapeLayer()
    private let label = UILabel()
    private let stack = UIStackView()

    // MARK: - 状态

    /// 下拉进度 0..1（刷新中不生效，走 270° 缺口环旋转）。
    var progress: CGFloat = 0 {
        didSet { updateRing() }
    }

    /// 是否刷新中。
    var spinning: Bool = false {
        didSet {
            guard spinning != oldValue else { return }
            updateSpin()
        }
    }

    /// 刷新文案（空=不显示）。
    var title: String = "" {
        didSet {
            label.text = title
            updateTitleVisibility()
        }
    }

    /// 文案是否可见（下拉 > 15% 阈值或刷新中）。
    var titleVisible: Bool = true {
        didSet {
            guard titleVisible != oldValue else { return }
            updateTitleVisibility()
        }
    }

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        // 圆环层：描边圆（无填充），线帽圆头，起始 12 点方向
        ringLayer.fillColor = nil
        ringLayer.strokeColor = AppColor.textSecondary.cgColor
        ringLayer.lineWidth = ringStroke
        ringLayer.lineCap = .round
        ringLayer.strokeStart = 0
        ringLayer.strokeEnd = 0
        ringView.layer.addSublayer(ringLayer)

        // 文案：textSecondary + sizeSm（14），与 Android Text(sizeSm/textSecondary) 一致
        label.font = .systemFont(ofSize: AppFont.sizeSm)
        label.textColor = AppColor.textSecondary
        label.textAlignment = .center

        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = ringTitleSpacing
        stack.addArrangedSubview(ringView)
        stack.addArrangedSubview(label)
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        ringView.snp.makeConstraints { make in
            make.size.equalTo(ringSize)
        }
        stack.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        updateTitleVisibility()
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        ringLayer.frame = ringView.bounds
        updateRingPath()
    }

    // MARK: - Private

    /// 圆环路径：完整圆（-90° → 270° 顺时针），弧长由 strokeEnd 控制。
    private func updateRingPath() {
        let side = min(ringView.bounds.width, ringView.bounds.height)
        guard side > ringStroke else { return }
        let radius = side / 2 - ringStroke / 2
        let center = CGPoint(x: ringView.bounds.midX, y: ringView.bounds.midY)
        // 起始 -90°（12 点方向），顺时针画满一圈；与 Android drawArc(-90°, progress × 360°) 同构
        let path = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: -.pi / 2,
            endAngle: .pi * 1.5,
            clockwise: true
        )
        ringLayer.path = path.cgPath
    }

    /// 下拉进度环：strokeEnd = progress。
    private func updateRing() {
        updateRingPath()
        guard !spinning else { return }
        ringLayer.strokeEnd = progress
    }

    /// 刷新中：270° 缺口环（strokeEnd = 0.75）+ 绕圆心 0.8s/圈线性旋转。
    private func updateSpin() {
        if spinning {
            ringLayer.strokeEnd = 0.75
            let rotation = CABasicAnimation(keyPath: "transform.rotation.z")
            rotation.fromValue = 0
            rotation.toValue = 2 * Double.pi
            rotation.duration = 0.8
            rotation.repeatCount = .infinity
            rotation.isRemovedOnCompletion = false
            ringLayer.add(rotation, forKey: "refreshRingSpin")
        } else {
            ringLayer.removeAnimation(forKey: "refreshRingSpin")
            ringLayer.strokeEnd = progress
        }
    }

    private func updateTitleVisibility() {
        // 空文案恒隐藏（对齐 Android title.isEmpty() 时不显示文案）
        label.isHidden = title.isEmpty || !titleVisible
    }
}
