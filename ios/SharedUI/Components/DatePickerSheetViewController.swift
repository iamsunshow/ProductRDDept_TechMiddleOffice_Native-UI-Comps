/// 统一日期选择弹层：支持 date（年/月/日）/ month（年/月）/ year（年）三种模式。
/// 视觉对齐 Picker #33：工具栏 44pt（取消 sizeSm 次色 / 标题 sizeMd Semibold / 确定 primary sizeMd Semibold）
/// + 滚轮 220pt=5 行×44（选中行 primary Semibold，其余 textPrimary，上下 hairline 夹线）。

import UIKit
import SnapKit

/// 日期选择模式。
public enum DatePickerMode {
    case date   /// 年/月/日
    case month  /// 年/月
    case year   /// 年
}

/// 统一日期选择弹层。
///
/// 确认后通过 `onConfirm` 回传 `Date`：
/// - `.date`：选中日期（含年月日）
/// - `.month`：该月 1 号 0 点
/// - `.year`：该年 1 月 1 号 0 点
public final class DatePickerSheetViewController: UIViewController {
    public var onConfirm: ((Date) -> Void)?

    private let mode: DatePickerMode
    private let initialDate: Date
    private let maximumDate: Date?

    private let pickerView = UIPickerView()
    private let cancelButton = UIButton(type: .system)
    private let confirmButton = UIButton(type: .system)
    private let titleLabel = UILabel()
    private let separator = UIView()

    private let years: [Int]
    private var selectedYear: Int
    private var selectedMonth: Int = 1
    private var selectedDay: Int = 1

    /// 最大可选日期的年/月/日分量（maximumDate 为 nil 时各分量=Int.max 表示不限制）
    private let maxYear: Int
    private let maxMonth: Int
    private let maxDay: Int

    private let barHeight: CGFloat = 44
    private let wheelHeight: CGFloat = 220
    private let rowHeight: CGFloat = 44

    /// 创建日期选择器。
    ///
    /// - Parameters:
    ///   - mode: 选择模式（date/month/year）
    ///   - date: 初始日期
    ///   - maximumDate: 最大可选日期，默认今天（仅 date 模式生效）
    public init(mode: DatePickerMode = .date, date: Date, maximumDate: Date? = Date()) {
        self.mode = mode
        self.initialDate = date
        self.maximumDate = maximumDate
        let cal = Calendar.current
        let comp = cal.dateComponents([.year, .month, .day], from: date)
        let currentYear = cal.component(.year, from: Date())
        // 计算最大可选日期分量（仅 date 模式限制）
        if mode == .date, let max = maximumDate {
            let maxComp = cal.dateComponents([.year, .month, .day], from: max)
            self.maxYear = maxComp.year ?? Int.max
            self.maxMonth = maxComp.month ?? 12
            self.maxDay = maxComp.day ?? 31
        } else {
            self.maxYear = Int.max
            self.maxMonth = 12
            self.maxDay = 31
        }
        let yearUpper = min(currentYear + 1, maxYear)
        self.years = Array((currentYear - 10)...yearUpper)
        self.selectedYear = comp.year ?? currentYear
        self.selectedMonth = comp.month ?? 1
        self.selectedDay = comp.day ?? 1
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
        if let sheet = sheetPresentationController {
            let height = barHeight + wheelHeight
            sheet.detents = [.custom(identifier: .init("date")) { _ in height }]
            sheet.prefersGrabberVisible = false
            sheet.preferredCornerRadius = AppRadius.lg
        }
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) { nil }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColor.bgCard
        buildUI()
        syncSelection()
    }

    private func buildUI() {
        // ---- 工具栏（高 44：取消 sizeSm 次色 / 标题 sizeMd Semibold / 确定 primary sizeMd Semibold）----
        let title: String
        switch mode {
        case .date: title = "选择日期"
        case .month: title = "选择月份"
        case .year: title = "选择年份"
        }

        cancelButton.titleLabel?.font = .systemFont(ofSize: AppFont.sizeSm)
        cancelButton.setTitleColor(AppColor.textSecondary, for: .normal)
        cancelButton.setTitle("取消", for: .normal)
        cancelButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)

        confirmButton.titleLabel?.font = .systemFont(ofSize: AppFont.sizeMd, weight: .semibold)
        confirmButton.setTitleColor(AppColor.primary, for: .normal)
        confirmButton.setTitle("确定", for: .normal)
        confirmButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        confirmButton.addTarget(self, action: #selector(confirm), for: .touchUpInside)

        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: AppFont.sizeMd, weight: .semibold)
        titleLabel.textColor = AppColor.textPrimary
        titleLabel.textAlignment = .center

        let bar = UIView()
        bar.backgroundColor = AppColor.bgCard
        view.addSubview(bar)
        bar.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(barHeight)
        }

        bar.addSubview(cancelButton)
        bar.addSubview(confirmButton)
        bar.addSubview(titleLabel)
        cancelButton.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalToSuperview()
        }
        confirmButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.leading.greaterThanOrEqualTo(cancelButton.snp.trailing).offset(8)
            make.trailing.lessThanOrEqualTo(confirmButton.snp.leading).offset(-8)
        }

        separator.backgroundColor = AppColor.border
        view.addSubview(separator)
        separator.snp.makeConstraints { make in
            make.top.equalTo(bar.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(1.0 / UIScreen.main.scale)
        }

        // ---- 滚轮（UIPickerView，rowHeight=44，可视 220=5 行）----
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.backgroundColor = .clear
        view.addSubview(pickerView)
        pickerView.snp.makeConstraints { make in
            make.top.equalTo(separator.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    private func syncSelection() {
        if let idx = years.firstIndex(of: selectedYear) {
            pickerView.selectRow(idx, inComponent: 0, animated: false)
        }
        if mode != .year {
            pickerView.selectRow(selectedMonth - 1, inComponent: 1, animated: false)
        }
        if mode == .date {
            pickerView.selectRow(selectedDay - 1, inComponent: 2, animated: false)
        }
    }

    private func daysInMonth(year: Int, month: Int) -> Int {
        var comps = DateComponents()
        comps.year = year
        comps.month = month
        let cal = Calendar.current
        guard let date = cal.date(from: comps),
              let range = cal.range(of: .day, in: .month, for: date) else { return 31 }
        return range.count
    }

    @objc private func cancel() { dismiss(animated: true) }

    @objc private func confirm() {
        let cal = Calendar.current
        var comps = DateComponents()
        comps.year = selectedYear
        comps.month = (mode == .year) ? 1 : selectedMonth
        comps.day = (mode == .date) ? selectedDay : 1
        let date = cal.date(from: comps) ?? initialDate
        onConfirm?(date)
        dismiss(animated: true)
    }
}

// MARK: - UIPickerView DataSource & Delegate

extension DatePickerSheetViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        switch mode {
        case .date: return 3
        case .month: return 2
        case .year: return 1
        }
    }

    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0: return years.count
        case 1:
            // 到达最大年份时月份上限=maxMonth
            return (selectedYear == maxYear) ? min(12, maxMonth) : 12
        case 2:
            let dim = daysInMonth(year: selectedYear, month: selectedMonth)
            // 到达最大年月时日期上限=maxDay
            return (selectedYear == maxYear && selectedMonth == maxMonth) ? min(dim, maxDay) : dim
        default: return 0
        }
    }

    public func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        rowHeight
    }

    public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int,
                           forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = (view as? UILabel) ?? makeRowLabel()
        let text: String
        switch component {
        case 0: text = "\(years[row])年"
        case 1: text = "\(row + 1)月"
        case 2: text = "\(row + 1)日"
        default: text = ""
        }
        let selected = row == pickerView.selectedRow(inComponent: component)
        label.text = text
        label.textColor = selected ? AppColor.primary : AppColor.textPrimary
        label.font = selected
            ? .systemFont(ofSize: AppFont.sizeMd, weight: .semibold)
            : .systemFont(ofSize: AppFont.sizeMd)
        return label
    }

    private func makeRowLabel() -> UILabel {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }

    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0:
            selectedYear = years[row]
            // 切换年份后若月份/日期越界（超过最大日期或当月天数）则修正
            let monthLimit = (selectedYear == maxYear) ? min(12, maxMonth) : 12
            if selectedMonth > monthLimit { selectedMonth = monthLimit }
            let dim = daysInMonth(year: selectedYear, month: selectedMonth)
            let dayLimit = (selectedYear == maxYear && selectedMonth == maxMonth) ? min(dim, maxDay) : dim
            if selectedDay > dayLimit { selectedDay = dayLimit }
        case 1:
            selectedMonth = row + 1
            let dim = daysInMonth(year: selectedYear, month: selectedMonth)
            let dayLimit = (selectedYear == maxYear && selectedMonth == maxMonth) ? min(dim, maxDay) : dim
            if selectedDay > dayLimit { selectedDay = dayLimit }
        case 2:
            selectedDay = row + 1
        default: break
        }
        // 年/月变更时重载日列（天数可能变化）
        if component != 2, mode == .date {
            pickerView.reloadComponent(2)
            pickerView.selectRow(selectedDay - 1, inComponent: 2, animated: false)
        }
        // 年变更时重载月列（月份上限可能变化）
        if component == 0, mode != .year {
            pickerView.reloadComponent(1)
            pickerView.selectRow(selectedMonth - 1, inComponent: 1, animated: false)
        }
        // 重绘行样式：选中行 primary 加粗
        for c in 0..<numberOfComponents(in: pickerView) {
            pickerView.reloadComponent(c)
        }
    }
}
