package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.PathEffect
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppFont
import com.zhiqihuayun.foundation.design.AppSpace

/**
 * 分割线方向。
 */
enum class DividerDirection { Horizontal, Vertical }

/**
 * 带文本时文本位置。
 */
enum class DividerContentPosition { Left, Center, Right }

/**
 * 分割线 Divider：区隔内容的分割线（水平/垂直 + 实线/虚线 + 可选文本）。
 *
 * 组件 ID：`ui.divider`（api.json 契约对齐，门禁 A 评审通过 2026-09-04）。
 * 命名：Divider，与 api.json id 一致。
 *
 * 支持：
 * - [direction] 方向（Horizontal / Vertical）
 * - [dashed] 虚线样式
 * - [hairline] 细线模式（0.5dp）
 * - [contentPosition] 文本位置（Left / Center / Right）
 * - [text] 内嵌文本（空=纯线条）
 *
 * @param direction 方向（默认 Horizontal）
 * @param dashed 是否虚线（默认 false）
 * @param hairline 是否细线（默认 true，0.5dp）
 * @param contentPosition 文本位置（默认 Center）
 * @param text 内嵌文本（空=纯线条）
 * @param modifier 布局修饰符
 */
@Composable
fun Divider(
    direction: DividerDirection = DividerDirection.Horizontal,
    dashed: Boolean = false,
    hairline: Boolean = true,
    contentPosition: DividerContentPosition = DividerContentPosition.Center,
    text: String = "",
    modifier: Modifier = Modifier
) {
    val lineWidth: Dp = if (hairline) 0.5.dp else 1.dp
    val density = LocalDensity.current
    val dashIntervals = if (dashed) with(density) { floatArrayOf(4.dp.toPx(), 3.dp.toPx()) } else null
    val pathEffect = dashIntervals?.let { PathEffect.dashPathEffect(it) }

    if (direction == DividerDirection.Horizontal) {
        if (text.isEmpty()) {
            // 纯线条
            Canvas(
                modifier = modifier
                    .fillMaxWidth()
                    .height(AppSpace.sm * 2)
            ) {
                val y = size.height / 2
                drawLine(
                    color = AppColor.border,
                    start = Offset(0f, y),
                    end = Offset(size.width, y),
                    strokeWidth = lineWidth.toPx(),
                    pathEffect = pathEffect
                )
            }
        } else {
            // 带文本：左线 + 文本 + 右线
            Row(
                modifier = modifier
                    .fillMaxWidth()
                    .heightIn(min = AppSpace.sm * 2),
                verticalAlignment = Alignment.CenterVertically
            ) {
                // 根据 contentPosition 计算左右线条权重
                val (leftWeight, rightWeight) = when (contentPosition) {
                    DividerContentPosition.Left -> 0.1f to 0.9f
                    DividerContentPosition.Center -> 1f to 1f
                    DividerContentPosition.Right -> 0.9f to 0.1f
                }

                // 左线
                Canvas(modifier = Modifier.weight(leftWeight).fillMaxHeight()) {
                    val y = size.height / 2
                    drawLine(
                        color = AppColor.border,
                        start = Offset(0f, y),
                        end = Offset(size.width, y),
                        strokeWidth = lineWidth.toPx(),
                        pathEffect = pathEffect
                    )
                }

                // 文本
                Text(
                    text = text,
                    color = AppColor.textSecondary,
                    fontSize = AppFont.sizeXs,
                    modifier = Modifier.padding(horizontal = AppSpace.sm)
                )

                // 右线
                Canvas(modifier = Modifier.weight(rightWeight).fillMaxHeight()) {
                    val y = size.height / 2
                    drawLine(
                        color = AppColor.border,
                        start = Offset(0f, y),
                        end = Offset(size.width, y),
                        strokeWidth = lineWidth.toPx(),
                        pathEffect = pathEffect
                    )
                }
            }
        }
    } else {
        // 垂直分割线
        Canvas(
            modifier = modifier
                .width(AppSpace.sm * 2)
                .fillMaxHeight()
        ) {
            val x = size.width / 2
            drawLine(
                color = AppColor.border,
                start = Offset(x, 0f),
                end = Offset(x, size.height),
                strokeWidth = lineWidth.toPx(),
                pathEffect = pathEffect
            )
        }
    }
}
