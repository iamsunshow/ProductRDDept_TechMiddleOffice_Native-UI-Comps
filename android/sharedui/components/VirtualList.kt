// VirtualList 虚拟列表组件（Compose 版，对齐 iOS VirtualListView）。
//
// 大数据量虚拟滚动列表：仅渲染可见区域 item，支持分隔线、下拉刷新占位、item 点击。
// 底层使用 LazyColumn（Compose 内置虚拟化），万级数据不卡顿。

package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppFont
import com.zhiqihuayun.foundation.design.AppSpace

/**
 * 虚拟列表项数据。
 *
 * @param title 主标题
 * @param subtitle 副标题（可选）
 */
data class VirtualListItem(
    val title: String,
    val subtitle: String? = null,
)

/**
 * 虚拟列表组件。
 *
 * @param items 数据列表
 * @param onItemClick 点击回调
 * @param itemHeight 每项固定高度（null 时自适应）
 * @param showSeparator 是否显示分隔线
 * @param header 列表头部 composable（可选）
 * @param emptyText 空数据提示文案
 */
@Composable
fun VirtualList(
    items: List<VirtualListItem>,
    onItemClick: ((Int) -> Unit)? = null,
    itemHeight: Dp? = 56.dp,
    showSeparator: Boolean = true,
    header: (@Composable () -> Unit)? = null,
    emptyText: String = "暂无数据",
) {
    val listState = rememberLazyListState()

    if (items.isEmpty()) {
        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(AppColor.bgPage),
            contentAlignment = Alignment.Center,
        ) {
            Text(
                text = emptyText,
                color = AppColor.textSecondary,
                fontSize = AppFont.sizeSm,
            )
        }
        return
    }

    LazyColumn(
        state = listState,
        modifier = Modifier
            .fillMaxSize()
            .background(AppColor.bgPage),
    ) {
        // 可选 header
        if (header != null) {
            item { header() }
        }

        itemsIndexed(items) { index, item ->
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .then(
                        if (itemHeight != null) Modifier.height(itemHeight) else Modifier,
                    )
                    .background(AppColor.bgCard)
                    .clickable { onItemClick?.invoke(index) }
                    .padding(horizontal = AppSpace.lg, vertical = AppSpace.sm),
                verticalArrangement = androidx.compose.foundation.layout.Arrangement.Center,
            ) {
                Text(
                    text = item.title,
                    color = AppColor.textPrimary,
                    fontSize = AppFont.sizeMd,
                    fontWeight = FontWeight.Medium,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                )
                if (item.subtitle != null) {
                    Spacer(modifier = Modifier.height(2.dp))
                    Text(
                        text = item.subtitle,
                        color = AppColor.textSecondary,
                        fontSize = AppFont.sizeSm,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis,
                    )
                }
            }

            // 分隔线
            if (showSeparator && index < items.lastIndex) {
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(0.5.dp)
                        .background(AppColor.border),
                )
            }
        }
    }
}
