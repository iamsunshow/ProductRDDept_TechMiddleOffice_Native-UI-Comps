package com.zhiqihuayun.demo

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppFont
import com.zhiqihuayun.foundation.design.AppRadius
import com.zhiqihuayun.foundation.design.AppSpace
import com.zhiqihuayun.foundation.design.AppText

/**
 * DesignTokens 设计令牌 Demo（foundation.design-tokens #91）。
 * 4 组排查：①色板全谱（AppColor）②字号阶梯（AppFont 6 档）
 * ③间距 5 档可视化条 + 圆角 3 档 ④文本排版（多行行高 / cell 主副标题行高）。
 */
@Composable
fun DesignTokensDemo() {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(horizontal = AppSpace.lg, vertical = AppSpace.md),
        verticalArrangement = Arrangement.spacedBy(AppSpace.lg)
    ) {
        DemoSection("D1 · 色板全谱（AppColor ${tokenList.size} 项）") {
            Column(verticalArrangement = Arrangement.spacedBy(AppSpace.sm)) {
                tokenList.forEach { (name, hex, color) ->
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(AppSpace.md)
                    ) {
                        Box(
                            modifier = Modifier
                                .size(24.dp)
                                .clip(RoundedCornerShape(4.dp))
                                .background(color)
                                .border(0.5.dp, AppColor.border, RoundedCornerShape(4.dp))
                        )
                        Text(
                            name,
                            fontSize = AppFont.sizeSm,
                            color = AppColor.textPrimary,
                            modifier = Modifier.weight(1f)
                        )
                        Text(hex, fontSize = AppFont.sizeSm, color = AppColor.textSecondary)
                    }
                }
            }
        }

        DemoSection("D2 · 字号阶梯（AppFont 6 档）") {
            Column(verticalArrangement = Arrangement.spacedBy(AppSpace.xs)) {
                listOf(
                    "sizeXs" to AppFont.sizeXs,
                    "sizeSm" to AppFont.sizeSm,
                    "sizeMd" to AppFont.sizeMd,
                    "sizeLg" to AppFont.sizeLg,
                    "sizeXl" to AppFont.sizeXl,
                    "sizeDisplay" to AppFont.sizeDisplay
                ).forEach { (name, size) ->
                    Text(
                        "Aa $name ${size.value.toInt()}sp",
                        fontSize = size,
                        color = AppColor.textPrimary
                    )
                }
            }
        }

        DemoSection("D3 · 间距 5 档 + 圆角 3 档") {
            Column(verticalArrangement = Arrangement.spacedBy(AppSpace.sm)) {
                listOf(
                    "xs" to AppSpace.xs,
                    "sm" to AppSpace.sm,
                    "md" to AppSpace.md,
                    "lg" to AppSpace.lg,
                    "xl" to AppSpace.xl
                ).forEach { (name, space) ->
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(AppSpace.md)
                    ) {
                        Text(
                            "AppSpace.$name",
                            fontSize = AppFont.sizeSm,
                            color = AppColor.textPrimary,
                            modifier = Modifier.width(96.dp)
                        )
                        Box(
                            modifier = Modifier
                                .width(space)
                                .height(16.dp)
                                .background(AppColor.gray15)
                        )
                        Text(
                            "${space.value.toInt()}dp",
                            fontSize = AppFont.sizeSm,
                            color = AppColor.textSecondary
                        )
                    }
                }
            }
            Column(
                modifier = Modifier.padding(top = AppSpace.md),
                verticalArrangement = Arrangement.spacedBy(AppSpace.sm)
            ) {
                listOf(
                    "sm" to AppRadius.sm,
                    "md" to AppRadius.md,
                    "lg" to AppRadius.lg
                ).forEach { (name, radius) ->
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(AppSpace.md)
                    ) {
                        Box(
                            modifier = Modifier
                                .size(48.dp)
                                .clip(RoundedCornerShape(radius))
                                .background(AppColor.gray10)
                        )
                        Text(
                            "AppRadius.$name（${radius.value.toInt()}dp）",
                            fontSize = AppFont.sizeSm,
                            color = AppColor.textPrimary
                        )
                    }
                }
            }
        }

        DemoSection("D4 · 文本排版（多行行高 1.8 / cell 主副标题行高）") {
            Text(
                "AppText.contentStyle 多行段落：快捷记账，让每一笔收支都清清楚楚。行高为字号 1.8 倍，阅读舒适。",
                fontSize = AppFont.sizeMd,
                lineHeight = AppText.cellTitleLineHeight,
                color = AppColor.textPrimary
            )
            Text(
                "主标题（cellTitleLineHeight 24）",
                fontSize = AppFont.sizeMd,
                lineHeight = AppText.cellTitleLineHeight,
                color = AppColor.textPrimary
            )
            Text(
                "副标题（cellSubtitleLineHeight 18）",
                fontSize = AppFont.sizeSm,
                lineHeight = AppText.cellSubtitleLineHeight,
                color = AppColor.textSecondary
            )
        }

        Text(
            "foundation.design-tokens = 视觉语言唯一出口（颜色/字号/间距/圆角/字体层级五族），" +
                "对齐 iOS AppTokens 同名同值（hex 逐项一致）。",
            fontSize = AppFont.sizeXs, color = AppColor.textSecondary
        )
    }
}

private data class TokenEntry(val name: String, val hex: String, val color: Color)

/** 色板全谱（与 iOS AppColor 交集 19 项 + Android 额外 textInverse）。 */
private val tokenList = listOf(
    TokenEntry("primary", "#16A34A", AppColor.primary),
    TokenEntry("primaryPressed", "#15803D", AppColor.primaryPressed),
    TokenEntry("primaryMuted", "#DCFCE7", AppColor.primaryMuted),
    TokenEntry("income", "#16A34A", AppColor.income),
    TokenEntry("expense", "#DC2626", AppColor.expense),
    TokenEntry("warning", "#F59E0B", AppColor.warning),
    TokenEntry("textPrimary", "#111827", AppColor.textPrimary),
    TokenEntry("textSecondary", "#6B7280", AppColor.textSecondary),
    TokenEntry("textInverse", "#FFFFFF", AppColor.textInverse),
    TokenEntry("border", "#E5E7EB", AppColor.border),
    TokenEntry("bgPage", "#F9FAFB", AppColor.bgPage),
    TokenEntry("bgCard", "#FFFFFF", AppColor.bgCard),
    TokenEntry("success", "#16A34A", AppColor.success),
    TokenEntry("error", "#DC2626", AppColor.error),
    TokenEntry("gray4", "#F5F5F5", AppColor.gray4),
    TokenEntry("gray6", "#E5E5E5", AppColor.gray6),
    TokenEntry("gray10", "#D9D9D9", AppColor.gray10),
    TokenEntry("gray15", "#BFBFBF", AppColor.gray15),
    TokenEntry("gray25", "#8C8C8C", AppColor.gray25),
    TokenEntry("buttonDisabled", "#9CA3AF", AppColor.buttonDisabled)
)
