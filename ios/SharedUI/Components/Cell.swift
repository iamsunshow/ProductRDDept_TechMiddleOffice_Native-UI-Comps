/// 通用列表行容器：左侧可选图标 + 中间标题（可副标题）+ 右侧值/箭头/状态标识。
///
/// 对标 NutUI Cell / Ant Design List.Item，支持五态（默认/禁用/加载/成功/失败）。
/// 业务侧把数据映射为 `CellModel` 即可复用；事件参数（数据+索引）由业务侧绑定透传。
///
/// - Note: 加载态标题区骨架占位；按下态背景 `gray.4`，松手恢复；行高最小 56（设计稿「32 号字 cell」单行，两行副标题自动增高到 76）。

import UIKit
import SnapKit

/// Cell 状态标识。
enum CellStatus {
    /// 默认：右侧按 `arrow` 显示箭头。
    case normal
    /// 成功：右侧 ✓（success 色）。
    case success
    /// 失败：右侧 !（error 色）。
    case error
}

/// 列表行数据模型（业务无关）。
struct CellModel {
    /// 主标题（必填）。
    var title: String
    /// 副标题；为空自动隐藏（单行）。
    var subtitle: String?
    /// 左侧图标（SF Symbol 名称）。
    var iconSymbol: String?
    /// 右侧值文本。
    var value: String?
    /// 是否显示右侧箭头，默认 true。
    var arrow: Bool = true
    /// 禁用态：背景置灰、文字置灰、不透箭头、不可点。
    var disabled: Bool = false
    /// 加载态：标题区骨架占位。
    var loading: Bool = false
    /// 状态标识，默认 .normal。
    var status: CellStatus = .normal

    init(
        title: String,
        subtitle: String? = nil,
        iconSymbol: String? = nil,
        value: String? = nil,
        arrow: Bool = true,
        disabled: Bool = false,
        loading: Bool = false,
        status: CellStatus = .normal
    ) {
        self.title = title
        self.subtitle = subtitle
        self.iconSymbol = iconSymbol
        self.value = value
        self.arrow = arrow
        self.disabled = disabled
        self.loading = loading
        self.status = status
    }
}

/// 通用列表行 Cell。
final class Cell: UITableViewCell {
    static let reuseId = "Cell"

    /// 最小行高（设计稿「32 号字 cell」单行 = 56pt = 16pt 内边距×2 + 24pt 主标题行高）。
    static let minHeight: CGFloat = 56

    /// 点击回调（参数=数据+索引）。
    var onTap: ((_ item: Any?, _ index: Int) -> Void)?
    /// 长按回调（iOS 触发；Android 不承诺，平台差异见平台登记）。
    var onLongPress: ((_ item: Any?, _ index: Int) -> Void)?
    /// 是否显示底部 1px 分隔线（最后一行由业务置 false）。
    var showsDivider: Bool = true {
        didSet { updateDivider() }
    }
    /// 行底部间隙（pt）。>0 时以「间隙」替代分隔线（对标 Android demo 的 Arrangement.spacedBy(16)）。
    var rowSpacing: CGFloat = 0 {
        didSet { updateDivider() }
    }

    private var boundItem: Any?
    private var boundIndex: Int = -1

    /// 手势代理：允许点击与长按共存识别，避免二者相互延迟/吞掉。
    private let gestureDelegate = CellGestureDelegate()

    /// 简化手势代理：允许多手势同时识别。
    private final class CellGestureDelegate: NSObject, UIGestureRecognizerDelegate {
        func gestureRecognizer(
            _ gestureRecognizer: UIGestureRecognizer,
            shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
        ) -> Bool { true }
    }

    /// 更新底部视图：横线(1px) / 间隙(rowSpacing) / 隐藏 三态。
    private func updateDivider() {
        if rowSpacing > 0 {
            // 间隙模式（与 Android 的 Arrangement.spacedBy(16) 对标）：
            // divider 撑高为 rowSpacing，铺满整行，颜色用页面背景 bgPage，视觉上即为 cell 间留白。
            // divider 独立于 contentView，点击态（contentView 变 gray4）不影响间隙，不会断层。
            dividerHeightConstraint?.update(offset: rowSpacing)
            divider.backgroundColor = AppColor.bgPage
            divider.isHidden = false
        } else if showsDivider {
            dividerHeightConstraint?.update(offset: 1)
            divider.backgroundColor = AppColor.border
            divider.isHidden = false
        } else {
            divider.isHidden = true
        }
    }


    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let valueLabel = UILabel()
    private let arrowView = UIImageView()
    private let statusBadge = UIImageView()
    private let skeletonView = UIView()
    private let divider = UIView()
    private var textStack: UIStackView!
    /// divider 高度约束引用（横线 1px 或间隙 rowSpacing）。
    private var dividerHeightConstraint: Constraint?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        // cell 自身背景设为 bgCard，覆盖 UITableViewCell 默认的白色 backgroundView，
        // 避免 automaticDimension 下 contentView 未完全撑满时从边缘露白条（曾导致"左侧高 54 宽 17 白条"）。
        backgroundColor = AppColor.bgCard
        contentView.backgroundColor = AppColor.bgCard

        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = AppColor.textSecondary

        titleLabel.font = .systemFont(ofSize: AppFont.sizeMd)
        titleLabel.textColor = AppColor.textPrimary
        // 标题抗压缩高：被 value 挤压时优先保证 title 完整显示（与 Android weight(1f) 行为一致）。
        titleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        titleLabel.lineBreakMode = .byTruncatingTail

        subtitleLabel.font = .systemFont(ofSize: AppFont.sizeSm)
        subtitleLabel.textColor = AppColor.textSecondary
        // 副标题可被压缩/截断（单行 ellipsis），优先保证 title 和右侧 value 的空间。
        subtitleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        subtitleLabel.lineBreakMode = .byTruncatingTail
        subtitleLabel.numberOfLines = 1

        valueLabel.font = .systemFont(ofSize: AppFont.sizeSm)
        valueLabel.textColor = AppColor.textSecondary
        valueLabel.textAlignment = .right
        valueLabel.setContentHuggingPriority(.required, for: .horizontal)

        arrowView.image = UIImage(systemName: "chevron.right")
        arrowView.tintColor = AppColor.gray25
        arrowView.contentMode = .scaleAspectFit
        arrowView.setContentHuggingPriority(.required, for: .horizontal)

        statusBadge.contentMode = .scaleAspectFit
        statusBadge.setContentHuggingPriority(.required, for: .horizontal)

        skeletonView.backgroundColor = AppColor.border
        skeletonView.layer.cornerRadius = AppRadius.sm
        skeletonView.isHidden = true

        divider.backgroundColor = AppColor.border

        textStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        textStack.axis = .vertical
        // 主标题-副标题间距：设计稿「32 号字 cell」4px@2x = 2pt。
        textStack.spacing = 2
        // textStack 是「中间文本列」，必须抗压缩=required：保证不被 value/arrow 完全挤没
        // （对标 Android Column(Modifier.weight(1f))，让文本列占据中间剩余空间）。
        textStack.setContentCompressionResistancePriority(.required, for: .horizontal)
        textStack.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textStack.alignment = .fill

        contentView.addSubview(iconView)
        contentView.addSubview(textStack)
        contentView.addSubview(valueLabel)
        contentView.addSubview(arrowView)
        contentView.addSubview(statusBadge)
        contentView.addSubview(skeletonView)
        contentView.addSubview(divider)

        // 注意：不要直接对 contentView 设 height 约束。
        // UITableViewCell 内部对 contentView 有系统管理的布局约束，叠加 height 约束会
        // 与 automaticDimension 的 systemLayoutSizeFitting 冲突（曾导致 cell 只显示一半）。
        // 最小行高改在 cell 的 systemLayoutSizeFitting 兜底实现（见下），标准且无冲突。

        iconView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(AppSpace.lg)
            make.centerY.equalTo(textStack.snp.centerY)
            make.width.height.equalTo(AppSpace.xl)
        }
        arrowView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(AppSpace.lg)
            make.centerY.equalTo(textStack.snp.centerY)
            make.width.height.equalTo(AppSpace.lg)
        }
        statusBadge.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(AppSpace.lg)
            make.centerY.equalTo(textStack.snp.centerY)
            make.width.height.equalTo(AppSpace.xl)
        }
        divider.snp.makeConstraints { make in
            // 间隙模式必须铺满整行宽（leading 不偏移）：
            // 若只从 x=lg 开始（之前），点击态下 contentView 变 gray4 而 divider 区保持 bgPage，
            // 会在 cell 左侧形成一条宽 lg 的颜色断层竖条（即曾出现的"左侧高 54 宽 17 白条"）。
            make.leading.trailing.bottom.equalToSuperview()
            // 保存高度约束引用供 updateDivider 动态改高度（横线 1px / 间隙 rowSpacing）。
            dividerHeightConstraint = make.height.equalTo(1).constraint
        }
        // 文本/骨架/右侧值的约束在 apply 中按 icon/arrow 显隐调整。
        skeletonView.snp.makeConstraints { make in
            make.leading.equalTo(textStack)
            make.centerY.equalTo(textStack)
            // 骨架宽度跟随 textStack 优先级=.medium，兜底最小 80，避免被 value 挤没。
            make.width.equalTo(textStack.snp.width).priority(.medium)
            make.width.greaterThanOrEqualTo(80)
            make.height.equalTo(AppFont.sizeMd)
        }

        // 应用默认分隔状态（横线 1px，bgPage 间隙色兜底）。
        updateDivider()

        // 点击手势：delaysTouchesBegan=false 让按压时 setHighlighted 立即变色，
        // 同时配合 GestureDelegate 使 tap 不被 longPress 延迟占用，保证 onTap 稳定触发。
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tap.delaysTouchesBegan = false
        tap.delaysTouchesEnded = false
        tap.delegate = gestureDelegate
        addGestureRecognizer(tap)
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        addGestureRecognizer(longPress)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    /// 自适高兜底最小行高（对标 Android `heightIn(min = 56.dp)`）。
    /// 不直接约束 contentView（会与 automaticDimension 冲突），而是由
    /// systemLayoutSizeFitting 在内容高度基础上取 max 到 Cell.minHeight，标准且无冲突。
    override func systemLayoutSizeFitting(
        _ targetSize: CGSize,
        withHorizontalFittingPriority horizontalPriority: UILayoutPriority,
        verticalFittingPriority: UILayoutPriority
    ) -> CGSize {
        var size = super.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: horizontalPriority,
            verticalFittingPriority: verticalFittingPriority
        )
        size.height = max(size.height, Cell.minHeight)
        return size
    }

    /// 用数据模型绑定 Cell。
    ///
    /// - Parameter model: 列表行数据
    /// - Returns: 无
    func apply(_ model: CellModel) {
        boundItem = model
        // 显式行高对齐设计稿（主 24 / 副 18），两端一致；禁用态颜色置灰在下方统一处理。
        // 顺序：先赋 text，再用 attributed 覆写行高（attributedText 会被 text= 重置）。
        titleLabel.text = model.title
        titleLabel.setLineHeight(
            AppText.cellTitleLineHeight,
            fontSize: AppFont.sizeMd
        )
        subtitleLabel.text = model.subtitle
        subtitleLabel.setLineHeight(
            AppText.cellSubtitleLineHeight,
            fontSize: AppFont.sizeSm
        )

        // 左侧图标：存在时文本列右移，否则从左边距起排。
        // 先确定右侧 value 是否可见（决定 textStack 的 trailing 锚点）。
        let hasValue = !(model.value?.isEmpty ?? true)
        valueLabel.text = model.value
        valueLabel.isHidden = !hasValue

        if let symbol = model.iconSymbol, !symbol.isEmpty {
            iconView.image = UIImage(systemName: symbol)
            iconView.isHidden = false
            textStack.snp.remakeConstraints { make in
                make.leading.equalTo(iconView.snp.trailing).offset(AppSpace.md)
                if hasValue {
                    make.trailing.lessThanOrEqualTo(valueLabel.snp.leading).offset(-AppSpace.sm)
                } else {
                    // value 不可见时，文本列直接撑到右侧安全区，避免被空 valueLabel 挤压。
                    make.trailing.lessThanOrEqualToSuperview().inset(AppSpace.lg)
                }
                // 关键：textStack 用精确的 top+bottom 约束闭合到 contentView，
                // 唯一确定 contentView 高度（自适高由它撑起）。不要用 centerY+>=/<= 弱约束。
                // 上下内边距用设计稿 16pt（cellVertical），对齐两端高度。
                make.top.equalToSuperview().offset(AppSpace.cellVertical)
                make.bottom.equalToSuperview().offset(-AppSpace.cellVertical)
                // 最小高度：loading 时 title/subtitle 均隐藏，textStack 会塌为 0，
                // 用 min 高度保证骨架有垂直空间且不至于上下错位。
                make.height.greaterThanOrEqualTo(AppFont.sizeMd)
            }
        } else {
            iconView.image = nil
            iconView.isHidden = true
            textStack.snp.remakeConstraints { make in
                make.leading.equalToSuperview().offset(AppSpace.lg)
                if hasValue {
                    make.trailing.lessThanOrEqualTo(valueLabel.snp.leading).offset(-AppSpace.sm)
                } else {
                    // value 不可见时，文本列直接撑到右侧安全区。
                    make.trailing.lessThanOrEqualToSuperview().inset(AppSpace.lg)
                }
                // 同上有图标分支：textStack 精确闭合 top/bottom，撑起 contentView 高度。
                make.top.equalToSuperview().offset(AppSpace.cellVertical)
                make.bottom.equalToSuperview().offset(-AppSpace.cellVertical)
                // 最小高度：loading 时 title/subtitle 均隐藏，textStack 会塌为 0。
                make.height.greaterThanOrEqualTo(AppFont.sizeMd)
            }
        }

        // 右侧值（isHidden 已在上面设置）。
        if !hasValue {
            valueLabel.text = nil
        }

        // 状态标识：success/error 时替换箭头位。
        let hasStatus = model.status != .normal
        switch model.status {
        case .success:
            statusBadge.image = UIImage(systemName: "checkmark.circle.fill")
            statusBadge.tintColor = AppColor.success
        case .error:
            statusBadge.image = UIImage(systemName: "exclamationmark.circle.fill")
            statusBadge.tintColor = AppColor.error
        case .normal:
            statusBadge.image = nil
        }
        statusBadge.isHidden = !hasStatus

        // 箭头：arrow 且无状态标识且非禁用时显示；隐藏时值文本贴右。
        let showArrow = model.arrow && !hasStatus && !model.disabled
        arrowView.isHidden = !showArrow
        // valueLabel 的 trailing 锚点：
        //   1. 有箭头：在箭头左侧（保持 ❯ 与 value 间 sm 间距）
        //   2. 有状态标识：在状态标识左侧（避免被状态图标覆盖）
        //   3. 都没有：贴 contentView 右安全区
        // 优先级：状态 > 箭头（statusBadge 与 arrowView 互斥时不会撞车）
        let valueTrailingTarget: UIView = hasStatus
            ? statusBadge
            : (showArrow ? arrowView : self.contentView)
        let valueTrailingOffset: CGFloat = (hasStatus || showArrow) ? -AppSpace.sm : -AppSpace.lg
        valueLabel.snp.remakeConstraints { make in
            make.trailing.equalTo(valueTrailingTarget.snp.leading).offset(valueTrailingOffset)
            // 跟随 textStack 垂直居中（textStack 撑起 contentView 高度）。
            make.centerY.equalTo(textStack.snp.centerY)
            make.leading.greaterThanOrEqualTo(textStack.snp.trailing).offset(AppSpace.sm)
        }

        // 加载骨架：仅显示骨架占位，隐藏标题/副标题/值/箭头/状态标识。
        let loading = model.loading
        skeletonView.isHidden = !loading
        titleLabel.isHidden = loading
        subtitleLabel.isHidden = loading || (model.subtitle?.isEmpty ?? true)
        if loading {
            valueLabel.isHidden = true
            // 加载态：保留箭头与状态标识的可见性（对标 Android：arrow 不受 loading 影响）。
            // 骨架动画表达"加载中"，箭头表达"可点击进入详情"，二者语义独立。
            startSkeleton()
        } else {
            // 恢复 valueLabel/arrowView 的显示由后续禁用/箭头逻辑控制。
            valueLabel.isHidden = model.value?.isEmpty ?? true
            // 箭头/状态标识显示规则在前面已设置，loading 退出后保持。
            stopSkeleton()
        }

        // 禁用态：背景/文字置灰、不透标识、不可点。
        let disabled = model.disabled
        contentView.backgroundColor = disabled ? AppColor.gray4 : AppColor.bgCard
        titleLabel.textColor = disabled ? AppColor.gray25 : AppColor.textPrimary
        subtitleLabel.textColor = disabled ? AppColor.gray25 : AppColor.textSecondary
        valueLabel.textColor = disabled ? AppColor.gray25 : AppColor.textSecondary
        iconView.tintColor = disabled ? AppColor.gray25 : AppColor.textSecondary
        if disabled { statusBadge.isHidden = true }
        isUserInteractionEnabled = !disabled
    }

    /// 绑定事件参数（数据 + 索引），供 onTap/onLongPress 透传。
    /// - Parameters:
    ///   - item: 数据
    ///   - index: 所在行索引
    /// - Returns: 无
    func bind(_ item: Any?, index: Int) {
        boundItem = item
        boundIndex = index
    }

    /// 按下态反馈：背景 gray.4，松手恢复。
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        contentView.backgroundColor = highlighted ? AppColor.gray4 : AppColor.bgCard
    }

    @objc private func handleTap() {
        onTap?(boundItem, boundIndex)
    }

    @objc private func handleLongPress(_ recognizer: UILongPressGestureRecognizer) {
        guard recognizer.state == .began else { return }
        onLongPress?(boundItem, boundIndex)
    }

    private func startSkeleton() {
        stopSkeleton()
        let pulse = CABasicAnimation(keyPath: "opacity")
        pulse.fromValue = 1
        pulse.toValue = 0.35
        pulse.duration = 0.8
        pulse.autoreverses = true
        pulse.repeatCount = .infinity
        skeletonView.layer.add(pulse, forKey: "skeletonPulse")
    }

    private func stopSkeleton() {
        skeletonView.layer.removeAnimation(forKey: "skeletonPulse")
    }
}
