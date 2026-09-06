package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppFont
import com.zhiqihuayun.foundation.design.AppSpace

/**
 * Radio 通用排他单选（ui.radio，#35）——数据录入区全新立项。
 *
 * 双形态：
 * - `Radio(label, checked, ...)`：单只独立单选标记（行尾/宿主组合互斥用）；checked 半受控
 *   （null=内部自持初始未选、外部赋值=同步回显不触发 onChange）；点选即置 true 并回调，
 *   已选中再点=幂等忽略（radio 语义无 toggle 取消）；取消只能外部驱动（checked=false）。
 * - `RadioGroup(options, value, ...)`：垂直排他单选列表（options 数据驱动一选一）；value 半受控
 *   （null=内部自持初始未选=合法未选态，不自动回填首项=不改宿主表单语义；外部赋值=同步回显不触发
 *   onChange）；点击未选行=切中并回调 onChange(value)；点击已选中行=幂等忽略。
 *
 * 契约（与 iOS RadioView/RadioGroupView 同构）：
 * - `RadioOption(value, label, disabled)`；组禁用 disabled=整体灰 40% 不可点（高于单项）；
 *   选项级禁用用 option.disabled；value 指向 disabled 项=灰点灰圈只读保留。
 *
 * 视觉锚点：单选点 20dp 圆形；未选中=白底 + textSecondary(alpha 0.3) 1.5dp 圆描边（同 Checkbox
 * 未选描边惯例）；选中=外圈 primary 描边 + 中心实心点 8dp primary；禁用=textSecondary(alpha 0.4)
 * 描边、已选禁用=灰外圈灰点保留（gray15）；label Md16 后置间距 8、选中行 label 加粗（SemiBold）、
 * 长文本单行省略；行纵向 padding 10（行高 40）；行距 4（xs）。与 #25 Checkbox（方形复选可多选可
 * 取消）划界=Radio 圆形排他点选即确定；与协议行/富文本 label 业务形态划界不混入。
 *
 * 规格：docs/数据与产物/design-spec/radio-design-spec.html（门禁 A，P1–P4 全 A）。
 * 基线：组件库 v1.4.0（2026-09-06，未过 C2/D 不升版）。
 */
data class RadioOption(
    val value: String,
    val label: String = "",
    val disabled: Boolean = false
)

private const val GLYPH_LENGTH_DP = 20f
private const val DOT_LENGTH_DP = 8f

/** 单只单选（label 空=仅单选点；点选置 true、已选再点幂等忽略）。 */
@Composable
fun Radio(
    label: String? = null,
    checked: Boolean? = null,
    onCheckedChange: ((Boolean) -> Unit)? = null,
    disabled: Boolean = false,
    modifier: Modifier = Modifier
) {
    var internalChecked by remember(checked) { mutableStateOf(checked ?: false) }
    // 外部 checked 赋值=同步回显（不触发 onChange）
    LaunchedEffect(checked) {
        if (checked != null && internalChecked != checked) {
            internalChecked = checked
        }
    }
    Row(
        modifier = modifier
            .alpha(if (disabled) 0.4f else 1f)
            .clickable(enabled = !disabled) {
                // 点选即确定；已选中再点=幂等忽略（radio 语义无 toggle 取消）
                if (!internalChecked) {
                    internalChecked = true
                    onCheckedChange?.invoke(true)
                }
            }
            .padding(vertical = 10.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        RadioGlyph(selected = internalChecked, disabled = disabled)
        if (label != null) {
            Spacer(Modifier.width(AppSpace.sm))
            Text(
                text = label,
                fontSize = AppFont.sizeMd,
                fontWeight = if (internalChecked && !disabled) FontWeight.SemiBold else FontWeight.Normal,
                color = if (disabled) AppColor.textSecondary.copy(alpha = 0.6f) else AppColor.textPrimary,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )
        }
    }
}

/** RadioGroup 垂直排他单选列表（options 数据驱动一选一）。 */
@Composable
fun RadioGroup(
    options: List<RadioOption>,
    value: String? = null,
    onChange: ((String) -> Unit)? = null,
    disabled: Boolean = false,
    modifier: Modifier = Modifier
) {
    // 半受控：null=内部自持且初始未选（合法未选态）；外部 value 赋值=同步回显（不触发 onChange）
    var internalValue by remember(value) { mutableStateOf(value) }
    LaunchedEffect(value) {
        if (value != null && internalValue != value) {
            internalValue = value
        }
    }
    val disabledColor = AppColor.textSecondary.copy(alpha = 0.4f)
    Column(
        modifier = modifier.alpha(if (disabled) 0.4f else 1f),
        verticalArrangement = Arrangement.spacedBy(AppSpace.xs)
    ) {
        options.forEach { option ->
            val optDisabled = disabled || option.disabled
            val selected = internalValue == option.value
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .clickable(enabled = !optDisabled) {
                        // 排他：点未选行=切中并回调；点已选中行=幂等忽略
                        if (!selected) {
                            internalValue = option.value
                            onChange?.invoke(option.value)
                        }
                    }
                    .padding(vertical = 10.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                RadioGlyph(selected = selected, disabled = optDisabled)
                if (option.label.isNotEmpty()) {
                    Spacer(Modifier.width(AppSpace.sm))
                    Text(
                        text = option.label,
                        fontSize = AppFont.sizeMd,
                        fontWeight = if (selected && !optDisabled) FontWeight.SemiBold else FontWeight.Normal,
                        color = if (optDisabled) disabledColor else AppColor.textPrimary,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )
                }
            }
        }
    }
}

/** 单选点本体：20dp 圆形白底 + 外圈描边 + 选中中心实心点 8dp（与 iOS draw 同构 1:1）。 */
@Composable
private fun RadioGlyph(selected: Boolean, disabled: Boolean) {
    val strokeColor = when {
        disabled -> AppColor.textSecondary.copy(alpha = 0.4f)
        selected -> AppColor.primary
        else -> AppColor.textSecondary.copy(alpha = 0.3f)
    }
    val dotColor = when {
        !selected -> Color.Transparent
        disabled -> AppColor.gray15
        else -> AppColor.primary
    }
    Box(
        modifier = Modifier
            .size(GLYPH_LENGTH_DP.dp)
            .clip(CircleShape)
            .background(Color.White)
            .border(1.5.dp, strokeColor, CircleShape),
        contentAlignment = Alignment.Center
    ) {
        Box(
            modifier = Modifier
                .size(DOT_LENGTH_DP.dp)
                .clip(CircleShape)
                .background(dotColor)
        )
    }
}
