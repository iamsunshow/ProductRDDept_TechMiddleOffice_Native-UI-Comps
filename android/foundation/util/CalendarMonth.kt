package com.zhiqihuayun.foundation.util

import java.util.Calendar

/**
 * 公历月份区间工具，对齐 iOS CalendarMonth。
 */
object CalendarMonth {
    data class Interval(val startMillis: Long, val endMillis: Long)

    fun interval(year: Int, month: Int): Interval {
        val cal = Calendar.getInstance()
        cal.clear()
        cal.set(Calendar.YEAR, year)
        cal.set(Calendar.MONTH, month - 1)
        cal.set(Calendar.DAY_OF_MONTH, 1)
        val start = cal.timeInMillis
        cal.add(Calendar.MONTH, 1)
        val end = cal.timeInMillis
        return Interval(start, end)
    }

    fun yearInterval(year: Int): Interval {
        val cal = Calendar.getInstance()
        cal.clear()
        cal.set(Calendar.YEAR, year)
        cal.set(Calendar.MONTH, Calendar.JANUARY)
        cal.set(Calendar.DAY_OF_MONTH, 1)
        val start = cal.timeInMillis
        cal.add(Calendar.YEAR, 1)
        return Interval(start, cal.timeInMillis)
    }

    fun components(nowMillis: Long = System.currentTimeMillis()): Pair<Int, Int> {
        val cal = Calendar.getInstance()
        cal.timeInMillis = nowMillis
        return cal.get(Calendar.YEAR) to (cal.get(Calendar.MONTH) + 1)
    }

    fun startOfDay(millis: Long): Long {
        val cal = Calendar.getInstance()
        cal.timeInMillis = millis
        cal.set(Calendar.HOUR_OF_DAY, 0)
        cal.set(Calendar.MINUTE, 0)
        cal.set(Calendar.SECOND, 0)
        cal.set(Calendar.MILLISECOND, 0)
        return cal.timeInMillis
    }
}
