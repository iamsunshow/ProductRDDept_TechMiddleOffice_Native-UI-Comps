/// 年月滚轮选择器（组件 C1），供明细/账单等页切换月份。

import UIKit
import SnapKit

/// 年月滚轮选择弹层。
///
/// 用户确认后通过 `onConfirm` 回传所选年月。
final class MonthPickerViewController: UIViewController {
    var onConfirm: ((Int, Int) -> Void)?

    private let years: [Int]
    private let months = Array(1...12)
    private var selectedYear: Int
    private var selectedMonth: Int
    private let picker = UIPickerView()

    /// 创建选择器并预选指定年月。
    ///
    /// - Parameters:
    ///   - year: 初始选中年
    ///   - month: 初始选中月 1...12
    /// - Returns: 无
    init(year: Int, month: Int) {
        let current = CalendarFormatter.components().year
        self.years = Array((current - 10)...(current + 1))
        self.selectedYear = year
        self.selectedMonth = month
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
        if let sheet = sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    /// 搭建导航栏与双列滚轮。
    ///
    /// - Returns: 无
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColor.bgCard
        title = "选择月份"

        let nav = UINavigationBar()
        nav.prefersLargeTitles = false
        let item = UINavigationItem(title: "选择月份")
        item.leftBarButtonItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(cancel))
        item.rightBarButtonItem = UIBarButtonItem(title: "确定", style: .done, target: self, action: #selector(confirm))
        nav.items = [item]

        picker.dataSource = self
        picker.delegate = self

        view.addSubview(nav)
        view.addSubview(picker)

        nav.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        picker.snp.makeConstraints { make in
            make.top.equalTo(nav.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }

        if let yIndex = years.firstIndex(of: selectedYear) {
            picker.selectRow(yIndex, inComponent: 0, animated: false)
        }
        picker.selectRow(selectedMonth - 1, inComponent: 1, animated: false)
    }

    /// 取消选择并关闭弹层。
    ///
    /// - Returns: 无
    @objc private func cancel() {
        dismiss(animated: true)
    }

    /// 确认所选年月并回调。
    ///
    /// - Returns: 无
    @objc private func confirm() {
        onConfirm?(selectedYear, selectedMonth)
        dismiss(animated: true)
    }
}

extension MonthPickerViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    /// 返回滚轮列数（年、月两列）。
    ///
    /// - Parameter pickerView: 滚轮视图
    /// - Returns: 列数 2
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 2 }

    /// 返回指定列的行数。
    ///
    /// - Parameters:
    ///   - pickerView: 滚轮视图
    ///   - component: 列索引，0 为年，1 为月
    /// - Returns: 行数
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        component == 0 ? years.count : months.count
    }

    /// 返回指定行的展示标题。
    ///
    /// - Parameters:
    ///   - pickerView: 滚轮视图
    ///   - row: 行索引
    ///   - component: 列索引
    /// - Returns: 如 `"2026年"` 或 `"7月"`
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return "\(years[row])年"
        }
        return "\(months[row])月"
    }

    /// 用户滚动后更新内部选中值。
    ///
    /// - Parameters:
    ///   - pickerView: 滚轮视图
    ///   - row: 选中行
    ///   - component: 列索引
    /// - Returns: 无
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            selectedYear = years[row]
        } else {
            selectedMonth = months[row]
        }
    }
}
