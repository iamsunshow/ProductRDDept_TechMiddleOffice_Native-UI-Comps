package com.zhiqihuayun.sharedui.components

import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.gestures.detectDragGesturesAfterLongPress
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableFloatStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.unit.dp
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppFont
import com.zhiqihuayun.foundation.design.AppSpace

// 拖拽态视觉常量（与设计规格 drag-design-spec.html §4 对齐）：
// - 阴影 elevation 8dp
// - 缩放 1.02
// - 透明度 0.9
// - 落位动画 0.25s easeOut
private const val DragScale = 1.02f
private const val DragOpacity = 0.9f
private const val DropAnimMs = 250

/**
 * Drag 拖拽排序（操作反馈区 · ui.drag · #47）：通用列表拖拽排序组件。
 *
 * 实现：LazyColumn 自管滚动 + 每个 item 挂 pointerInput detectDragGesturesAfterLongPress。
 * 用 LazyColumn 而非普通 Column 的根因（v1.4.3 修复）：
 * 普通Column 嵌套在外层 verticalScroll 容器内时，外层滚动手势在长按等待期（~500ms）
 * 抢先消费触摸事件，导致 detectDragGesturesAfterLongPress 收不到 DOWN 事件而完全失效。
 * LazyColumn 自身是滚动容器，通过 nestedScroll 协议与外层 verticalScroll 协作，
 * 长按等待期手指不动则两层都不消费，detectDragGesturesAfterLongPress 正常收到 DOWN 并等待长按。
 * 落位后 LazyColumn 按 key 重组，自动刷新顺序。
 *
 * @param items 数据列表
 * @param key 唯一标识提供器
 * @param itemContent 每项渲染内容
 * @param onReorder 拖拽释放后回调（from=原索引 to=目标索引）
 * @param enabled 是否启用拖拽，默认 true
 * @param handle 是否仅手柄可拖，默认 false
 * @param modifier 修饰符（建议传固定高度，让 LazyColumn 在此高度内自管滚动）
 */
@Composable
fun <T> Drag(
    items: List<T>,
    key: (T) -> Any,
    itemContent: @Composable (T) -> Unit,
    onReorder: (Int, Int) -> Unit,
    enabled: Boolean = true,
    handle: Boolean = false,
    modifier: Modifier = Modifier,
) {
    var internalItems by remember(items) { mutableStateOf(items.toList()) }
    var draggingIndex by remember { mutableStateOf(-1) }
    var dragInitialIndex by remember { mutableStateOf(-1) }
    var dragOffset by remember { mutableFloatStateOf(0f) }

    // LazyColumn 自管滚动，隔离外层 verticalScroll 的手势干扰
    LazyColumn(
        modifier = modifier
            .fillMaxWidth()
            .testTag("drag-root"),
    ) {
        itemsIndexed(
            items = internalItems,
            key = { _, item -> key(item) }
        ) { index, item ->
            val isDragging = draggingIndex == index
            val scale by animateFloatAsState(
                targetValue = if (isDragging) DragScale else 1f,
                animationSpec = tween(DropAnimMs),
                label = "dragScale",
            )
            val alpha by animateFloatAsState(
                targetValue = if (isDragging) DragOpacity else 1f,
                animationSpec = tween(DropAnimMs),
                label = "dragAlpha",
            )

            val dragModifier = if (enabled) {
                Modifier.pointerInput(index) {
                    detectDragGesturesAfterLongPress(
                        onDragStart = {
                            draggingIndex = index
                            dragInitialIndex = index
                            dragOffset = 0f
                        },
                        onDragEnd = {
                            if (dragInitialIndex >= 0 && draggingIndex >= 0 && dragInitialIndex != draggingIndex) {
                                onReorder(dragInitialIndex, draggingIndex)
                            }
                            draggingIndex = -1
                            dragInitialIndex = -1
                            dragOffset = 0f
                        },
                        onDragCancel = {
                            draggingIndex = -1
                            dragInitialIndex = -1
                            dragOffset = 0f
                        },
                        onDrag = { change, dragAmount ->
                            change.consume()
                            dragOffset += dragAmount.y
                            while (dragOffset > 10f && draggingIndex >= 0 && draggingIndex < internalItems.lastIndex) {
                                val next = draggingIndex + 1
                                internalItems = internalItems.toMutableList().apply {
                                    val tmp = this[draggingIndex]
                                    this[draggingIndex] = this[next]
                                    this[next] = tmp
                                }
                                draggingIndex = next
                                dragOffset -= 10f
                            }
                            while (dragOffset < -10f && draggingIndex > 0) {
                                val prev = draggingIndex - 1
                                internalItems = internalItems.toMutableList().apply {
                                    val tmp = this[draggingIndex]
                                    this[draggingIndex] = this[prev]
                                    this[prev] = tmp
                                }
                                draggingIndex = prev
                                dragOffset += 10f
                            }
                        },
                    )
                }
            } else {
                Modifier
            }

            Row(
                verticalAlignment = Alignment.CenterVertically,
                modifier = Modifier
                    .fillMaxWidth()
                    .graphicsLayer {
                        this.scaleX = scale
                        this.scaleY = scale
                        this.alpha = alpha
                        if (isDragging) {
                            this.shadowElevation = 8f
                        }
                    }
                    .then(dragModifier),
            ) {
                if (handle && enabled) {
                    Box(
                        contentAlignment = Alignment.Center,
                        modifier = Modifier
                            .padding(horizontal = AppSpace.sm, vertical = AppSpace.sm)
                            .width(24.dp),
                    ) {
                        Text(
                            text = "≡",
                            fontSize = AppFont.sizeLg,
                            color = AppColor.textSecondary,
                        )
                    }
                    Spacer(modifier = Modifier.width(AppSpace.sm))
                }
                Box(modifier = Modifier.weight(1f)) {
                    itemContent(item)
                }
            }
        }
    }
}
