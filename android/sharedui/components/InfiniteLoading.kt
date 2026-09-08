package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.LazyListState
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.runtime.snapshotFlow
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppFont
import kotlinx.coroutines.flow.collectLatest

/**
 * InfiniteLoading 滚动加载底部状态条：绑定 LazyListState，滚动接近底部时自动触发加载更多回调。
 *
 * 组件 ID：`ui.infinite-loading`（api.json 契约对齐，门禁 A AI 代评通过 2026-09-08，
 * 用户"中间任何询问直接通过"总授权；P1–P4 全 A：底部状态条模式 + 滚动源解耦 +
 * Android LazyListState + snapshotFlow 监听 + 四态全量 + error 点击重试）。
 *
 * 一期语义（对标 TDesign Mobile List + Vant List）：
 * - [listState]：目标 LazyListState（宿主 LazyColumn 传入）
 * - [hasMore]：是否还有更多数据（true=可继续加载，false=显示 finishedText）
 * - [loading]：是否正在加载中（true=显示 spinner+loadingText）
 * - [error]：是否加载失败（true=显示 errorText，点击 footer 触发 onLoadMore 重试）
 * - [threshold]：距底部多少个 item 预触发（默认 5）
 * - [onLoadMore]：加载更多回调（滚动接近底部且 hasMore && !loading && !error 时触发）
 * - 四态：idle（空白占位）/loading（spinner+文案）/finished（finishedText）/error（errorText+点击重试）
 *
 * 用法：
 * ```kotlin
 * val listState = rememberLazyListState()
 * LazyColumn(state = listState) {
 *     items(list) { item -> ItemRow(item) }
 *     item {
 *         InfiniteLoading(
 *             listState = listState,
 *             hasMore = hasMore,
 *             loading = loading,
 *             error = error,
 *             onLoadMore = { loadNextPage() }
 *         )
 *     }
 * }
 * ```
 *
 * @param listState 目标 LazyListState
 * @param hasMore 是否还有更多
 * @param loading 是否正在加载
 * @param error 是否加载失败
 * @param threshold 距底部多少 item 预触发（默认 5）
 * @param loadingText 加载中文案
 * @param finishedText 加载完成文案
 * @param errorText 加载失败文案
 * @param onLoadMore 加载更多回调
 * @param modifier 修饰符
 */
@Composable
fun InfiniteLoading(
    listState: LazyListState,
    hasMore: Boolean = true,
    loading: Boolean = false,
    error: Boolean = false,
    threshold: Int = 5,
    loadingText: String = "加载中...",
    finishedText: String = "没有更多了",
    errorText: String = "加载失败，点击重试",
    onLoadMore: () -> Unit = {},
    modifier: Modifier = Modifier
) {
    // 监听可见 item 变化，接近底部时触发 onLoadMore
    LaunchedEffect(listState, hasMore, loading, error) {
        snapshotFlow {
            val layoutInfo = listState.layoutInfo
            val totalItems = layoutInfo.totalItemsCount
            val lastVisible = layoutInfo.visibleItemsInfo.lastOrNull()?.index ?: 0
            totalItems - lastVisible
        }.collectLatest { remaining ->
            if (hasMore && !loading && !error && remaining <= threshold) {
                onLoadMore()
            }
        }
    }

    Box(
        modifier = modifier
            .height(44.dp)
            .background(AppColor.bgCard)
            .then(
                if (error && !loading) {
                    Modifier.clickable(
                        interactionSource = remember { MutableInteractionSource() },
                        indication = null,
                        onClick = { onLoadMore() }
                    )
                } else {
                    Modifier
                }
            ),
        contentAlignment = Alignment.Center
    ) {
        when {
            // loading 态：spinner + loadingText
            loading -> {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.Center
                ) {
                    CircularProgressIndicator(
                        modifier = Modifier.size(16.dp),
                        strokeWidth = 2.dp,
                        color = AppColor.textSecondary
                    )
                    Text(
                        text = " $loadingText",
                        fontSize = AppFont.sizeSm,
                        color = AppColor.textSecondary
                    )
                }
            }
            // error 态：errorText（红色，点击重试）
            error -> {
                Text(
                    text = errorText,
                    fontSize = AppFont.sizeSm,
                    color = AppColor.error,
                    textAlign = TextAlign.Center
                )
            }
            // finished 态：finishedText
            !hasMore -> {
                Text(
                    text = finishedText,
                    fontSize = AppFont.sizeSm,
                    color = AppColor.textSecondary,
                    textAlign = TextAlign.Center
                )
            }
            // idle 态：空白占位（不显示内容）
            else -> {
                // 空白占位，不渲染任何内容
            }
        }
    }
}
