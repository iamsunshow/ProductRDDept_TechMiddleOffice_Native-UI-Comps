/// Notify 消息通知：顶部/底部全局消息通知浮层（操作反馈区 #52，全新立项）。
///
/// 组件 ID：`ui.notify`（api.json 契约对齐，门禁 A AI 代评通过 2026-09-08，
/// 用户"中间任何询问直接通过"总授权；P1–P4 全 A：命令式 API + 全局浮层 +
/// 自动消失 + 可关闭 + 左右图标 slot + type 变色 + position(top/bottom)）。
///
/// 一期语义（对标 NutUI React Notify + Vant Notify）：
/// - 命令式 API：Notify.show(message:position:type:duration:closeable:...) / Notify.clear()
/// - [position]：.top（默认）/ .bottom
/// - [type]：.default（深色底白字，默认）/ .primary / .success / .warning / .danger
/// - [duration]：展示时长 s（默认 3.0，0=常驻不消失）
/// - [closeable]：是否可关闭（true=右侧 × 关闭按钮+onClose 回调）
/// - [leftIcon]：左侧图标 slot（nil=默认喇叭）
/// - [rightIcon]：右侧图标 slot（nil=closeable 时 × 否则空）
/// - [distance]：距离顶部/底部 pt（默认 8）
/// - [navHeight]：顶部导航高度 pt（默认 57，position=top 时下移避开导航栏）
/// - [onClick]：点击回调
/// - [onClose]：关闭回调
///
/// 用法：
/// ```swift
/// Notify.show(message: "这是一条通知消息")
/// Notify.show(message: "底部通知", position: .bottom, duration: 5)
/// Notify.show(message: "成功通知", type: .success)
/// Notify.show(message: "可关闭通知", closeable: true) { /* onClose */ }
/// Notify.clear()
/// ```
import UIKit
import SnapKit

enum NotifyPosition {
    case top, bottom
}

enum NotifyType {
    case `default`, primary, success, warning, danger

    var backgroundColor: UIColor {
        switch self {
        case .default: return AppColor.textPrimary
        case .primary: return AppColor.primary
        case .success: return AppColor.success
        case .warning: return AppColor.warning
        case .danger: return AppColor.error
        }
    }
}

final class Notify {

    private static var currentView: NotifyContainerView?

    static func show(message: String,
                     position: NotifyPosition = .top,
                     type: NotifyType = .default,
                     duration: TimeInterval = 3.0,
                     closeable: Bool = false,
                     leftIcon: UIView? = nil,
                     rightIcon: UIView? = nil,
                     distance: CGFloat = 8,
                     navHeight: CGFloat = 57,
                     onClick: (() -> Void)? = nil,
                     onClose: (() -> Void)? = nil) {
        // 清除现有
        clear()

        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) ??
            UIApplication.shared.windows.first else { return }

        let container = NotifyContainerView(message: message,
                                            position: position,
                                            type: type,
                                            duration: duration,
                                            closeable: closeable,
                                            leftIcon: leftIcon,
                                            rightIcon: rightIcon,
                                            distance: distance,
                                            navHeight: navHeight,
                                            onClick: onClick,
                                            onClose: onClose)
        window.addSubview(container)

        switch position {
        case .top:
            let topInset = window.safeAreaInsets.top + navHeight + distance
            container.snp.makeConstraints { make in
                make.left.right.equalToSuperview()
                make.top.equalToSuperview().offset(topInset)
            }
        case .bottom:
            let bottomInset = window.safeAreaInsets.bottom + distance
            container.snp.makeConstraints { make in
                make.left.right.equalToSuperview()
                make.bottom.equalToSuperview().offset(-bottomInset)
            }
        }

        // 进入动画
        container.alpha = 0
        container.transform = CGAffineTransform(translationX: 0, y: position == .top ? -40 : 40)
        UIView.animate(withDuration: 0.3) {
            container.alpha = 1
            container.transform = .identity
        }

        // 自动消失
        if duration > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak container] in
                guard let container = container, container === currentView else { return }
                dismiss(container: container, position: position, onClose: onClose)
            }
        }

        currentView = container
    }

    static func clear() {
        guard let container = currentView else { return }
        dismiss(container: container, position: .top, onClose: nil)
    }

    private static func dismiss(container: NotifyContainerView, position: NotifyPosition, onClose: (() -> Void)?) {
        UIView.animate(withDuration: 0.3, animations: {
            container.alpha = 0
            container.transform = CGAffineTransform(translationX: 0, y: position == .top ? -40 : 40)
        }, completion: { _ in
            container.removeFromSuperview()
            currentView = nil
            onClose?()
        })
    }
}

private final class NotifyContainerView: UIView {

    private let message: String
    private let type: NotifyType
    private let closeable: Bool
    private let onClick: (() -> Void)?
    private let onClose: (() -> Void)?

    init(message: String,
         position: NotifyPosition,
         type: NotifyType,
         duration: TimeInterval,
         closeable: Bool,
         leftIcon: UIView?,
         rightIcon: UIView?,
         distance: CGFloat,
         navHeight: CGFloat,
         onClick: (() -> Void)?,
         onClose: (() -> Void)?) {
        self.message = message
        self.type = type
        self.closeable = closeable
        self.onClick = onClick
        self.onClose = onClose
        super.init(frame: .zero)
        setupViews(leftIcon: leftIcon, rightIcon: rightIcon)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }

    private func setupViews(leftIcon: UIView?, rightIcon: UIView?) {
        backgroundColor = type.backgroundColor

        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = AppSpace.sm
        addSubview(stack)
        stack.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(AppSpace.lg)
            make.right.equalToSuperview().offset(-AppSpace.lg)
            make.centerY.equalToSuperview()
        }

        snp.makeConstraints { make in
            make.height.equalTo(40)
        }

        // 左侧图标
        let leftView: UIView
        if let leftIcon = leftIcon {
            leftView = leftIcon
        } else {
            let icon = UILabel()
            icon.text = "📢"
            icon.font = .systemFont(ofSize: AppFont.sizeMd)
            leftView = icon
        }
        stack.addArrangedSubview(leftView)

        // 文本
        let label = UILabel()
        label.text = message
        label.textColor = UIColor.white
        label.font = .systemFont(ofSize: AppFont.sizeSm)
        stack.addArrangedSubview(label)
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)

        // 右侧图标
        let rightView: UIView
        if let rightIcon = rightIcon {
            rightView = rightIcon
        } else if closeable {
            let closeBtn = UIButton(type: .system)
            closeBtn.setTitle("✕", for: .normal)
            closeBtn.setTitleColor(UIColor.white, for: .normal)
            closeBtn.titleLabel?.font = .systemFont(ofSize: AppFont.sizeSm)
            closeBtn.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
            rightView = closeBtn
        } else {
            rightView = UIView()
        }
        stack.addArrangedSubview(rightView)

        // 点击手势
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapContent))
        addGestureRecognizer(tap)
    }

    @objc private func didTapContent() {
        onClick?()
    }

    @objc private func didTapClose() {
        Notify.clear()
        onClose?()
    }
}
