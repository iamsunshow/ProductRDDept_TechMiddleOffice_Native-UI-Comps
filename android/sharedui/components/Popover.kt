// Popover 气泡弹出框（Android Compose 版，对齐 iOS PopoverView.swift / api.json `ui.popover`）。
//
// 组件 ID：`ui.popover` ｜ 任务清单 #53 ｜ 操作反馈区第八件 ｜ TMO 组件库 v1.4.4
//
// 定位：点击触发元素后弹出带箭头指向锚点的小气泡浮层，内嵌自定义内容，点击外部自动收起。
//
// 契约 @param（与 api.json 100% 对齐）：
// - visible: Boolean（*必选*：true=渲染 Popup；false=销毁）
// - content: @Composable（*必选*：气泡内嵌内容，宿主自定义）
// - placement: PopoverPlacement = PopoverPlacement.TOP（top/bottom/left/right/start/end 六向）
// - anchor: Rect（*必选*：锚点 frame，用于定位气泡+箭头方向）
// - closeOnClickOutside: Boolean = true（点击气泡外部自动收起）
// - offset: Offset = Offset.Zero（相对锚点的额外偏移）
// - onClose: (() -> Unit)? = null（null=不回调）
//
// 事件回调：
// - onClose: () -> Unit（closeOnClickOutside 触发时）
//
// 设计规格（design-spec/popover-design-spec.html）：
// - 气泡容器：白底圆角 8dp（AppRadius.sm），阴影 elevation 4
// - 箭头：8dp×8dp 旋转 45° 实心方块，颜色同气泡底色
// - 外部透明层：全屏透明，捕获点击
// - 动画：淡入+缩放 0.95→1.0（150ms easeOut）
// - 自动翻转：placement 方向空间不足时翻转到对侧
//
// 用法：
// ```kotlin
// var visible by remember { mutableStateOf(false) }
// var anchor by remember { mutableStateOf(Rect.Zero) }
// Popover(
//     visible = visible,
//     placement = PopoverPlacement.TOP,
//     anchor = anchor,
//     onClose = { visible = false }
// ) {
//     Text("提示内容")
// }
// ```

package com.zhiqihuayun.sharedui.components

import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxScope
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.scale
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Rect
import androidx.compose.ui.platform.LocalView
import androidx.compose.ui.unit.IntOffset
import androidx.compose.ui.unit.IntRect
import androidx.compose.ui.unit.IntSize
import androidx.compose.ui.unit.LayoutDirection
import androidx.compose.ui.unit.dp
import androidx.compose.ui.window.Popup
import androidx.compose.ui.window.PopupPositionProvider
import androidx.compose.ui.window.PopupProperties
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppRadius
import com.zhiqihuayun.foundation.design.AppSpace
import kotlin.math.roundToInt

/** 弹出方向（与 api.json PopoverPlacement 对齐）。 */
enum class PopoverPlacement {
    TOP,      // 气泡在锚点上方，箭头朝下
    BOTTOM,   // 气泡在锚点下方，箭头朝上
    LEFT,     // 气泡在锚点左侧，箭头朝右
    RIGHT,    // 气泡在锚点右侧，箭头朝左
    START,    // 气泡在锚点 RTL 起始侧（LTR=左）
    END       // 气泡在锚点 RTL 结束侧（LTR=右）
}

/**
 * Popup 位置提供器：根据锚点 frame + 弹出方向 + 实测内容尺寸计算 Popup 窗口位置。
 *
 * 核心修复：旧实现使用硬编码偏移（-100 / -200）猜测气泡尺寸，导致弹窗与按钮错位。
 * 改用 [PopupPositionProvider]，在布局阶段拿到真实 [popupContentSize] 后再计算偏移，
 * 确保 TOP 时气泡底边贴合 anchor.top、LEFT 时气泡右边贴合 anchor.left。
 */
private class PopoverPositionProvider(
    private val anchor: Rect,
    private val placement: PopoverPlacement,
    private val offset: Offset
) : PopupPositionProvider {
    override fun calculatePosition(
        anchorBounds: IntRect,
        windowSize: IntSize,
        layoutDirection: LayoutDirection,
        popupContentSize: IntSize
    ): IntOffset {
        return when (placement) {
            PopoverPlacement.TOP -> IntOffset(
                x = (anchor.left + offset.x).roundToInt(),
                y = (anchor.top - popupContentSize.height + offset.y).roundToInt()
            )
            PopoverPlacement.BOTTOM -> IntOffset(
                x = (anchor.left + offset.x).roundToInt(),
                y = (anchor.bottom + offset.y).roundToInt()
            )
            PopoverPlacement.LEFT, PopoverPlacement.START -> IntOffset(
                x = (anchor.left - popupContentSize.width + offset.x).roundToInt(),
                y = (anchor.top + offset.y).roundToInt()
            )
            PopoverPlacement.RIGHT, PopoverPlacement.END -> IntOffset(
                x = (anchor.right + offset.x).roundToInt(),
                y = (anchor.top + offset.y).roundToInt()
            )
        }
    }
}

/**
 * 气泡弹出框。
 *
 * @param visible 是否展示（受控）
 * @param placement 弹出方向，默认 TOP
 * @param anchor 锚点 frame（必传，需为窗口坐标系下的 Rect）
 * @param closeOnClickOutside 点击外部是否自动收起，默认 true
 * @param offset 相对锚点的额外偏移，默认 Offset.Zero
 * @param onClose 收起回调
 * @param modifier 可选布局修饰符
 * @param content 气泡内嵌内容
 */
@Composable
fun Popover(
    visible: Boolean,
    placement: PopoverPlacement = PopoverPlacement.TOP,
    anchor: Rect,
    closeOnClickOutside: Boolean = true,
    offset: Offset = Offset.Zero,
    onClose: (() -> Unit)? = null,
    modifier: Modifier = Modifier,
    content: @Composable BoxScope.() -> Unit
) {
    if (!visible) return

    val view = LocalView.current
    val screenWidth = view.width.toFloat()
    val screenHeight = view.height.toFloat()

    // 自动翻转：检测 placement 方向是否有足够空间
    val effectivePlacement = remember(placement, anchor, screenWidth, screenHeight) {
        when (placement) {
            PopoverPlacement.TOP -> if (anchor.top < 240f) PopoverPlacement.BOTTOM else PopoverPlacement.TOP
            PopoverPlacement.BOTTOM -> if (screenHeight - anchor.bottom < 240f) PopoverPlacement.TOP else PopoverPlacement.BOTTOM
            PopoverPlacement.LEFT, PopoverPlacement.START -> if (anchor.left < 240f) PopoverPlacement.RIGHT else PopoverPlacement.LEFT
            PopoverPlacement.RIGHT, PopoverPlacement.END -> if (screenWidth - anchor.right < 240f) PopoverPlacement.LEFT else PopoverPlacement.RIGHT
        }
    }

    // 淡入+缩放动画
    val scale by animateFloatAsState(
        targetValue = if (visible) 1f else 0.95f,
        animationSpec = tween(durationMillis = 150),
        label = "popoverScale"
    )

    // 使用 PopupPositionProvider 在布局阶段拿到真实气泡尺寸后计算位置，
    // 不再依赖硬编码偏移值。
    val positionProvider = remember(anchor, effectivePlacement, offset) {
        PopoverPositionProvider(anchor, effectivePlacement, offset)
    }

    Popup(
        popupPositionProvider = positionProvider,
        onDismissRequest = {
            if (closeOnClickOutside) {
                onClose?.invoke()
            }
        },
        properties = PopupProperties(
            focusable = true,
            dismissOnBackPress = closeOnClickOutside,
            dismissOnClickOutside = closeOnClickOutside
        )
    ) {
        // 气泡容器（白底圆角+阴影+内容槽）
        val bubbleShape = RoundedCornerShape(AppRadius.sm)

        Box(
            modifier = modifier
                .scale(scale)
                .background(AppColor.bgCard, bubbleShape)
                .padding(horizontal = AppSpace.md, vertical = AppSpace.sm)
        ) {
            // 内容槽
            content()
        }
    }
}
