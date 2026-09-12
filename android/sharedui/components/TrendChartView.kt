package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
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
import com.zhiqihuayun.foundation.design.AppSpace
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
        // 内边距对齐 iOS chartView inset(top/bottom=sm, left/right=md)（TrendChartView.swift L48-51）：
        // 数据不紧贴图表边缘（用户反馈点 1）。
        modifier = modifier.fillMaxWidth().height(140.dp).background(AppColor.bgCard)
            .padding(top = AppSpace.sm, bottom = AppSpace.sm, start = AppSpace.md, end = AppSpace.md),
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
            val yAxisWPx = with(density) { 48.dp.toPx() }
            val xLabelHeightPx = with(density) { 24.dp.toPx() }
            val textSizePx = with(density) { AppFont.sizeXs.toPx() }
            // 台账 #58：数据点/圆尺寸/线宽一律 dp→px，禁止裸 px（此前 r5f/2f 在真机≈1.9dp/0.76dp，实心小圆）。
            val pointR = with(density) { 3.dp.toPx() }      // 对齐 iOS circleRadius = 3
            val holeR = with(density) { 1.5.dp.toPx() }     // 对齐 iOS circleHoleRadius = 1.5（白洞）
            val lineWidthPx = with(density) { 2.dp.toPx() } // 对齐 iOS lineWidth = 2
            val gridWidthPx = with(density) { 0.5.dp.toPx() } // 对齐 iOS 默认网格 0.5pt（旧 0.5f=0.5px 亚像素真机不可见，用户反馈点 2）
            val holeColor = androidx.compose.ui.graphics.Color.White // 对齐 iOS circleHoleColor = .white
            val textPaint = remember(textSizePx) {
                android.graphics.Paint(android.graphics.Paint.ANTI_ALIAS_FLAG).apply {
                    color = AppColor.textSecondary.toArgb()
                    this.textSize = textSizePx
                }
            }

            // 台账 #58：x 域对齐 iOS（axisMinimum=-0.5, axisMaximum=count-0.5）——
            // 首末数据点距图表左右缘各内缩半个步长，X 轴首标签左半字不再伸入 Y 轴标签列。

            Canvas(modifier = Modifier.fillMaxSize()) {
                val canvasW = size.width
                val canvasH = size.height
                val chartH = canvasH - xLabelHeightPx  // 绘图区域高度（不含 X 轴标签区）
                fun xFor(index: Int): Float =
                    yAxisWPx + (index + 0.5f) / count * (canvasW - yAxisWPx)
                // 对齐 iOS DGCharts 默认 spaceTop/spaceBottom=0.1（leftAxis.axisMinimum=0 + 自动上限留白）：
                // 数据最高点上方、0 值下方各留 10% 空隙，数据不贴图表上下缘（用户反馈点 1）。
                fun yFor(amt: Double): Float =
                    chartH * (1 - ((amt + 0.1 * maxVal) / (1.2 * maxVal)).toFloat())
                val metrics = textPaint.fontMetrics
                val ascent = metrics.ascent
                val descent = metrics.descent

                // ── 网格线（gridCount+1 条横线，横跨数据显示区域，位置按 y 域映射）──
                for (i in 0..gridCount) {
                    val y = yFor(maxVal * i / gridCount)
                    drawLine(
                        color = AppColor.border,
                        start = Offset(yAxisWPx, y),
                        end = Offset(canvasW, y),
                        strokeWidth = gridWidthPx
                    )
                }

                // ── Y 轴标签（右对齐，精确对齐每条网格线 y 坐标）──
                textPaint.textAlign = android.graphics.Paint.Align.RIGHT
                val maxValInt = maxVal.toInt()
                val stepVal = maxValInt / gridCount
                for (i in 0..gridCount) {
                    val v = maxValInt - i * stepVal
                    val gridY = yFor(maxVal * i / gridCount)  // 与网格线同一映射，保持重合
                    // 文字基线居中对齐网格线
                    val textY = gridY - (ascent + descent) / 2f + descent
                    drawIntoCanvas { canvas ->
                        canvas.nativeCanvas.drawText("$v", yAxisWPx - 4f, textY, textPaint)
                    }
                }

                // ── 支出折线（红）──
                if (expensePoints.isNotEmpty()) {
                    val path = Path()
                    expensePoints.forEachIndexed { i, pt ->
                        val x = xFor(i)
                        val y = yFor(pt.amount)
                        if (i == 0) path.moveTo(x, y) else path.lineTo(x, y)
                    }
                    drawPath(path = path, color = AppColor.expense, style = Stroke(width = lineWidthPx))
                    // 空心圆（彩圆填充+白色洞，对齐 iOS circleRadius 3 + hole 1.5/.white）
                    if (count <= 14) {
                        expensePoints.forEachIndexed { i, pt ->
                            val x = xFor(i)
                            val y = yFor(pt.amount)
                            drawCircle(color = AppColor.expense, radius = pointR, center = Offset(x, y))
                            drawCircle(color = holeColor, radius = holeR, center = Offset(x, y))
                        }
                    }
                }

                // ── 收入折线（绿）──
                if (incomePoints.isNotEmpty()) {
                    val path = Path()
                    incomePoints.forEachIndexed { i, pt ->
                        val x = xFor(i)
                        val y = yFor(pt.amount)
                        if (i == 0) path.moveTo(x, y) else path.lineTo(x, y)
                    }
                    drawPath(path = path, color = AppColor.primary, style = Stroke(width = lineWidthPx))
                    // 空心圆
                    if (count <= 14) {
                        incomePoints.forEachIndexed { i, pt ->
                            val x = xFor(i)
                            val y = yFor(pt.amount)
                            drawCircle(color = AppColor.primary, radius = pointR, center = Offset(x, y))
                            drawCircle(color = holeColor, radius = holeR, center = Offset(x, y))
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
                    val x = xFor(dataIdx)
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
