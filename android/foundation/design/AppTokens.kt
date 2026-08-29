package com.zhiqihuayun.foundation.design

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Typography
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

/**
 * 设计令牌：与 docs/design/tokens.json、iOS AppColor 对齐。
 */
object AppColor {
    val primary = Color(0xFF16A34A)
    val primaryPressed = Color(0xFF15803D)
    val primaryMuted = Color(0xFFDCFCE7)
    val income = Color(0xFF16A34A)
    val expense = Color(0xFFDC2626)
    val warning = Color(0xFFF59E0B)
    val textPrimary = Color(0xFF111827)
    val textSecondary = Color(0xFF6B7280)
    val textInverse = Color(0xFFFFFFFF)
    val border = Color(0xFFE5E7EB)
    val bgPage = Color(0xFFF9FAFB)
    val bgCard = Color(0xFFFFFFFF)
    val success = Color(0xFF16A34A)
    val error = Color(0xFFDC2626)
}

object AppFont {
    val sizeXs = 12.sp
    val sizeSm = 14.sp
    val sizeMd = 16.sp
    val sizeLg = 18.sp
    val sizeXl = 22.sp
    val sizeDisplay = 32.sp
}

object AppSpace {
    val xs = 4.dp
    val sm = 8.dp
    val md = 12.dp
    val lg = 16.dp
    val xl = 24.dp
}

object AppRadius {
    val sm = 6.dp
    val md = 10.dp
    val lg = 14.dp
}

/** 多行文本排版间距（与 docs/design/tokens.json `text` 对齐）。 */
object AppText {
    val lineSpacing = AppSpace.sm
    val paragraphSpacing = AppSpace.md
    const val lineHeightMultiple = 1.8f

    fun lineHeight(fontSize: androidx.compose.ui.unit.TextUnit) = fontSize * lineHeightMultiple

    fun contentStyle(
        fontSize: androidx.compose.ui.unit.TextUnit,
        color: Color
    ) = TextStyle(
        fontSize = fontSize,
        color = color,
        lineHeight = lineHeight(fontSize)
    )
}

private val LightColors = lightColorScheme(
    primary = AppColor.primary,
    onPrimary = AppColor.textInverse,
    secondary = AppColor.primaryMuted,
    background = AppColor.bgPage,
    surface = AppColor.bgCard,
    onBackground = AppColor.textPrimary,
    onSurface = AppColor.textPrimary,
    error = AppColor.error
)

private val AppTypography = Typography(
    bodyLarge = TextStyle(
        fontSize = AppFont.sizeMd,
        fontWeight = FontWeight.Normal,
        color = AppColor.textPrimary
    ),
    titleLarge = TextStyle(
        fontSize = AppFont.sizeXl,
        fontWeight = FontWeight.SemiBold,
        color = AppColor.textPrimary
    ),
    labelLarge = TextStyle(
        fontSize = AppFont.sizeSm,
        fontWeight = FontWeight.Medium,
        color = AppColor.textPrimary
    )
)

@Composable
fun KeepAccountsTheme(content: @Composable () -> Unit) {
    MaterialTheme(
        colorScheme = LightColors,
        typography = AppTypography,
        content = content
    )
}
