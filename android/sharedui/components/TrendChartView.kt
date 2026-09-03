package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppFont
import com.zhiqihuayun.foundation.design.AppRadius
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
        modifier = modifier
            .fillMaxWidth()
            .height(140.dp)
            .background(AppColor.bgCard)
    ) {
        if (!hasValue || count == 0) {
            Text(
                text = "暂无数据",
                color = AppColor.textSecondary,
                fontSize = AppFont.sizeSm,
                textAlign = TextAlign.Center,
                modifier = Modifier.align(Alignment.Center)
            )
        } else {
            val maxVal = max(
                expensePoints.maxOfOrNull { it.amount } ?: 0.0,
                incomePoints.maxOfOrNull { it.amount } ?: 0.0
            ).coerceAtLeast(1.0)

            Canvas(modifier = Modifier.fillMaxWidth().height(140.dp)) {
                val canvasW = size.width
                val canvasH = size.height
                val padLeft = 40f
                val padBottom = 24f
                val padTop = 8f
                val padRight = 8f
                val chartW = canvasW - padLeft - padRight
                val chartH = canvasH - padTop - padBottom

                // ── 网格线（4 条横线）──
                val gridCount = 4
                for (i in 0..gridCount) {
                    val y = padTop + chartH * i / gridCount
                    drawLine(
                        color = AppColor.border,
                        start = Offset(padLeft, y),
                        end = Offset(canvasW - padRight, y),
                        strokeWidth = 0.5f
                    )
                }

                // ── 支出折线（红）──
                if (expensePoints.isNotEmpty()) {
                    val stepX = if (count > 1) chartW / (count - 1) else 0f
                    val path = Path()
                    expensePoints.forEachIndexed { i, pt ->
                        val x = padLeft + i * stepX
                        val y = padTop + chartH * (1 - (pt.amount / maxVal).toFloat())
                        if (i == 0) path.moveTo(x, y) else path.lineTo(x, y)
                    }
                    drawPath(path = path, color = AppColor.expense, style = Stroke(width = 4f))
                    // 圆点
                    expensePoints.forEachIndexed { i, pt ->
                        if (count <= 14) {
                            val x = padLeft + i * stepX
                            val y = padTop + chartH * (1 - (pt.amount / maxVal).toFloat())
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
                        val x = padLeft + i * stepX
                        val y = padTop + chartH * (1 - (pt.amount / maxVal).toFloat())
                        if (i == 0) path.moveTo(x, y) else path.lineTo(x, y)
                    }
                    drawPath(path = path, color = AppColor.primary, style = Stroke(width = 4f))
                    // 圆点
                    incomePoints.forEachIndexed { i, pt ->
                        if (count <= 14) {
                            val x = padLeft + i * stepX
                            val y = padTop + chartH * (1 - (pt.amount / maxVal).toFloat())
                            drawCircle(color = AppColor.primary, radius = 5f, center = Offset(x, y))
                            drawCircle(color = AppColor.bgCard, radius = 2f, center = Offset(x, y))
                        }
                    }
                }
            }

            // ── Y 轴标签 ──
            Row(
                modifier = Modifier.fillMaxWidth().height(140.dp),
                verticalAlignment = Alignment.Top
            ) {
                Column(
                    modifier = Modifier.width(40.dp).padding(top = 0.dp),
                    horizontalAlignment = Alignment.End,
                    verticalArrangement = Arrangement.spacedBy(0.dp)
                ) {
                    val maxValInt = maxVal.toInt()
                    val gridCount = 4
                    val stepVal = maxValInt / gridCount
                    for (i in 0..gridCount) {
                        val v = maxValInt - i * stepVal
                        Text(
                            text = "$v",
                            color = AppColor.textSecondary,
                            fontSize = AppFont.sizeXs,
                            textAlign = TextAlign.End,
                            modifier = Modifier.height((116f / gridCount).dp)
                        )
                    }
                }
                Spacer(modifier = Modifier.width(0.dp))
            }

            // ── X 轴标签 ──
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .align(Alignment.BottomCenter)
                    .padding(start = 40.dp, end = 8.dp),
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                labels.take(8).forEach { label ->
                    Text(
                        text = label,
                        color = AppColor.textSecondary,
                        fontSize = AppFont.sizeXs,
                        textAlign = TextAlign.Center
                    )
                }
            }
        }
    }
}
