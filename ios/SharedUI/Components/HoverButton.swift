/// HoverButton 悬浮按钮：页面角落常驻的"单功能悬浮动作钮"。
///
/// 与悬浮族划界：多入口列表面板 → FixedNav；滚动超阈值回顶 → BackTop；
/// 本组件 = 单钮常驻（无滚动阈值自动显隐）、图标字符 + 可选文本、点击交回 onTap。
/// 位置由宿主锚定（组件为纯内容视图：self 尺寸 = 钮内容，宿主只锚边/角即可撑开）。
import UIKit

final class HoverButton: UIView {
    /// 设计 token（与 docs/design-spec/hover-button-design-spec.html §02 对齐）。
    private enum Metrics {
        /// 悬浮钮高度基线（pt；icon-only 圆钮直径 = 胶囊高度 = 40）。
        static let size: CGFloat = 40
        /// 胶囊水平内边距 = AppSpace.lg（16pt）。
        static let pillInsetX: CGFloat = AppSpace.lg
        /// icon 与 text 间距 = AppSpace.sm（8pt）。
        static let iconGap: CGFloat = AppSpace.sm
        /// 默认图标字符（U+271A，零图片依赖）。
        static let defaultIcon = "✚"
        /// 按压压暗透明度（iOS 原生按压反馈，差异表放行）。
        static let pressedAlpha: CGFloat = 0.75
    }

    // MARK: - 对外

    let icon: String?
    let text: String?
    /// 点击回调（业务自理动作；nil = 仅形态预览）。
    var onTap: (() -> Void)?

    init(icon: String? = nil, text: String? = nil, onTap: (() -> Void)? = nil) {
        self.icon = icon
        self.text = text
        self.onTap = onTap
        super.init(frame: .zero)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 内部

    private let bgView = UIView()
    private let content = UIStackView()
    private let iconLabel = UILabel()
    private let textLabel = UILabel()
    private var tapButton: UIButton!
    private var hasText: Bool {
        !(text?.isEmpty ?? true)
    }

    private var effectiveIcon: String? {
        if let icon, !icon.isEmpty { return icon }
        return hasText ? nil : Metrics.defaultIcon
    }

    private func setup() {
        backgroundColor = .clear

        // 主色圆底（圆角按实际 bounds 动态=全库悬浮钮先例）。
        bgView.backgroundColor = AppColor.primary
        bgView.clipsToBounds = true
        bgView.isUserInteractionEnabled = false
        addSubview(bgView)

        // icon + text（仅存在时加入 content），spacing 8pt。
        content.axis = .horizontal
        content.alignment = .center
        content.spacing = Metrics.iconGap
        content.isUserInteractionEnabled = false
        if let effIcon = effectiveIcon {
            iconLabel.text = effIcon
            iconLabel.font = .systemFont(ofSize: AppFont.sizeLg, weight: .bold)
            iconLabel.textColor = .white
            iconLabel.textAlignment = .center
            content.addArrangedSubview(iconLabel)
        }
        if hasText, let text {
            textLabel.text = text
            textLabel.font = .systemFont(ofSize: AppFont.sizeSm)
            textLabel.textColor = .white
            textLabel.textAlignment = .center
            content.addArrangedSubview(textLabel)
        }
        bgView.addSubview(content)

        bgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        content.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.top.greaterThanOrEqualToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
            make.leading.greaterThanOrEqualToSuperview()
            make.trailing.lessThanOrEqualToSuperview()
        }

        // 点击承载（BackTop 同款：常驻不移除，只负责点击与按压反馈）。
        let button = UIButton(type: .custom)
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(pressDown), for: [.touchDown, .touchDragEnter])
        button.addTarget(self, action: #selector(pressRestore), for: [.touchDragExit, .touchCancel, .touchUpOutside])
        button.addTarget(self, action: #selector(didTap), for: .touchUpInside)
        addSubview(button)
        tapButton = button
        button.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // 圆角 = bounds 高一半（icon-only 圆钮 40×40 → 20；胶囊高 40 → 20，即 full）。
        bgView.layer.cornerRadius = bounds.height / 2
    }

    override var intrinsicContentSize: CGSize {
        let base: CGFloat = Metrics.size
        if !hasText {
            return CGSize(width: base, height: base)
        }
        // 胶囊宽 = 内容自然宽（icon + gap + text）+ 双侧 padding lg。
        var contentWidth: CGFloat = 0
        if effectiveIcon != nil { contentWidth += iconLabel.intrinsicContentSize.width }
        if hasText { contentWidth += textLabel.intrinsicContentSize.width }
        if effectiveIcon != nil, hasText { contentWidth += Metrics.iconGap }
        return CGSize(width: contentWidth + Metrics.pillInsetX * 2, height: base)
    }

    @objc private func pressDown() {
        UIView.animate(withDuration: 0.12) { [weak self] in
            self?.bgView.alpha = Metrics.pressedAlpha
        }
    }

    @objc private func pressRestore() {
        UIView.animate(withDuration: 0.12) { [weak self] in
            self?.bgView.alpha = 1
        }
    }

    @objc private func didTap() {
        UIView.animate(withDuration: 0.12) { [weak self] in
            self?.bgView.alpha = 1
        }
        onTap?()
    }
}
