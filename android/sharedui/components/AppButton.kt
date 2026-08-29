package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.interaction.collectIsPressedAsState
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.TextUnit
import androidx.compose.ui.unit.dp
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppFont
import com.zhiqihuayun.foundation.design.AppRadius

/** 中台基础按钮视觉样式。 */
enum class AppButtonStyle {
    /** 主操作：主色填充 + 白字（本机一键登录样式）。 */
    Primary,

    /** 次要操作：白底 + 主色描边 + 主色文字。 */
    Secondary,

    /** 破坏性操作：白底 + 红色描边 + 红色文字。 */
    Destructive
}

/**
 * 中台基础按钮组件。
 *
 * 对齐「本机号码一键登录」主按钮样式：48dp 高、圆角 lg、主色填充 + 白色半粗字。
 * 作为中台基础组件统一登录/注册/弹窗/表单等所有主操作按钮视觉，禁止各页面单独发挥。
 *
 * @param text 按钮文案
 * @param onClick 点击回调
 * @param modifier 可选布局修饰符（默认通栏全宽）
 * @param style 视觉样式，默认 [AppButtonStyle.Primary]
 * @param fontSize 文案字号，默认与一键登录一致（16sp）
 * @param height 按钮高度，默认 48dp
 * @param enabled 是否可用，false 时按钮置灰且不可点击
 */
@Composable
fun AppButton(
    text: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    style: AppButtonStyle = AppButtonStyle.Primary,
    fontSize: TextUnit = AppFont.sizeMd,
    height: Dp = 48.dp,
    enabled: Boolean = true
) {
    val interactionSource = remember { MutableInteractionSource() }
    val pressed by interactionSource.collectIsPressedAsState()

    val shape = RoundedCornerShape(AppRadius.lg)
    val (container, content, borderColor) = when {
        !enabled -> Triple(Color(0xFF9CA3AF), Color.White, null)
        style == AppButtonStyle.Primary ->
            Triple(if (pressed) AppColor.primaryPressed else AppColor.primary, Color.White, null)
        style == AppButtonStyle.Secondary ->
            Triple(Color.Transparent, AppColor.primary, AppColor.primary)
        else ->
            Triple(Color.Transparent, AppColor.error, AppColor.error)
    }

    Box(
        modifier = modifier
            .fillMaxWidth()
            .height(height)
            .then(
                if (borderColor != null) Modifier.border(BorderStroke(1.dp, borderColor), shape) else Modifier
            )
            .clickable(
                interactionSource = interactionSource,
                indication = null,
                enabled = enabled,
                onClick = onClick
            ),
        contentAlignment = Alignment.Center
    ) {
        Text(
            text = text,
            color = content,
            fontSize = fontSize,
            fontWeight = FontWeight.SemiBold
        )
    }
}
