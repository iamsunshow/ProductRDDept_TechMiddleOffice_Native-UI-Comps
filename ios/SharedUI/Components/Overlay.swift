/// Overlay 遮罩层（UIKit 版，对齐 Android Overlay.kt / api.json `ui.overlay`）。
///
/// 定位：全屏遮罩 + 自定义内容插槽 = 所有浮层的**通用底部基座**（Dialog / Drawer / Popover /
/// ActionSheet / 气泡菜单 / 新手引导蒙版等一律组合 Overlay 二次开发，禁手写遮罩）。
/// 组件库版本基线 v1.3.12 → 本期实现升级：MINOR **v1.4.0**（基础组件 6/6 收官）。
///
/// 契约 props（与 api.json 100% 对齐，命名同函数字段）：
/// - visible: Bool （*必选*：显示=true / 卸载关闭=false；切换驱动 fade 动画）
/// - maskColor: OverlayMaskColor = .default / .transparent / .rgba(UIColor)
/// - closeOnMaskClick: Bool（默认 true：点击遮罩空白区域自动触发 onClose；clickThrough=true 时失效）
/// - clickThrough: Bool（默认 false：true 则遮罩不拦截任何事件，穿透到底层页面）
/// - contentPosition: OverlayContentPosition（9 点：center / top / bottom / left / right / topLeft / topRight / bottomLeft / bottomRight；默认 center）
/// - contentOffset: CGPoint（默认 .zero：x 正向右偏移 / y 正向下偏移，单位 pt，与 Android dp 视觉等价）
/// - contentRadius: OverlayRadius（token 档位 .sm/.md/.lg 或数值；默认 0；贴边时边缘两角自动 = 0）
/// - animation: Bool（默认 true；false 时 visible 切换无过渡）
/// - dismissOnBackPress: Bool（iOS 无返回键；本属性读取忽略，为与 Android API 对齐保留）
/// - content: (UIView) -> Void（*必选*：业务向 contentContainer 嵌入自定义子视图）
///
/// 事件（与 api.json 正交一致）：
/// - onClose: () -> Void（遮罩点击关闭 / 返回键（Android 独有）的统一回调；业务层 visible=false 切换不重复触发，仅组件内部发起关闭时触发）
/// - onMaskClick: () -> Void（点击遮罩背景；clickThrough=true 时不触发；closeOnMaskClick=false 仍触发，可用于埋点）
///
/// 设计决策（门禁 A 推荐 A × 4）：
/// P1 挂载：A `UIApplication.shared.keyWindow` addSubview（跨页面层级最高；业务负责 deinit 时 visible=false 清理）
/// P2 动画：A 一期仅 fade 200ms ease-out / 180ms ease-in；抽屉/弹等位移动画归上层插槽（Overlay 只做基座）
/// P3 遮罩点击：A closeOnMaskClick=true（默认）+ clickThrough 独立开关 + onMaskClick/onClose 回调解耦
/// P4 内容位置：A 9 点锚 + contentOffset{x,y} 微调（覆盖 center Modal / top 通知 / bottom 抽屉 / corner 气泡）
///
/// 双端差异（登记 `docs/数据与产物/diff-api.json`）：
/// 1) 挂载：iOS keyWindow / Android Compose Dialog（外部不可见，visible 语义一致）
/// 2) dismissOnBackPress：iOS 无物理返回键，属性读取忽略不报错
/// 3) 圆角掩膜：iOS `CACornerMask` + `maskedCorners`；Android `RoundedCornerShape(topStart/topEnd/…)`
///
/// 用法：
/// ```swift
/// let overlay = Overlay(
///   visible: true,
///   contentPosition: .center,
///   contentRadius: .lg,
///   content: { container in
///       container.addSubview(myDialogView)
///       // ... 布局 myDialogView 到 container
///   },
///   onClose: { /* 业务设置 overlay.visible = false */ }
/// )
/// ```

import UIKit

// MARK: - 枚举（与 api.json 字符串一一对应；双端统一取值）

/// 遮罩颜色（api.json maskColor：'default'|'transparent'|rgba string）。iOS 内部保留 UIColor 扩展。
enum OverlayMaskColor: Equatable {
    case `default`
    case transparent
    case custom(UIColor)

    /// 渲染颜色（使用命名常量避免魔法数字）。
    static let OVERLAY_MASK_ALPHA: CGFloat = 0.55
    static let FEEDBACK_TAP_ALPHA: CGFloat = 0.65

    var resolved: UIColor {
        switch self {
        case .default:
            // textPrimary #111827 × 0.55（设计规格 §02）
            return UIColor(red: 0x11/255.0, green: 0x18/255.0, blue: 0x27/255.0, alpha: Self.OVERLAY_MASK_ALPHA)
        case .transparent:
            // ⚠️ 绝对不能只写 .clear —— Swift 5.9+ implicit return + switch case 单表达式会触发 "Reference to member 'clear' cannot be resolved without a contextual type"（真 build 第 14 条实锤抓包）
            // 必须显式写 UIColor.clear 全名 + 显式 return，与 case .default / case .custom 三分支全显式 return 风格保持一致，永久避免 contextual type 推断边界 bug
            return UIColor.clear
        case .custom(let c):
            return c
        }
    }

    /// 解析 api.json 字符串（'default'/'transparent'/'rgba(r,g,b,a)'/'#RRGGBBAA'）。
    static func parse(_ raw: String) -> OverlayMaskColor {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if trimmed == "default" { return .default }
        if trimmed == "transparent" { return .transparent }
        if trimmed.hasPrefix("rgba("), let c = parseRgba(trimmed) { return .custom(c) }
        if let hex = UIColor(hexString: trimmed) { return .custom(hex) }
        return .default // 非法输入降级 default
    }

    private static func parseRgba(_ s: String) -> UIColor? {
        let body = s.dropFirst(5).dropLast(1).split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        guard body.count == 4 else { return nil }
        let vals = body.compactMap { Double($0) }
        guard vals.count == 4 else { return nil }
        let r = max(0, min(1, vals[0] <= 1 ? vals[0] : vals[0]/255))
        let g = max(0, min(1, vals[1] <= 1 ? vals[1] : vals[1]/255))
        let b = max(0, min(1, vals[2] <= 1 ? vals[2] : vals[2]/255))
        let a = max(0, min(1, vals[3]))
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}

/// 内容位置（9 点锚；api.json contentPosition 枚举值）。
@objc enum OverlayContentPosition: Int {
    case center, top, bottom, left, right
    case topLeft, topRight, bottomLeft, bottomRight

    var rawString: String {
        switch self {
        case .center: return "center"
        case .top: return "top"
        case .bottom: return "bottom"
        case .left: return "left"
        case .right: return "right"
        case .topLeft: return "top-left"
        case .topRight: return "top-right"
        case .bottomLeft: return "bottom-left"
        case .bottomRight: return "bottom-right"
        }
    }

    static func fromString(_ s: String) -> OverlayContentPosition {
        switch s {
        case "top": return .top
        case "bottom": return .bottom
        case "left": return .left
        case "right": return .right
        case "top-left": return .topLeft
        case "top-right": return .topRight
        case "bottom-left": return .bottomLeft
        case "bottom-right": return .bottomRight
        default: return .center
        }
    }

    /// 按 9 点锚拆成水平/垂直系数（0=start/left-top, 0.5=center, 1=end/right-bottom）。
    var anchor: (x: CGFloat, y: CGFloat) {
        switch self {
        case .center:     return (0.5, 0.5)
        case .top:        return (0.5, 0)
        case .bottom:     return (0.5, 1)
        case .left:       return (0, 0.5)
        case .right:      return (1, 0.5)
        case .topLeft:    return (0, 0)
        case .topRight:   return (1, 0)
        case .bottomLeft: return (0, 1)
        case .bottomRight:return (1, 1)
        }
    }

    /// 贴边时需要保留直角（=0）的两角掩码方向：贴 top → 底两角直角；贴 bottom → 顶两角直角；贴 left/right 同理。
    /// 返回哪些角需要设置圆角（=所有角减去贴边侧的两角）；nil = 4 角全圆（非贴边）。
    func edgeMaskedCornersIfPinnedToEdge() -> CACornerMask? {
        switch self {
        case .top, .topLeft, .topRight:       // 顶部贴边：顶部两角直角
            return [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]     // 仅底部两圆角（topLeft/Right 精确时顶边一角贴边，近似用底部两圆角保留顶两边）
        case .bottom, .bottomLeft, .bottomRight:
            return [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        case .left:
            return [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        case .right:
            return [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        case .center:
            return nil  // 不贴边：4 角全部圆
        }
    }
}

/// 内容圆角（token 档位 或 任意数值 pt）。
enum OverlayRadius: Equatable {
    case sm, md, lg
    case value(CGFloat)

    /// 与 design-token radius：sm=6/md=10/lg=14（单位 pt，与 Android Dp 视觉等价）。
    var resolvedValue: CGFloat {
        switch self {
        case .sm: return 6
        case .md: return 10
        case .lg: return 14
        case .value(let v): return max(0, v)
        }
    }

    static func fromStringOrNumber(_ v: Any?) -> OverlayRadius {
        if let s = v as? String {
            switch s {
            case "sm": return .sm
            case "md": return .md
            case "lg": return .lg
            default: return .value(0)
            }
        }
        if let n = v as? CGFloat { return .value(n) }
        if let n = v as? Double { return .value(CGFloat(n)) }
        if let n = v as? Int { return .value(CGFloat(n)) }
        return .value(0)
    }
}

// MARK: - 主组件

final class Overlay: UIView {

    // MARK: 公共属性（props；设置触发重排，visible 切换触发挂载/卸载+动画）

    /// 是否显示（*必选*；设置 true=挂载到 keyWindow + fade-in；false=fade-out 后移除）。
    var visible: Bool = false {
        didSet { applyVisibility(old: oldValue, new: visible) }
    }

    var maskColor: OverlayMaskColor = .default { didSet { overlayMaskView.backgroundColor = maskColor.resolved } }

    var closeOnMaskClick: Bool = true

    /// true 时遮罩完全不拦截事件；穿透到底层视图。`closeOnMaskClick` 与 `onMaskClick` 均不触发。
    var clickThrough: Bool = false {
        didSet {
            // 穿透=关闭 userInteraction；默认关闭=开启。
            self.isUserInteractionEnabled = !clickThrough
            overlayMaskView.isUserInteractionEnabled = !clickThrough
        }
    }

    var contentPosition: OverlayContentPosition = .center { didSet { setNeedsLayout() } }

    /// 二次偏移（x 正数向右 / y 正数向下；单位 pt；与 contentPosition 锚点叠加）。
    var contentOffset: CGPoint = .zero { didSet { setNeedsLayout() } }

    var contentRadius: OverlayRadius = .value(0) {
        didSet { applyRadius() }
    }

    var animation: Bool = true

    /// iOS 无物理返回键：本属性保留与 Android API 对齐，读取忽略，不报错。
    @available(*, unavailable, message: "iOS 无物理返回键，此属性仅供跨端 API 对齐保留")
    var dismissOnBackPress: Bool { true }

    /// 内容嵌入回调（调用方在闭包内 addSubview 业务内容；contentContainer 会根据内容自适应）。
    var contentBuilder: ((_ contentContainer: UIView) -> Void)? {
        didSet { rebuildContent() }
    }

    // MARK: 公共事件（events）

    /// 组件内部触发"关闭"时回调（① closeOnMaskClick=true 点击遮罩；② Android 返回键；iOS 仅 ①）。
    /// 业务层设置 visible=false 切换不重复触发本回调。
    var onClose: (() -> Void)?

    /// 点击遮罩背景（非内容区域）时触发。clickThrough=true 时不触发。
    var onMaskClick: (() -> Void)?

    // MARK: 动画命名常量（P2 决策 A：fade 200ms / 180ms）

    private static let FADE_IN_DURATION: TimeInterval = 0.20   // 200ms ease-out
    private static let FADE_OUT_DURATION: TimeInterval = 0.18  // 180ms ease-in
    private static let FEEDBACK_DURATION: TimeInterval = 0.08  // 按下态闪 alpha

    // MARK: 内部子视图

    private let overlayMaskView = UIView()           // 全屏遮罩（拦截点击 + 视觉背景；注意：⚠️ 变量名绝对不能叫 overlayMaskView——UIKit UIView 自带 `var overlayMaskView: UIView?` 内置属性，同名会触发 override mutable property + 访问级别 + 协变 三重编译错误，以上8报错前2项即由此而来）
    private let contentContainer = UIView()   // 插槽容器（9 点布局 + 圆角掩膜）
    private var isCurrentlyMounted: Bool = false
    private var tapRecognizer: UITapGestureRecognizer?
    private var pressRecognizer: UILongPressGestureRecognizer?

    // MARK: 生命周期

    convenience init(
        visible: Bool = false,
        maskColor: OverlayMaskColor = .default,
        closeOnMaskClick: Bool = true,
        clickThrough: Bool = false,
        contentPosition: OverlayContentPosition = .center,
        contentOffset: CGPoint = .zero,
        contentRadius: OverlayRadius = .value(0),
        animation: Bool = true,
        content: @escaping (_ contentContainer: UIView) -> Void,
        onClose: (() -> Void)? = nil,
        onMaskClick: (() -> Void)? = nil
    ) {
        // ⚠️ Swift 两阶段初始化 Safety Check 1（永久钉死，真 build 第 15-18 条实锤=4 条 self used before self.init 全由下面这条顺序错触发）：
        // convenience init 必须【先 self.init 代理到同类 designated init】（完成第 1 阶段=对象内存/父类链构造完毕），之后才能给 self 的属性赋值。
        // 绝对不允许先 self.visible = xxx 赋值 → 再 self.init 代理 = 顺序反了！
        self.init(frame: .zero)

        // —— 以下为 Phase 2：self 已完全构造完毕，可安全赋值属性 & 调用方法 ——
        self.visible = visible
        self.maskColor = maskColor
        self.closeOnMaskClick = closeOnMaskClick
        self.clickThrough = clickThrough
        self.contentPosition = contentPosition
        self.contentOffset = contentOffset
        self.contentRadius = contentRadius
        self.animation = animation
        self.contentBuilder = content
        self.onClose = onClose
        self.onMaskClick = onMaskClick
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        // 根视图：透明；只做容器（拦截通过 overlayMaskView）。
        self.backgroundColor = .clear
        self.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        // overlayMaskView：全屏、拦截点击（clickThrough=false 时）
        overlayMaskView.backgroundColor = maskColor.resolved
        overlayMaskView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        overlayMaskView.isUserInteractionEnabled = !clickThrough
        addSubview(overlayMaskView)

        // contentContainer：根据内容自适应尺寸，由布局阶段 9 点锚 + offset 定位
        contentContainer.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.backgroundColor = .clear
        contentContainer.clipsToBounds = true
        addSubview(contentContainer)

        applyRadius()
        installGestures()
        rebuildContent()

        if visible { mountToWindow(animated: animation) }
    }

    // MARK: 圆角：按 contentRadius + 贴边位置自动保留直角

    private func applyRadius() {
        let r = contentRadius.resolvedValue
        contentContainer.layer.cornerRadius = r
        contentContainer.layer.cornerCurve = .continuous
        if let pinOnly = contentPosition.edgeMaskedCornersIfPinnedToEdge(), r > 0 {
            // 贴边时只留朝外的两角为圆角（内侧两角保留直角）
            contentContainer.layer.maskedCorners = pinOnly
        } else {
            contentContainer.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
    }

    // MARK: 手势：mask 点击 / 按压态反馈

    private func installGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleMaskTap(_:)))
        tap.cancelsTouchesInView = false
        tap.delegate = self
        overlayMaskView.addGestureRecognizer(tap)
        self.tapRecognizer = tap

        // 按下态：0.08s 短按模拟 press feedback（闪 alpha）。
        let press = UILongPressGestureRecognizer(target: self, action: #selector(handleMaskPress(_:)))
        press.minimumPressDuration = 0.0
        press.cancelsTouchesInView = false
        press.delegate = self
        overlayMaskView.addGestureRecognizer(press)
        self.pressRecognizer = press
    }

    @objc private func handleMaskTap(_: UITapGestureRecognizer) {
        guard !clickThrough else { return }
        onMaskClick?()
        guard closeOnMaskClick else { return }
        onClose?()
        if animation {
            fadeOutAndUnmount()
        } else {
            unmountFromWindow(animated: false)
        }
    }

    @objc private func handleMaskPress(_ g: UILongPressGestureRecognizer) {
        guard !clickThrough else { return }
        let targetAlpha: CGFloat = (g.state == .began || g.state == .changed)
            ? OverlayMaskColor.FEEDBACK_TAP_ALPHA
            : 1.0
        UIView.animate(withDuration: Self.FEEDBACK_DURATION, delay: 0, options: [.beginFromCurrentState, .allowUserInteraction]) {
            self.overlayMaskView.alpha = targetAlpha
        }
    }

    // MARK: 重建插槽内容（调用方设置 contentBuilder 触发）

    private func rebuildContent() {
        // 清理旧业务视图
        contentContainer.subviews.forEach { $0.removeFromSuperview() }
        if let builder = contentBuilder { builder(contentContainer) }
        setNeedsLayout()
    }

    // MARK: 布局阶段：9 点锚定 + offset 微调

    override func layoutSubviews() {
        super.layoutSubviews()
        overlayMaskView.frame = bounds
        // 让 contentContainer 根据内置子视图算出 intrinsic size
        let fittingSize = contentContainer.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        let (ax, ay) = contentPosition.anchor
        let originX = (bounds.width - fittingSize.width) * ax + contentOffset.x
        let originY = (bounds.height - fittingSize.height) * ay + contentOffset.y
        // 约束不越界（简单 clamp 到 bounds 内）
        let x = min(max(originX, 0), max(0, bounds.width - fittingSize.width))
        let y = min(max(originY, 0), max(0, bounds.height - fittingSize.height))
        contentContainer.frame = CGRect(origin: CGPoint(x: x, y: y), size: fittingSize)
        applyRadius()
    }

    // MARK: visible 切换 —— 挂载 keyWindow / 卸载 + fade 动画

    private func applyVisibility(old: Bool, new: Bool) {
        guard old != new else { return }
        if new { mountToWindow(animated: animation) }
        else { unmountFromWindow(animated: animation) }
    }

    private func mountToWindow(animated: Bool) {
        guard !isCurrentlyMounted,
              let window = Self.keyWindow() else { return }
        self.alpha = animated ? 0 : 1
        self.frame = window.bounds
        // ⚠️ 永久钉死=用户亲测iOS Overlay点不动=根因=挂载到 keyWindow 后=被系统手势/其他 window 拦截=2 行治根（AI 之前没加=全责）：
        // ① self.isUserInteractionEnabled = true=显式开 UIView 交互=避免父视图/系统把我们的 Overlay 当透明容器=忽略交互
        // ② window.windowLevel = .normal + 0.01=把 App 主 window 提到最前（比普通弹窗还高一点=不被系统手势/Alert/其他浮层拦截触摸=Overlay 永远最上层=点击 100% 命中）
        self.isUserInteractionEnabled = true
        window.windowLevel = UIWindow.Level.normal + 0.01
        window.addSubview(self)
        overlayMaskView.alpha = 1
        isCurrentlyMounted = true
        setNeedsLayout()
        if animated {
            UIView.animate(withDuration: Self.FADE_IN_DURATION, delay: 0, options: [.curveEaseOut]) {
                self.alpha = 1
            }
        }
    }

    private func fadeOutAndUnmount() {
        UIView.animate(withDuration: Self.FADE_OUT_DURATION, delay: 0, options: [.curveEaseIn]) {
            self.alpha = 0
        } completion: { _ in
            self.removeFromSuperview()
            self.alpha = 1
            self.isCurrentlyMounted = false
        }
    }

    private func unmountFromWindow(animated: Bool) {
        guard isCurrentlyMounted else { return }
        if animated {
            fadeOutAndUnmount()
        } else {
            removeFromSuperview()
            isCurrentlyMounted = false
        }
    }

    // MARK: Helper：keyWindow

    static func keyWindow() -> UIWindow? {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first(where: \.isKeyWindow) ?? UIApplication.shared.keyWindow
        } else {
            return UIApplication.shared.keyWindow
        }
    }

    // MARK: Deinit：自动清理（业务忘记 visible=false 时兜底）

    deinit {
        if isCurrentlyMounted {
            removeFromSuperview()
            isCurrentlyMounted = false
        }
    }
}

// MARK: - UIGestureRecognizerDelegate：点击 overlayMaskView 非 content 区域才触发手势（点击 content 上透传给内部控件）

extension Overlay: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let p = touch.location(in: overlayMaskView)
        // 若点到 contentContainer（或其子视图），手势不拦截 → 事件进入内容控件（按钮等正常响应）
        let contentPoint = touch.location(in: contentContainer)
        if contentContainer.point(inside: contentPoint, with: nil) {
            return false
        }
        return overlayMaskView.point(inside: p, with: nil)
    }

    func gestureRecognizer(_: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith _: UIGestureRecognizer) -> Bool {
        // tap + press 共存
        true
    }
}

// MARK: - UIColor 十六进制解析（复用 Image/ConfigProvider 同款，保持组件间零依赖）

private extension UIColor {
    convenience init?(overlayHexString hex: String) {
        let cleaned = hex.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
        let scanner = Scanner(string: cleaned)
        var value: UInt64 = 0
        guard scanner.scanHexInt64(&value) else { return nil }
        switch cleaned.count {
        case 6:
            self.init(
                red: CGFloat((value & 0xFF0000) >> 16) / 255.0,
                green: CGFloat((value & 0x00FF00) >> 8) / 255.0,
                blue: CGFloat(value & 0x0000FF) / 255.0,
                alpha: 1.0
            )
        case 8:
            self.init(
                red: CGFloat((value & 0xFF000000) >> 24) / 255.0,
                green: CGFloat((value & 0x00FF0000) >> 16) / 255.0,
                blue: CGFloat((value & 0x0000FF00) >> 8) / 255.0,
                alpha: CGFloat(value & 0x000000FF) / 255.0
            )
        case 3:
            let r = (value & 0xF00) >> 8
            let g = (value & 0x0F0) >> 4
            let b = value & 0x00F
            let exp: (UInt64) -> CGFloat = { CGFloat($0 * 17) / 255.0 }
            self.init(red: exp(r), green: exp(g), blue: exp(b), alpha: 1.0)
        default:
            return nil
        }
    }
}
