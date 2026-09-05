/// SideBarView 侧边导航：页面内容区左侧的竖排目录导航轨（垂直单选导航）。
///
/// 组件 ID：`ui.side-bar`（api.json 契约对齐，门禁 A AI 代评通过 2026-09-05，
/// 用户"除特色组件外所有组件评审文档全部生成，中间任何询问直接通过"总授权；
/// P1–P4 全 A：纯导航轨 + 数据驱动 + 半受控选中 + 一期无内置右内容联动）。
///
/// 一期语义（对标 NutUI React SideBar 收敛为库内自有设计语言）：
/// - [items]：SideBarItem 列表（title 单行省略 / value 稳定标识 / disabled 禁用项不可点）
/// - [selectedValue]：外部驱动选中（半受控）；nil=默认首项激活自管理
/// - [onChange]：点选回调 (value)；点击已激活项不重复回调（幂等）
/// - 轨内可滚动：项数超出可视区时 UIScrollView 纵向滚动；选中项自动滚入可视
/// - 激活视觉：选中项=白底胶囊 + 主色加粗（同导航项激活先例，浮于灰轨之上）
/// - 组件=纯导航轨（轨宽默认 96pt，宿主可宽度约束覆盖）；右侧内容联动完全宿主自理
///   （与 Elevator 划界：本组件不监听滚动/不做锚点跟随）
///
/// 用法：
/// ```swift
/// let sideBar = SideBarView(items: [
///     SideBarItem(title: "全部", value: "all"),
///     SideBarItem(title: "餐饮", value: "dining"),
/// ]) { value in
///     // 宿主切换右侧内容
/// }
/// host.addSubview(sideBar)
/// sideBar.snp.makeConstraints { make in
///     make.leading.top.bottom.equalToSuperview()
///     make.width.equalTo(SideBarView.Metrics.railWidth)
/// }
/// ```
import UIKit
import SnapKit

/// 侧边导航目录项数据（与 Android `SideBarItem` 同构）
struct SideBarItem {
    let title: String
    let value: String
    let disabled: Bool

    init(title: String, value: String, disabled: Bool = false) {
        self.title = title
        self.value = value
        self.disabled = disabled
    }
}

final class SideBarView: UIView {

    /// 组件内布局规格（与 Android 侧同数值不同单位；Token 对齐注释防魔法值误判）
    struct Metrics {
        /// 导航轨宽（96pt，与 Android 96dp 同构；宿主可随布局用宽度约束覆盖，建议 80–128）
        static let railWidth: CGFloat = 96
        /// 项行高（48pt，与 Android 48dp 同构；行内容垂直居中）
        static let rowHeight: CGFloat = 48
        /// 激活胶囊行内左右 margin（AppSpace.xs=4 → 胶囊宽=轨宽−8）
        static let capsuleMarginX: CGFloat = AppSpace.xs
        /// 激活胶囊高 = 行高 − 上下各 xs（48−8=40），圆角 full=高一半
        static let capsuleHeight: CGFloat = rowHeight - AppSpace.xs * 2
    }

    /// 数据项（可整体替换，didSet 重建轨内行 + 高亮）
    var items: [SideBarItem] {
        didSet { rebuildRows() }
    }

    /// 半受控选中值：外部赋值（受控/驱动）时同步高亮并滚入可视；nil=组件内部自管理
    var selectedValue: String? {
        didSet {
            guard selectedValue != oldValue else { return }
            refreshHighlightAndScroll(animated: false)
        }
    }

    private let onChange: ((_ value: String) -> Void)?

    /// 非受控模式下内部当前选中（首启用项兜底）
    private var internalValue: String?
    private let railScroll = UIScrollView()
    private var rowButtons: [(button: UIButton, item: SideBarItem)] = []

    init(items: [SideBarItem],
         selectedValue: String? = nil,
         onChange: ((_ value: String) -> Void)? = nil) {
        self.items = items
        self.selectedValue = selectedValue
        self.onChange = onChange
        super.init(frame: .zero)
        backgroundColor = .clear
        internalValue = firstEnabledItem()?.value
        setupRail()
        rebuildRows()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("SideBarView 不支持 initWithCoder 解码，请使用 init(items:selectedValue:onChange:)。")
    }

    /// 当前生效选中 value：外部受控值优先，其次内部自管理
    private var effectiveValue: String? {
        selectedValue ?? internalValue
    }

    private func firstEnabledItem() -> SideBarItem? {
        items.first(where: { !$0.disabled })
    }

    // MARK: - 布局

    private func setupRail() {
        // 轨背景=灰底（与 Android 侧 SideBar 容器 background(gray4) 同构）
        railScroll.backgroundColor = AppColor.gray4
        railScroll.showsVerticalScrollIndicator = false
        addSubview(railScroll)
        railScroll.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    /// 按 items 重建行按钮（含禁用行）；随后重排 frame 并刷新高亮
    private func rebuildRows() {
        for entry in rowButtons {
            entry.button.removeFromSuperview()
        }
        rowButtons.removeAll()

        for item in items {
            let button = UIButton(type: .system)
            button.setTitle(item.title, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: AppFont.sizeSm, weight: .regular)
            button.titleLabel?.lineBreakMode = .byTruncatingTail
            button.titleLabel?.numberOfLines = 1
            button.tintColor = .clear
            // 系统按压反馈（touchDown 压暗瞬态=表内放行，同 Grid/列表先例）
            button.addTarget(self, action: #selector(didTapRow(_:)), for: .touchUpInside)
            if item.disabled {
                button.isEnabled = false
            }
            railScroll.addSubview(button)
            rowButtons.append((button, item))
        }
        setNeedsLayout()
        refreshHighlightAndScroll(animated: false)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        var contentHeight: CGFloat = 0
        for (index, entry) in rowButtons.enumerated() {
            let item = entry.item
            // 胶囊区域：行内左右 margin xs → 宽=轨宽−8；高 40；随行号 y 排列
            let rowY = CGFloat(index) * Metrics.rowHeight
            let capsuleX = Metrics.capsuleMarginX
            let capsuleW = railScroll.bounds.width - Metrics.capsuleMarginX * 2
            entry.button.frame = CGRect(
                x: capsuleX,
                y: rowY + Metrics.capsuleMarginX,
                width: max(capsuleW, 0),
                height: Metrics.capsuleHeight
            )
            contentHeight = rowY + Metrics.rowHeight
        }
        // 内容高度 = 行数 × 行高（与 Android LazyColumn 滚动域同构）
        railScroll.contentSize = CGSize(width: railScroll.bounds.width, height: max(contentHeight, railScroll.bounds.height))
    }

    @objc private func didTapRow(_ sender: UIButton) {
        guard let value = rowButtons.first(where: { $0.button === sender })?.item.value,
              let item = items.first(where: { $0.value == value }),
              !item.disabled else { return }
        // 幂等：点击已激活项不重复回调（同 Cell/FixedNav 先例）
        guard value != effectiveValue else { return }
        if selectedValue == nil {
            internalValue = value
        }
        refreshHighlightAndScroll(animated: true)
        onChange?(value)
    }

    // MARK: - 高亮与滚入可视

    private func refreshHighlightAndScroll(animated: Bool) {
        guard let current = effectiveValue else { return }
        var targetButton: UIButton?
        for entry in rowButtons {
            let isSelected = entry.item.value == current && !entry.item.disabled
            let button = entry.button
            if isSelected {
                targetButton = button
                button.backgroundColor = AppColor.bgCard
                button.layer.cornerRadius = Metrics.capsuleHeight / 2
                button.setTitleColor(AppColor.primary, for: .normal)
                button.titleLabel?.font = .systemFont(ofSize: AppFont.sizeSm, weight: .bold)
            } else {
                button.backgroundColor = .clear
                button.layer.cornerRadius = Metrics.capsuleHeight / 2
                if entry.item.disabled {
                    // 禁用态：同 default 布局 + 文字透明度 40%（A2 规格）
                    let disabledColor = AppColor.textSecondary.withAlphaComponent(0.4)
                    button.setTitleColor(disabledColor, for: .normal)
                    button.setTitleColor(disabledColor, for: .disabled)
                    button.titleLabel?.font = .systemFont(ofSize: AppFont.sizeSm, weight: .regular)
                } else {
                    button.setTitleColor(AppColor.textSecondary, for: .normal)
                    button.titleLabel?.font = .systemFont(ofSize: AppFont.sizeSm, weight: .regular)
                }
            }
        }
        // 选中项滚入可视（外部驱动/点击均同步）
        if let button = targetButton {
            railScroll.scrollRectToVisible(button.frame.insetBy(dx: 0, dy: -Metrics.capsuleMarginX), animated: animated)
        }
    }
}
