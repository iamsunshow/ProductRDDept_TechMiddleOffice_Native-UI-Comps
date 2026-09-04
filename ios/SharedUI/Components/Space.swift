/// Space 间距：纯间距容器——一组任意子内容按统一档位间距排布（水平/垂直）。
///
/// 组件 ID：`ui.space`（api.json 契约对齐，门禁 A 评审通过 2026-09-04，
/// 用户 P1–P4 全票 A：方向双向 + AppSpace 五档 + 默认 sm=8 + 一期无 wrap/split）。
/// 命名：Space（双端同名；iOS 去 View 后缀规范，无系统同名类冲突）。
///
/// 一期语义：
/// - 子项按 `direction` 排布：horizontal=一行从左到右；vertical=一列从上到下
/// - 相邻子项间距 = `spacing`（size 档位 token 值）；间距仅在子项之间（首尾无 padding）
/// - 子项对齐：横向顶部对齐、纵向起始侧对齐；不拉伸子项（子项须自含尺寸：intrinsic 或约束）
/// - 容器 pass-through：透明零绘制零自有文本，装饰由子项内容承担
///
/// 用法：
/// ```swift
/// let space = Space(direction: .horizontal, spacing: AppSpace.sm)
/// space.addItems([tool1, tool2, tool3])
/// ```
import UIKit

/// 间距排布容器：内部由 UIStackView 承担编排（axis=direction、spacing=size 档位）。
///
/// 富余空间语义（对齐 Android wrap_content）：
/// UIStackView 的 `.fill` 会把轴向上的富余空间摊给 content hugging 最低的
/// arranged subview——没有任何兜底时会被摊给内容子项（实测摊给首个子项，
/// 表现为"第一个元素被拉宽"）。Space 内部恒定挂一个 hugging=1 的透明尾部
/// 吸收件（尾随弹性件）：富余空间永远先被它吸收=视觉上落在尾部留白，
/// 内容子项始终保持自身内容宽，与 Android Row/Column 的 spacedBy +
/// 子项 wrap_content、富余留尾语义一致。
final class Space: UIStackView {

    /// 排布方向（P1 用户全 A：单组件 + direction 双向）。
    enum Direction {
        case horizontal
        case vertical
    }

    /// 透明尾部弹性吸收件：轴方向 hugging/compression 均置为最低，
    /// fill 富余空间只会摊给它，内容子项不被拉伸；内容超宽时它也先塌缩到 0。
    private let tailAbsorber: UIView = {
        let view = UIView()
        view.setContentHuggingPriority(UILayoutPriority(1), for: .horizontal)
        view.setContentHuggingPriority(UILayoutPriority(1), for: .vertical)
        view.setContentCompressionResistancePriority(UILayoutPriority(1), for: .horizontal)
        view.setContentCompressionResistancePriority(UILayoutPriority(1), for: .vertical)
        return view
    }()

    /// 当前排布方向（horizontal=一行 / vertical=一列）。
    private(set) var direction: Direction {
        didSet {
            guard direction != oldValue else { return }
            updateStackFromDirection()
        }
    }

    init(direction: Direction = .horizontal, spacing: CGFloat = AppSpace.sm) {
        self.direction = direction
        super.init(frame: .zero)
        self.spacing = spacing
        updateStackFromDirection()
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("Space 不支持 initWithCoder 解码，请使用 init(direction:spacing:)。")
    }

    /// 添加一个子项。
    func addItem(_ item: UIView) {
        removeTailAbsorber()
        addArrangedSubview(item)
        attachTailAbsorber(after: item)
    }

    /// 批量添加子项（子项按添加顺序从左到右/从上到下排布）。
    func addItems(_ items: [UIView]) {
        removeTailAbsorber()
        items.forEach { addArrangedSubview($0) }
        attachTailAbsorber(after: items.last)
    }

    /// 清空全部子项。
    func removeAllItems() {
        removeTailAbsorber()
        arrangedSubviews.forEach {
            removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
    }

    /// 摘除尾随吸收件（addItem(s) 时先摘再补，保证它永远位于 arrangedSubviews 最末）。
    private func removeTailAbsorber() {
        guard arrangedSubviews.contains(tailAbsorber) else { return }
        removeArrangedSubview(tailAbsorber)
        tailAbsorber.removeFromSuperview()
    }

    /// 把尾随吸收件挂到所有内容子项之后；吸收件与最后一个内容子项之间不产生间距。
    private func attachTailAbsorber(after lastContent: UIView?) {
        addArrangedSubview(tailAbsorber)
        if #available(iOS 11.0, *), let lastContent {
            setCustomSpacing(0, after: lastContent)
        }
    }

    /// direction → 系统 axis 与对齐（横向顶部对齐 / 纵向起始侧对齐，一期固定不拉伸）。
    private func updateStackFromDirection() {
        switch direction {
        case .horizontal:
            axis = .horizontal
            alignment = .top
        case .vertical:
            axis = .vertical
            alignment = .leading
        }
    }
}
