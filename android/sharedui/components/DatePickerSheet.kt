package com.zhiqihuayun.sharedui.components

import android.widget.NumberPicker
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.rememberModalBottomSheetState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.viewinterop.AndroidView
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppFont
import com.zhiqihuayun.foundation.design.AppRadius
import com.zhiqihuayun.foundation.design.AppSpace
import java.util.Calendar

/**
 * 日期滚轮选择器（年/月/日三列），对齐 iOS DatePickerSheetViewController。
 *
 * @param dateMillis 初始选中日期毫秒
 * @param maximumDateMillis 最大可选日期，默认今天
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DatePickerSheet(
    dateMillis: Long,
    maximumDateMillis: Long? = System.currentTimeMillis(),
    onDismiss: () -> Unit,
    onConfirm: (dateMillis: Long) -> Unit
) {
    val cal = Calendar.getInstance()
    cal.timeInMillis = dateMillis
    var selectedYear by remember(dateMillis) { mutableIntStateOf(cal.get(Calendar.YEAR)) }
    var selectedMonth by remember(dateMillis) { mutableIntStateOf(cal.get(Calendar.MONTH) + 1) }
    var selectedDay by remember(dateMillis) { mutableIntStateOf(cal.get(Calendar.DAY_OF_MONTH)) }

    val currentYear = Calendar.getInstance().get(Calendar.YEAR)
    val years = remember { ((currentYear - 10)..(currentYear + 1)).toList() }

    val maxCal = maximumDateMillis?.let {
        Calendar.getInstance().apply { timeInMillis = it }
    }
    val sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = false)

    fun daysInMonth(year: Int, month: Int): Int {
        val c = Calendar.getInstance()
        c.set(Calendar.YEAR, year)
        c.set(Calendar.MONTH, month - 1)
        return c.getActualMaximum(Calendar.DAY_OF_MONTH)
    }

    fun isOverMax(year: Int, month: Int, day: Int): Boolean {
        maxCal ?: return false
        val c = Calendar.getInstance()
        c.set(Calendar.YEAR, year)
        c.set(Calendar.MONTH, month - 1)
        c.set(Calendar.DAY_OF_MONTH, day)
        c.set(Calendar.HOUR_OF_DAY, 23)
        c.set(Calendar.MINUTE, 59)
        c.set(Calendar.SECOND, 59)
        return c.after(maxCal)
    }

    ModalBottomSheet(
        onDismissRequest = onDismiss,
        sheetState = sheetState,
        containerColor = AppColor.bgCard,
        shape = RoundedCornerShape(topStart = AppRadius.lg, topEnd = AppRadius.lg)
    ) {
        Column(modifier = Modifier.fillMaxWidth().padding(bottom = AppSpace.lg)) {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = AppSpace.sm),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                TextButton(onClick = onDismiss) {
                    Text("取消", color = AppColor.textSecondary, fontSize = AppFont.sizeMd)
                }
                Text(
                    "选择日期",
                    color = AppColor.textPrimary,
                    fontSize = AppFont.sizeLg,
                    fontWeight = FontWeight.SemiBold
                )
                TextButton(onClick = {
                    val y = selectedYear
                    val m = selectedMonth
                    var d = selectedDay
                    val maxD = daysInMonth(y, m)
                    if (d > maxD) d = maxD
                    if (isOverMax(y, m, d)) {
                        d = maxCal!!.get(Calendar.DAY_OF_MONTH)
                    }
                    val c = Calendar.getInstance()
                    c.set(y, m - 1, d, 0, 0, 0)
                    c.set(Calendar.MILLISECOND, 0)
                    onConfirm(c.timeInMillis)
                }) {
                    Text("确定", color = AppColor.primary, fontSize = AppFont.sizeMd, fontWeight = FontWeight.SemiBold)
                }
            }
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(200.dp)
                    .padding(horizontal = AppSpace.lg),
                horizontalArrangement = Arrangement.spacedBy(AppSpace.md)
            ) {
                // 年
                AndroidView(
                    factory = { context ->
                        NumberPicker(context).apply {
                            minValue = 0
                            maxValue = years.lastIndex
                            displayedValues = years.map { "${it}年" }.toTypedArray()
                            value = years.indexOf(selectedYear).coerceAtLeast(0)
                            wrapSelectorWheel = false
                            setOnValueChangedListener { _, _, newVal ->
                                selectedYear = years[newVal]
                                val maxD = daysInMonth(selectedYear, selectedMonth)
                                if (selectedDay > maxD) selectedDay = maxD
                            }
                        }
                    },
                    modifier = Modifier.weight(1f).fillMaxWidth()
                )
                // 月
                AndroidView(
                    factory = { context ->
                        NumberPicker(context).apply {
                            minValue = 1
                            maxValue = 12
                            displayedValues = (1..12).map { "${it}月" }.toTypedArray()
                            value = selectedMonth
                            wrapSelectorWheel = false
                            setOnValueChangedListener { _, _, newVal ->
                                selectedMonth = newVal
                                val maxD = daysInMonth(selectedYear, selectedMonth)
                                if (selectedDay > maxD) selectedDay = maxD
                            }
                        }
                    },
                    modifier = Modifier.weight(1f).fillMaxWidth()
                )
                // 日
                AndroidView(
                    factory = { context ->
                        NumberPicker(context).apply {
                            val maxD = daysInMonth(selectedYear, selectedMonth)
                            minValue = 1
                            maxValue = maxD
                            displayedValues = (1..maxD).map { "${it}日" }.toTypedArray()
                            value = selectedDay.coerceIn(1, maxD)
                            wrapSelectorWheel = false
                            setOnValueChangedListener { _, _, newVal ->
                                selectedDay = newVal
                            }
                        }
                    },
                    update = { picker ->
                        val maxD = daysInMonth(selectedYear, selectedMonth)
                        if (picker.maxValue != maxD) {
                            picker.maxValue = maxD
                            picker.displayedValues = (1..maxD).map { "${it}日" }.toTypedArray()
                            if (picker.value > maxD) picker.value = maxD
                        }
                    },
                    modifier = Modifier.weight(1f).fillMaxWidth()
                )
            }
        }
    }
}
