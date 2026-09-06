/// Checkbox 通用复选（数据录入区 · ui.checkbox · #25）双形态。
///
/// 组件 ID：`ui.checkbox`（api.json 契约对齐；门禁 A AI 代评通过 2026-09-06，规格
/// design-spec/checkbox-design-spec.html + 评审单 review-checkbox-A.md，P1–P4 全 A）。
///
/// 双形态：
/// - `CheckboxView`（单只）：label 可选；checked `Bool?` 半受控（nil=内部自持、外部赋值=同步
///   回显不触发 onChange）；disabled 整体禁点；整行点击回调 `onChange(Bool)`。
/// - `CheckboxGroupView`（组）：垂直多选（options 数据驱动、整行 40pt 命中、行距 4pt）；
///   selected `Set<String>?` 半受控（外部重新赋值=同步回显不触发 onChange）；组 disabled
///   整组灰 40%；选项级禁用以 `CheckboxOption.disabled`。点击回传 `onChange(value, checked)`。
///
/// 视觉锚点（与 Android Checkbox 同构）：勾选框 20pt 方形 radiusSm(6) 圆角；选中=primary 底 +
/// 白勾（自绘 path 与 Android Canvas 同坐标：箱内起点 (0.24,0.52)→(0.42,0.72)→(0.78,0.34)，
/// 线宽 2）；未选中=白底 + textSecondary(alpha 0.3) 1.5pt 描边；禁用已选=gray15 底白勾保留
/// 形态（不可点）；label Md16 后置间距 8（sm）、长文本单行省略；行纵向 padding 10（行高 40）；
/// 行距 4。与业务 AgreementCheckRow（foundation/design 圆形 12dp 富文本场景）划界不混入。
import UIKit

/// 复选选项数据。
struct CheckboxOption {
    let value: String
    let label: String
    let disabled: Bool

    init(value: String, label: String = "", disabled: Bool = false) {
        self.value = value
        self.label = label
        self.disabled = disabled
    }
}

// MARK: - 勾选框自绘（20pt 方形：底/描边/白勾）

/// 勾选框绘制视图：圆角方框 + 条件描边 + 选中白勾 path（双端 1:1 同坐标）。
final class CheckGlyphView: UIView {
    var isChecked = false {
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
        fatalError("CheckGlyphView 不支持 initWithCoder 解码。")
    }

    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext(), bounds.width > 0 else { return }
        let side = bounds.width
        let box = CGRect(x: 0, y: 0, width: side, height: side)
        let shape = UIBezierPath(roundedRect: box, cornerRadius: AppRadius.sm)

        // 底
        let bg: UIColor
        switch (isChecked, isDisabled) {
        case (true, true): bg = AppColor.gray15
        case (true, false): bg = AppColor.primary
        case (false, true): bg = AppColor.textSecondary.withAlphaComponent(0.06)
        case (false, false): bg = UIColor.white
        }
        ctx.saveGState()
        bg.setFill()
        shape.fill()

        // 描边：未选中=textSecondary 30%（禁用 40%）；选中且不禁用=无边框
        if !(isChecked && !isDisabled) {
            let stroke = isDisabled
                ? AppColor.textSecondary.withAlphaComponent(0.4)
                : AppColor.textSecondary.withAlphaComponent(0.3)
            stroke.setStroke()
            shape.lineWidth = 1.5
            shape.stroke()
        }

        // 白勾（20pt 箱坐标与 Android Canvas 相同比例；禁用保留灰勾形态 60% 白）
        if isChecked {
            let check = UIBezierPath()
            check.move(to: CGPoint(x: side * 0.24, y: side * 0.52))
            check.addLine(to: CGPoint(x: side * 0.42, y: side * 0.72))
            check.addLine(to: CGPoint(x: side * 0.78, y: side * 0.34))
            check.lineWidth = max(side * 0.09, 1)
            check.lineCapStyle = .round
            check.lineJoinStyle = .round
            UIColor.white.withAlphaComponent(isDisabled ? 0.6 : 1).setStroke()
            check.stroke()
        }
        ctx.restoreGState()
    }
}

// MARK: - 单只复选

/// 单只复选（label 空=仅勾选框；整行点击 40pt 高命中）。
final class CheckboxView: UIView {
    var onChange: ((Bool) -> Void)?

    /// 选中态；半受控：外部赋值=同步回显（不触发 onChange）。
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
    private let glyph = CheckGlyphView()
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
            labelView.font = .systemFont(ofSize: AppFont.sizeMd)
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
        fatalError("CheckboxView 不支持 initWithCoder 解码，请使用 init(label:checked:disabled:onChange:)。")
    }

    override var intrinsicContentSize: CGSize {
        let width: CGFloat
        if let label, !label.isEmpty {
            let textWidth = (label as NSString).size(
                withAttributes: [.font: UIFont.systemFont(ofSize: AppFont.sizeMd)]
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
        let next = !internalChecked
        internalChecked = next
        refreshGlyph()
        onChange?(next)
    }

    private func refreshGlyph() {
        glyph.isChecked = internalChecked
        glyph.isDisabled = disabled
        labelView.textColor = disabled
            ? AppColor.textSecondary.withAlphaComponent(0.6)
            : AppColor.textPrimary
    }

    private func refreshEnabled() {
        tapButton.isEnabled = !disabled
        alpha = disabled ? 0.4 : 1
    }
}

// MARK: - 复选组（垂直多选）

/// CheckboxGroup 垂直多选列表（options 数据驱动、整行命中）。
final class CheckboxGroupView: UIView {

    var onChange: ((String, Bool) -> Void)?

    /// 选中值集合；半受控：外部重新赋值=同步回显（不触发 onChange）。
    var selected: Set<String>? {
        didSet {
            if let selected, selected != internalSelected {
                internalSelected = selected
                refreshRows()
            }
        }
    }

    /// 整组禁用（灰 40%、行按钮全禁点）；选项级禁用走 CheckboxOption.disabled。
    var disabled: Bool {
        didSet { refreshEnabled(); refreshRows() }
    }

    private struct RowBox {
        let option: CheckboxOption
        let row: CheckboxRowView
    }

    private var rows: [RowBox] = []
    private var internalSelected: Set<String> = []
    private let stack = UIStackView()

    init(
        options: [CheckboxOption],
        selected: Set<String>? = nil,
        disabled: Bool = false,
        onChange: ((String, Bool) -> Void)? = nil
    ) {
        self.internalSelected = selected ?? []
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
            let row = CheckboxRowView(option: option)
            row.onToggle = { [weak self] in
                guard let self else { return }
                self.handleToggle(option.value)
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
        fatalError("CheckboxGroupView 不支持 initWithCoder 解码，请使用 init(options:selected:disabled:onChange:)。")
    }

    override var intrinsicContentSize: CGSize {
        let count = rows.count
        let height = count > 0 ? CGFloat(count) * 40 + CGFloat(count - 1) * 4 : 0
        return CGSize(width: UIView.noIntrinsicMetric, height: height)
    }

    private func handleToggle(_ value: String) {
        let checked = internalSelected.contains(value)
        if checked {
            internalSelected.remove(value)
        } else {
            internalSelected.insert(value)
        }
        refreshRows()
        onChange?(value, !checked)
    }

    private func refreshRows() {
        for box in rows {
            let rowDisabled = disabled || box.option.disabled
            box.row.setChecked(internalSelected.contains(box.option.value), disabled: rowDisabled)
        }
    }

    private func refreshEnabled() {
        alpha = disabled ? 0.4 : 1
    }
}

// MARK: - 组内单行（40pt 整行命中）

/// 组内复选行：glyph(0,10,20,20) + label(28,0,宽-28,40)，整行 UIButton 命中。
final class CheckboxRowView: UIView {
    var onToggle: (() -> Void)?

    private let glyph = CheckGlyphView()
    private let labelView = UILabel()
    private let tapButton = UIButton(type: .custom)
    private var rowDisabled = false

    init(option: CheckboxOption) {
        super.init(frame: .zero)
        backgroundColor = .clear

        glyph.frame = CGRect(x: 0, y: 10, width: 20, height: 20)
        addSubview(glyph)

        if !option.label.isEmpty {
            labelView.text = option.label
            labelView.font = .systemFont(ofSize: AppFont.sizeMd)
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
        fatalError("CheckboxRowView 不支持 initWithCoder 解码。")
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

    /// 由组刷新行态（checked + disabled）。
    func setChecked(_ checked: Bool, disabled: Bool) {
        rowDisabled = disabled
        glyph.isChecked = checked
        glyph.isDisabled = disabled
        labelView.textColor = disabled
            ? AppColor.textSecondary.withAlphaComponent(0.6)
            : AppColor.textPrimary
        tapButton.isEnabled = !disabled
    }

    @objc private func tapped() {
        guard !rowDisabled else { return }
        onToggle?()
    }
}
