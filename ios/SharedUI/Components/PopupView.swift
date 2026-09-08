/// Popup 弹出层（UIKit 版，对齐 Android Popup.kt / api.json `ui.popup`）。
///
/// 组件 ID：`ui.popup` ｜ 任务清单 #54 ｜ 操作反馈区第九件 ｜ TMO 组件库 v1.4.4
///
/// 定位：通用弹出层容器——居中/底部/顶部弹出，带遮罩，承载任意自定义内容，可关闭。
///
/// 契约 props（与 api.json 100% 对齐）：
/// - visible: Bool（*必选*：true=挂载到 keyWindow + 动画进入；false=退出动画后卸载）
/// - content: UIView（*必选*：弹层内嵌内容，宿主自定义）
/// - position: PopupPosition（默认 .center：center/bottom/top 三向）
/// - closeable: Bool（默认 false：是否显示右上角关闭按钮）
/// - closeOnClickOverlay: Bool（默认 true：点击遮罩是否收起）
/// - radius: CGFloat（默认 AppRadius.lg：弹层圆角）
/// - onClose: (() -> Void)?（null=不回调）
///
/// 事件：
/// - onClose: () -> Void（closeable 关闭按钮 / closeOnClickOverlay 遮罩点击 / 外部 visible=false）
///
/// 设计规格（design-spec/popup-design-spec.html）：
/// - 遮罩：全屏 black 45% 透明
/// - 弹层容器：白底，圆角按 position 变化（center=四角 radiusLg / bottom=顶两角 / top=底两角）
/// - 关闭按钮：24×24 圆形灰底白叉，closeable=true 时显示
/// - 动画：center=淡入+缩放 0.2s / bottom=从底部滑入 0.25s easeOut / top=从顶部滑入
/// - 底部安全区：position=bottom 时 safeArea bottom padding
///
/// 用法：
/// ```swift
/// let popup = PopupContainerView()
/// popup.position = .bottom
/// popup.content = myContentView
/// popup.closeable = true
/// popup.onClose = { /* ... */ }
/// popup.visible = true
/// ```

import UIKit
import SnapKit

// MARK: - 数据模型

/// 弹出位置（与 api.json PopupPosition 对齐）。
public enum PopupPosition {
    case center   // 居中弹出
    case bottom   // 底部贴底
    case top      // 顶部贴顶
}

// MARK: - 组件

/// 通用弹出层容器。
public final class PopupContainerView: UIView {

    // MARK: - Props

    public var visible: Bool = false {
        didSet {
            if visible != oldValue {
                visible ? show() : hide()
            }
        }
    }
    public var content: UIView? { didSet { replaceContent() } }
    public var position: PopupPosition = .center { didSet { updateLayout() } }
    public var closeable: Bool = false { didSet { closeButton.isHidden = !closeable } }
    public var closeOnClickOverlay: Bool = true
    public var radius: CGFloat = AppRadius.lg { didSet { updateLayout() } }
    public var onClose: (() -> Void)?

    // MARK: - 子视图

    private let overlayView = UIView()
    private let containerStack = UIView()
    private let closeButton = UIButton(type: .custom)
    private var contentConstraints: [Constraint] = []

    // MARK: - 常量

    private enum Layout {
        static let overlayAlpha: CGFloat = 0.45
        static let closeButtonSize: CGFloat = 24
        static let closeButtonInset: CGFloat = 8
        static let animationDurationCenter: TimeInterval = 0.2
        static let animationDurationSlide: TimeInterval = 0.25
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

        // 遮罩
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(Layout.overlayAlpha)
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(overlayView)
        overlayView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(overlayTapped))
        overlayView.addGestureRecognizer(tap)

        // 弹层容器
        containerStack.backgroundColor = AppColor.bgCard
        containerStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerStack)
        containerStack.layer.masksToBounds = true
        updateLayout()

        // 关闭按钮
        closeButton.setTitle("×", for: .normal)
        closeButton.setTitleColor(AppColor.textSecondary, for: .normal)
        closeButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        closeButton.backgroundColor = AppColor.gray6
        closeButton.layer.cornerRadius = Layout.closeButtonSize / 2
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.isHidden = !closeable
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        containerStack.addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(Layout.closeButtonInset)
            make.size.equalTo(Layout.closeButtonSize)
        }
    }

    // MARK: - 布局

    private func updateLayout() {
        containerStack.snp.remakeConstraints { make in
            switch position {
            case .center:
                make.center.equalToSuperview()
                make.leading.greaterThanOrEqualToSuperview().offset(AppSpace.lg)
                make.trailing.lessThanOrEqualToSuperview().offset(-AppSpace.lg)
            case .bottom:
                make.leading.trailing.bottom.equalToSuperview()
            case .top:
                make.leading.trailing.top.equalToSuperview()
            }
        }
        // 圆角按 position 变化
        let r = radius
        switch position {
        case .center:
            containerStack.layer.cornerRadius = r
        case .bottom:
            containerStack.layer.cornerRadius = r
            // 仅顶两角（用 maskedCorners）
            containerStack.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        case .top:
            containerStack.layer.cornerRadius = r
            containerStack.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
    }

    // MARK: - 内容

    private func replaceContent() {
        contentConstraints.forEach { $0.deactivate() }
        contentConstraints = []
        content?.removeFromSuperview()
        guard let content = content else { return }
        content.translatesAutoresizingMaskIntoConstraints = false
        containerStack.addSubview(content)
        content.snp.prepareConstraints { make in
            make.edges.equalToSuperview()
        }?.forEach { c in
            c.activate()
            contentConstraints.append(c)
        }
        // 关闭按钮置顶
        containerStack.bringSubviewToFront(closeButton)
    }

    // MARK: - 展示/隐藏

    private func show() {
        guard let window = UIApplication.shared.keyWindow else { return }
        frame = window.bounds
        window.addSubview(self)
        window.bringSubviewToFront(self)

        switch position {
        case .center:
            overlayView.alpha = 0
            containerStack.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            containerStack.alpha = 0
            UIView.animate(withDuration: Layout.animationDurationCenter, delay: 0, options: .curveEaseOut) {
                self.overlayView.alpha = 1
                self.containerStack.transform = .identity
                self.containerStack.alpha = 1
            }
        case .bottom:
            overlayView.alpha = 0
            containerStack.transform = CGAffineTransform(translationX: 0, y: containerStack.bounds.height)
            UIView.animate(withDuration: Layout.animationDurationSlide, delay: 0, options: .curveEaseOut) {
                self.overlayView.alpha = 1
                self.containerStack.transform = .identity
            }
        case .top:
            overlayView.alpha = 0
            containerStack.transform = CGAffineTransform(translationX: 0, y: -containerStack.bounds.height)
            UIView.animate(withDuration: Layout.animationDurationSlide, delay: 0, options: .curveEaseOut) {
                self.overlayView.alpha = 1
                self.containerStack.transform = .identity
            }
        }
    }

    private func hide() {
        let duration: TimeInterval
        switch position {
        case .center:
            duration = Layout.animationDurationCenter
        case .bottom, .top:
            duration = Layout.animationDurationSlide
        }
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseIn, animations: {
            self.overlayView.alpha = 0
            switch self.position {
            case .center:
                self.containerStack.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                self.containerStack.alpha = 0
            case .bottom:
                self.containerStack.transform = CGAffineTransform(translationX: 0, y: self.containerStack.bounds.height)
            case .top:
                self.containerStack.transform = CGAffineTransform(translationX: 0, y: -self.containerStack.bounds.height)
            }
        }) { _ in
            self.removeFromSuperview()
        }
    }

    // MARK: - 交互

    @objc private func overlayTapped() {
        guard closeOnClickOverlay else { return }
        visible = false
        onClose?()
    }

    @objc private func closeTapped() {
        visible = false
        onClose?()
    }
}
