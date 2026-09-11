// Segmented 分段选择器组件（Compose 版，对齐 iOS SegmentedView）。
//
// 胶囊式分段控件：等分选项横向排列，选中项填充背景色，圆角轨道。
// 泛化自 SegmentControl：支持 fillMaxWidth / 自定义宽度 / 禁用项。

package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.RectangleShape
import androidx.compose.ui.graphics.Shape
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppFont
import com.zhiqihuayun.foundation.design.AppRadius

/**
 * 分段选择器项。
 *
 * @param label 选项文案
 * @param enabled 是否可点击，默认 true
 */
data class SegmentedItem(
    val label: String,
    val enabled: Boolean = true,
)

/**
 * 分段选择器。
 *
 * @param options 选项列表
 * @param selectedIndex 当前选中索引
 * @param onSelect 选中回调
 * @param modifier 外部修饰
 * @param width 固定宽度（null 时 fillMaxWidth）
 */
@Composable
fun Segmented(
    options: List<SegmentedItem>,
    selectedIndex: Int,
    onSelect: (Int) -> Unit,
    modifier: Modifier = Modifier,
    width: Dp? = 200.dp,
) {
    val trackShape = RoundedCornerShape(AppRadius.md)
    val widthMod = if (width != null) Modifier.width(width) else Modifier.fillMaxWidth()

    Box(
        modifier = modifier
            .then(widthMod)
            .height(48.dp),
        contentAlignment = Alignment.Center,
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .height(32.dp)
                .clip(trackShape)
                .background(AppColor.bgPage, trackShape),
        ) {
            options.forEachIndexed { index, item ->
                val selected = index == selectedIndex
                Box(
                    modifier = Modifier
                        .weight(1f)
                        .fillMaxHeight()
                        .background(
                            color = when {
                                selected -> AppColor.textPrimary
                                !item.enabled -> Color.Transparent
                                else -> Color.Transparent
                            },
                            shape = selectedSegmentShape(index, options.size),
                        )
                        .clickable(
                            enabled = item.enabled,
                            interactionSource = remember { MutableInteractionSource() },
                            indication = null,
                        ) { onSelect(index) },
                    contentAlignment = Alignment.Center,
                ) {
                    Text(
                        text = item.label,
                        color = when {
                            selected -> AppColor.textInverse
                            !item.enabled -> AppColor.textSecondary.copy(alpha = 0.4f)
                            else -> AppColor.textSecondary
                        },
                        fontSize = AppFont.sizeSm,
                        fontWeight = FontWeight.SemiBold,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis,
                    )
                }
            }
        }
    }
}

/**
 * 选中块形状：内缘直角；仅首/末项的外侧带圆角。
 */
private fun selectedSegmentShape(index: Int, count: Int): Shape {
    if (count <= 1) return RoundedCornerShape(AppRadius.md)
    val r = AppRadius.md
    return when (index) {
        0 -> RoundedCornerShape(topStart = r, bottomStart = r, topEnd = 0.dp, bottomEnd = 0.dp)
        count - 1 -> RoundedCornerShape(topStart = 0.dp, bottomStart = 0.dp, topEnd = r, bottomEnd = r)
        else -> RectangleShape
    }
}
