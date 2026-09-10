/// Carousel 轮播（UIKit 版，对齐 Android Carousel.kt / api.json `ui.carousel`）。
///
/// 组件 ID：`ui.carousel` ｜ 任务清单 #59 ｜ 信息展示区 ｜ TMO 组件库 v1.4.20
///
/// 定位：横向分页轮播容器——items 数组驱动内容，支持自动播放 / 循环 / 指示器 / 手动滑动，
/// 用于首页 Banner、活动推荐、商品图集等横向翻页展示。对标 Vant Swipe / NutUI Carousel。
///
/// 契约 props（与 api.json 100% 对齐）：
/// - items: [UIView]               轮播内容数组（每项为任意 UIView，至少 1 项）
/// - autoPlay: Bool = true         是否自动播放
/// - duration: TimeInterval = 3.0  自动播放间隔（秒，对应 api.json 3000ms）
/// - loop: Bool = true             是否循环轮播（末张→首张无缝衔接）
/// - showIndicators: Bool = true   是否显示底部指示器
/// - indicatorColor: UIColor = AppColor.primary  指示器高亮色
/// - onChange: ((Int) -> Void)?    索引变化回调
///
/// 设计规格（design-spec/carousel-design-spec.html）：
/// - 容器默认高度 200pt，圆角 radiusMd(10)
/// - 指示器 8×8 圆形，间距 spaceSm(8)，底部居中距底 8
/// - 当前指示器 indicatorColor，其他 indicatorColor.withAlphaComponent(0.3)
/// - 滑动 300ms ease-in-out，自动播放间隔 3000ms
///
/// 用法：
/// ```swift
/// let carousel = CarouselView()
/// carousel.items = [view1, view2, view3]
/// carousel.onChange = { idx in print("当前页：\(idx)") }
/// ```

import UIKit
import SnapKit

/// 横向分页轮播容器（UIKit + UICollectionView isPagingEnabled）。
public final class CarouselView: UIView {

    // MARK: - 常量

    private enum Layout {
        static let defaultHeight: CGFloat = 200            // 容器默认高度 200pt
        static let containerRadius: CGFloat = AppRadius.md // 容器圆角 10
        static let indicatorSize: CGFloat = 8              // 指示器圆点 8×8
        static let indicatorSpacing: CGFloat = AppSpace.sm // 指示器间距 8
        static let indicatorBottomInset: CGFloat = AppSpace.sm // 距底 8
        static let loopRepeatFactor = 10_000               // 循环假倍数（中段起始，安全且近似无限）
    }

    // MARK: - Props

    /// 轮播内容数组（每项为任意 UIView）。
    public var items: [UIView] = [] {
        didSet {
            rebuildIndicators()
            collectionView.reloadData()
            resetToStartPosition()
        }
    }

    /// 是否自动播放，默认 true。
    public var autoPlay: Bool = true {
        didSet { restartTimerIfNeeded() }
    }

    /// 自动播放间隔（秒），默认 3.0（对应 api.json 3000ms）。
    public var duration: TimeInterval = 3.0 {
        didSet { restartTimerIfNeeded() }
    }

    /// 是否循环轮播，默认 true。
    public var loop: Bool = true {
        didSet {
            collectionView.reloadData()
            resetToStartPosition()
        }
    }

    /// 是否显示指示器，默认 true。
    public var showIndicators: Bool = true {
        didSet { pageControl.isHidden = !showIndicators }
    }

    /// 指示器高亮色，默认 AppColor.primary。
    public var indicatorColor: UIColor = AppColor.primary {
        didSet { applyIndicatorColors() }
    }

    /// 索引变化回调（自动播放 / 手动滑动均触发）。
    public var onChange: ((Int) -> Void)?

    // MARK: - 子视图

    private let collectionView: UICollectionView
    private let pageControl = UIPageControl()

    // MARK: - 内部状态

    /// 当前在（可能放大后的）item 空间中的绝对索引。
    private var absoluteIndex: Int = 0
    /// 是否已完成初始定位（loop 模式需静默滚到中段）。
    private var hasInitializedPosition: Bool = false
    /// 自动播放定时器。
    private var timer: Timer?

    // MARK: - Init

    public override init(frame: CGRect) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(frame: frame)
        setupViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) 未实现") }

    /// 便利构造器：一次性传入 props。
    public convenience init(items: [UIView] = [],
                            autoPlay: Bool = true,
                            duration: TimeInterval = 3.0,
                            loop: Bool = true,
                            showIndicators: Bool = true,
                            indicatorColor: UIColor? = nil,
                            onChange: ((Int) -> Void)? = nil) {
        self.init(frame: .zero)
        self.autoPlay = autoPlay
        self.duration = duration
        self.loop = loop
        self.showIndicators = showIndicators
        if let color = indicatorColor {
            self.indicatorColor = color
        }
        self.onChange = onChange
        // items 最后赋值以触发布局刷新
        if !items.isEmpty { self.items = items }
    }

    // MARK: - 默认尺寸

    /// 默认高度 200pt，宽度跟随外部约束（可通过 frame / 外部约束覆盖）。
    public override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: Layout.defaultHeight)
    }

    // MARK: - 布局

    public override func layoutSubviews() {
        super.layoutSubviews()
        // itemSize 同步为当前大小（等宽分页：每页宽=容器宽，高=容器高）
        if let flow = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flow.itemSize = collectionView.bounds.size
        }
        // 首次布局完成后定位到起始页（loop 模式滚到中段，避免越界）
        if !hasInitializedPosition, bounds.width > 0, !items.isEmpty {
            hasInitializedPosition = true
            resetToStartPosition()
            restartTimerIfNeeded()
        }
    }

    // MARK: - 生命周期

    public override func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil {
            restartTimerIfNeeded()
        } else {
            stopTimer() // 移出窗口时停止定时器，避免离屏耗电
        }
    }

    // MARK: - Setup

    private func setupViews() {
        backgroundColor = AppColor.bgCard
        layer.cornerRadius = Layout.containerRadius
        clipsToBounds = true

        collectionView.backgroundColor = .clear
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(CarouselCell.self, forCellWithReuseIdentifier: CarouselCell.reuseId)
        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // UIPageControl = iOS 原生分页指示器
        pageControl.currentPage = 0
        pageControl.hidesForSinglePage = false
        pageControl.isUserInteractionEnabled = false
        // iOS 14+ 显式设置背景样式，避免系统默认气泡干扰 dot 可见性
        if #available(iOS 14.0, *) {
            pageControl.backgroundStyle = .minimal
        }
        addSubview(pageControl)
        bringSubviewToFront(pageControl)
        pageControl.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-8)
            make.height.equalTo(20)
        }
    }

    // MARK: - 循环定位

    /// 循环模式下的起始绝对索引（位于放大区间的中段，便于双向滑动）。
    private var startPosition: Int {
        guard loop, items.count > 1 else { return 0 }
        // 取中段且为 items.count 的整数倍，使 logicalIndex = 0
        return (Layout.loopRepeatFactor / 2) * items.count
    }

    /// 静默滚动到起始位置（无动画）。
    private func resetToStartPosition() {
        guard !items.isEmpty, bounds.width > 0 else {
            hasInitializedPosition = false
            return
        }
        absoluteIndex = startPosition
        collectionView.scrollToItem(at: IndexPath(item: absoluteIndex, section: 0),
                                    at: [],
                                    animated: false)
        applyIndicatorColors(for: 0)
    }

    // MARK: - 指示器

    /// 当前逻辑索引（0 ..< items.count）。
    private var logicalIndex: Int {
        guard !items.isEmpty else { return 0 }
        return ((absoluteIndex % items.count) + items.count) % items.count
    }

    private func rebuildIndicators() {
        pageControl.numberOfPages = items.count
        pageControl.currentPage = logicalIndex
        pageControl.isHidden = !showIndicators || items.isEmpty
        applyIndicatorColors()
    }

    private func applyIndicatorColors() {
        applyIndicatorColors(for: logicalIndex)
    }

    /// 更新指示器颜色（当前页 indicatorColor，其他默认灰）。
    private func applyIndicatorColors(for index: Int) {
        // UIPageControl 用 pageIndicatorTintColor / currentPageIndicatorTintColor
        pageControl.pageIndicatorTintColor = indicatorColor.withAlphaComponent(0.3)
        pageControl.currentPageIndicatorTintColor = indicatorColor
        pageControl.currentPage = index
    }

    // MARK: - 自动播放定时器

    private func restartTimerIfNeeded() {
        stopTimer()
        guard autoPlay, items.count > 1, window != nil else { return }
        // duration 下限 0.1s，避免 0/负值导致定时器异常
        timer = Timer.scheduledTimer(withTimeInterval: max(duration, 0.1), repeats: true) { [weak self] _ in
            self?.advance()
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    /// 自动播放前进一步。
    private func advance() {
        guard !items.isEmpty else { return }
        if !loop, logicalIndex == items.count - 1 {
            // loop=false 时末张停止，不再回 0
            stopTimer()
            return
        }
        absoluteIndex += 1
        collectionView.scrollToItem(at: IndexPath(item: absoluteIndex, section: 0),
                                    at: [],
                                    animated: true)
        let next = logicalIndex
        applyIndicatorColors(for: next)
        onChange?(next)
    }

    // MARK: - 手动滑动索引计算

    /// 由 contentOffset 反推绝对索引（仅在放大倍数有界的安全范围内调用）。
    private func absoluteIndexFromOffset() -> Int {
        let pageWidth = collectionView.bounds.width
        guard pageWidth > 0 else { return absoluteIndex }
        return Int(round(collectionView.contentOffset.x / pageWidth))
    }
}

// MARK: - UICollectionView 数据源 / 代理

extension CarouselView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    public func collectionView(_ collectionView: UICollectionView,
                                numberOfItemsInSection section: Int) -> Int {
        guard !items.isEmpty else { return 0 }
        // 循环模式放大倍数（假无限）；非循环模式为真实数量；单项无需放大
        return (loop && items.count > 1) ? items.count * Layout.loopRepeatFactor : items.count
    }

    public func collectionView(_ collectionView: UICollectionView,
                                cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CarouselCell.reuseId, for: indexPath) as! CarouselCell
        let idx = loop ? indexPath.item % items.count : indexPath.item
        cell.host(items[idx])
        return cell
    }

    // MARK: - 滚动事件

    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        // 手动滑动时暂停自动播放，松手恢复（避免手势/自动播放互相打架）
        stopTimer()
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 实时联动指示器（按当前可视页）
        guard !items.isEmpty else { return }
        let absIdx = absoluteIndexFromOffset()
        let logical = ((absIdx % items.count) + items.count) % items.count
        applyIndicatorColors(for: logical)
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard !items.isEmpty else { return }
        absoluteIndex = absoluteIndexFromOffset()
        let logical = logicalIndex
        applyIndicatorColors(for: logical)
        onChange?(logical)
        restartTimerIfNeeded()
    }
}

// MARK: - CarouselCell

/// 轮播单元格——承载单个 UIView 内容（cell 复用时迁移内容视图）。
private final class CarouselCell: UICollectionViewCell {
    static let reuseId = "CarouselCell"

    private let container = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(container)
        container.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) 未实现") }

    /// 承载外部视图：先从其他 cell 移出，再固定到本容器。
    func host(_ view: UIView) {
        container.subviews.forEach { $0.removeFromSuperview() }
        view.removeFromSuperview() // 从其他 cell 容器移出（如有）
        container.addSubview(view)
        // remakeConstraints 避免复用视图旧约束冲突
        view.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
