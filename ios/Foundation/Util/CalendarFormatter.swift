/// 公历月份区间与分量解析工具。

import Foundation

/// 按公历月份计算时间区间。
enum CalendarFormatter {
    /// 计算当月 `[start, end)` 半开区间（end 为下月 1 日 0 点）。
    ///
    /// - Parameters:
    ///   - year: 公历年
    ///   - month: 月份 1...12
    ///   - calendar: 日历，默认当前
    /// - Returns: 当月时间区间
    static func interval(year: Int, month: Int, calendar: Calendar = .current) -> DateInterval {
        var comps = DateComponents()
        comps.year = year
        comps.month = month
        comps.day = 1
        let start = calendar.date(from: comps)!
        let end = calendar.date(byAdding: .month, value: 1, to: start)!
        return DateInterval(start: start, end: end)
    }

    /// 计算当年 `[start, end)` 半开区间（end 为次年 1 日 0 点）。
    ///
    /// - Parameters:
    ///   - year: 公历年
    ///   - calendar: 日历，默认当前
    /// - Returns: 当年时间区间
    static func yearInterval(year: Int, calendar: Calendar = .current) -> DateInterval {
        var comps = DateComponents()
        comps.year = year
        comps.month = 1
        comps.day = 1
        let start = calendar.date(from: comps)!
        let end = calendar.date(byAdding: .year, value: 1, to: start)!
        return DateInterval(start: start, end: end)
    }

    /// 从日期提取公历年与月。
    ///
    /// - Parameters:
    ///   - date: 参考日期，默认当前
    ///   - calendar: 日历，默认当前
    /// - Returns: `(year, month)` 元组
    static func components(from date: Date = Date(), calendar: Calendar = .current) -> (year: Int, month: Int) {
        let c = calendar.dateComponents([.year, .month], from: date)
        return (c.year!, c.month!)
    }
}
