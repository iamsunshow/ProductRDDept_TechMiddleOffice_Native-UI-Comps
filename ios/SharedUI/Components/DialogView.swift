/// Dialog 对话框（UIKit 版，对齐 Android AppDialog / api.json `ui.dialog`）。
///
/// 组件 ID：`ui.dialog` ｜ 任务清单 #46 ｜ 操作反馈区第三件 ｜ TMO 组件库 v1.4.0
///
/// 定位：居中弹出的模态对话框——标题 + 正文 + 操作按钮，用于确认/警示/告知。
/// 与 ActionSheet #44（底部动作面板）划界：Dialog=居中确认对话（是/否），
/// ActionSheet=底部多选一动作列表。
///
/// 契约 props（与 Android AppDialog 100% 对齐）：
/// - title: String?（null=不渲染标题区）
/// - content: String?（正文文本，与自定义内容二选一）
/// - contentView: UIView?（自定义正文内容，优先于 content）
/// - actions: [DialogAction]（必传：按钮列表）
/// - buttonLayout: DialogButtonLayout（默认 .vertical 通栏；.horizontal 并排最多 2 项）
/// - onDismiss: (() -> Void)?（null=不响应遮罩点击；非 null=点遮罩关闭并回调）
///
/// 事件：
/// - 点击任一操作按钮 → 先 dismiss 动画 → 再回调 action.onClick
/// - 点击遮罩（onDismiss != nil）→ 先 dismiss 动画 → 再回调 onDismiss
///
/// 设计规格（design-spec/dialog-design-spec.html）：
/// - 遮罩：全屏 black 45%
/// - 卡片：居中，width 300~360，radiusLg 14，bgCard 白底
/// - 标题：Md16 SemiBold textPrimary 居中，padding top lg
/// - 正文：Sm14 textSecondary 居中，lineHeight Sm，padding vertical lg
/// - Vertical 按钮：通栏全宽，高 44，radius 10，自上而下间距 md
/// - Horizontal 按钮：左右并排各 flex 1，高 44，间距 8
/// - Primary 按钮：primary 底白字
/// - Default 按钮：gray10 底 textPrimary
/// - Destructive 按钮：textPrimary 底 danger 字
///
/// 用法：
/// ```swift
/// let dialog = DialogViewController(
///     title: "确认删除",
///     content: "删除后不可恢复，确定删除？",
///     actions: [
///         DialogAction(text: "取消", onClick: { print("取消") }),
///         DialogAction(text: "删除", onClick: { print("删除") }, style: .destructive)
///     ],
///     onDismiss: { print("dismiss") }
/// )
/// dialog.show()
/// ```

import UIKit
import SnapKit

// MARK: - 数据模型

/// 按钮布局方式（与 Android DialogButtonLayout 对齐）。
public enum DialogButtonLayout {
    /// 通栏全宽，自上而下排列。
    case vertical
    /// 左右并排，各占一半（最多 2 项）。
    case horizontal
}

/// 按钮视觉样式（与 Android DialogButtonStyle 对齐）。
public enum DialogButtonStyle {
    /// 主操作：主色填充 + 白字。
    case primary
    /// 默认操作：浅灰填充 + 主文字色。
    case `default`
    /// 破坏性操作：白底/透明 + 危险红色文字。
    case destructive
}

/// 对话框操作按钮数据模型（与 Android DialogAction 对齐）。
public struct DialogAction {
    /// 按钮文案。
    public let text: String
    /// 点击回调（dismiss 动画结束后触发）。
    public let onClick: () -> Void
    /// 按钮视觉样式，默认 .default。
    public let style: DialogButtonStyle

    public init(text: String, onClick: @escaping () -> Void, style: DialogButtonStyle = .default) {
        self.text = text
        self.onClick = onClick
        self.style = style
    }
}

// MARK: - 主组件

/// 居中模态对话框 UIViewController（管理 overlay + card）。
///
/// 调用 `show()` 挂载到 keyWindow 并淡入+缩放弹出；点击按钮/遮罩后自动
/// 淡出+缩放收起并从 keyWindow 移除，再触发对应回调。
public final class DialogViewController: UIViewController {

    // MARK: 公共属性（props）

    /// 对话框标题（nil=不渲染标题区）。
    public let dialogTitle: String?
    /// 正文文本（contentView 为 nil 时使用）。
    public let content: String?
    /// 自定义正文内容视图（优先于 content）。
    public let contentView: UIView?
    /// 操作按钮列表（必传）。
    public let actions: [DialogAction]
    /// 按钮布局方式，默认 .vertical。
    public let buttonLayout: DialogButtonLayout
    /// 遮罩点击关闭回调（nil=不响应遮罩点击）。
    public let onDismiss: (() -> Void)?

    // MARK: 内部视图

    private let overlayView = UIView()   // 全屏遮罩（black 45% + 点击收起手势）
    private let cardView = UIView()      // 居中卡片容器（白底 + 圆角）

    private var isMounted = false        // 是否已挂载到 keyWindow

    // MARK: 设计常量（命名常量，杜绝魔法数字）

    private let overlayAlpha: CGFloat = 0.45          // 遮罩透明度（black 45%）
    private let cardCornerRadius: CGFloat = AppRadius.lg  // 卡片圆角 14
    private let cardWidth: CGFloat = 320              // 卡片宽度（300~360 区间取 320）
    private let cardHorizontalInset: CGFloat = 32     // 小屏下卡片距屏幕边最小间距
    private let buttonHeight: CGFloat = 44            // 按钮高度
    private let buttonCornerRadius: CGFloat = AppRadius.md  // 按钮圆角 10
    private let verticalButtonSpacing: CGFloat = AppSpace.md  // 通栏按钮间距 12
    private let horizontalButtonSpacing: CGFloat = 8  // 并排按钮间距 8
    private let fadeDuration: TimeInterval = 0.2      // 遮罩淡入/淡出时长
    private let scaleDuration: TimeInterval = 0.25    // 卡片缩放时长

    // MARK: 初始化

    public init(
        title: String? = nil,
        content: String? = nil,
        contentView: UIView? = nil,
        actions: [DialogAction],
        buttonLayout: DialogButtonLayout = .vertical,
        onDismiss: (() -> Void)? = nil
    ) {
        self.dialogTitle = title
        self.content = content
        self.contentView = contentView
        self.actions = actions
        self.buttonLayout = buttonLayout
        self.onDismiss = onDismiss
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: 生命周期

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = true
    }

    // MARK: 展示/收起

    /// 挂载到 keyWindow 并以「遮罩淡入 + 卡片缩放淡入」弹出。
    public func show() {
        guard !isMounted else { return }
        guard let hostView = Self.keyWindowHostView() else { return }

        // 挂载到 keyWindow 根视图（跨页面层级最高）
        view.frame = hostView.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        hostView.addSubview(view)

        // 构建 UI
        buildUI()

        // 初始状态：遮罩透明 + 卡片缩放 0.9 + 透明
        overlayView.alpha = 0
        cardView.alpha = 0
        cardView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        view.layoutIfNeeded()

        // 遮罩淡入
        UIView.animate(withDuration: fadeDuration) {
            self.overlayView.alpha = self.overlayAlpha
        }
        // 卡片缩放淡入（ease-out）
        UIView.animate(withDuration: scaleDuration, delay: 0, options: [.curveEaseOut]) {
            self.cardView.alpha = 1
            self.cardView.transform = .identity
        }
        isMounted = true
    }

    /// 以「遮罩淡出 + 卡片缩放淡出」收起并从 keyWindow 移除。
    /// - Parameter completion: 动画结束回调（移除后触发）。
    private func dismiss(completion: (() -> Void)? = nil) {
        guard isMounted else {
            completion?()
            return
        }
        // 遮罩淡出
        UIView.animate(withDuration: fadeDuration) {
            self.overlayView.alpha = 0
        }
        // 卡片缩放淡出（ease-in）
        UIView.animate(withDuration: scaleDuration, delay: 0, options: [.curveEaseIn]) {
            self.cardView.alpha = 0
            self.cardView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        } completion: { _ in
            self.view.removeFromSuperview()
            self.isMounted = false
            completion?()
        }
    }

    // MARK: UI 构建

    private func buildUI() {
        // 清理旧子视图（防止重复构建）
        overlayView.removeFromSuperview()
        cardView.removeFromSuperview()

        // ---- 遮罩层 ----
        overlayView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: overlayAlpha)
        overlayView.isUserInteractionEnabled = true
        view.addSubview(overlayView)
        overlayView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // 遮罩点击 → 若 onDismiss != nil 则收起并回调
        if onDismiss != nil {
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleOverlayTap))
            overlayView.addGestureRecognizer(tap)
        }

        // ---- 卡片 ----
        cardView.backgroundColor = AppColor.bgCard
        cardView.layer.cornerRadius = cardCornerRadius
        cardView.layer.cornerCurve = .continuous
        cardView.clipsToBounds = true
        view.addSubview(cardView)
        cardView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            // 宽度优先 320，小屏（宽度 < 320+64）则收缩到屏幕宽 - 两侧 32
            make.width.equalTo(cardWidth).priority(.high)
            make.leading.greaterThanOrEqualToSuperview().offset(cardHorizontalInset)
            make.trailing.lessThanOrEqualToSuperview().offset(-cardHorizontalInset)
        }

        // 卡片内容纵向堆叠
        let contentStack = UIStackView()
        contentStack.axis = .vertical
        contentStack.alignment = .fill
        contentStack.spacing = 0
        cardView.addSubview(contentStack)
        contentStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // ---- 标题（无 title=不渲染）----
        if let title = dialogTitle, !title.isEmpty {
            contentStack.addArrangedSubview(makeTitleLabel(title: title))
        }

        // ---- 正文（contentView 优先于 content 文本）----
        if let customView = contentView {
            // 自定义正文：垂直 lg 内边距
            let wrapper = UIView()
            wrapper.addSubview(customView)
            customView.snp.makeConstraints { make in
                make.edges.equalToSuperview().inset(UIEdgeInsets(top: AppSpace.lg, left: AppSpace.lg, bottom: AppSpace.lg, right: AppSpace.lg))
            }
            contentStack.addArrangedSubview(wrapper)
        } else if let text = content, !text.isEmpty {
            contentStack.addArrangedSubview(makeContentLabel(text: text))
        }

        // ---- 按钮区 ----
        // 按钮区左右 lg 内边距，底部 md 内边距（与 Android padding(bottom=md) 对齐）
        let buttonContainer = UIView()
        buttonContainer.layoutMargins = UIEdgeInsets(top: 0, left: AppSpace.lg, bottom: AppSpace.md, right: AppSpace.lg)
        contentStack.addArrangedSubview(buttonContainer)

        if buttonLayout == .vertical {
            buildVerticalButtons(in: buttonContainer)
        } else {
            buildHorizontalButtons(in: buttonContainer)
        }
    }

    // MARK: 子视图工厂

    /// 标题标签：Md16 SemiBold textPrimary 居中，padding top lg。
    private func makeTitleLabel(title: String) -> UIView {
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: AppFont.sizeMd, weight: .semibold)
        label.textColor = AppColor.textPrimary
        label.textAlignment = .center
        label.numberOfLines = 0

        let container = UIView()
        container.addSubview(label)
        label.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(AppSpace.lg)
            make.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(AppSpace.lg)
            make.trailing.equalToSuperview().offset(-AppSpace.lg)
        }
        return container
    }

    /// 正文标签：Sm14 textSecondary 居中，lineHeight，padding vertical lg。
    private func makeContentLabel(text: String) -> UIView {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: AppFont.sizeSm)
        label.textColor = AppColor.textSecondary
        label.textAlignment = .center
        label.numberOfLines = 0

        let container = UIView()
        container.addSubview(label)
        label.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(AppSpace.lg)
            make.bottom.equalToSuperview().offset(-AppSpace.lg)
            make.leading.equalToSuperview().offset(AppSpace.lg)
            make.trailing.equalToSuperview().offset(-AppSpace.lg)
        }
        return container
    }

    /// 构建通栏按钮（垂直排列，全宽，间距 md）。
    private func buildVerticalButtons(in container: UIView) {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = verticalButtonSpacing
        container.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalTo(container.layoutMarginsGuide)
        }
        for (index, action) in actions.enumerated() {
            let button = makeButton(action: action, index: index)
            stack.addArrangedSubview(button)
            button.snp.makeConstraints { make in
                make.height.equalTo(buttonHeight)
            }
        }
    }

    /// 构建并排按钮（左右各占一半，最多 2 项，间距 8）。
    private func buildHorizontalButtons(in container: UIView) {
        // 与 Android 一致：最多取前 2 项
        let visible = Array(actions.prefix(2))
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = horizontalButtonSpacing
        stack.distribution = .fillEqually
        container.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalTo(container.layoutMarginsGuide)
        }
        for (index, action) in visible.enumerated() {
            let button = makeButton(action: action, index: index)
            stack.addArrangedSubview(button)
            button.snp.makeConstraints { make in
                make.height.equalTo(buttonHeight)
            }
        }
    }

    /// 构建单个按钮（按 style 应用视觉，tag 传 index 供点击回调定位）。
    private func makeButton(action: DialogAction, index: Int) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(action.text, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: AppFont.sizeMd, weight: .semibold)
        button.layer.cornerRadius = buttonCornerRadius
        button.layer.cornerCurve = .continuous
        button.clipsToBounds = true
        button.tag = index

        // 按样式应用背景色与文字色
        switch action.style {
        case .primary:
            button.backgroundColor = AppColor.primary
            button.setTitleColor(.white, for: .normal)
            // 按下态：主色深一档
            button.setBackgroundColor(AppColor.primaryPressed, for: .highlighted)
        case .default:
            button.backgroundColor = AppColor.gray10
            button.setTitleColor(AppColor.textPrimary, for: .normal)
        case .destructive:
            // textPrimary 底（白底）+ danger 红字
            button.backgroundColor = AppColor.bgCard
            button.setTitleColor(AppColor.error, for: .normal)
        }

        button.addTarget(self, action: #selector(handleButtonTap(_:)), for: .touchUpInside)
        return button
    }

    // MARK: 手势/点击处理

    /// 遮罩点击 → 收起 → onDismiss()。
    @objc private func handleOverlayTap() {
        dismiss { [weak self] in
            self?.onDismiss?()
        }
    }

    /// 按钮点击 → 收起 → action.onClick()。
    /// 通过 button.tag 定位 action，避免闭包捕获 self 的循环引用。
    @objc private func handleButtonTap(_ sender: UIButton) {
        let index = sender.tag
        guard index >= 0, index < actions.count else { return }
        let action = actions[index]
        dismiss {
            action.onClick()
        }
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

// MARK: - UIButton 扩展：按状态设置背景色

private extension UIButton {
    /// 为指定状态设置背景色（通过生成纯色图片实现）。
    func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1))
        let image = renderer.image { context in
            color.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        }
        setBackgroundImage(image, for: state)
    }
}
