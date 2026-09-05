package com.zhiqihuayun.sharedui.components

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.foundation.ScrollState
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.defaultMinSize
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.text.BasicText
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.runtime.snapshotFlow
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppFont
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch

/**
 * BackTop 返回顶部悬浮钮：绑定滚动状态，滚动超过阈值后淡入显示，点击回滚到顶。
 *
 * 组件 ID：`ui.back-top`（api.json 契约对齐，门禁 A AI 代评通过 2026-09-04，
 * 用户"中间任何询问直接通过"总授权；P1–P4 全 A：浮层按钮模式 + 滚动源解耦 +
 * Android scrollState + snapshotFlow 监听）。
 *
 * 一期语义（对标 NutUI React BackTop）：
 * - [scrollState]：目标滚动状态（Column verticalScroll / LazyColumn 均传其 state）
 * - [appearAfterPx]：滚动位移超过该值（px）后显示，默认 120
 * - [onClick]：点击回调；默认执行 scrollState.animateScrollTo(0)
 * - 默认视觉 = 主色圆钮 + 白色 ↑ 文本（零图片依赖）；内容可整体替换
 * - 位置由宿主容器自行摆放（组件不代管布局上下文），显隐为淡入淡出不占布局位
 *
 * 用法：
 * ```kotlin
 * val scrollState = rememberScrollState()
 * Box {
 *     Column(Modifier.verticalScroll(scrollState)) { /* 长内容 */ }
 *     BackTop(scrollState = scrollState, modifier = Modifier.align(Alignment.BottomEnd))
 * }
 * ```
 *
 * @param scrollState 目标滚动状态
 * @param modifier 用于摆放（如 align BottomEnd、padding）
 * @param appearAfterPx 出现阈值（px）
 * @param onClick 点击回调（null=使用默认回顶动画）
 * @param content 按钮内容（默认主色 ↑ 圆钮）
 */
@Composable
fun BackTop(
    scrollState: ScrollState,
    modifier: Modifier = Modifier,
    appearAfterPx: Int = 120,
    onClick: (() -> Unit)? = null,
    content: @Composable () -> Unit = { BackTopDefaultFace() }
) {
    var visible by remember { mutableStateOf(false) }
    val scope = rememberCoroutineScope()
    LaunchedEffect(scrollState) {
        snapshotFlow { scrollState.value }.collectLatest { value ->
            visible = value > appearAfterPx
        }
    }
    AnimatedVisibility(
        visible = visible,
        modifier = modifier,
        enter = fadeIn(),
        exit = fadeOut()
    ) {
        Box(
            modifier = Modifier
                .clip(CircleShape)
                .background(AppColor.primary)
                .clickable(
                    interactionSource = remember { MutableInteractionSource() },
                    indication = null,
                    onClick = {
                        if (onClick != null) {
                            onClick.invoke()
                        } else {
                            scope.launch { scrollState.animateScrollTo(0) }
                        }
                    }
                )
                .defaultMinSize(minWidth = 40.dp, minHeight = 40.dp),
            contentAlignment = Alignment.Center
        ) {
            content()
        }
    }
}

/** BackTop 默认视觉：白色 ↑（U+2191）文本。 */
@Composable
private fun BackTopDefaultFace() {
    BasicText(
        text = "↑",
        style = TextStyle(
            fontSize = AppFont.sizeLg,
            fontWeight = FontWeight.Bold,
            color = Color.White
        )
    )
}
