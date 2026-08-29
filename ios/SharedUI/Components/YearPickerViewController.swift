/// 年份滚轮选择器，供账单年账单模式使用。

import UIKit
import SnapKit

/// 年份选择弹层。
final class YearPickerViewController: UIViewController {
    var onConfirm: ((Int) -> Void)?

    private let years: [Int]
    private var selectedYear: Int
    private let picker = UIPickerView()

    /// 创建年份选择器。
    ///
    /// - Parameter year: 初始年
    /// - Returns: 无
    init(year: Int) {
        let current = CalendarFormatter.components().year
        self.years = Array((current - 10)...(current + 1))
        self.selectedYear = year
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
        if let sheet = sheetPresentationController {
            sheet.detents = [.custom(identifier: .init("year")) { _ in 300 }]
            sheet.prefersGrabberVisible = false
            sheet.preferredCornerRadius = AppRadius.lg
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    /// 搭建取消/确定与滚轮。
    ///
    /// - Returns: 无
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColor.bgCard

        let nav = UINavigationBar()
        nav.prefersLargeTitles = false
        let item = UINavigationItem(title: "选择年份")
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

        if let index = years.firstIndex(of: selectedYear) {
            picker.selectRow(index, inComponent: 0, animated: false)
        }
    }

    /// 取消关闭。
    ///
    /// - Returns: 无
    @objc private func cancel() { dismiss(animated: true) }

    /// 确认回调。
    ///
    /// - Returns: 无
    @objc private func confirm() {
        onConfirm?(selectedYear)
        dismiss(animated: true)
    }
}

extension YearPickerViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    /// 列数。
    ///
    /// - Parameter pickerView: 滚轮
    /// - Returns: 1
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }

    /// 行数。
    ///
    /// - Parameters:
    ///   - pickerView: 滚轮
    ///   - component: 列
    /// - Returns: 可选年份数
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        years.count
    }

    /// 行标题。
    ///
    /// - Parameters:
    ///   - pickerView: 滚轮
    ///   - row: 行
    ///   - component: 列
    /// - Returns: 如 `2026年`
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        "\(years[row])年"
    }

    /// 选中更新。
    ///
    /// - Parameters:
    ///   - pickerView: 滚轮
    ///   - row: 行
    ///   - component: 列
    /// - Returns: 无
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedYear = years[row]
    }
}
