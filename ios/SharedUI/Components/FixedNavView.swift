import UIKit
import SnapKit

// MARK: - 数据与类型

/// 悬浮导航项数据（与 Android `FixedNavItem` 同构）。
struct FixedNavItem {
    /// 唯一标识（选中回传用）
    let key: String
    /// 行展示文案
    let text: String
    /// 行图标位字符（emoji/单字符）；nil=行内不显示图标位（不占位，见 D3）
    let icon: String?
    /// 角标数字；nil 或 <=0=不显示角标
    let num: Int?

    init(key: String, text: String, icon: String? = nil, num: Int? = nil) {
        self.key = key
        self.text = text
        self.icon = icon
        self.num = num
    }
}

/// 悬浮导航摆放方向（type）：right=钮靠右缘、面板同右缘对齐向上弹出；left=对称。
enum FixedNavType {
    case right
    case left
}

// MARK: - FixedNavView 悬浮导航

/// FixedNavView 悬浮导航：页面边缘常驻悬浮入口钮 + 展开导航项列表的"快捷导航器"。
///
/// 组件 ID：`ui.fixed-nav`（api.json 契约对齐，门禁 A AI 代评通过 2026-09-05，
/// 用户"除特色组件外所有组件评审文档全部生成，中间任何询问直接通过"总授权；
/// P1–P4 全 A：收起胶囊钮 + 点钮弹出面板 + 点项自动收起 + type 左右 + 文案自定义）。
///
/// 一期语义（对标 NutUI React FixedNav 悬浮导航）：
/// - [items]：导航项列表（key/text/icon?/num?），面板竖排行数 = items 数
/// - [type]：`right`=钮在右缘、面板同右缘对齐向上弹出；`left` 对称
/// - [activeText]/[unActiveText]：展开/收起态钮文案（nil=默认"收起导航"/"快速导航"）
/// - [onSelect]：点某项回调（触发后组件自动收起面板）；nil=点项仅展开/收起
/// - 交互：点钮=展开/收起切换；展开态钮文字切 activeText；面板为钮上方同缘卡片
/// - "悬浮"定位由宿主完成（把本视图放入非滚动覆盖层锚定边角，同 BackTop 先例）；
///   组件不代管布局上下文、不做 window 级浮层、不监听滚动
///
/// 用法：
/// ```swift
/// let nav = FixedNavView(items: [
///     FixedNavItem(key: "home", text: "首页", icon: "⌂", num: 2),
///     FixedNavItem(key: "cart", text: "购物车", num: 5),
/// ]) { item in print("selected:", item.key) }
/// host.addSubview(nav) // host=页面非滚动覆盖层
/// nav.snp.makeConstraints { make in
///     make.trailing.equalToSuperview().offset(-AppSpace.md)
///     make.bottom.equalToSuperview().offset(-AppSpace.lg)
/// }
/// ```
final class FixedNavView: UIView {

    /// 组件内布局规格（与 Android 侧同数值不同单位；Token 对齐注释防魔法值误判）
    struct Metrics {
        /// 悬浮钮高（40pt，对齐 BackTop 悬浮钮直径=同库悬浮钮视觉族）
        static let buttonHeight: CGFloat = 40
        /// 面板行高（44pt）
        static let panelRowHeight: CGFloat = 44
        /// 行图标位（20pt，圆角 6=AppRadius.sm）
        static let iconSlotSize: CGFloat = 20
        /// 面板行最小宽（140pt，内容不足时保底宽度，卡片窄于 140 视觉不成立）
        static let minPanelWidth: CGFloat = 140
        /// 面板与钮间距（=AppSpace.sm）
        static let panelToButtonGap: CGFloat = AppSpace.sm
        /// 行 num 角标高（16pt，圆角=full）
        static let numBadgeHeight: CGFloat = 16
        /// 钮水平内边距（=AppSpace.lg）
        static let buttonHPadding: CGFloat = AppSpace.lg
    }

    /// 展开/收起态默认文案（NutUI active-text/un-active-text 语义）
    private static let defaultActiveText = "收起导航"
    private static let defaultUnActiveText = "快速导航"

    /// 当前是否展开（只读；外部收起请调用 collapse()）
    private(set) var isExpanded = false

    private let items: [FixedNavItem]
    private let type: FixedNavType
    private let activeText: String
    private let unActiveText: String
    private let onSelect: ((FixedNavItem) -> Void)?

    private let button = UIButton(type: .custom)
    /// 面板卡片（展开时才挂到层级，收起即移除→不占布局空间）
    private var panelCard: UIView?

    // MARK: - init

    init(items: [FixedNavItem],
         type: FixedNavType = .right,
         activeText: String? = nil,
         unActiveText: String? = nil,
         onSelect: ((FixedNavItem) -> Void)? = nil) {
        self.items = items
        self.type = type
        self.activeText = activeText ?? Self.defaultActiveText
        self.unActiveText = unActiveText ?? Self.defaultUnActiveText
        self.onSelect = onSelect
        super.init(frame: .zero)
        setupButton()
        updateButtonTitle()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("FixedNavView 不支持 initWithCoder 解码，请使用 init(items:type:activeText:unActiveText:onSelect:)。")
    }

    // MARK: - 按钮（收起/展开态共用胶囊钮）

    private func setupButton() {
        button.backgroundColor = AppColor.primary
        button.layer.cornerRadius = Metrics.buttonHeight / 2
        button.clipsToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: AppFont.sizeSm, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        // 左/右间距 + 文字留白（钮内容宽度自适应；高固定 Metrics.buttonHeight）
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: Metrics.buttonHPadding, bottom: 0, right: Metrics.buttonHPadding)
        button.addTarget(self, action: #selector(didTapToggle(_:)), for: .touchUpInside)
        addSubview(button)

        button.snp.makeConstraints { make in
            make.height.equalTo(Metrics.buttonHeight)
            make.bottom.equalToSuperview()
            switch type {
            case .right: make.trailing.equalToSuperview()
            case .left: make.leading.equalToSuperview()
            }
        }
    }

    private func updateButtonTitle() {
        button.setTitle(isExpanded ? activeText : unActiveText, for: .normal)
        // 标题文字变化→钮宽变化→组件内容尺寸变化；失效缓存让 AutoLayout 重算（钮锚点稳定）。
        invalidateIntrinsicContentSize()
    }

    /// 组件自身内容尺寸 = 钮宽（标题+横向内边距自适应）× 钮高 40。
    ///
    /// 关键（D3/D4"钮点不动"根因修复）：宿主通常只锚 trailing/bottom 两角、不给组件宽高，
    /// 若无 intrinsic 内容尺寸，Auto Layout 对父视图尺寸是 ambiguous 的——布局解析结果
    /// 依赖容器/内容高度等外部因素，导致部分段组件 bounds 不含钮（钮渲染在父外却不可点）。
    /// 提供确定内容尺寸后，宿主只锚角也能把组件撑到钮大小，钮必然落在自身 bounds 内。
    override var intrinsicContentSize: CGSize {
        CGSize(width: button.intrinsicContentSize.width, height: Metrics.buttonHeight)
    }

    @objc private func didTapToggle(_ sender: UIButton) {
        guard !items.isEmpty else { return }
        isExpanded ? collapse(animated: true) : expand(animated: true)
    }

    // MARK: - 展开 / 收起

    /// 收起面板（外部"点面板外收起"等场景调用；按钮文案同步回收起态）。
    func collapse(animated: Bool = true) {
        guard isExpanded, let card = panelCard else { return }
        isExpanded = false
        updateButtonTitle()
        let dismiss: () -> Void = { card.alpha = 0 }
        let finish: (Bool) -> Void = { [weak self] _ in
            card.removeFromSuperview()
            self?.panelCard = nil
        }
        if animated {
            UIView.animate(withDuration: 0.18, animations: dismiss, completion: finish)
        } else {
            dismiss()
            finish(true)
        }
    }

    /// 命中查询：判断给定点（相对本组件坐标）是否落在"组件可交互区"=收起钮 ∪ 展开面板卡片。
    ///
    /// 供宿主做"点面板外收起"手势判定：命中返回 true=点击交给组件内部处理（钮开合 / 行选中），
    /// 宿主不应额外收起；未命中=面板外空白，宿主可调用 `collapse()`。不依赖组件自身 frame 尺寸
    /// （组件是纯容器，尺寸由宿主锚定约束推导，钮/卡片布局可超出 bounds）。
    func hitTestInteractiveArea(point: CGPoint) -> Bool {
        if button.frame.contains(point) { return true }
        if let card = panelCard, card.frame.contains(point) { return true }
        return false
    }

    /// hitTest 兜底（D3/D4"钮可见却点不动"根因修复）：
    ///
    /// 本组件是纯容器、无 intrinsic 尺寸，宿主只锚 trailing/bottom 两角；AutoLayout 对
    /// "父视图无宽高约束、子视图只锚底/角"是 ambiguous 的，FixedNavView 的 bounds 可能小于
    /// 钮实际 frame（钮渲染在父 bounds 之外——UIView 默认不裁剪所以"看得见"）。而 UIKit 默认
    /// hitTest 要求命中点落在父 bounds 内才下钻子视图 → 钮永远收不到 touchUpInside。
    /// 各 demo 段容器/内容高度不同会改变布局解析结果，故 D1/D2 正常、D3/D4 失灵。
    ///
    /// 修复：点落在钮或展开面板（含面板内行按钮）的实际 frame 上时，把命中显式转发给对应子视图，
    /// 使钮开合/行选中不再依赖宿主给足组件 bounds。
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard !isHidden, isUserInteractionEnabled, alpha > 0.01 else { return nil }

        let hit = super.hitTest(point, with: event)
        if let hit, hit !== self { return hit }

        // 点不在自身 bounds（或仅命中容器自身）：向钮与面板卡片递归命中（含面板内行按钮）。
        let targets: [UIView] = [button] + (panelCard.map { [$0] } ?? [])
        for target in targets {
            guard !target.isHidden, target.isUserInteractionEnabled, target.alpha > 0.01 else { continue }
            let local = convert(point, to: target)
            if target.bounds.contains(local),
               let sub = target.hitTest(local, with: event) {
                return sub
            }
        }
        return nil
    }

    private func expand(animated: Bool) {
        guard !isExpanded else { return }
        isExpanded = true
        updateButtonTitle()
        let card = makePanelCard()
        panelCard = card
        addSubview(card)
        card.snp.makeConstraints { make in
            switch type {
            case .right: make.trailing.equalToSuperview()
            case .left: make.leading.equalToSuperview()
            }
            make.bottom.equalTo(button.snp.top).offset(-Metrics.panelToButtonGap)
        }
        if animated {
            card.alpha = 0
            UIView.animate(withDuration: 0.18) { card.alpha = 1 }
        }
    }

    // MARK: - 面板

    /// 构建面板卡片：卡片壳（bgCard/圆角 md/边框/阴影）+ 竖排行（行高 44，末行无下边线）。
    private func makePanelCard() -> UIView {
        let card = UIView()
        card.backgroundColor = AppColor.bgCard
        card.layer.cornerRadius = AppRadius.md
        card.layer.borderWidth = 0.5
        card.layer.borderColor = AppColor.border.cgColor
        card.layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
        card.layer.shadowOpacity = 1
        card.layer.shadowOffset = CGSize(width: 0, height: 2)
        card.layer.shadowRadius = 8
        card.layer.masksToBounds = false

        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fill
        stack.alignment = .fill
        stack.spacing = 0
        card.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        for (index, item) in items.enumerated() {
            let row = FixedNavItemRowButton(item: item, showSeparator: index < items.count - 1) { [weak self] in
                guard let self else { return }
                // 点项=回传并自动收起面板（P2 契约）
                self.onSelect?(item)
                self.collapse(animated: true)
            }
            stack.addArrangedSubview(row)
            row.snp.makeConstraints { make in
                make.height.equalTo(Metrics.panelRowHeight)
                make.width.greaterThanOrEqualTo(Metrics.minPanelWidth)
            }
        }
        return card
    }
}

// MARK: - 面板行按钮

/// 面板导航行：整行可点；可选 图标位(20 圆角 6 primaryMuted) + 文案 + 可选 num 角标；底细分割线。
private final class FixedNavItemRowButton: UIButton {

    private let separator = UIView()
    private let onTap: () -> Void

    init(item: FixedNavItem, showSeparator: Bool, onTap: @escaping () -> Void) {
        self.onTap = onTap
        super.init(frame: .zero)
        backgroundColor = .clear
        contentHorizontalAlignment = .fill

        let content = UIStackView()
        content.axis = .horizontal
        content.alignment = .center
        content.spacing = AppSpace.sm
        content.isUserInteractionEnabled = false
        addSubview(content)
        content.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(AppSpace.md)
            make.centerY.equalToSuperview()
        }

        if let icon = item.icon {
            let slot = UIView()
            slot.backgroundColor = AppColor.primaryMuted
            slot.layer.cornerRadius = AppRadius.sm
            slot.layer.masksToBounds = true
            let iconLabel = UILabel()
            iconLabel.text = icon
            iconLabel.font = .systemFont(ofSize: AppFont.sizeXs, weight: .semibold)
            iconLabel.textColor = AppColor.primary
            iconLabel.textAlignment = .center
            slot.addSubview(iconLabel)
            iconLabel.snp.makeConstraints { make in
                make.center.equalToSuperview()
            }
            content.addArrangedSubview(slot)
            slot.snp.makeConstraints { make in
                make.width.height.equalTo(FixedNavView.Metrics.iconSlotSize)
            }
        }

        let title = UILabel()
        title.text = item.text
        title.font = .systemFont(ofSize: AppFont.sizeSm)
        title.textColor = AppColor.textPrimary
        title.numberOfLines = 1
        content.addArrangedSubview(title)

        if let num = item.num, num > 0 {
            let badge = NumBadgeView(num: num)
            content.addArrangedSubview(badge)
            badge.snp.makeConstraints { make in
                make.height.equalTo(FixedNavView.Metrics.numBadgeHeight)
            }
        }

        separator.backgroundColor = AppColor.border
        separator.isHidden = !showSeparator
        addSubview(separator)
        separator.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }

        addTarget(self, action: #selector(handleTap), for: .touchUpInside)
    }

    @objc private func handleTap() {
        onTap()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("FixedNavItemRowButton 不支持 initWithCoder 解码。")
    }
}

// MARK: - num 角标

/// 主色圆角数字角标：高 16、圆角=full、白字、横向留白（内容自适应宽度）。
private final class NumBadgeView: UIView {

    private let label = UILabel()

    init(num: Int) {
        super.init(frame: .zero)
        backgroundColor = AppColor.primary
        layer.cornerRadius = FixedNavView.Metrics.numBadgeHeight / 2
        layer.masksToBounds = true

        label.text = "\(num)"
        label.font = .systemFont(ofSize: AppFont.sizeXs, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        addSubview(label)
        label.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(AppSpace.xs)
            make.centerY.equalToSuperview()
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("NumBadgeView 不支持 initWithCoder 解码。")
    }

    override var intrinsicContentSize: CGSize {
        let textW = label.intrinsicContentSize.width
        let w = textW + AppSpace.xs * 2
        return CGSize(width: max(w, FixedNavView.Metrics.numBadgeHeight), height: FixedNavView.Metrics.numBadgeHeight)
    }
}
