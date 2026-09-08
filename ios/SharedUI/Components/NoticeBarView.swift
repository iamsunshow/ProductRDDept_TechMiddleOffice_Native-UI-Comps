/// NoticeBar 公告栏：顶部/内嵌公告/通知栏（操作反馈区 #51，全新立项）。
///
/// 组件 ID：`ui.notice-bar`（api.json 契约对齐，门禁 A AI 代评通过 2026-09-08，
/// 用户"中间任何询问直接通过"总授权；P1–P4 全 A：双方向 horizontal/vertical +
/// 可关闭 closeable + 左右自定义图标 slot + 页面内嵌占位）。
///
/// 一期语义（对标 NutUI React NoticeBar + Vant NoticeBar）：
/// - [direction]：.horizontal（横向跑马灯，默认）/ .vertical（纵向多条轮播）
/// - [text]：单条文本（horizontal 模式）
/// - [list]：多条文本（vertical 模式）
/// - [closeable]：是否可关闭（true=右侧 × 关闭按钮+onClose 回调）
/// - [leftIcon]：左侧图标 slot（nil=默认喇叭 UIView）
/// - [rightIcon]：右侧图标 slot（nil=closeable 时 × 否则空）
/// - [backgroundColor]：背景色（默认 #FFF7ED 警告浅底）
/// - [textColor]：文本色（默认 textPrimary）
/// - [textSize]：文本字号（默认 sizeSm 14pt）
/// - [height]：栏高（默认 40pt）
/// - [speed]：滚动速度 px/s（默认 50）
/// - [delay]：延时启动秒数（默认 1）
/// - [duration]：vertical 模式每条停留时间 s（默认 1.0）
/// - [onClose]：关闭回调
///
/// 用法：
/// ```swift
/// // 基础横向滚动
/// let bar = NoticeBarView(text: "📢 这是一条公告信息...")
/// // 纵向多条轮播
/// let bar = NoticeBarView(direction: .vertical, list: ["消息 1", "消息 2", "消息 3"])
/// // 可关闭
/// let bar = NoticeBarView(text: "📢 可关闭公告", closeable: true) { /* 已关闭 */ }
/// ```
import UIKit
import SnapKit

enum NoticeBarDirection {
    case horizontal, vertical
}

final class NoticeBarView: UIView {

    private let direction: NoticeBarDirection
    private let text: String
    private let list: [String]
    private let closeable: Bool
    private let leftIcon: UIView?
    private let rightIcon: UIView?
    private let backgroundColorValue: UIColor
    private let textColor: UIColor
    private let textSize: CGFloat
    private let height: CGFloat
    private let speed: CGFloat
    private let delay: TimeInterval
    private let duration: TimeInterval
    private let onClose: (() -> Void)?

    private let containerStack = UIStackView()
    private let textLabel = UILabel()
    private var displayLink: CADisplayLink?
    private var textWidth: CGFloat = 0
    private var offset: CGFloat = 0
    private var currentIndex = 0
    private var verticalTimer: Timer?

    init(direction: NoticeBarDirection = .horizontal,
         text: String = "",
         list: [String] = [],
         closeable: Bool = false,
         leftIcon: UIView? = nil,
         rightIcon: UIView? = nil,
         backgroundColor: UIColor = UIColor(hex: 0xFFF7ED),
         textColor: UIColor = AppColor.textPrimary,
         textSize: CGFloat = AppFont.sizeSm,
         height: CGFloat = 40,
         speed: CGFloat = 50,
         delay: TimeInterval = 1,
         duration: TimeInterval = 1.0,
         onClose: (() -> Void)? = nil) {
        self.direction = direction
        self.text = text
        self.list = list
        self.closeable = closeable
        self.leftIcon = leftIcon
        self.rightIcon = rightIcon
        self.backgroundColorValue = backgroundColor
        self.textColor = textColor
        self.textSize = textSize
        self.height = height
        self.speed = speed
        self.delay = delay
        self.duration = duration
        self.onClose = onClose
        super.init(frame: .zero)
        setupViews()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }

    private func setupViews() {
        backgroundColor = backgroundColorValue
        layer.cornerRadius = AppRadius.sm
        clipsToBounds = true

        addSubview(containerStack)
        containerStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: AppSpace.sm, bottom: 0, right: AppSpace.sm))
        }
        containerStack.axis = .horizontal
        containerStack.alignment = .center
        containerStack.spacing = AppSpace.sm

        // 左侧图标
        let leftView: UIView
        if let leftIcon = leftIcon {
            leftView = leftIcon
        } else {
            let icon = NoticeBarMegaphoneIcon()
            leftView = icon
        }
        containerStack.addArrangedSubview(leftView)

        // 中间文本
        textLabel.textColor = textColor
        textLabel.font = .systemFont(ofSize: textSize)
        textLabel.numberOfLines = 1
        textLabel.lineBreakMode = .byClipping
        containerStack.addArrangedSubview(textLabel)
        textLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        // 右侧图标
        let rightView: UIView
        if let rightIcon = rightIcon {
            rightView = rightIcon
        } else if closeable {
            let closeBtn = UIButton(type: .system)
            closeBtn.setTitle("✕", for: .normal)
            closeBtn.setTitleColor(textColor, for: .normal)
            closeBtn.titleLabel?.font = .systemFont(ofSize: textSize)
            closeBtn.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
            rightView = closeBtn
        } else {
            rightView = UIView()
        }
        containerStack.addArrangedSubview(rightView)

        snp.makeConstraints { make in
            make.height.equalTo(height)
        }

        // 启动滚动
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            self?.startScrolling()
        }
    }

    private func startScrolling() {
        guard window != nil else { return }
        if direction == .horizontal {
            startHorizontalScroll()
        } else {
            startVerticalScroll()
        }
    }

    private func startHorizontalScroll() {
        textLabel.text = text
        // 计算文本宽度
        let attributes: [NSAttributedString.Key: Any] = [.font: textLabel.font as Any]
        textWidth = (text as NSString).size(withAttributes: attributes).width
        offset = bounds.width

        displayLink = CADisplayLink(target: self, selector: #selector(updateHorizontalScroll))
        displayLink?.add(to: .main, forMode: .common)
    }

    @objc private func updateHorizontalScroll() {
        guard textWidth > 0 else { return }
        let distance: CGFloat = textWidth + AppSpace.sm + bounds.width
        // 速度 px/s → px/frame（60fps）
        let pxPerFrame = speed / 60.0
        offset -= pxPerFrame
        if offset < -textWidth - AppSpace.sm {
            offset = bounds.width
        }
        textLabel.frame = CGRect(x: offset, y: 0, width: textWidth + AppSpace.sm, height: bounds.height)
    }

    private func startVerticalScroll() {
        guard !list.isEmpty else { return }
        textLabel.text = list[0]
        verticalTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.currentIndex = (self.currentIndex + 1) % self.list.count
            UIView.transition(with: self.textLabel, duration: 0.3, options: .transitionCrossDissolve) {
                self.textLabel.text = self.list[self.currentIndex]
            }
        }
    }

    @objc private func didTapClose() {
        removeFromSuperview()
        onClose?()
    }

    deinit {
        displayLink?.invalidate()
        verticalTimer?.invalidate()
    }
}

private extension UIColor {
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        let r = CGFloat((hex >> 16) & 0xFF) / 255.0
        let g = CGFloat((hex >> 8) & 0xFF) / 255.0
        let b = CGFloat(hex & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
}

// MARK: - 自绘喇叭图标（替代 emoji 📢，双端一致）
final class NoticeBarMegaphoneIcon: UIView {
    private let iconColor: UIColor

    init(color: UIColor = AppColor.textSecondary) {
        iconColor = color
        super.init(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        backgroundColor = .clear
        isUserInteractionEnabled = false
        snp.makeConstraints { make in
            make.width.height.equalTo(20)
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }

    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        ctx.setStrokeColor(iconColor.cgColor)
        ctx.setFillColor(iconColor.cgColor)
        ctx.setLineWidth(1.5)
        ctx.setLineJoin(.round)
        ctx.setLineCap(.round)

        let w = rect.width
        let h = rect.height

        // 喇叭体（梯形）
        let body = UIBezierPath()
        body.move(to: CGPoint(x: w * 0.15, y: h * 0.35))
        body.addLine(to: CGPoint(x: w * 0.15, y: h * 0.65))
        body.addLine(to: CGPoint(x: w * 0.45, y: h * 0.65))
        body.addLine(to: CGPoint(x: w * 0.75, y: h * 0.85))
        body.addLine(to: CGPoint(x: w * 0.75, y: h * 0.15))
        body.addLine(to: CGPoint(x: w * 0.45, y: h * 0.35))
        body.close()
        body.fill()

        // 声波弧线
        ctx.setStrokeColor(iconColor.cgColor)
        let wave1 = UIBezierPath(arcCenter: CGPoint(x: w * 0.75, y: h * 0.5),
                                 radius: w * 0.18,
                                 startAngle: -.pi / 3,
                                 endAngle: .pi / 3,
                                 clockwise: true)
        wave1.lineWidth = 1.5
        wave1.stroke()

        let wave2 = UIBezierPath(arcCenter: CGPoint(x: w * 0.75, y: h * 0.5),
                                 radius: w * 0.28,
                                 startAngle: -.pi / 4,
                                 endAngle: .pi / 4,
                                 clockwise: true)
        wave2.lineWidth = 1.5
        wave2.stroke()
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: 20, height: 20)
    }
}
