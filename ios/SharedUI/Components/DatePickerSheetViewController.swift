/// 统一日期选择弹层：支持 date（年/月/日）/ month（年/月）/ year（年）三种模式。

import UIKit
import SnapKit

/// 日期选择模式。
enum DatePickerMode {
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
final class DatePickerSheetViewController: UIViewController {
    var onConfirm: ((Date) -> Void)?

    private let mode: DatePickerMode
    private let initialDate: Date
    private let maximumDate: Date?

    private let datePicker = UIDatePicker()
    private let pickerView = UIPickerView()

    private let years: [Int]
    private var selectedYear: Int
    private var selectedMonth: Int = 1

    /// 创建日期选择器。
    ///
    /// - Parameters:
    ///   - mode: 选择模式（date/month/year）
    ///   - date: 初始日期
    ///   - maximumDate: 最大可选日期，默认今天
    init(mode: DatePickerMode = .date, date: Date, maximumDate: Date? = Date()) {
        self.mode = mode
        self.initialDate = date
        self.maximumDate = maximumDate
        let comp = CalendarFormatter.components(from: date)
        let currentYear = CalendarFormatter.components().year
        self.years = Array((currentYear - 10)...(currentYear + 1))
        self.selectedYear = comp.year
        let cal = Calendar.current
        self.selectedMonth = cal.component(.month, from: date)
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
        if let sheet = sheetPresentationController {
            let height: CGFloat = mode == .year ? 300 : 320
            sheet.detents = [.custom(identifier: .init("date")) { _ in height }]
            sheet.prefersGrabberVisible = false
            sheet.preferredCornerRadius = AppRadius.lg
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColor.bgCard

        let nav = UINavigationBar()
        nav.prefersLargeTitles = false
        let title: String
        switch mode {
        case .date: title = "选择日期"
        case .month: title = "选择月份"
        case .year: title = "选择年份"
        }
        let item = UINavigationItem(title: title)
        item.leftBarButtonItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(cancel))
        item.rightBarButtonItem = UIBarButtonItem(title: "确定", style: .done, target: self, action: #selector(confirm))
        nav.items = [item]

        view.addSubview(nav)
        nav.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        switch mode {
        case .date:
            datePicker.datePickerMode = .date
            datePicker.preferredDatePickerStyle = .wheels
            datePicker.locale = Locale(identifier: "zh_CN")
            datePicker.date = initialDate
            datePicker.maximumDate = maximumDate
            view.addSubview(datePicker)
            datePicker.snp.makeConstraints { make in
                make.top.equalTo(nav.snp.bottom)
                make.leading.trailing.bottom.equalToSuperview()
            }
        case .month, .year:
            pickerView.dataSource = self
            pickerView.delegate = self
            view.addSubview(pickerView)
            pickerView.snp.makeConstraints { make in
                make.top.equalTo(nav.snp.bottom)
                make.leading.trailing.bottom.equalToSuperview()
            }
            if let idx = years.firstIndex(of: selectedYear) {
                pickerView.selectRow(idx, inComponent: 0, animated: false)
            }
            if mode == .month {
                pickerView.selectRow(selectedMonth - 1, inComponent: 1, animated: false)
            }
        }
    }

    @objc private func cancel() { dismiss(animated: true) }

    @objc private func confirm() {
        let cal = Calendar.current
        let date: Date
        switch mode {
        case .date:
            date = datePicker.date
        case .month:
            var comps = DateComponents()
            comps.year = selectedYear
            comps.month = selectedMonth
            comps.day = 1
            date = cal.date(from: comps) ?? initialDate
        case .year:
            var comps = DateComponents()
            comps.year = selectedYear
            comps.month = 1
            comps.day = 1
            date = cal.date(from: comps) ?? initialDate
        }
        onConfirm?(date)
        dismiss(animated: true)
    }
}

// MARK: - UIPickerView DataSource & Delegate

extension DatePickerSheetViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        mode == .month ? 2 : 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 { return years.count }
        return 12
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 { return "\(years[row])年" }
        return "\(row + 1)月"
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            selectedYear = years[row]
        } else {
            selectedMonth = row + 1
        }
    }
}
