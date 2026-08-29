/// 中台基础按钮组件（UIKit 版，对齐 Android 中台 AppButton）。
///
/// 对齐「本机号码一键登录」主按钮样式：48pt 高、圆角 lg、主色填充 + 白色半粗字。
/// 作为中台基础组件统一登录/注册/弹窗/表单等所有主操作按钮视觉，禁止各页面单独发挥。
///
/// 用法：
/// ```swift
/// let button = AppButton.primary("登录")
/// button.addTarget(self, action: #selector(tapLogin), for: .touchUpInside)
/// button.setLoading(true)   // 加载中置灰 + 文案"加载中..."
/// button.setAppEnabled(false) // 置灰不可点
/// ```

import UIKit

/// 中台基础按钮视觉样式。
enum AppButtonStyle {
    /// 主操作：主色填充 + 白字（本机一键登录样式）。
    case primary
    /// 次要操作：白底 + 主色描边 + 主色文字。
    case secondary
    /// 破坏性操作：白底 + 红色描边 + 红色文字。
    case destructive
}

/// 中台基础按钮组件（UIKit）。
final class AppButton: UIButton {
    /// 按钮视觉样式。
    private var buttonStyle: AppButtonStyle = .primary

    /// 是否处于加载态（置灰 + 文案"加载中..."，不可点击）。
    private var isLoading = false

    /// 是否需要最小高度（非通栏时用于撑高）。
    /// 通栏按钮由外部约束高度；这里提供 48pt 的默认内容高度兜底。
    static let standardHeight: CGFloat = 48

    // MARK: - 工厂方法

    /// 主操作按钮（主色填充 + 白字）。
    static func primary(_ title: String) -> AppButton {
        makeButton(title: title, style: .primary)
    }

    /// 次要操作按钮（白底 + 主色描边 + 主色文字）。
    static func secondary(_ title: String) -> AppButton {
        makeButton(title: title, style: .secondary)
    }

    /// 破坏性操作按钮（白底 + 红色描边 + 红色文字）。
    static func destructive(_ title: String) -> AppButton {
        makeButton(title: title, style: .destructive)
    }

    private static func makeButton(title: String, style: AppButtonStyle) -> AppButton {
        let button = AppButton(type: .custom)
        button.buttonStyle = style
        button.applyStyle()
        button.setAppTitle(title)
        return button
    }

    // MARK: - 对外接口

    /// 设置按钮文案。
    func setAppTitle(_ title: String) {
        setTitle(title, for: .normal)
    }

    /// 设置可用状态；false 时置灰且不可点击。
    func setAppEnabled(_ enabled: Bool) {
        isEnabled = enabled
        updateBackground()
    }

    /// 设置加载态；true 时置灰并显示"加载中..."，不可点击。
    func setLoading(_ loading: Bool) {
        isLoading = loading
        isEnabled = !loading
        if loading {
            setTitle("加载中...", for: .normal)
        } else {
            updateBackground()
        }
    }

    // MARK: - 样式

    private func applyStyle() {
        titleLabel?.font = .systemFont(ofSize: AppFont.sizeMd, weight: .semibold)
        layer.cornerRadius = AppRadius.lg
        clipsToBounds = true
        updateBackground()
    }

    private func updateBackground() {
        let disabledColor = UIColor(hex: 0x9CA3AF)
        let disabledTitle = UIColor.white

        let (bg, border, title): (UIColor, UIColor?, UIColor) = {
            if !isEnabled || isLoading {
                return (disabledColor, nil, disabledTitle)
            }
            switch buttonStyle {
            case .primary:
                return (AppColor.primary, nil, .white)
            case .secondary:
                return (.white, AppColor.primary, AppColor.primary)
            case .destructive:
                return (.white, AppColor.error, AppColor.error)
            }
        }()

        backgroundColor = bg
        setTitleColor(title, for: .normal)
        setTitleColor(title.withAlphaComponent(0.6), for: .highlighted)
        layer.borderWidth = border == nil ? 0 : 1
        layer.borderColor = border?.cgColor
    }

    override var isHighlighted: Bool {
        didSet {
            // 主操作按下态用深一档主色，其余样式用透明度反馈。
            if buttonStyle == .primary && isEnabled && !isLoading {
                backgroundColor = isHighlighted ? AppColor.primaryPressed : AppColor.primary
            }
        }
    }
}
