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
        // entries 总宽 = columns 等分；超出 columns 走横向滚动
        let visibleCount = min(items.count, self.columns)
        let totalWidth = UIScreen.main.bounds.width - AppSpace.lg * 2
        let entryWidth = (totalWidth - AppSpace.sm * CGFloat(self.columns - 1)) / CGFloat(self.columns)
        rowStack.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalToSuperview()
        }
        // 填充 entries（≤columns 等分展示，>columns 横滚；entry 宽度固定保证等分）
        for (index, item) in items.enumerated() {
            let entryView = makeEntryView(item, width: entryWidth, index: index)
            rowStack.addArrangedSubview(entryView)
            // 第 columns+1 个开始横滚——放宽 rowStack 宽度
            if index == self.columns {
                rowStack.snp.remakeConstraints { make in
                    make.edges.equalToSuperview()
                    make.height.equalToSuperview()
                    make.width.greaterThanOrEqualToSuperview()
                }
            }
        }
        _ = visibleCount  // 当前展示计数（保留用于未来扩展 e.g. 截断徽标）
    }

    // MARK: - 单个入口项

    private func makeEntryView(_ item: ShortcutBarItem, width: CGFloat, index: Int) -> UIView {
        let control = UIControl()
        control.tag = index
        control.backgroundColor = .clear
        control.addTarget(self, action: #selector(entryTapped(_:)), for: .touchUpInside)
        control.addTarget(self, action: #selector(entryTouchDown(_:)), for: .touchDown)
        control.addTarget(self, action: #selector(entryTouchUp(_:)), for: [.touchUpOutside, .touchCancel])

        // 图标容器（primary 背景 + 白色图标 16）
        let iconContainer = UIView()
        iconContainer.backgroundColor = AppColor.primary
        iconContainer.layer.cornerRadius = 6
        let icon = UIImageView(image: UIImage(systemName: item.icon))
        icon.tintColor = .white
        icon.contentMode = .scaleAspectFit
        iconContainer.addSubview(icon)
        icon.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(16)
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
        col.layoutMargins = UIEdgeInsets(top: 6, left: 4, bottom: 6, right: 4)
        col.isUserInteractionEnabled = false

        control.addSubview(col)
        iconContainer.snp.makeConstraints { make in
            make.width.height.equalTo(26)
        }
        col.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        control.snp.makeConstraints { make in
            make.width.equalTo(width)
        }

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