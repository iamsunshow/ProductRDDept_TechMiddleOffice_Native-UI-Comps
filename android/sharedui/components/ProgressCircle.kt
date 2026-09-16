package com.zhiqihuayun.sharedui.components

import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.size
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.rotate
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppFont

/** ProgressCircle 视觉 token：与 iOS ProgressCircleView / design-spec §02 对齐。 */
private object ProgressCircleTokens {
    /** 默认尺寸（dp；64dp = Apple Watch 活动环 64 惯例）。 */
    val defaultSize = 64.dp
    /** 轨道 stroke 宽度（dp；size × 0.094 = 64 → 6dp）。 */
    fun strokeWidth(size: Dp): Dp = size * 0.094f
    /** 中心文案 inset（dp；轨道内留 8dp 让文案居中）。 */
    val centerTextInset = 8.dp
    /** 过渡时长（ms；与 iOS CABasicAnimation duration 一致）。 */
    const val animationDurationMs = 300
}

/**
 * 环形进度条（数据驱动 + 阈值三态颜色 + 可选中心文案 + 0.3s 过渡）。
 *
 * 视觉锚点（与 iOS ProgressCircleView 1:1）：轨道 6dp 圆头线帽 + 默认 64dp + 中心文案
 * sizeMd=16 Semibold textPrimary + primary 16A34A + 阈值切换 warnThreshold=0.8
 * warning F59E0B / dangerThreshold=1.0 error DC2626 + 0.3s ease-out 过渡。
 *
 * @param modifier 宿主修饰。
 * 进度 0~1（必传；超界 clamp 到 [0,1]）。
 * @param size 直径（默认 64dp；可覆盖 32/48/64/96/128）。
 * @param centerText 自定义中心文案（默认显示百分比）。
 * @param warnThreshold warning 阈值（默认 0.8；<warnThreshold 显示 primary）。
 * @param dangerThreshold error 阈值（默认 1.0；≥warnThreshold & <dangerThreshold 显示 warning；
 *   ≥dangerThreshold 显示 error）。
 */
@Composable
fun ProgressCircle(
    modifier: Modifier = Modifier,
    value: Float,
    size: Dp = ProgressCircleTokens.defaultSize,
    centerText: String? = null,
    warnThreshold: Float = 0.8f,
    dangerThreshold: Float = 1.0f,
) {
    val clamped = value.coerceIn(0f, 1f)
    // 颜色阈值动画（0.3s tween）
    val targetColor = when {
        clamped >= dangerThreshold -> AppColor.error
        clamped >= warnThreshold -> AppColor.warning
        else -> AppColor.primary
    }
    val animatedColor by animateColorAsState(
        targetValue = targetColor,
        animationSpec = tween(ProgressCircleTokens.animationDurationMs),
        label = "progressColor",
    )
    // 进度动画（0.3s tween）
    val animatedProgress by animateFloatAsState(
        targetValue = clamped,
        animationSpec = tween(ProgressCircleTokens.animationDurationMs),
        label = "progressValue",
    )
    val strokeWidthDp = ProgressCircleTokens.strokeWidth(size)
    val displayText = centerText ?: "${(clamped * 100).toInt()}%"
    Box(
        modifier = modifier.size(size),
        contentAlignment = Alignment.Center,
    ) {
        Canvas(modifier = Modifier.size(size).rotate(-90f)) {
            val strokePx = strokeWidthDp.toPx()
            val diameter = this.size.minDimension - strokePx
            val topLeft = Offset(strokePx / 2, strokePx / 2)
            val arcSize = Size(diameter, diameter)
            // 轨道（border 灰底铺满 360°）
            drawArc(
                color = AppColor.border,
                startAngle = 0f,
                sweepAngle = 360f,
                useCenter = false,
                topLeft = topLeft,
                size = arcSize,
                style = Stroke(width = strokePx, cap = StrokeCap.Round),
            )
            // 进度环（动画填充 + 阈值色）
            drawArc(
                color = animatedColor,
                startAngle = 0f,
                sweepAngle = 360f * animatedProgress,
                useCenter = false,
                topLeft = topLeft,
                size = arcSize,
                style = Stroke(width = strokePx, cap = StrokeCap.Round),
            )
        }
        // 中心文案（sizeMd=16 Semibold textPrimary）
        Text(
            text = displayText,
            color = AppColor.textPrimary,
            fontSize = AppFont.sizeMd,
            fontWeight = FontWeight.SemiBold,
            modifier = Modifier.size(size - ProgressCircleTokens.centerTextInset * 2),
        )
    }
}