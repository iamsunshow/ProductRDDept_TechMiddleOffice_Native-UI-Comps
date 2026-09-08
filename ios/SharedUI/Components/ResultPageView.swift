/// ResultPage 结果反馈（UIKit 版，对齐 Android ResultPage.kt / api.json `ui.result-page`）。
///
/// 组件 ID：`ui.result-page` ｜ 任务清单 #56 ｜ 操作反馈区第十件 ｜ TMO 组件库 v1.4.4
///
/// 定位：整页/区域级操作结果反馈——四态图标+标题+描述+操作按钮列表。
///
/// 契约 props（与 api.json 100% 对齐）：
/// - type: ResultType（默认 .success：success/error/warning/info 四态）
/// - title: String（*必选*：结果标题）
/// - description: String?（null=不渲染描述行）
/// - actions: [ResultAction]（默认 []：操作按钮列表，按顺序水平排列）
/// - icon: UIView?（null=按 type 显示默认图标；!=nil 替换默认图标）
///
/// 事件：
/// - actions[i].onClick: () -> Void（点击对应操作按钮）
///
/// 设计规格（design-spec/result-page-design-spec.html）：
/// - 容器：整页或区域居中，bgPage 底
/// - 图标：56×56 圆形浅色底+对应色图标，居中
/// - 标题：fontLg(18) textPrimary semibold，图标下 12
/// - 描述：fontSm(14) textSecondary，标题下 4，居中
/// - 按钮组：描述下 24，水平排列居中，间距 12
/// - 按钮：高 40，padding 水平 20，圆角 8（复用 AppButton）
///
/// 用法：
/// ```swift
/// let result = ResultPageView()
/// result.type = .success
/// result.title = "提交成功"
/// result.description = "您的申请已提交"
/// result.actions = [
///     ResultAction(text: "返回首页", style: .primary) { /* ... */ }
/// ]
/// ```

import UIKit
import SnapKit

// MARK: - 数据模型

/// 结果类型（与 api.json ResultType 对齐）。
public enum ResultType {
    case success
    case error
    case warning
    case info
}

/// 操作按钮样式（与 api.json ResultActionStyle 对齐）。
public enum ResultActionStyle {
    case primary   // 主按钮（主色填充+白字）
    case ghost     // 次按钮（白底+主色描边+主色字）
    case text      // 文本按钮（无背景，纯文字链接）
}

/// 操作按钮数据模型（与 api.json ResultAction 对齐）。
public struct ResultAction {
    public let text: String
    public let style: ResultActionStyle
    public let onClick: () -> Void

    public init(text: String, style: ResultActionStyle = .primary, onClick: @escaping () -> Void) {
        self.text = text
        self.style = style
        self.onClick = onClick
    }
}

// MARK: - 组件

/// 结果反馈组件。
public final class ResultPageView: UIView {

    // MARK: - Props

    public var type: ResultType = .success { didSet { updateIcon() } }
    public var title: String = "" { didSet { titleLabel.text = title } }
    public var description: String? { didSet { updateDescription() } }
    public var actions: [ResultAction] = [] { didSet { rebuildButtons() } }
    public var icon: UIView? { didSet { updateIcon() } }

    // MARK: - 子视图

    private let iconContainerView = UIView()
    private let iconView = ResultIconView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let buttonStack = UIStackView()

    // MARK: - 常量

    private enum Layout {
        static let iconSize: CGFloat = 56
        static let iconMarginTop: CGFloat = 0  // 容器顶部对齐
        static let titleMarginTop: CGFloat = 12
        static let descMarginTop: CGFloat = 4
        static let buttonMarginTop: CGFloat = 24
        static let buttonHeight: CGFloat = 40
        static let buttonSpacing: CGFloat = 12  // AppSpace.md
        static let buttonPaddingX: CGFloat = 20
    }

    // MARK: - Init

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    // MARK: - Setup

    private func setupViews() {
        backgroundColor = AppColor.bgPage

        // 图标容器（圆形浅色底）
        iconContainerView.backgroundColor = .clear
        iconContainerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(iconContainerView)
        iconContainerView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
            make.size.equalTo(Layout.iconSize)
        }

        // 图标（自绘四态）
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconContainerView.addSubview(iconView)
        iconView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // 标题
        titleLabel.font = .systemFont(ofSize: AppFont.sizeLg, weight: .semibold)
        titleLabel.textColor = AppColor.textPrimary
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(iconContainerView.snp.bottom).offset(Layout.titleMarginTop)
            make.leading.greaterThanOrEqualToSuperview().offset(AppSpace.xl)
            make.trailing.lessThanOrEqualToSuperview().offset(-AppSpace.xl)
        }

        // 描述
        descriptionLabel.font = .systemFont(ofSize: AppFont.sizeSm)
        descriptionLabel.textColor = AppColor.textSecondary
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(Layout.descMarginTop)
            make.leading.greaterThanOrEqualToSuperview().offset(AppSpace.xl)
            make.trailing.lessThanOrEqualToSuperview().offset(-AppSpace.xl)
        }

        // 按钮组
        buttonStack.axis = .horizontal
        buttonStack.alignment = .center
        buttonStack.distribution = .equalSpacing
        buttonStack.spacing = Layout.buttonSpacing
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(buttonStack)
        buttonStack.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(descriptionLabel.snp.bottom).offset(Layout.buttonMarginTop)
            make.leading.greaterThanOrEqualToSuperview().offset(AppSpace.lg)
            make.trailing.lessThanOrEqualToSuperview().offset(-AppSpace.lg)
            make.bottom.equalToSuperview()
        }

        updateIcon()
    }

    // MARK: - 更新

    private func updateIcon() {
        // 先移除自定义 icon
        iconView.isHidden = (icon != nil)
        icon?.removeFromSuperview()
        if let customIcon = icon {
            customIcon.translatesAutoresizingMaskIntoConstraints = false
            iconContainerView.addSubview(customIcon)
            customIcon.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        } else {
            iconView.type = type
        }
    }

    private func updateDescription() {
        descriptionLabel.text = description
        descriptionLabel.isHidden = (description == nil)
    }

    private func rebuildButtons() {
        buttonStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for action in actions {
            let button = makeButton(action: action)
            buttonStack.addArrangedSubview(button)
        }
    }

    private func makeButton(action: ResultAction) -> UIView {
        switch action.style {
        case .primary:
            let btn = AppButton.primary(action.text)
            btn.frame.size.height = Layout.buttonHeight
            btn.layer.cornerRadius = AppRadius.sm
            btn.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            btn.tag = actions.firstIndex(where: { $0.text == action.text }) ?? 0
            return btn
        case .ghost:
            let btn = AppButton.secondary(action.text)
            btn.frame.size.height = Layout.buttonHeight
            btn.layer.cornerRadius = AppRadius.sm
            btn.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            btn.tag = actions.firstIndex(where: { $0.text == action.text }) ?? 0
            return btn
        case .text:
            let btn = UIButton(type: .system)
            btn.setTitle(action.text, for: .normal)
            btn.setTitleColor(AppColor.primary, for: .normal)
            btn.titleLabel?.font = .systemFont(ofSize: AppFont.sizeSm)
            btn.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            btn.tag = actions.firstIndex(where: { $0.text == action.text }) ?? 0
            return btn
        }
    }

    @objc private func buttonTapped(_ sender: UIControl) {
        guard sender.tag < actions.count else { return }
        actions[sender.tag].onClick()
    }
}

// MARK: - 四态图标自绘

/// 四态图标视图（success 对勾 / error 叉 / warning 感叹号 / info 字母 i）。
final class ResultIconView: UIView {

    var type: ResultType = .success { didSet { setNeedsDisplay() } }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isUserInteractionEnabled = false
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
        isUserInteractionEnabled = false
    }

    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        let size = rect.width
        let center = CGPoint(x: rect.midX, y: rect.midY)

        // 1. 圆形浅色底（type 对应色 alpha 0.1）
        let bgColor: UIColor
        let strokeColor: UIColor
        switch type {
        case .success:
            bgColor = AppColor.success.withAlphaComponent(0.1)
            strokeColor = AppColor.success
        case .error:
            bgColor = AppColor.error.withAlphaComponent(0.1)
            strokeColor = AppColor.error
        case .warning:
            bgColor = AppColor.warning.withAlphaComponent(0.1)
            strokeColor = AppColor.warning
        case .info:
            bgColor = UIColor(hex: 0x3B82F6).withAlphaComponent(0.1)
            strokeColor = UIColor(hex: 0x3B82F6)
        }
        ctx.setFillColor(bgColor.cgColor)
        ctx.fillEllipse(in: rect)

        // 2. 图标（对勾/叉/感叹号/i）自绘
        ctx.setStrokeColor(strokeColor.cgColor)
        ctx.setLineWidth(size / 14)  // 描边粗细按尺寸比例
        ctx.setLineCap(.round)
        ctx.setLineJoin(.round)

        let scale: CGFloat = 0.5  // 图标占圆形直径 50%
        let iconRect = rect.insetBy(dx: size * (1 - scale) / 2, dy: size * (1 - scale) / 2)
        let w = iconRect.width
        let h = iconRect.height

        switch type {
        case .success:
            // 对勾 ✓（两段贝塞尔）
            let p1 = CGPoint(x: iconRect.minX + w * 0.15, y: iconRect.minY + h * 0.55)
            let p2 = CGPoint(x: iconRect.minX + w * 0.42, y: iconRect.minY + h * 0.78)
            let p3 = CGPoint(x: iconRect.minX + w * 0.85, y: iconRect.minY + h * 0.25)
            ctx.move(to: p1)
            ctx.addLine(to: p2)
            ctx.addLine(to: p3)
            ctx.strokePath()

        case .error:
            // 叉 ✕（两条对角线）
            let inset: CGFloat = w * 0.15
            ctx.move(to: CGPoint(x: iconRect.minX + inset, y: iconRect.minY + inset))
            ctx.addLine(to: CGPoint(x: iconRect.maxX - inset, y: iconRect.maxY - inset))
            ctx.move(to: CGPoint(x: iconRect.maxX - inset, y: iconRect.minY + inset))
            ctx.addLine(to: CGPoint(x: iconRect.minX + inset, y: iconRect.maxY - inset))
            ctx.strokePath()

        case .warning:
            // 感叹号 !（竖线+底部圆点）
            let cx = iconRect.midX
            let topY = iconRect.minY + h * 0.15
            let midY = iconRect.midY - h * 0.05
            ctx.move(to: CGPoint(x: cx, y: topY))
            ctx.addLine(to: CGPoint(x: cx, y: midY))
            ctx.strokePath()
            // 底部圆点
            let dotRect = CGRect(x: cx - size / 28, y: iconRect.midY + h * 0.15, width: size / 14, height: size / 14)
            ctx.setFillColor(strokeColor.cgColor)
            ctx.fillEllipse(in: dotRect)

        case .info:
            // 字母 i（点+竖线）
            let cx = iconRect.midX
            // 顶部圆点
            let dotRect = CGRect(x: cx - size / 28, y: iconRect.minY + h * 0.1, width: size / 14, height: size / 14)
            ctx.setFillColor(strokeColor.cgColor)
            ctx.fillEllipse(in: dotRect)
            // 竖线
            ctx.move(to: CGPoint(x: cx, y: iconRect.minY + h * 0.35))
            ctx.addLine(to: CGPoint(x: cx, y: iconRect.maxY - h * 0.1))
            ctx.strokePath()
        }
    }
}
