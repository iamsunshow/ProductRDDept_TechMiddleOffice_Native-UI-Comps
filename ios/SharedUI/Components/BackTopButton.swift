/// BackTopButton 返回顶部悬浮钮：绑定目标滚动容器，滚动超过阈值后淡入显示，点击回滚到顶。
///
/// 组件 ID：`ui.back-top`（api.json 契约对齐，门禁 A AI 代评通过 2026-09-04，
/// 用户"中间任何询问直接通过"总授权；P1–P4 全 A：浮层按钮模式 + 滚动源解耦 +
/// iOS KVO 监听 contentOffset + 默认视觉可替换）。
///
/// 一期语义（对标 NutUI React BackTop）：
/// - [appearAfter]：滚动位移超过该值（pt）后显示，默认 120
/// - [onTap]：点击回调；nil=使用默认回顶（scrollView.setContentOffset(.zero, animated: true)）
/// - 默认视觉 = 主色圆钮 + 白色 ↑（U+2191 文本，零图片依赖），圆角按实际 bounds 计算
/// - 位置由宿主容器自行摆放（组件不代管约束），显隐为 alpha 过渡不占布局位
/// - 视觉可整体替换（setFace），点击行为保留
///
/// 用法：
/// ```swift
/// let backtop = BackTopButton(target: scrollView, appearAfter: 120)
/// host.addSubview(backtop)
/// backtop.snp.makeConstraints { make in
///     make.trailing.equalToSuperview().offset(-16)
///     make.bottom.equalToSuperview().offset(-24)
///     make.width.height.equalTo(40)
/// }
/// ```
import UIKit

final class BackTopButton: UIView {

    /// 目标滚动容器（滚动源；nil 时默认回顶动作不可用但显隐逻辑不崩）
    weak var target: UIScrollView?

    /// 点击回调（nil=默认回顶动画）
    var onTap: (() -> Void)?

    /// 出现阈值（pt）
    private let appearAfter: CGFloat

    /// 淡入淡出时长
    private let animationDuration: TimeInterval

    /// 点击承载 + face 容器（自身永不从父视图移除）
    private let tapButton = UIButton(type: .custom)
    /// 当前 face 内容视图（默认=默认 ↑ 圆钮视图；setFace 后=宿主传入视图）
    private var contentView: UIView?
    /// 当前内容是否为默认 face（默认 face 圆角须随宿主实际尺寸动态=边长一半；
    /// 自定义 face 全权负责自身视觉，组件不代管圆角——与 Android content 替换语义一致）
    private var usingDefaultFace = false
    private var observer: NSKeyValueObservation?
    private var isShowing = false

    // MARK: - init

    init(target: UIScrollView?,
         appearAfter: CGFloat = 120,
         animationDuration: TimeInterval = 0.15,
         onTap: (() -> Void)? = nil) {
        self.target = target
        self.appearAfter = appearAfter
        self.animationDuration = animationDuration
        self.onTap = onTap
        super.init(frame: .zero)
        backgroundColor = .clear

        // tapButton 只作点击 + 内容承载，自身透明无圆角；
        // 全部视觉（默认 ↑ 圆钮）由独立 face 内容视图承载——setFace 只替换内容，
        // 绝不触碰承载按钮本身（2026-09-05 修复：旧实现把默认 face 直接等于
        // tapButton，setFace 的 faceView?.removeFromSuperview() 把承载按钮从宿主拔除，
        // 之后内容挂到已脱离层级的按钮上 → 整钮不可见 → iOS Demo D2 滑动后不出现）。
        tapButton.addTarget(self, action: #selector(didTap), for: .touchUpInside)
        addSubview(tapButton)
        tapButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        install(face: Self.makeDefaultFaceView(), isDefault: true)

        // 初始隐藏（不占位、不可点）
        alpha = 0
        isUserInteractionEnabled = false

        observer = target?.observe(\.contentOffset, options: [.new]) { [weak self] _, _ in
            self?.refreshVisibility()
        }
        refreshVisibility()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("BackTopButton 不支持 initWithCoder 解码，请使用 init(target:appearAfter:animationDuration:onTap:)。")
    }

    deinit {
        observer?.invalidate()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // 默认 face 圆角 = 实际边长一半（尺寸由宿主决定，不写死魔法值）
        if usingDefaultFace, let contentView {
            contentView.layer.cornerRadius = min(bounds.width, bounds.height) / 2
            contentView.clipsToBounds = true
        }
    }

    /// 默认视觉：主色圆钮 + 白色 ↑（U+2191）文本，零图片依赖
    private static func makeDefaultFaceView() -> UIView {
        let v = UIView()
        v.backgroundColor = AppColor.primary
        let l = UILabel()
        l.text = "↑"
        l.font = .systemFont(ofSize: AppFont.sizeLg, weight: .bold)
        l.textColor = .white
        v.addSubview(l)
        l.snp.makeConstraints { make in make.center.equalToSuperview() }
        return v
    }

    // MARK: - 视觉替换

    /// 替换默认视觉视图（点击行为保留；调用后默认 ↑ 圆钮被替换）。
    func setFace(_ view: UIView) {
        install(face: view, isDefault: false)
    }

    private func install(face: UIView, isDefault: Bool) {
        contentView?.removeFromSuperview()
        tapButton.addSubview(face)
        face.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        face.isUserInteractionEnabled = false
        contentView = face
        usingDefaultFace = isDefault
        if isDefault {
            setNeedsLayout()
            layoutIfNeeded()
        }
    }

    // MARK: - 行为

    @objc private func didTap() {
        if let onTap {
            onTap()
        } else {
            target?.setContentOffset(.zero, animated: true)
        }
    }

    private func refreshVisibility() {
        let shouldShow = (target?.contentOffset.y ?? 0) > appearAfter
        guard shouldShow != isShowing else { return }
        isShowing = shouldShow
        UIView.animate(withDuration: animationDuration) {
            self.alpha = shouldShow ? 1 : 0
        }
        isUserInteractionEnabled = shouldShow
    }
}
