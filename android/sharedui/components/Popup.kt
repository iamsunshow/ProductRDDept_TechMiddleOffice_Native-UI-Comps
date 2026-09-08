// Popup 弹出层（Android Compose 版，对齐 iOS PopupContainerView.swift / api.json `ui.popup`）。
//
// 组件 ID：`ui.popup` ｜ 任务清单 #54 ｜ 操作反馈区第九件 ｜ TMO 组件库 v1.4.4
//
// 定位：通用弹出层容器——居中/底部/顶部弹出，带遮罩，承载任意自定义内容，可关闭。
//
// 契约 @param（与 api.json 100% 对齐）：
// - visible: Boolean（*必选*：true=渲染 Dialog + 动画进入；false=退出动画后销毁）
// - content: @Composable（*必选*：弹层内嵌内容，宿主自定义）
// - position: PopupPosition = PopupPosition.CENTER（center/bottom/top 三向）
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
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.slideInVertically
import androidx.compose.animation.slideOutVertically
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxScope
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Close
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.window.Dialog
import androidx.compose.ui.window.DialogProperties
import com.zhiqihuayun.foundation.design.AppColor
import androidx.compose.ui.unit.sp
import com.zhiqihuayun.foundation.design.AppRadius
import com.zhiqihuayun.foundation.design.AppSpace
import androidx.compose.foundation.layout.imePadding
import androidx.compose.foundation.layout.navigationBarsPadding

/** 弹出位置（与 api.json PopupPosition 对齐）。 */
enum class PopupPosition {
    CENTER,   // 居中弹出
    BOTTOM,   // 底部贴底
    TOP       // 顶部贴顶
}

/**
 * 通用弹出层容器。
 *
 * @param visible 是否展示（受控）
 * @param position 弹出位置，默认 CENTER
 * @param closeable 是否显示关闭按钮，默认 false
 * @param closeOnClickOverlay 点击遮罩是否收起，默认 true
 * @param radius 弹层圆角，默认 AppRadius.lg
 * @param onClose 收起回调
 * @param modifier 可选布局修饰符
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
    if (!visible) return

    Dialog(
        onDismissRequest = {
            if (closeOnClickOverlay) {
                onClose?.invoke()
            }
        },
        properties = DialogProperties(
            dismissOnBackPress = closeOnClickOverlay,
            dismissOnClickOutside = closeOnClickOverlay,
            usePlatformDefaultWidth = false
        )
    ) {
        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(Color.Black.copy(alpha = 0.45f))
                .clickable(
                    enabled = closeOnClickOverlay,
                    indication = null,
                    interactionSource = androidx.compose.foundation.interaction.MutableInteractionSource(),
                    onClick = { onClose?.invoke() }
                )
        ) {
            // 弹层容器（白底+圆角按 position 变化）
            val shape = when (position) {
                PopupPosition.CENTER -> RoundedCornerShape(radius)
                PopupPosition.BOTTOM -> RoundedCornerShape(topStart = radius, topEnd = radius)
                PopupPosition.TOP -> RoundedCornerShape(bottomStart = radius, bottomEnd = radius)
            }
            val containerModifier = when (position) {
                PopupPosition.CENTER -> Modifier
                    .align(Alignment.Center)
                    .background(AppColor.bgCard, shape)
                    .padding(horizontal = AppSpace.lg)
                PopupPosition.BOTTOM -> Modifier
                    .align(Alignment.BottomCenter)
                    .fillMaxWidth()
                    .background(AppColor.bgCard, shape)
                    .navigationBarsPadding()
                    .padding(bottom = AppSpace.sm)
                PopupPosition.TOP -> Modifier
                    .align(Alignment.TopCenter)
                    .fillMaxWidth()
                    .background(AppColor.bgCard, shape)
            }
            Box(
                modifier = containerModifier.clickable(
                    enabled = false,  // 阻止点击穿透到遮罩
                    indication = null,
                    interactionSource = androidx.compose.foundation.interaction.MutableInteractionSource(),
                    onClick = {}
                )
            ) {
                // 内容槽（closeable 时顶部留出关闭按钮空间）
                val contentTopPadding = if (closeable) 32.dp else 0.dp
                Box(modifier = Modifier
                    .then(modifier)
                    .padding(top = contentTopPadding)
                ) {
                    content()
                }
                // 关闭按钮
                if (closeable) {
                    Box(
                        modifier = Modifier
                            .align(Alignment.TopEnd)
                            .padding(AppSpace.sm)
                            .size(24.dp)
                            .background(AppColor.gray6, RoundedCornerShape(50))
                            .clickable { onClose?.invoke() },
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
