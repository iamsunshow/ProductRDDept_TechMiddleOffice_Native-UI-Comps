package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.input.VisualTransformation
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppFont
import com.zhiqihuayun.foundation.design.AppRadius
import com.zhiqihuayun.foundation.design.AppSpace

/**
 * Input 通用单行文本输入内容组件（ui.input，#29）——数据录入区缺口补齐批之二。
 *
 * 定位：纯输入内容组件（label/必填星/校验=FormFieldRow 壳职责，本组件不变红、不含 label）。
 * 受控：`value` 必传 + `onTextChange` 直通（外部赋值=同步回显）；无内部状态。
 *
 * 契约（与 iOS InputView 同构）：
 * - `placeholder`：占位灰字（textSecondary Md16）。
 * - `keyboard`：text|number|phone|email 映射系统键盘。
 * - `secure`：密码掩码（回调仍传原文；一期无显隐切换钮）。
 * - `maxLength`：仅输入路径截断（外部赋值不限）。
 * - `disabled`：整体灰 40% 不可编辑，清除钮隐藏。
 * - 非空文本显示清除钮（20dp 圆 gray15 底白叉，点击清空回调空串）。
 * - `trailing`：尾部附加槽（宿主自放单位/按钮）。
 *
 * 视觉锚点：壳 48dp 高 bgPage 底 + radiusLg 圆角、无边框；行内水平 padding 16；
 * 文本 Md16 textPrimary；输入光标 primary。与 Android sharedui AppInputField 系列
 * （52dp 灰底 BasicTextField）=视觉前身可平滑迁移。
 *
 * 规格：docs/数据与产物/design-spec/input-design-spec.html（门禁 A，P1–P4 全 A）。
 * 基线：组件库 v1.4.0（2026-09-06，未过 C2/D 不升版）。
 */
@Composable
fun Input(
    value: String,
    onTextChange: (String) -> Unit,
    placeholder: String? = null,
    keyboard: String = "text",
    secure: Boolean = false,
    maxLength: Int? = null,
    disabled: Boolean = false,
    trailing: (@Composable () -> Unit)? = null,
    modifier: Modifier = Modifier
) {
    val keyboardType = when (keyboard) {
        "number" -> KeyboardType.Number
        "phone" -> KeyboardType.Phone
        "email" -> KeyboardType.Email
        else -> KeyboardType.Text
    }
    Row(
        modifier = modifier
            .fillMaxWidth()
            .height(48.dp)
            .clip(RoundedCornerShape(AppRadius.lg))
            .background(AppColor.bgPage)
            .alpha(if (disabled) 0.4f else 1f)
            .padding(horizontal = AppSpace.lg),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Box(
            modifier = Modifier.weight(1f),
            contentAlignment = Alignment.CenterStart
        ) {
            BasicTextField(
                value = value,
                onValueChange = { raw ->
                    val newText = if (maxLength != null && raw.length > maxLength) {
                        raw.take(maxLength)
                    } else {
                        raw
                    }
                    if (newText != value) onTextChange(newText)
                },
                textStyle = TextStyle(
                    fontSize = AppFont.sizeMd,
                    color = AppColor.textPrimary
                ),
                cursorBrush = SolidColor(AppColor.primary),
                keyboardOptions = KeyboardOptions(keyboardType = keyboardType),
                visualTransformation = if (secure) PasswordVisualTransformation() else VisualTransformation.None,
                enabled = !disabled,
                singleLine = true,
                modifier = Modifier.fillMaxWidth()
            )
            if (value.isEmpty()) {
                Text(
                    text = placeholder ?: "",
                    fontSize = AppFont.sizeMd,
                    color = AppColor.textSecondary,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
            }
        }
        // 清除钮：非空且非禁用显示（点击清空）
        if (value.isNotEmpty() && !disabled) {
            Spacer(Modifier.width(AppSpace.sm))
            Box(
                modifier = Modifier
                    .size(20.dp)
                    .clip(CircleShape)
                    .background(AppColor.gray15)
                    .clickable { onTextChange("") },
                contentAlignment = Alignment.Center
            ) {
                Canvas(Modifier.size(12.dp)) {
                    val inset = size.width * 0.2f
                    val outer = size.width - inset
                    drawLine(
                        color = Color.White,
                        start = Offset(inset, inset),
                        end = Offset(outer, outer),
                        strokeWidth = size.width * 0.17f,
                        cap = StrokeCap.Round
                    )
                    drawLine(
                        color = Color.White,
                        start = Offset(outer, inset),
                        end = Offset(inset, outer),
                        strokeWidth = size.width * 0.17f,
                        cap = StrokeCap.Round
                    )
                }
            }
        }
        // trailing 尾槽（宿主自放）
        if (trailing != null) {
            Spacer(Modifier.width(AppSpace.sm))
            trailing()
        }
    }
}
