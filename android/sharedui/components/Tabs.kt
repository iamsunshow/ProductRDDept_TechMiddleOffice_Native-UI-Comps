package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppFont

/**
 * Tabs 选项卡（ui.tabs，#20）。
 *
 * 页内顶部页签条：等分（2-5 项，文字 Sm 14dp 单行省略），半受控选中
 * （默认首启用项自管理 + 外部 selectedValue 驱动高亮 + 点击幂等），
 * 激活项底部 2dp 指示线（宽=当前项整宽，激活色覆盖默认主色）+ 禁用（40%）。
 * 条高 44dp；内容面板由宿主渲染，指示线即分界，不另加 hairline。
 * 对应 iOS：TabsView(items, selectedValue?, activeColor?, onChange)。
 * 版本：Native-UI-Comps ui-version v1.4.0（本文件为新组件初版，随 demo 徽标 v1.0）。
 */
data class TabItem(
    val title: String,
    val value: String,
    val disabled: Boolean = false,
)

private object TabsTokens {
    const val barHeightDp = 44
    val labelFont = AppFont.sizeSm // 14dp
    const val indicatorHeightDp = 2
    // 指示线宽度 = 当前项整宽（等分格宽），激活项底部 2dp 激活色
}

@Composable
fun Tabs(
    items: List<TabItem>,
    selectedValue: String? = null,
    activeColor: Color? = null,
    onChange: (String) -> Unit,
    modifier: Modifier = Modifier,
) {
    val firstEnabled = remember(items) { items.firstOrNull { !it.disabled }?.value }
    var internalValue by remember(items) { mutableStateOf(firstEnabled) }
    val current = selectedValue ?: internalValue
    val effColor = activeColor ?: AppColor.primary

    Row(
        modifier = modifier
            .fillMaxWidth()
            .height(TabsTokens.barHeightDp.dp),
    ) {
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
                Text(
                    text = item.title,
                    color = if (active) effColor else AppColor.textSecondary,
                    fontSize = TabsTokens.labelFont,
                    fontWeight = if (active) FontWeight.SemiBold else FontWeight.Normal,
                    textAlign = TextAlign.Center,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                    modifier = Modifier.alpha(contentAlpha),
                )
                // 底部指示线：整项宽，激活项激活色
                Box(
                    modifier = Modifier
                        .align(Alignment.BottomCenter)
                        .fillMaxWidth()
                        .height(TabsTokens.indicatorHeightDp.dp)
                        .background(if (active) effColor else Color.Transparent),
                )
            }
        }
    }
}
