package com.zhiqihuayun.sharedui.components

import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.gestures.detectDragGestures
import androidx.compose.foundation.gestures.detectDragGesturesAfterLongPress
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.lazy.items
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
import androidx.compose.ui.layout.onSizeChanged
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.zIndex
import androidx.compose.ui.unit.dp
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppFont
import com.zhiqihuayun.foundation.design.AppSpace

// 拖拽态视觉常量（与设计规格 drag-design-spec.html §4 对齐 + iOS 对齐 2026-09-08）：
// - 阴影 elevation 8dp
// - 缩放 1.02
// - 透明度 0.6（与 iOS 一致，被拖动对象有可见透明度）
// - 落位动画 0.25s easeOut
// - 拖拽时 translationY 跟随手指（与 iOS 标准 reorder 一致）
// - swap 阈值=itemHeight/2，swap 后 dragOffset 减 itemHeight（保持手指相对位置）
private const val DragScale = 1.02f
private const val DragOpacity = 0.6f
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
 * pointerInput 以 key(item) 为键（v1.4.6 修复）：v1.4.2 曾改用 index 为键以修 index 过期，
 * 但拖拽中 swap 后 LazyColumn 把同一 item 的 composable 实例搬到新位置、其 index 变化，
 * 导致 pointerInput 协程被取消重启、拖拽手势在首次 swap 即中断（“Android 上依然不可用”）。
 * 改回 itemKey 为键后同一 item 跨 swap 持有同一协程，当前位置用 internalItems.indexOf(item)
 * 实时计算，既不依赖捕获的 index、也不怕过期。handle=true 时手势挂到手柄 Box、整行不响应。
 *
 * @param items 数据列表
 * @param key 唯一标识提供器
 * @param itemContent 每项渲染内容
 * @param onReorder 拖拽释放后回调（from=原索引 to=目标索引）
 * @param enabled 是否启用拖拽，默认 true
 * @param handle 是否仅手柄可拖，默认 false
 * @param modifier 修饰符（建议传固定高度，让 LazyColumn 在此高度内自管滚动）
 */
@OptIn(androidx.compose.foundation.ExperimentalFoundationApi::class)
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
    // 拖拽态按 item 唯一标识跟踪（而非 index）：swap 后同一 item 的 index 会变，
    // 用 key 跟踪才能让拖拽视觉态与手势协程跨 swap 不中断。
    var draggingKey by remember { mutableStateOf<Any?>(null) }
    var dragInitialIndex by remember { mutableStateOf(-1) }
    var dragOffset by remember { mutableFloatStateOf(0f) }
    // 实测 item 高度（px）：swap 阈值=itemHeight/2，swap 后 dragOffset 减 itemHeight，
    // 让被拖动项 translationY 跟随手指并保持相对位置（与 iOS 标准 reorder 一致）。
    var itemHeight by remember { mutableFloatStateOf(0f) }

    // LazyColumn 自管滚动，隔离外层 verticalScroll 的手势干扰
    LazyColumn(
        modifier = modifier
            .fillMaxWidth()
            .testTag("drag-root"),
    ) {
        itemsIndexed(
            items = internalItems,
            key = { _, item -> key(item) }
        ) { _, item ->
            val itemKey = key(item)
            val isDragging = draggingKey == itemKey
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

            // 根因修复（v1.4.6）：pointerInput 以 itemKey 为键，而非 index。
            // v1.4.2 曾把 key 从 Unit 改成 index 以修 index 过期，却引入更严重的缺陷：
            // 拖拽中 swap 后 LazyColumn 把同一 item 的 composable 实例搬到新位置，其 index
            // 随之变化 → pointerInput(index) 的键变了 → 手势协程被取消重启 → 进行中的拖拽
            // 手势在首次 swap 时即中断（“Android 上依然不可用”的根因）。
            // 改为 key(item) 后：同一 item 跨 swap 持有同一手势协程，拖拽全程不中断；
            // 当前位置改用 internalItems.indexOf(item) 实时计算，既不依赖捕获的 index、也不怕过期。
            //
            // v1.4.7（2026-09-08）对齐 iOS 标准 reorder：
            // - swap 阈值=itemHeight/2（不再是固定 10f），手指越过相邻项中点才 swap
            // - swap 后 dragOffset 减/加 itemHeight（不再是 10f），保持手指与项的相对位置
            // - 配合 graphicsLayer.translationY=dragOffset，被拖动项跟随手指平滑移动
            val swapThreshold = if (itemHeight > 0f) itemHeight * 0.5f else 30f
            val swapStep = if (itemHeight > 0f) itemHeight else 60f
            val dragModifier = if (enabled) {
                Modifier.pointerInput(itemKey) {
                    // handle 模式用即时拖拽（与 iOS showsReorderControl 一致）；
                    // 非 handle 模式用长按拖拽（避免误触）
                    if (handle) {
                        detectDragGestures(
                            onDragStart = {
                                draggingKey = itemKey
                                dragInitialIndex = internalItems.indexOf(item)
                                dragOffset = 0f
                            },
                            onDragEnd = {
                                val curIndex = internalItems.indexOf(item)
                                if (dragInitialIndex >= 0 && curIndex >= 0 && dragInitialIndex != curIndex) {
                                    onReorder(dragInitialIndex, curIndex)
                                }
                                draggingKey = null
                                dragInitialIndex = -1
                                dragOffset = 0f
                            },
                            onDragCancel = {
                                draggingKey = null
                                dragInitialIndex = -1
                                dragOffset = 0f
                            },
                            onDrag = { change, dragAmount ->
                                change.consume()
                                dragOffset += dragAmount.y
                                var curIndex = internalItems.indexOf(item)
                                while (dragOffset > swapThreshold && curIndex >= 0 && curIndex < internalItems.lastIndex) {
                                    val next = curIndex + 1
                                    internalItems = internalItems.toMutableList().apply {
                                        val tmp = this[curIndex]
                                        this[curIndex] = this[next]
                                        this[next] = tmp
                                    }
                                    curIndex = next
                                    dragOffset -= swapStep
                                }
                                while (dragOffset < -swapThreshold && curIndex > 0) {
                                    val prev = curIndex - 1
                                    internalItems = internalItems.toMutableList().apply {
                                        val tmp = this[curIndex]
                                        this[curIndex] = this[prev]
                                        this[prev] = tmp
                                    }
                                    curIndex = prev
                                    dragOffset += swapStep
                                }
                            },
                        )
                    } else {
                        detectDragGesturesAfterLongPress(
                        onDragStart = {
                            draggingKey = itemKey
                            dragInitialIndex = internalItems.indexOf(item)
                            dragOffset = 0f
                        },
                        onDragEnd = {
                            val curIndex = internalItems.indexOf(item)
                            if (dragInitialIndex >= 0 && curIndex >= 0 && dragInitialIndex != curIndex) {
                                onReorder(dragInitialIndex, curIndex)
                            }
                            draggingKey = null
                            dragInitialIndex = -1
                            dragOffset = 0f
                        },
                        onDragCancel = {
                            draggingKey = null
                            dragInitialIndex = -1
                            dragOffset = 0f
                        },
                        onDrag = { change, dragAmount ->
                            change.consume()
                            dragOffset += dragAmount.y
                            var curIndex = internalItems.indexOf(item)
                            while (dragOffset > swapThreshold && curIndex >= 0 && curIndex < internalItems.lastIndex) {
                                val next = curIndex + 1
                                internalItems = internalItems.toMutableList().apply {
                                    val tmp = this[curIndex]
                                    this[curIndex] = this[next]
                                    this[next] = tmp
                                }
                                curIndex = next
                                dragOffset -= swapStep
                            }
                            while (dragOffset < -swapThreshold && curIndex > 0) {
                                val prev = curIndex - 1
                                internalItems = internalItems.toMutableList().apply {
                                    val tmp = this[curIndex]
                                    this[curIndex] = this[prev]
                                    this[prev] = tmp
                                }
                                curIndex = prev
                                dragOffset += swapStep
                            }
                        },
                    )
                    }
                }
            } else {
                Modifier
            }

            Row(
                verticalAlignment = Alignment.CenterVertically,
                modifier = Modifier
                    .animateItemPlacement()
                    .fillMaxWidth()
                    // 被拖动项置顶：zIndex=1f 让它在 LazyColumn 中渲染在其他项之上，
                    // 不被相邻项遮挡（与 iOS 标准 reorder 一致）
                    .zIndex(if (isDragging) 1f else 0f)
                    .onSizeChanged { size ->
                        if (size.height > 0) itemHeight = size.height.toFloat()
                    }
                    .graphicsLayer {
                        this.scaleX = scale
                        this.scaleY = scale
                        this.alpha = alpha
                        // 被拖动项跟随手指平滑移动（与 iOS 标准 reorder 一致）
                        this.translationY = if (isDragging) dragOffset else 0f
                        if (isDragging) {
                            this.shadowElevation = 8f
                        }
                    }
                    // handle=true：整行不挂拖拽手势（仅手柄响应）；否则整行长按拖拽。
                    .then(if (enabled && !handle) dragModifier else Modifier),
            ) {
                // 内容在左（占满剩余空间），手柄在右（与 iOS 标准 reorder 一致）
                Box(modifier = Modifier.weight(1f)) {
                    itemContent(item)
                }
                if (handle && enabled) {
                    Spacer(modifier = Modifier.width(AppSpace.sm))
                    Box(
                        contentAlignment = Alignment.Center,
                        modifier = Modifier
                            .padding(horizontal = AppSpace.sm, vertical = AppSpace.sm)
                            .width(24.dp)
                            // 手柄承载拖拽手势：handle 模式下仅 ≡ 手柄可触发，整行不响应。
                            .then(dragModifier),
                    ) {
                        Text(
                            text = "≡",
                            fontSize = AppFont.sizeLg,
                            color = AppColor.textSecondary,
                        )
                    }
                }
            }
        }
    }
}
