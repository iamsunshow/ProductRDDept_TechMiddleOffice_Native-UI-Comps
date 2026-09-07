// Badge 徽标组件（Compose 版，对齐 iOS BadgeView）。
//
// 展示在宿主内容右上角的数字/圆点/文本提醒，用于未读数、新消息、状态标识。
// 形态由 count / text / dot 三参数自动推断，支持 maxCount 截断、color 主题色、offset 锚点偏移。
//
// 形态自动选择（与设计规格 badge-design-spec.html 一致）：
// - dot=true → 圆点 8×8
// - text 非空 → 文本胶囊（height 18，paddingH 8）
// - count 在 1..maxCount → 数字胶囊（minWidth 18，height 18，paddingH 6）
// - count > maxCount → 「maxCount+」胶囊
// - count==0 或 (count==null && text==null && dot==false) → 不渲染

package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.IntOffset
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.zhiqihuayun.foundation.design.AppColor
import kotlin.math.roundToInt

/**
 * 徽标组件：包裹宿主 content，在其右上角渲染数字/圆点/文本徽标。
 *
 * @param count 数字徽标：null=圆点形态（需 dot 配合）；0=不显示；≥1=数字；>maxCount 显示 maxCount+
 * @param text 自定义文本徽标（与 count 二选一，text 优先）
 * @param maxCount 数字上限，超过显示「maxCount+」，默认 99
 * @param color 徽标背景色，默认 danger 红（AppColor.error）
 * @param dot 强制圆点形态（忽略 count/text）
 * @param offset 锚点偏移（像素），null 时使用默认（右上角外凸 4dp，按屏幕密度转 px）
 * @param content 宿主内容
 */
@Composable
fun Badge(
    count: Int? = null,
    text: String? = null,
    maxCount: Int = 99,
    color: Color = AppColor.error,
    dot: Boolean = false,
    offset: Offset? = null,
    content: @Composable () -> Unit
) {
    val mode = resolveBadgeMode(count, text, maxCount, dot)
    Box {
        content()
        if (mode != BadgeMode.Hidden) {
            val density = LocalDensity.current
            // 默认偏移：右上角外凸 4dp（CSS 语义 top:-4 / right:-4），按密度转像素。
            val defaultOffset = with(density) { Offset(4.dp.toPx(), (-4.dp).toPx()) }
            val off = offset ?: defaultOffset
            Box(
                modifier = Modifier
                    .align(Alignment.TopEnd)
                    .offset { IntOffset(off.x.roundToInt(), off.y.roundToInt()) }
            ) {
                when (mode) {
                    BadgeMode.Dot -> DotBadge(color = color)
                    is BadgeMode.Number -> BadgePill(
                        text = mode.text,
                        minWidth = 18.dp,
                        paddingH = 6.dp,
                        color = color
                    )
                    is BadgeMode.Text -> BadgePill(
                        text = mode.text,
                        minWidth = null,
                        paddingH = 8.dp,
                        color = color
                    )
                    BadgeMode.Hidden -> Unit
                }
            }
        }
    }
}

// MARK: - 形态解析

/** 徽标形态。 */
private sealed interface BadgeMode {
    object Hidden : BadgeMode
    object Dot : BadgeMode
    data class Number(val text: String) : BadgeMode
    data class Text(val text: String) : BadgeMode
}

/** 根据 count/text/dot/maxCount 推断徽标形态。 */
private fun resolveBadgeMode(
    count: Int?,
    text: String?,
    maxCount: Int,
    dot: Boolean
): BadgeMode {
    if (dot) return BadgeMode.Dot
    if (!text.isNullOrEmpty()) return BadgeMode.Text(text)
    if (count != null) {
        if (count <= 0) return BadgeMode.Hidden
        if (count <= maxCount) return BadgeMode.Number(count.toString())
        return BadgeMode.Number("$maxCount+")
    }
    // count==null && text==null && dot==false
    return BadgeMode.Hidden
}

// MARK: - 徽标本体

/** 圆点徽标：8×8 圆形。 */
@Composable
private fun DotBadge(color: Color) {
    Box(
        modifier = Modifier
            .size(8.dp)
            .background(color, CircleShape)
    )
}

/** 胶囊徽标：圆角背景 + 居中文本。 */
@Composable
private fun BadgePill(
    text: String,
    minWidth: androidx.compose.ui.unit.Dp?,
    paddingH: androidx.compose.ui.unit.Dp,
    color: Color
) {
    Row(
        modifier = Modifier
            .height(18.dp)
            .then(if (minWidth != null) Modifier.widthIn(min = minWidth) else Modifier)
            .background(color, RoundedCornerShape(percent = 50))
            .padding(horizontal = paddingH),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.Center
    ) {
        Text(
            text = text,
            color = Color.White,
            fontSize = 11.sp,
            fontWeight = FontWeight.SemiBold
        )
    }
}
