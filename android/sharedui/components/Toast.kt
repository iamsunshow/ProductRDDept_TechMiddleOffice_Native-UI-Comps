//
//  Toast.kt
//  SharedUI
//
//  组件 ID：`ui.toast` ｜ 任务清单 #59 ｜ 操作反馈区第十五件 ｜ TMO 组件库 v1.4.14
//
//  定位：全局轻量提示浮层——屏幕居中短时显示文本+类型图标，自动消失，不阻断用户操作。
//
//  结构：
//  - ToastType（枚举）：success/error/warning/info/loading/text
//  - Toast（object 静态方法）：show/success/error/warning/info/loading/dismiss
//
//  契约 @param（与 api.json 100% 对齐）：
//  - Toast.show(message, type, duration)：显示一条 Toast
//  - Toast.success/error/warning/info(message, duration=2s)：快捷类型提示
//  - Toast.loading(message)：显示 loading（不自动消失）
//  - Toast.dismiss()：手动关闭
//
//  设计规格（design-spec/toast-design-spec.html）：
//  - 浮层背景 rgba(26,26,26,0.9)，文字 #fff fontMd(16)
//  - 圆角 radiusMd(8)，内边距 10×16，最大宽 80%
//  - 动画 250ms tween 淡入淡出
//  - 层级 Window 最顶层（WindowManager TYPE_APPLICATION_OVERLAY）
//
//  用法：
//  ```kotlin
//  Toast.success("保存成功")
//  Toast.loading("加载中...")
//  // 2 秒后
//  Toast.dismiss()
//  ```

package com.zhiqihuayun.sharedui.components

import android.os.Handler
import android.os.Looper
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.Error
import androidx.compose.material.icons.filled.Info
import androidx.compose.material.icons.filled.Warning
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.ComposeView
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

// MARK: - Toast 类型

/** Toast 类型枚举（success/error/warning/info/loading/text）。 */
enum class ToastType {
    Success, Error, Warning, Info, Loading, Text;

    val color: Color
        get() = when (this) {
            Success -> Color(0xFF16A34A)
            Error   -> Color(0xFFDC2626)
            Warning -> Color(0xFFF59E0B)
            Info    -> Color(0xFF3B82F6)
            Loading, Text -> Color.White
        }
}

// MARK: - Toast 单例

/**
 * 全局轻量提示浮层（object 静态方法调用，单例管理显示/消失）。
 *
 * 实现方式：ComposeView 挂载到 Activity 的 WindowManager 最顶层（android.R.id.content），
 * 透传触摸事件（setOnTouchListener return true 消费但不拦截下层=实际不拦截因为 Toast 层不处理点击）。
 */
object Toast {

    private const val PADDING_V = 10
    private const val PADDING_H = 16
    private const val CORNER_RADIUS = 8
    private const val MAX_WIDTH_RATIO = 0.8f
    private const val ANIM_DURATION = 250
    private const val DEFAULT_DURATION = 2000L
    private const val SPINNER_SIZE = 24
    private const val ICON_SIZE = 20
    private const val SPACING = 8

    private val handler = Handler(Looper.getMainLooper())
    private var composeView: ComposeView? = null
    private var dismissRunnable: Runnable? = null

    // 当前 Toast 状态（供 Composable 读取）
    private var currentMessage = mutableStateOf("")
    private var currentType = mutableStateOf(ToastType.Text)
    private var visible = mutableStateOf(false)

    /** 显示一条 Toast（默认 Text 类型，默认 2 秒）。 */
    fun show(message: String, type: ToastType = ToastType.Text, duration: Long? = DEFAULT_DURATION) {
        handler.post { showInternal(message, type, duration) }
    }

    /** 成功提示（绿色 ✓，默认 2 秒）。 */
    fun success(message: String, duration: Long = DEFAULT_DURATION) {
        showInternal(message, ToastType.Success, duration)
    }

    /** 错误提示（红色 ✗，默认 2 秒）。 */
    fun error(message: String, duration: Long = DEFAULT_DURATION) {
        showInternal(message, ToastType.Error, duration)
    }

    /** 警告提示（黄色 ⚠，默认 2 秒）。 */
    fun warning(message: String, duration: Long = DEFAULT_DURATION) {
        showInternal(message, ToastType.Warning, duration)
    }

    /** 信息提示（蓝色 ℹ，默认 2 秒）。 */
    fun info(message: String, duration: Long = DEFAULT_DURATION) {
        showInternal(message, ToastType.Info, duration)
    }

    /** Loading 提示（白色 spinner，不自动消失，需手动 dismiss）。 */
    fun loading(message: String) {
        showInternal(message, ToastType.Loading, null)
    }

    /** 手动关闭当前 Toast。 */
    fun dismiss() {
        handler.post { hideToast() }
    }

    private fun showInternal(message: String, type: ToastType, duration: Long?) {
        // 清除已有 Toast
        hideToast(immediately = true)

        currentMessage.value = message
        currentType.value = type

        // 获取 Activity 的 root content View（与 Notify 同模式）
        val activity = ActivityTracker.currentActivity ?: return
        val root = activity.findViewById<ViewGroup>(android.R.id.content) ?: return

        // 创建 ComposeView
        val view = ComposeView(activity)
        view.setContent {
            ToastContent(
                message = currentMessage.value,
                type = currentType.value,
                visible = visible.value
            )
        }
        // 不拦截触摸事件（Toast 层不处理点击，透传到下层）
        view.setOnTouchListener { _, _ -> false }

        // 添加到 root 顶层（全屏覆盖居中）
        val params = FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.MATCH_PARENT,
            FrameLayout.LayoutParams.MATCH_PARENT
        )
        root.addView(view, params)
        composeView = view

        // 淡入
        visible.value = true

        // 自动消失
        if (duration != null) {
            val r = Runnable { hideToast() }
            dismissRunnable = r
            handler.postDelayed(r, duration)
        }
    }

    private fun hideToast(immediately: Boolean = false) {
        dismissRunnable?.let { handler.removeCallbacks(it) }
        dismissRunnable = null

        if (immediately) {
            composeView?.let { view ->
                (view.parent as? android.view.ViewGroup)?.removeView(view)
            }
            composeView = null
            visible.value = false
        } else {
            visible.value = false
            // 等待淡出动画后移除
            handler.postDelayed({
                composeView?.let { view ->
                    (view.parent as? android.view.ViewGroup)?.removeView(view)
                }
                composeView = null
            }, ANIM_DURATION.toLong())
        }
    }

    // MARK: - Toast Composable 内容

    @Composable
    private fun ToastContent(message: String, type: ToastType, visible: Boolean) {
        val alpha by animateFloatAsState(
            targetValue = if (visible) 1f else 0f,
            animationSpec = tween(durationMillis = ANIM_DURATION),
            label = "toast-alpha"
        )

        Box(
            modifier = Modifier
                .fillMaxSize(),
            contentAlignment = Alignment.Center
        ) {
            Row(
                modifier = Modifier
                    .widthIn(max = 280.dp)
                    .background(
                        color = Color(0xE61A1A1A),     // rgba(26,26,26,0.9)
                        shape = RoundedCornerShape(CORNER_RADIUS.dp)
                    )
                    .padding(vertical = PADDING_V.dp, horizontal = PADDING_H.dp),
                horizontalArrangement = Arrangement.spacedBy(SPACING.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                // 图标/loading
                when (type) {
                    ToastType.Loading -> {
                        CircularProgressIndicator(
                            modifier = Modifier.size(SPINNER_SIZE.dp),
                            color = Color.White,
                            strokeWidth = 2.dp
                        )
                    }
                    ToastType.Text -> { /* 无图标 */ }
                    else -> {
                        val icon = when (type) {
                            ToastType.Success -> Icons.Default.CheckCircle
                            ToastType.Error   -> Icons.Default.Error
                            ToastType.Warning -> Icons.Default.Warning
                            ToastType.Info    -> Icons.Default.Info
                            else -> null
                        }
                        icon?.let {
                            Icon(
                                imageVector = it,
                                contentDescription = null,
                                tint = type.color,
                                modifier = Modifier.size(ICON_SIZE.dp)
                            )
                        }
                    }
                }

                // 文本
                Text(
                    text = message,
                    color = Color.White,
                    fontSize = 16.sp,
                    textAlign = TextAlign.Center
                )
            }
        }
    }
}
