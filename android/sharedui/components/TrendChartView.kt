package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.drawscope.drawIntoCanvas
import androidx.compose.ui.graphics.nativeCanvas
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppFont
import kotlin.math.max

/**
 * 趋势折线图数据点。
 *
 * @param label X 轴标签（如 "1 月"）
 * @param amount 数值
 */
data class ChartPoint(
    val label: String,
    val amount: Double
)

/**
 * 双色折线图 Composable（对标 iOS TrendChartView）。
 *
 * 支出红色折线 + 收入绿色折线，含 Y 轴刻度、X 轴标签、网格线、空态。
 * 双端 1:1 对齐。
 *
 * 布局：单 Canvas 统一绘制网格线+Y轴标签+折线+圆点+X轴标签，
 * 精确对齐坐标，消除叠加覆盖问题。
 *
 * @param expensePoints 支出趋势点
 * @param incomePoints 收入趋势点（与支出同标签轴）
 * @param modifier 布局修饰符
 */
@Composable
fun TrendChartView(
    expensePoints: List<ChartPoint>,
    incomePoints: List<ChartPoint>,
    modifier: Modifier = Modifier
) {
    val labels = if (expensePoints.isNotEmpty()) expensePoints.map { it.label }
                 else incomePoints.map { it.label }
    val count = labels.size
    val hasValue = expensePoints.any { it.amount > 0 } || incomePoints.any { it.amount > 0 }

    Box(
        modifier = modifier.fillMaxWidth().height(140.dp).background(AppColor.bgCard),
        contentAlignment = Alignment.Center
    ) {
        if (!hasValue || count == 0) {
            Text(
                text = "暂无数据",
                color = AppColor.textSecondary,
                fontSize = AppFont.sizeSm,
                textAlign = TextAlign.Center
            )
        } else {
            val maxVal = max(
                expensePoints.maxOfOrNull { it.amount } ?: 0.0,
                incomePoints.maxOfOrNull { it.amount } ?: 0.0
            ).coerceAtLeast(1.0)

            val gridCount = 4
            val density = LocalDensity.current
            val yAxisWPx = with(density) { 40.dp.toPx() }
            val xLabelHeightPx = with(density) { 24.dp.toPx() }
            val textSizePx = with(density) { AppFont.sizeXs.toPx() }
            val textPaint = remember(textSizePx) {
                android.graphics.Paint(android.graphics.Paint.ANTI_ALIAS_FLAG).apply {
                    color = AppColor.textSecondary.toArgb()
                    this.textSize = textSizePx
                }
            }

            Canvas(modifier = Modifier.fillMaxSize()) {
                val canvasW = size.width
                val canvasH = size.height
                val chartW = canvasW - yAxisWPx
                val chartH = canvasH - xLabelHeightPx  // 绘图区域高度（不含 X 轴标签区）
                val metrics = textPaint.fontMetrics
                val ascent = metrics.ascent
                val descent = metrics.descent

                // ── 网格线（gridCount+1 条横线，横跨数据显示区域）──
                for (i in 0..gridCount) {
                    val y = chartH * i / gridCount
                    drawLine(
                        color = AppColor.border,
                        start = Offset(yAxisWPx, y),
                        end = Offset(canvasW, y),
                        strokeWidth = 0.5f
                    )
                }

                // ── Y 轴标签（右对齐，精确对齐每条网格线 y 坐标）──
                textPaint.textAlign = android.graphics.Paint.Align.RIGHT
                val maxValInt = maxVal.toInt()
                val stepVal = maxValInt / gridCount
                for (i in 0..gridCount) {
                    val v = maxValInt - i * stepVal
                    val gridY = chartH * i / gridCount
                    // 文字基线居中对齐网格线
                    val textY = gridY - (ascent + descent) / 2f + descent
                    drawIntoCanvas { canvas ->
                        canvas.nativeCanvas.drawText("$v", yAxisWPx - 4f, textY, textPaint)
                    }
                }

                // ── 支出折线（红）──
                if (expensePoints.isNotEmpty()) {
                    val stepX = if (count > 1) chartW / (count - 1) else 0f
                    val path = Path()
                    expensePoints.forEachIndexed { i, pt ->
                        val x = yAxisWPx + if (count > 1) i * stepX else chartW / 2
                        val y = chartH * (1 - (pt.amount / maxVal).toFloat())
                        if (i == 0) path.moveTo(x, y) else path.lineTo(x, y)
                    }
                    drawPath(path = path, color = AppColor.expense, style = Stroke(width = 4f))
                    // 圆点（外圈彩色+内圈背景色=空心圆，与 iOS 一致）
                    if (count <= 14) {
                        expensePoints.forEachIndexed { i, pt ->
                            val x = yAxisWPx + if (count > 1) i * stepX else chartW / 2
                            val y = chartH * (1 - (pt.amount / maxVal).toFloat())
                            drawCircle(color = AppColor.expense, radius = 5f, center = Offset(x, y))
                            drawCircle(color = AppColor.bgCard, radius = 2f, center = Offset(x, y))
                        }
                    }
                }

                // ── 收入折线（绿）──
                if (incomePoints.isNotEmpty()) {
                    val stepX = if (count > 1) chartW / (count - 1) else 0f
                    val path = Path()
                    incomePoints.forEachIndexed { i, pt ->
                        val x = yAxisWPx + if (count > 1) i * stepX else chartW / 2
                        val y = chartH * (1 - (pt.amount / maxVal).toFloat())
                        if (i == 0) path.moveTo(x, y) else path.lineTo(x, y)
                    }
                    drawPath(path = path, color = AppColor.primary, style = Stroke(width = 4f))
                    // 圆点
                    if (count <= 14) {
                        incomePoints.forEachIndexed { i, pt ->
                            val x = yAxisWPx + if (count > 1) i * stepX else chartW / 2
                            val y = chartH * (1 - (pt.amount / maxVal).toFloat())
                            drawCircle(color = AppColor.primary, radius = 5f, center = Offset(x, y))
                            drawCircle(color = AppColor.bgCard, radius = 2f, center = Offset(x, y))
                        }
                    }
                }

                // ── X 轴标签（居中对齐数据点 x 坐标，与 iOS Charts labelCount 对齐）──
                textPaint.textAlign = android.graphics.Paint.Align.CENTER
                val displayCount = minOf(count, 8)
                val displayLabels = labels.take(displayCount)
                displayLabels.forEachIndexed { i, label ->
                    // 均匀映射 displayCount 个标签到 count 个数据点的索引
                    val dataIdx = if (displayCount == 1) 0
                                  else i * (count - 1) / (displayCount - 1)
                    val x = if (count > 1) yAxisWPx + dataIdx * (chartW / (count - 1))
                            else yAxisWPx + chartW / 2
                    val labelCenterY = chartH + xLabelHeightPx / 2f
                    val textY = labelCenterY - (ascent + descent) / 2f + descent
                    drawIntoCanvas { canvas ->
                        canvas.nativeCanvas.drawText(label, x, textY, textPaint)
                    }
                }
            }
        }
    }
}
