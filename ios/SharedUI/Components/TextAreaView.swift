import UIKit

/// TextArea 文本域（数据录入 #42 ui.textarea，门禁 B，验证组件库 v1.4.0）。
/// 通用多行文本输入内容组件（受控 value）：
/// - 灰底圆角文本域壳（bgPage + radiusLg + 四向内边距 md 12）= 与 InputView #29 同壳语言（单行/多行两形态）；
/// - placeholder：textSecondary Md16 顶部左对齐（多行不垂直居中），由自绘叠层 UILabel 承载（UITextView 无原生 placeholder）；
/// - 文本：Md16 textPrimary，行高 24=库 token cellTitleLineHeight（注释锚定，NSMutableParagraphStyle 作用于 textStorage）；
/// - rows 可视行：整件高 = rows×24 + 上下内边距 12×2，默认 3 行 = 96 = 2×48 交互行基准（同 Signature 板高 96 注释锚定）；
/// - 内容超可视行：UITextView 原生内部滚动（scrollEnabled=true），光标随键入保持可视（系统行为）；
/// - maxLength：0/缺省=不限，仅输入路径截断（含粘贴超长只收前 N），外部赋值不强制截断；
/// - disabled：整壳 alpha0.4 不可编辑不可滚动不可点（含已填文本只读回显）。
/// - 受控：text 属性命令式外部赋值=同步回显（不触发 onTextChange）；用户编辑经 UITextViewDelegate 回调 onTextChange。
final class TextAreaView: UIView, UITextViewDelegate {
    /// 组件内行高与内边距常量（spec §02 注释锚定，库 token 同值）：
    /// rowHeight 24 = cellTitleLineHeight（AppTokens.cellTitleLineHeight=24pt）；
    /// pad 12 = AppSpace.md（壳内边距 md 四向，与 Input #29 一致）。
    private enum Metrics {
        static let rowHeight: CGFloat = 24
        static let pad: CGFloat = AppSpace.md
    }

    private static let textFont = UIFont.systemFont(ofSize: AppFont.sizeMd) // Md16

    /// 统一多行排版段落：min/max lineHeight=24（TextKit 行片段高 24、字形顶部对齐行片段起始）。
    private static let paragraph: NSParagraphStyle = {
        let p = NSMutableParagraphStyle()
        p.minimumLineHeight = Metrics.rowHeight
        p.maximumLineHeight = Metrics.rowHeight
        return p
    }()

    var onTextChange: ((String) -> Void)?

    /// disabled：整壳 40% 灰、不可编辑不可滚动不可点（运行期可更新=集中刷新）。
    var disabled: Bool {
        didSet { refreshDisabled() }
    }

    /// 受控文本：外部赋值=命令式同步回显（不触发 onTextChange）。
    var text: String {
        get { textView.text }
        set {
            guard newValue != textView.text else { return }
            textView.text = newValue
            textView.selectedRange = NSRange(location: (newValue as NSString).length, length: 0)
            applyTextStyleIfNeeded()
            refreshPlaceholder()
        }
    }

    private let rows: Int
    private let maxLength: Int?
    private let textView = UITextView()
    private var placeholderLabel: UILabel?

    init(
        value: String = "",
        placeholder: String? = nil,
        rows: Int = 3,
        maxLength: Int? = nil,
        disabled: Bool = false,
        onTextChange: ((String) -> Void)? = nil
    ) {
        self.rows = max(1, rows)
        self.maxLength = maxLength
        self.disabled = disabled
        super.init(frame: .zero)
        self.onTextChange = onTextChange

        backgroundColor = AppColor.bgPage
        layer.cornerRadius = AppRadius.lg
        clipsToBounds = true

        setupTextView()
        if let placeholder, !placeholder.isEmpty {
            setupPlaceholder(placeholder)
        }
        textView.text = value
        textView.selectedRange = NSRange(location: (value as NSString).length, length: 0)
        applyTextStyleIfNeeded()
        refreshPlaceholder()
        refreshDisabled()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        // 整件高 = rows×24 + 上下内边距 12×2（默认 3 行=96=2×48 交互行基准）
        CGSize(width: UIView.noIntrinsicMetric, height: CGFloat(rows) * Metrics.rowHeight + Metrics.pad * 2)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        textView.frame = bounds
        if let label = placeholderLabel {
            label.frame = CGRect(
                x: Metrics.pad,
                y: Metrics.pad,
                width: bounds.width - Metrics.pad * 2,
                height: bounds.height - Metrics.pad * 2
            )
        }
    }

    // MARK: - 组装

    private func setupTextView() {
        textView.delegate = self
        textView.backgroundColor = .clear
        textView.font = Self.textFont
        textView.textColor = AppColor.textPrimary
        // 文本起点内边距与 placeholder 同参（壳内边距 md 12）；lineFragmentPadding 清零避免文本再右偏
        textView.textContainerInset = UIEdgeInsets(
            top: Metrics.pad,
            left: Metrics.pad,
            bottom: Metrics.pad,
            right: Metrics.pad
        )
        textView.textContainer.lineFragmentPadding = 0
        // 内容超可视行内部滚动（原生）；未超限不产生滚动
        textView.isScrollEnabled = true
        textView.alwaysBounceVertical = false
        textView.keyboardDismissMode = .none
        // 预置输入排版：新键入段落行高 24
        textView.typingAttributes = [
            .font: Self.textFont,
            .foregroundColor: AppColor.textPrimary,
            .paragraphStyle: Self.paragraph
        ]
        addSubview(textView)
    }

    /// UITextView 无原生 placeholder：自绘叠层 UILabel（同 textContainer 起点 12/12、同字体行高，
    /// isUserInteractionEnabled=false=触摸穿透到底层 textView）。
    private func setupPlaceholder(_ p: String) {
        let label = UILabel()
        label.isUserInteractionEnabled = false
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.attributedText = NSAttributedString(
            string: p,
            attributes: [.font: Self.textFont, .foregroundColor: AppColor.textSecondary, .paragraphStyle: Self.paragraph]
        )
        addSubview(label)
        placeholderLabel = label
    }

    private func refreshPlaceholder() {
        placeholderLabel?.isHidden = !textView.text.isEmpty
    }

    private func refreshDisabled() {
        textView.isEditable = !disabled
        textView.isSelectable = !disabled
        alpha = disabled ? 0.4 : 1
    }

    /// 对 textStorage 全量应用 Md16 + textPrimary + 行高 24（begin/endEditing 不破坏当前光标）。
    private func applyTextStyleIfNeeded() {
        guard !textView.text.isEmpty else { return }
        textView.textStorage.beginEditing()
        textView.textStorage.addAttributes(
            [.font: Self.textFont, .foregroundColor: AppColor.textPrimary, .paragraphStyle: Self.paragraph],
            range: NSRange(location: 0, length: (textView.text as NSString).length)
        )
        textView.textStorage.endEditing()
    }

    // MARK: - UITextViewDelegate

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let maxLength else { return true }
        let candidate = (textView.text as NSString).replacingCharacters(in: range, with: text)
        if candidate.count <= maxLength { return true }
        // 输入/粘贴超限：仅保留前 N=命令式回写并手动走 didChange（与单次键入等价的宿主回调路径）
        let prefix = String(candidate.prefix(maxLength))
        self.text = prefix
        textViewDidChange(textView)
        return false
    }

    func textViewDidChange(_ textView: UITextView) {
        applyTextStyleIfNeeded()
        refreshPlaceholder()
        onTextChange?(textView.text)
    }
}
