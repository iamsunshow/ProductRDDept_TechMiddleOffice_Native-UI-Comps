package com.zhiqihuayun.sharedui.components

import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppFont
import com.zhiqihuayun.foundation.design.AppSpace

/** BarChart 视觉 token：与 iOS BarChartView / design-spec §02 对齐。 */
private object BarChartTokens {
    /** 行高（dp；24dp = 16dp 轨道 + 上下 4dp 内衬）。 */
    val rowHeight = 24.dp
    /** 轨道高度（dp；16dp）。 */
    val trackHeight = 16.dp
    /** 圆角（dp；4dp = strokeCap=Round）。 */
    val trackCornerRadius = 4.dp
    /** 类别标签宽（dp；64dp）。 */
    val labelWidth = 64.dp
    /** 数值标签宽（dp；48dp）。 */
    val valueWidth = 48.dp
    /** 过渡时长（ms；与 iOS UIView.animate 0.3s 一致）。 */
    const val animationDurationMs = 300
}

/** 条形图条目（label/value 一对一）。 */
data class BarChartItem(
    val label: String,
    val value: Float,
)

/**
 * 横向条形图（数据驱动 + 阈值三态颜色 + 0.3s 过渡）。
 *
 * 视觉锚点（与 iOS BarChartView 1:1）：白底 bgCard + 行高 24dp + 类别标签 64dp 宽
 * sizeXs=12 textSecondary 右对齐 + 轨道 16dp 高 bgGrayLight=F3F4F6 灰底 + 填充按比例 =
 * (value/maxValue) × 轨道宽 + 圆角 4dp + 数值标签 48dp 宽 sizeSm=14 Semibold textPrimary
 * 左对齐 + 阈值三态颜色（primary/warning/error）+ 0.3s ease-out 过渡。
 *
 * @param modifier 宿主修饰。
 * @param items 条目列表（label/value）。
 * @param warnThreshold warning 阈值（默认 0.8；value/maxValue ≥ warnThreshold 显示 warning）。
 * @param dangerThreshold error 阈值（默认 1.0；≥ 1.0 显示 error）。
 * @param maxValue 自定义 max（默认 = max(items.value)）。
 */
@Composable
fun BarChart(
    modifier: Modifier = Modifier,
    items: List<BarChartItem>,
    warnThreshold: Float = 0.8f,
    dangerThreshold: Float = 1.0f,
    maxValue: Float? = null,
) {
    if (items.isEmpty()) return
    val m = maxValue ?: items.maxOf { it.value }
    Column(
        modifier = modifier.fillMaxWidth(),
        verticalArrangement = Arrangement.spacedBy(AppSpace.md),
    ) {
        items.forEach { item ->
            BarChartRow(
                item = item,
                maxValue = m,
                warnThreshold = warnThreshold,
                dangerThreshold = dangerThreshold,
            )
        }
    }
}

/** 单行条形（label + 轨道 + 数值）。 */
@Composable
private fun BarChartRow(
    item: BarChartItem,
    maxValue: Float,
    warnThreshold: Float,
    dangerThreshold: Float,
) {
    val ratio = if (maxValue > 0f) (item.value / maxValue).coerceIn(0f, 1f) else 0f
    // 填充颜色阈值动画
    val targetColor = when {
        ratio >= dangerThreshold -> AppColor.error
        ratio >= warnThreshold -> AppColor.warning
        else -> AppColor.primary
    }
    val animatedColor by animateColorAsState(
        targetValue = targetColor,
        animationSpec = tween(BarChartTokens.animationDurationMs),
        label = "barFillColor",
    )
    // 填充宽度动画（0 → ratio）
    val animatedRatio by animateFloatAsState(
        targetValue = ratio,
        animationSpec = tween(BarChartTokens.animationDurationMs),
        label = "barFillWidth",
    )
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .height(BarChartTokens.rowHeight),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        // label（64dp 宽 sizeXs=12 textSecondary 右对齐）
        Text(
            text = item.label,
            color = AppColor.textSecondary,
            fontSize = AppFont.sizeXs,
            textAlign = TextAlign.End,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis,
            modifier = Modifier.width(BarChartTokens.labelWidth),
        )
        // 轨道（bgGrayLight 灰底铺满）
        Box(
            modifier = Modifier
                .weight(1f)
                .height(BarChartTokens.trackHeight)
                .padding(horizontal = AppSpace.sm)
                .clip(RoundedCornerShape(BarChartTokens.trackCornerRadius))
                .background(AppColor.bgGrayLight),
        ) {
            // 填充（按比例 + 阈值色 + 圆角 4dp + 0.3s 动画）
            Box(
                modifier = Modifier
                    .fillMaxHeight()
                    .fillMaxWidth(animatedRatio)
                    .clip(RoundedCornerShape(BarChartTokens.trackCornerRadius))
                    .background(animatedColor),
            )
        }
        // value（48dp 宽 sizeSm=14 Semibold textPrimary 左对齐）
        Text(
            text = "¥${item.value.toInt()}",
            color = AppColor.textPrimary,
            fontSize = AppFont.sizeSm,
            fontWeight = FontWeight.SemiBold,
            textAlign = TextAlign.Start,
            maxLines = 1,
            modifier = Modifier.width(BarChartTokens.valueWidth),
        )
    }
}