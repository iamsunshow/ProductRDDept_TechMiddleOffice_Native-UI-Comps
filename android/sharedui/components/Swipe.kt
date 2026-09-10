//
//  Swipe.kt
//  SharedUI
//
//  组件 ID：`ui.swipe` ｜ 任务清单 #58 ｜ 操作反馈区第十四件 ｜ TMO 组件库 v1.4.14
//
//  定位：列表项横向滑动露出操作按钮——左右双向滑动露操作，松手自动回弹或展开。
//
//  结构：
//  - SwipeAction（数据结构）：text/color/onClick
//  - SwipeItem（包裹器）：横向滑动容器+主内容+左右操作按钮列表
//
//  契约 @param（与 api.json 100% 对齐）：
//  - SwipeItem: actions(默认[])/leftActions(默认[])/disabled(默认false)/autoClose(默认true)/content slot
//  - SwipeAction: text(必填)/color(primary/danger/warning/default)/onClick(必填)
//
//  设计规格（design-spec/swipe-design-spec.html）：
//  - 操作按钮宽 80dp，高撑满主内容
//  - primary=#16A34A，danger=#DC2626，warning=#F59E0B，default=#6B7280
//  - 滑动动画 250ms tween
//
//  实现（与 iOS SwipeView 1:1）：
//  - 底层操作按钮：绝对定位在左端/右端（bounds 内，被主内容遮挡）
//  - 顶层主内容：offset 整体移动（不含背景，背景由 content slot 决定），移走后露出底层操作按钮
//  - 不硬编码高度（由 content slot 撑高，与 iOS contentView autoresizingMask 一致）
//
//  用法：
//  ```kotlin
//  SwipeItem(
//      actions = listOf(SwipeAction("删除", SwipeActionColor.Danger) { delete() })
//  ) {
//      RealContent()
//  }
//  ```

package com.zhiqihuayun.sharedui.components

import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.gestures.detectHorizontalDragGestures
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.width
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableFloatStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.unit.IntOffset
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import kotlin.math.abs
import kotlin.math.roundToInt

// MARK: - 操作颜色

/** 操作按钮颜色四态（与 design-spec 一致：primary/danger/warning/default）。 */
enum class SwipeActionColor(val color: Color) {
    Primary(Color(0xFF16A34A)),
    Danger(Color(0xFFDC2626)),
    Warning(Color(0xFFF59E0B)),
    Default(Color(0xFF6B7280))
}

// MARK: - 操作数据结构

/** 操作按钮数据结构（text + color + onClick 回调）。 */
data class SwipeAction(
    val text: String,
    val color: SwipeActionColor = SwipeActionColor.Default,
    val onClick: () -> Unit
)

// MARK: - 滑动容器

/**
 * 列表项横向滑动露出操作按钮的包裹器（左右双向）。
 *
 * 实现与 iOS SwipeView 1:1：
 * - 不硬编码高度（由 content slot 撑高，与 iOS contentView autoresizingMask 一致）
 * - 顶层主内容不加 background（由 content slot 决定背景色，与 iOS makeRow.backgroundColor=.white 一致）
 * - 底层操作按钮绝对定位在左端/右端（bounds 内，被主内容遮挡，移走后露出）
 * - 顶层主内容 offset 整体移动，露出底层操作按钮
 */
@Composable
fun SwipeItem(
    actions: List<SwipeAction> = emptyList(),
    leftActions: List<SwipeAction> = emptyList(),
    disabled: Boolean = false,
    autoClose: Boolean = true,
    content: @Composable () -> Unit
) {
    val density = LocalDensity.current
    val actionWidthPx = with(density) { 80.dp.toPx() }

    val leftMaxPx = leftActions.size * actionWidthPx
    val rightMaxPx = actions.size * actionWidthPx

    var offsetX by remember { mutableFloatStateOf(0f) }
    var dragStart by remember { mutableFloatStateOf(0f) }
    var targetX by remember { mutableFloatStateOf(0f) }
    var isAnimating by remember { mutableStateOf(false) }

    val animatedX by animateFloatAsState(
        targetValue = targetX,
        animationSpec = tween(durationMillis = 250),
        label = "swipe-offset"
    )

    BoxWithConstraints(
        modifier = Modifier
            .fillMaxWidth()
            // 不硬编码高度——由 content slot 撑高（与 iOS contentView autoresizingMask 一致）
            .pointerInput(disabled) {
                if (disabled) return@pointerInput
                detectHorizontalDragGestures(
                    onDragStart = { dragStart = offsetX },
                    onDragEnd = {
                        val maxRight = leftMaxPx
                        val maxLeft = -rightMaxPx
                        when {
                            offsetX > 0 && maxRight > 0 -> {
                                targetX = if (offsetX > maxRight * 0.5f) maxRight else 0f
                            }
                            offsetX < 0 && maxLeft < 0 -> {
                                targetX = if (-offsetX > abs(maxLeft) * 0.5f) maxLeft else 0f
                            }
                            else -> targetX = 0f
                        }
                        isAnimating = true
                    }
                ) { _, dragAmount ->
                    val proposed = dragStart + (offsetX - dragStart) + dragAmount
                    val clamped = when {
                        leftMaxPx > 0 && rightMaxPx > 0 -> proposed.coerceIn(-rightMaxPx, leftMaxPx)
                        leftMaxPx > 0 -> proposed.coerceIn(0f, leftMaxPx)
                        rightMaxPx > 0 -> proposed.coerceIn(-rightMaxPx, 0f)
                        else -> 0f
                    }
                    offsetX = clamped
                    targetX = clamped
                    isAnimating = false
                }
            }
    ) {
        val containerWidthPx = with(density) { maxWidth.toPx() }

        // 底层左操作（右滑露出，左对齐绝对定位）
        leftActions.forEachIndexed { i, action ->
            val leftOffset = i * actionWidthPx
            Box(
                modifier = Modifier
                    .offset { IntOffset(leftOffset.roundToInt(), 0) }
                    .width(80.dp)
                    .fillMaxHeight()
                    .background(action.color.color)
                    .pointerInput(action) {
                        detectTapGestures(onTap = {
                            action.onClick()
                            if (autoClose) { targetX = 0f; offsetX = 0f; isAnimating = true }
                        })
                    },
                contentAlignment = Alignment.Center
            ) {
                Text(text = action.text, color = Color.White, fontSize = 16.sp)
            }
        }

        // 底层右操作（左滑露出，右对齐绝对定位，从右到左排列）
        actions.forEachIndexed { i, action ->
            val rightOffset = containerWidthPx - (i + 1) * actionWidthPx
            Box(
                modifier = Modifier
                    .offset { IntOffset(rightOffset.roundToInt(), 0) }
                    .width(80.dp)
                    .fillMaxHeight()
                    .background(action.color.color)
                    .pointerInput(action) {
                        detectTapGestures(onTap = {
                            action.onClick()
                            if (autoClose) { targetX = 0f; offsetX = 0f; isAnimating = true }
                        })
                    },
                contentAlignment = Alignment.Center
            ) {
                Text(text = action.text, color = Color.White, fontSize = 16.sp)
            }
        }

        // 顶层主内容（整体 offset 移动，不加 background——由 content slot 决定背景色）
        val displayX = if (isAnimating) animatedX else offsetX
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .fillMaxHeight()
                .offset { IntOffset(displayX.roundToInt(), 0) }
        ) {
            content()
        }
    }
}
