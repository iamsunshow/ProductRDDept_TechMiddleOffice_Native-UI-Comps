/// 单列文案滚轮选择弹层（对齐日期选择：顶栏取消/确定）。

import UIKit
import SnapKit

/// 通用选项滚轮。
final class OptionPickerSheetViewController: UIViewController {
    var onConfirm: ((Int) -> Void)?

    private let titleText: String
    private let options: [String]
    private var selectedIndex: Int
    private let picker = UIPickerView()

    /// 创建选项滚轮。
    ///
    /// - Parameters:
    ///   - title: 顶栏标题
    ///   - options: 选项文案
    ///   - selectedIndex: 初始选中下标
    /// - Returns: 无
    init(title: String, options: [String], selectedIndex: Int = 0) {
        self.titleText = title
        self.options = options
        self.selectedIndex = min(max(0, selectedIndex), max(0, options.count - 1))
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
        if let sheet = sheetPresentationController {
            sheet.detents = [.custom(identifier: .init("option")) { _ in 320 }]
            sheet.prefersGrabberVisible = false
            sheet.preferredCornerRadius = AppRadius.lg
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    /// 搭建顶栏与滚轮。
    ///
    /// - Returns: 无
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColor.bgCard

        let nav = UINavigationBar()
        nav.prefersLargeTitles = false
        let item = UINavigationItem(title: titleText)
        item.leftBarButtonItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(cancel))
        item.rightBarButtonItem = UIBarButtonItem(title: "确定", style: .done, target: self, action: #selector(confirm))
        nav.items = [item]

        picker.dataSource = self
        picker.delegate = self
        if !options.isEmpty {
            picker.selectRow(selectedIndex, inComponent: 0, animated: false)
        }

        view.addSubview(nav)
        view.addSubview(picker)
        nav.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        picker.snp.makeConstraints { make in
            make.top.equalTo(nav.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    /// 取消关闭。
    ///
    /// - Returns: 无
    @objc private func cancel() {
        dismiss(animated: true)
    }

    /// 确认并回调选中下标。
    ///
    /// - Returns: 无
    @objc private func confirm() {
        onConfirm?(picker.selectedRow(inComponent: 0))
        dismiss(animated: true)
    }
}

extension OptionPickerSheetViewController: UIPickerViewDataSource, UIPickerViewDelegate {
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
    /// - Returns: 选项数
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        options.count
    }

    /// 行文案。
    ///
    /// - Parameters:
    ///   - pickerView: 滚轮
    ///   - row: 行
    ///   - component: 列
    /// - Returns: 文案
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        options[row]
    }
}
