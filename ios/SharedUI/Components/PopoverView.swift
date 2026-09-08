/// Popover 气泡弹出框（UIKit 版，对齐 Android Popover.kt / api.json `ui.popover`）。
///
/// 组件 ID：`ui.popover` ｜ 任务清单 #53 ｜ 操作反馈区第八件 ｜ TMO 组件库 v1.4.4
///
/// 定位：点击触发元素后弹出带箭头指向锚点的小气泡浮层，内嵌自定义内容，点击外部自动收起。
///
/// 契约 props（与 api.json 100% 对齐）：
/// - visible: Bool（*必选*：true=挂载到 keyWindow；false=卸载）
/// - content: UIView（*必选*：气泡内嵌内容，宿主自定义）
/// - placement: PopoverPlacement（默认 .top：top/bottom/left/right/start/end 六向）
/// - anchor: CGRect（*必选*：锚点 frame，用于定位气泡+箭头方向）
/// - closeOnClickOutside: Bool（默认 true：点击气泡外部自动收起）
/// - offset: CGPoint（默认 .zero：相对锚点的额外偏移）
/// - onClose: (() -> Void)?（null=不回调）
///
/// 事件：
/// - onClose: () -> Void（closeOnClickOutside 触发时）
///
/// 设计规格（design-spec/popover-design-spec.html）：
/// - 气泡容器：白底圆角 8（AppRadius.sm），阴影 0 4 12 rgba(0,0,0,0.15)
/// - 箭头：8×8 旋转 45° 实心方块，颜色同气泡底色
/// - 外部透明层：全屏透明，捕获点击
/// - 动画：淡入+缩放 0.95→1.0（150ms easeOut）
/// - 自动翻转：placement 方向空间不足时翻转到对侧
///
/// 用法：
/// ```swift
/// let popover = PopoverView()
/// popover.placement = .top
/// popover.anchor = button.frame  // 锚点
/// popover.content = myLabel
/// popover.onClose = { /* ... */ }
/// popover.visible = true
/// ```

import UIKit
import SnapKit

// MARK: - 数据模型

/// 弹出方向（与 api.json PopoverPlacement 对齐）。
public enum PopoverPlacement {
    case top      // 气泡在锚点上方，箭头朝下
    case bottom   // 气泡在锚点下方，箭头朝上
    case left     // 气泡在锚点左侧，箭头朝右
    case right    // 气泡在锚点右侧，箭头朝左
    case start    // 气泡在锚点 RTL 起始侧（LTR=左）
    case end      // 气泡在锚点 RTL 结束侧（LTR=右）
}

// MARK: - 组件

/// 气泡弹出框。
public final class PopoverView: UIView {

    // MARK: - Props

    public var visible: Bool = false {
        didSet {
            if visible != oldValue {
                visible ? show() : hide()
            }
        }
    }
    public var content: UIView? { didSet { replaceContent() } }
    public var placement: PopoverPlacement = .top { didSet { setNeedsLayout() } }
    public var anchor: CGRect = .zero { didSet { setNeedsLayout() } }
    public var closeOnClickOutside: Bool = true
    public var offset: CGPoint = .zero { didSet { setNeedsLayout() } }
    public var onClose: (() -> Void)?

    // MARK: - 子视图

    private let outsideView = UIView()
    private let bubbleView = UIView()
    private let arrowView = UIView()
    private var contentConstraints: [Constraint] = []

    // MARK: - 常量

    private enum Layout {
        static let bubbleRadius: CGFloat = AppRadius.sm
        static let arrowSize: CGFloat = 8
        static let contentPaddingH: CGFloat = AppSpace.md
        static let contentPaddingV: CGFloat = AppSpace.sm
        static let shadowOpacity: Float = 0.15
        static let shadowRadius: CGFloat = 12
        static let shadowOffset = CGSize(width: 0, height: 4)
        static let animationDuration: TimeInterval = 0.15
        static let minBubbleMargin: CGFloat = AppSpace.lg
    }

    // MARK: - Init

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    // MARK: - Setup

    private func setupViews() {
        backgroundColor = .clear

        // 外部透明层
        outsideView.backgroundColor = .clear
        outsideView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(outsideView)
        outsideView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(outsideTapped))
        outsideView.addGestureRecognizer(tap)

        // 气泡容器
        bubbleView.backgroundColor = AppColor.bgCard
        bubbleView.layer.cornerRadius = Layout.bubbleRadius
        bubbleView.layer.masksToBounds = false
        bubbleView.layer.shadowColor = UIColor.black.cgColor
        bubbleView.layer.shadowOpacity = Layout.shadowOpacity
        bubbleView.layer.shadowRadius = Layout.shadowRadius
        bubbleView.layer.shadowOffset = Layout.shadowOffset
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(bubbleView)

        // 箭头
        arrowView.backgroundColor = AppColor.bgCard
        arrowView.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.addSubview(arrowView)
    }

    // MARK: - 内容

    private func replaceContent() {
        contentConstraints.forEach { $0.deactivate() }
        contentConstraints = []
        content?.removeFromSuperview()
        guard let content = content else { return }
        // v1.4.8: frame 定位（不用 SnapKit 约束），layoutBubbleFrame() 直接设置 content.frame
        content.translatesAutoresizingMaskIntoConstraints = true
        bubbleView.addSubview(content)
        bubbleView.bringSubviewToFront(arrowView)
    }

    // MARK: - 布局

    public override func layoutSubviews() {
        super.layoutSubviews()
        // show() 已直接计算 bubbleView.frame；此处仅处理属性变化时的重定位。
        if bubbleView.superview != nil && bubbleView.frame != .zero {
            layoutBubbleFrame()
        }
    }

    /// 直接计算 bubbleView + arrowView 的 frame（不用 AutoLayout 约束）。
    /// 根因（v1.4.8）：旧版用 SnapKit 约束设置 bubbleView 的 bottom/top/centerX 等
    /// 到 anchor 常量值，但约束需额外 layout pass 才能应用到 frame，且 show() 添加到
    /// window 后 self 的 layout 尚未完成 → 约束解析到错误坐标 → 气泡跑到容器外/最底部。
    /// 改为直接计算 frame = 与 Android PopupPositionProvider 一致，布局即结果，无延迟。
    ///
    /// v1.4.9 修复气泡尺寸太小（还没内容大）：
    /// - arrowView.translatesAutoresizingMaskIntoConstraints 必须设 true，否则 Auto Layout 覆盖 frame 赋值
    /// - content 尺寸用 intrinsicContentSize（UILabel 可靠），sizeToFit 作 fallback
    /// - 加最小气泡尺寸（minBubbleWidth=80, minBubbleHeight=30）防止 content 尺寸为 0
    private func layoutBubbleFrame() {
        let effectivePlacement = resolveEffectivePlacement()
        let arrow = Layout.arrowSize
        let margin = Layout.minBubbleMargin
        let screen = UIScreen.main.bounds

        // 1. 获取 content 的自然尺寸（intrinsicContentSize 比 sizeToFit 更可靠，
        //    UIStackView.sizeToFit() 返回 .zero，但 UILabel.intrinsicContentSize 正确）
        var contentSize = content?.intrinsicContentSize ?? .zero
        if contentSize.width == 0 || contentSize.height == 0 {
            content?.sizeToFit()
            let fitSize = content?.frame.size ?? .zero
            contentSize = CGSize(
                width: max(contentSize.width, fitSize.width),
                height: max(contentSize.height, fitSize.height)
            )
        }
        // 2. 计算气泡尺寸 = content + padding，加最小尺寸防止 0
        let minBubbleWidth: CGFloat = 80
        let minBubbleHeight: CGFloat = 30
        let bubbleWidth = max(contentSize.width + Layout.contentPaddingH * 2, minBubbleWidth)
        let bubbleHeight = max(contentSize.height + Layout.contentPaddingV * 2, minBubbleHeight)

        // 3. offset 烘焙进坐标
        let anchorMinX = anchor.minX + offset.x
        let anchorMaxX = anchor.maxX + offset.x
        let anchorMinY = anchor.minY + offset.y
        let anchorMaxY = anchor.maxY + offset.y
        let anchorMidX = anchor.midX + offset.x
        let anchorMidY = anchor.midY + offset.y

        // 4. 按 placement 计算 bubble 原点
        var bubbleOrigin: CGPoint = .zero
        switch effectivePlacement {
        case .top:
            bubbleOrigin.x = anchorMidX - bubbleWidth / 2
            bubbleOrigin.y = anchorMinY - arrow - bubbleHeight
        case .bottom:
            bubbleOrigin.x = anchorMidX - bubbleWidth / 2
            bubbleOrigin.y = anchorMaxY + arrow
        case .left, .start:
            bubbleOrigin.x = anchorMinX - arrow - bubbleWidth
            bubbleOrigin.y = anchorMidY - bubbleHeight / 2
        case .right, .end:
            bubbleOrigin.x = anchorMaxX + arrow
            bubbleOrigin.y = anchorMidY - bubbleHeight / 2
        }

        // 5. 屏幕边缘裁剪（margin）
        bubbleOrigin.x = max(margin, min(screen.width - margin - bubbleWidth, bubbleOrigin.x))
        bubbleOrigin.y = max(margin, min(screen.height - margin - bubbleHeight, bubbleOrigin.y))

        // 6. 设置 bubbleView frame
        bubbleView.frame = CGRect(origin: bubbleOrigin, size: CGSize(width: bubbleWidth, height: bubbleHeight))

        // 7. content frame（padding 内边）
        content?.frame = CGRect(
            x: Layout.contentPaddingH,
            y: Layout.contentPaddingV,
            width: bubbleWidth - Layout.contentPaddingH * 2,
            height: bubbleHeight - Layout.contentPaddingV * 2
        )

        // 8. 箭头 frame + 旋转
        let arrowRect: CGRect
        switch effectivePlacement {
        case .top:
            // 箭头在气泡底部居中，露出半个
            arrowRect = CGRect(
                x: bubbleWidth / 2 - arrow / 2,
                y: bubbleHeight - arrow / 2,
                width: arrow,
                height: arrow
            )
        case .bottom:
            arrowRect = CGRect(
                x: bubbleWidth / 2 - arrow / 2,
                y: -arrow / 2,
                width: arrow,
                height: arrow
            )
        case .left, .start:
            arrowRect = CGRect(
                x: bubbleWidth - arrow / 2,
                y: bubbleHeight / 2 - arrow / 2,
                width: arrow,
                height: arrow
            )
        case .right, .end:
            arrowRect = CGRect(
                x: -arrow / 2,
                y: bubbleHeight / 2 - arrow / 2,
                width: arrow,
                height: arrow
            )
        }
        arrowView.frame = arrowRect
        arrowView.transform = CGAffineTransform(rotationAngle: .pi / 4)
    }

    /// 检测 placement 方向是否有足够空间，不足则翻转到对侧。
    private func resolveEffectivePlacement() -> PopoverPlacement {
        let screen = UIScreen.main.bounds
        switch placement {
        case .top:
            if anchor.minY < 120 { return .bottom }
            return .top
        case .bottom:
            if screen.height - anchor.maxY < 120 { return .top }
            return .bottom
        case .left, .start:
            if anchor.minX < 120 { return .right }
            return .left
        case .right, .end:
            if screen.width - anchor.maxX < 120 { return .left }
            return .right
        }
    }

    // MARK: - 展示/隐藏

    private func show() {
        // 兼容 iOS 13+：优先用 connectedScenes 的 keyWindow，回退到 keyWindow
        let window: UIWindow?
        if #available(iOS 13, *) {
            window = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first?.windows.first(where: { $0.isKeyWindow })
        } else {
            window = UIApplication.shared.keyWindow
        }
        guard let win = window else { return }
        frame = win.bounds
        win.addSubview(self)
        win.bringSubviewToFront(self)

        // 直接计算 frame（不用 Auto Layout），布局即结果，无延迟
        // bubbleView、content、arrowView 全部用 frame 定位
        // v1.4.9：arrowView 也必须设 true，否则 Auto Layout 覆盖 frame 赋值
        bubbleView.translatesAutoresizingMaskIntoConstraints = true
        content?.translatesAutoresizingMaskIntoConstraints = true
        arrowView.translatesAutoresizingMaskIntoConstraints = true
        layoutBubbleFrame()

        bubbleView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        bubbleView.alpha = 0
        UIView.animate(withDuration: Layout.animationDuration, delay: 0, options: .curveEaseOut) {
            self.bubbleView.transform = .identity
            self.bubbleView.alpha = 1
        }
    }

    private func hide() {
        UIView.animate(withDuration: Layout.animationDuration, delay: 0, options: .curveEaseIn, animations: {
            self.bubbleView.alpha = 0
            self.bubbleView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            self.removeFromSuperview()
        }
    }

    // MARK: - 交互

    @objc private func outsideTapped() {
        guard closeOnClickOutside else { return }
        visible = false
        onClose?()
    }
}
