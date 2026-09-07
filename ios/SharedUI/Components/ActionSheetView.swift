/// ActionSheet 动作面板（UIKit 版，对齐 Android ActionSheet.kt / api.json `ui.action-sheet`）。
///
/// 组件 ID：`ui.action-sheet` ｜ 任务清单 #44 ｜ 操作反馈区首件 ｜ TMO 组件库 v1.4.0
///
/// 定位：底部弹出的动作选择面板——点击触发按钮后从底部滑出，展示一组操作选项供用户点选，
/// 选中后自动收起。受控 visible 模式（与 DatePicker/Picker 一致），宿主完全控制生命周期。
///
/// 契约 props（与 api.json 100% 对齐）：
/// - visible: Bool（*必选*：true=挂载到 keyWindow + 滑入；false=滑出后卸载）
/// - title: String?（复用 UIViewController.title；null=不渲染标题行）
/// - description: String?（null=不渲染描述行；命名 descriptionText 避让 NSObject.description）
/// - actions: [ActionSheetItem]（*必选*：操作项列表）
/// - cancelText: String（默认 "取消"）
/// - onSelect: ((Int) -> Void)?（null=不回调仅收起）
/// - onCancel: (() -> Void)?（null=不回调）
/// - disabled: Bool（默认 false：整体禁用，所有操作项灰显不可点，取消按钮仍可点收起）
///
/// 事件：
/// - onSelect: (index: Int) -> Void（点击非禁用操作项 → 滑出 → 回调 index）
/// - onCancel: () -> Void（点击取消/遮罩 → 滑出 → 回调）
///
/// 设计规格（design-spec/action-sheet-design-spec.html）：
/// - 遮罩：black 45% 透明
/// - 面板：白底，顶部圆角 radiusLg 14pt
/// - 标题行：高 56，居中，fontMd(16) textSecondary；无 title=不渲染
/// - 描述行：标题下方，居中，fontSm(14) textSecondary；无 description=不渲染
/// - 操作项：高 56，居中，fontLg(18) textPrimary；destructive=danger 色；disabled=alpha 0.4
/// - 分隔线：操作项间 0.5pt hairline
/// - 间距条：操作列表与取消按钮间 8pt bgPage 灰底间隙
/// - 取消按钮：高 56，居中，fontLg(18) textPrimary，白底，顶部 hairline
/// - 底部安全区：safeAreaInsets.bottom padding
/// - 动画：遮罩淡入 200ms + 面板滑入 250ms ease-out
///
/// 用法：
/// ```swift
/// let sheet = ActionSheetView()
/// sheet.title = "分享到"
/// sheet.actions = [
///     ActionSheetItem(text: "微信好友"),
///     ActionSheetItem(text: "朋友圈"),
///     ActionSheetItem(text: "复制链接")
/// ]
/// sheet.onSelect = { index in print("选中: \(index)") }
/// sheet.visible = true  // 挂载到 keyWindow 并滑入
/// ```

import UIKit
import SnapKit

// MARK: - 数据模型

/// 操作项数据模型（与 api.json ActionSheetItem 对齐）。
public struct ActionSheetItem {
    /// 操作项文案。
    public let text: String
    /// 是否危险动作（红色文案）。
    public var destructive: Bool
    /// 该操作项是否禁用（灰显不可点）。
    public var disabled: Bool

    public init(text: String, destructive: Bool = false, disabled: Bool = false) {
        self.text = text
        self.destructive = destructive
        self.disabled = disabled
    }
}

// MARK: - 主组件

/// 底部动作面板 UIViewController（管理 overlay + panel）。
///
/// 受控 visible 驱动挂载/卸载到 keyWindow：
/// - visible=true → 挂载到 keyWindow + 遮罩淡入 200ms + 面板滑入 250ms ease-out
/// - visible=false → 面板滑出 250ms ease-in + 遮罩淡出 200ms → 从 keyWindow 移除
public final class ActionSheetView: UIViewController {

    // MARK: 公共属性（props）

    /// 面板标题（复用 UIViewController.title；nil=不渲染标题行）。
    // 注：直接使用继承的 title 属性，无需额外声明。

    /// 标题下方描述文案（nil=不渲染描述行）。
    /// 命名 descriptionText 以避让 NSObject.description 只读计算属性。
    public var descriptionText: String?

    /// 操作项列表（必传）。
    public var actions: [ActionSheetItem] = []

    /// 取消按钮文案，默认 "取消"。
    public var cancelText: String = "取消"

    /// 选中操作项回调（回传 index；nil=不回调仅收起）。
    public var onSelect: ((Int) -> Void)?

    /// 取消/遮罩点击回调（nil=不回调）。
    public var onCancel: (() -> Void)?

    /// 整体禁用（所有操作项灰显不可点，取消按钮仍可点收起）。
    public var disabled: Bool = false

    /// 是否展示（受控；true=挂载+滑入 / false=滑出+卸载）。
    public var visible: Bool = false {
        didSet {
            guard oldValue != visible else { return }
            if visible { show() } else { hide() }
        }
    }

    // MARK: 内部视图

    private let overlayView = UIView()      // 全屏遮罩（black 45% + 点击收起手势）
    private let panelView = UIView()        // 面板容器（白底 + 顶部圆角）
    private let contentStack = UIStackView() // 面板内容纵向堆叠
    private var panelBottomConstraint: Constraint?  // 面板底部约束（滑入/滑出动画用）
    private var isMounted = false          // 是否已挂载到 keyWindow

    // MARK: 设计常量（命名常量，杜绝魔法数字）

    private let rowHeight: CGFloat = 56        // 标题行/操作项/取消按钮高度
    private let gapHeight: CGFloat = 8         // 操作列表与取消按钮间灰底间隙
    private let overlayAlpha: CGFloat = 0.45  // 遮罩透明度（black 45%）
    private let slideDuration: TimeInterval = 0.25  // 面板滑入/滑出时长
    private let fadeDuration: TimeInterval = 0.20  // 遮罩淡入/淡出时长
    private let hairlineHeight: CGFloat = 0.5       // 分隔线 hairline

    // MARK: 生命周期

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = true
    }

    // MARK: 挂载/卸载（受控 visible 驱动）

    /// 挂载到 keyWindow 并滑入。
    private func show() {
        guard !isMounted else { return }
        guard let hostView = Self.keyWindowHostView() else { return }

        // 挂载到 keyWindow 根视图（跨页面层级最高）
        view.frame = hostView.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        hostView.addSubview(view)

        // 构建 UI
        buildUI()

        // 初始状态：遮罩透明 + 面板在屏幕下方
        overlayView.alpha = 0
        view.layoutIfNeeded()
        panelBottomConstraint?.update(offset: panelHeight)

        // 遮罩淡入 200ms
        UIView.animate(withDuration: fadeDuration) {
            self.overlayView.alpha = self.overlayAlpha
        }
        // 面板滑入 250ms ease-out
        view.layoutIfNeeded()
        UIView.animate(withDuration: slideDuration, delay: 0, options: [.curveEaseOut]) {
            self.panelBottomConstraint?.update(offset: 0)
            self.view.layoutIfNeeded()
        }
        isMounted = true
    }

    /// 滑出并从 keyWindow 卸载。
    private func hide() {
        guard isMounted else { return }
        // 遮罩淡出 200ms
        UIView.animate(withDuration: fadeDuration) {
            self.overlayView.alpha = 0
        }
        // 面板滑出 250ms ease-in
        UIView.animate(withDuration: slideDuration, delay: 0, options: [.curveEaseIn]) {
            self.panelBottomConstraint?.update(offset: self.panelHeight)
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.view.removeFromSuperview()
            self.isMounted = false
        }
    }

    // MARK: UI 构建

    private func buildUI() {
        // 清理旧子视图（防止重复构建）
        overlayView.removeFromSuperview()
        panelView.removeFromSuperview()

        // ---- 遮罩层 ----
        overlayView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: overlayAlpha)
        overlayView.isUserInteractionEnabled = true
        view.addSubview(overlayView)
        overlayView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // 遮罩点击 → onCancel 收起
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleOverlayTap))
        overlayView.addGestureRecognizer(tap)

        // ---- 面板 ----
        panelView.backgroundColor = AppColor.bgCard
        panelView.layer.cornerRadius = AppRadius.lg
        panelView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        panelView.layer.cornerCurve = .continuous
        panelView.clipsToBounds = true
        view.addSubview(panelView)
        panelView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            self.panelBottomConstraint = make.bottom.equalToSuperview().constraint
        }

        // 面板内容堆叠
        contentStack.axis = .vertical
        contentStack.alignment = .fill
        contentStack.spacing = 0
        panelView.addSubview(contentStack)
        contentStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // ---- 标题行（无 title=不渲染）----
        if let title = title, !title.isEmpty {
            let titleRow = makeTitleRow(title: title)
            contentStack.addArrangedSubview(titleRow)
            // 标题行底部 hairline
            contentStack.addArrangedSubview(makeHairline())
        }

        // ---- 描述行（无 description=不渲染）----
        if let desc = descriptionText, !desc.isEmpty {
            let descRow = makeDescriptionRow(desc: desc)
            contentStack.addArrangedSubview(descRow)
            contentStack.addArrangedSubview(makeHairline())
        }

        // ---- 操作项列表 ----
        for (index, item) in actions.enumerated() {
            let actionRow = makeActionRow(item: item, index: index)
            contentStack.addArrangedSubview(actionRow)
            // 非末项底部 hairline
            if index < actions.count - 1 {
                contentStack.addArrangedSubview(makeHairline())
            }
        }

        // ---- 间距条（8pt 灰底间隙）----
        let gapView = UIView()
        gapView.backgroundColor = AppColor.bgPage
        gapView.snp.makeConstraints { make in
            make.height.equalTo(gapHeight)
        }
        contentStack.addArrangedSubview(gapView)

        // ---- 取消按钮 ----
        let cancelRow = makeCancelRow()
        contentStack.addArrangedSubview(cancelRow)

        // ---- 底部安全区 ----
        let safeAreaBottom = UIView()
        safeAreaBottom.backgroundColor = AppColor.bgCard
        contentStack.addArrangedSubview(safeAreaBottom)
        safeAreaBottom.snp.makeConstraints { make in
            make.height.equalTo(view.safeAreaInsets.bottom)
        }
    }

    // MARK: 行工厂

    /// 标题行：高 56，居中，fontMd(16) textSecondary。
    private func makeTitleRow(title: String) -> UIView {
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: AppFont.sizeMd)
        label.textColor = AppColor.textSecondary
        label.textAlignment = .center
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        let container = UIView()
        container.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().offset(AppSpace.lg)
            make.trailing.lessThanOrEqualToSuperview().offset(-AppSpace.lg)
        }
        container.snp.makeConstraints { make in
            make.height.equalTo(rowHeight)
        }
        return container
    }

    /// 描述行：居中，fontSm(14) textSecondary。
    private func makeDescriptionRow(desc: String) -> UIView {
        let label = UILabel()
        label.text = desc
        label.font = .systemFont(ofSize: AppFont.sizeSm)
        label.textColor = AppColor.textSecondary
        label.textAlignment = .center
        label.numberOfLines = 0
        let container = UIView()
        container.addSubview(label)
        label.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(AppSpace.sm)
            make.bottom.equalToSuperview().offset(-AppSpace.sm)
            make.leading.greaterThanOrEqualToSuperview().offset(AppSpace.lg)
            make.trailing.lessThanOrEqualToSuperview().offset(-AppSpace.lg)
        }
        return container
    }

    /// 操作项行：高 56，居中，fontLg(18)；destructive=danger 色；disabled=alpha 0.4。
    private func makeActionRow(item: ActionSheetItem, index: Int) -> UIView {
        let label = UILabel()
        label.text = item.text
        label.font = .systemFont(ofSize: AppFont.sizeLg)
        label.textColor = item.destructive ? AppColor.error : AppColor.textPrimary
        label.textAlignment = .center
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail

        let container = UIView()
        container.backgroundColor = AppColor.bgCard
        container.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().offset(AppSpace.lg)
            make.trailing.lessThanOrEqualToSuperview().offset(-AppSpace.lg)
        }
        container.snp.makeConstraints { make in
            make.height.equalTo(rowHeight)
        }

        // 禁用判定：整体 disabled 或单项 disabled
        let isItemDisabled = disabled || item.disabled
        if isItemDisabled {
            container.alpha = 0.4
            container.isUserInteractionEnabled = false
        } else {
            // 点击操作项 → 滑出 → onSelect(index)
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleActionTap(_:)))
            container.addGestureRecognizer(tap)
            container.tag = index
            container.isUserInteractionEnabled = true
        }
        return container
    }

    /// 取消按钮：高 56，居中，fontLg(18) textPrimary，白底，顶部 hairline。
    private func makeCancelRow() -> UIView {
        let label = UILabel()
        label.text = cancelText
        label.font = .systemFont(ofSize: AppFont.sizeLg)
        label.textColor = AppColor.textPrimary
        label.textAlignment = .center
        let container = UIView()
        container.backgroundColor = AppColor.bgCard
        container.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().offset(AppSpace.lg)
            make.trailing.lessThanOrEqualToSuperview().offset(-AppSpace.lg)
        }
        container.snp.makeConstraints { make in
            make.height.equalTo(rowHeight)
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleCancelTap))
        container.addGestureRecognizer(tap)
        container.isUserInteractionEnabled = true
        return container
    }

    /// hairline 分隔线（0.5pt = 1/scale）。
    private func makeHairline() -> UIView {
        let line = UIView()
        line.backgroundColor = AppColor.border
        line.snp.makeConstraints { make in
            make.height.equalTo(1.0 / UIScreen.main.scale)
        }
        return line
    }

    // MARK: 手势处理

    /// 遮罩点击 → 滑出 → onCancel()。
    @objc private func handleOverlayTap() {
        visible = false
        onCancel?()
    }

    /// 取消按钮点击 → 滑出 → onCancel()。
    @objc private func handleCancelTap() {
        visible = false
        onCancel?()
    }

    /// 操作项点击 → 滑出 → onSelect(index)。
    /// 通过 container.tag 传递 index（避免闭包捕获 self 的循环引用）。
    @objc private func handleActionTap(_ recognizer: UITapGestureRecognizer) {
        let index = recognizer.view?.tag ?? -1
        guard index >= 0, index < actions.count else { return }
        visible = false
        onSelect?(index)
    }

    // MARK: 计算

    /// 面板总高度（用于滑入/滑出动画的位移量）。
    private var panelHeight: CGFloat {
        var height: CGFloat = 0
        // 标题行
        if let t = title, !t.isEmpty { height += rowHeight + hairlineHeight }
        // 描述行
        if let d = descriptionText, !d.isEmpty {
            // 描述行高度不固定，用估算值
            height += rowHeight + hairlineHeight
        }
        // 操作项
        height += CGFloat(actions.count) * rowHeight
        // 操作项间 hairline
        if actions.count > 1 {
            height += CGFloat(actions.count - 1) * hairlineHeight
        }
        // 间距条
        height += gapHeight
        // 取消按钮
        height += rowHeight
        // 底部安全区
        height += view.safeAreaInsets.bottom
        return height
    }

    // MARK: Helper：keyWindow 的根视图

    private static func keyWindowHostView() -> UIView? {
        let window = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first(where: { $0.isKeyWindow })
        return window?.rootViewController?.view ?? window
    }

    // MARK: Deinit

    deinit {
        view.removeFromSuperview()
    }
}
