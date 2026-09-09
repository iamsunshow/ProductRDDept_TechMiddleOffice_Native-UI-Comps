//
//  ToastView.swift
//  SharedUI
//
//  组件 ID：`ui.toast` ｜ 任务清单 #59 ｜ 操作反馈区第十五件 ｜ TMO 组件库 v1.4.14
//
//  定位：全局轻量提示浮层——屏幕居中短时显示文本+类型图标，自动消失，不阻断用户操作。
//
//  结构：
//  - ToastType（枚举）：success/error/warning/info/loading/text
//  - Toast（静态方法）：show/success/error/warning/info/loading/dismiss
//
//  契约 props（与 api.json 100% 对齐）：
//  - Toast.show(message, type, duration)：显示一条 Toast
//  - Toast.success/error/warning/info(message, duration=2s)：快捷类型提示
//  - Toast.loading(message)：显示 loading（不自动消失）
//  - Toast.dismiss()：手动关闭
//
//  设计规格（design-spec/toast-design-spec.html）：
//  - 浮层背景 rgba(26,26,26,0.9)，文字 #fff fontMd(16)
//  - 圆角 radiusMd(8)，内边距 10×16，最大宽 80%
//  - 动画 0.25s easeOut 淡入淡出
//  - 层级 Window 最顶层（windowLevel = .alert）
//
//  用法：
//  ```swift
//  Toast.success("保存成功")
//  Toast.loading("加载中...")
//  // 2 秒后
//  Toast.dismiss()
//  ```

import UIKit

// MARK: - Toast 类型

/// Toast 类型枚举（success/error/warning/info/loading/text）。
public enum ToastType {
    case success
    case error
    case warning
    case info
    case loading
    case text

    /// 类型图标颜色（icon 色彩，loading 用白色 spinner）。
    var color: UIColor {
        switch self {
        case .success: return UIColor(red: 0.086, green: 0.639, blue: 0.290, alpha: 1)   // #16A34A
        case .error:   return UIColor(red: 0.863, green: 0.149, blue: 0.149, alpha: 1)   // #DC2626
        case .warning: return UIColor(red: 0.961, green: 0.620, blue: 0.043, alpha: 1)    // #F59E0B
        case .info:    return UIColor(red: 0.231, green: 0.510, blue: 0.965, alpha: 1)    // #3B82F6
        case .loading, .text: return .white
        }
    }

    /// 类型图标符号（SF Symbols），text 类型无图标。
    var iconName: String? {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .error:   return "xmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .info:    return "info.circle.fill"
        case .loading, .text: return nil
        }
    }
}

// MARK: - Toast 单例

/// 全局轻量提示浮层（静态方法调用，单例管理显示/消失）。
public final class Toast {

    // MARK: - 常量

    private enum Layout {
        static let paddingV: CGFloat = 10
        static let paddingH: CGFloat = 16
        static let cornerRadius: CGFloat = 8
        static let maxWidthRatio: CGFloat = 0.8
        static let animDuration: TimeInterval = 0.25
        static let defaultDuration: TimeInterval = 2.0
        static let spinnerSize: CGFloat = 24
        static let iconSize: CGFloat = 20
        static let spacing: CGFloat = 8
    }

    // MARK: - 单例

    public static let shared = Toast()
    private init() {}

    // MARK: - 状态

    private var toastWindow: UIWindow?
    private var toastView: UIView?
    private var dismissWork: DispatchWorkItem?

    // MARK: - 静态方法

    /// 显示一条 Toast（默认 text 类型，默认 2 秒）。
    public static func show(message: String, type: ToastType = .text, duration: TimeInterval = 2.0) {
        shared.display(message: message, type: type, duration: duration)
    }

    /// 成功提示（绿色 ✓，默认 2 秒）。
    public static func success(_ message: String, duration: TimeInterval = 2.0) {
        shared.display(message: message, type: .success, duration: duration)
    }

    /// 错误提示（红色 ✗，默认 2 秒）。
    public static func error(_ message: String, duration: TimeInterval = 2.0) {
        shared.display(message: message, type: .error, duration: duration)
    }

    /// 警告提示（黄色 ⚠，默认 2 秒）。
    public static func warning(_ message: String, duration: TimeInterval = 2.0) {
        shared.display(message: message, type: .warning, duration: duration)
    }

    /// 信息提示（蓝色 ℹ，默认 2 秒）。
    public static func info(_ message: String, duration: TimeInterval = 2.0) {
        shared.display(message: message, type: .info, duration: duration)
    }

    /// Loading 提示（白色 spinner，不自动消失，需手动 dismiss）。
    public static func loading(_ message: String) {
        shared.display(message: message, type: .loading, duration: nil)
    }

    /// 手动关闭当前 Toast。
    public static func dismiss() {
        shared.hideToast()
    }

    // MARK: - 内部显示

    private func display(message: String, type: ToastType, duration: TimeInterval?) {
        DispatchQueue.main.async { self._display(message: message, type: type, duration: duration) }
    }

    private func _display(message: String, type: ToastType, duration: TimeInterval?) {
        // 清除已有 Toast
        hideToast(immediately: true)

        // 创建 Window
        let window = ToastWindow(frame: UIScreen.main.bounds)
        window.windowLevel = .alert
        window.backgroundColor = .clear
        window.isUserInteractionEnabled = false    // 不阻断下层交互

        // 透明 rootVC
        let rootVC = UIViewController()
        rootVC.view.backgroundColor = .clear
        window.rootViewController = rootVC
        window.isHidden = false
        toastWindow = window

        // 创建 Toast 视图
        let container = makeToastView(message: message, type: type)
        container.alpha = 0
        rootVC.view.addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            container.centerXAnchor.constraint(equalTo: rootVC.view.centerXAnchor),
            container.centerYAnchor.constraint(equalTo: rootVC.view.centerYAnchor),
            container.widthAnchor.constraint(lessThanOrEqualTo: rootVC.view.widthAnchor, multiplier: Layout.maxWidthRatio)
        ])
        toastView = container

        // 淡入
        UIView.animate(withDuration: Layout.animDuration, delay: 0, options: .curveEaseOut) {
            container.alpha = 1
        }

        // 自动消失
        if let duration = duration {
            let work = DispatchWorkItem { [weak self] in self?.hideToast() }
            dismissWork = work
            DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: work)
        }
    }

    // MARK: - 构造 Toast 视图

    private func makeToastView(message: String, type: ToastType) -> UIView {
        let container = UIView()
        container.backgroundColor = UIColor(white: 0.102, alpha: 0.9)   // rgba(26,26,26,0.9)
        container.layer.cornerRadius = Layout.cornerRadius
        container.layer.masksToBounds = true

        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = Layout.spacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: Layout.paddingV),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -Layout.paddingV),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: Layout.paddingH),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -Layout.paddingH)
        ])

        // 图标/loading
        if type == .loading {
            let spinner = UIActivityIndicatorView(style: .white)
            spinner.startAnimating()
            stack.addArrangedSubview(spinner)
            spinner.widthAnchor.constraint(equalToConstant: Layout.spinnerSize).isActive = true
            spinner.heightAnchor.constraint(equalToConstant: Layout.spinnerSize).isActive = true
        } else if let name = type.iconName {
            let icon = UIImageView(image: UIImage(systemName: name))
            icon.tintColor = type.color
            icon.contentMode = .scaleAspectFit
            stack.addArrangedSubview(icon)
            icon.widthAnchor.constraint(equalToConstant: Layout.iconSize).isActive = true
            icon.heightAnchor.constraint(equalToConstant: Layout.iconSize).isActive = true
        }

        // 文本
        let label = UILabel()
        label.text = message
        label.textColor = .white
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.textAlignment = .center
        stack.addArrangedSubview(label)

        return container
    }

    // MARK: - 隐藏

    private func hideToast(immediately: Bool = false) {
        dismissWork?.cancel()
        dismissWork = nil

        guard let view = toastView else {
            toastWindow?.isHidden = true
            toastWindow = nil
            return
        }

        if immediately {
            view.alpha = 0
            toastWindow?.isHidden = true
            toastWindow = nil
            toastView = nil
        } else {
            UIView.animate(withDuration: Layout.animDuration, animations: {
                view.alpha = 0
            }) { _ in
                self.toastWindow?.isHidden = true
                self.toastWindow = nil
                self.toastView = nil
            }
        }
    }
}

// MARK: - ToastWindow（透传点击，不阻断下层）

private final class ToastWindow: UIWindow {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // 让 Toast Window 不接收任何触摸事件（透传到下层）
        return nil
    }
}
