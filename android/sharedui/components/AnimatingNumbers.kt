// AnimatingNumbers 数字动画组件（Compose 版，对齐 iOS AnimatingNumbersView）。
//
// 数值变化时以「逐位滚动」动画展示数字过渡：每位数字是一个竖排 0~9 的定高滚动窗口，
// value 驱动——挂载后等待 delay，再在 duration 内从 0 滚到目标字形。
// length 控制最大位数（位数不足时整数部分前按位补 0），thousands 控制千分位分隔符
// （分隔符静态渲染，不参与滚动）。
//
// 决策（与 design-spec/animating-numbers-design-spec.html 一致）：
// - P1-A 复用 Price 尺寸语言三档：medium = AppFont.sizeLg(18)/窗口高 32、small = sizeSm(14)/24、large = sizeDisplay(32)/48
// - P2-A delay/duration 统一毫秒（默认 300 / 1000，等价 NutUI 的 300ms / 1s）
// - P3-A value 变化时全体从 0 重滚（位数增减不错位、行为可断言）
// - P4-A 千分位分隔符与小数为静态渲染，不参与滚动
//
// 边界（划界见规格第 2 节）：只滚数字，不做货币符号/前后缀/小数位格式化（归 Price #72）。
//
// 可测性语义标签：animating-numbers-root / animating-numbers-digit-N（纯内部 testTag，无视觉契约影响）。

package com.zhiqihuayun.sharedui.components

import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.FastOutSlowInEasing
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.wrapContentHeight
import androidx.compose.material3.LocalTextStyle
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.TextUnit
import androidx.compose.ui.unit.dp
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppFont
import androidx.compose.foundation.shape.RoundedCornerShape
import kotlinx.coroutines.delay as coroutineDelay
import java.math.BigDecimal

/** 数字动画尺寸档位：字号 + 数位窗口高。 */
enum class AnimatingNumbersSize(val fontSize: TextUnit, val cellHeight: Dp) {
    /** 小号：14 / 24。 */
    Small(AppFont.sizeSm, 24.dp),

    /** 中号（默认）：18 / 32（18 恰为 NutUI base-size，窗口高 32 = 交互行基准 48 的 2/3，注释锚定）。 */
    Medium(AppFont.sizeLg, 32.dp),

    /** 大号：32 / 48。 */
    Large(AppFont.sizeDisplay, 48.dp),
}

/** 渲染令牌：一位可滚动数字 / 一个静态分隔符（小数点、千分位逗号、负号）。 */
internal sealed interface AnimatingToken {
    data class Digit(val digit: Int) : AnimatingToken
    data class Separator(val text: String) : AnimatingToken
}

/**
 * 数字动画：value 驱动的逐位滚动数字展示。
 *
 * @param value 结束值（数值驱动；NaN/Infinity 等非法值 fallback 0，不崩溃）
 * @param length 最大展示位数（仅计数字位，不含小数点/千分位分隔符）；0=按实际位数，不足时整数部分前补 0
 * @param delay 等待动画执行时间（毫秒，默认 300）
 * @param duration 动画执行时长（毫秒，默认 1000）
 * @param thousands 是否显示千位分隔符（分隔符静态渲染不滚动）
 * @param size 尺寸档位（字号/窗口高），默认 Medium
 * @param color 数字颜色，默认 textPrimary
 * @param separatorColor 分隔符（小数点/千分位/负号）颜色，默认跟随 color
 * @param backgroundColor 数位背景色（非透明时按 cornerRadius 圆角），默认透明
 * @param cornerRadius 数位背景圆角，默认 4（NutUI 原值）
 * @param modifier 根容器修饰符
 */
@Composable
fun AnimatingNumbers(
    value: Double,
    length: Int = 0,
    delay: Int = 300,
    duration: Int = 1000,
    thousands: Boolean = false,
    size: AnimatingNumbersSize = AnimatingNumbersSize.Medium,
    color: Color = AppColor.textPrimary,
    separatorColor: Color = Color.Unspecified,
    backgroundColor: Color = Color.Transparent,
    cornerRadius: Dp = 4.dp,
    modifier: Modifier = Modifier,
) {
    val tokens = remember(value, length, thousands) { buildAnimatingTokens(value, length, thousands) }
    val sepColor = if (separatorColor == Color.Unspecified) color else separatorColor

    val density = LocalDensity.current
    val cellHeightPx = with(density) { size.cellHeight.toPx() }
    // 等宽数字（FontFeature tnum）下数字宽 ≈ 0.62em，用于锁定数位宽，滚动时不抖动。
    val digitWidth = with(density) { (size.fontSize.toPx() * 0.62f).toDp() }

    // 全局滚动进度 0→1：delay 后由 0 滚到 1，各位位移 = 进度 × 该位数字 × 窗口高。
    val progress = remember { Animatable(0f) }

    // P3-A：value/length/thousands 变化 → 全体从 0 重滚（先归零、再等待 delay、再滚到目标）。
    LaunchedEffect(tokens) {
        progress.snapTo(0f)
        if (delay > 0) coroutineDelay(delay.toLong())
        progress.animateTo(
            targetValue = 1f,
            animationSpec = tween(durationMillis = duration, easing = FastOutSlowInEasing),
        )
    }

    Row(
        modifier = modifier.testTag("animating-numbers-root"),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        tokens.forEachIndexed { index, token ->
            when (token) {
                is AnimatingToken.Separator -> Text(
                    text = token.text,
                    fontSize = size.fontSize,
                    fontWeight = FontWeight.SemiBold,
                    color = sepColor,
                    modifier = Modifier
                        .height(size.cellHeight)
                        .wrapContentHeight(Alignment.CenterVertically),
                )

                is AnimatingToken.Digit -> Box(
                    modifier = Modifier
                        .height(size.cellHeight)
                        .clip(RoundedCornerShape(cornerRadius))
                        .background(backgroundColor),
                ) {
                    Column(
                        modifier = Modifier.graphicsLayer {
                            // 高频动画：draw-phase 直读 state（不触发重组/重排），与 Drag 组件经验一致。
                            translationY = -progress.value * token.digit * cellHeightPx
                        },
                    ) {
                        for (d in 0..9) {
                            Text(
                                text = d.toString(),
                                fontSize = size.fontSize,
                                fontWeight = FontWeight.SemiBold,
                                color = color,
                                textAlign = TextAlign.Center,
                                style = LocalTextStyle.current.copy(fontFeatureSettings = "tnum"),
                                modifier = Modifier
                                    .height(size.cellHeight)
                                    .width(digitWidth)
                                    .wrapContentHeight(Alignment.CenterVertically)
                                    .testTag("animating-numbers-digit-$index"),
                            )
                        }
                    }
                }
            }
        }
    }
}

/**
 * 把数值展开为渲染令牌序列。
 *
 * 规则：
 * - 数值格式化 = BigDecimal 最短表示（88.0 → "88"、88.8 → "88.8"、12345.67 → "12345.67"），非法值 fallback "0"；
 * - length 只计数字位：不足时在整数部分前补 0（value=12、length=4 → 0012）；
 * - thousands 时整数部分每 3 位插一个静态逗号（不计入 length 补位）；
 * - 负号按静态分隔符渲染。
 */
internal fun buildAnimatingTokens(value: Double, length: Int, thousands: Boolean): List<AnimatingToken> {
    val plain = runCatching {
        if (value.isNaN() || value.isInfinite()) "0"
        else BigDecimal.valueOf(value).stripTrailingZeros().toPlainString()
    }.getOrDefault("0")

    val negative = plain.startsWith("-")
    val unsigned = if (negative) plain.substring(1) else plain
    var intPart = unsigned.substringBefore(".")
    val decPart = unsigned.substringAfter(".", "")

    val digitCount = intPart.length + decPart.length
    if (length > digitCount) intPart = "0".repeat(length - digitCount) + intPart

    val tokens = mutableListOf<AnimatingToken>()
    if (negative) tokens += AnimatingToken.Separator("-")

    val intChars = intPart.toCharArray()
    intChars.forEachIndexed { idx, ch ->
        tokens += AnimatingToken.Digit(ch - '0')
        val remaining = intChars.size - idx
        if (thousands && remaining > 1 && remaining % 3 == 1) tokens += AnimatingToken.Separator(",")
    }

    if (decPart.isNotEmpty()) {
        tokens += AnimatingToken.Separator(".")
        decPart.forEach { tokens += AnimatingToken.Digit(it - '0') }
    }
    return tokens
}
