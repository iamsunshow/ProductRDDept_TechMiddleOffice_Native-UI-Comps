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
        // cell + contentView 同色：v1.26 横屏 safeArea 修复后 contentView.frame = bounds，
        // 二者底色完全一致，对外呈现 bgCard（卡片白）。
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

        // 骨架：灰底 + 圆角 sm + 脉冲透明度，对齐 Android SkeletonTitle 视觉。
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

    /// v1.26 修复：强制 contentView 充满 cell。
    /// 原因：UITableViewCell 默认 `insetsContentViewsToSafeArea=true`（iOS 11+），
    /// 横屏时 iPhone X+ 系列 safeArea 左右各 44pt，系统把 contentView inset 到 safeArea
    /// 内，导致 cell 两侧（safeArea 外）露出 cell.backgroundColor（v1.25 诊断红色已确认）；
    /// 竖屏 safeArea 左右=0 故 contentView 充满 cell 无此问题。super.layoutSubviews() 后
    /// 系统已设置 contentView.frame（含 safeArea inset），此处覆盖为完整 bounds 让
    /// contentView 充满 cell。内容子视图仍受 leading/trailing offset 约束在 safeArea 内，
    /// 不会被刘海遮挡。
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = bounds
    }

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
        // v1.24：仅标题时也设行高 24pt（设计稿 cellTitleLineHeight）。
        // v1.20 曾注释"仅标题不设 attributedText，让 UILabel 原生垂直居中"，但实测发现：
        // 不设行高时 titleLabel 行高退化到系统默认 ~19pt，导致 textStack 只占 ~19pt，
        // cell 56pt 内上下空白 ~24pt（偏离设计稿 cellVertical=16pt）。
        // 设行高 24pt 后 textStack 24pt，centerY 居中到可见区（divider 上方 0-40pt），
        // 上下空白各 8pt（divider 占下方 16pt，故可见区上下内边距折半为 8pt，符合设计稿逻辑）。
        // 文字在 24pt 行框内的垂直位置由 lineHeightMultiple 决定（v1.19 改用 lineHeightMultiple，
        // iOS TextKit 在行框内更均匀分配空间，文字接近居中——见 AppTokens 注释）。
        // 顺序：先赋 text（清除旧 attributedText），再覆写行高。
        titleLabel.text = model.title
        let hasSubtitle = !(model.subtitle?.isEmpty ?? true)
        titleLabel.setLineHeight(
            AppText.cellTitleLineHeight,
            fontSize: AppFont.sizeMd
        )
        subtitleLabel.text = model.subtitle
        if hasSubtitle {
            subtitleLabel.setLineHeight(
                AppText.cellSubtitleLineHeight,
                fontSize: AppFont.sizeSm
            )
        }

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
                if hasSubtitle {
                    // 有副标题：top+bottom 精确闭合，撑起 contentView 高度。
                    // v1.30 修复：bottom 扣除 rowSpacing（divider 占了底部 rowSpacing 高的 bgPage 色间隙），
                    // 否则 textStack 视觉上顶住了 divider，"上面有 16pt 蓝色内边距，下面看起来没有"。
                    // 视觉对称：顶部 16pt 蓝 + 中间黄 + 底部 16pt 蓝 + 底部 divider（间隙灰）= 对称。
                    make.top.equalToSuperview().offset(AppSpace.cellVertical)
                    make.bottom.equalToSuperview().offset(-(AppSpace.cellVertical + rowSpacing))
                } else {
                    // v1.23：仅标题时用 centerY 居中到可见区域。
                    // 不加 top/bottom 约束——centerY + top>=16 会冲突，
                    // Auto Layout 被迫撑高 cell（56→67pt），多出白色块。
                    // cell 高度由 systemLayoutSizeFitting min 56pt 兜底，
                    // textStack 居中在 divider 上方的可见区域，不与 divider 重叠。
                    make.centerY.equalToSuperview().offset(-rowSpacing / 2.0)
                }
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
                if hasSubtitle {
                    make.top.equalToSuperview().offset(AppSpace.cellVertical)
                    make.bottom.equalToSuperview().offset(-(AppSpace.cellVertical + rowSpacing))  // 同上对称修复
                } else {
                    // v1.23：仅标题时用 centerY 居中到可见区域（同上有图标分支）。
                    make.centerY.equalToSuperview().offset(-rowSpacing / 2.0)
                }
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
        //   3. 都没有：贴 contentView 右边距 lg
        // 优先级：状态 > 箭头（statusBadge 与 arrowView 互斥时不会撞车）
        // v1.28 修复：原逻辑当无箭头无状态时 valueTrailingTarget=contentView，
        // 用 .snp.leading 锚点导致 valueLabel.trailing = contentView.leading - lg（左边外），
        // textStack.trailing <= valueLabel.leading - sm 变负数，文字被压缩消失。
        // 拆分分支：无箭头无状态时用 .equalToSuperview().inset(lg) 贴右边距。
        valueLabel.snp.remakeConstraints { make in
            if hasStatus {
                make.trailing.equalTo(statusBadge.snp.leading).offset(-AppSpace.sm)
            } else if showArrow {
                make.trailing.equalTo(arrowView.snp.leading).offset(-AppSpace.sm)
            } else {
                make.trailing.equalToSuperview().inset(AppSpace.lg)
            }
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

    /// 按下态反馈：背景 gray.4，松手恢复 bgCard。禁用态下此方法理论上不会被系统调用
    /// （apply() 已设置 `isUserInteractionEnabled = false`），但为保险起见仍显式 guard，
    /// 避免 setHighlighted 被系统/调用方强制触发时，覆盖掉 apply() 为禁用态设置的 gray4 背景
    /// （导致「禁用 cell 按住 → 松手恢复 bgCard 白色」视觉错位）。
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        // 禁用态 = !isUserInteractionEnabled（apply() 中统一赋值），此时禁止改背景。
        guard isUserInteractionEnabled else { return }
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

    // MARK: - 垂直居中实测辅助（iOS 实机校准用，验收通过后可移除）

    /// 测量「标题文字实际绘制中心」相对「cell 内容区垂直中心」的偏移（pt）。
    /// 正值=文字偏下，负值=文字偏上，0=完美居中。
    ///
    /// 背景：iOS 文字在行框内的视觉位置（受 minimumLineHeight 行高分配影响）无法
    /// 在本机（macOS）确定性还原，需在 iOS 实机读取真实渲染位置。demo 调用此方法
    /// 输出实测值，据此精确校准 `verticalCenterBaselineOffset`，替代纯数学推导。
    ///
    /// - Returns: 文字绘制中心的垂直偏移（pt）。0 = 居中。
    func debugTitleVerticalOffset() -> CGFloat {
        layoutIfNeeded()
        // 标题文字实际绘制矩形（单行时即文字像素框），坐标相对 titleLabel bounds。
        // textRect(forBounds:limitedToNumberOfLines:) 会结合 attributedText 的
        // 字体度量与行高设置，返回文字真实绘制区域。
        let textRect = titleLabel.textRect(forBounds: titleLabel.bounds, limitedToNumberOfLines: 1)
        // 文字绘制中心在 cell 内容区坐标系中的 y。
        let textCenterY = titleLabel.convert(CGPoint(x: 0, y: textRect.midY), to: contentView).y
        // cell 内容区（contentView）垂直中心。
        let cellCenterY = contentView.bounds.midY
        return textCenterY - cellCenterY
    }

    /// 测量「箭头（trailing 侧）视图中心」相对「cell 内容区垂直中心」的偏移（pt）。
    /// 正值=偏下，负值=偏上，0=居中。取当前可见的 trailing 锚点视图（箭头/状态标识/值）。
    ///
    /// - Returns: 偏移（pt）。
    func debugTrailingCenterOffset() -> CGFloat {
        layoutIfNeeded()
        let anchor = arrowView.isHidden ? valueLabel : arrowView
        let centerY = anchor.convert(CGPoint(x: 0, y: anchor.bounds.midY), to: contentView).y
        return centerY - contentView.bounds.midY
    }
}
