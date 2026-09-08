package com.zhiqihuayun.sharedui.components

import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.size
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppFont
import com.zhiqihuayun.foundation.design.AppSpace

/**
 * Loading 加载中：全屏/区域遮罩加载指示器（操作反馈区 #50，全新立项）。
 *
 * 组件 ID：`ui.loading`（api.json 契约对齐，门禁 A AI 代评通过 2026-09-08，
 * 用户"中间任何询问直接通过"总授权；P1–P4 全 A：纯加载指示器模式 +
 * 双类型 circular/spinner + 双方向 horizontal/vertical + 不内置遮罩）。
 *
 * 一期语义（对标 NutUI React Loading + Vant Loading）：
 * - [type]：图标类型 circular（环形旋转，默认）/ spinner（5 线跳动）
 * - [direction]：图标+文案排列方向 horizontal（水平，默认）/ vertical（竖向）
 * - [text]：可选文案（null=纯图标）
 * - [color]：图标+文案颜色（默认 textSecondary，可配 primary 等）
 * - [size]：图标尺寸（默认 sizeLg 18dp）
 * - [textSize]：文案字号（默认 sizeSm 14sp）
 * - 不内置遮罩=宿主组合 Overlay #6 做全屏加载（与 NutUI Loading+Overlay 组合模式一致）
 *
 * 用法：
 * ```kotlin
 * // 基础
 * Loading()
 * // 带文案
 * Loading(text = "加载中...", direction = LoadingDirection.VERTICAL)
 * // spinner 类型
 * Loading(type = LoadingType.SPINNER, color = AppColor.primary, size = 32.dp)
 * // 全屏遮罩（宿主组合 Overlay）
 * Overlay(visible = true) { Loading(text = "加载中...", direction = LoadingDirection.VERTICAL) }
 * ```
 *
 * @param type 图标类型（circular/spinner）
 * @param direction 排列方向（horizontal/vertical）
 * @param text 可选文案（null=纯图标）
 * @param color 图标+文案颜色
 * @param size 图标尺寸
 * @param textSize 文案字号
 * @param modifier Modifier
 */
@Composable
fun Loading(
    type: LoadingType = LoadingType.CIRCULAR,
    direction: LoadingDirection = LoadingDirection.HORIZONTAL,
    text: String? = null,
    color: Color = AppColor.textSecondary,
    size: Dp = AppFont.sizeLg.dp,
    textSize: androidx.compose.ui.unit.TextUnit = AppFont.sizeSm,
    modifier: Modifier = Modifier
) {
    val content: @Composable () -> Unit = {
        when (type) {
            LoadingType.CIRCULAR -> CircularProgressIndicator(
                modifier = Modifier.size(size),
                strokeWidth = (size.value / 8).dp.coerceAtLeast(2.dp),
                color = color
            )
            LoadingType.SPINNER -> LoadingSpinner(size = size, color = color)
        }
    }

    if (text == null) {
        Box(modifier = modifier, contentAlignment = Alignment.Center) {
            content()
        }
    } else {
        val arrangement = if (direction == LoadingDirection.HORIZONTAL) {
            Arrangement.Center
        } else {
            Arrangement.Center
        }
        if (direction == LoadingDirection.HORIZONTAL) {
            Row(
                modifier = modifier,
                horizontalArrangement = arrangement,
                verticalAlignment = Alignment.CenterVertically
            ) {
                content()
                Text(
                    text = " $text",
                    color = color,
                    fontSize = textSize
                )
            }
        } else {
            Column(
                modifier = modifier,
                verticalArrangement = arrangement,
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                content()
                Text(
                    text = text,
                    color = color,
                    fontSize = textSize,
                    textAlign = TextAlign.Center
                )
            }
        }
    }
}

/**
 * spinner 类型：5 线交替跳动（与 iOS CAShapeLayer+5 线同构）。
 * 动画：scaleY 0.4↔1，1s ease-in-out infinite，交替延迟 -0.4s~-0s。
 */
@Composable
private fun LoadingSpinner(size: Dp, color: Color) {
    val transition = rememberInfiniteTransition(label = "loading_spinner")
    val lineHeightPx = size.toPx()
    val lineW = (size.value / 6).dp.coerceAtLeast(2.dp).toPx()
    val gap = (size.value / 6).dp.coerceAtLeast(2.dp).toPx()
    val totalW = lineW * 5 + gap * 4

    // 5 线交替延迟，与 iOS 一致：-0.4s, -0.3s, -0.2s, -0.1s, 0s
    val delays = listOf(-400, -300, -200, -100, 0)
    // 5 线高度比例（与 iOS spec 一致：40%, 70%, 100%, 60%, 35%）
    val heightRatios = listOf(0.4f, 0.7f, 1.0f, 0.6f, 0.35f)

    Canvas(modifier = Modifier.size(width = totalW.dp, height = size)) {
        val totalWFloat = lineW * 5 + gap * 4
        repeat(5) { i ->
            val anim by transition.animateFloat(
                initialValue = 0.4f,
                targetValue = 1.0f,
                animationSpec = infiniteRepeatable(
                    animation = tween(durationMillis = 1000, delayMillis = delays[i].coerceAtLeast(0)),
                    repeatMode = RepeatMode.Reverse
                ),
                label = "spinner_line_$i"
            )
            val lineH = lineHeightPx * heightRatios[i] * anim
            val left = i * (lineW + gap)
            drawRoundRect(
                color = color,
                topLeft = Offset(left, (lineHeightPx - lineH) / 2),
                size = Size(lineW, lineH),
                cornerRadius = androidx.compose.ui.geometry.CornerRadius(lineW / 2, lineW / 2)
            )
        }
    }
}

/** Loading 图标类型。 */
enum class LoadingType {
    /** 环形旋转（系统 CircularProgressIndicator）。 */
    CIRCULAR,

    /** 5 线跳动（Canvas 自绘）。 */
    SPINNER
}

/** Loading 排列方向。 */
enum class LoadingDirection {
    /** 水平排列（图标左、文案右）。 */
    HORIZONTAL,

    /** 竖向排列（图标上、文案下）。 */
    VERTICAL
}
