/// Radio 通用排他单选（数据录入区 · ui.radio · #35）双形态。
///
/// 组件 ID：`ui.radio`（api.json 契约对齐；门禁 A AI 代评通过 2026-09-06，规格
/// design-spec/radio-design-spec.html + 评审单 review-radio-A.md，P1–P4 全 A）。
///
/// 双形态：
/// - `RadioView`（单只独立单选标记）：label 可选；checked `Bool?` 半受控（nil=内部自持初始未选、
///   外部赋值=同步回显不触发 onChange）；disabled 整体禁点；点选即置 true 并回调 `onChange(true)`，
///   已选中再点=幂等忽略（radio 语义无 toggle 取消）；取消只能外部驱动（checked=false）。
/// - `RadioGroupView`（组）：垂直排他单选列表（options 数据驱动一选一、整行 40pt 命中、行距 4pt）；
///   value `String?` 半受控（nil=内部自持初始未选=合法未选态，不自动回填首项；外部赋值=同步回显
///   不触发 onChange）；点击未选行=切中回调 `onChange(value)`；点击已选中行=幂等忽略；组 disabled
///   整组灰 40%；选项级禁用以 `RadioOption.disabled`；value 指向 disabled 项=灰点灰圈只读保留。
///
/// 视觉锚点（与 Android Radio 同构）：单选点 20pt 圆形白底；未选中=外圈描边 1.5pt
/// textSecondary(alpha 0.3)（同 Checkbox 未选描边惯例）；选中=外圈 primary 描边 + 中心实心点
/// 8pt primary；禁用=textSecondary(alpha 0.4) 描边、已选禁用=灰外圈灰点保留（gray15）；label Md16
/// 后置间距 8（sm）、选中行 label 加粗（semibold）、长文本单行省略；行纵向 padding 10（行高 40）；
/// 行距 4。与 #25 Checkbox（方形复选可多选可取消）划界=Radio 圆形排他点选即确定；与协议行/富文本
/// label 业务形态划界不混入。
import UIKit

/// 单选选项数据。
struct RadioOption {
    let value: String
    let label: String
    let disabled: Bool

    init(value: String, label: String = "", disabled: Bool = false) {
        self.value = value
        self.label = label
        self.disabled = disabled
    }
}

// MARK: - 单选点自绘（20pt 圆：描边 + 中心实心点）

/// 单选点绘制视图：白底圆 + 条件描边 + 选中中心实心点（双端 1:1）。
final class RadioGlyphView: UIView {
    var isSelected = false {
        didSet { setNeedsDisplay() }
    }

    var isDisabled = false {
        didSet { setNeedsDisplay() }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isOpaque = false
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("RadioGlyphView 不支持 initWithCoder 解码。")
    }

    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext(), bounds.width > 0 else { return }
        let side = bounds.width

        // 白底圆
        ctx.saveGState()
        UIColor.white.setFill()
        UIBezierPath(ovalIn: bounds).fill()

        // 外圈描边：未选=textSecondary 30%（禁用 40%）；选中=primary（禁用灰保留）
        let stroke: UIColor
        if isDisabled {
            stroke = AppColor.textSecondary.withAlphaComponent(0.4)
        } else if isSelected {
            stroke = AppColor.primary
        } else {
            stroke = AppColor.textSecondary.withAlphaComponent(0.3)
        }
        let outer = UIBezierPath(ovalIn: bounds.insetBy(dx: 0.75, dy: 0.75))
        outer.lineWidth = 1.5
        stroke.setStroke()
        outer.stroke()

        // 中心实心点 8pt（20pt 箱 40% 半径；禁用已选=灰点保留）
        if isSelected {
            let dot = UIBezierPath(
                ovalIn: CGRect(x: side / 2 - 4, y: side / 2 - 4, width: 8, height: 8)
            )
            (isDisabled ? AppColor.gray15 : AppColor.primary).setFill()
            dot.fill()
        }
        ctx.restoreGState()
    }
}

// MARK: - 单只单选

/// 单只单选（label 空=仅单选点；整行点击 40pt 高命中；点选置 true、已选再点幂等忽略）。
final class RadioView: UIView {
    var onChange: ((Bool) -> Void)?

    /// 选中态；半受控：外部赋值=同步回显（不触发 onChange）。取消选中只能外部 checked=false 驱动。
    var checked: Bool? {
        didSet {
            if let checked, checked != internalChecked {
                internalChecked = checked
                refreshGlyph()
            }
        }
    }

    var disabled: Bool {
        didSet {
            refreshEnabled()
            refreshGlyph()
        }
    }

    private let label: String?
    private var internalChecked: Bool
    private let glyph = RadioGlyphView()
    private let labelView = UILabel()
    private let tapButton = UIButton(type: .custom)

    init(
        label: String? = nil,
        checked: Bool? = nil,
        disabled: Bool = false,
        onChange: ((Bool) -> Void)? = nil
    ) {
        self.label = label
        self.internalChecked = checked ?? false
        self.disabled = disabled
        self.onChange = onChange
        super.init(frame: .zero)
        backgroundColor = .clear

        addSubview(glyph)
        if let label, !label.isEmpty {
            labelView.text = label
            labelView.font = Self.normalFont
            labelView.textColor = AppColor.textPrimary
            labelView.numberOfLines = 1
            labelView.lineBreakMode = .byTruncatingTail
            addSubview(labelView)
        }

        tapButton.addTarget(self, action: #selector(tapped), for: .touchUpInside)
        tapButton.backgroundColor = .clear
        addSubview(tapButton)

        refreshGlyph()
        refreshEnabled()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("RadioView 不支持 initWithCoder 解码，请使用 init(label:checked:disabled:onChange:)。")
    }

    override var intrinsicContentSize: CGSize {
        let width: CGFloat
        if let label, !label.isEmpty {
            let textWidth = (label as NSString).size(
                withAttributes: [.font: Self.normalFont]
            ).width
            width = 20 + AppSpace.sm + textWidth
        } else {
            width = 20
        }
        return CGSize(width: width, height: 40)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        tapButton.frame = bounds
        glyph.frame = CGRect(x: 0, y: (bounds.height - 20) / 2, width: 20, height: 20)
        labelView.frame = CGRect(x: 28, y: 0, width: max(bounds.width - 28, 0), height: bounds.height)
    }

    @objc private func tapped() {
        guard !disabled else { return }
        // 点选即确定；已选中再点=幂等忽略（radio 语义无 toggle 取消）
        guard !internalChecked else { return }
        internalChecked = true
        refreshGlyph()
        onChange?(true)
    }

    private func refreshGlyph() {
        glyph.isSelected = internalChecked
        glyph.isDisabled = disabled
        labelView.font = internalChecked && !disabled ? Self.semiboldFont : Self.normalFont
        labelView.textColor = disabled
            ? AppColor.textSecondary.withAlphaComponent(0.6)
            : AppColor.textPrimary
    }

    private func refreshEnabled() {
        tapButton.isEnabled = !disabled
        alpha = disabled ? 0.4 : 1
    }

    static var normalFont: UIFont {
        .systemFont(ofSize: AppFont.sizeMd)
    }

    static var semiboldFont: UIFont {
        .systemFont(ofSize: AppFont.sizeMd, weight: .semibold)
    }
}

// MARK: - 单选组（垂直排他）

/// RadioGroup 垂直排他单选列表（options 数据驱动、整行命中、value 半受控）。
final class RadioGroupView: UIView {

    var onChange: ((String) -> Void)?

    /// 当前选中值；半受控：外部赋值=同步回显（不触发 onChange）。nil=内部自持且初始未选（合法态）。
    var value: String? {
        didSet {
            if let value, value != internalValue {
                internalValue = value
                refreshRows()
            }
        }
    }

    /// 整组禁用（灰 40%、行按钮全禁点）；选项级禁用走 RadioOption.disabled。
    var disabled: Bool {
        didSet { refreshEnabled(); refreshRows() }
    }

    private struct RowBox {
        let option: RadioOption
        let row: RadioRowView
    }

    private var rows: [RowBox] = []
    private var internalValue: String?
    private let stack = UIStackView()

    init(
        options: [RadioOption],
        value: String? = nil,
        disabled: Bool = false,
        onChange: ((String) -> Void)? = nil
    ) {
        self.internalValue = value
        self.disabled = disabled
        self.onChange = onChange
        super.init(frame: .zero)
        backgroundColor = .clear

        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])

        for option in options {
            let row = RadioRowView(option: option)
            row.onSelect = { [weak self] in
                self?.handleSelect(option.value)
            }
            stack.addArrangedSubview(row)
            row.translatesAutoresizingMaskIntoConstraints = false
            row.heightAnchor.constraint(equalToConstant: 40).isActive = true
            rows.append(RowBox(option: option, row: row))
        }
        refreshEnabled()
        refreshRows()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("RadioGroupView 不支持 initWithCoder 解码，请使用 init(options:value:disabled:onChange:)。")
    }

    override var intrinsicContentSize: CGSize {
        let count = rows.count
        let height = count > 0 ? CGFloat(count) * 40 + CGFloat(count - 1) * 4 : 0
        return CGSize(width: UIView.noIntrinsicMetric, height: height)
    }

    /// 排他选择：点未选行=切中回调；点已选中行=幂等忽略。
    private func handleSelect(_ value: String) {
        guard internalValue != value else { return }
        internalValue = value
        refreshRows()
        onChange?(value)
    }

    private func refreshRows() {
        for box in rows {
            let rowDisabled = disabled || box.option.disabled
            box.row.setSelected(
                internalValue == box.option.value,
                disabled: rowDisabled
            )
        }
    }

    private func refreshEnabled() {
        alpha = disabled ? 0.4 : 1
    }
}

// MARK: - 组内单行（40pt 整行命中）

/// 组内单选行：glyph(0,10,20,20) + label(28,0,宽-28,40)，整行 UIButton 命中。
final class RadioRowView: UIView {
    var onSelect: (() -> Void)?

    private let glyph = RadioGlyphView()
    private let labelView = UILabel()
    private let tapButton = UIButton(type: .custom)
    private var rowDisabled = false

    init(option: RadioOption) {
        super.init(frame: .zero)
        backgroundColor = .clear

        glyph.frame = CGRect(x: 0, y: 10, width: 20, height: 20)
        addSubview(glyph)

        if !option.label.isEmpty {
            labelView.text = option.label
            labelView.font = RadioView.normalFont
            labelView.numberOfLines = 1
            labelView.lineBreakMode = .byTruncatingTail
            addSubview(labelView)
        }

        tapButton.backgroundColor = .clear
        tapButton.addTarget(self, action: #selector(tapped), for: .touchUpInside)
        addSubview(tapButton)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("RadioRowView 不支持 initWithCoder 解码。")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        tapButton.frame = bounds
        glyph.frame = CGRect(x: 0, y: 10, width: 20, height: 20)
        labelView.frame = CGRect(x: 28, y: 0, width: max(bounds.width - 28, 0), height: bounds.height)
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        bounds.contains(point)
    }

    /// 由组刷新行态（selected + disabled）。
    func setSelected(_ selected: Bool, disabled: Bool) {
        rowDisabled = disabled
        glyph.isSelected = selected
        glyph.isDisabled = disabled
        labelView.font = selected && !disabled ? RadioView.semiboldFont : RadioView.normalFont
        labelView.textColor = disabled
            ? AppColor.textSecondary.withAlphaComponent(0.4)
            : AppColor.textPrimary
        tapButton.isEnabled = !disabled
    }

    @objc private func tapped() {
        guard !rowDisabled else { return }
        onSelect?()
    }
}
