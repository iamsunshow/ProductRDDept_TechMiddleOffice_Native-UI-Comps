package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
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
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppFont
import com.zhiqihuayun.foundation.design.AppRadius
import com.zhiqihuayun.foundation.design.AppSpace
import kotlin.math.max
import kotlin.math.min

private val StepperButtonSize = 32.dp
private val StepperLabelMinWidth = 40.dp
private val StepperComponentHeight = 32.dp

/**
 * Stepper 步进器（数据录入组件 · ui.stepper）：数值增减步进器。
 *
 * 视觉：[−] 按钮 + 数值标签 + [+] 按钮，高 32，按钮 32×32 圆角；
 * 到达 min/max 时对应按钮灰显不可点。
 * 语义：value 受控当前值；onValueChange 步进回调；disabled 整体 40% 灰。
 */
@Composable
fun Stepper(
    value: Float,
    range: ClosedFloatingPointRange<Float> = 0f..100f,
    step: Float = 1f,
    onValueChange: ((Float) -> Unit)? = null,
    enabled: Boolean = true,
    modifier: Modifier = Modifier
) {
    // 内部自持态（value=null 时自持）
    var internalValue by remember { mutableStateOf(value) }
    val currentValue = value

    val atMin = currentValue <= range.start
    val atMax = currentValue >= range.endInclusive

    fun formatValue(v: Float): String {
        return if (step == step.toInt().toFloat() && step >= 1f) {
            v.toInt().toString()
        } else {
            String.format("%.1f", v)
        }
    }

    Row(
        modifier = modifier
            .testTag("stepper-root")
            .alpha(if (enabled) 1f else 0.4f),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(AppSpace.xs)
    ) {
        // − 按钮
        val minusEnabled = enabled && !atMin
        Box(
            modifier = Modifier
                .size(StepperButtonSize)
                .clip(RoundedCornerShape(AppRadius.sm))
                .background(AppColor.bgPage)
                .alpha(if (minusEnabled) 1f else 0.4f)
                .clickable(enabled = minusEnabled) {
                    val newVal = max(range.start, currentValue - step)
                    onValueChange?.invoke(newVal)
                },
            contentAlignment = Alignment.Center
        ) {
            Text(
                text = "−",
                fontSize = AppFont.sizeLg,
                fontWeight = FontWeight.Medium,
                color = AppColor.textPrimary
            )
        }

        // 数值标签
        Box(
            modifier = Modifier
                .width(StepperLabelMinWidth)
                .height(StepperComponentHeight),
            contentAlignment = Alignment.Center
        ) {
            Text(
                text = formatValue(currentValue),
                fontSize = AppFont.sizeMd,
                fontWeight = FontWeight.Medium,
                color = AppColor.textPrimary,
                textAlign = TextAlign.Center,
                maxLines = 1
            )
        }

        // + 按钮
        val plusEnabled = enabled && !atMax
        Box(
            modifier = Modifier
                .size(StepperButtonSize)
                .clip(RoundedCornerShape(AppRadius.sm))
                .background(AppColor.bgPage)
                .alpha(if (plusEnabled) 1f else 0.4f)
                .clickable(enabled = plusEnabled) {
                    val newVal = min(range.endInclusive, currentValue + step)
                    onValueChange?.invoke(newVal)
                },
            contentAlignment = Alignment.Center
        ) {
            Text(
                text = "+",
                fontSize = AppFont.sizeLg,
                fontWeight = FontWeight.Medium,
                color = AppColor.textPrimary
            )
        }
    }
}
