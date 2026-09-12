package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.gestures.detectHorizontalDragGestures
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.layout.onSizeChanged
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.unit.IntOffset
import androidx.compose.ui.unit.dp
import com.zhiqihuayun.foundation.design.AppColor
import kotlin.math.max
import kotlin.math.min
import kotlin.math.roundToInt

private val SliderTrackHeight = 4.dp
private val SliderThumbSize = 24.dp
private val SliderComponentHeight = 44.dp

/**
 * Slider 滑块（数据录入组件 · ui.slider）：单值连续/分档滑块。
 *
 * 视觉：水平轨道（灰底 + primary 激活段）+ 圆形 thumb 可拖拽；
 * 有 step 时吸附档位，无 step 时连续滑动。
 * 语义：value 受控当前值（valueRange）；onValueChange 拖拽释放回调；
 * disabled 整体 40% 灰不可拖。
 */
@Composable
fun Slider(
    value: Float,
    valueRange: ClosedFloatingPointRange<Float> = 0f..100f,
    steps: Int = 0,
    onValueChange: ((Float) -> Unit)? = null,
    enabled: Boolean = true,
    modifier: Modifier = Modifier
) {
    var trackWidth by remember { mutableStateOf(0f) }
    val density = LocalDensity.current
    val thumbSizePx = with(density) { SliderThumbSize.toPx() }
    val halfThumb = thumbSizePx / 2f
    val effectiveWidth = max(trackWidth - thumbSizePx, 1f)

    val rangeSpan = valueRange.endInclusive - valueRange.start
    val ratio = if (rangeSpan > 0f) ((value - valueRange.start) / rangeSpan).coerceIn(0f, 1f) else 0f
    val thumbOffsetPx = halfThumb + ratio * effectiveWidth

    // step 吸附
    fun snapToStep(raw: Float): Float {
        if (steps <= 0) return raw.coerceIn(valueRange.start, valueRange.endInclusive)
        val stepSize = rangeSpan / (steps + 1)
        val stepped = valueRange.start + ((raw - valueRange.start) / stepSize).roundToInt() * stepSize
        return stepped.coerceIn(valueRange.start, valueRange.endInclusive)
    }

    fun valueFromX(x: Float): Float {
        val r = ((x - halfThumb) / effectiveWidth).coerceIn(0f, 1f)
        return snapToStep(valueRange.start + r * rangeSpan)
    }

    Box(
        modifier = modifier
            .testTag("slider-root")
            .fillMaxWidth()
            .height(SliderComponentHeight)
            .alpha(if (enabled) 1f else 0.4f)
            .onSizeChanged { trackWidth = it.width.toFloat() }
            .pointerInput(enabled, valueRange, steps) {
                if (!enabled) return@pointerInput
                detectTapGestures { offset ->
                    onValueChange?.invoke(snapToStep(valueFromX(offset.x)))
                }
            }
            .pointerInput(enabled, valueRange, steps) {
                if (!enabled) return@pointerInput
                detectHorizontalDragGestures { change, _ ->
                    change.consume()
                    onValueChange?.invoke(snapToStep(valueFromX(change.position.x)))
                }
            }
    ) {
        // 轨道（灰底）——CenterStart 已垂直居中（中心=44/2=22dp，与 thumb 同轴），
        // 禁止再叠加 y offset：旧实现 CenterStart + offset(y=(44-4)/2=20dp) 把轨道
        // 二次下移到 y=40 贴底，thumb 中心在 22 → 圆跑到横线上方（台账 #54）。
        Box(
            modifier = Modifier
                .align(Alignment.CenterStart)
                .testTag("slider-track")
                .fillMaxWidth()
                .height(SliderTrackHeight)
                .clip(RoundedCornerShape(50))
                .background(AppColor.border)
        )

        // 激活段（primary）
        Box(
            modifier = Modifier
                .align(Alignment.CenterStart)
                .testTag("slider-active")
                .offset(x = with(density) { halfThumb.toDp() })
                .size(
                    width = with(density) { (ratio * effectiveWidth).toDp() },
                    height = SliderTrackHeight
                )
                .clip(RoundedCornerShape(50))
                .background(AppColor.primary)
        )

        // Thumb（白色圆 + 阴影）——CenterStart 垂直居中，offset 仅给 x
        Box(
            modifier = Modifier
                .align(Alignment.CenterStart)
                .testTag("slider-thumb")
                .offset {
                    IntOffset(
                        x = (thumbOffsetPx - halfThumb).toInt(),
                        y = 0
                    )
                }
                .shadow(4.dp, CircleShape)
                .size(SliderThumbSize)
                .clip(CircleShape)
                .background(AppColor.bgCard)
        )
    }
}
