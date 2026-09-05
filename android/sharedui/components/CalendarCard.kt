package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppFont

/**
 * CalendarCard 日历卡片（ui.calendar-card）——内嵌卡片式单月日历视图（单选日期，数据录入区首批三件）。
 * 7×6 网格月历（周起始周日），头部"yyyy 年 M 月 + ‹/› 翻月"，今日主色描边圆、选中主色实心圆白字、
 * min/maxDate 范围外灰禁不可点，点选日期回调 onChange(CalendarDate)。半受控：selected 外部传入同步高亮并自动切月。
 * 组件为内嵌内容视图：不含弹层；展示月由组件内部自管理（外部可通过 selected 驱动跳月）。
 * 与 foundation.calendar（黄历工具）划界：本组件=交互选择控件（产出日期）。
 *
 * 规格：docs/数据与产物/design-spec/calendar-card-design-spec.html（门禁 A review-calendar-card-A.md，P1–P4 全 A）。
 * 基线：组件库 v1.4.0（2026-09-05，未过 C2/D 不升版）。
 *
 * 设计锚点（Token 注释锚定）：导航头 44dp（箭头点区 28×28）；星期行高 22dp/Xs=12 textSecondary；
 * 日格高 40dp/Md=16，选中圆半径=格高一半（primary 实心圆白字），今日 inset 1.5dp 主色描边圆主色字；
 * 范围外灰 40%（textSecondary @ 0.4）不可点；7×6 固定网格（首尾空位占位）。
 */
data class CalendarDate(
    val year: Int,
    val month: Int, // 1-12
    val day: Int
) {
    val text: String get() = "%04d-%02d-%02d".format(year, month, day)
    val value: Int get() = year * 10000 + month * 100 + day

    companion object {
        fun today(): CalendarDate {
            val c = java.util.Calendar.getInstance()
            return CalendarDate(
                c.get(java.util.Calendar.YEAR),
                c.get(java.util.Calendar.MONTH) + 1,
                c.get(java.util.Calendar.DAY_OF_MONTH)
            )
        }
    }
}

private fun isLeapYear(year: Int) = (year % 4 == 0 && year % 100 != 0) || year % 400 == 0

private fun daysInMonth(year: Int, month: Int): Int = when (month) {
    1, 3, 5, 7, 8, 10, 12 -> 31
    4, 6, 9, 11 -> 30
    2 -> if (isLeapYear(year)) 29 else 28
    else -> 0
}

/** 周起始周日：返回该日是周几（周日=0、周一=1 … 周六=6）。 */
private fun sundayFirstWeekday(year: Int, month: Int, day: Int): Int {
    val c = java.util.Calendar.getInstance()
    c.clear()
    c.set(year, month - 1, day)
    // java.util.Calendar: DAY_OF_WEEK 周日=1；换算到周日=0
    return (c.get(java.util.Calendar.DAY_OF_WEEK) + 6) % 7
}

@Composable
fun CalendarCard(
    selected: CalendarDate? = null,
    minDate: CalendarDate? = null,
    maxDate: CalendarDate? = null,
    onChange: (CalendarDate) -> Unit,
    modifier: Modifier = Modifier
) {
    val today = remember { CalendarDate.today() }
    var sel by remember { mutableStateOf(selected) }
    // 展示月：初始=选中日所在月；无选中=今日所在月
    var showYear by remember { mutableIntStateOf(selected?.year ?: today.year) }
    var showMonth by remember { mutableIntStateOf(selected?.month ?: today.month) }

    // 半受控：外部 selected 变化 → 同步高亮并自动切到所属月（nil=仅清空选中，保留当前月）
    LaunchedEffect(selected) {
        sel = selected
        if (selected != null) {
            showYear = selected.year
            showMonth = selected.month
        }
    }

    // 翻月：基准 1900-01 ~ 2099-12 + min/maxDate 约束（目标月整体越出边界时对应箭头置灰禁翻）
    val moveMonth: (Boolean) -> Unit = { back ->
        val (y, m) = shiftMonth(showYear, showMonth, back)
        showYear = y
        showMonth = m
    }
    val backEnabled = !(
        (minDate != null && monthOutOfBound(showYear, showMonth, back = true, minDate)) ||
            showYear <= 1900
        )
    val fwdEnabled = !(
        (maxDate != null && monthOutOfBound(showYear, showMonth, back = false, maxDate)) ||
            showYear >= 2099
        )

    val firstWeekday = remember(showYear, showMonth) { sundayFirstWeekday(showYear, showMonth, 1) }
    val monthDays = remember(showYear, showMonth) { daysInMonth(showYear, showMonth) }

    Column(modifier = modifier.fillMaxWidth()) {
        // —— 导航头（高 44dp）——
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .height(44.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Box(
                modifier = Modifier
                    .size(28.dp)
                    .clickable(enabled = backEnabled) { moveMonth(true) }
            ) {
                Text(
                    text = "‹",
                    modifier = Modifier.align(Alignment.Center),
                    fontSize = AppFont.sizeXl,
                    color = if (backEnabled) AppColor.textPrimary else AppColor.textSecondary.copy(alpha = 0.4f)
                )
            }
            Text(
                text = "$showYear 年 $showMonth 月",
                modifier = Modifier.weight(1f),
                fontSize = AppFont.sizeSm,
                fontWeight = FontWeight.SemiBold,
                textAlign = TextAlign.Center,
                color = AppColor.textPrimary
            )
            Box(
                modifier = Modifier
                    .size(28.dp)
                    .clickable(enabled = fwdEnabled) { moveMonth(false) }
            ) {
                Text(
                    text = "›",
                    modifier = Modifier.align(Alignment.Center),
                    fontSize = AppFont.sizeXl,
                    color = if (fwdEnabled) AppColor.textPrimary else AppColor.textSecondary.copy(alpha = 0.4f)
                )
            }
        }

        // —— 星期行（高 22dp，周起始周日）——
        Row(modifier = Modifier.fillMaxWidth()) {
            listOf("日", "一", "二", "三", "四", "五", "六").forEach { w ->
                Text(
                    text = w,
                    modifier = Modifier.weight(1f),
                    fontSize = AppFont.sizeXs,
                    textAlign = TextAlign.Center,
                    color = AppColor.textSecondary,
                    lineHeight = 22.sp
                )
            }
        }

        // —— 7×6 日网格（高 40dp/格；首尾空位占位保证网格稳定）——
        Column(modifier = Modifier.fillMaxWidth()) {
            repeat(6) { rowIdx ->
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(40.dp),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.Center
                ) {
                    for (col in 0 until 7) {
                        val idx = rowIdx * 7 + col
                        val dayNum = idx - firstWeekday + 1
                        val inRange = dayNum in 1..monthDays
                        val date = if (inRange) CalendarDate(showYear, showMonth, dayNum) else null
                        val disabled = date != null && !isInRange(date, minDate, maxDate)
                        val isToday = date != null && date == today
                        val isSel = date != null && date == sel
                        Box(
                            modifier = Modifier
                                .weight(1f)
                                .fillMaxSize()
                                .clickable(enabled = date != null && !disabled) {
                                    if (date != null) {
                                        sel = date
                                        onChange(date)
                                    }
                                },
                            contentAlignment = Alignment.Center
                        ) {
                            if (date != null) {
                                Box(
                                    modifier = Modifier
                                        .size(40.dp)
                                        .clip(CircleShape)
                                        .background(if (isSel) AppColor.primary else androidx.compose.ui.graphics.Color.Transparent)
                                        .then(
                                            if (isToday && !isSel) {
                                                Modifier.border(1.5.dp, AppColor.primary, CircleShape)
                                            } else Modifier
                                        ),
                                    contentAlignment = Alignment.Center
                                ) {
                                    Text(
                                        text = dayNum.toString(),
                                        fontSize = AppFont.sizeMd,
                                        fontWeight = if (isSel) FontWeight.SemiBold else FontWeight.Normal,
                                        color = when {
                                            isSel -> AppColor.textInverse
                                            isToday -> AppColor.primary
                                            disabled -> AppColor.textSecondary.copy(alpha = 0.4f)
                                            else -> AppColor.textPrimary
                                        }
                                    )
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

/** 判断目标月整体是否已越出 min/maxDate 边界（翻月按钮置灰依据）。 */
private fun monthOutOfBound(showYear: Int, showMonth: Int, back: Boolean, bound: CalendarDate): Boolean {
    return if (back) {
        // 目标=上一月：其末日若仍早于 minDate → 不可再退
        val (py, pm) = shiftMonth(showYear, showMonth, back = true)
        val last = CalendarDate(py, pm, daysInMonth(py, pm))
        last.value < bound.value
    } else {
        // 目标=下一月：其首日若晚于 maxDate → 不可再进
        val (ny, nm) = shiftMonth(showYear, showMonth, back = false)
        CalendarDate(ny, nm, 1).value > bound.value
    }
}

private fun shiftMonth(year: Int, month: Int, back: Boolean): Pair<Int, Int> {
    var y = year
    var m = if (back) month - 1 else month + 1
    if (m == 0) { m = 12; y -= 1 }
    if (m == 13) { m = 1; y += 1 }
    return y to m
}

private fun isInRange(date: CalendarDate, minDate: CalendarDate?, maxDate: CalendarDate?): Boolean {
    if (minDate != null && date.value < minDate.value) return false
    if (maxDate != null && date.value > maxDate.value) return false
    return true
}
