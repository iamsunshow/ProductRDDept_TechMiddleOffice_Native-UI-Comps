package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.defaultMinSize
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
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
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppFont
import com.zhiqihuayun.foundation.design.AppRadius
import java.math.BigDecimal
import java.math.RoundingMode
import java.util.Locale

/**
 * InputNumber 步进式数字输入（ui.input-number，#30）——数据录入区第二批三件之二。
 *
 * 定位：步进式数字输入内容组件（无弹层/无键盘拉起面）：宿主传值，用户点 − / + 按 step 增减，
 * 中段显示当前值；一期无键盘直输/长按连续（=二期，键盘=Input #29 职责）。
 *
 * 契约（半受控，与 iOS InputNumberView 同构）：
 * - `value: Double?`：null/缺省=min 存在则 min、否则 0；外部重新赋值=同步刷新（LaunchedEffect
 *   回写 internal，不触发 onChange）。
 * - `min/max`：到达边界对应按钮禁用灰 40%，点边界按钮幂等无回调。
 * - `step` 默认 1；`precision` 默认 0：运算展示按 precision 定点收敛（BigDecimal + HALF_UP）。
 * - `disabled`：整控件灰 40% 不可点（优先级高于边界）。
 * - 每次有效增减触发 `onChange(newValue)`（未变不回调）。
 *
 * 设计锚点：整高 32dp；按钮宽 32dp 字号 Lg=18 主色；值区 min 40dp 字号 Md=16 主色；
 * 壳=bgPage + 0.5dp hairline + radiusSm(6) 圆角裁剪（iOS=1/scale pt 表内放行）；
 * 边界/禁用=textSecondary alpha 0.4；点击 ripple vs iOS 按压瞬态=平台差异表内放行。
 *
 * 规格：docs/数据与产物/design-spec/input-number-design-spec.html（门禁 A，P1–P4 全 A）。
 * 基线：组件库 v1.4.0（2026-09-06，未过 C2/D 不升版）。
 */
@Composable
fun InputNumber(
    value: Double?,
    min: Double? = null,
    max: Double? = null,
    step: Double = 1.0,
    precision: Int = 0,
    disabled: Boolean = false,
    onChange: (Double) -> Unit,
    modifier: Modifier = Modifier
) {
    val p = precision.coerceIn(0, 6)
    val normalize: (Double) -> Double = { raw ->
        var v = raw
        min?.let { if (v < it) v = it }
        max?.let { if (v > it) v = it }
        BigDecimal(v.toString()).setScale(p, RoundingMode.HALF_UP).toDouble()
    }
    var internal by remember(value) { mutableStateOf(normalize(value ?: (min ?: 0.0))) }
    // 外部 value 赋值=同步刷新（不触发 onChange）
    LaunchedEffect(value) {
        if (value != null && internal != normalize(value)) {
            internal = normalize(value)
        }
    }

    val stepFn: (Int) -> Unit = step@{ direction ->
        if (disabled) return@step
        val factor = BigDecimal.TEN.pow(p)
        val scaled = BigDecimal(internal.toString()).multiply(factor).setScale(0, RoundingMode.HALF_UP)
            .add(BigDecimal(step.toString()).multiply(factor).setScale(0, RoundingMode.HALF_UP).multiply(BigDecimal(direction)))
        var next = scaled.divide(factor, p, RoundingMode.HALF_UP).toDouble()
        min?.let { if (next < it) next = it }
        max?.let { if (next > it) next = it }
        next = BigDecimal(next.toString()).setScale(p, RoundingMode.HALF_UP).toDouble()
        if (next == internal) return@step
        internal = next
        onChange(next)
    }

    val canMinus = !disabled && (min == null || internal > min)
    val canPlus = !disabled && (max == null || internal < max)
    val disabledColor = AppColor.textSecondary.copy(alpha = 0.4f)

    val shellShape = RoundedCornerShape(AppRadius.sm)
    Row(
        modifier = modifier
            .height(32.dp)
            .clip(shellShape)
            .background(AppColor.bgPage)
            .border(0.5.dp, AppColor.border, shellShape),
        verticalAlignment = Alignment.CenterVertically
    ) {
        StepperButton("−", canMinus, disabledColor) { stepFn(-1) }
        Box(
            modifier = Modifier
                .defaultMinSize(minWidth = 40.dp)
                .padding(horizontal = 6.dp),
            contentAlignment = Alignment.Center
        ) {
            Text(
                text = displayText(internal, p),
                fontSize = AppFont.sizeMd,
                color = if (disabled) disabledColor else AppColor.primary
            )
        }
        StepperButton("+", canPlus, disabledColor) { stepFn(1) }
    }
}

@Composable
private fun StepperButton(
    symbol: String,
    enabled: Boolean,
    disabledColor: Color,
    onClick: () -> Unit
) {
    Box(
        modifier = Modifier
            .width(32.dp)
            .fillMaxHeight()
            .clip(RoundedCornerShape(AppRadius.sm))
            .clickable(enabled = enabled, onClick = onClick),
        contentAlignment = Alignment.Center
    ) {
        Text(
            text = symbol,
            fontSize = AppFont.sizeLg,
            color = if (enabled) AppColor.primary else disabledColor,
            fontWeight = FontWeight.Medium
        )
    }
}

/** 定点展示：固定 precision 小数位（尾部零保留，如 50.0），避免浮点 toString 长尾。 */
private fun displayText(value: Double, precision: Int): String {
    val rounded = BigDecimal(value.toString()).setScale(precision, RoundingMode.HALF_UP).toDouble()
    return String.format(Locale.US, "%.${precision}f", rounded)
}
