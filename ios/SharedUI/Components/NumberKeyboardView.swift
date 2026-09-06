/// NumberKeyboardView 数字键盘（ui.number-keyboard，任务清单 #32）——内嵌式数字键盘面板（数据录入区，UIKit 版，对齐 Android NumberKeyboard）。
///
/// 4 行×4 列键格：1~9 三行 + 底行（首格=extraKey 文本，否则 showDot=true 显示「.」、showDot=false
/// 且无 extraKey=灰「·」空占位不可点；中格=0；末格=删除）+ 右列「确认」竖条整列主色。
/// 纯事件回调（键盘零状态、无内部值）：数字/小数/extraKey 文本=onInput(字符)，退格=onDelete()，
/// 点确认列=onConfirm()；值由宿主输入模型持有（对齐 Input 受控惯例）。禁用：confirmDisabled=仅确认列
/// buttonDisabled 灰不可点；disabled=整键盘 alpha 40% 不可点。一期无遮罩/浮层/乱序/连删（二期随 Popup）。
/// 与业务记账 AmountKeyboard（business.amount-keyboard，金额千分位/两位小数/确认金额）划界=本组件
/// 通用裸键格无金额语义。
///
/// 规格：docs/数据与产物/design-spec/number-keyboard-design-spec.html（门禁 A P1–P4 全 A）。
/// 基线：组件库 v1.4.0（2026-09-06，未过 C2/D 不升版）。
///
/// 设计锚点（Token 注释锚定）：整件高 208pt=52×4 行；键格缝隙=hairline(1/scale pt) 露 AppColor.border
/// 底色线；键底白 bgCard；数字/点/X 字号 22=sizeXl、删除 14=sizeSm 次色、确认列 Md=16 白字整列；
/// 空占位「·」textSecondary alpha 0.4；confirmDisabled=buttonDisabled 灰；disabled=整体 alpha 0.4 不可点。
/// 尺寸/坐标由 layoutSubviews 计算（宿主给宽度，intrinsicContentSize 高=208、宽无固有值）。
import UIKit

/// 数字键盘面板。
final class NumberKeyboardView: UIView {
    // MARK: - 对外属性
    /// 数字/小数/extraKey 文本上屏回调（必传）。
    private let onInput: (String) -> Void
    /// 退格回调。
    private let onDelete: (() -> Void)?
    /// 点确认列回调。
    private let onConfirm: (() -> Void)?
    /// 确认列文案。
    private let confirmText: String
    /// 是否显示小数点键（extraKey 非空时忽略，底行首格取 extraKey）。
    private let showDot: Bool
    /// 自定义底键文本（如身份证 "X"）；设置时替换底行首格。
    private let extraKey: String?

    /// 仅确认列禁用（buttonDisabled 灰不可点）。
    var confirmDisabled: Bool = false {
        didSet { refreshConfirm() }
    }
    /// 整键盘禁用（整体 alpha 0.4、全部不可点）。
    var disabled: Bool = false {
        didSet {
            isUserInteractionEnabled = !disabled
            alpha = disabled ? 0.4 : 1
        }
    }

    // MARK: - 布局指标
    private enum Metrics {
        /// 键间网格缝隙（1/scale pt，与 Android 0.5dp 表内放行的系统级差异）
        static var hairline: CGFloat { 1 / UIScreen.main.scale }
        static let rowCount: CGFloat = 4
        static let digitCols: CGFloat = 3
        static let totalCols: CGFloat = 4
        static let rowHeight: CGFloat = 52
        static let totalHeight: CGFloat = rowHeight * rowCount // 208
    }

    // MARK: - 子视图
    private var keyButtons: [UIButton] = []      // 数字/底行键（frame 布局随 bounds 重算）
    private let confirmButton = UIButton(type: .custom)

    // MARK: - 初始化
    init(
        onInput: @escaping (String) -> Void,
        onDelete: (() -> Void)? = nil,
        onConfirm: (() -> Void)? = nil,
        confirmText: String = "确认",
        showDot: Bool = true,
        extraKey: String? = nil
    ) {
        self.onInput = onInput
        self.onDelete = onDelete
        self.onConfirm = onConfirm
        self.confirmText = confirmText
        self.showDot = showDot
        self.extraKey = extraKey
        super.init(frame: .zero)
        backgroundColor = AppColor.border
        // 注意：本组件固定高 208pt（intrinsicContentSize），宿主在使用 AutoLayout 时
        // 必须同时约束 bottom 或 height，否则容器高度链不闭合，frame 子视图会溢出
        // 父 bounds，导致超出部分无法响应 touch（实测 pinFullWidth 只给 top/leading/trailing 时
        // 容器高度仅取到 field 56pt，键盘 208pt 溢出被截断）。
        buildKeys()
        buildConfirm()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: Metrics.totalHeight)
    }

    // MARK: - 构建
    private func makeKey(_ title: String, textColor: UIColor = AppColor.textPrimary,
                         fontSize: CGFloat = AppFont.sizeXl, enabled: Bool = true,
                         action: (() -> Void)? = nil) -> UIButton {
        let button = UIButton(type: .custom)
        button.backgroundColor = AppColor.bgCard
        button.setTitle(title, for: .normal)
        button.setTitleColor(textColor, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.6
        button.isEnabled = enabled
        if let action, enabled {
            button.addAction(UIAction { [weak self] _ in _ = self; action() }, for: .touchUpInside)
        }
        return button
    }

    private func buildKeys() {
        keyButtons = []
        // 行 1-3：数字 1~9
        for digit in 1...9 {
            let digitText = "\(digit)"
            keyButtons.append(
                makeKey(digitText) { [weak self] in
                    self?.onInput(digitText)
                }
            )
        }
        // 底行首格：extraKey / . / 空占位「·」不可点
        if let extraKey {
            keyButtons.append(makeKey(extraKey) { [weak self] in self?.onInput(extraKey) })
        } else if showDot {
            keyButtons.append(makeKey(".") { [weak self] in self?.onInput(".") })
        } else {
            keyButtons.append(makeKey("·", textColor: AppColor.textSecondary.withAlphaComponent(0.4), enabled: false))
        }
        // 底行中格：0
        keyButtons.append(makeKey("0") { [weak self] in self?.onInput("0") })
        // 底行末格：删除
        let deleteEnabled = onDelete != nil
        keyButtons.append(
            makeKey("删除",
                    textColor: AppColor.textSecondary,
                    fontSize: AppFont.sizeSm,
                    enabled: deleteEnabled,
                    action: { [weak self] in self?.onDelete?() })
        )
        keyButtons.forEach(addSubview)
    }

    private func buildConfirm() {
        confirmButton.backgroundColor = AppColor.primary
        confirmButton.setTitle(confirmText, for: .normal)
        confirmButton.setTitleColor(.white, for: .normal)
        confirmButton.titleLabel?.font = UIFont.systemFont(ofSize: AppFont.sizeMd)
        confirmButton.addAction(UIAction { [weak self] _ in self?.onConfirm?() }, for: .touchUpInside)
        addSubview(confirmButton)
        refreshConfirm()
    }

    private func refreshConfirm() {
        let active = !confirmDisabled && !disabled && onConfirm != nil
        confirmButton.backgroundColor = active ? AppColor.primary : AppColor.buttonDisabled
        confirmButton.isEnabled = active
    }

    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        let w = bounds.width
        let h = bounds.height
        guard w > 0, h > 0 else { return }
        let gap = Metrics.hairline
        let colWidth = (w - gap * (Metrics.totalCols - 1)) / Metrics.totalCols
        let rowHeight = (h - gap * (Metrics.rowCount - 1)) / Metrics.rowCount

        // 数字/底行键：3 列 × 4 行
        for index in 0..<keyButtons.count {
            let col = index % Int(Metrics.digitCols)
            let row = index / Int(Metrics.digitCols)
            let x = CGFloat(col) * (colWidth + gap)
            let y = CGFloat(row) * (rowHeight + gap)
            keyButtons[index].frame = CGRect(x: x, y: y, width: colWidth, height: rowHeight)
        }
        // 确认竖条：右列，跨 4 行整列
        let confirmX = Metrics.digitCols * (colWidth + gap)
        confirmButton.frame = CGRect(x: confirmX, y: 0, width: colWidth, height: h)
    }
}
