package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.background
import androidx.compose.foundation.gestures.snapping.SnapPosition
import androidx.compose.foundation.gestures.snapping.rememberSnapFlingBehavior
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.rememberModalBottomSheetState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.derivedStateOf
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.runtime.snapshotFlow
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppFont
import com.zhiqihuayun.foundation.design.AppRadius
import com.zhiqihuayun.foundation.design.AppSpace
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.launch
import java.util.Calendar
import kotlin.math.abs

/**
 * 日期选择模式，对齐 iOS DatePickerMode。
 */
enum class DatePickerMode {
    DATE,   // 年/月/日
    MONTH,  // 年/月
    YEAR    // 年
}

/**
 * 统一日期滚轮选择器，支持 DATE / MONTH / YEAR 三种模式，对齐 iOS DatePickerSheetViewController。
 * 视觉对齐 Picker #33：工具栏 44dp（取消 sizeSm 次色 / 标题 sizeMd Semibold / 确定 primary sizeMd Semibold）
 * + 滚轮 220dp=5 行×44（选中行 primary Semibold，其余 textPrimary，上下 hairline 夹线+渐隐遮罩）。
 *
 * 确认后通过 [onConfirm] 回传毫秒时间戳：
 * - DATE：选中日期 0 点
 * - MONTH：该月 1 号 0 点
 * - YEAR：该年 1 月 1 号 0 点
 *
 * @param mode 选择模式
 * @param initialDateMillis 初始日期毫秒
 * @param maximumDateMillis 最大可选日期（仅 DATE 模式，预留）
 */
@OptIn(ExperimentalMaterial3Api::class, ExperimentalFoundationApi::class)
@Composable
fun DatePickerSheet(
    mode: DatePickerMode = DatePickerMode.DATE,
    initialDateMillis: Long,
    maximumDateMillis: Long? = System.currentTimeMillis(),
    onDismiss: () -> Unit,
    onConfirm: (dateMillis: Long) -> Unit
) {
    val cal = Calendar.getInstance().apply { timeInMillis = initialDateMillis }
    var selectedYear by remember(initialDateMillis) { mutableIntStateOf(cal.get(Calendar.YEAR)) }
    var selectedMonth by remember(initialDateMillis) { mutableIntStateOf(cal.get(Calendar.MONTH) + 1) }
    var selectedDay by remember(initialDateMillis) { mutableIntStateOf(cal.get(Calendar.DAY_OF_MONTH)) }

    val currentYear = Calendar.getInstance().get(Calendar.YEAR)

    // 最大可选日期分量（仅 DATE 模式限制；为 null 或非 DATE 模式时不限制）
    val maxComp = maximumDateMillis?.let {
        Calendar.getInstance().apply { timeInMillis = it }
    }
    val maxYear = if (mode == DatePickerMode.DATE && maxComp != null) maxComp.get(Calendar.YEAR) else Int.MAX_VALUE
    val maxMonth = if (mode == DatePickerMode.DATE && maxComp != null) maxComp.get(Calendar.MONTH) + 1 else 12
    val maxDay = if (mode == DatePickerMode.DATE && maxComp != null) maxComp.get(Calendar.DAY_OF_MONTH) else 31

    val yearUpper = minOf(currentYear + 1, maxYear)
    val years = remember(maxYear) { ((currentYear - 10)..yearUpper).toList() }

    val sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = false)

    val title = when (mode) {
        DatePickerMode.DATE -> "选择日期"
        DatePickerMode.MONTH -> "选择月份"
        DatePickerMode.YEAR -> "选择年份"
    }

    fun daysInMonth(year: Int, month: Int): Int {
        val c = Calendar.getInstance()
        c.set(Calendar.YEAR, year)
        c.set(Calendar.MONTH, month - 1)
        return c.getActualMaximum(Calendar.DAY_OF_MONTH)
    }

    fun commit() {
        val y = selectedYear
        val m = selectedMonth
        val c = Calendar.getInstance()
        when (mode) {
            DatePickerMode.DATE -> {
                var d = selectedDay
                val maxD = daysInMonth(y, m)
                if (d > maxD) d = maxD
                c.set(y, m - 1, d, 0, 0, 0)
            }
            DatePickerMode.MONTH -> c.set(y, m - 1, 1, 0, 0, 0)
            DatePickerMode.YEAR -> c.set(y, Calendar.JANUARY, 1, 0, 0, 0)
        }
        c.set(Calendar.MILLISECOND, 0)
        onConfirm(c.timeInMillis)
    }

    ModalBottomSheet(
        onDismissRequest = onDismiss,
        sheetState = sheetState,
        containerColor = AppColor.bgCard,
        shape = RoundedCornerShape(topStart = AppRadius.lg, topEnd = AppRadius.lg)
    ) {
        Column(modifier = Modifier.fillMaxWidth().padding(bottom = AppSpace.sm)) {
            // ---- 工具栏（高 44：取消 sizeSm 次色 / 标题 sizeMd Semibold / 确定 primary sizeMd Semibold）----
            Row(
                modifier = Modifier.fillMaxWidth().height(44.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                TextButton(
                    onClick = onDismiss,
                    contentPadding = PaddingValues(horizontal = 16.dp, vertical = 0.dp),
                    modifier = Modifier.height(44.dp)
                ) {
                    Text("取消", fontSize = AppFont.sizeSm, color = AppColor.textSecondary)
                }
                Text(
                    title,
                    fontSize = AppFont.sizeMd,
                    fontWeight = FontWeight.SemiBold,
                    color = AppColor.textPrimary,
                    textAlign = TextAlign.Center,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                    modifier = Modifier.weight(1f).padding(horizontal = 4.dp)
                )
                TextButton(
                    onClick = { commit() },
                    contentPadding = PaddingValues(horizontal = 16.dp, vertical = 0.dp),
                    modifier = Modifier.height(44.dp)
                ) {
                    Text("确定", fontSize = AppFont.sizeMd, color = AppColor.primary, fontWeight = FontWeight.SemiBold)
                }
            }
            Box(modifier = Modifier.fillMaxWidth().height(1.dp).background(AppColor.border))

            // ---- 滚轮列（1~3 列，每列 220dp=5×44）----
            val columns = when (mode) {
                DatePickerMode.DATE -> 3
                DatePickerMode.MONTH -> 2
                DatePickerMode.YEAR -> 1
            }
            Row(
                modifier = Modifier.fillMaxWidth().height(220.dp).padding(horizontal = AppSpace.lg),
                horizontalArrangement = Arrangement.spacedBy(AppSpace.md)
            ) {
                // 年列
                WheelColumn(
                    values = years.map { "${it}年" },
                    initialIndex = years.indexOf(selectedYear).coerceAtLeast(0),
                    onIndexChange = {
                        selectedYear = years[it]
                        // 切换年份后若月份/日期越界则修正
                        val monthLimit = if (selectedYear == maxYear) minOf(12, maxMonth) else 12
                        if (selectedMonth > monthLimit) selectedMonth = monthLimit
                        val dim = daysInMonth(selectedYear, selectedMonth)
                        val dayLimit = if (selectedYear == maxYear && selectedMonth == maxMonth) minOf(dim, maxDay) else dim
                        if (selectedDay > dayLimit) selectedDay = dayLimit
                    },
                    modifier = Modifier.weight(1f)
                )
                // 月列（到达最大年份时月份上限=maxMonth）
                if (columns >= 2) {
                    val monthUpper = if (selectedYear == maxYear) minOf(12, maxMonth) else 12
                    WheelColumn(
                        key = "${selectedYear}-m",
                        values = (1..monthUpper).map { "${it}月" },
                        initialIndex = (selectedMonth - 1).coerceIn(0, monthUpper - 1),
                        onIndexChange = {
                            selectedMonth = it + 1
                            val dim = daysInMonth(selectedYear, selectedMonth)
                            val dayLimit = if (selectedYear == maxYear && selectedMonth == maxMonth) minOf(dim, maxDay) else dim
                            if (selectedDay > dayLimit) selectedDay = dayLimit
                        },
                        modifier = Modifier.weight(1f)
                    )
                }
                // 日列（随年/月动态变化；到达最大年月时日期上限=maxDay）
                if (columns == 3) {
                    val dim = daysInMonth(selectedYear, selectedMonth)
                    val dayUpper = if (selectedYear == maxYear && selectedMonth == maxMonth) minOf(dim, maxDay) else dim
                    WheelColumn(
                        key = "${selectedYear}-${selectedMonth}",
                        values = (1..dayUpper).map { "${it}日" },
                        initialIndex = (selectedDay - 1).coerceIn(0, dayUpper - 1),
                        onIndexChange = { selectedDay = it + 1 },
                        modifier = Modifier.weight(1f)
                    )
                }
            }
        }
    }
}

/**
 * 单列滚轮：高 220dp=5 行×44dp，选中行 primary Semibold，其余 textPrimary，
 * 上下 hairline 夹线 + 渐隐遮罩，松手吸附中心整行（与 Picker #33 同构）。
 */
@OptIn(ExperimentalFoundationApi::class)
@Composable
private fun WheelColumn(
    values: List<String>,
    initialIndex: Int,
    onIndexChange: (Int) -> Unit,
    modifier: Modifier = Modifier,
    key: String? = null
) {
    val rowHeightDp = 44.dp
    val wheelHeight = 220.dp
    val rowHeightPx = with(LocalDensity.current) { rowHeightDp.toPx() }

    val listState = rememberLazyListState()

    // 中心行判定（与 Picker #33 同模型：scroll 整格模型）
    val selectedIndex by remember(rowHeightPx, values) {
        derivedStateOf {
            if (values.isEmpty()) 0
            else {
                val first = listState.firstVisibleItemIndex
                val os = listState.firstVisibleItemScrollOffset
                (if (os >= rowHeightPx / 2f) first + 1 else first).coerceIn(0, values.lastIndex)
            }
        }
    }

    // 松手吸附兜底：滚动结束未整格则归位
    LaunchedEffect(listState, values, rowHeightPx) {
        snapshotFlow { listState.isScrollInProgress }
            .distinctUntilChanged()
            .collect { inProgress ->
                if (inProgress) return@collect
                val currentScroll =
                    listState.firstVisibleItemIndex * rowHeightPx + listState.firstVisibleItemScrollOffset
                val targetScroll = selectedIndex * rowHeightPx
                if (abs(currentScroll - targetScroll) > 0.5f) {
                    listState.animateScrollToItem(selectedIndex)
                }
            }
    }

    // 选中变化回调
    LaunchedEffect(selectedIndex) {
        onIndexChange(selectedIndex)
    }

    // 初始定位
    LaunchedEffect(key, values, initialIndex) {
        val init = initialIndex.coerceIn(0, (values.size - 1).coerceAtLeast(0))
        if (listState.firstVisibleItemIndex != init) {
            listState.scrollToItem(init)
        }
    }

    Box(modifier = modifier.fillMaxSize()) {
        LazyColumn(
            state = listState,
            contentPadding = PaddingValues(top = 88.dp, bottom = 132.dp),
            flingBehavior = rememberSnapFlingBehavior(
                lazyListState = listState,
                snapPosition = SnapPosition.Center
            ),
            modifier = Modifier.fillMaxSize()
        ) {
            items(count = values.size) { index ->
                val isSelected = index == selectedIndex
                Box(
                    modifier = Modifier.fillMaxWidth().height(rowHeightDp),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = values[index],
                        fontSize = AppFont.sizeMd,
                        fontWeight = if (isSelected) FontWeight.SemiBold else FontWeight.Normal,
                        color = if (isSelected) AppColor.primary else AppColor.textPrimary,
                        textAlign = TextAlign.Center,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )
                }
            }
        }
        // 上下渐隐遮罩
        Box(
            modifier = Modifier.align(Alignment.TopCenter).fillMaxWidth().height(70.dp)
                .background(Brush.verticalGradient(listOf(AppColor.bgCard, Color.Transparent)))
        )
        Box(
            modifier = Modifier.align(Alignment.BottomCenter).fillMaxWidth().height(70.dp)
                .background(Brush.verticalGradient(listOf(Color.Transparent, AppColor.bgCard)))
        )
        // 选中带夹线（中心行上下各 1dp hairline）
        Box(
            modifier = Modifier.align(Alignment.TopCenter).padding(top = 87.5.dp)
                .fillMaxWidth().height(1.dp).background(AppColor.border)
        )
        Box(
            modifier = Modifier.align(Alignment.BottomCenter).padding(bottom = 87.5.dp)
                .fillMaxWidth().height(1.dp).background(AppColor.border)
        )
    }
}
