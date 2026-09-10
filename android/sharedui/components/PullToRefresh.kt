// PullToRefresh 下拉刷新（Android Compose 版，对齐 iOS PullRefreshView.swift / api.json `ui.refresh`）。
//
// 组件 ID：`ui.refresh` ｜ 任务清单 #55 ｜ 操作反馈区第十一件 ｜ TMO 组件库 v1.4.13
//
// 定位：列表/可滚动内容下拉触发刷新的容器组件——用户在内容顶部下拉，顶开内容露出刷新指示器
// （灰圈+文案），松手达到阈值触发 onRefresh 回调，业务完成后将 refreshing 设为 false 收起指示器。
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
// - 触发阈值 threshold = 72dp，maxPull = threshold × 1.6，hold = 64dp
// - 指示器圆圈：22×22，strokeWidth=2，color=textSecondary
//   - 下拉中=进度环（progress = pull / threshold）
//   - 刷新中=旋转环
// - 文案：textSecondary + sizeSm（14），下拉距离 > 15% 阈值时显示
// - 收起动画：tween 220ms
// - 阻尼系数：0.55
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
import androidx.compose.material3.CircularProgressIndicator
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
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.input.nestedscroll.NestedScrollConnection
import androidx.compose.ui.input.nestedscroll.NestedScrollSource
import androidx.compose.ui.input.nestedscroll.nestedScroll
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.unit.Velocity
import androidx.compose.ui.unit.dp
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppFont
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
                    val next = (dragPull + available.y * 0.7f).coerceIn(0f, maxPullPx)
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
                        CircularProgressIndicator(
                            color = AppColor.textSecondary,
                            strokeWidth = 2.dp,
                            modifier = Modifier.size(22.dp)
                        )
                    } else if (progress > 0.05f) {
                        CircularProgressIndicator(
                            progress = { progress },
                            color = AppColor.textSecondary,
                            strokeWidth = 2.dp,
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
