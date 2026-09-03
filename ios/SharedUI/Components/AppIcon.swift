/// 中台基础图标组件（UIKit 版，对齐 Android AppIcon）。
///
/// 封装 SF Symbols，统一双端图标使用方式。
/// iOS 直接用系统 SF Symbols（零资源开销），Android 用 SfApproxIcons 矢量近似。
///
/// 用法：
/// ```swift
/// let icon = AppIcon.make(.list, size: 24, color: AppColor.primary)
/// view.addSubview(icon)
/// ```

import UIKit

/// 中台统一图标名（双端共用，iOS 映射 SF Symbol，Android 映射 SfApproxIcons）。
enum AppIconName: String, CaseIterable {
    case list
    case chart
    case plus
    case safari
    case person
    case arrowDown
    case smartphone
    case mail

    /// 对应的 SF Symbol 系统名。
    var sfSymbol: String {
        switch self {
        case .list: return "list.bullet.rectangle"
        case .chart: return "chart.xyaxis.line"
        case .plus: return "plus.circle.fill"
        case .safari: return "safari"
        case .person: return "person"
        case .arrowDown: return "arrowtriangle.down.fill"
        case .smartphone: return "iphone.gen3"
        case .mail: return "envelope"
        }
    }

    /// 语义标签（无障碍 / Demo 展示用）。
    var label: String {
        switch self {
        case .list: return "列表"
        case .chart: return "图表"
        case .plus: return "加号"
        case .safari: return "浏览器"
        case .person: return "人物"
        case .arrowDown: return "下拉三角"
        case .smartphone: return "手机"
        case .mail: return "邮箱"
        }
    }
}

/// 中台基础图标组件（UIKit）。
final class AppIcon: UIImageView {
    /// 图标名。
    private(set) var iconName: AppIconName = .list

    /// 默认尺寸。
    static let defaultSize: CGFloat = 24

    // MARK: - 工厂方法

    /// 创建图标。
    /// - Parameters:
    ///   - name: 图标名（双端统一枚举）。
    ///   - size: 尺寸（pt），默认 24。
    ///   - color: 着色（tintColor），默认 textPrimary。
    /// - Returns: 配置好的 AppIcon 实例，已约束宽高。
    static func make(
        _ name: AppIconName,
        size: CGFloat = defaultSize,
        color: UIColor = AppColor.textPrimary
    ) -> AppIcon {
        let icon = AppIcon()
        icon.iconName = name
        // 强制 SF Symbol 单色（monochrome）轮廓渲染，与 Android SfApproxIcons 矢量着色语义一致。
        // 否则「iphone.gen3」等多色符号会保留内部屏幕渐变/Home Indicator 颜色，
        // 忽略 tintColor，导致双端视觉不一致（iOS 有内色 vs Android 纯白/纯色）。
        let config = UIImage.SymbolConfiguration.preferringMonochrome()
        icon.image = UIImage(systemName: name.sfSymbol, withConfiguration: config)
        icon.tintColor = color
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.widthAnchor.constraint(equalToConstant: size).isActive = true
        icon.heightAnchor.constraint(equalToConstant: size).isActive = true
        return icon
    }

    /// 更新着色。
    func setColor(_ color: UIColor) {
        tintColor = color
    }
}
