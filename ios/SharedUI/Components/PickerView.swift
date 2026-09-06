import UIKit

/// Picker 选项数据模型（ui.picker，任务清单 #33）
/// value=稳定选中值、text=滚轮行文案、disabled=禁停靠灰显行（滚掠不可停靠，自动吸附最近可用行）。
public struct PickerOption: Equatable {
    public let value: String
    public let text: String
    public let disabled: Bool

    public init(value: String, text: String, disabled: Bool = false) {
        self.value = value
        self.text = text
        self.disabled = disabled
    }
}

/// PickerView 单列滚轮选择器内容块（iOS 收编近似 OptionPickerSheetViewController 组件化升级，
/// 底层 UIPickerView rowHeight=44，原生渐隐/阻尼=平台差异表内放行）。
///
/// 组件=「工具栏（高 44：取消/标题/确定）+ 单列滚轮可视区（高 220=5 行×44）」内容块：
/// 无遮罩无自绘浮层，宿主自行承载（页面卡片内嵌 / 系统 sheet 弹层承载，参见 Demo D4）。
/// - 受控 `value`：初始滚停与外部回滚定位（外部 set 触发滚轮 animate 定位，不触发 onChange）；
/// - 点「确定」= onChange(选中行 value) 提交；点「取消」= 丢弃临时滚动态、滚回 value 行，
///   并回调可选 onCancel（宿主据此自理关闭动作）；组件本身无遮罩不处理弹层关闭。
/// - 选项级 disabled：行文案灰 40%，滚掠不可停靠（didSelectRow 时自动吸附最近可用行）；
/// - 组件级 disabled：整体 40% 灰 + 滚轮/工具栏不可交互。
///
/// 规格：docs/数据与产物/design-spec/picker-design-spec.html（门禁 A P1–P4 全 A，2026-09-06）。
/// 基线：组件库 v1.4.0（2026-09-06，未过 C2/D 不升版）。
public final class PickerView: UIView, UIPickerViewDataSource, UIPickerViewDelegate {

    public enum Metrics {
        /// 工具栏高 44pt（取消=sizeSm14 次色 / 标题=sizeMd16 Semibold / 确定=sizeMd16 primary）
        public static let barHeight: CGFloat = 44
        /// 滚轮可视区高 220pt=5 行×44
        public static let wheelHeight: CGFloat = 220
        /// 滚轮行高 44pt；选中行=primary Semibold16，其余=textPrimary Regular16，禁用=textPrimary 40%
        public static let rowHeight: CGFloat = 44
    }

    public private(set) var picker = UIPickerView()
    private let cancelButton = UIButton(type: .system)
    private let confirmButton = UIButton(type: .system)
    private let titleLabel = UILabel()
    private let separator = UIView()

    private var optionsStorage: [PickerOption] = []

    /// 选项池（value/text/disabled）
    public var options: [PickerOption] {
        get { optionsStorage }
        set { optionsStorage = newValue; reloadAndSyncSelection() }
    }

    private var valueStorage = ""
    /// 受控选中值：外部赋值即滚轮 animate 定位（不触发 onChange）
    public var value: String {
        get { valueStorage }
        set {
            guard newValue != valueStorage else { return }
            valueStorage = newValue
            syncSelectionToValue(animated: true)
        }
    }

    /// 确定提交回调
    public var onChange: ((String) -> Void)?
    /// 取消可选回调：内部先滚回 value 行，宿主据其自理关闭动作
    public var onCancel: (() -> Void)?

    private var disabledStorage = false
    /// 组件级禁用：整体 40% 灰 + 不可交互
    public var disabled: Bool {
        get { disabledStorage }
        set { disabledStorage = newValue; applyDisabledState() }
    }

    public var title: String { didSet { titleLabel.text = title } }
    public var cancelText: String { didSet { cancelButton.setTitle(cancelText, for: .normal) } }
    public var confirmText: String { didSet { confirmButton.setTitle(confirmText, for: .normal) } }

    private var stack: UIStackView!

    public init(
        options: [PickerOption],
        value: String,
        disabled: Bool = false,
        title: String = "请选择",
        cancelText: String = "取消",
        confirmText: String = "确定",
        onChange: ((String) -> Void)? = nil,
        onCancel: (() -> Void)? = nil
    ) {
        self.title = title
        self.cancelText = cancelText
        self.confirmText = confirmText
        super.init(frame: .zero)
        optionsStorage = options
        valueStorage = value
        self.disabled = disabled
        self.onChange = onChange
        self.onCancel = onCancel
        buildUI()
        applyDisabledState()
        syncSelectionToValue(animated: false)
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) { fatalError("init(coder:) 未支持") }

    public override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric,
               height: Metrics.barHeight + Metrics.wheelHeight)
    }

    private func buildUI() {
        backgroundColor = AppColor.bgCard

        // ---- 工具栏（高 44，取消/标题/确定，下 hairline 分隔）----
        cancelButton.titleLabel?.font = .systemFont(ofSize: AppFont.sizeSm)
        cancelButton.setTitleColor(AppColor.textSecondary, for: .normal)
        cancelButton.setTitle(cancelText, for: .normal)
        cancelButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)

        confirmButton.titleLabel?.font = .systemFont(ofSize: AppFont.sizeMd)
        confirmButton.setTitleColor(AppColor.primary, for: .normal)
        confirmButton.setTitle(confirmText, for: .normal)
        confirmButton.titleLabel?.font = .systemFont(ofSize: AppFont.sizeMd, weight: .semibold)
        confirmButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        confirmButton.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)

        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: AppFont.sizeMd, weight: .semibold)
        titleLabel.textColor = AppColor.textPrimary
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 1
        titleLabel.lineBreakMode = .byTruncatingTail

        let bar = UIView()
        bar.backgroundColor = AppColor.bgCard
        addSubview(bar)
        bar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bar.topAnchor.constraint(equalTo: topAnchor),
            bar.leadingAnchor.constraint(equalTo: leadingAnchor),
            bar.trailingAnchor.constraint(equalTo: trailingAnchor),
            bar.heightAnchor.constraint(equalToConstant: Metrics.barHeight)
        ])

        bar.addSubview(cancelButton)
        bar.addSubview(confirmButton)
        bar.addSubview(titleLabel)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cancelButton.leadingAnchor.constraint(equalTo: bar.leadingAnchor),
            cancelButton.centerYAnchor.constraint(equalTo: bar.centerYAnchor),
            cancelButton.heightAnchor.constraint(equalTo: bar.heightAnchor),

            confirmButton.trailingAnchor.constraint(equalTo: bar.trailingAnchor),
            confirmButton.centerYAnchor.constraint(equalTo: bar.centerYAnchor),
            confirmButton.heightAnchor.constraint(equalTo: bar.heightAnchor),

            titleLabel.centerXAnchor.constraint(equalTo: bar.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: bar.centerYAnchor),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: cancelButton.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: confirmButton.leadingAnchor, constant: -8)
        ])

        separator.backgroundColor = AppColor.border
        addSubview(separator)
        separator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            separator.topAnchor.constraint(equalTo: bar.bottomAnchor),
            separator.leadingAnchor.constraint(equalTo: leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1.0 / UIScreen.main.scale)
        ])

        // ---- 滚轮（单列 rowHeight=44，可视 220=5 行）----
        picker.dataSource = self
        picker.delegate = self
        picker.backgroundColor = .clear
        addSubview(picker)
        picker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            picker.topAnchor.constraint(equalTo: separator.bottomAnchor),
            picker.leadingAnchor.constraint(equalTo: leadingAnchor),
            picker.trailingAnchor.constraint(equalTo: trailingAnchor),
            picker.heightAnchor.constraint(equalToConstant: Metrics.wheelHeight),
            picker.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    // MARK: - 数据源 & 代理

    public func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }

    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        optionsStorage.count
    }

    public func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        Metrics.rowHeight
    }

    public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int,
                           forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = (view as? UILabel) ?? makeRowLabel()
        guard row < optionsStorage.count else { return label }
        let opt = optionsStorage[row]
        let selected = (row == pickerView.selectedRow(inComponent: 0))
        label.text = opt.text
        if opt.disabled {
            label.textColor = AppColor.textPrimary.withAlphaComponent(0.4)
            label.font = .systemFont(ofSize: AppFont.sizeMd)
        } else if selected {
            label.textColor = AppColor.primary
            label.font = .systemFont(ofSize: AppFont.sizeMd, weight: .semibold)
        } else {
            label.textColor = AppColor.textPrimary
            label.font = .systemFont(ofSize: AppFont.sizeMd)
        }
        return label
    }

    private func makeRowLabel() -> UILabel {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }

    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard row < optionsStorage.count else { return }
        // 禁用行掠行校正：滚到禁用行立即吸附最近可用行（不可停靠）
        if optionsStorage[row].disabled {
            if let target = nearestEnabledIndex(to: row), target != row {
                pickerView.selectRow(target, inComponent: 0, animated: true)
            }
            return
        }
        // 重绘行样式：选中行 primary 加粗、其余 textPrimary
        pickerView.reloadComponent(0)
    }

    private func nearestEnabledIndex(to row: Int) -> Int? {
        var i = row
        while i >= 0 {
            if !optionsStorage[i].disabled { return i }
            i -= 1
        }
        i = row + 1
        while i < optionsStorage.count {
            if !optionsStorage[i].disabled { return i }
            i += 1
        }
        return nil
    }

    // MARK: - 动作

    @objc private func confirmTapped() {
        guard !disabledStorage else { return }
        let row = picker.selectedRow(inComponent: 0)
        guard row >= 0, row < optionsStorage.count, !optionsStorage[row].disabled else { return }
        onChange?(optionsStorage[row].value)
    }

    @objc private func cancelTapped() {
        guard !disabledStorage else { return }
        // 丢弃临时滚动态，滚回受控 value 行
        syncSelectionToValue(animated: true)
        onCancel?()
    }

    // MARK: - 受控 value 定位

    private func reloadAndSyncSelection() {
        picker.reloadAllComponents()
        if !valueStorage.isEmpty {
            syncSelectionToValue(animated: false)
        }
    }

    private func syncSelectionToValue(animated: Bool) {
        guard !optionsStorage.isEmpty else { return }
        var row = optionsStorage.firstIndex { $0.value == valueStorage }
        if row == nil {
            row = optionsStorage.firstIndex { !$0.disabled }
        }
        guard let target = row, target < picker.numberOfRows(inComponent: 0) else { return }
        if picker.selectedRow(inComponent: 0) != target {
            picker.selectRow(target, inComponent: 0, animated: animated)
        }
        picker.reloadComponent(0)
    }

    private func applyDisabledState() {
        alpha = disabledStorage ? 0.4 : 1.0
        picker.isUserInteractionEnabled = !disabledStorage
        cancelButton.isEnabled = !disabledStorage
        confirmButton.isEnabled = !disabledStorage
        cancelButton.alpha = disabledStorage ? 0.4 : 1.0
        confirmButton.alpha = disabledStorage ? 0.4 : 1.0
    }
}
