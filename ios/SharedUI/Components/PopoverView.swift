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
        content.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.addSubview(content)
        content.snp.prepareConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(
                top: Layout.contentPaddingV,
                left: Layout.contentPaddingH,
                bottom: Layout.contentPaddingV,
                right: Layout.contentPaddingH
            ))
        }.forEach { c in
            c.activate()
            contentConstraints.append(c)
        }
        bubbleView.bringSubviewToFront(arrowView)
    }

    // MARK: - 布局

    public override func layoutSubviews() {
        super.layoutSubviews()
        // 仅在属性变化触发 layoutSubviews 时更新约束；
        // show() 已显式调用 layoutBubble() + bubbleView.layoutIfNeeded() 应用约束。
        // 不在此处设置 transform，避免与 show()/hide() 动画 transform 冲突。
        layoutBubble()
    }

    private func layoutBubble() {
        let effectivePlacement = resolveEffectivePlacement()
        let arrow = Layout.arrowSize
        let margin = Layout.minBubbleMargin
        // offset 烘焙进约束（避免与 show()/hide() 的 scale transform 冲突）
        let anchorMinX = anchor.minX + offset.x
        let anchorMaxX = anchor.maxX + offset.x
        let anchorMinY = anchor.minY + offset.y
        let anchorMaxY = anchor.maxY + offset.y
        let anchorMidX = anchor.midX + offset.x
        let anchorMidY = anchor.midY + offset.y

        // 限制气泡尺寸（通过 intrinsicContentSize）
        bubbleView.snp.remakeConstraints { make in
            switch effectivePlacement {
            case .top, .start, .end:
                make.bottom.equalTo(anchorMinY).offset(-arrow)
            case .bottom:
                make.top.equalTo(anchorMaxY).offset(arrow)
            case .left:
                make.trailing.equalTo(anchorMinX).offset(-arrow)
            case .right:
                make.leading.equalTo(anchorMaxX).offset(arrow)
            }

            switch effectivePlacement {
            case .top, .bottom:
                make.centerX.equalTo(anchorMidX)
                make.leading.greaterThanOrEqualToSuperview().offset(margin)
                make.trailing.lessThanOrEqualToSuperview().offset(-margin)
            case .left, .right:
                make.centerY.equalTo(anchorMidY)
                make.top.greaterThanOrEqualToSuperview().offset(margin)
                make.bottom.lessThanOrEqualToSuperview().offset(-margin)
            case .start:
                make.trailing.equalTo(anchorMinX).offset(-arrow)
                make.centerY.equalTo(anchorMidY)
                make.top.greaterThanOrEqualToSuperview().offset(margin)
                make.bottom.lessThanOrEqualToSuperview().offset(-margin)
            case .end:
                make.leading.equalTo(anchorMaxX).offset(arrow)
                make.centerY.equalTo(anchorMidY)
                make.top.greaterThanOrEqualToSuperview().offset(margin)
                make.bottom.lessThanOrEqualToSuperview().offset(-margin)
            }

        }

        // 箭头位置
        arrowView.snp.remakeConstraints { make in
            make.size.equalTo(arrow)
            switch effectivePlacement {
            case .top:
                make.bottom.equalToSuperview().offset(arrow / 2)
                make.centerX.equalToSuperview().multipliedBy(1)
            case .bottom:
                make.top.equalToSuperview().offset(-arrow / 2)
                make.centerX.equalToSuperview()
            case .left, .start:
                make.trailing.equalToSuperview().offset(arrow / 2)
                make.centerY.equalToSuperview()
            case .right, .end:
                make.leading.equalToSuperview().offset(-arrow / 2)
                make.centerY.equalToSuperview()
            }
        }
        arrowView.transform = CGAffineTransform(rotationAngle: .pi / 4)
    }

    /// 检测 placement 方向是否有足够空间，不足则翻转到对侧。
    private func resolveEffectivePlacement() -> PopoverPlacement {
        let screen = UIScreen.main.bounds
        switch placement {
        case .top:
            // 顶部空间不足=翻转到底部
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
        guard let window = UIApplication.shared.keyWindow else { return }
        frame = window.bounds
        window.addSubview(self)
        window.bringSubviewToFront(self)
        // 显式设置约束 + 强制 layoutSubviews 同步应用约束到 bubbleView.frame，
        // 然后再启动动画——避免动画捕获到旧 frame（v1.4.5 修复"气泡位置跑到容器外/最底部"）。
        layoutBubble()
        bubbleView.setNeedsLayout()
        bubbleView.layoutIfNeeded()

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
