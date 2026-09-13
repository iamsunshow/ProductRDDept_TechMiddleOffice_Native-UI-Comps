// PullToRefresh 下拉刷新（Android Compose 版，对齐 iOS PullRefreshView.swift / api.json `ui.refresh`）。
//
// 组件 ID：`ui.refresh` ｜ 任务清单 #55 ｜ 操作反馈区第十一件 ｜ TMO 组件库 v1.4.13
//
// 定位：列表/可滚动内容下拉触发刷新的容器组件——用户在内容顶部下拉，顶开内容露出刷新指示器
// （菊花+文案），松手达到阈值触发 onRefresh 回调，业务完成后将 refreshing 设为 false 收起指示器。
// 采用 iOS 风格（非浮层顶开内容），与 iOS UIRefreshControl 视觉对齐。
//
// 契约 @param（与 api.json 100% 对齐）：
// - refreshing: Boolean（*必选*：true=显示刷新指示器（旋转中），false=收起）
// - content: @Composable（*必选*：可滚动内容，宿主提供 LazyColumn/Scroll 等）
// - onRefresh: () -> Unit（*必选*：下拉达到阈值松手时触发）
// - title: String = "下拉刷新数据"（刷新文案）
// - enabled: Boolean = true（是否允许下拉刷新）
//
// Android 特有参数（diff-api 登记，iOS 由 UIRefreshControl 自动处理）：
// - canPull: () -> Boolean = { true }（内容是否在顶部，宿主传入如 { listState.isAtTop() }）
//
// 设计规格（design-spec/refresh-design-spec.html）：
// - 触发阈值 threshold = 56dp，maxPull = threshold × 1.6，hold = 48dp
// - 指示器：菊花式（8 花瓣绕圆心旋转，递进透明度），22×22，color=textSecondary
//   - 下拉中=静态菊花（不旋转，progress = pull / threshold 控制透明度）
//   - 刷新中=旋转菊花（与 iOS UIRefreshControl 视觉一致）
// - 文案：textSecondary + sizeSm（14），下拉距离 > 15% 阈值时显示
// - 收起动画：tween 220ms
// - 阻尼系数：0.5（v1.8.8 由 0.7 调降，用户反馈 D1/D2/D3 难触发，0.7 阻尼下拉不跟手）
//
// 用法：
// ```kotlin
// val listState = rememberLazyListState()
// var refreshing by remember { mutableStateOf(false) }
// PullToRefresh(
//     refreshing = refreshing,
//     onRefresh = {
//         refreshing = true
//         viewModel.loadData { refreshing = false }
//     },
//     canPull = { listState.isAtTop() }
// ) {
//     LazyColumn(state = listState) { ... }
// }
// ```

package com.zhiqihuayun.sharedui.components

import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.LazyListState
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableFloatStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.rememberUpdatedState
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clipToBounds
import androidx.compose.ui.draw.rotate
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.drawscope.rotate
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.input.nestedscroll.NestedScrollConnection
import androidx.compose.ui.input.nestedscroll.NestedScrollSource
import androidx.compose.ui.input.nestedscroll.nestedScroll
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.unit.Velocity
import androidx.compose.ui.unit.dp
import androidx.compose.foundation.Canvas
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppFont
import kotlin.math.PI
import kotlin.math.cos
import kotlin.math.sin
import kotlinx.coroutines.launch

/**
 * 下拉刷新容器。
 *
 * @param refreshing 受控刷新状态（true=显示指示器，false=收起）
 * @param onRefresh 下拉达到阈值松手时触发
 * @param title 刷新文案，默认 "下拉刷新数据"
 * @param enabled 是否允许下拉刷新，默认 true
 * @param canPull 内容是否在顶部（Android 特有，iOS 由 UIRefreshControl 自动处理）
 * @param modifier 布局修饰符
 * @param content 可滚动内容
 */
@Composable
fun PullToRefresh(
    refreshing: Boolean,
    onRefresh: () -> Unit,
    title: String = "下拉刷新数据",
    enabled: Boolean = true,
    canPull: () -> Boolean = { true },
    modifier: Modifier = Modifier,
    content: @Composable () -> Unit
) {
    val density = LocalDensity.current
    val thresholdPx = with(density) { 56.dp.toPx() }
    val maxPullPx = thresholdPx * 1.6f
    val holdPx = with(density) { 48.dp.toPx() }

    val pullAnim = remember { Animatable(0f) }
    var dragPull by remember { mutableFloatStateOf(0f) }
    var settling by remember { mutableStateOf(false) }
    val scope = rememberCoroutineScope()
    val refreshingState = rememberUpdatedState(refreshing)
    val onRefreshState = rememberUpdatedState(onRefresh)
    val canPullState = rememberUpdatedState(canPull)
    val enabledState = rememberUpdatedState(enabled)

    val displayedPull = if (refreshing) {
        maxOf(pullAnim.value, holdPx)
    } else {
        maxOf(pullAnim.value, dragPull)
    }

    LaunchedEffect(refreshing) {
        if (refreshing) {
            pullAnim.snapTo(holdPx)
            dragPull = holdPx
        } else {
            dragPull = 0f
            pullAnim.animateTo(0f, animationSpec = tween(220))
        }
    }

    val connection = remember {
        object : NestedScrollConnection {
            override fun onPreScroll(available: Offset, source: NestedScrollSource): Offset {
                if (refreshingState.value || !enabledState.value) return Offset.Zero
                // 下拉（available.y > 0）且在顶部 → 主动拦截消费，顶开内容
                // （之前用 onPostScroll 只拿子组件剩余，LazyColumn 顶部下拉时自消费导致不灵敏）
                if (available.y > 0f && canPullState.value()) {
                    // 阻尼 0.5（v1.8.8 由 0.7 调降）：用户反馈 D1/D2/D3 难触发，
                    // 0.7 阻尼下拉不跟手需拉更远才达阈值；0.5 后下拉距离与露出空白 1:2，
                    // 主观"轻拉即触发"，与 iOS UIRefreshControl 顺畅度对齐。
                    val next = (dragPull + available.y * 0.5f).coerceIn(0f, maxPullPx)
                    val consumedY = next - dragPull
                    dragPull = next
                    return Offset(0f, consumedY)
                }
                // 上推时先收起已露出的空白区
                if (available.y < 0f && dragPull > 0f) {
                    val consumed = available.y.coerceAtLeast(-dragPull)
                    dragPull += consumed
                    return Offset(0f, consumed)
                }
                return Offset.Zero
            }

            override fun onPostScroll(
                consumed: Offset,
                available: Offset,
                source: NestedScrollSource
            ): Offset {
                // onPreScroll 已主动拦截下拉，这里不再处理
                return Offset.Zero
            }

            override suspend fun onPreFling(available: Velocity): Velocity {
                if (dragPull > 0f && !refreshingState.value && !settling && enabledState.value) {
                    val distance = dragPull
                    settling = true
                    scope.launch {
                        try {
                            if (distance >= thresholdPx) {
                                pullAnim.snapTo(holdPx)
                                dragPull = holdPx
                                onRefreshState.value()
                            } else {
                                dragPull = 0f
                                pullAnim.snapTo(distance)
                                pullAnim.animateTo(0f, animationSpec = tween(200))
                            }
                        } finally {
                            settling = false
                        }
                    }
                    return available
                }
                return Velocity.Zero
            }
        }
    }

    Box(
        modifier = modifier
            .fillMaxSize()
            .clipToBounds()
            .background(AppColor.bgCard)
            .nestedScroll(connection)
    ) {
        // 列表被顶开：整体下移
        Box(
            modifier = Modifier
                .fillMaxSize()
                .graphicsLayer { translationY = displayedPull }
        ) {
            content()
        }
        // 露出的空白区（列表上方），非浮层
        if (displayedPull > 0.5f) {
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(with(density) { displayedPull.toDp() })
                    .background(AppColor.bgCard),
                contentAlignment = Alignment.Center
            ) {
                Column(
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.spacedBy(6.dp)
                ) {
                    val progress = (displayedPull / thresholdPx).coerceIn(0f, 1f)
                    if (refreshing || progress >= 1f) {
                        // 刷新中=旋转菊花（与 iOS UIRefreshControl 系统菊花视觉一致）
                        IOSActivityIndicator(
                            color = AppColor.textSecondary,
                            modifier = Modifier.size(22.dp)
                        )
                    } else if (progress > 0.05f) {
                        // 下拉中=静态菊花（不旋转，progress 控制整体透明度）
                        IOSActivityIndicator(
                            color = AppColor.textSecondary,
                            progress = progress,
                            modifier = Modifier.size(22.dp)
                        )
                    }
                    if (progress > 0.15f || refreshing) {
                        Text(
                            text = title,
                            color = AppColor.textSecondary,
                            fontSize = AppFont.sizeSm,
                            modifier = Modifier.fillMaxWidth(),
                            textAlign = androidx.compose.ui.text.style.TextAlign.Center
                        )
                    }
                }
            }
        }
    }
}

/** LazyColumn 是否在顶部，可供 [PullToRefresh.canPull] 使用。 */
fun LazyListState.isAtTop(): Boolean =
    firstVisibleItemIndex == 0 && firstVisibleItemScrollOffset == 0

/**
 * iOS 风格菊花式活动指示器（v1.8.8 新增，对齐 iOS UIRefreshControl 系统 UIActivityIndicator）。
 *
 * 8 花瓣绕圆心均匀分布（每 45°），每花瓣按索引递进透明度（菊花式"追光"效果），
 * 刷新中整体绕圆心 1s/圈线性无限旋转。
 *
 * 与 [androidx.compose.material3.CircularProgressIndicator]（圆环）视觉差异：
 * - 圆环=连续描边圆，进度=弧长
 * - 菊花=8 离散花瓣，进度=花瓣透明度
 *
 * @param color 花瓣颜色，默认 [AppColor.textSecondary]
 * @param progress 0..1，下拉中静态菊花整体透明度；null=刷新中旋转菊花（默认 null）
 * @param modifier 布局修饰符，建议传 size(22.dp)
 */
@Composable
fun IOSActivityIndicator(
    color: Color = AppColor.textSecondary,
    progress: Float? = null,
    modifier: Modifier = Modifier,
) {
    // 刷新中（progress=null）整体绕圆心旋转，1s/圈线性无限循环
    val rotation: Float = if (progress == null) {
        val transition = rememberInfiniteTransition(label = "ios-activity-rotation")
        transition.animateFloat(
            initialValue = 0f,
            targetValue = 360f,
            animationSpec = infiniteRepeatable(
                animation = tween(durationMillis = 1000, easing = LinearEasing),
                repeatMode = RepeatMode.Restart,
            ),
            label = "ios-activity-angle",
        ).value
    } else {
        // 静态菊花：恒 0° 不旋转
        0f
    }

    val petalCount = 8
    val alphaStep = 1f / petalCount
    // 整体透明度：下拉中按 progress 渐入，刷新中恒 1
    val overallAlpha = progress ?: 1f

    Canvas(
        modifier = modifier.graphicsLayer { this.alpha = overallAlpha }
    ) {
        val centerX = size.width / 2f
        val centerY = size.height / 2f
        // 花瓣=圆点：半径≈0.065×尺寸（22dp → 半径 1.43dp，直径 2.86dp）
        val petalRadius = size.minDimension * 0.065f
        // 花瓣圆心距整体中心≈0.27×尺寸（让花瓣远端贴近外圈）
        val orbitRadius = size.minDimension * 0.27f

        rotate(degrees = rotation, pivot = Offset(centerX, centerY)) {
            for (i in 0 until petalCount) {
                val angleDeg = i * (360f / petalCount)
                val angleRad = (angleDeg * PI / 180f).toFloat()
                val petalCenterX = centerX + orbitRadius * cos(angleRad)
                val petalCenterY = centerY + orbitRadius * sin(angleRad)
                // 花瓣按索引递进透明度（菊花式"追光"效果）
                val petalAlpha = (i + 1) * alphaStep
                drawCircle(
                    color = color.copy(alpha = petalAlpha),
                    radius = petalRadius,
                    center = Offset(petalCenterX, petalCenterY),
                )
            }
        }
    }
}
