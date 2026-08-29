/// 原生页面路由：Tab 切换与按产品页编号 push 目标页。

import UIKit

/// 目标页解析器 —— 由宿主 App 注入，把通用 [AppRouter.Destination] 映射为真实业务控制器。
///
/// 中台包只负责通用导航机制（Tab 切换 / push / pop），**具体页面构造交由宿主注入**，
/// 从而与业务解耦、可独立编译。未注入 provider 或返回 nil 时回退到占位页。
protocol RouterDestinationProvider: AnyObject {
    /// 解析目标页控制器。
    ///
    /// - Parameters:
    ///   - destination: 目标页枚举
    ///   - yearMonth: 可选 `(年, 月)`；部分页面（如排行）依赖该参数，nil 用当前月
    /// - Returns: 目标控制器；返回 nil 时由 AppRouter 回退占位页
    func makeViewController(for destination: AppRouter.Destination, yearMonth: (Int, Int)?) -> UIViewController?
}

/// 应用内导航路由。
///
/// ## 路由策略
/// - **一级页**（明细 / 图表 / 记账 / 发现 / 我的）：各 Tab 根控制器，显示底部主导航。
/// - **二级及以下**：一律 `push` 进入；`hidesBottomBarWhenPushed = true` 隐藏底栏；
///   导航栈自动提供左上角返回（系统 Back）。
///
/// ## 业务解耦
/// 目标页解析经 [provider] 注入，AppRouter 本身不依赖任何业务控制器。
enum AppRouter {
    /// 目标页解析器；宿主 App 启动时注入。
    static var provider: RouterDestinationProvider?
    /// 底部 Tab 索引，与 `MainTabBarController` 顺序一致。
    enum Tab: Int {
        case ledger = 0
        case charts = 1
        case bookkeeping = 2
        case discover = 3
        case profile = 4
    }

    /// 可 push 的目标页面。
    enum Destination {
        case incomeList     // 1.1
        case expenseList    // 1.2
        case bill           // 1.3
        case budget         // 1.4
        case assetsHome     // 1.5
        case more           // 1.8
        case mortgageCalculator // 4.4
        case fxConverter        // 4.5
        case invoiceHelper      // 4.6
        case couponSaver        // 4.7
        case recurringRules     // B4 周期记账规则管理
        case myLedgers          // 5.1
        case familyBill         // 5.2
        case settings           // 5.3
        case accountSecurity    // 5.4
        case help               // 5.5
        case feedback           // 5.6
        case about              // 5.7
        case accountSettings    // 5.8
    }

    /// 切换根 TabBar 选中项。
    ///
    /// - Parameter tab: 目标 Tab
    /// - Returns: 无
    static func selectTab(_ tab: Tab) {
        guard
            let window = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .flatMap(\.windows)
                .first(where: \.isKeyWindow),
            let tabBar = window.rootViewController as? UITabBarController
        else { return }
        tabBar.selectedIndex = tab.rawValue
    }

    /// 从宿主页面 push 二级页（隐藏底栏，保留系统返回）。
    ///
    /// - Parameters:
    ///   - viewController: 目标控制器
    ///   - host: 发起导航的视图控制器
    /// - Returns: 无
    static func push(_ viewController: UIViewController, from host: UIViewController) {
        viewController.hidesBottomBarWhenPushed = true
        guard let nav = navigationController(from: host) else { return }
        // 记账等一级页可能隐藏导航栏，二级页需恢复以便返回。
        nav.setNavigationBarHidden(false, animated: true)
        nav.pushViewController(viewController, animated: true)
    }

    /// 从宿主页面 push 目标页（年月取当前月）。
    ///
    /// - Parameters:
    ///   - destination: 目标页面
    ///   - host: 发起导航的视图控制器
    /// - Returns: 无
    static func open(_ destination: Destination, from host: UIViewController) {
        open(destination, yearMonth: nil, from: host)
    }

    /// 打开指定年月的收入排行页（1.1）。
    ///
    /// - Parameters:
    ///   - year: 公历年
    ///   - month: 月份 1...12
    ///   - host: 发起导航的视图控制器
    /// - Returns: 无
    static func openIncome(year: Int, month: Int, from host: UIViewController) {
        open(.incomeList, yearMonth: (year, month), from: host)
    }

    /// 打开指定年月的支出排行页（1.2）。
    ///
    /// - Parameters:
    ///   - year: 公历年
    ///   - month: 月份 1...12
    ///   - host: 发起导航的视图控制器
    /// - Returns: 无
    static func openExpense(year: Int, month: Int, from host: UIViewController) {
        open(.expenseList, yearMonth: (year, month), from: host)
    }

    /// 解析目标页并 push；私有入口支持可选年月。
    ///
    /// - Parameters:
    ///   - destination: 目标页面
    ///   - yearMonth: 可选 `(年, 月)`，nil 时用当前月
    ///   - host: 发起导航的视图控制器
    /// - Returns: 无
    private static func open(_ destination: Destination, yearMonth: (Int, Int)?, from host: UIViewController) {
        let now = yearMonth ?? (CalendarFormatter.components().year, CalendarFormatter.components().month)
        // 优先由宿主 provider 解析真实业务控制器；未注入或解析失败时回退占位页。
        let vc = provider?.makeViewController(for: destination, yearMonth: (now.0, now.1))
            ?? NativePlaceholderViewController(
                pageId: String(describing: destination),
                titleText: "原生页占位（未注入 \(destination)）"
            )
        push(vc, from: host)
    }

    /// 解析可用于 push 的导航控制器。
    ///
    /// - Parameter host: 发起导航的视图控制器
    /// - Returns: 导航控制器；找不到时为 nil
    private static func navigationController(from host: UIViewController) -> UINavigationController? {
        if let nav = host.navigationController { return nav }
        if let nav = host as? UINavigationController { return nav }
        return host.tabBarController?.selectedViewController as? UINavigationController
    }
}

/// 尚未实现的 Feature 页占位控制器。
final class NativePlaceholderViewController: UIViewController {
    private let pageId: String
    private let titleText: String

    /// 创建占位页。
    ///
    /// - Parameters:
    ///   - pageId: 产品页编号
    ///   - titleText: 导航栏标题
    /// - Returns: 无
    init(pageId: String, titleText: String) {
        self.pageId = pageId
        self.titleText = titleText
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    /// 展示占位说明文案。
    ///
    /// - Returns: 无
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColor.bgPage
        title = titleText

        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = AppColor.textSecondary
        label.font = .systemFont(ofSize: AppFont.sizeMd)
        label.text = "原生页占位\n编号：\(pageId)\n（后续在对应 Feature 中实现）"
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
