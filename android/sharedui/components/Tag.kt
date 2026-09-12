// Tag 标签组件（Compose 版，对齐 iOS TagView）。
//
// 彩色标签，用于状态标识、分类标记、关键词展示。
// 三种形态：filled（实心白字）/ outline（描边）/ light（浅色底深色字）。
// 四种主题色：primary / success / warning / error。
// 三种尺寸：sm / md / lg。可选关闭按钮。

package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Close
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.LineHeightStyle
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppRadius

/** 标签主题色。 */
enum class TagColor(val color: Color) {
    PRIMARY(AppColor.primary),
    SUCCESS(AppColor.success),
    WARNING(AppColor.warning),
    ERROR(AppColor.error),
}

/** 标签形态。 */
enum class TagVariant {
    /** 实心填充，白字。 */
    FILLED,
    /** 描边，深色字。 */
    OUTLINE,
    /** 浅色底，深色字。 */
    LIGHT,
}

/** 标签尺寸。 */
enum class TagSize(
    val height: Dp,
    val fontSize: androidx.compose.ui.unit.TextUnit,
    val paddingH: Dp,
    val iconSize: Dp,
) {
    SM(height = 20.dp, fontSize = 11.sp, paddingH = 6.dp, iconSize = 12.dp),
    MD(height = 24.dp, fontSize = 12.sp, paddingH = 8.dp, iconSize = 14.dp),
    LG(height = 28.dp, fontSize = 14.sp, paddingH = 10.dp, iconSize = 16.dp),
}

/**
 * 标签组件。
 *
 * @param text 标签文案
 * @param color 主题色，默认 primary
 * @param variant 形态，默认 filled
 * @param size 尺寸，默认 sm
 * @param closable 是否显示关闭按钮
 * @param onClose 关闭回调
 */
@Composable
fun Tag(
    text: String,
    color: TagColor = TagColor.PRIMARY,
    variant: TagVariant = TagVariant.FILLED,
    size: TagSize = TagSize.SM,
    closable: Boolean = false,
    onClose: (() -> Unit)? = null,
) {
    val c = color.color
    val shape = RoundedCornerShape(AppRadius.sm)

    val bgColor: Color
    val textColor: Color
    val borderMod: Modifier

    when (variant) {
        TagVariant.FILLED -> {
            bgColor = c
            textColor = Color.White
            borderMod = Modifier
        }
        TagVariant.OUTLINE -> {
            bgColor = Color.Transparent
            textColor = c
            borderMod = Modifier.border(1.dp, c, shape)
        }
        TagVariant.LIGHT -> {
            bgColor = c.copy(alpha = 0.1f)
            textColor = c
            borderMod = Modifier
        }
    }

    Row(
        modifier = Modifier
            .height(size.height)
            .then(borderMod)
            .background(bgColor, shape)
            .padding(horizontal = size.paddingH),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.Center,
    ) {
        Text(
            text = text,
            color = textColor,
            fontSize = size.fontSize,
            fontWeight = FontWeight.Medium,
            modifier = Modifier.testTag("tag-text"),
            // 小高度标签视觉居中（台账 #56）：默认行高（≈字号×1.2+）大于字号，
            // 行盒虽被 Row 垂直居中、字形仍按 baseline 落位致视觉中线偏移，与几何居中的
            // Close 矢量图标错位。lineHeight 收紧到字号 + Center/Trim.Both 让字形居中；
            // Compose 1.7（BOM 2024.12.01）includeFontPadding 已默认 false，无需再设。
            style = TextStyle(
                lineHeight = size.fontSize,
                lineHeightStyle = LineHeightStyle(
                    alignment = LineHeightStyle.Alignment.Center,
                    trim = LineHeightStyle.Trim.Both,
                ),
            ),
        )
        if (closable) {
            // 文字与关闭叉间隙 2dp，对齐 iOS TagView intrinsicContentSize 中 iconSize+2。
            Spacer(Modifier.width(2.dp))
            Icon(
                imageVector = Icons.Filled.Close,
                contentDescription = "关闭",
                tint = textColor,
                modifier = Modifier
                    .testTag("tag-close")
                    .size(size.iconSize)
                    .clickable { onClose?.invoke() },
            )
        }
    }
}
