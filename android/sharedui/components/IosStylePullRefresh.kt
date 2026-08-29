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
 * 对齐 iOS `UIRefreshControl`：下拉时**顶开列表**露出空白区，
 * 空白区内显示灰圈 +「下拉刷新数据」；禁止 Material 浮层盖在列表上。
 *
 * @param canPull 是否在列表顶部（LazyColumn / Scroll 到顶时为 true）
 */
@Composable
fun IosStylePullRefresh(
    isRefreshing: Boolean,
    onRefresh: () -> Unit,
    canPull: () -> Boolean,
    modifier: Modifier = Modifier,
    content: @Composable () -> Unit
) {
    val density = LocalDensity.current
    val thresholdPx = with(density) { 72.dp.toPx() }
    val maxPullPx = thresholdPx * 1.6f
    val holdPx = with(density) { 64.dp.toPx() }

    val pullAnim = remember { Animatable(0f) }
    var dragPull by remember { mutableFloatStateOf(0f) }
    var settling by remember { mutableStateOf(false) }
    val scope = rememberCoroutineScope()
    val refreshingState = rememberUpdatedState(isRefreshing)
    val onRefreshState = rememberUpdatedState(onRefresh)
    val canPullState = rememberUpdatedState(canPull)

    val displayedPull = if (isRefreshing) {
        maxOf(pullAnim.value, holdPx)
    } else {
        maxOf(pullAnim.value, dragPull)
    }

    LaunchedEffect(isRefreshing) {
        if (isRefreshing) {
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
                if (refreshingState.value) return Offset.Zero
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
                if (refreshingState.value) return Offset.Zero
                // 到顶后继续下拉 → 顶开内容
                if (available.y > 0f && canPullState.value()) {
                    val next = (dragPull + available.y * 0.55f).coerceIn(0f, maxPullPx)
                    val consumedY = next - dragPull
                    dragPull = next
                    return Offset(0f, consumedY)
                }
                return Offset.Zero
            }

            override suspend fun onPreFling(available: Velocity): Velocity {
                if (dragPull > 0f && !refreshingState.value && !settling) {
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
                    if (isRefreshing || progress >= 1f) {
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
                    if (progress > 0.15f || isRefreshing) {
                        Text(
                            text = "下拉刷新数据",
                            color = AppColor.textSecondary,
                            fontSize = AppFont.sizeSm
                        )
                    }
                }
            }
        }
    }
}

/** LazyColumn 是否在顶部，可供 [IosStylePullRefresh.canPull] 使用。 */
fun LazyListState.isAtTop(): Boolean =
    firstVisibleItemIndex == 0 && firstVisibleItemScrollOffset == 0
