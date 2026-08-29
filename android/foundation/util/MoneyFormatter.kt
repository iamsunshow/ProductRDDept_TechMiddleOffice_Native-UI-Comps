package com.zhiqihuayun.foundation.util

import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

/**
 * 金额展示格式化，对齐 iOS MoneyFormatter（两位小数、无千分位）。
 */
object MoneyFormatter {
    fun string(amount: Double): String = String.format(Locale.US, "%.2f", amount)

    fun currency(amount: Double): String = "¥" + string(amount)

    fun signed(amount: Double, isIncome: Boolean): String {
        val body = string(amount)
        return if (isIncome) "+$body" else "-$body"
    }
}

object DateFormatters {
    private val zh = Locale.CHINA

    fun displayDay(millis: Long): String =
        SimpleDateFormat("MM月dd日", zh).format(Date(millis))

    fun weekdayShort(millis: Long): String =
        SimpleDateFormat("EEE", zh).format(Date(millis))

    fun yearLabel(year: Int): String = "${year}年"

    fun monthLabel(month: Int): String = String.format(Locale.CHINA, "%02d月", month)

    /** 对齐 iOS `yyyy年M月`（月份不补零），用于发现页账单副标题等。 */
    fun yearMonthLabel(year: Int, month: Int): String = "${year}年${month}月"
}
