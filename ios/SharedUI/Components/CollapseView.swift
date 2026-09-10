/// Collapse 折叠面板组件（UIKit 版，对齐 Android Collapse）。
///
/// 可折叠/展开的内容区域——点击标题展开或收起内容，用于将较长内容分组收纳、节省页面纵向空间。
/// 数据驱动 items 数组（每项 title+contentView+key+disabled），activeKeys 控制展开项 key 列表
/// （nil=内部自管理，非 nil=受控），accordion 开手风琴互斥（只展一项），右侧 chevron 箭头展开时旋转。
///
/// 用法：
/// ```swift
/// let panel = CollapseView()
/// panel.items = [
///     CollapseItem(key: "1", title: "标题一", contentView: label1),
///     CollapseItem(key: "2", title: "标题二", contentView: label2, disabled: true),
/// ]
/// // 受控：panel.activeKeys = ["1"]
/// ```
///
/// 决策（与设计规格 collapse-design-spec.html 一致）：
/// - P1-C 混合受控：activeKeys 非空=受控，nil=内部自管理
/// - P2-A 一期无动画：瞬切显隐（高度动画=二期）
/// - P3-A 默认右侧 chevron 旋转：收起=右指(identity)，展开=下指(rotate 90°)
/// - P4-A 一期=基础折叠/手风琴/禁用/受控+demo 四段
///
/// 注：标题点击遵循手册禁令——用 UITapGestureRecognizer(target:action:) + objc 方法，
/// 不用 UIAction/addAction(for:) block 新 API（iOS14+）。

import UIKit
import SnapKit

/// 折叠项数据。
struct CollapseItem {
    let key: String
    let title: String
    let contentView: UIView
    let disabled: Bool

    init(key: String, title: String, contentView: UIView, disabled: Bool = false) {
        self.key = key
        self.title = title
        self.contentView = contentView
        self.disabled = disabled
    }
}

final class CollapseView: UIView {
    // MARK: - 配置属性

    /// 折叠项数据数组。设置后重建布局。
    var items: [CollapseItem] = [] { didSet { rebuild() } }

    /// 展开项 key 列表；nil=内部自管理状态，非 nil=受控。
    var activeKeys: [String]? { didSet { applyState() } }

    /// 手风琴模式：true 时只允许一项展开，展新项自动收旧项。
    var accordion: Bool = false { didSet { applyState() } }

    /// 展开态变化回调，返回最新 activeKeys。
    var onChange: (([String]) -> Void)?

    // MARK: - 内部状态

    /// 内部自管理展开 key 集合（activeKeys==nil 时生效）。
    private var internalKeys: Set<String> = []

    /// 当前的有效展开 key 集合（受控优先，否则内部）。
    private var effectiveKeys: Set<String> {
        if let active = activeKeys { return Set(active) }
        return internalKeys
    }

    /// 面板纵向容器：每个 itemStack + 项间 divider 交替排列。
    private let panelStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        stack.alignment = .fill
        return stack
    }()

    /// 每项的视图句柄（标题行、箭头、内容容器），按 items 索引对齐。
    private var rows: [(header: UIView, chevron: UIImageView, contentContainer: UIView)] = []

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("CollapseView does not support NSCoder")
    }

    private func setup() {
        backgroundColor = AppColor.bgCard
        layer.cornerRadius = AppRadius.lg
        clipsToBounds = true

        addSubview(panelStack)
        panelStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    // MARK: - 重建布局

    /// 全量重建：清空容器并按 items 重新生成标题行/内容区/分隔线。
    private func rebuild() {
        // 清空旧 arrangedSubviews 与 rows。
        panelStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        rows = []

        for (index, item) in items.enumerated() {
            // 每项纵向栈：标题行 + 内容容器。UIStackView 隐藏 arrangedSubview 时自动收起空间。
            let itemStack = UIStackView()
            itemStack.axis = .vertical
            itemStack.spacing = 0
            itemStack.alignment = .fill

            // 标题行：titleLabel + chevron，整行可点（禁用态关闭交互）。
            let header = UIView()
            header.tag = index
            // 手册禁令：用 target/action + objc 方法，不用 UIAction/addAction block。
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleHeaderTap(_:)))
            header.addGestureRecognizer(tap)

            let titleLabel = UILabel()
            titleLabel.text = item.title
            titleLabel.font = .systemFont(ofSize: AppFont.sizeMd, weight: .medium)
            titleLabel.textColor = item.disabled ? AppColor.gray25 : AppColor.textPrimary
            titleLabel.numberOfLines = 1
            titleLabel.lineBreakMode = .byTruncatingTail
            titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            header.addSubview(titleLabel)

            let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
            chevron.tintColor = AppColor.gray25
            chevron.contentMode = .scaleAspectFit
            chevron.setContentHuggingPriority(.required, for: .horizontal)
            header.addSubview(chevron)

            titleLabel.snp.makeConstraints { make in
                make.leading.equalToSuperview().offset(AppSpace.lg)
                make.trailing.equalTo(chevron.snp.leading).offset(-AppSpace.sm)
                make.top.bottom.equalToSuperview().inset(AppSpace.cellVertical)
            }
            chevron.snp.makeConstraints { make in
                make.trailing.equalToSuperview().offset(-AppSpace.lg)
                make.centerY.equalToSuperview()
                make.width.height.equalTo(AppSpace.lg)
            }

            // 内容容器：包裹业务 contentView，隐藏态 isHidden=true 由 UIStackView 收起。
            let contentContainer = UIView()
            contentContainer.addSubview(item.contentView)
            item.contentView.snp.makeConstraints { make in
                make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: AppSpace.lg, bottom: AppSpace.md, right: AppSpace.lg))
            }

            itemStack.addArrangedSubview(header)
            itemStack.addArrangedSubview(contentContainer)
            panelStack.addArrangedSubview(itemStack)

            // 项间分隔线：非末项。
            if index < items.count - 1 {
                let divider = UIView()
                divider.backgroundColor = AppColor.border
                panelStack.addArrangedSubview(divider)
                divider.snp.makeConstraints { make in
                    make.height.equalTo(1)
                }
            }

            rows.append((header: header, chevron: chevron, contentContainer: contentContainer))
        }
        applyState()
    }

    // MARK: - 点击处理

    /// 标题行点击：toggle 对应项展开态（禁用态不响应）。
    @objc private func handleHeaderTap(_ gesture: UITapGestureRecognizer) {
        guard let index = gesture.view?.tag, index >= 0, index < items.count else { return }
        let item = items[index]
        guard !item.disabled else { return }
        toggle(key: item.key)
    }

    /// 切换某项展开/收起，并同步状态/回调。
    private func toggle(key: String) {
        var keys = effectiveKeys
        if keys.contains(key) {
            keys.remove(key)
        } else {
            if accordion { keys = [key] } else { keys.insert(key) }
        }
        if activeKeys == nil {
            internalKeys = keys
        }
        onChange?(Array(keys))
        applyState()
    }

    // MARK: - 状态应用

    /// 按 effectiveKeys 同步每项展开/收起视觉态。
    private func applyState() {
        for (index, item) in items.enumerated() {
            guard index < rows.count else { continue }
            let row = rows[index]
            let expanded = effectiveKeys.contains(item.key)
            row.contentContainer.isHidden = !expanded
            // chevron 旋转：收起=identity(右指)，展开=rotate 90°(下指)。
            row.chevron.transform = expanded ? CGAffineTransform(rotationAngle: .pi / 2) : .identity
        }
    }
}
