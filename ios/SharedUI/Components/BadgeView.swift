/// Badge 徽标组件（UIKit 版，对齐 Android Badge）。
///
/// 展示在宿主内容右上角的数字/圆点/文本提醒，用于未读数、新消息、状态标识。
/// 形态由 count / text / dot 三参数自动推断，支持 maxCount 截断、color 主题色、offset 锚点偏移。
///
/// 用法：
/// ```swift
/// let badge = BadgeView(content: iconView, count: 3)
/// // 或
/// let badge = BadgeView(content: iconView)
/// badge.count = 99
/// ```
///
/// 形态自动选择（与设计规格 badge-design-spec.html 一致）：
/// - dot=true → 圆点 8×8
/// - text 非空 → 文本胶囊（height 18，paddingH 8）
/// - count 在 1...maxCount → 数字胶囊（minWidth 18，height 18，paddingH 6）
/// - count > maxCount → 「maxCount+」胶囊
/// - count==0 或 (count==nil && text==nil && dot==false) → 不渲染

import UIKit
import SnapKit

/// 徽标锚点偏移量（相对宿主右上角）。
///
/// x：水平偏移，正=向右（徽标相对宿主右边缘向外）；
/// y：垂直偏移，正=向下。
/// 默认 (x: 4, y: -4) → 徽标位于宿主右上角外凸 4pt（即 CSS 语义 top:-4 / right:-4）。
struct BadgeOffset: Equatable {
    let x: CGFloat
    let y: CGFloat

    /// 默认偏移：右上角外凸 4pt。
    static let `default` = BadgeOffset(x: 4, y: -4)
}

final class BadgeView: UIView {
    // MARK: - 配置属性

    /// 宿主内容视图。
    private(set) var contentView: UIView

    /// 数字徽标：nil=圆点形态（需 dot 配合）；0=不显示；≥1=数字；>maxCount 显示 maxCount+。
    var count: Int? { didSet { updateBadge() } }

    /// 自定义文本徽标（与 count 二选一，text 优先）。
    var text: String? { didSet { updateBadge() } }

    /// 数字上限，超过显示「maxCount+」，默认 99。
    var maxCount: Int = 99 { didSet { updateBadge() } }

    /// 徽标背景色，默认 danger 红（AppColor.error）。
    var color: UIColor = AppColor.error { didSet { updateBadge() } }

    /// 强制圆点形态（忽略 count/text）。
    var dot: Bool = false { didSet { updateBadge() } }

    /// 锚点偏移，nil 时使用默认（右上角外凸 4pt）。
    var offset: BadgeOffset? { didSet { updateBadge() } }

    // MARK: - 子视图

    /// 当前徽标视图（圆点或胶囊），隐藏态为 nil。
    private var badgeView: UIView?

    // MARK: - 初始化

    /// 完整初始化。
    init(
        contentView: UIView,
        count: Int? = nil,
        text: String? = nil,
        maxCount: Int = 99,
        color: UIColor = AppColor.error,
        dot: Bool = false,
        offset: BadgeOffset? = nil
    ) {
        self.contentView = contentView
        self.count = count
        self.text = text
        self.maxCount = maxCount
        self.color = color
        self.dot = dot
        self.offset = offset
        super.init(frame: .zero)
        setup()
    }

    /// 便捷初始化：仅传入宿主内容视图，其余参数走默认值。
    convenience init(content: UIView) {
        self.init(contentView: content)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("BadgeView does not support NSCoder")
    }

    // MARK: - 布局

    private func setup() {
        // 徽标需渲染到宿主边界外（右上角外凸），关闭裁剪。
        clipsToBounds = false
        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        updateBadge()
    }

    /// 透传宿主内容的固有尺寸，便于在 UIStackView 等场景正确撑开。
    override var intrinsicContentSize: CGSize {
        contentView.intrinsicContentSize
    }

    // MARK: - 形态解析

    private enum BadgeMode {
        case hidden
        case dot
        case number(String)
        case text(String)
    }

    /// 根据 count/text/dot/maxCount 推断徽标形态。
    private func resolveMode() -> BadgeMode {
        if dot { return .dot }
        if let text = text, !text.isEmpty { return .text(text) }
        if let count = count {
            if count <= 0 { return .hidden }
            if count <= maxCount { return .number("\(count)") }
            return .number("\(maxCount)+")
        }
        // count==nil && text==nil && dot==false
        return .hidden
    }

    // MARK: - 徽标渲染

    private func updateBadge() {
        badgeView?.removeFromSuperview()
        badgeView = nil

        switch resolveMode() {
        case .hidden:
            return
        case .dot:
            let dotView = UIView()
            dotView.backgroundColor = color
            dotView.layer.cornerRadius = 4 // 8×8 → radius 4
            dotView.clipsToBounds = true
            addSubview(dotView)
            dotView.snp.makeConstraints { make in
                make.width.height.equalTo(8)
                applyAnchor(to: make)
            }
            badgeView = dotView
        case .number(let str):
            let pill = makePill(text: str, minWidth: 18, paddingH: 6)
            addSubview(pill)
            pill.snp.makeConstraints { make in
                make.height.equalTo(18)
                applyAnchor(to: make)
            }
            badgeView = pill
        case .text(let str):
            let pill = makePill(text: str, minWidth: nil, paddingH: 8)
            addSubview(pill)
            pill.snp.makeConstraints { make in
                make.height.equalTo(18)
                applyAnchor(to: make)
            }
            badgeView = pill
        }
    }

    /// 构造胶囊徽标：圆角背景 + 居中文本。
    /// - Parameters:
    ///   - text: 徽标文案
    ///   - minWidth: 最小宽度（数字徽标 18；文本徽标 nil 即仅由文字+内边距决定）
    ///   - paddingH: 水平内边距（数字 6 / 文本 8）
    private func makePill(text: String, minWidth: CGFloat?, paddingH: CGFloat) -> UIView {
        let container = UIView()
        container.backgroundColor = color
        container.layer.cornerRadius = 9 // height 18 → radius 9 = 半圆
        container.clipsToBounds = true

        let label = UILabel()
        label.text = text
        label.textColor = .white
        label.font = .systemFont(ofSize: 11, weight: .semibold)
        label.textAlignment = .center
        container.addSubview(label)

        label.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(paddingH)
            make.trailing.equalToSuperview().offset(-paddingH)
        }
        if let minW = minWidth {
            container.snp.makeConstraints { make in
                make.width.greaterThanOrEqualTo(minW)
            }
        }
        return container
    }

    /// 将徽标锚定到宿主右上角，并应用 offset 偏移。
    private func applyAnchor(to make: ConstraintMaker) {
        let off = offset ?? .default
        make.top.equalToSuperview().offset(off.y)
        make.trailing.equalToSuperview().offset(off.x)
    }
}
