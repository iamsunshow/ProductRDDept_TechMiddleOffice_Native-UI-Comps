package com.zhiqihuayun.sharedui.components

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.runtime.snapshotFlow
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppFont
import com.zhiqihuayun.foundation.design.AppRadius
import com.zhiqihuayun.foundation.design.AppSpace
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.collectLatest

/**
 * NoticeBar 公告栏：顶部/内嵌公告/通知栏（操作反馈区 #51，全新立项）。
 *
 * 组件 ID：`ui.notice-bar`（api.json 契约对齐，门禁 A AI 代评通过 2026-09-08，
 * 用户"中间任何询问直接通过"总授权；P1–P4 全 A：双方向 horizontal/vertical +
 * 可关闭 closeable + 左右自定义图标 slot + 页面内嵌占位）。
 *
 * 一期语义（对标 NutUI React NoticeBar + Vant NoticeBar）：
 * - [direction]：horizontal（横向跑马灯，默认）/ vertical（纵向多条轮播）
 * - [text]：单条文本（horizontal 模式）
 * - [list]：多条文本（vertical 模式）
 * - [closeable]：是否可关闭（true=右侧 × 关闭按钮+onClose 回调）
 * - [leftIcon]：左侧图标 slot（null=默认喇叭）
 * - [rightIcon]：右侧图标 slot（null=closeable 时 × 否则空）
 * - [backgroundColor]：背景色（默认 #FFF7ED 警告浅底）
 * - [textColor]：文本色（默认 textPrimary）
 * - [textSize]：文本字号（默认 sizeSm 14sp）
 * - [height]：栏高（默认 40dp）
 * - [speed]：滚动速度 px/s（默认 50）
 * - [delay]：延时启动秒数（默认 1）
 * - [duration]：vertical 模式每条停留时间 ms（默认 1000）
 * - [onClose]：关闭回调
 *
 * 用法：
 * ```kotlin
 * // 基础横向滚动
 * NoticeBar(text = "📢 这是一条公告信息...")
 * // 纵向多条轮播
 * NoticeBar(direction = NoticeBarDirection.VERTICAL, list = listOf("消息 1", "消息 2", "消息 3"))
 * // 可关闭
 * NoticeBar(text = "📢 可关闭公告", closeable = true) { /* 已关闭 */ }
 * ```
 *
 * @param direction 滚动方向（horizontal/vertical）
 * @param text 单条文本（horizontal 模式）
 * @param list 多条文本（vertical 模式）
 * @param closeable 是否可关闭
 * @param leftIcon 左侧图标 slot
 * @param rightIcon 右侧图标 slot
 * @param backgroundColor 背景色
 * @param textColor 文本色
 * @param textSize 文本字号
 * @param height 栏高
 * @param speed 滚动速度 px/s
 * @param delay 延时启动毫秒
 * @param duration vertical 模式停留时间 ms
 * @param onClose 关闭回调
 * @param modifier Modifier
 */
@Composable
fun NoticeBar(
    direction: NoticeBarDirection = NoticeBarDirection.HORIZONTAL,
    text: String = "",
    list: List<String> = emptyList(),
    closeable: Boolean = false,
    leftIcon: @Composable (() -> Unit)? = null,
    rightIcon: @Composable (() -> Unit)? = null,
    backgroundColor: Color = Color(0xFFFFF7ED),
    textColor: Color = AppColor.textPrimary,
    textSize: androidx.compose.ui.unit.TextUnit = AppFont.sizeSm,
    height: Dp = 40.dp,
    speed: Float = 50f,
    delay: Long = 1000L,
    duration: Long = 1000L,
    onClose: (() -> Unit)? = null,
    modifier: Modifier = Modifier
) {
    var visible by remember { mutableStateOf(true) }
    var currentIndex by remember { mutableStateOf(0) }

    // vertical 模式自动轮播
    if (direction == NoticeBarDirection.VERTICAL && list.isNotEmpty()) {
        LaunchedEffect(list, duration) {
            kotlinx.coroutines.delay(delay)
            while (true) {
                kotlinx.coroutines.delay(duration)
                currentIndex = (currentIndex + 1) % list.size
            }
        }
    }

    AnimatedVisibility(
        visible = visible,
        enter = fadeIn(),
        exit = fadeOut(),
        modifier = modifier
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .height(height)
                .clip(RoundedCornerShape(AppRadius.sm))
                .background(backgroundColor)
                .padding(horizontal = AppSpace.sm),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(AppSpace.sm)
        ) {
            // 左侧图标
            if (leftIcon != null) {
                leftIcon()
            } else {
                NoticeBarDefaultLeftIcon()
            }

            // 中间内容
            Box(
                modifier = Modifier.weight(1f),
                contentAlignment = Alignment.CenterStart
            ) {
                if (direction == NoticeBarDirection.HORIZONTAL) {
                    NoticeBarHorizontalText(
                        text = text,
                        textColor = textColor,
                        textSize = textSize,
                        speed = speed,
                        delay = delay
                    )
                } else {
                    if (list.isNotEmpty()) {
                        Text(
                            text = list[currentIndex],
                            color = textColor,
                            fontSize = textSize,
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis
                        )
                    }
                }
            }

            // 右侧图标
            if (rightIcon != null) {
                rightIcon()
            } else if (closeable) {
                Text(
                    text = "✕",
                    color = textColor,
                    fontSize = textSize,
                    modifier = Modifier.clickable(
                        interactionSource = remember { MutableInteractionSource() },
                        indication = null
                    ) {
                        visible = false
                        onClose?.invoke()
                    }
                )
            }
        }
    }
}

/**
 * horizontal 模式文本滚动：LaunchedEffect+animateScrollTo 横向滚动。
 */
@Composable
private fun NoticeBarHorizontalText(
    text: String,
    textColor: Color,
    textSize: androidx.compose.ui.unit.TextUnit,
    speed: Float,
    delay: Long
) {
    val scrollState = rememberLazyListState()
    val scope = androidx.compose.runtime.rememberCoroutineScope()

    // 持续滚动
    LaunchedEffect(text, speed, delay) {
        kotlinx.coroutines.delay(delay)
        // 复制内容制造滚动效果
        val itemCount = 3
        var current = 0
        while (true) {
            val target = current + 1
            scrollState.animateScrollToItem(
                index = target,
                scrollOffset = 0
            )
            current = target
            // 速度控制：speed px/s，假设每个字符宽 textSize.value px
            val charCount = text.length + 2 // +2 间隔
            val totalPx = charCount * textSize.value
            val timeMs = (totalPx / speed * 1000).toLong().coerceAtLeast(100)
            kotlinx.coroutines.delay(timeMs)
            if (current > itemCount * 2) {
                scrollState.scrollToItem(0)
                current = 0
            }
        }
    }

    LazyRow(
        state = scrollState,
        horizontalArrangement = Arrangement.spacedBy(AppSpace.sm)
    ) {
        items(3) {
            Text(
                text = text,
                color = textColor,
                fontSize = textSize,
                maxLines = 1
            )
        }
    }
}

/** 默认左侧图标：喇叭符号（文本）。 */
@Composable
private fun NoticeBarDefaultLeftIcon() {
    Canvas(modifier = Modifier.size(20.dp, 20.dp)) {
        val w = size.width
        val h = size.height
        val iconColor = AppColor.textSecondary

        // 喇叭体（梯形）
        val body = Path().apply {
            moveTo(w * 0.15f, h * 0.35f)
            lineTo(w * 0.15f, h * 0.65f)
            lineTo(w * 0.45f, h * 0.65f)
            lineTo(w * 0.75f, h * 0.85f)
            lineTo(w * 0.75f, h * 0.15f)
            lineTo(w * 0.45f, h * 0.35f)
            close()
        }
        drawPath(body, color = iconColor)

        // 声波弧线 1
        drawArc(
            color = iconColor,
            startAngle = -60f,
            sweepAngle = 120f,
            useCenter = false,
            topLeft = androidx.compose.ui.geometry.Offset(w * 0.57f, h * 0.32f),
            size = androidx.compose.ui.geometry.Size(w * 0.36f, h * 0.36f),
            style = Stroke(width = w * 0.075f)
        )

        // 声波弧线 2
        drawArc(
            color = iconColor,
            startAngle = -45f,
            sweepAngle = 90f,
            useCenter = false,
            topLeft = androidx.compose.ui.geometry.Offset(w * 0.47f, h * 0.22f),
            size = androidx.compose.ui.geometry.Size(w * 0.56f, h * 0.56f),
            style = Stroke(width = w * 0.075f)
        )
    }
}

/** NoticeBar 滚动方向。 */
enum class NoticeBarDirection {
    /** 横向跑马灯。 */
    HORIZONTAL,

    /** 纵向多条轮播。 */
    VERTICAL
}

