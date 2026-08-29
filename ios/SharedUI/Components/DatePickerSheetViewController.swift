/// 日期滚轮选择器：取消 / 确定在顶部，避免底部误触。

import UIKit
import SnapKit

/// 日期选择弹层。
///
/// 用户确认后通过 `onConfirm` 回传所选日期。
final class DatePickerSheetViewController: UIViewController {
    var onConfirm: ((Date) -> Void)?

    private let picker = UIDatePicker()
    private let initialDate: Date
    private let maximumDate: Date?

    /// 创建日期选择器。
    ///
    /// - Parameters:
    ///   - date: 初始选中日期
    ///   - maximumDate: 可选最大日期
    /// - Returns: 无
    init(date: Date, maximumDate: Date? = Date()) {
        self.initialDate = date
        self.maximumDate = maximumDate
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
        if let sheet = sheetPresentationController {
            sheet.detents = [.custom(identifier: .init("date")) { _ in 320 }]
            sheet.prefersGrabberVisible = false
            sheet.preferredCornerRadius = AppRadius.lg
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    /// 搭建顶部取消/确定与日期滚轮。
    ///
    /// - Returns: 无
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColor.bgCard

        let nav = UINavigationBar()
        nav.prefersLargeTitles = false
        let item = UINavigationItem(title: "选择日期")
        item.leftBarButtonItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(cancel))
        item.rightBarButtonItem = UIBarButtonItem(title: "确定", style: .done, target: self, action: #selector(confirm))
        nav.items = [item]

        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .wheels
        picker.locale = Locale(identifier: "zh_CN")
        picker.date = initialDate
        picker.maximumDate = maximumDate

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

    /// 取消并关闭。
    ///
    /// - Returns: 无
    @objc private func cancel() {
        dismiss(animated: true)
    }

    /// 确认所选日期并回调。
    ///
    /// - Returns: 无
    @objc private func confirm() {
        onConfirm?(picker.date)
        dismiss(animated: true)
    }
}
