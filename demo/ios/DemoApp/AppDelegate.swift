import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let nav = UINavigationController(rootViewController: DemoListViewController())
        nav.navigationBar.prefersLargeTitles = true
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = nav
        window.makeKeyAndVisible()
        self.window = window
        // TEMP-DEBUG（验证后删除）：OPEN_SHOWCASE=ui.drag 时自动进入 Drag Demo 页截图比对
        if ProcessInfo.processInfo.environment["OPEN_SHOWCASE"] == "ui.drag" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                nav.pushViewController(DragShowcase(), animated: false)
            }
        }
        return true
    }
}