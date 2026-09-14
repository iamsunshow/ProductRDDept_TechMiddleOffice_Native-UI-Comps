/// 按页声明系统栏外观（底色 + 图标明暗）——组件级轻量工具。

import UIKit

/// 系统栏样式枚举与应用辅助。
///
/// ## 定位
/// 按页声明系统栏外观三态（默认 / 沉浸 / 透明）。Android 侧对应
/// `ConfigureSystemBars(statusBarColor)`（可直接设窗口状态栏底色）；
/// **iOS 系统不提供状态栏背景色 API**，沉浸态底色由页面在状态栏安全区
/// 自绘等价色块实现（[SystemBars.background(for:)] 提供该色值），
/// 图标明暗经 `preferredStatusBarStyle` 显式声明（差异表已放行）。
enum SystemBars {
    /// 系统栏三态。
    enum Style: String, CaseIterable {
        /// 默认态：白底（bgCard）深色图标。
        case `default` = "默认（白底深字）"
        /// 沉浸态：品牌绿底（primary）浅色图标。
        case immersive = "沉浸（绿底白字）"
        /// 透明态：透明底深色图标（页面内容延伸到状态栏下方）。
        case transparent = "透明（透明底深字）"
    }

    /// 状态栏底色（供页面在安全区自绘等价视觉）。
    ///
    /// - Parameter style: 系统栏样式
    /// - Returns: 底色
    static func background(for style: Style) -> UIColor {
        switch style {
        case .default: return AppColor.bgCard
        case .immersive: return AppColor.primary
        case .transparent: return UIColor.clear
        }
    }

    /// 状态栏图标明暗样式。
    ///
    /// - Parameter style: 系统栏样式
    /// - Returns: 深色图标（default/transparent）或浅色图标（immersive）
    static func statusBarStyle(for style: Style) -> UIStatusBarStyle {
        switch style {
        case .default, .transparent: return UIStatusBarStyle.default
        case .immersive: return UIStatusBarStyle.lightContent
        }
    }

    /// 刷新宿主页状态栏外观（样式变更后调用）。
    ///
    /// - Parameter viewController: 当前页面（触发 `setNeedsStatusBarAppearanceUpdate`）
    static func refresh(on viewController: UIViewController) {
        viewController.setNeedsStatusBarAppearanceUpdate()
    }
}
