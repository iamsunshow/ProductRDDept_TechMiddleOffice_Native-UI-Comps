/// Skeleton 骨架屏（UIKit 版，对齐 Android Skeleton.kt / api.json `ui.skeleton`）。
///
/// 组件 ID：`ui.skeleton` ｜ 任务清单 #57 ｜ 操作反馈区第十二件 ｜ TMO 组件库 v1.4.14
///
/// 定位：首屏/加载过渡期占位骨架——灰块模拟内容布局，shimmer 扫光动画提示加载中。
///
/// 双模式：
/// - SkeletonBlock（原子块）：width/height/radius 可配，自由组合自定义布局
/// - SkeletonRow（包裹器）：loading 受控切换骨架/真实内容，预设 avatar+title+subtitle 行布局
///
/// 契约 props（与 api.json 100% 对齐）：
/// - SkeletonBlock: width(默认100%)/height(默认12)/radius(默认radiusSm)
/// - SkeletonRow: loading(必选)/avatar(默认true)/titleWidth(默认70%)/subtitle(默认true)/subtitleWidth(默认40%)/content(loading=false显示)
///
/// 设计规格（design-spec/skeleton-design-spec.html）：
/// - 骨架底色 gray100(#F3F4F6)，高亮 gray200(#E5E7EB)
/// - shimmer 1.5s linear infinite，从左到右渐变扫光（CAGradientLayer）
/// - 行圆角 radiusSm(6)，头像 40×40 radiusFull
///
/// 用法：
/// ```swift
/// // 原子块
/// let block = SkeletonBlock(width: .percentage(100), height: 120)
///
/// // 包裹器
/// let row = SkeletonRow(loading: true)
/// row.content = realContentView
/// row.loading = false  // 切换为真实内容
/// ```

import UIKit
import SnapKit

// MARK: - 骨架块尺寸

/// 骨架块宽度（百分比或固定值）。
public enum SkeletonDimension {
    case percentage(CGFloat)   // 0.0–1.0
    case fixed(CGFloat)        // dp/pt
}

// MARK: - SkeletonBlock（原子块）

/// 骨架原子块——灰块 + shimmer 扫光动画。
public final class SkeletonBlock: UIView {

    // MARK: - Props

    public var width: SkeletonDimension = .percentage(1.0) { didSet { setNeedsUpdateConstraints() } }
    public var height: SkeletonDimension = .fixed(12) { didSet { setNeedsUpdateConstraints() } }
    public var cornerRadius: CGFloat = AppRadius.sm { didSet { layer.cornerRadius = cornerRadius } }

    // MARK: - Layers

    private let gradientLayer = CAGradientLayer()
    private var widthConstraint: Constraint?
    private var heightConstraint: Constraint?

    // MARK: - 常量

    private enum Layout {
        static let baseColor = UIColor(white: 0.95, alpha: 1.0)      // gray100 #F3F4F6
        static let activeColor = UIColor(white: 0.90, alpha: 1.0)    // gray200 #E5E7EB
        static let shimmerDuration: CFTimeInterval = 1.5
    }

    // MARK: - Init

    public init(width: SkeletonDimension = .percentage(1.0), height: SkeletonDimension = .fixed(12), cornerRadius: CGFloat = 6) {
        self.width = width
        self.height = height
        self.cornerRadius = cornerRadius
        super.init(frame: .zero)
        setupViews()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    // MARK: - Setup

    private func setupViews() {
        backgroundColor = Layout.baseColor
        layer.cornerRadius = cornerRadius
        clipsToBounds = true

        // shimmer 渐变层
        gradientLayer.colors = [
            Layout.baseColor.cgColor,
            Layout.activeColor.cgColor,
            Layout.baseColor.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.locations = [0, 0.5, 1]
        layer.addSublayer(gradientLayer)

        startShimmer()
    }

    // MARK: - Layout
    // 不重写 updateConstraints——SkeletonBlock 的尺寸约束完全由外部容器决定
    // （与 Android Compose modifier 一致，外部 makeConstraints 设置 width/height/top/leading 等）
    // 之前 updateConstraints 调用 snp.remakeConstraints 会覆盖外部约束导致布局错乱

    public override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        // 扩大 gradient 宽度以实现扫光位移
        gradientLayer.frame = CGRect(x: -bounds.width, y: 0, width: bounds.width * 3, height: bounds.height)
    }

    // MARK: - Shimmer

    private func startShimmer() {
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-0.5, -0.3, -0.1]
        animation.toValue = [1.1, 1.3, 1.5]
        animation.duration = Layout.shimmerDuration
        animation.repeatCount = .infinity
        gradientLayer.add(animation, forKey: "shimmer")
    }
}

// MARK: - SkeletonRow（包裹器）

/// 骨架行包裹器——loading=true 显示骨架行（avatar+title+subtitle），loading=false 显示 content。
/// 不用 UIStackView（避免 arrangedSubview 的 width 约束冲突），改用纯 UIView + 手动 Auto Layout。
public final class SkeletonRow: UIView {

    // MARK: - Props

    public var loading: Bool = true {
        didSet {
            if loading {
                showSkeleton()
            } else {
                showContent()
            }
        }
    }

    public var avatar: Bool = true { didSet { updateSkeletonLayout() } }
    public var titleWidth: SkeletonDimension = .percentage(0.7) { didSet { updateSkeletonLayout() } }
    public var subtitle: Bool = true { didSet { updateSkeletonLayout() } }
    public var subtitleWidth: SkeletonDimension = .percentage(0.4) { didSet { updateSkeletonLayout() } }
    public var content: UIView? { didSet { replaceContent() } }

    // MARK: - 子视图（纯 UIView 容器，不用 stack）

    private let skeletonContainer = UIView()
    private var avatarBlock: SkeletonBlock?
    private var titleBlock: SkeletonBlock?
    private var subtitleBlock: SkeletonBlock?
    private var contentView: UIView?
    private var textColumnView: UIView?

    // MARK: - 常量

    private enum Layout {
        static let avatarSize: CGFloat = 40
        static let blockHeight: CGFloat = 12
        static let spacing: CGFloat = 12
        static let textSpacing: CGFloat = 6
    }

    // MARK: - Init

    /// 便利构造器：loading 受控初始化（默认 true 显示骨架）。
    public convenience init(loading: Bool = true) {
        self.init(frame: .zero)
        self.loading = loading
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        showSkeleton()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        showSkeleton()
    }

    // MARK: - Setup

    private func setupViews() {
        backgroundColor = .clear
        addSubview(skeletonContainer)
        skeletonContainer.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    // MARK: - Skeleton 显示/隐藏

    private func showSkeleton() {
        contentView?.isHidden = true
        skeletonContainer.isHidden = false
        updateSkeletonLayout()
    }

    private func showContent() {
        skeletonContainer.isHidden = true
        contentView?.isHidden = false
    }

    private func updateSkeletonLayout() {
        // 清空旧 subview
        skeletonContainer.subviews.forEach { $0.removeFromSuperview() }
        avatarBlock = nil
        titleBlock = nil
        subtitleBlock = nil
        textColumnView = nil

        var leadingOffset: CGFloat = 0

        // 头像（固定 40×40，垂直居中）
        if avatar {
            let av = SkeletonBlock(width: .fixed(Layout.avatarSize), height: .fixed(Layout.avatarSize), cornerRadius: Layout.avatarSize / 2)
            avatarBlock = av
            skeletonContainer.addSubview(av)
            av.snp.makeConstraints { make in
                make.leading.equalToSuperview().offset(leadingOffset)
                make.centerY.equalToSuperview()
                make.size.equalTo(Layout.avatarSize)
            }
            leadingOffset += Layout.avatarSize + Layout.spacing
        }

        // 文字列容器（撑满剩余宽度，title/subtitle 在内用 percentage）
        let textCol = UIView()
        textCol.backgroundColor = .clear
        textColumnView = textCol
        skeletonContainer.addSubview(textCol)
        textCol.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(leadingOffset)
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
        }

        // title（percentage 相对于 textCol）
        let titleBlk = SkeletonBlock(width: titleWidth, height: .fixed(Layout.blockHeight))
        titleBlock = titleBlk
        textCol.addSubview(titleBlk)
        titleBlk.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.height.equalTo(Layout.blockHeight)
        }
        switch titleWidth {
        case .percentage(let pct):
            titleBlk.snp.makeConstraints { make in make.width.equalTo(textCol).multipliedBy(pct) }
        case .fixed(let v):
            titleBlk.snp.makeConstraints { make in make.width.equalTo(v) }
        }

        // subtitle（percentage 相对于 textCol）
        if subtitle {
            let subBlk = SkeletonBlock(width: subtitleWidth, height: .fixed(Layout.blockHeight))
            subtitleBlock = subBlk
            textCol.addSubview(subBlk)
            subBlk.snp.makeConstraints { make in
                make.top.equalTo(titleBlk.snp.bottom).offset(Layout.textSpacing)
                make.leading.equalToSuperview()
                make.height.equalTo(Layout.blockHeight)
                make.bottom.equalToSuperview()
            }
            switch subtitleWidth {
            case .percentage(let pct):
                subBlk.snp.makeConstraints { make in make.width.equalTo(textCol).multipliedBy(pct) }
            case .fixed(let v):
                subBlk.snp.makeConstraints { make in make.width.equalTo(v) }
            }
        } else {
            titleBlk.snp.makeConstraints { make in make.bottom.equalToSuperview() }
        }
    }

    private func replaceContent() {
        contentView?.removeFromSuperview()
        if let cv = content {
            cv.translatesAutoresizingMaskIntoConstraints = false
            addSubview(cv)
            cv.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            cv.isHidden = loading
            contentView = cv
        }
    }
}
