package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.gestures.awaitEachGesture
import androidx.compose.foundation.gestures.awaitFirstDown
import androidx.compose.foundation.gestures.drag
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.width
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.input.pointer.positionChange
import androidx.compose.ui.unit.dp
import com.zhiqihuayun.foundation.design.AppColor
import kotlin.math.abs
import kotlin.math.cos
import kotlin.math.max
import kotlin.math.sin

/**
 * Rate 评分（ui.rate，#37）——数据录入区全新立项（规格 rate-design-spec.html，门禁 A P1–P4 全 A）。
 *
 * 行内 n 颗自绘五角星整数评分点（默认 5）：
 * - 值=已点亮整星数 Int 0~count（0=未评合法态）；点击第 k 颗=点亮到该颗并回调 k；
 * - 再点当前值同一颗=清空归 0（评价可取消=allowClear 语义）；
 * - 横向滑动=随手指连续点亮/收回（拖出组件左缘=熄灭归 0）、松手一次性定值回调；
 * - 半受控：`value` 可选（nil=内部自持初始 0），外部赋值（含 clamp 0~count）=仅同步回显
 *   不触发 onChange；点/滑定值=onChange 一次性回调、宿主回写；
 * - readonly=只读彩色展示评分、不可交互无回调；disabled=灰星不可交互无回调（与 readonly
 *   并存 disabled 压过）；count 可配（>0）。
 * - 无 label/文案/提交=宿主自理。
 *
 * 视觉锚点（Token 零硬编码原则，锚定规格文档）：星外接圆直径 22dp（=AppFont.sizeXl 基准）、
 * 五角星内凹比 0.382（R_in=R×sin18°/sin54°）、星间距 8dp（=AppSpace.sm）、行高 40dp（整行命中）、
 * 点亮星=primary 填充、未点亮星=textSecondary(alpha0.3) 1.5dp 空心描边、readonly 保色不降、
 * disabled=点亮星 textSecondary(alpha0.4) 灰填 / 未点亮 alpha0.2 描边；组件宽度=wrap content
 * （星与间距总和），不撑满宿主。
 *
 * 手势=Range #36 修复经验：pointerInput key 不含受控 value（防宿主回写触发重启）、单自旋
 * awaitEachGesture 统一点/滑（无双 detector 串行陷阱）；readonly/disabled 不挂手势。
 *
 * 规格：docs/数据与产物/design-spec/rate-design-spec.html（门禁 A，P1–P4 全 A）。
 * 基线：组件库 v1.4.0（2026-09-06，未过 C2/D 不升版）。
 */
private const val RATE_STAR_SIZE_DP = 22f
private const val RATE_GAP_DP = 8f
private const val RATE_ROW_HEIGHT_DP = 40f
private const val RATE_HOLLOW_STROKE_DP = 1.5f
private const val RATE_INNER_RATIO = 0.382f
private const val RATE_TAP_SLOP_PX = 8f

@Composable
fun Rate(
    count: Int = 5,
    value: Int? = null,
    readonly: Boolean = false,
    disabled: Boolean = false,
    onValueChange: ((Int) -> Unit)? = null
) {
    val starCount = max(1, count)
    // 半受控内部亮星数（含点/滑预览）；value 参数变化=外部赋值仅同步回显。
    var filled by remember { mutableIntStateOf(value?.coerceIn(0, starCount) ?: 0) }
    LaunchedEffect(value, starCount) {
        filled = value?.coerceIn(0, starCount) ?: 0
    }
    val totalWidthDp = RATE_STAR_SIZE_DP * starCount + RATE_GAP_DP * (starCount - 1)

    val interact = Modifier
    Box(
        modifier = interact
            .width(totalWidthDp.dp)
            .height(RATE_ROW_HEIGHT_DP.dp)
            .then(
                if (readonly || disabled) {
                    Modifier
                } else {
                    Modifier.pointerInput(starCount, readonly, disabled) {
                        if (readonly || disabled) return@pointerInput
                        val cellPx = (RATE_STAR_SIZE_DP + RATE_GAP_DP).dp.toPx()
                        fun valueAt(xPx: Float): Int {
                            if (xPx < 0f) return 0
                            val idx = (xPx / cellPx).toInt()
                            return if (idx >= starCount) starCount else idx + 1
                        }
                        awaitEachGesture {
                            val down = awaitFirstDown()
                            val pointerId = down.id
                            val prior = filled
                            var moved = false
                            var totalDx = 0f
                            var totalDy = 0f
                            // down 即预览点亮（不回调，松手统一判定）
                            filled = valueAt(down.position.x)
                            // drag() 跟踪移动直至松手（或手势被外层取消）；仅横向位移消费，
                            // 纵向位移不消费=留给外层列表滚动；全程累计两轴位移以便松手判定
                            // 是「滚动顺手滑过本行」（纵向主导=回滚不回调）还是「点/滑选」。
                            drag(pointerId) { change ->
                                val delta = change.positionChange()
                                totalDx += abs(delta.x)
                                totalDy += abs(delta.y)
                                if (abs(delta.x) < abs(delta.y)) {
                                    return@drag
                                }
                                change.consume()
                                moved = true
                                filled = valueAt(change.position.x)
                            }
                            // 纵向主导=列表滚动（本行滚动顺手经过）=回滚不做任何回调
                            if (totalDy > totalDx + RATE_TAP_SLOP_PX) {
                                filled = prior
                            } else {
                                val current = filled
                                // tap（几乎无位移）落在「当前已点亮」的同一颗上=清空归 0（评价可取消）；
                                // 拖动=直接取松手时预览值（可能回到原值=幂等无回调）。
                                val next = if (!moved && current == prior && current > 0) 0 else current
                                if (next != filled) filled = next
                                if (next != prior) onValueChange?.invoke(next)
                            }
                        }
                    }
                }
            )
    ) {
        Canvas(modifier = Modifier.fillMaxSize()) {
            val starPx = RATE_STAR_SIZE_DP.dp.toPx()
            val cellPx = (RATE_STAR_SIZE_DP + RATE_GAP_DP).dp.toPx()
            val strokePx = RATE_HOLLOW_STROKE_DP.dp.toPx()
            val centerY = size.height / 2f
            for (i in 0 until starCount) {
                val on = i < filled
                val centerX = i * cellPx + starPx / 2f
                val star = buildStarPath(centerX, centerY, starPx / 2f)
                when {
                    on && disabled -> drawPath(star, AppColor.textSecondary.copy(alpha = 0.4f))
                    on -> drawPath(star, AppColor.primary)
                    disabled -> drawPath(
                        star,
                        color = AppColor.textSecondary.copy(alpha = 0.2f),
                        style = Stroke(width = strokePx)
                    )
                    else -> drawPath(
                        star,
                        color = AppColor.textSecondary.copy(alpha = 0.3f),
                        style = Stroke(width = strokePx)
                    )
                }
            }
        }
    }
}

/** 五角星 path：外接圆半径 outer、内接圆半径 outer×0.382，起点顶点朝上（-90°）、每步 36°。
 * 与 iOS RateView.swift 同坐标算法（Compose/iOS 的 y 均向下=公式一致）。 */
private fun buildStarPath(cx: Float, cy: Float, outer: Float): Path {
    val inner = outer * RATE_INNER_RATIO
    val path = Path()
    var angleDeg = -90f
    for (k in 0 until 10) {
        val radius = if (k % 2 == 0) outer else inner
        val rad = Math.toRadians(angleDeg.toDouble())
        val x = cx + (radius * cos(rad)).toFloat()
        val y = cy + (radius * sin(rad)).toFloat()
        if (k == 0) path.moveTo(x, y) else path.lineTo(x, y)
        angleDeg += 36f
    }
    path.close()
    return path
}
