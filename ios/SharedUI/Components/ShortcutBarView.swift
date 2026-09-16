// ShortcutBar 快捷栏（信息展示区 · ui.shortcut-bar · #82）通用横向图标快捷入口条。
//
// 组件 ID：`ui.shortcut-bar`（api.json 契约对齐；门禁 A AI 代评通过 2026-09-16，规格
// docs/数据与产物/design-spec/shortcut-bar-design-spec.html + 评审单
// docs/评审记录/review-shortcut-bar-A.md，P1–P4 全 A）。
//
// 视觉锚点（与 Android ShortcutBar 同构 / 与库内 Grid #8 划界）：横向单行快捷入口条——
// 白底 bgCard + hairline 描边 + radiusLg 圆角壳 + 顶部内边距 12/16 + 底部内边距 12/16 +
// 行内 entry 等分（columns 默认 4，支持 3/4/5）+ entry=图标容器 26×26 圆角 6 primary 背景 +
// 白色图标 16 + 文字 sizeXs=12 textPrimary 单行省略 + entry 间距 8/8 + 点击命中整 entry 透明 UIControl
// + 灰底按压态 alpha 0.05 与 Android ripple 行为一致；无选中态（≠Tabs/Tabbar 选中概念）、无角标
// （≠Tabbar badge）、无更多/收起按钮（≠FixedNav 面板展开）。
//
// 语义：items `[{id, icon, text}]` 数据驱动 + columns? 列数默认 4 + onClick(id) 回调；
// 命名图标=UIImage(systemName:) 字符（如 "plus"、"doc.text"）；emoji/字符图标由宿主拼 image。
//
// 划界勿混：#8 Grid 多行可分组网格 / #19 Tabbar 页面底部主导航带激活态 / #15 FixedNav 面板展开 /
// #23 CalendarCard 日历卡内嵌入口 / #74 Segmented 分段页签。
import UIKit
import SnapKit

/// 快捷栏视觉 token（与 Android `ShortcutBarTokens` / design-spec §02 对齐）。
private enum ShortcutBarTokens {
    /// 图标容器尺寸（=26×26 圆角 6 primary 背景）。
    static let iconContainerSize: CGFloat = 26
    /// 图标容器圆角。
    static let iconContainerRadius: CGFloat = 6
    /// 图标白圆尺寸（system font glyph 标准尺寸）。
    static let iconSize: CGFloat = 16
    /// entry 上下内边距。
    static let entryPaddingVertical: CGFloat = 6
    /// entry 左右内边距。
    static let entryPaddingHorizontal: CGFloat = 4
}

/// 快捷栏入口数据项。
public struct ShortcutBarItem {
    public let id: String
    public let icon: String
    public let text: String

    public init(id: String, icon: String, text: String) {
        self.id = id
        self.icon = icon
        self.text = text
    }
}

/// 横向单行快捷入口条（数据驱动 + 等分列 + 点击回调）。
///
/// 支持：
/// - `columns` 列数（默认 4，支持 3/4/5；超长自动换行=横向 ScrollView 兜底）
/// - `items` 数据驱动（id/图标字符/文本）
/// - `onClick` 点击回调（返回 entry id）
public final class ShortcutBarView: UIView {

    /// 点击回调（返回 entry id）。
    public var onClick: ((String) -> Void)?

    /// 列数（默认 4；修改后需调用 `apply` 重新绑定）。
    public var columns: Int = 4

    private let scrollView = UIScrollView()
    private let rowStack = UIStackView()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupCardShell()
        setupScrollContainer()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    // MARK: - 自然高度

    /// 自然高度 = 壳上下内边距 md×2 + entry 高（entry 上下内边距 ×2 + 图标 26 + 图标文本间距 + 文本行高）。
    /// 宿主只锚 top/leading/trailing/bottom 即可，无需写死高度（写死 72 < 自然高 81 → entry 内容被压重叠）。
    public override var intrinsicContentSize: CGSize {
        let textLineHeight = ceil(UIFont.systemFont(ofSize: AppFont.sizeXs).lineHeight)
        let entryHeight = ShortcutBarTokens.entryPaddingVertical * 2
            + ShortcutBarTokens.iconContainerSize
            + AppSpace.xs
            + textLineHeight
        return CGSize(width: UIView.noIntrinsicMetric, height: entryHeight + AppSpace.md * 2)
    }

    // MARK: - 卡片壳

    private func setupCardShell() {
        backgroundColor = AppColor.bgCard
        layer.cornerRadius = AppRadius.lg
        layer.borderWidth = 1 / UIScreen.main.scale
        layer.borderColor = AppColor.border.cgColor
    }

    // MARK: - 滚动容器（横向，超长 entries 自动横滚）

    private func setupScrollContainer() {
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceHorizontal = false
        addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(
                top: AppSpace.md, left: AppSpace.lg, bottom: AppSpace.md, right: AppSpace.lg
            ))
        }

        rowStack.axis = .horizontal
        rowStack.distribution = .fillEqually
        rowStack.alignment = .fill
        rowStack.spacing = AppSpace.sm
        scrollView.addSubview(rowStack)
        rowStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalToSuperview()
        }
    }

    // MARK: - 绑定数据

    /// 绑定 entries 列表 + 列数 + 点击回调。
    ///
    /// - Parameters:
    ///   - items: 入口列表（id/图标字符/文本）
    ///   - columns: 列数（默认 4；传 0 或负值回退到 4）
    public func apply(items: [ShortcutBarItem], columns: Int = 4) {
        self.columns = max(1, columns)
        // 清空旧 entries
        rowStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let needsScroll = items.count > self.columns
        // 布局契约（与 Android horizontalScroll 1:1）：
        //  - items ≤ columns：整条宽 = 可视宽，fillEqually 等分（不写死 entry 宽，避免与组件实际宽度脱钩）
        //  - items > columns：entry 宽 = 可视宽/columns（扣间距均摊），rowStack 随内容撑宽 → 横向滚动
        rowStack.snp.remakeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview()
            // 非横滚：整条宽 == 可视宽（fillEqually 等分 + 超长文本 truncating）；
            // 横滚：宽 >= 可视宽，随 entry 定宽和撑开 → 内容可滚。
            if needsScroll {
                make.width.greaterThanOrEqualToSuperview()
            } else {
                make.width.equalToSuperview()
            }
        }
        // 填充 entries
        for (index, item) in items.enumerated() {
            let entryView = makeEntryView(item, index: index)
            // 先入树再建「相对 scrollView 宽度」的约束（否则无共同祖先 → NSGenericException 崩溃）
            rowStack.addArrangedSubview(entryView)
            if needsScroll {
                let perColumn = 1.0 / CGFloat(self.columns)
                let gutter = AppSpace.sm * CGFloat(self.columns - 1) / CGFloat(self.columns)
                entryView.snp.makeConstraints { make in
                    make.width.equalTo(scrollView.snp.width).multipliedBy(perColumn).offset(-gutter)
                }
            }
        }
    }

    // MARK: - 单个入口项

    private func makeEntryView(_ item: ShortcutBarItem, index: Int) -> UIView {
        let control = UIControl()
        control.tag = index
        control.backgroundColor = .clear
        control.addTarget(self, action: #selector(entryTapped(_:)), for: .touchUpInside)
        control.addTarget(self, action: #selector(entryTouchDown(_:)), for: .touchDown)
        control.addTarget(self, action: #selector(entryTouchUp(_:)), for: [.touchUpOutside, .touchCancel])

        // 图标容器（primary 背景 + 白色图标 16）
        let iconContainer = UIView()
        iconContainer.backgroundColor = AppColor.primary
        iconContainer.layer.cornerRadius = ShortcutBarTokens.iconContainerRadius
        let icon = UIImageView(image: UIImage(systemName: item.icon))
        icon.tintColor = .white
        icon.contentMode = .scaleAspectFit
        iconContainer.addSubview(icon)
        icon.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(ShortcutBarTokens.iconSize)
        }

        // 文本（sizeXs=12 textPrimary 单行省略）
        let label = UILabel()
        label.text = item.text
        label.font = .systemFont(ofSize: AppFont.sizeXs)
        label.textColor = AppColor.textPrimary
        label.textAlignment = .center
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail

        let col = UIStackView(arrangedSubviews: [iconContainer, label])
        col.axis = .vertical
        col.spacing = AppSpace.xs
        col.alignment = .center
        col.distribution = .equalCentering
        col.isLayoutMarginsRelativeArrangement = true
        col.layoutMargins = UIEdgeInsets(
            top: ShortcutBarTokens.entryPaddingVertical,
            left: ShortcutBarTokens.entryPaddingHorizontal,
            bottom: ShortcutBarTokens.entryPaddingVertical,
            right: ShortcutBarTokens.entryPaddingHorizontal
        )
        col.isUserInteractionEnabled = false

        control.addSubview(col)
        iconContainer.snp.makeConstraints { make in
            make.width.height.equalTo(ShortcutBarTokens.iconContainerSize)
        }
        col.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        // entry 定宽约束由 apply() 在入树后统一建立（此处 control 尚未入树，不能引用 scrollView 锚点）


        // 绑定 id 关联
        control.accessibilityIdentifier = item.id
        return control
    }

    @objc private func entryTapped(_ sender: UIControl) {
        guard let id = sender.accessibilityIdentifier else { return }
        onClick?(id)
        UIView.animate(withDuration: 0.15) {
            sender.backgroundColor = .clear
            sender.alpha = 1.0
        }
    }

    @objc private func entryTouchDown(_ sender: UIControl) {
        UIView.animate(withDuration: 0.1) {
            sender.backgroundColor = UIColor(white: 0, alpha: 0.05)
            sender.alpha = 0.7
        }
    }

    @objc private func entryTouchUp(_ sender: UIControl) {
        UIView.animate(withDuration: 0.15) {
            sender.backgroundColor = .clear
            sender.alpha = 1.0
        }
    }
}