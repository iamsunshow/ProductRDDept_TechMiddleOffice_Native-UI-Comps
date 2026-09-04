/// StickyView 粘性布局容器：把内容流中登记的吸顶块（Sticky Header）在滚动到钉线时钉在可视区顶部。
///
/// 组件 ID：`ui.sticky`（api.json 契约对齐，门禁 A AI 代评通过 2026-09-04，
/// 用户"中间任何询问直接通过"总授权；P1–P4 全 A：单吸顶行封装 + 列表/通用滚动双路径 +
/// iOS 走 contentOffset 监听 + pinned 平移方案（不依赖系统 section 模型）+ 一期单吸顶点 + offset）。
///
/// 一期语义（对标 Web position:sticky / Android LazyColumn stickyHeader）：
/// - [addRow] 添加普通内容行（AutoLayout 高度自适应或传 height 固定高，自动纵向排布）
/// - [addStickyHeader] 添加吸顶行：内容任意（标题/筛选条/可交互行），滚动到达钉线后钉在容器顶部，
///   被后续吸顶行顶替；回滚后恢复随流排布
/// - [offset] = 钉线距容器顶的距离（默认 0；给固定 AppBar 让位时传入 AppBar 高）
/// - 吸顶态视觉不变式一期：不提供任何视觉/状态样式，背景/圆角由吸顶内容自带（零硬编码）
/// - [onStickChange] 吸顶态切换回调（一期仅登记，供业务埋点/UI 反馈）
///
/// 用法：
/// ```swift
/// let sticky = StickyView(offset: 44)
/// sticky.addRow(普通行)
/// sticky.addStickyHeader(吸顶标题行)   // 内容任意（Cell/标签+按钮均可）
/// ```
import UIKit
import SnapKit

final class StickyView: UIView {

    /// 钉线距容器顶部的距离（默认 0）。
    let offset: CGFloat

    /// 吸顶态切换回调：true=当前有吸顶块钉在顶部，false=无。
    private let onStickChange: ((Bool) -> Void)?

    /// 滚动宿主（内容随其滚动；内容总高度由内部行链自动推出）。
    let scrollView = UIScrollView()

    /// 滚动内容容器：所有行（含吸顶块 flow 位）的 AutoLayout 布局宿主。
    private let contentView = UIView()

    /// 吸顶浮层：不随滚动，承载"当前被钉住的吸顶块"（z 序高于 scrollView）。
    private let pinnedHost = UIView()

    /// 当前按序参与流式布局的视图（吸顶块被钉住时该位被同高透明占位替换）。
    private var flowViews: [UIView] = []

    /// 登记的吸顶块（按添加顺序，滚动到钉线时依次顶替）。
    private var stickyHeaders: [UIView] = []

    /// 各视图固定高（未传 height 的由内容自适应撑高，不进此表）。
    private var fixedHeights: [UIView: CGFloat] = [:]

    /// 吸顶块被钉住时留在流中的占位（补位防内容塌陷）。
    private var spacers: [UIView: UIView] = [:]

    /// 当前被钉住的吸顶块（nil=无）。
    private var pinned: UIView?

    /// 内容纵向间距（默认 0：行间距由业务行自带 margin 控制）。
    private let rowSpacing: CGFloat

    /// 行链首个顶部边距（默认 0）。
    private let contentTopInset: CGFloat

    private var needsRelayout = false
    private var stickState = false
    private var observer: NSKeyValueObservation?

    // MARK: - init

    init(offset: CGFloat = 0,
         rowSpacing: CGFloat = 0,
         contentTopInset: CGFloat = 0,
         onStickChange: ((Bool) -> Void)? = nil) {
        self.offset = offset
        self.rowSpacing = rowSpacing
        self.contentTopInset = contentTopInset
        self.onStickChange = onStickChange
        super.init(frame: .zero)
        backgroundColor = .clear
        setupSubviews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("StickyView 不支持 initWithCoder 解码，请使用 init(offset:rowSpacing:contentTopInset:onStickChange:)。")
    }

    deinit {
        observer?.invalidate()
    }

    private func setupSubviews() {
        // 滚动容器填满自身
        addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        scrollView.alwaysBounceVertical = true

        // 内容容器：宽随可视区，高由内部行链推出（末行 bottom 封口）
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
        }

        // 吸顶浮层：不随滚动、位于 scrollView 之上（后 addSubview 即 z 序更高）
        addSubview(pinnedHost)
        pinnedHost.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(offset)
            make.leading.trailing.equalToSuperview()
        }
        pinnedHost.isUserInteractionEnabled = true

        // KVO 监听 contentOffset（不占用业务 delegate 位）
        observer = scrollView.observe(\.contentOffset, options: [.new]) { [weak self] _, _ in
            self?.updateStick()
        }
    }

    // MARK: - 内容添加

    /// 添加普通内容行（不吸顶，随滚动流式排布）。
    /// - Parameters:
    ///   - view: 内容视图（宽度自动撑满；高度自适应或内部约束撑起）
    ///   - height: 可选固定高度（nil=按内容自适应）
    @discardableResult
    func addRow(_ view: UIView, height: CGFloat? = nil) -> Int {
        attachToFlow(view)
        if let h = height { fixedHeights[view] = h }
        return flowViews.count - 1
    }

    /// 添加吸顶块行：滚动到钉线后钉在容器顶部，被后续吸顶块顶替；回滚恢复随流排布。
    /// - Parameters:
    ///   - header: 吸顶内容（任意：标题行/筛选条/可交互行）
    ///   - height: 可选固定高度（nil=按内容自适应）
    @discardableResult
    func addStickyHeader(_ header: UIView, height: CGFloat? = nil) -> Int {
        attachToFlow(header)
        if let h = height { fixedHeights[header] = h }
        stickyHeaders.append(header)
        return flowViews.count - 1
    }

    /// 移除全部内容（含吸顶登记），回到空容器。
    func removeAllContent() {
        flowViews.forEach { $0.removeFromSuperview() }
        flowViews.removeAll()
        stickyHeaders.removeAll()
        fixedHeights.removeAll()
        spacers.removeAll()
        pinned = nil
        setStickState(false)
        needsRelayout = true
        setNeedsLayout()
    }

    private func attachToFlow(_ view: UIView) {
        contentView.addSubview(view)
        flowViews.append(view)
        needsRelayout = true
        setNeedsLayout()
    }

    // MARK: - 布局

    override func layoutSubviews() {
        super.layoutSubviews()
        if needsRelayout {
            needsRelayout = false
            relayoutFlow()
        }
    }

    /// 行链重排：首行 top=contentTopInset；相邻行间距 rowSpacing；末行 bottom 封口到 contentView。
    private func relayoutFlow() {
        guard !flowViews.isEmpty else { return }
        var prevBottom: ConstraintItem?
        for view in flowViews {
            view.snp.remakeConstraints { make in
                if let prev = prevBottom {
                    make.top.equalTo(prev).offset(rowSpacing)
                } else {
                    make.top.equalTo(contentView.snp.top).offset(contentTopInset)
                }
                make.leading.trailing.equalTo(contentView)
                if let h = fixedHeights[view] {
                    make.height.equalTo(h)
                }
            }
            prevBottom = view.snp.bottom
        }
        // 末行 bottom 封口到 contentView：行高由链推出后 contentView 高随之闭合
        // （UIScrollView + AutoLayout 下 contentView 高必须显式等于内容总高，否则滚动域为 0）
        if let last = flowViews.last {
            last.snp.makeConstraints { make in
                make.bottom.equalTo(contentView.snp.bottom)
            }
        }
    }

    // MARK: - 吸顶状态机

    private func updateStick() {
        guard !stickyHeaders.isEmpty else { return }
        let scrollTop = scrollView.contentOffset.y
        let lineY = scrollTop + offset  // 钉线（内容坐标）

        // 找 flow 态吸顶块中已越过钉线的最近者（flowTop 最大）。
        // flow 态取 header 自身 frame；pinned 态其 flow 位由 spacer 占位（frame 同原位置）。
        var candidate: UIView?
        var candTop: CGFloat = -.greatestFiniteMagnitude
        for header in stickyHeaders where header !== pinned {
            let holder = spacers[header] ?? header
            guard holder.superview === contentView else { continue }
            let top = holder.frame.minY
            if top <= lineY && top > candTop {
                candidate = header
                candTop = top
            }
        }

        if let candidate {
            // 下一吸顶块顶入（或新吸顶块首次触发）：pin（内部先让出旧的）
            pinHeader(candidate)
        } else if let current = pinned {
            // 当前钉住者：回滚越过钉线则恢复随流（其 flow 位 = spacer 位置）
            if let spacer = spacers[current], spacer.frame.minY > lineY + 0.5 {
                unpinHeader(current)
            }
        }
    }

    private func pinHeader(_ header: UIView) {
        guard let idx = flowViews.firstIndex(of: header) else { return }
        if let old = pinned, old !== header {
            unpinHeader(old)
        }
        // 记下吸顶块高度（flow 位移除前最后实测高；优先取 fixedHeights）
        let h = fixedHeights[header] ?? (header.frame.height > 0 ? header.frame.height : 44)
        // 1) flow 位换同高透明占位（内容高度稳定、下方行不跳动；高度走 fixedHeights 由 relayout 统一管理）
        let spacer = UIView()
        spacer.backgroundColor = .clear
        flowViews[idx] = spacer
        contentView.addSubview(spacer)
        fixedHeights[spacer] = h
        spacers[header] = spacer
        // 2) 吸顶块从内容流移出，挂到浮层钉线位置（z 序最高、不随滚动）
        header.removeFromSuperview()
        pinnedHost.addSubview(header)
        header.snp.remakeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            if let h = fixedHeights[header] {
                make.height.equalTo(h)
            }
        }
        pinned = header
        setStickState(true)
        needsRelayout = true
        setNeedsLayout()
        layoutIfNeeded()
    }

    private func unpinHeader(_ header: UIView) {
        guard let spacer = spacers.removeValue(forKey: header) else { return }
        guard let idx = flowViews.firstIndex(of: spacer) else { return }
        // 吸顶块从浮层移回内容流原位（原占位移除、位置还原）
        spacer.removeFromSuperview()
        fixedHeights.removeValue(forKey: spacer)
        flowViews[idx] = header
        contentView.addSubview(header)
        pinned = nil
        setStickState(false)
        needsRelayout = true
        setNeedsLayout()
        layoutIfNeeded()
    }

    private func setStickState(_ state: Bool) {
        guard state != stickState else { return }
        stickState = state
        onStickChange?(state)
    }
}
