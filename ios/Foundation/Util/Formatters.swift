/// 金额与日期格式化工具，统一 UI 展示格式。

import Foundation

/// 金额字符串格式化。
///
/// **全局规范**：所有对外展示的金额均保留两位小数（如 `1121.00`），由本类型统一处理。
enum MoneyFormatter {
    private static let decimal: NumberFormatter = {
        let f = NumberFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.numberStyle = .decimal
        f.minimumFractionDigits = 2
        f.maximumFractionDigits = 2
        f.groupingSeparator = ""
        return f
    }()

    /// 格式化为两位小数字符串（无货币符号）。
    ///
    /// - Parameter amount: 金额
    /// - Returns: 如 `"38.50"`、`"-1118.00"`
    static func string(from amount: Double) -> String {
        decimal.string(from: NSNumber(value: amount)) ?? String(format: "%.2f", amount)
    }

    /// 格式化为带人民币符号的金额。
    ///
    /// - Parameter amount: 金额
    /// - Returns: 如 `"¥38.50"`
    static func currency(from amount: Double) -> String {
        "¥" + string(from: amount)
    }

    /// 按收支方向添加正负号前缀（业务无关：由调用方映射收入/支出语义）。
    ///
    /// - Parameters:
    ///   - amount: 金额
    ///   - isIncome: 收入为 `true`，支出为 `false`
    /// - Returns: 收入带 `+`，支出带 `-`
    static func signed(from amount: Double, isIncome: Bool) -> String {
        let body = string(from: amount)
        return isIncome ? "+\(body)" : "-\(body)"
    }
}

/// 中文日期格式化器集合。
enum DateFormatters {
    static let displayDay: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "zh_CN")
        f.dateFormat = "MM月dd日"
        return f
    }()

    static let yearMonth: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "zh_CN")
        f.dateFormat = "yyyy年M月"
        return f
    }()

    static let weekdayShort: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "zh_CN")
        f.dateFormat = "EEE"
        return f
    }()

    static let dateTime: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "zh_CN")
        f.dateFormat = "yyyy-MM-dd HH:mm"
        return f
    }()

    /// 生成「yyyy年M月」标签。
    ///
    /// - Parameters:
    ///   - year: 公历年
    ///   - month: 月份 1...12
    /// - Returns: 本地化年月文案
    static func yearMonthLabel(year: Int, month: Int) -> String {
        var comps = DateComponents()
        comps.year = year
        comps.month = month
        comps.day = 1
        let date = Calendar.current.date(from: comps) ?? Date()
        return yearMonth.string(from: date)
    }

    /// 生成日期时间标签。
    ///
    /// - Parameter date: 日期
    /// - Returns: `yyyy-MM-dd HH:mm`
    static func dateTimeLabel(_ date: Date) -> String {
        dateTime.string(from: date)
    }
}
