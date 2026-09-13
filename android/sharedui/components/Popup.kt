// Popup 弹出层（Android Compose 版，对齐 iOS PopupContainerView.swift / api.json `ui.popup`）。
//
// 组件 ID：`ui.popup` ｜ 任务清单 #54 ｜ 操作反馈区第九件 ｜ TMO 组件库 v1.8.6
//
// 定位：通用弹出层容器——居中/底部/顶部弹出，带遮罩，承载任意自定义内容，可关闭。
//
// 契约 @param（与 api.json 100% 对齐）：
// - visible: Boolean（*必选*：true=渲染 Popup + 动画进入；false=退出动画后销毁）
// - content: @Composable（*必选*：弹层内嵌内容，宿主自定义）
// - position: PopupPosition = PopupPosition.CENTER（center/bottom/top/left/right）
// - closeable: Boolean = false（是否显示右上角关闭按钮）
// - closeOnClickOverlay: Boolean = true（点击遮罩是否收起）
// - radius: Dp = AppRadius.lg（弹层圆角）
// - onClose: (() -> Unit)? = null（null=不回调）
//
// 事件回调：
// - onClose: () -> Unit（closeable 关闭按钮 / closeOnClickOverlay 遮罩点击 / 外部 visible=false）
//
// 设计规格（design-spec/popup-design-spec.html）：
// - 遮罩：全屏 black 45% 透明
// - 弹层容器：白底，圆角按 position 变化（center=四角 / bottom=顶两角 / top=底两角）
// - 关闭按钮：24dp 圆形灰底白叉，closeable=true 时显示
// - 动画：center=淡入+缩放 200ms / bottom=从底部滑入 250ms / top=从顶部滑入
// - 底部安全区：position=bottom 时 navigationBars bottom padding
//
// v1.8.6 修复（用户 2026-09-13 反馈 7 项）：
// 1. 内容定位失效（居中/底部/顶部全跑到左上角）：根因=container 的 .align(Alignment.xxx)
//    写在 AnimatedVisibility 内部，不是 mask Box 的直接子节点，align 失效→默认 top-start。
//    修复=mask 与 content 改平级兄弟节点（Overlay 同款），用外层 Box 的 contentAlignment 定位。
// 2. 点击蒙层不消失+页面被永久遮住：根因=①animVisible 只置 true 从不置 false，visible=false
//    后 WindowPopup(含 mask)永远不卸载；②mask 与 container 嵌套+clickable(enabled=false) 不可靠。
//    修复=用 MutableTransitionState 精准控制退出后卸载；mask/content 平级；container 用
//    clickable(onClick={}) 消费点击阻止穿透；mask 与 content 同进 AnimatedVisibility 整体退场。
// 3. Demo3 底部弹出变顶部：同 #1 根因，BottomCenter align 失效。
// 4. Demo6/8 居中失效：同 #1。
// 5. Demo7 通栏：同 #1，居中失效+宽度约束未生效。
//
// 用法：
// ```kotlin
// var visible by remember { mutableStateOf(false) }
// Popup(
//     visible = visible,
//     position = PopupPosition.BOTTOM,
//     closeable = true,
//     onClose = { visible = false }
// ) {
//     // 自定义内容
// }
// ```

package com.zhiqihuayun.sharedui.components

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.core.MutableTransitionState
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.scaleIn
import androidx.compose.animation.scaleOut
import androidx.compose.animation.slideInHorizontally
import androidx.compose.animation.slideInVertically
import androidx.compose.animation.slideOutHorizontally
import androidx.compose.animation.slideOutVertically
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxScope
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.layout.wrapContentHeight
import androidx.compose.foundation.layout.wrapContentWidth
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Close
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalConfiguration
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.IntOffset
import androidx.compose.ui.unit.IntRect
import androidx.compose.ui.unit.IntSize
import androidx.compose.ui.unit.LayoutDirection
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.window.Popup as WindowPopup
import androidx.compose.ui.window.PopupPositionProvider
import androidx.compose.ui.window.PopupProperties
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppRadius
import com.zhiqihuayun.foundation.design.AppSpace
import androidx.compose.foundation.layout.navigationBarsPadding

/** 弹出位置（与 api.json PopupPosition 对齐）。 */
enum class PopupPosition {
    CENTER,   // 居中弹出
    BOTTOM,   // 底部贴底
    TOP,      // 顶部贴顶
    LEFT,     // 左侧弹出
    RIGHT     // 右侧弹出
}

/** 内部 testTag 常量，供自动化单测定位蒙版/容器/关闭按钮（回归测试台账 L1）。 */
internal object PopupTestTags {
    const val MASK = "popup_mask"
    const val CONTAINER = "popup_container"
    const val CLOSE_BUTTON = "popup_close_button"
}

/**
 * 全屏 Popup 位置提供器：让 Popup 内容从窗口 (0,0) 开始，
 * 配合 fillMaxSize() 覆盖整个屏幕。
 * 用 Popup 替代 Dialog，去除 Dialog 系统级 dim 层（~0.6），
 * 只保留 Color.Black.copy(alpha = 0.45f) 蒙版，与 iOS 完全一致。
 */
private object FullScreenPopupPositionProvider : PopupPositionProvider {
    override fun calculatePosition(
        anchorBounds: IntRect,
        windowSize: IntSize,
        layoutDirection: LayoutDirection,
        popupContentSize: IntSize
    ): IntOffset = IntOffset(0, 0)
}

/** 蒙层透明度常量。 */
private const val MASK_ALPHA = 0.45f

/** 关闭按钮尺寸与内边距（与 iOS closeButtonSize=24 / closeButtonInset=8 对齐）。 */
private val CLOSE_BUTTON_SIZE = 24.dp
private val CLOSE_BUTTON_INSET = AppSpace.sm
private const val CLOSE_BUTTON_TOP_PAD = 40 // 24 + 8*2

/**
 * 通用弹出层容器。
 *
 * @param visible 是否展示（受控）
 * @param position 弹出位置，默认 CENTER
 * @param closeable 是否显示关闭按钮，默认 false
 * @param closeOnClickOverlay 点击遮罩是否收起，默认 true
 * @param radius 弹层圆角，默认 AppRadius.lg
 * @param onClose 收起回调
 * @param modifier 可选布局修饰符（作用于内容槽）
 * @param content 弹层内嵌内容
 */
@Composable
fun Popup(
    visible: Boolean,
    position: PopupPosition = PopupPosition.CENTER,
    closeable: Boolean = false,
    closeOnClickOverlay: Boolean = true,
    radius: Dp = AppRadius.lg,
    onClose: (() -> Unit)? = null,
    modifier: Modifier = Modifier,
    content: @Composable BoxScope.() -> Unit
) {
    // 用 MutableTransitionState 精准控制生命周期：
    // visible=true → 立即渲染并播放进入动画；
    // visible=false → 播放退出动画，动画结束后 currentState 变 false，外层 guard 卸载 WindowPopup。
    // 彻底解决旧 animVisible 只置 true 不置 false 导致蒙层永久残留、页面无法操作的 bug。
    val visibilityState = remember { MutableTransitionState(visible) }
    visibilityState.targetState = visible
    if (!visibilityState.currentState && !visibilityState.targetState) return

    // 弹层容器在屏幕中的对齐方式（由外层 contentAlignment Box 统一控制，修复 align 失效）。
    val contentAlignment = when (position) {
        PopupPosition.CENTER -> Alignment.Center
        PopupPosition.BOTTOM -> Alignment.BottomCenter
        PopupPosition.TOP -> Alignment.TopCenter
        PopupPosition.LEFT -> Alignment.CenterStart
        PopupPosition.RIGHT -> Alignment.CenterEnd
    }

    // 进入/退出动画按 position 选择
    val enterTransition = when (position) {
        PopupPosition.CENTER -> fadeIn(animationSpec = tween(200)) + scaleIn(initialScale = 0.9f, animationSpec = tween(200))
        PopupPosition.BOTTOM -> fadeIn(animationSpec = tween(250)) + slideInVertically(initialOffsetY = { it }, animationSpec = tween(250))
        PopupPosition.TOP -> fadeIn(animationSpec = tween(250)) + slideInVertically(initialOffsetY = { -it }, animationSpec = tween(250))
        PopupPosition.LEFT -> fadeIn(animationSpec = tween(250)) + slideInHorizontally(initialOffsetX = { -it }, animationSpec = tween(250))
        PopupPosition.RIGHT -> fadeIn(animationSpec = tween(250)) + slideInHorizontally(initialOffsetX = { it }, animationSpec = tween(250))
    }
    val exitTransition = when (position) {
        PopupPosition.CENTER -> fadeOut(animationSpec = tween(200)) + scaleOut(targetScale = 0.9f, animationSpec = tween(200))
        PopupPosition.BOTTOM -> fadeOut(animationSpec = tween(250)) + slideOutVertically(targetOffsetY = { it }, animationSpec = tween(250))
        PopupPosition.TOP -> fadeOut(animationSpec = tween(250)) + slideOutVertically(targetOffsetY = { -it }, animationSpec = tween(250))
        PopupPosition.LEFT -> fadeOut(animationSpec = tween(250)) + slideOutHorizontally(targetOffsetX = { -it }, animationSpec = tween(250))
        PopupPosition.RIGHT -> fadeOut(animationSpec = tween(250)) + slideOutHorizontally(targetOffsetX = { it }, animationSpec = tween(250))
    }

    WindowPopup(
        popupPositionProvider = FullScreenPopupPositionProvider,
        onDismissRequest = {
            // 返回键：closeOnClickOverlay=false 时不响应（与点击蒙层行为一致）
            if (closeOnClickOverlay) onClose?.invoke()
        },
        properties = PopupProperties(
            focusable = true,
            dismissOnBackPress = closeOnClickOverlay,
            // dismissOnClickOutside=false：由平级 mask 的 clickable 自行处理点击收起
            dismissOnClickOutside = false
        )
    ) {
        // mask 与 content 整体进入/退出，避免旧版 mask 残留
        AnimatedVisibility(
            visibleState = visibilityState,
            enter = enterTransition,
            exit = exitTransition
        ) {
            // 外层全屏 Box：mask（下层）与 content 定位层（上层）为平级兄弟节点
            Box(modifier = Modifier.fillMaxSize()) {
                // ── 平级子节点 1：蒙层（下层，负责遮罩色 + 点击空白关闭）──
                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .background(Color.Black.copy(alpha = MASK_ALPHA))
                        .testTag(PopupTestTags.MASK)
                        // 始终挂 clickable，enabled 由 closeOnClickOverlay 控制：
                        // true→可点击收起；false→clickable 禁用（节点仍存在，assertIsNotEnabled 可断言）
                        .clickable(
                            enabled = closeOnClickOverlay,
                            indication = null,
                            interactionSource = remember { MutableInteractionSource() },
                            onClick = { onClose?.invoke() }
                        )
                )

                // ── 平级子节点 2：内容定位层（上层，负责按 position 定位容器）──
                // 用 contentAlignment 替代容器自身的 .align()，根治 AnimatedVisibility 内 align 失效。
                // 本层 fillMaxSize 但无 clickable，点击容器外区域→穿透到下层 mask 触发关闭。
                Box(
                    modifier = Modifier.fillMaxSize(),
                    contentAlignment = contentAlignment
                ) {
                    // 容器形状按 position 变化
                    val shape = when (position) {
                        PopupPosition.CENTER -> RoundedCornerShape(radius)
                        PopupPosition.BOTTOM -> RoundedCornerShape(topStart = radius, topEnd = radius)
                        PopupPosition.TOP -> RoundedCornerShape(bottomStart = radius, bottomEnd = radius)
                        PopupPosition.LEFT -> RoundedCornerShape(topEnd = radius, bottomEnd = radius)
                        PopupPosition.RIGHT -> RoundedCornerShape(topStart = radius, bottomStart = radius)
                    }

                    // 居中模式：宽度=内容，min=240dp，max=屏宽-32dp（与 iOS center 约束一致）
                    // v1.9.22 修复（用户 2026-09-13 反馈“Demo1 双端文案不一致”）：
                    // screenWidthDp 本身已是 dp，旧实现又走了一遍 LocalDensity.toDp()（把 379dp 当成 379px
                    // 再除以 density），Pixel 7 Pro（density≈2.625）上 max 只剩 ~133dp < min 240dp，
                    // max 反压 min → 弹层被压到 ~133dp 宽 → 内容被截断（Android 弹层显示“大圆/常规”，
                    // iOS 显示完整“大圆角弹出层（24pt）/常规弹出层内容”）。直接用 .dp 即可。
                    val screenWidthDp = LocalConfiguration.current.screenWidthDp
                    val maxCenterWidth = (screenWidthDp - AppSpace.lg.value * 2).dp

                    val containerModifier = when (position) {
                        PopupPosition.CENTER -> Modifier
                            // 宽度=内容，min=240dp，max=屏宽-32dp（与 iOS center 约束一致）
                            .widthIn(min = 240.dp, max = maxCenterWidth)
                        PopupPosition.BOTTOM -> Modifier
                            .fillMaxWidth()
                            .wrapContentHeight()
                            // navigationBarsPadding 在最外层：让 heightIn 限制 content 高度不含 padding，
                            // 弹层贴到安全区底部（与 iOS safeArea bottom 对齐）
                            .navigationBarsPadding()
                            .heightIn(min = 160.dp)
                        PopupPosition.TOP -> Modifier
                            .fillMaxWidth()
                            .wrapContentHeight()
                            .heightIn(min = 120.dp)
                        PopupPosition.LEFT -> Modifier
                            .fillMaxHeight()
                            .wrapContentWidth()
                            .widthIn(min = 120.dp)
                        PopupPosition.RIGHT -> Modifier
                            .fillMaxHeight()
                            .wrapContentWidth()
                            .widthIn(min = 120.dp)
                    }

                    Box(
                        // v1.9.23：内容槽在容器内水平+垂直居中（v1.9.22 的 TopCenter 只解决水平居中）。
                        // 根因：TOP/BOTTOM 有 heightIn(min)、LEFT/RIGHT 有 fillMaxHeight，容器被撑高后
                        // 旧 TopCenter 让内容槽贴顶 → Demo2/Demo3 文字偏上（实测距顶 24dp / 距底 71.7dp），
                        // 而 iOS 内容在容器内垂直居中 → 双端不一致。
                        // 居中对象是"含上下 padding 的内容槽"，故 closeable 顶部 40dp 关闭按钮避让语义不变，
                        // 只是整槽沿容器竖向对中；CENTER 位置容器高=内容高，居中前后无差异。
                        contentAlignment = Alignment.Center,
                        modifier = containerModifier
                            .clip(shape)
                            .background(AppColor.bgCard, shape)
                            .testTag(PopupTestTags.CONTAINER)
                            // 消费容器内点击，阻止穿透到下层 mask（旧 clickable(enabled=false) 不可靠）
                            .clickable(
                                indication = null,
                                interactionSource = remember { MutableInteractionSource() },
                                onClick = {}
                            )
                    ) {
                        // 内容槽：统一 padding（与 iOS PopupContainerView 一致）
                        val topPad = if (closeable) CLOSE_BUTTON_TOP_PAD.dp else AppSpace.sm
                        Box(
                            modifier = Modifier
                                .then(modifier)
                                .padding(
                                    top = topPad,
                                    start = AppSpace.lg,
                                    end = AppSpace.lg,
                                    bottom = AppSpace.sm
                                )
                        ) {
                            content()
                        }
                        // 关闭按钮
                        if (closeable) {
                            Box(
                                modifier = Modifier
                                    .align(Alignment.TopEnd)
                                    .padding(CLOSE_BUTTON_INSET)
                                    .size(CLOSE_BUTTON_SIZE)
                                    .background(AppColor.gray6, RoundedCornerShape(50))
                                    .clickable { onClose?.invoke() }
                                    .testTag(PopupTestTags.CLOSE_BUTTON),
                                contentAlignment = Alignment.Center
                            ) {
                                Icon(
                                    imageVector = Icons.Default.Close,
                                    contentDescription = "关闭",
                                    tint = AppColor.textSecondary,
                                    modifier = Modifier.size(16.dp)
                                )
                            }
                        }
                    }
                }
            }
        }
    }
}
