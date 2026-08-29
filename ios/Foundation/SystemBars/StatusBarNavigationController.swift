/// 导航容器：将状态栏样式委托给栈顶页面（明细页浅绿底需 lightContent）。

import UIKit

/// 转发顶层 VC 的状态栏样式。
///
/// 明细页等子页面通过 `preferredStatusBarStyle` 控制状态栏颜色。
final class StatusBarNavigationController: UINavigationController {
    /// 将状态栏样式决策委托给栈顶视图控制器。
    ///
    /// - Returns: 栈顶视图控制器
    override var childForStatusBarStyle: UIViewController? { topViewController }

    /// 将状态栏显隐决策委托给栈顶视图控制器。
    ///
    /// - Returns: 栈顶视图控制器
    override var childForStatusBarHidden: UIViewController? { topViewController }
}
