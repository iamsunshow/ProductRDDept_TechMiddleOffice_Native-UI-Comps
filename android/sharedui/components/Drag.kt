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
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
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
 * 视觉锚点：列表项由 itemContent 渲染（Drag 不强制样式）；拖拽态 elevation 8dp + scale 1.02 + opacity 0.9；
 * 手柄 24×24 fontLg textSecondary；落位动画 0.25s easeOut。
 *
 * 语义：items 数据列表 + onReorder(from,to) 拖拽释放后回调新位置；
 * enabled=false=纯列表不可拖；handle=true=仅手柄可拖（≡ 左侧 24dp），handle=false=整行长按拖拽。
 *
 * 划界勿混：SwipeAction #19 横滑操作菜单 vs Drag 纵向拖拽排序；
 * IosStylePullRefresh #55 下拉刷新 vs Drag 长按拖拽；Tabs #20 横向页签 vs Drag 纵向排序。
 *
 * 实现：LazyColumn + Modifier.pointerInput { detectDragGesturesAfterLongPress }。
 * 拖拽中实时 swap 显示位置（视觉跟随手指）；落位 onDragEnd 仅触发一次 onReorder(initialIndex, finalIndex)。
 * 落位动画 0.25s easeOut 由 animateFloatAsState(tween(250)) 驱动 scale/alpha 还原。
 *
 * @param items 数据列表
 * @param key 唯一标识提供器（用作 LazyColumn key，避免重组错位）
 * @param itemContent 每项渲染内容
 * @param onReorder 拖拽释放后回调（from=原索引 to=目标索引）；拖拽中不触发，仅落位一次
 * @param enabled 是否启用拖拽，默认 true；false=纯列表不可拖
 * @param handle 是否仅手柄可拖，默认 false；true=左侧 ≡ 24dp 手柄触发拖拽，false=整行长按触发
 * @param modifier 修饰符
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
    // 本地可变数据源：拖拽中实时 swap 显示位置，对外仅在落位时通过 onReorder 通知。
    var internalItems by remember(items) { mutableStateOf(items.toList()) }
    val listState = rememberLazyListState()
    // 当前正在拖拽的索引（-1=未拖拽）；用于给被拖项叠加 elevation/scale/opacity 视觉。
    var draggingIndex by remember { mutableStateOf(-1) }
    // 拖拽起始索引：落位时与最终索引一起回 onReorder(from=initial, to=final)。
    var dragInitialIndex by remember { mutableStateOf(-1) }

    LazyColumn(
        state = listState,
        modifier = modifier
            .fillMaxWidth()
            .testTag("drag-root"),
    ) {
        itemsIndexed(
            items = internalItems,
            key = { _, item -> key(item) },
        ) { index, item ->
            val isDragging = draggingIndex == index
            // 拖拽态视觉：elevation 8dp（graphicsLayer shadow）+ scale 1.02 + opacity 0.9（对齐设计规格）。
            // 落位还原动画 0.25s easeOut（tween(250) 默认 easing 即 EaseOut）。
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

            // 拖拽手势处理：handle=false=整行长按；handle=true=手柄 Box 内单独挂 pointerInput。
            // 注意：detectDragGesturesAfterLongPress 已自带长按识别（不另加 LongPressGesture）。
            val dragModifier = if (enabled && !handle) {
                Modifier.pointerInput(internalItems) {
                    detectDragGesturesAfterLongPress(
                        onDragStart = {
                            draggingIndex = index
                            dragInitialIndex = index
                        },
                        onDragEnd = {
                            // 落位回调：from=dragInitialIndex, to=最终位置（draggingIndex=最终位置）。
                            // 仅触发一次（落位时刻）；拖拽中的 swap 不触发 onReorder。
                            if (dragInitialIndex >= 0 && draggingIndex >= 0 && dragInitialIndex != draggingIndex) {
                                onReorder(dragInitialIndex, draggingIndex)
                            }
                            draggingIndex = -1
                            dragInitialIndex = -1
                        },
                        onDragCancel = {
                            draggingIndex = -1
                            dragInitialIndex = -1
                        },
                        onDrag = { change, dragAmount ->
                            change.consume()
                            // 按累积位移阈值 swap：每超过 ~10f 即与上/下项 swap，
                            // 阈值小=跟手灵敏；过大=迟钝。10f 经验值。
                            val delta = dragAmount.y
                            if (delta > 10f && index < internalItems.lastIndex) {
                                val next = index + 1
                                internalItems = internalItems.toMutableList().apply {
                                    val tmp = this[index]
                                    this[index] = this[next]
                                    this[next] = tmp
                                }
                                draggingIndex = next
                            } else if (delta < -10f && index > 0) {
                                val prev = index - 1
                                internalItems = internalItems.toMutableList().apply {
                                    val tmp = this[index]
                                    this[index] = this[prev]
                                    this[prev] = tmp
                                }
                                draggingIndex = prev
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
                        // 阴影 8dp：Compose graphicsLayer shadowColor+shadowElevation（API 28+）。
                        if (isDragging) {
                            this.shadowElevation = 8f
                        }
                    }
                    .then(dragModifier),
            ) {
                if (handle && enabled) {
                    // handle=true=左侧 24dp 手柄（≡），手柄挂 pointerInput 触发拖拽；
                    // 整行不再挂拖拽手势（仅手柄可拖）。
                    Box(
                        contentAlignment = Alignment.Center,
                        modifier = Modifier
                            .padding(
                                horizontal = AppSpace.sm,
                                vertical = AppSpace.sm,
                            )
                            .width(24.dp)
                            .pointerInput(internalItems) {
                                detectDragGesturesAfterLongPress(
                                    onDragStart = {
                                        draggingIndex = index
                                        dragInitialIndex = index
                                    },
                                    onDragEnd = {
                                        if (dragInitialIndex >= 0 && draggingIndex >= 0 && dragInitialIndex != draggingIndex) {
                                            onReorder(dragInitialIndex, draggingIndex)
                                        }
                                        draggingIndex = -1
                                        dragInitialIndex = -1
                                    },
                                    onDragCancel = {
                                        draggingIndex = -1
                                        dragInitialIndex = -1
                                    },
                                    onDrag = { change, dragAmount ->
                                        change.consume()
                                        val delta = dragAmount.y
                                        if (delta > 10f && index < internalItems.lastIndex) {
                                            val next = index + 1
                                            internalItems = internalItems.toMutableList().apply {
                                                val tmp = this[index]
                                                this[index] = this[next]
                                                this[next] = tmp
                                            }
                                            draggingIndex = next
                                        } else if (delta < -10f && index > 0) {
                                            val prev = index - 1
                                            internalItems = internalItems.toMutableList().apply {
                                                val tmp = this[index]
                                                this[index] = this[prev]
                                                this[prev] = tmp
                                            }
                                            draggingIndex = prev
                                        }
                                    },
                                )
                            },
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
