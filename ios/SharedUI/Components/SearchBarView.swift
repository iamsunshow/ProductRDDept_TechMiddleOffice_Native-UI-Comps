import UIKit

/// SearchBar 搜索栏（ui.search-bar，#38）——数据录入区全新立项组件。
///
/// 定位：搜索输入壳=48pt 灰底 bgPage + radiusLg 圆角（对齐已收编 Input #29 壳 token，复用不复制），
/// 前置放大镜（自绘 glyph 14 灰）+ 文本输入 + 非空清除钮 + trailing 宿主尾槽；
/// 检索语义：软键盘「搜索」键/回车=onSearch(当前文本) 一次性回调（主触发），
/// 后置搜索按钮=trailing 宿主槽自放（与键盘搜索键双路径，动作联动宿主自理）。
/// 真实检索执行/结果/历史/联想=宿主自理（组件零内部异步态）。
///
/// 半受控：`value: String?`=nil 内部自持输入（宿主拿 onTextChange 实时拿词即可，无需回写）；
/// 外部赋值（value = "xx"）=仅同步回显（不触发 onTextChange）；disabled=整行 40% 灰不可输入、
/// 清除钮隐藏、无任何回调；maxLength 仅截断键盘输入路径；placeholder 默认「请输入搜索关键词」。
///
/// 视觉锚点：壳 48pt 高 bgPage + radiusLg 圆角、无边框；行内水平 padding 16；放大镜 14 灰；
/// 文本 Md16 textPrimary；placeholder textSecondary Md16；清除钮 20pt 圆 gray15 底白叉（非空显示，
/// 复用 InputView.swift 的 XGlyphView=同 Android Canvas 双端 1:1）；输入光标 primary。
/// 放大镜=本文件 MagGlyphView 自绘（圆+斜柄，与 Android SearchBar.kt Canvas 同坐标）。
///
/// 规格：docs/数据与产物/design-spec/search-bar-design-spec.html（门禁 A，P1–P4 全 A）。
/// 基线：组件库 v1.4.0（2026-09-06，未过 C2/D 不升版）。
final class SearchBarView: UIView, UITextFieldDelegate {
    /// 输入实时直通（含清除钮点击后清空回传 ""）；disabled 无回调。
    var onTextChange: ((String) -> Void)?

    /// 软键盘「搜索」键/回车触发一次（空串也回调、宿主自判忽略）；disabled 无回调。
    var onSearch: ((String) -> Void)?

    /// 半受控 value：nil=内部自持（输入无需外部回写）；外部赋值=仅同步回显（不触发 onTextChange）。
    var value: String? {
        didSet {
            guard let v = value, v != textField.text else { return }
            textField.text = v
            setNeedsLayout()
        }
    }

    /// 当前输入文本（只读）：供宿主 trailing 按钮等外部动作读取（与 Android demo 受控 state 语义一致）。
    var currentText: String { textField.text ?? "" }

    /// 禁用（灰 40% 不可编辑、清除钮隐藏）。
    var disabled: Bool {
        didSet { refreshDisabled() }
    }

    private let textField = UITextField()
    private let magView = MagGlyphView()
    private let clearButton = UIButton(type: .custom)
    private let clearGlyph = XGlyphView()
    private let trailingView: UIView?
    private let maxChars: Int?

    private enum Metrics {
        static let height: CGFloat = 48 // 壳高 48=对齐 Input #29/FormFieldRow min48（AppSpace 无行高档，注释锚定）
        static let horizontalPad: CGFloat = 16 // AppSpace.lg
        static let spacing: CGFloat = 8 // AppSpace.sm
        static let glyph: CGFloat = 14 // 放大镜 14
        static let clear: CGFloat = 20 // 清除钮 20
    }

    init(
        value: String? = nil,
        placeholder: String? = "请输入搜索关键词",
        maxLength: Int? = nil,
        disabled: Bool = false,
        trailing: UIView? = nil,
        onTextChange: ((String) -> Void)? = nil,
        onSearch: ((String) -> Void)? = nil
    ) {
        self.value = value
        self.maxChars = maxLength
        self.disabled = disabled
        self.trailingView = trailing
        self.onTextChange = onTextChange
        self.onSearch = onSearch
        super.init(frame: .zero)
        backgroundColor = AppColor.bgPage
        layer.cornerRadius = AppRadius.lg
        clipsToBounds = true

        magView.isUserInteractionEnabled = false
        addSubview(magView)

        textField.text = value ?? ""
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
        textField.returnKeyType = .search
        textField.clearButtonMode = .never
        textField.delegate = self
        textField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        addSubview(textField)

        clearGlyph.isUserInteractionEnabled = false
        clearButton.addSubview(clearGlyph)
        clearButton.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)
        addSubview(clearButton)

        if let trailingView {
            addSubview(trailingView)
        }
        refreshDisabled()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("SearchBarView 不支持 initWithCoder 解码。")
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: Metrics.height)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let h = bounds.height
        guard h > 0 else { return }
        let pad = Metrics.horizontalPad
        var rightEdge = bounds.width - pad

        // trailing 尾槽（宿主自放：搜索按钮/取消钮等=与键盘搜索键双路径）
        if let trailingView {
            let tSize = trailingView.intrinsicContentSize
            let tw = max(tSize.width, 1)
            let th = min(max(tSize.height, 1), h)
            trailingView.frame = CGRect(x: rightEdge - tw, y: (h - th) / 2, width: tw, height: th)
            rightEdge -= tw + Metrics.spacing
        }

        // 清除钮：非空且非禁用显示
        let showClear = !(textField.text?.isEmpty ?? true) && !disabled
        clearButton.isHidden = !showClear
        if showClear {
            let c = Metrics.clear
            clearButton.frame = CGRect(x: rightEdge - c, y: (h - c) / 2, width: c, height: c)
            clearGlyph.frame = clearButton.bounds
            rightEdge -= c + Metrics.spacing
        }

        // 前置放大镜 14 + 文本输入
        magView.frame = CGRect(x: pad, y: (h - Metrics.glyph) / 2, width: Metrics.glyph, height: Metrics.glyph)
        let leftEdge = pad + Metrics.glyph + Metrics.spacing
        textField.frame = CGRect(x: leftEdge, y: 0, width: max(rightEdge - leftEdge, 0), height: h)
    }

    // MARK: - 内部

    @objc private func textDidChange() {
        onTextChange?(textField.text ?? "")
        setNeedsLayout()
    }

    @objc private func clearTapped() {
        textField.text = ""
        textDidChange()
    }

    private func refreshDisabled() {
        alpha = disabled ? 0.4 : 1
        textField.isEnabled = !disabled
        setNeedsLayout()
    }

    // MARK: - UITextFieldDelegate

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let maxChars, let current = textField.text else { return true }
        let candidate = (current as NSString).replacingCharacters(in: range, with: string)
        guard candidate.count > maxChars else { return true }
        // 截断到 maxLength（含粘贴/联想输入）
        textField.text = String(candidate.prefix(maxChars))
        textDidChange()
        return false
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        onSearch?(textField.text ?? "")
        textField.resignFirstResponder()
        return true
    }
}

/// 前置放大镜自绘 glyph：圆（直径 14×0.52≈7.3）+ 斜柄（延伸 0.26）、描边 0.15×14、
/// textSecondary 灰（alpha 0.85）=与 Android SearchBar.kt Canvas 同坐标双端 1:1。
final class MagGlyphView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isOpaque = false
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("MagGlyphView 不支持 initWithCoder 解码。")
    }

    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext(), bounds.width > 0 else { return }
        let side = bounds.width
        ctx.saveGState()
        ctx.setStrokeColor(AppColor.textSecondary.withAlphaComponent(0.85).cgColor)
        ctx.setLineWidth(side * 0.15)
        ctx.setLineCap(.round)
        // 圆圈：圆心 (0.44,0.44) 半径 0.26×side
        ctx.addArc(center: CGPoint(x: side * 0.44, y: side * 0.44), radius: side * 0.26, startAngle: 0, endAngle: .pi * 2, clockwise: false)
        ctx.strokePath()
        // 斜柄：从 (0.64,0.64) 到 (0.90,0.90)
        ctx.move(to: CGPoint(x: side * 0.64, y: side * 0.64))
        ctx.addLine(to: CGPoint(x: side * 0.90, y: side * 0.90))
        ctx.strokePath()
        ctx.restoreGState()
    }
}
