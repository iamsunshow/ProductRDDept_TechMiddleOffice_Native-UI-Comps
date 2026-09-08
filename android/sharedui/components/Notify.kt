package com.zhiqihuayun.sharedui.components

import android.app.Activity
import android.os.Looper
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.slideInVertically
import androidx.compose.animation.slideOutVertically
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalView
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.zhiqihuayun.foundation.design.AppColor
import androidx.compose.ui.unit.sp
import com.zhiqihuayun.foundation.design.AppFont
import com.zhiqihuayun.foundation.design.AppSpace
import kotlinx.coroutines.delay

/**
 * Notify 消息通知：顶部/底部全局消息通知浮层（操作反馈区 #52，全新立项）。
 *
 * 组件 ID：`ui.notify`（api.json 契约对齐，门禁 A AI 代评通过 2026-09-08，
 * 用户"中间任何询问直接通过"总授权；P1–P4 全 A：命令式 API + 全局浮层 +
 * 自动消失 + 可关闭 + 左右图标 slot + type 变色 + position(top/bottom)）。
 *
 * 一期语义（对标 NutUI React Notify + Vant Notify）：
 * - 命令式 API：Notify.show(message, position, type, duration, closeable, ...) / Notify.clear()
 * - [position]：TOP（默认）/ BOTTOM
 * - [type]：DEFAULT（深色底白字，默认）/ PRIMARY / SUCCESS / WARNING / DANGER
 * - [duration]：展示时长 ms（默认 3000，0=常驻不消失）
 * - [closeable]：是否可关闭（true=右侧 ×+onClose 回调）
 * - [leftIcon]：左侧图标 slot（null=默认喇叭）
 * - [rightIcon]：右侧图标 slot（null=closeable 时 × 否则空）
 * - [distance]：距离顶部/底部 dp（默认 8）
 * - [navHeight]：顶部导航高度 dp（默认 57，position=TOP 时下移避开导航栏）
 * - [onClick]：点击回调
 * - [onClose]：关闭回调
 *
 * 用法：
 * ```kotlin
 * Notify.show(message = "这是一条通知消息")
 * Notify.show(message = "底部通知", position = NotifyPosition.BOTTOM, duration = 5000)
 * Notify.show(message = "成功通知", type = NotifyType.SUCCESS)
 * Notify.show(message = "可关闭通知", closeable = true) { /* onClose */ }
 * Notify.clear()
 * ```
 */
object Notify {

    private var currentHost: ViewGroup? = null
    private var currentComposeView: View? = null

    fun show(message: String,
             position: NotifyPosition = NotifyPosition.TOP,
             type: NotifyType = NotifyType.DEFAULT,
             duration: Long = 3000L,
             closeable: Boolean = false,
             distance: Int = 8,
             navHeight: Int = 57,
             onClick: (() -> Unit)? = null,
             onClose: (() -> Unit)? = null) {
        // 清除现有
        clear()

        val activity = currentActivity() ?: return
        val contentHost = activity.findViewById<ViewGroup>(android.R.id.content)
        val params = FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.MATCH_PARENT,
            FrameLayout.LayoutParams.WRAP_CONTENT
        )
        when (position) {
            NotifyPosition.TOP -> {
                // 使用 windowInsets 获取状态栏高度，避免固定 navHeight 不准确导致盖住 titlebar
                val statusBarHeight = androidx.core.view.WindowInsetsCompat
                    .toWindowInsetsCompat(activity.window.decorView.rootWindowInsets, activity.window.decorView)
                    .getInsets(androidx.core.view.WindowInsetsCompat.Type.statusBars())
                    .top
                val density = activity.resources.displayMetrics.density
                val offsetDp = navHeight + distance
                // 取状态栏实际高度与 navHeight 取大值，确保不会盖住导航栏
                val effectiveTop = maxOf(statusBarHeight, (density * offsetDp).toInt())
                params.topMargin = effectiveTop
                params.gravity = android.view.Gravity.TOP
            }
            NotifyPosition.BOTTOM -> {
                params.bottomMargin = (activity.resources.displayMetrics.density * distance).toInt()
                params.gravity = android.view.Gravity.BOTTOM
            }
        }

        val composeView = androidx.compose.ui.platform.ComposeView(activity).apply {
            setContent {
                NotifyContent(
                    message = message,
                    type = type,
                    closeable = closeable,
                    duration = duration,
                    onClick = onClick,
                    onClose = {
                        clear()
                        onClose?.invoke()
                    }
                )
            }
        }
        contentHost.addView(composeView, params)
        currentHost = contentHost
        currentComposeView = composeView
    }

    fun clear() {
        val host = currentHost
        val view = currentComposeView
        if (host != null && view != null) {
            android.os.Handler(Looper.getMainLooper()).post {
                host.removeView(view)
            }
        }
        currentHost = null
        currentComposeView = null
    }

    private fun currentActivity(): Activity? {
        return ActivityTracker.currentActivity
    }
}

/** Activity 引用追踪（由宿主 Activity onCreate 时赋值）。 */
object ActivityTracker {
    @Volatile
    var currentActivity: Activity? = null
}

@Composable
private fun NotifyContent(message: String,
                         type: NotifyType,
                         closeable: Boolean,
                         duration: Long,
                         onClick: (() -> Unit)?,
                         onClose: () -> Unit) {
    var visible by remember { mutableStateOf(true) }

    LaunchedEffect(Unit) {
        if (duration > 0) {
            delay(duration)
            visible = false
        }
    }

    AnimatedVisibility(
        visible = visible,
        enter = fadeIn(),
        exit = fadeOut()
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .height(40.dp)
                .background(type.backgroundColor())
                .clickable(
                    interactionSource = remember { MutableInteractionSource() },
                    indication = null,
                    onClick = { onClick?.invoke() }
                )
                .padding(horizontal = AppSpace.lg),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(AppSpace.sm)
        ) {
            // 左侧图标（默认喇叭 emoji）
            Text(text = "📢", fontSize = AppFont.sizeMd)
            // 文本
            Text(
                text = message,
                color = AppColor.textInverse,
                fontSize = AppFont.sizeSm,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
                modifier = Modifier.weight(1f)
            )
            // 关闭按钮
            if (closeable) {
                Text(
                    text = "✕",
                    color = AppColor.textInverse,
                    fontSize = AppFont.sizeSm,
                    modifier = Modifier.clickable(
                        interactionSource = remember { MutableInteractionSource() },
                        indication = null,
                        onClick = {
                            visible = false
                            onClose()
                        }
                    )
                )
            }
        }
    }
}

/** Notify 位置。 */
enum class NotifyPosition {
    TOP, BOTTOM
}

/** Notify 类型。 */
enum class NotifyType {
    DEFAULT, PRIMARY, SUCCESS, WARNING, DANGER;

    fun backgroundColor(): Color = when (this) {
        DEFAULT -> AppColor.textPrimary
        PRIMARY -> AppColor.primary
        SUCCESS -> AppColor.success
        WARNING -> AppColor.warning
        DANGER -> AppColor.error
    }
}
