package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.gestures.awaitEachGesture
import androidx.compose.foundation.gestures.awaitFirstDown
import androidx.compose.foundation.gestures.drag
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.input.pointer.positionChange
import androidx.compose.ui.unit.dp
import com.zhiqihuayun.foundation.design.AppColor
import kotlin.math.abs
import kotlin.math.round

/**
 * Range 区间选择（ui.range，#36）——数据录入区全新立项。
 *
 * 横向双钮区间滑块：一条共用轨道 + start/end 两枚滑块（闭区间 start≤end 恒成立、可相等=
 * 零宽单点）、激活段高亮（start 中心~end 中心 primary）、点轨道空段=吸附最近滑块到点击值、
 * 拖动任一端连续调整（step 粒度吸附）、数值 Double 承载=宿主格式化单位展示。
 *
 * 半受控（与 iOS RangeView 同构）：
 * - `value: RangeValue?`=nil 内部自持且初始 [min,max]（「全选=不过滤」语义）；外部赋值
 *   （含 clamp 后）=仅同步回显不触发 onChange；
 * - 点/拖=onChange 连续回调（每次 step 对齐后），宿主回写；
 * - start≤end 硬钳制（滑块不可越过对方）、可相等零宽单点；
 * - min/max 动态改=越界端自动 clamp 并回显（值域级变化=回调一次让宿主可同步）；
 * - disabled=整条灰、不可拖不可点无回调。
 *
 * 视觉锚点：行高 40（整条命中）；轨道高 4 圆角 full，未激活段=textSecondary(alpha 0.3)、
 * 激活段=primary；滑块钮白底圆形 20 + primary 描边 1.5（禁用=textSecondary(alpha 0.4)）；
 * 端点贴边=钮中心贴轨道端点、半钮视觉溢出允许。无壳无刻度无数值气泡=宿主格式化单位（同
 * Checkbox/Radio 无壳先例）。
 *
 * 规格：docs/数据与产物/design-spec/range-design-spec.html（门禁 A，P1–P4 全 A）。
 * 基线：组件库 v1.4.0（2026-09-06，未过 C2/D 不升版）。
 */
data class RangeValue(
    val start: Double,
    val end: Double
)

private const val RANGE_HEIGHT_DP = 40f
private const val TRACK_HEIGHT_DP = 4f
private const val THUMB_DIAMETER_DP = 20f
private const val THUMB_STROKE_DP = 1.5f

/** 拖动目标滑块。 */
private enum class RangeThumb { Start, End }

/** 区间滑轨（宽=宿主填充）。 */
@Composable
fun Range(
    value: RangeValue? = null,
    onValueChange: ((RangeValue) -> Unit)? = null,
    min: Double = 0.0,
    max: Double = 100.0,
    step: Double = 1.0,
    disabled: Boolean = false,
    modifier: Modifier = Modifier
) {
    // 参数断言（注释级，不做运行时抛错）：step > 0 且 step <= (max - min)
    // 半受控：初始=外部 value（已 clamp）或内部自持 [min, max]（全选=不过滤语义）
    var internalValue by remember {
        mutableStateOf(
            if (value != null) clampRange(value, min, max)
            else RangeValue(min.coerceAtMost(max), max)
        )
    }
    // 外部 value 赋值=同步回显（clamp 后）不触发 onChange
    LaunchedEffect(value) {
        if (value != null) {
            internalValue = clampRange(value, min, max)
        }
    }
    // min/max 动态变化：内部越界端自动 clamp 并回显；发生 clamp=回调一次（值域级变化=宿主可同步）
    LaunchedEffect(min, max, step) {
        val clamped = clampRange(internalValue, min, max)
        if (clamped != internalValue) {
            internalValue = clamped
            onValueChange?.invoke(clamped)
        }
    }

    val inactiveColor = AppColor.textSecondary.copy(alpha = 0.3f)
    val activeColor = if (disabled) AppColor.textSecondary.copy(alpha = 0.4f) else AppColor.primary

    Box(
        modifier = modifier
            .fillMaxWidth()
            .height(RANGE_HEIGHT_DP.dp)
            .pointerInput(min, max, step, disabled) {
                if (disabled) return@pointerInput
                fun commit(thumb: RangeThumb, atX: Float, widthPx: Float) {
                    val cur = internalValue
                    val raw = snapToStep(xToValue(atX, widthPx, min, max), min, max, step)
                    val next = when (thumb) {
                        RangeThumb.Start -> RangeValue(raw.coerceAtMost(cur.end), cur.end)
                        RangeThumb.End -> RangeValue(cur.start, raw.coerceAtLeast(cur.start))
                    }
                    if (next != cur) {
                        internalValue = next
                        onValueChange?.invoke(next)
                    }
                }
                fun nearest(atX: Float, widthPx: Float): RangeThumb {
                    val v = snapToStep(xToValue(atX, widthPx, min, max), min, max, step)
                    val cur = internalValue
                    return if (abs(v - cur.start) <= abs(cur.end - v)) RangeThumb.Start else RangeThumb.End
                }
                // 统一手势自旋（同 Material Slider 模式，规避串行 detect* 第二者永不到达的陷阱）：
                // down=吸附最近滑块到点击值并锁定活动钮；拖动=同一钮连续调整（step 对齐后回调）。
                // key 仅放 min/max/step/disabled（不放 value）：拖动 onChange→宿主回写→recompose
                // 若 key 含 value 会每帧取消重启手势 coroutine，拖动即断。
                awaitEachGesture {
                    val down = awaitFirstDown()
                    val w = size.width.toFloat()
                    val thumb = nearest(down.position.x, w)
                    commit(thumb = thumb, atX = down.position.x, widthPx = w)
                    drag(down.id) { change ->
                        // 纵向位移=外层滚动容器主导（列表可滚），不消费不吸附
                        val delta = change.positionChange()
                        if (abs(delta.x) < abs(delta.y)) return@drag
                        change.consume()
                        commit(thumb = thumb, atX = change.position.x, widthPx = w)
                    }
                }
            }
    ) {
        Canvas(Modifier.fillMaxSize()) {
            val trackH = TRACK_HEIGHT_DP.dp.toPx()
            val thumbR = THUMB_DIAMETER_DP.dp.toPx() / 2f
            val centerY = size.height / 2f
            val topY = centerY - trackH / 2f
            // 轨道未激活段（全宽灰底）
            drawRoundRect(
                color = inactiveColor,
                topLeft = Offset(0f, topY),
                size = Size(size.width, trackH),
                cornerRadius = CornerRadius(trackH / 2f)
            )
            // 激活段 start 中心 ~ end 中心（零宽单点=不画）
            val sX = ratioOf(internalValue.start, min, max) * size.width
            val eX = ratioOf(internalValue.end, min, max) * size.width
            if (eX - sX > 0.5f) {
                drawRoundRect(
                    color = activeColor,
                    topLeft = Offset(sX, topY),
                    size = Size(eX - sX, trackH),
                    cornerRadius = CornerRadius(trackH / 2f)
                )
            }
            drawThumb(sX, centerY, thumbR, disabled)
            drawThumb(eX, centerY, thumbR, disabled)
        }
    }
}

private fun androidx.compose.ui.graphics.drawscope.DrawScope.drawThumb(
    centerX: Float,
    centerY: Float,
    radius: Float,
    disabled: Boolean
) {
    drawCircle(
        color = Color.White,
        radius = radius,
        center = Offset(centerX, centerY)
    )
    val strokeColor = if (disabled) AppColor.textSecondary.copy(alpha = 0.4f) else AppColor.primary
    drawCircle(
        color = strokeColor,
        radius = radius,
        center = Offset(centerX, centerY),
        style = Stroke(width = THUMB_STROKE_DP.dp.toPx())
    )
}

/** x 像素 → 值（比例线性，越界 coerce 到 [0,1]）。 */
private fun xToValue(x: Float, widthPx: Float, min: Double, max: Double): Double {
    if (widthPx <= 0f) return min
    val ratio = (x / widthPx).coerceIn(0f, 1f)
    return min + ratio * (max - min)
}

/** 值 → x 像素比例（0~1）。 */
private fun ratioOf(v: Double, min: Double, max: Double): Float {
    val span = max - min
    if (span <= 0.0) return 0f
    return (((v - min) / span).toFloat()).coerceIn(0f, 1f)
}

/** 按 step 对齐到网格并 clamp 值域。 */
private fun snapToStep(v: Double, min: Double, max: Double, step: Double): Double {
    if (step <= 0.0) return v.coerceIn(min, max)
    val grid = min + round((v - min) / step) * step
    return grid.coerceIn(min, max)
}

/** 将区间 clamp 到 [min,max]（clamp 单调不减=保序，start≤end 恒成立）。 */
private fun clampRange(value: RangeValue, min: Double, max: Double): RangeValue {
    val start = value.start.coerceIn(min, max)
    val end = value.end.coerceIn(min, max)
    return RangeValue(start.coerceAtMost(end), end)
}
