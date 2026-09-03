/// 全局配置 ConfigProvider（UIKit 命令式版，对齐 Android ConfigProvider / api.json `ui.config-provider`）。
///
/// 定位：design-token 静态基准（AppTokens）之上的**运行时覆盖层**。本组件不产出视觉像素，
/// 只提供「配置通道」：消费组件经 [AppTheme] 解析属性读取合并后的配置；未挂 ConfigProvider 时
/// 解析属性返回静态基准，零行为变化（D1）。
///
/// 契约 props（与 api.json 对齐，nil = 未覆盖、取父级/静态基准）：
/// - `primaryColor`：主题色覆盖（十六进制字符串，如 "#4F46E5"）
/// - `rounded`：圆角升一档（sm→md，md→lg，lg 封顶）
/// - `compact`：间距降一档（md→sm，lg→md，xl→lg）
/// - `locale`：文案语言（'zh-CN' | 'en-US'）
///
/// 覆盖语义：内层覆盖外层同名项；外层未覆盖项继承；全未设取静态基准（D6）。
///
/// 双通道（平台差异登记 `docs/平台差异.md`）：
/// - 命令式（UIKit）：[ConfigProvider] 作用域栈 push/pop，消费组件在渲染时刻读 [AppTheme]
/// - 声明式（SwiftUI）：环境对象通道，未来引入 SwiftUI 包装组件时经 `AppTheme` 同一解析层
///
/// 消费组件接入（读取解析层改造）属后续版本渐进落地；本文件提供配置容器 + 解析层本身。

import UIKit

/// 全局配置数据（值类型，运行时覆盖层）。
struct AppConfig {
    /// 主题色覆盖（UIKit 颜色）。
    var primaryColor: UIColor?
    /// 圆角模式：true 时全局圆角提升一档（radius.sm→md，md→lg，lg 封顶）。
    var rounded: Bool?
    /// 紧凑尺寸模式：true 时全局间距降一档（space.md→sm，lg→md，xl→lg；sm 不降）。
    var compact: Bool?
    /// 文案语言，默认 'zh-CN'。
    var locale: String?

    /// 静态基准等价物：全字段 nil，解析层回退 AppTokens。
    static let baseline = AppConfig()

    /// 合并：self 为父级（外层），overlay 覆盖同名项（内层优先）。
    func merged(with overlay: AppConfig) -> AppConfig {
        AppConfig(
            primaryColor: overlay.primaryColor ?? primaryColor,
            rounded: overlay.rounded ?? rounded,
            compact: overlay.compact ?? compact,
            locale: overlay.locale ?? locale
        )
    }
}

extension UIColor {
    /// 解析 "#4F46E5" / "4F46E5" / "#abc" 形式十六进制为颜色；非法输入返回 nil。
    /// 对齐 Android `parseHexColor`（支持 6 位 / 3 位，带或不带 # 前缀）。
    convenience init?(hexString: String) {
        let hex = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
        let scanner = Scanner(string: hex)
        var value: UInt64 = 0
        guard scanner.scanHexInt64(&value) else { return nil }

        switch hex.count {
        case 6:
            self.init(
                red: CGFloat((value >> 16) & 0xFF) / 255,
                green: CGFloat((value >> 8) & 0xFF) / 255,
                blue: CGFloat(value & 0xFF) / 255,
                alpha: 1
            )
        case 3:
            let r = CGFloat((value >> 8) & 0xF)
            let g = CGFloat((value >> 4) & 0xF)
            let b = CGFloat(value & 0xF)
            self.init(
                red: (r * 17) / 255,
                green: (g * 17) / 255,
                blue: (b * 17) / 255,
                alpha: 1
            )
        default:
            return nil
        }
    }
}

/// 全局配置 ConfigProvider（UIKit 命令式通道）。
///
/// 以「作用域栈」表达嵌套 Provider：进入子树渲染前 push（内层覆盖外层、未设继承），
/// 渲染结束 pop 恢复父级配置。栈底恒为静态基准（[AppConfig.baseline]）。
///
/// 用法（ViewController 渲染子树）：
/// ```swift
/// // 方式一：闭包自动 push/pop（推荐）
/// ConfigProvider.withScope(AppConfig(primaryColor: UIColor(hexString: "#4F46E5"), compact: true)) {
///     // 此子树内 AppTheme.primaryColor / space* 等读取覆盖后结果
/// }
///
/// // 方式二：显式 push/pop（跨方法作用域）
/// ConfigProvider.push(AppConfig(rounded: true))
/// defer { ConfigProvider.pop() }
/// ```
final class ConfigProvider {
    /// 作用域栈；栈底 = 静态基准，越靠栈顶越内层。
    private static var stack: [AppConfig] = [.baseline]

    /// 当前生效配置（栈顶 = 合并后的最内层；空栈回退静态基准）。
    static var current: AppConfig { stack.last ?? .baseline }

    /// 进入一层配置作用域：overlay 覆盖当前生效配置，生成新栈顶。
    static func push(_ overlay: AppConfig) {
        stack.append(current.merged(with: overlay))
    }

    /// 退出一层配置作用域；栈底（静态基准）不可弹出。
    static func pop() {
        guard stack.count > 1 else { return }
        stack.removeLast()
    }

    /// 以闭包方式执行配置作用域：进入 push，闭包返回前自动 pop（含抛错路径）。
    /// - Returns: 闭包返回值。
    static func withScope<T>(_ overlay: AppConfig, _ body: () -> T) -> T {
        push(overlay)
        defer { pop() }
        return body()
    }

    /// 仅供测试复位作用域栈到静态基准。
    static func resetForTesting() {
        stack = [.baseline]
    }
}

/// 读取解析层：消费组件读取 token 的唯一入口（与 Android `AppTheme` 同名同函数集）。
///
/// 规则：先查当前配置（[ConfigProvider.current]）覆盖项，未覆盖回退静态基准（AppTokens）。
/// - rounded = true → 圆角升一档：sm→md、md→lg、lg 封顶
/// - compact = true → 间距降一档：md→sm、lg→md、xl→lg（sm 不降）
enum AppTheme {
    /// 主题色（主色）。
    static var primaryColor: UIColor {
        ConfigProvider.current.primaryColor ?? AppColor.primary
    }

    /// 圆角档位解析（rounded 升档）。sm 档：6 → rounded 后 10。
    static var radiusSm: CGFloat {
        ConfigProvider.current.rounded == true ? AppRadius.md : AppRadius.sm
    }

    /// 圆角档位解析（rounded 升档）。md 档：10 → rounded 后 14。
    static var radiusMd: CGFloat {
        ConfigProvider.current.rounded == true ? AppRadius.lg : AppRadius.md
    }

    /// 圆角档位解析（rounded 升档）。lg 档封顶（无 xl token）：默认 14，rounded 仍 14。
    static var radiusLg: CGFloat { AppRadius.lg }

    /// 间距档位解析（compact 降档）。sm 档不降：默认 8，compact 仍 8。
    static var spaceSm: CGFloat { AppSpace.sm }

    /// 间距档位解析（compact 降档）。md 档：默认 12 → compact 后 8。
    static var spaceMd: CGFloat {
        ConfigProvider.current.compact == true ? AppSpace.sm : AppSpace.md
    }

    /// 间距档位解析（compact 降档）。lg 档：默认 16 → compact 后 12。
    static var spaceLg: CGFloat {
        ConfigProvider.current.compact == true ? AppSpace.md : AppSpace.lg
    }

    /// 间距档位解析（compact 降档）。xl 档：默认 24 → compact 后 16。
    static var spaceXl: CGFloat {
        ConfigProvider.current.compact == true ? AppSpace.lg : AppSpace.xl
    }

    /// 文案语言：默认 'zh-CN'。
    static var locale: String { ConfigProvider.current.locale ?? "zh-CN" }
}
