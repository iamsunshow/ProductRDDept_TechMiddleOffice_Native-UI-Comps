/// CalendarCardView 日历卡片（ui.calendar-card）——内嵌卡片式单月日历视图（单选日期，数据录入区首批三件）。
///
/// 组件 ID：`ui.calendar-card`（api.json 契约对齐；门禁 A AI 代评通过 2026-09-05，规格
/// design-spec/calendar-card-design-spec.html + 评审单 review-calendar-card-A.md，P1–P4 全 A）。
///
/// 7×6 网格月历（周起始周日），头部「yyyy 年 M 月 + ‹/› 翻月」，今日主色描边圆、选中主色实心圆白字、
/// min/maxDate 范围外灰禁不可点，点选日期回调 onChange(CalendarDate)。
/// 半受控：selected 外部传入同步高亮并自动切到所属月。
/// 组件为内嵌内容视图：不含弹层；展示月由组件内部自管理（外部可通过 selected 驱动跳月）。
///
/// 基线：组件库 v1.4.0（2026-09-05，未过 C2/D 不升版）。
///
/// 设计锚点（Token 注释锚定）：导航头 44pt（箭头点区 28×28）；星期行高 22pt/Xs=12 textSecondary；
/// 日格高 40pt/Md=16，选中圆半径=格高一半（primary 实心圆白字），今日 inset 1.5pt 主色描边圆主色字；
/// 范围外灰 40%（textSecondary @ 0.4）不可点；7×6 固定网格（首尾空位占位）。
///
/// 用法：
/// ```swift
/// let card = CalendarCardView(selected: nil, minDate: min, maxDate: max, onChange: { date in ... })
/// host.addSubview(card)
/// card.snp.makeConstraints { make in make.edges.equalToSuperview(); make.height.equalTo(306) }
/// card.selected = CalendarDate(year: 2026, month: 9, day: 15) // 编辑回显/跳月
/// ```
import UIKit
import SnapKit

/// 日期值对象（与 Android `CalendarDate` 同构；text/值对齐）。
struct CalendarDate: Equatable {
    let year: Int
    let month: Int // 1-12
    let day: Int

    var text: String { String(format: "%04d-%02d-%02d", year, month, day) }
    var value: Int { year * 10000 + month * 100 + day }

    static func today() -> CalendarDate {
        let comps = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        return CalendarDate(year: comps.year ?? 2026, month: comps.month ?? 1, day: comps.day ?? 1)
    }
}

private func isLeapYear(_ year: Int) -> Bool {
    (year % 4 == 0 && year % 100 != 0) || year % 400 == 0
}

private func daysInMonth(_ year: Int, _ month: Int) -> Int {
    switch month {
    case 1, 3, 5, 7, 8, 10, 12: return 31
    case 4, 6, 9, 11: return 30
    case 2: return isLeapYear(year) ? 29 : 28
    default: return 0
    }
}

/// 周起始周日：返回该日是周几（周日=0、周一=1 … 周六=6）。
private func sundayFirstWeekday(_ year: Int, _ month: Int, _ day: Int) -> Int {
    var comps = DateComponents()
    comps.year = year
    comps.month = month
    comps.day = day
    guard let date = Calendar.current.date(from: comps) else { return 0 }
    let weekday = Calendar.current.component(.weekday, from: date) // 1=周日 … 7=周六
    return (weekday + 6) % 7
}

/// 目标月整体是否已越出 min/maxDate 边界（翻月按钮置灰依据，与 Android monthOutOfBound 同构）。
private func monthOutOfBound(_ year: Int, _ month: Int, back: Bool, bound: CalendarDate) -> Bool {
    if back {
        let (py, pm) = shiftMonth(year, month, back: true)
        let last = CalendarDate(year: py, month: pm, day: daysInMonth(py, pm))
        return last.value < bound.value
    } else {
        let (ny, nm) = shiftMonth(year, month, back: false)
        return CalendarDate(year: ny, month: nm, day: 1).value > bound.value
    }
}

private func shiftMonth(_ year: Int, _ month: Int, back: Bool) -> (Int, Int) {
    var y = year
    var m = back ? month - 1 : month + 1
    if m == 0 { m = 12; y -= 1 }
    if m == 13 { m = 1; y += 1 }
    return (y, m)
}

private func isInRange(_ date: CalendarDate, minDate: CalendarDate?, maxDate: CalendarDate?) -> Bool {
    if let min = minDate, date.value < min.value { return false }
    if let max = maxDate, date.value > max.value { return false }
    return true
}

final class CalendarCardView: UIView {

    /// 组件内布局规格（与 Android 侧同数值不同单位；Token 对齐注释防魔法值误判）
    struct Metrics {
        static let navHeight: CGFloat = 44
        static let arrowTap: CGFloat = 28
        static let weekHeight: CGFloat = 22
        static let cellHeight: CGFloat = 40
        static let circle: CGFloat = 40
        static let todayBorder: CGFloat = 1.5
        static let gridRows = 6
        static let weekdayCount = 7
    }

    private let minDate: CalendarDate?
    private let maxDate: CalendarDate?
    private let onChange: ((CalendarDate) -> Void)?

    private var showYear: Int
    private var showMonth: Int
    private var internalSelected: CalendarDate?

    /// 半受控选中日期：外部驱动（初始预填/编辑回显/清空）同步高亮并自动切到所属月（nil=仅清空，保留当前月）。
    var selected: CalendarDate? {
        didSet {
            internalSelected = selected
            if let s = selected {
                showYear = s.year
                showMonth = s.month
            }
            refresh()
        }
    }

    private let titleLabel = UILabel()
    private let prevButton = UIButton(type: .system)
    private let nextButton = UIButton(type: .system)
    private let weekdayStack = UIStackView()
    private let gridStack = UIStackView()
    private var dayCells: [DayCell] = []

    // MARK: - init

    init(
        selected: CalendarDate? = nil,
        minDate: CalendarDate? = nil,
        maxDate: CalendarDate? = nil,
        onChange: ((CalendarDate) -> Void)? = nil
    ) {
        let initial = selected ?? CalendarDate.today()
        self.minDate = minDate
        self.maxDate = maxDate
        self.onChange = onChange
        self.showYear = initial.year
        self.showMonth = initial.month
        self.internalSelected = selected
        super.init(frame: .zero)
        backgroundColor = AppColor.bgCard
        setup()
        refresh()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("CalendarCardView 不支持 initWithCoder 解码，请使用 init(selected:minDate:maxDate:onChange:)。")
    }

    // MARK: - 布局

    private func setup() {
        // —— 导航头（高 44pt）：‹/› 28×28 点区 + 中央标题 ——
        prevButton.setTitle("‹", for: .normal)
        nextButton.setTitle("›", for: .normal)
        prevButton.titleLabel?.font = .systemFont(ofSize: AppFont.sizeXl)
        nextButton.titleLabel?.font = .systemFont(ofSize: AppFont.sizeXl)
        prevButton.addTarget(self, action: #selector(prevTapped), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        titleLabel.textAlignment = .center
        titleLabel.font = .systemFont(ofSize: AppFont.sizeSm, weight: .semibold)
        titleLabel.textColor = AppColor.textPrimary
        addSubview(prevButton)
        addSubview(nextButton)
        addSubview(titleLabel)
        prevButton.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalTo(titleLabel)
            make.size.equalTo(Metrics.arrowTap)
        }
        nextButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalTo(titleLabel)
            make.size.equalTo(Metrics.arrowTap)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(Metrics.navHeight)
        }
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)

        // —— 星期行（高 22pt，周起始周日）——
        weekdayStack.axis = .horizontal
        weekdayStack.distribution = .fillEqually
        weekdayStack.spacing = 0
        addSubview(weekdayStack)
        weekdayStack.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(Metrics.weekHeight)
        }
        for name in ["日", "一", "二", "三", "四", "五", "六"] {
            let label = UILabel()
            label.text = name
            label.font = .systemFont(ofSize: AppFont.sizeXs)
            label.textAlignment = .center
            label.textColor = AppColor.textSecondary
            weekdayStack.addArrangedSubview(label)
        }

        // —— 7×6 日网格（高 40pt/格；首尾空位占位保证网格稳定）——
        gridStack.axis = .vertical
        gridStack.distribution = .fillEqually
        gridStack.spacing = 0
        addSubview(gridStack)
        gridStack.snp.makeConstraints { make in
            make.top.equalTo(weekdayStack.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        for _ in 0..<Metrics.gridRows {
            let row = UIStackView()
            row.axis = .horizontal
            row.distribution = .fillEqually
            row.spacing = 0
            for _ in 0..<Metrics.weekdayCount {
                let cell = DayCell()
                cell.tag = dayCells.count
                cell.addTarget(self, action: #selector(dayTapped(_:)), for: .touchUpInside)
                row.addArrangedSubview(cell)
                dayCells.append(cell)
            }
            gridStack.addArrangedSubview(row)
        }
    }

    // MARK: - 状态机（与 Android CalendarCard 同构）

    private func refresh() {
        titleLabel.text = "\(showYear) 年 \(showMonth) 月"

        let backEnabled = !(
            (minDate != nil && monthOutOfBound(showYear, showMonth, back: true, bound: minDate!)) ||
                showYear <= 1900
        )
        let fwdEnabled = !(
            (maxDate != nil && monthOutOfBound(showYear, showMonth, back: false, bound: maxDate!)) ||
                showYear >= 2099
        )
        prevButton.isEnabled = backEnabled
        nextButton.isEnabled = fwdEnabled
        prevButton.setTitleColor(backEnabled ? AppColor.textPrimary : AppColor.textSecondary.withAlphaComponent(0.4), for: .normal)
        nextButton.setTitleColor(fwdEnabled ? AppColor.textPrimary : AppColor.textSecondary.withAlphaComponent(0.4), for: .normal)

        let today = CalendarDate.today()
        let firstWeekday = sundayFirstWeekday(showYear, showMonth, 1)
        let days = daysInMonth(showYear, showMonth)
        for cell in dayCells {
            let dayNum = cell.tag - firstWeekday + 1
            let date = (1...days).contains(dayNum) ? CalendarDate(year: showYear, month: showMonth, day: dayNum) : nil
            let disabled = date != nil && !isInRange(date!, minDate: minDate, maxDate: maxDate)
            let isToday = date == today
            let isSel = date != nil && date == internalSelected
            cell.configure(date: date, disabled: disabled, isToday: isToday, isSelected: isSel)
        }
    }

    @objc private func prevTapped() {
        let (y, m) = shiftMonth(showYear, showMonth, back: true)
        showYear = y
        showMonth = m
        refresh()
    }

    @objc private func nextTapped() {
        let (y, m) = shiftMonth(showYear, showMonth, back: false)
        showYear = y
        showMonth = m
        refresh()
    }

    @objc private func dayTapped(_ sender: UIControl) {
        guard dayCells.indices.contains(sender.tag) else { return }
        guard let date = dayCells[sender.tag].date else { return }
        internalSelected = date
        onChange?(date)
        refresh()
    }
}

// MARK: - 日格 Cell（今日描边圆 / 选中实心圆）

private final class DayCell: UIControl {
    private let marker = UIView()
    private let label = UILabel()
    var date: CalendarDate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        marker.layer.cornerRadius = CalendarCardView.Metrics.circle / 2
        marker.layer.masksToBounds = true
        marker.isUserInteractionEnabled = false
        label.isUserInteractionEnabled = false
        label.textAlignment = .center
        label.font = .systemFont(ofSize: AppFont.sizeMd)
        addSubview(marker)
        addSubview(label)
        marker.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(CalendarCardView.Metrics.circle)
        }
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("DayCell 不支持 initWithCoder")
    }

    func configure(date: CalendarDate?, disabled: Bool, isToday: Bool, isSelected: Bool) {
        self.date = date
        guard let date else {
            isEnabled = false
            marker.backgroundColor = .clear
            marker.layer.borderWidth = 0
            label.text = nil
            return
        }
        isEnabled = !disabled
        label.text = "\(date.day)"
        label.font = .systemFont(ofSize: AppFont.sizeMd, weight: isSelected ? .semibold : .regular)
        label.textColor = isSelected
            ? .white
            : (isToday
                ? AppColor.primary
                : (disabled
                    ? AppColor.textSecondary.withAlphaComponent(0.4)
                    : AppColor.textPrimary))
        if isSelected {
            marker.backgroundColor = AppColor.primary
            marker.layer.borderWidth = 0
        } else {
            marker.backgroundColor = .clear
            marker.layer.borderColor = AppColor.primary.cgColor
            marker.layer.borderWidth = isToday ? CalendarCardView.Metrics.todayBorder : 0
        }
    }
}
