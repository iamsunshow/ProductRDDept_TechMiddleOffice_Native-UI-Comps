package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
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
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppFont
import com.zhiqihuayun.foundation.design.AppRadius
import com.zhiqihuayun.foundation.design.AppSpace
import java.util.LinkedHashSet

/**
 * Checkbox 通用复选（ui.checkbox，#25）——数据录入区缺口补齐批之一。
 *
 * 双形态：
 * - `Checkbox(label, checked, ...)`：单只复选；checked 半受控（null=内部自持、外部赋值=同步
 *   回显不触发 onChange）；label 空则仅显勾选框（宽高 40dp 命中区随内容收窄）。
 * - `CheckboxGroup(options, selected, ...)`：垂直多选列表（options 数据驱动）；selected 半受控
 *   （null=内部自持、外部重新赋值=同步回显）；行整宽 40dp 命中、行距 4dp。
 *
 * 契约（与 iOS CheckboxView/CheckboxGroupView 同构）：
 * - `CheckboxOption(value, label, disabled)`；点击回传 `onChange(value, newChecked)`。
 * - `disabled`：组/单只整体灰 40% 不可点（高于单项 disabled）；选项级禁用用 option.disabled。
 * - 已选禁用=灰底（gray15）白勾保留形态（不可点）。
 *
 * 视觉锚点：勾选框 20dp 方形 radiusSm(6) 圆角；选中=primary 底 + 白勾（Canvas path 与 iOS
 * 同坐标 20pt 箱内：起点 (0.24,0.52)→(0.42,0.72)→(0.78,0.34)，线宽 2）；未选中=白底 +
 * textSecondary(alpha 0.3) 1.5dp 描边；label Md16 后置间距 8、长文本单行省略；
 * 行纵向 padding 10（行高 40）；行距 4（xs）。与业务 AgreementCheckRow
 * （foundation/design/AgreementCheckbox.kt=圆形 12dp 富文本场景）划界不混入。
 *
 * 规格：docs/数据与产物/design-spec/checkbox-design-spec.html（门禁 A，P1–P4 全 A）。
 * 基线：组件库 v1.4.0（2026-09-06，未过 C2/D 不升版）。
 */
data class CheckboxOption(
    val value: String,
    val label: String = "",
    val disabled: Boolean = false
)

private const val GLYPH_LENGTH_DP = 20f

/** 单只复选（label 空=仅勾选框）。 */
@Composable
fun Checkbox(
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
                val next = !internalChecked
                internalChecked = next
                onCheckedChange?.invoke(next)
            }
            .padding(vertical = 10.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        CheckGlyph(checked = internalChecked, disabled = disabled)
        if (label != null) {
            Spacer(Modifier.width(AppSpace.sm))
            Text(
                text = label,
                fontSize = AppFont.sizeMd,
                color = AppColor.textPrimary,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )
        }
    }
}

/** CheckboxGroup 垂直多选列表（options 数据驱动）。 */
@Composable
fun CheckboxGroup(
    options: List<CheckboxOption>,
    selected: Set<String>? = null,
    onChange: ((String, Boolean) -> Unit)? = null,
    disabled: Boolean = false,
    modifier: Modifier = Modifier
) {
    // 半受控：null=内部自持；外部 selected 赋值=同步回显（不触发 onChange）。
    // LinkedHashSet 保序（回显/展开顺序=options 顺序）。
    val internal = remember(selected) {
        if (selected == null) mutableStateOf(LinkedHashSet<String>())
        else mutableStateOf(LinkedHashSet(selected))
    }
    LaunchedEffect(selected) {
        if (selected != null && internal.value != selected) {
            internal.value = LinkedHashSet(selected)
        }
    }
    val disabledColor = AppColor.textSecondary.copy(alpha = 0.4f)
    Column(
        modifier = modifier.alpha(if (disabled) 0.4f else 1f),
        verticalArrangement = androidx.compose.foundation.layout.Arrangement.spacedBy(AppSpace.xs)
    ) {
        options.forEach { option ->
            val optDisabled = disabled || option.disabled
            val checked = option.value in internal.value
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .clickable(enabled = !optDisabled) {
                        val next = !checked
                        if (next) internal.value.add(option.value)
                        else internal.value.remove(option.value)
                        onChange?.invoke(option.value, next)
                    }
                    .padding(vertical = 10.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                CheckGlyph(checked = checked, disabled = optDisabled)
                if (option.label.isNotEmpty()) {
                    Spacer(Modifier.width(AppSpace.sm))
                    Text(
                        text = option.label,
                        fontSize = AppFont.sizeMd,
                        color = if (optDisabled) disabledColor else AppColor.textPrimary,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )
                }
            }
        }
    }
}

/** 勾选框本体：20dp 方形 radiusSm 圆角；选中=primary/gray15(禁用) 底 + 白勾 Canvas path。 */
@Composable
private fun CheckGlyph(checked: Boolean, disabled: Boolean) {
    val shape = RoundedCornerShape(AppRadius.sm)
    val bg = when {
        checked && disabled -> AppColor.gray15
        checked -> AppColor.primary
        else -> Color.White
    }
    val borderColor = when {
        disabled -> AppColor.textSecondary.copy(alpha = 0.4f)
        checked -> Color.Transparent
        else -> AppColor.textSecondary.copy(alpha = 0.3f)
    }
    val borderWidth = if (checked && !disabled) 0.dp else 1.5.dp
    Box(
        modifier = Modifier
            .size(GLYPH_LENGTH_DP.dp)
            .clip(shape)
            .background(bg)
            .then(
                if (borderWidth > 0.dp) {
                    Modifier.border(borderWidth, borderColor, shape)
                } else {
                    Modifier
                }
            ),
        contentAlignment = Alignment.Center
    ) {
        if (checked) {
            Canvas(Modifier.fillMaxSize()) {
                // 勾 path（坐标同 iOS CheckGlyph 20pt 箱，双端 1:1）
                val path = Path().apply {
                    moveTo(size.width * 0.24f, size.height * 0.52f)
                    lineTo(size.width * 0.42f, size.height * 0.72f)
                    lineTo(size.width * 0.78f, size.height * 0.34f)
                }
                drawPath(
                    path = path,
                    color = Color.White.copy(alpha = if (disabled) 0.6f else 1f),
                    style = Stroke(
                        width = size.width * 0.09f,
                        cap = androidx.compose.ui.graphics.StrokeCap.Round,
                        join = androidx.compose.ui.graphics.StrokeJoin.Round
                    )
                )
            }
        }
    }
}
