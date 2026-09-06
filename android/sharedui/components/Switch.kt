package com.zhiqihuayun.sharedui.components

import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.animateDpAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
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
import androidx.compose.ui.unit.dp
import com.zhiqihuayun.foundation.design.AppColor

// 轨道/滑块几何常量：轨道 48 宽=交互行基准注释锚定（同 Input/FormFieldRow min48 语义），
// 28 高=20 滑块+上下内衬各 4（spaceXs）；滑块 20=对齐 CheckboxGlyph/RadioGlyph 20 惯例；
// 行程 20 = 48 − 2×4(内衬) − 20(滑块)；轨道圆角 full=14=半高。
private val TrackWidth = 48.dp
private val TrackHeight = 28.dp
private val ThumbSize = 20.dp
private val ThumbInset = 4.dp
private val ThumbTravel = 20.dp // 行程 = TrackWidth - 2*ThumbInset - ThumbSize
private val ToggleDurationMs = 180 // 0.18s 同 FixedNav 展开/收起动效时长惯例

/**
 * Switch 开关（数据录入组件 #41，ui.switch）：通用二元即时开关核组件。
 *
 * 视觉：轨道 48×28 radiusFull，on=primary 填充 + 白色滑块居右；off=textSecondary(alpha0.3) 浅灰 + 白色滑块居左。
 * 语义：checked: Boolean? 半受控——nil=内部自持初始 off（点按翻转并回调）；外部赋值 checked=驱动回显
 *（同步渲染，不触发 onCheckedChange）；on→off 与 off→on 均回调。
 * disabled：整件 alpha0.4 不可点无回调；on+disabled=灰 primary 轨道灰滑块保留开态（只读回显）。
 * 动画：滑块位移 + 轨道变色 0.18s。无内置 label：label 文案=宿主行首（FormFieldRow #28 / Cell 行尾嵌用）。
 */
@Composable
fun Switch(
    checked: Boolean? = null,
    onCheckedChange: ((Boolean) -> Unit)? = null,
    disabled: Boolean = false,
    modifier: Modifier = Modifier
) {
    // 内部自持态：nil=自持初始 off；外部赋值仅在值不同时同步（LaunchedEffect 驱动回显，不触发回调）
    var internalChecked by remember { mutableStateOf(checked ?: false) }
    LaunchedEffect(checked) {
        val external = checked ?: return@LaunchedEffect
        if (internalChecked != external) internalChecked = external
    }

    // 滑块位移 + 轨道变色（0.18s，两端 1:1）
    val thumbX by animateDpAsState(
        targetValue = if (internalChecked) ThumbInset + ThumbTravel else ThumbInset,
        animationSpec = tween(durationMillis = ToggleDurationMs),
        label = "switchThumbX"
    )
    val trackColor by animateColorAsState(
        targetValue = if (internalChecked) AppColor.primary else AppColor.textSecondary.copy(alpha = 0.3f),
        animationSpec = tween(durationMillis = ToggleDurationMs),
        label = "switchTrackColor"
    )

    Box(
        modifier = modifier
            .size(TrackWidth, TrackHeight)
            .alpha(if (disabled) 0.4f else 1f)
            .clip(RoundedCornerShape(50))
            .background(trackColor)
            .clickable(enabled = !disabled) {
                val next = !internalChecked
                internalChecked = next
                onCheckedChange?.invoke(next)
            }
    ) {
        Box(
            Modifier
                .align(Alignment.CenterStart)
                .offset(x = thumbX)
                .size(ThumbSize)
                .clip(RoundedCornerShape(50))
                .background(Color.White)
        )
    }
}
