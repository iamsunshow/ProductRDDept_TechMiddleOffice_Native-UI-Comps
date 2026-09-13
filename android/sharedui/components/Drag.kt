package com.zhiqihuayun.sharedui.components

import androidx.compose.animation.core.EaseOut
import androidx.compose.animation.core.FastOutSlowInEasing
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.snap
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.background
import androidx.compose.foundation.gestures.detectDragGestures
import androidx.compose.foundation.gestures.detectDragGesturesAfterLongPress
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableFloatStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.RectangleShape
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.draw.drawWithContent
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.layout.onSizeChanged
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.zIndex
import androidx.compose.ui.unit.dp
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppFont
import com.zhiqihuayun.foundation.design.AppSpace

// 拖拽态视觉常量（与设计规格 drag-design-spec.html §4 对齐 + iOS 对齐 2026-09-13）：
// - 每条 cell 底部阴影=自绘顶部渐变带（对齐 iOS DragListView willDisplay：
//   layer.shadow 黑 opacity 0.15 / offset(0,4) / radius 8；实测 iOS 相邻 cell 分界处
//   最深处 (229,229,229)≈alpha 0.10、向下渐隐约 22pt 到纯白）
//   ★ v1.9.30：旧实现 Modifier.shadow(2.dp) 阴影被后绘制的相邻 item 完全覆盖（LazyColumn
//     中 item 无间隙、后绘制者在上），Android 上等于没有底部阴影（用户 2026-09-13 反馈
//     "iOS 每条 Cell 底部都有阴影，Android 没有"）。渐变带画在 item 自身 bounds 内，
//     不会被相邻 item 覆盖，与 iOS 视觉 1:1。
// - 缩放 1.02
// - 透明度 1.0（★ v1.9.32：由 0.75/0.9 的"半透明观感"改为不透明整块——用户 2026-09-13 反馈
//   "iOS 拖动时被拖动项是整体被拖动、背景就是白色背景"，故拖动项须呈实心白色整块；
//   半透明会让白色底与列表白底叠加，视觉上"看不出整块在动"）
// - ★ v1.9.32 根因修复：拖拽态变换（scale/alpha/translationY）的 graphicsLayer 必须置于
//   background/shadow/drawWithContent 之前。Compose 修饰符「左侧为外层」，旧实现把
//   graphicsLayer 放在链末（最内层）→ 只变换了 Row 的子内容，白色背景/阴影/阴影带留在槽位
//   不动，造成"被拖动项感觉只有图标文字在动、Cell 主体待在原地"（与 Swipe v1.9.31
//   background/offset 顺序同源问题）。
// - 落位动画 0.25s easeOut（拖动结束 translationY 平滑回落到槽位，对齐 iOS 落位 0.25s）
// - 拖拽时 translationY 跟随手指（与 iOS 标准 reorder 一致）
// - swap 阈值=itemHeight/2，swap 后 dragOffset 减 itemHeight（保持手指相对位置）
// - item 位置交换动画 0.35s FastOutSlowIn（v1.9.30：300→350 + EaseOut→FastOutSlowIn，
//   用户反馈 Android 互换动画"过快、不够丝滑"；对齐 iOS 标准 reorder 的平滑感）
// - 被拖动项自身禁用 placement 动画（tween(0)）：其槽位在 swap 时瞬移 itemHeight，
//   若同时跑 300ms placement 动画会与 graphicsLayer.translationY 抵消产生"回跳再追赶"
//   的顿挫感（用户反馈"不算丝滑"的根因之一）
private const val DragScale = 1.02f
private const val DragOpacity = 1.0f
private const val DropAnimMs = 250
private const val ItemPlaceAnimMs = 350

/// 底部阴影渐变带高度（dp）与最深处不透明度：对齐 iOS willDisplay 实测值（≈22pt / alpha 0.10）。
private val CellShadowHeight = 22.dp
private const val CellShadowAlpha = 0.10f

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
@OptIn(ExperimentalFoundationApi::class)
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
        ) { index, item ->
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
            // v1.9.30：落位动画——拖动结束 translationY 从残留偏移平滑回落到槽位（0.25s easeOut），
            // 对齐 iOS 松手后 cell 归位动画；拖拽中 snap 即时跟手（不引入额外延迟）。
            val animatedDragOffset by animateFloatAsState(
                targetValue = if (isDragging) dragOffset else 0f,
                animationSpec = if (isDragging) snap() else tween(DropAnimMs, easing = EaseOut),
                label = "dragTranslation",
            )
            // v1.9.30：底部阴影——每条 cell 顶部画向下渐隐的阴影带（模拟上方 cell 投下的阴影），
            // 首条不画（对齐 iOS：首条 cell 上方无阴影、末条下方无阴影）。
            val hasTopShadow = index > 0

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
                    // item 位置交换动画（v1.9.30：300ms EaseOut → 350ms FastOutSlowIn，
                    // 对齐 iOS 标准 reorder 的平滑感；用户反馈 Android 互换动画"过快、不够丝滑"）。
                    // ★ 被拖动项自身用 tween(0) 瞬时让位：其槽位在 swap 时瞬移 itemHeight，
                    //   若同时跑 placement 动画会与 graphicsLayer.translationY 相互抵消，
                    //   产生"先回跳再追赶"的顿挫（用户反馈不够丝滑的根因之一）。
                    .animateItemPlacement(
                        animationSpec = if (isDragging) {
                            tween(0)
                        } else {
                            tween(ItemPlaceAnimMs, easing = FastOutSlowInEasing)
                        }
                    )
                    .fillMaxWidth()
                    // ★ v1.9.32 根因修复：拖拽态整体变换（缩放/透明/纵向位移）须置于
                    //   background/shadow/drawWithContent 之前（Compose 左侧=外层）。
                    //   旧实现把 graphicsLayer 放在链末（最内层）→ 只变换了 Row 的子内容，
                    //   白色背景/阴影/阴影带留在槽位不动，造成"只有图标文字在动、Cell 主体待在原地"。
                    .graphicsLayer {
                        // v1.9.9：去掉 shadowElevation（改用 Modifier.shadow），只保留 scale/alpha/translation
                        this.scaleX = scale
                        this.scaleY = scale
                        this.alpha = alpha
                        // 被拖动项跟随手指平滑移动；松手后 animatedDragOffset 平滑回落到 0（对齐 iOS）
                        this.translationY = animatedDragOffset
                    }
                    // v1.9.9：默认阴影用 Modifier.shadow 替代 graphicsLayer.shadowElevation，
                    // Modifier.shadow 视觉更柔和（接近 iOS layer.shadow），不会像 graphicsLayer
                    // 在 LazyColumn 紧密排列下渲染成方形边框（用户反馈"四周都是横线"）。
                    // v1.9.30：非拖动态不再用 shadow——2dp 阴影会被后绘制的相邻 item 完全覆盖
                    // （LazyColumn 中 item 无间隙），Android 上等于没有底部阴影；底部阴影改由
                    // 下方 drawWithContent 在 item 自身 bounds 内绘制阴影带（见 hasTopShadow）。
                    // 拖动态保留 8dp：配合 zIndex=1f 置顶渲染，形成"提起"层次（对齐 iOS reorder，
                    // 即用户 2026-09-13 反馈的"拖动项底部阴影加深、顶部也出现阴影"）。
                    .shadow(
                        elevation = if (isDragging) 8.dp else 0.dp,
                        shape = RectangleShape,
                        clip = false,
                    )
                    .background(AppColor.bgCard)
                    // v1.9.30：底部阴影（自绘，画在 item 自身 bounds 内 → 不会被相邻 item 覆盖）
                    // = 顶部 CellShadowHeight 高度内由 CellShadowAlpha 线性渐隐到透明，
                    //   对齐 iOS willDisplay layer.shadow 的视觉（相邻 cell 分界处最深、向下渐隐）。
                    .drawWithContent {
                        drawContent()
                        if (hasTopShadow) {
                            val bandHeight = CellShadowHeight.toPx()
                            drawRect(
                                brush = Brush.verticalGradient(
                                    colors = listOf(
                                        Color.Black.copy(alpha = CellShadowAlpha),
                                        Color.Transparent,
                                    ),
                                    startY = 0f,
                                    endY = bandHeight,
                                ),
                                size = Size(size.width, bandHeight),
                            )
                        }
                    }
                    // 被拖动项置顶：zIndex=1f 让它在 LazyColumn 中渲染在其他项之上，
                    // 不被相邻项遮挡（与 iOS 标准 reorder 一致）
                    .zIndex(if (isDragging) 1f else 0f)
                    .onSizeChanged { size ->
                        if (size.height > 0) itemHeight = size.height.toFloat()
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
                            // 手柄承载拖拽手势：handle 模式下仅手柄可触发，整行不响应。
                            .then(dragModifier),
                    ) {
                        // 手柄 icon：v1.9.0 由 Icons.Default.DragIndicator 旋转 90° 改为自绘 DragHandle。
                        // 用户反复反馈"Android 与 iOS 不是一个 icon"——
                        // iOS 系统 reorder control = 三条水平线，每条线两端各一个圆点（两端略粗）。
                        // 自绘 Canvas 三条水平线+两端圆点，与 iOS 系统 reorder control 完全一致。
                        DragHandle(
                            color = AppColor.textSecondary,
                            modifier = Modifier.size(20.dp),
                        )
                    }
                }
            }
        }
    }
}

/**
 * iOS 风格拖拽手柄（v1.9.9 修正，对齐 iOS UITableView 系统 reorder control）。
 *
 * 视觉=三条等粗水平线（≡），无两端圆点。
 *
 * v1.9.9 修正：v1.9.0 误以为 iOS 系统 reorder control 有两端圆点（哑铃状），
 * 实际 iOS 系统 reorder control 就是三条等粗水平线。去掉两端圆点，与 iOS 完全一致。
 *
 * @param color 手柄颜色，默认 [AppColor.textSecondary]
 * @param modifier 布局修饰符，建议传 size(20.dp)
 */
@Composable
private fun DragHandle(
    color: Color = AppColor.textSecondary,
    modifier: Modifier = Modifier,
) {
    Canvas(modifier = modifier) {
        val w = size.width
        val h = size.height
        val lineCount = 3
        // 三条水平线纵向均布，每条线长度≈0.5×宽度
        val lineLength = w * 0.5f
        val lineStartX = (w - lineLength) / 2f
        val lineEndX = lineStartX + lineLength
        // 线粗≈0.08×高度（20dp → 1.6dp）
        val strokeWidth = h * 0.08f
        // 三条线纵向中心：0.3h / 0.5h / 0.7h
        val lineYs = listOf(h * 0.3f, h * 0.5f, h * 0.7f)

        for (i in 0 until lineCount) {
            val y = lineYs[i]
            // 三条等粗水平线（无两端圆点，对齐 iOS 系统 reorder control）
            drawLine(
                color = color,
                start = Offset(lineStartX, y),
                end = Offset(lineEndX, y),
                strokeWidth = strokeWidth,
            )
        }
    }
}
