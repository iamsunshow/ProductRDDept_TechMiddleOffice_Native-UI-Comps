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
final class Space: UIStackView {

    /// 排布方向（P1 用户全 A：单组件 + direction 双向）。
    enum Direction {
        case horizontal
        case vertical
    }

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
        addArrangedSubview(item)
    }

    /// 批量添加子项（子项按添加顺序从左到右/从上到下排布）。
    func addItems(_ items: [UIView]) {
        items.forEach { addArrangedSubview($0) }
    }

    /// 清空全部子项。
    func removeAllItems() {
        arrangedSubviews.forEach {
            removeArrangedSubview($0)
            $0.removeFromSuperview()
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
