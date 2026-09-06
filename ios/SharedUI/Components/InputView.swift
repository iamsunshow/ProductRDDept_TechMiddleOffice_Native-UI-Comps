/// InputView 通用单行文本输入（数据录入区 · ui.input · #29）。
///
/// 组件 ID：`ui.input`（api.json 契约对齐；门禁 A AI 代评通过 2026-09-06，规格
/// design-spec/input-design-spec.html + 评审单 review-input-A.md，P1–P4 全 A）。
///
/// 定位：**纯输入内容组件（无 label/必填星/校验=FormFieldRow 壳职责，本组件不变红）**——
/// 受控：宿主传 `value`，输入直通 `onTextChange` 回调原文；外部重新赋值 `value`=同步回显。
///
/// 契约（与 Android Input 同构）：
/// - `value: String`：当前文本（受控必传语义；外部赋值=回显）。
/// - `placeholder`：占位灰字（textSecondary Md16）。
/// - `keyboard`：text|number|phone|email 映射系统键盘（numberPad/phonePad/emailAddress）。
/// - `secure`：密码掩码（回调仍传原文；一期无显隐切换钮）。
/// - `maxLength`：仅输入路径截断（外部赋值不限）。
/// - `disabled`：整体 40% 置灰不可编辑，清除钮隐藏。
/// - 非空显示清除钮（20pt 圆 gray15 底白叉）；`trailing` 宿主尾槽自放。
///
/// 设计锚点：壳高 48pt bgPage + radiusLg 圆角、无边框；行内水平 padding 16；
/// 文本 Md16 textPrimary；placeholder textSecondary；清除钮 20pt circle gray15 白叉。
/// 键盘弹起/光标/安全区=宿主职责（UITextField 原生）。
///
/// 用法：
/// ```swift
/// let input = InputView(value: "", placeholder: "请输入昵称", keyboard: "text",
///                        onTextChange: { text in ... })
/// input.value = "外部回写"    // 同步回显
/// input.disabled = true       // 禁用
/// ```
import UIKit

/// 通用单行文本输入（受控）。
final class InputView: UIView, UITextFieldDelegate {

    enum Metrics {
        static let height: CGFloat = 48
        static let horizontalPad: CGFloat = 16
        static let clearLength: CGFloat = 20
        static let spacing: CGFloat = 8
        /// 清除钮白叉线宽（pt）。
        static let crossLineWidth: CGFloat = 1.7
    }

    /// 文本变更直通回调（含清空回调空串）。
    var onTextChange: ((String) -> Void)?

    /// 当前文本；外部赋值=同步回显（不额外触发回调）。
    var value: String {
        get { textField.text ?? "" }
        set {
            if newValue != textField.text {
                textField.text = newValue
                setNeedsLayout()
            }
        }
    }

    /// 禁用（灰 40% 不可编辑、清除钮隐藏）。
    var disabled: Bool {
        didSet { refreshDisabled() }
    }

    private let textField = UITextField()
    private let clearButton = UIButton(type: .custom)
    private let clearGlyph = XGlyphView()
    private let trailingView: UIView?
    private let maxChars: Int?

    init(
        value: String = "",
        placeholder: String? = nil,
        keyboard: String = "text",
        secure: Bool = false,
        maxLength: Int? = nil,
        disabled: Bool = false,
        trailing: UIView? = nil,
        onTextChange: ((String) -> Void)? = nil
    ) {
        self.trailingView = trailing
        self.maxChars = maxLength
        self.disabled = disabled
        self.onTextChange = onTextChange
        super.init(frame: .zero)
        backgroundColor = AppColor.bgPage
        layer.cornerRadius = AppRadius.lg
        clipsToBounds = true

        textField.text = value
        textField.font = .systemFont(ofSize: AppFont.sizeMd)
        textField.textColor = AppColor.textPrimary
        textField.borderStyle = .none
        textField.backgroundColor = .clear
        textField.attributedPlaceholder = placeholder.map {
            NSAttributedString(
                string: $0,
                attributes: [
                    .foregroundColor: AppColor.textSecondary,
                    .font: UIFont.systemFont(ofSize: AppFont.sizeMd),
                ]
            )
        }
        textField.isSecureTextEntry = secure
        switch keyboard {
        case "number": textField.keyboardType = .numberPad
        case "phone": textField.keyboardType = .phonePad
        case "email": textField.keyboardType = .emailAddress
        default: textField.keyboardType = .default
        }
        textField.delegate = self
        textField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        textField.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textField)

        clearGlyph.isUserInteractionEnabled = false
        clearGlyph.translatesAutoresizingMaskIntoConstraints = false
        clearButton.addSubview(clearGlyph)
        clearButton.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(clearButton)

        if let trailingView {
            trailingView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(trailingView)
        }
        setNeedsLayout()
        refreshDisabled()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("InputView 不支持 initWithCoder 解码，请使用 init(value:placeholder:keyboard:secure:maxLength:disabled:trailing:onTextChange:)。")
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: Metrics.height)
    }

    // MARK: - 布局

    override func layoutSubviews() {
        super.layoutSubviews()
        let height = bounds.height
        let trailingWidth: CGFloat = trailingView.flatMap { view in
            let w = view.bounds.width > 0 ? view.bounds.width : view.intrinsicContentSize.width
            return w > 0 ? w : 0
        } ?? 0

        var rightEdge = bounds.width - Metrics.horizontalPad
        if let trailing = trailingView, trailingWidth > 0 {
            let x = rightEdge - trailingWidth
            trailing.frame = CGRect(x: x, y: (height - trailingWidth) / 2, width: trailingWidth, height: min(height, trailingWidth))
            rightEdge = x - Metrics.spacing
        }

        let showClear = !value.isEmpty && !disabled
        clearButton.isHidden = !showClear
        if showClear {
            clearButton.frame = CGRect(
                x: rightEdge - Metrics.clearLength,
                y: (height - Metrics.clearLength) / 2,
                width: Metrics.clearLength,
                height: Metrics.clearLength
            )
            rightEdge -= Metrics.clearLength + Metrics.spacing
        }
        clearGlyph.frame = clearButton.bounds

        let left = Metrics.horizontalPad
        textField.frame = CGRect(x: left, y: 0, width: max(rightEdge - left, 0), height: height)
    }

    // MARK: - 交互

    @objc private func textDidChange() {
        setNeedsLayout()
        onTextChange?(value)
    }

    @objc private func clearTapped() {
        textField.text = ""
        setNeedsLayout()
        onTextChange?("")
    }

    private func refreshDisabled() {
        textField.isEnabled = !disabled
        alpha = disabled ? 0.4 : 1
        setNeedsLayout()
    }

    // MARK: - maxLength 截断（含 paste）

    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        guard let maxChars else { return true }
        let current = textField.text ?? ""
        let candidate = (current as NSString).replacingCharacters(in: range, with: string)
        guard candidate.count > maxChars else { return true }
        // 截断到 maxLength（含粘贴/联想输入）
        let prefix = String(candidate.prefix(maxChars))
        textField.text = prefix
        textDidChange()
        return false
    }
}

/// 清除钮自绘：20pt 圆（gray15 底）+ 白叉（双端 1:1，同 Android Canvas：线宽约 0.085×20pt）。
final class XGlyphView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isOpaque = false
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("XGlyphView 不支持 initWithCoder 解码。")
    }

    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext(), bounds.width > 0 else { return }
        let side = bounds.width
        let circle = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: side, height: side))
        AppColor.gray15.setFill()
        circle.fill()

        ctx.saveGState()
        ctx.setStrokeColor(UIColor.white.cgColor)
        ctx.setLineCap(.round)
        ctx.setLineWidth(side * 0.085)
        let inset = side * 0.2
        let outer = side - inset
        ctx.move(to: CGPoint(x: inset, y: inset))
        ctx.addLine(to: CGPoint(x: outer, y: outer))
        ctx.strokePath()
        ctx.move(to: CGPoint(x: outer, y: inset))
        ctx.addLine(to: CGPoint(x: inset, y: outer))
        ctx.strokePath()
        ctx.restoreGState()
    }
}
