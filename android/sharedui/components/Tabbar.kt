package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.defaultMinSize
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppFont

/**
 * Tabbar 标签栏（ui.tabbar，#19）。
 *
 * 页面底部一级主导航标签条：2-5 项等分（icon 字符 22dp + 文字 12dp），
 * 半受控选中（默认首启用项自管理 + 外部 selectedValue 驱动高亮 + 点击幂等），
 * 角标数字（高 16 圆角全主色白字 12dp，位于图标右上）+ 禁用（40%）+ 单行省略，
 * activeColor 可覆盖（默认主色），栏顶 hairline，栏高 56dp。
 * 对应 iOS：TabbarView(items, selectedValue?, activeColor?, onChange)。
 * 版本：Native-UI-Comps ui-version v1.4.0（本文件为新组件初版，随 demo 徽标 v1.0）。
 */
data class TabBarItem(
    val title: String,
    val value: String,
    val icon: String? = null,
    val badge: Int? = null,
    val disabled: Boolean = false,
)

private object TabbarTokens {
    const val barHeightDp = 56
    val iconFont = AppFont.sizeXl // 22dp
    val titleFont = AppFont.sizeXs // 12dp
    const val iconTitleGapDp = 4
    const val badgeHeightDp = 16
    const val badgeMinWidthDp = 16
    val badgeFont = AppFont.sizeXs
    const val badgeHorizPaddingDp = 3
    const val badgeCornerDp = 8
    // 角标锚点：cell 水平中心 +14 / 上缘距 cell 顶 2（= iOS top=2，中心 y=10）：对齐 spec preview。
    // 注意 align(TopCenter)+offset 的 y 作用于角标上缘，传 2 才是顶 2；旧值 10 使整枚角标下移 8dp。
    const val badgeCenterXOffsetDp = 14
    const val badgeTopOffsetDp = 2
}

@Composable
fun Tabbar(
    items: List<TabBarItem>,
    selectedValue: String? = null,
    activeColor: Color? = null,
    onChange: (String) -> Unit,
    modifier: Modifier = Modifier,
) {
    val firstEnabled = remember(items) { items.firstOrNull { !it.disabled }?.value }
    var internalValue by remember(items) { mutableStateOf(firstEnabled) }
    val current = selectedValue ?: internalValue
    val effColor = activeColor ?: AppColor.primary

    Box(
        modifier = modifier
            .fillMaxWidth()
            .height(TabbarTokens.barHeightDp.dp)
            .background(AppColor.bgCard),
    ) {
        Row(modifier = Modifier.fillMaxSize()) {
            items.forEach { item ->
                val active = !item.disabled && item.value == current
                val enabled = !item.disabled
                val contentAlpha = if (item.disabled) 0.4f else 1f
                Box(
                    modifier = Modifier
                        .weight(1f)
                        .fillMaxHeight()
                        .clickable(enabled = enabled) {
                            if (item.value != current) {
                                if (selectedValue == null) internalValue = item.value
                                onChange(item.value)
                            }
                        },
                    contentAlignment = Alignment.Center,
                ) {
                    Column(
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = if (item.icon != null) {
                            Arrangement.spacedBy(TabbarTokens.iconTitleGapDp.dp)
                        } else {
                            Arrangement.Top
                        },
                        modifier = Modifier.alpha(contentAlpha),
                    ) {
                        if (item.icon != null) {
                            Text(
                                text = item.icon,
                                color = if (active) effColor else AppColor.textSecondary,
                                fontSize = TabbarTokens.iconFont,
                                textAlign = TextAlign.Center,
                            )
                        }
                        Text(
                            text = item.title,
                            color = if (active) effColor else AppColor.textSecondary,
                            fontSize = TabbarTokens.titleFont,
                            fontWeight = if (active) FontWeight.SemiBold else FontWeight.Normal,
                            textAlign = TextAlign.Center,
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis,
                        )
                    }
                    // 角标：cell 水平中心 +14 / 中心垂直 10（顶 2），主色圆角白字
                    if (item.badge != null && item.badge > 0) {
                        Box(
                            modifier = Modifier
                                .align(Alignment.TopCenter)
                                .offset(
                                    x = TabbarTokens.badgeCenterXOffsetDp.dp,
                                    y = TabbarTokens.badgeTopOffsetDp.dp,
                                )
                                .height(TabbarTokens.badgeHeightDp.dp)
                                .clip(RoundedCornerShape(TabbarTokens.badgeCornerDp.dp))
                                .background(AppColor.primary)
                                .defaultMinSize(minWidth = TabbarTokens.badgeMinWidthDp.dp)
                                .padding(horizontal = TabbarTokens.badgeHorizPaddingDp.dp)
                                .alpha(contentAlpha),
                            contentAlignment = Alignment.Center,
                        ) {
                            Text(
                                text = "${item.badge}",
                                color = Color.White,
                                fontSize = TabbarTokens.badgeFont,
                                textAlign = TextAlign.Center,
                                // 行高=字号：去掉默认行高的额外纵向空隙，避免数字在胶囊内视觉偏下
                                lineHeight = TabbarTokens.badgeFont,
                            )
                        }
                    }
                }
            }
        }
        // 栏顶 hairline
        Box(
            modifier = Modifier
                .align(Alignment.TopCenter)
                .fillMaxWidth()
                .height(0.5.dp)
                .background(AppColor.border),
        )
    }
}
