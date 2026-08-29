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
 * 年月滚轮选择，对齐 iOS MonthPickerViewController。
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MonthPickerSheet(
    year: Int,
    month: Int,
    onDismiss: () -> Unit,
    onConfirm: (year: Int, month: Int) -> Unit
) {
    val currentYear = Calendar.getInstance().get(Calendar.YEAR)
    val years = remember { ((currentYear - 10)..(currentYear + 1)).toList() }
    var selectedYear by remember(year) { mutableIntStateOf(year) }
    var selectedMonth by remember(month) { mutableIntStateOf(month.coerceIn(1, 12)) }
    // 对齐 iOS medium detent：半高展开，可再拉满
    val sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = false)

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
                    "选择月份",
                    color = AppColor.textPrimary,
                    fontSize = AppFont.sizeLg,
                    fontWeight = FontWeight.SemiBold
                )
                TextButton(onClick = { onConfirm(selectedYear, selectedMonth) }) {
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
                            }
                        }
                    },
                    modifier = Modifier.weight(1f).fillMaxWidth()
                )
                AndroidView(
                    factory = { context ->
                        NumberPicker(context).apply {
                            minValue = 1
                            maxValue = 12
                            // 对齐 iOS picker：`7月` 不补零（汇总条仍用 07月）
                            displayedValues = (1..12).map { "${it}月" }.toTypedArray()
                            value = selectedMonth
                            wrapSelectorWheel = false
                            setOnValueChangedListener { _, _, newVal ->
                                selectedMonth = newVal
                            }
                        }
                    },
                    modifier = Modifier.weight(1f).fillMaxWidth()
                )
            }
        }
    }
}
