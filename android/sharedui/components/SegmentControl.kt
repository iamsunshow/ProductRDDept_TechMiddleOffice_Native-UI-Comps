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
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppFont
import com.zhiqihuayun.foundation.design.AppRadius

/**
 * 对齐 iOS 分段：视觉轨 **200×32**（bgPage / 选中 textPrimary 白字），
 * 外层触控高 **48**。
 *
 * 圆角规则（对齐 iOS `UIStackView.cornerRadius + clipsToBounds`，选中按钮无自身圆角）：
 * - 外轨整体圆角
 * - 选中块：**仅外侧**圆角；与相邻项相接的**内缘一律直角**
 * - 中间项：四角全直角（RectangleShape）
 */
@Composable
fun SegmentControl(
    options: List<String>,
    selectedIndex: Int,
    onSelect: (Int) -> Unit,
    modifier: Modifier = Modifier,
    width: Dp = 200.dp
) {
    val trackShape = RoundedCornerShape(AppRadius.md)
    Box(
        modifier = modifier
            .width(width)
            .height(48.dp),
        contentAlignment = Alignment.Center
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .height(32.dp)
                .clip(trackShape)
                .background(AppColor.bgPage, trackShape)
        ) {
            options.forEachIndexed { index, label ->
                val selected = index == selectedIndex
                Box(
                    modifier = Modifier
                        .weight(1f)
                        .fillMaxHeight()
                        .background(
                            color = if (selected) AppColor.textPrimary else Color.Transparent,
                            shape = selectedSegmentShape(index, options.size)
                        )
                        .clickable(
                            interactionSource = remember { MutableInteractionSource() },
                            indication = null
                        ) { onSelect(index) },
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = label,
                        color = if (selected) AppColor.textInverse else AppColor.textSecondary,
                        fontSize = AppFont.sizeSm,
                        fontWeight = FontWeight.SemiBold
                    )
                }
            }
        }
    }
}

/**
 * 选中块形状：内缘直角；仅首/末项的外侧带 [AppRadius.md]。
 */
private fun selectedSegmentShape(index: Int, count: Int): Shape {
    if (count <= 1) return RoundedCornerShape(AppRadius.md)
    val r = AppRadius.md
    return when (index) {
        0 -> RoundedCornerShape(
            topStart = r,
            bottomStart = r,
            topEnd = 0.dp,
            bottomEnd = 0.dp
        )
        count - 1 -> RoundedCornerShape(
            topStart = 0.dp,
            bottomStart = 0.dp,
            topEnd = r,
            bottomEnd = r
        )
        else -> RectangleShape
    }
}
