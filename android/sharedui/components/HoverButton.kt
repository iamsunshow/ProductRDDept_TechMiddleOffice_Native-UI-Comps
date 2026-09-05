package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppFont
import com.zhiqihuayun.foundation.design.AppSpace

/** 悬浮钮视觉 token：与 iOS `HoverButton.Metrics`、design-spec §02 对齐。 */
private object HoverTokens {
    /** 悬浮钮高度基线（dp；icon-only 圆钮直径 = 胶囊高度 = 40）。 */
    val size = 40.dp
    /** 胶囊水平内边距 = AppSpace.lg（16dp）。 */
    val pillInsetX = AppSpace.lg
    /** icon 与 text 间距 = AppSpace.sm（8dp）。 */
    val iconGap = AppSpace.sm
    /** 默认图标字符（U+271A，零图片依赖）。 */
    const val defaultIcon = "✚"
    /** 圆角 = 高度一半（icon-only 圆钮 40→20；胶囊高 40→20，即 full）。 */
    val corner = 20.dp
}

/**
 * HoverButton 悬浮按钮：页面角落常驻的"单功能悬浮动作钮"。
 *
 * 与悬浮族划界：多入口列表面板 → FixedNav；滚动超阈值回顶 → BackTop；
 * 本组件 = 单钮常驻（无滚动阈值自动显隐）、图标字符 + 可选文本、点击交回 onTap。
 *
 * 形态由内容驱动（P3-A）：text 为空 = icon-only 圆钮（40×40，icon 缺省 "✚"）；
 * text 非空 = 胶囊（高 40，宽 = 内容 + 双侧 padding lg），icon 可缺省=纯文本胶囊。
 * 位置由宿主摆放（组件自身 wrap 内容不撑满父级，宿主用 offset/Box 锚定）。
 *
 * @param modifier 宿主修饰（尺寸/位置/点击命中区域）。
 * @param icon 图标字符（单字符/emoji）；null 且 text 为空时兜底默认 "✚"。
 * @param text 文本；null/空 = icon-only 圆钮形态。
 * @param onTap 点击回调（业务自理动作；一期无涟漪/缩放=组件库悬浮族惯例）。
 */
@Composable
fun HoverButton(
    modifier: Modifier = Modifier,
    icon: String? = null,
    text: String? = null,
    onTap: () -> Unit,
) {
    val hasText = !text.isNullOrBlank()
    val effIcon = if (!icon.isNullOrEmpty()) icon else if (hasText) null else HoverTokens.defaultIcon
    val shape = RoundedCornerShape(HoverTokens.corner)
    val inner: Modifier = if (hasText) {
        Modifier.height(HoverTokens.size).padding(horizontal = HoverTokens.pillInsetX)
    } else {
        Modifier.size(HoverTokens.size)
    }
    Box(
        modifier = modifier
            .clip(shape)
            .background(AppColor.primary)
            .clickable(
                interactionSource = remember { MutableInteractionSource() },
                indication = null,
            ) { onTap() },
        contentAlignment = Alignment.Center,
    ) {
        Row(
            modifier = inner,
            verticalAlignment = Alignment.CenterVertically,
            // icon-only：行被强制 40×40，内容需水平居中（Arrangement.Start 会把 ✚ 顶到左侧=未水平居中）；
            // pill：icon+text 中间隔 spacing；纯文本胶囊内容自带 padding 居中即可。
            horizontalArrangement = when {
                hasText && effIcon != null -> Arrangement.spacedBy(HoverTokens.iconGap)
                effIcon != null && !hasText -> Arrangement.Center
                else -> Arrangement.Start
            },
        ) {
            if (effIcon != null) {
                Text(
                    text = effIcon,
                    color = Color.White,
                    fontSize = AppFont.sizeLg,
                    fontWeight = FontWeight.Bold,
                )
            }
            if (hasText && text != null) {
                Text(
                    text = text,
                    color = Color.White,
                    fontSize = AppFont.sizeSm,
                )
            }
        }
    }
}
