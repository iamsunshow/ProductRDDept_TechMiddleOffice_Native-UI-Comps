package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.outlined.KeyboardArrowRight
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppFont
import com.zhiqihuayun.foundation.design.AppRadius
import com.zhiqihuayun.foundation.design.AppSpace

/**
 * 通用摘要卡片 Composable（对标 iOS SummaryCardView）。
 *
 * 卡片壳 + 标题行（标题 + 右箭头）+ 副标题 + 数值行（主数值 + 辅助文案）。
 * 双端 1:1 对齐。
 *
 * @param title 主标题
 * @param subtitle 副标题
 * @param value 主数值文案
 * @param valueColor 主数值颜色，默认 textPrimary
 * @param accessory 右侧辅助文案，null 时隐藏
 * @param onClick 整卡点击回调，null 时不可点击
 * @param modifier 布局修饰符
 */
@Composable
fun SummaryCardView(
    title: String,
    subtitle: String,
    value: String,
    valueColor: Color = AppColor.textPrimary,
    accessory: String? = null,
    onClick: (() -> Unit)? = null,
    modifier: Modifier = Modifier
) {
    Column(
        modifier = modifier
            .fillMaxWidth()
            .background(AppColor.bgCard, RoundedCornerShape(AppRadius.lg))
            .border(0.5.dp, AppColor.border, RoundedCornerShape(AppRadius.lg))
            .clickable(enabled = onClick != null) { onClick?.invoke() }
            .padding(AppSpace.lg),
        verticalArrangement = Arrangement.spacedBy(AppSpace.sm)
    ) {
        // ── 标题行：标题 + 右箭头 ──
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                text = title,
                fontSize = AppFont.sizeMd,
                fontWeight = FontWeight.SemiBold,
                color = AppColor.textPrimary
            )
            Icon(
                imageVector = Icons.AutoMirrored.Outlined.KeyboardArrowRight,
                contentDescription = null,
                tint = AppColor.textSecondary,
                modifier = Modifier.size(14.dp)
            )
        }

        // ── 副标题 ──
        Text(
            text = subtitle,
            fontSize = AppFont.sizeXs,
            color = AppColor.textSecondary,
            maxLines = 2
        )

        // ── 数值行：主数值 + 辅助文案 ──
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.Bottom
        ) {
            Text(
                text = value,
                fontSize = AppFont.sizeXl,
                fontWeight = FontWeight.SemiBold,
                color = valueColor
            )
            if (accessory != null) {
                Text(
                    text = accessory,
                    fontSize = AppFont.sizeXs,
                    color = AppColor.textSecondary,
                    textAlign = TextAlign.Right
                )
            }
        }
    }
}
