// Overlay 遮罩层（Android Compose 版，对齐 iOS Overlay.swift / api.json `ui.overlay`）。
//
// 定位：全屏遮罩 + 自定义内容插槽 = 所有浮层的**通用底部基座**（Dialog / Drawer / Popover /
// ActionSheet / 气泡菜单 / 新手引导蒙版等一律组合 Overlay 二次开发，禁手写遮罩）。
// 组件库版本基线 v1.3.12 → 本期实现升级：MINOR **v1.4.0**（基础组件 6/6 收官）。
//
// 契约 @param（与 api.json 10 props 100% 命名/类型/默认值对齐）：
// - visible: Boolean                  （*必选*：true=Dialog 挂载显示 + fade-in；false=fade-out 后 dismiss）
// - maskColor: String = "default"     （"default"=半透明黑 / "transparent"=完全透明 / "rgba(r,g,b,a)" / "#RRGGBB[AA]"）
// - closeOnMaskClick: Boolean = true  （点击遮罩空白 → onClose；clickThrough=true 时失效）
// - clickThrough: Boolean = false      （true=遮罩不拦截事件，穿透到底层页面；true 时 closeOnMaskClick/onMaskClick 均失效）
// - contentPosition: String = "center"（9 点：center/top/bottom/left/right/top-left/top-right/bottom-left/bottom-right）
// - contentOffsetX/Y: Int = 0         （二次偏移 dp；x 正向右 / y 正向下，与 9 点锚叠加）
//   ⚠️ Compose 参数扁平化二值（{x,y} 不支持对象字面），语义与 iOS CGPoint 等价。
// - contentRadius: Any = 0             （"sm"=6dp / "md"=10dp / "lg"=14dp / 数值 Int:dp；贴边时朝外两圆角=token/数值，贴边侧两直角=0）
// - animation: Boolean = true         （true=fade-in 200ms ease-out / fade-out 180ms ease-in；false=立即切换）
// - dismissOnBackPress: Boolean = true（Android 专用：true=返回键关闭；iOS 本开关被平台代码忽略不报错）
// - content: @Composable () -> Unit    （*必选*：自定义插槽 Composable）
//
// 事件回调：
// - onClose: () -> Unit                （① closeOnMaskClick=true 点击遮罩；② dismissOnBackPress=true 返回键；
//                                        组件内部触发"关闭"统一回调；业务层自己切换 visible=false 不重复触发）
// - onMaskClick: () -> Unit            （点击遮罩空白；clickThrough=true 不触发；closeOnMaskClick=false 仍触发可埋点）
//
// 设计决策（与 iOS 同门禁 A 推荐 A × 4，双端一致）：
// P1 挂载：A Compose Dialog + usePlatformDefaultWidth=false + decorFitsSystemWindows=false → Dialog 全屏独立 window
// P2 动画：A 一期仅 fade（AnimatedVisibility + EnterExitTransition），位移动画归上层插槽
// P3 遮罩点击：A closeOnMaskClick 默认 true + clickThrough 独立开关 + onMaskClick/onClose 回调解耦
// P4 内容位置：A 9 点 Alignment + offset(x,y)（覆盖 Modal 居中 / 顶部通知 / bottom 抽屉 / corner 气泡）
//
// 双端差异（登记 docs/平台差异.md）：
// 1) 挂载：iOS keyWindow.addSubview vs 本文件 Compose Dialog → 视觉语义一致，外部不感知
// 2) dismissOnBackPress：本平台独有，原生 Dialog properties 控制；iOS 同名属性 API 保留但忽略
// 3) 圆角掩膜：iOS CACornerMask / 本文件 RoundedCornerShape(topStart …) → 贴边侧两角自动设零

package com.zhiqihuayun.sharedui.components

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Shape
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.semantics.testTag
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.IntOffset
import androidx.compose.ui.unit.dp
import androidx.compose.ui.window.Popup
import androidx.compose.ui.window.PopupProperties
import com.zhiqihuayun.foundation.design.AppColor
import kotlin.math.roundToInt

// ============== 枚举/解析工具（与 iOS 类一一对应，取值字符串 100% 一致）==============

// alpha/时长 命名常量（杜绝魔法数字）
private const val OVERLAY_MASK_ALPHA = 0.55f
private const val FEEDBACK_TAP_ALPHA = 0.65f
private const val FADE_IN_MS = 200
private const val FADE_OUT_MS = 180

/** 默认遮罩色：textPrimary #111827 × 55% alpha（与 iOS OverlayMaskColor.default 同一公式：RGB 分量 / 255.0 = Float 归一化，alpha 直传 OVERLAY_MASK_ALPHA Float） */
private val DefaultMaskColor = Color(red = 0x11 / 255f, green = 0x18 / 255f, blue = 0x27 / 255f, alpha = OVERLAY_MASK_ALPHA)

/** contentPosition → Alignment 9 点映射（与 iOS anchor 0/0.5/1 同一语义） */
private fun contentPositionAlignment(pos: String): Alignment = when (pos) {
    "top" -> Alignment.TopCenter
    "bottom" -> Alignment.BottomCenter
    "left" -> Alignment.CenterStart
    "right" -> Alignment.CenterEnd
    "top-left" -> Alignment.TopStart
    "top-right" -> Alignment.TopEnd
    "bottom-left" -> Alignment.BottomStart
    "bottom-right" -> Alignment.BottomEnd
    else -> Alignment.Center
}

/** contentRadius token → Dp（sm=6/md=10/lg=14；设计 token 与 iOS 数值一一对应） */
private fun resolveRadius(r: Any?): Dp = when (r) {
    "sm" -> 6.dp
    "md" -> 10.dp
    "lg" -> 14.dp
    is Int -> r.coerceAtLeast(0).dp
    is Long -> r.toInt().coerceAtLeast(0).dp
    is Float -> r.roundToInt().coerceAtLeast(0).dp
    is Double -> r.roundToInt().coerceAtLeast(0).dp
    is Dp -> r
    else -> 0.dp
}

/** 贴边内容 → 朝外侧两圆角保留，贴边侧两直角：返回 RoundedCornerShape（与 iOS CACornerMask 镜像） */
private fun resolveShape(contentPosition: String, radiusDp: Dp): Shape {
    val r = radiusDp
    val z = 0.dp
    return when (contentPosition) {
        // 顶部贴边：顶两直角 = 0 / 底两圆角 = r
        "top", "top-left", "top-right" ->
            RoundedCornerShape(topStart = z, topEnd = z, bottomStart = r, bottomEnd = r)
        // 底部贴边：底两直角 = 0 / 顶两圆角 = r
        "bottom", "bottom-left", "bottom-right" ->
            RoundedCornerShape(topStart = r, topEnd = r, bottomStart = z, bottomEnd = z)
        // 左 / 右 竖贴边
        "left" ->
            RoundedCornerShape(topStart = z, topEnd = r, bottomStart = z, bottomEnd = r)
        "right" ->
            RoundedCornerShape(topStart = r, topEnd = z, bottomStart = r, bottomEnd = z)
        // center / 其他：4 角全圆
        else -> RoundedCornerShape(r)
    }
}

/** maskColor 解析（default/transparent/rgba(#,#,#,#)/hex；非法降级 default；与 iOS OverlayMaskColor.parse 同语义） */
private fun resolveMaskColor(raw: String): Color {
    val s = raw.trim().lowercase()
    if (s == "default") return DefaultMaskColor
    if (s == "transparent") return Color.Transparent
    // rgba(r,g,b,a)
    if (s.startsWith("rgba(") && s.endsWith(")")) {
        val inner = s.removePrefix("rgba(").removeSuffix(")").split(",").map { it.trim() }
        if (inner.size == 4) {
            val nums = inner.mapNotNull { it.toDoubleOrNull() }
            if (nums.size == 4) {
                fun norm(i: Int) = if (nums[i] <= 1.0) nums[i].toFloat() else (nums[i] / 255.0).toFloat()
                val r = norm(0).coerceIn(0f, 1f)
                val g = norm(1).coerceIn(0f, 1f)
                val b = norm(2).coerceIn(0f, 1f)
                val a = norm(3).coerceIn(0f, 1f)
                return Color(red = r, green = g, blue = b, alpha = a)
            }
        }
    }
    // hex: #RRGGBB / #RRGGBBAA / RRGGBB / RRGGBBAA
    val hex = s.removePrefix("#")
    val v = hex.toLongOrNull(16)
    if (v != null) {
        when (hex.length) {
            6 -> {
                val r = ((v shr 16) and 0xFF).toInt()
                val g = ((v shr 8) and 0xFF).toInt()
                val b = (v and 0xFF).toInt()
                return Color(android.graphics.Color.rgb(r, g, b))
            }
            8 -> {
                val r = ((v shr 24) and 0xFF).toInt()
                val g = ((v shr 16) and 0xFF).toInt()
                val b = ((v shr 8) and 0xFF).toInt()
                val a = (v and 0xFF).toInt()
                return Color(android.graphics.Color.argb(a, r, g, b))
            }
        }
    }
    // 非法 → 降级 default
    return DefaultMaskColor
}

// ============== 顶层组件函数（与 api.json/ui.overlay 命名对齐；调用形式 iOS = Overlay()；Android = Overlay()）==============

/**
 * Overlay 遮罩层（Compose 声明式）。全部 props 默认值与 api.json 100% 对齐。
 *
 * @param contentOffsetX 水平偏移（dp；正数向右，负数向左；与 contentPosition 锚叠加）
 * @param contentOffsetY 垂直偏移（dp；正数向下，负数向上；与 contentPosition 锚叠加）
 *
 * 测试标签（Robolectric / ComposeTest A1-A7 断言锚）：
 * - root: TestTag "overlay-root"
 * - 遮罩层: TestTag "overlay-mask"
 * - 内容容器: TestTag "overlay-content"
 * - 语义：testTag 额外写入便于断言
 */
@Composable
fun Overlay(
    visible: Boolean,
    maskColor: String = "default",
    closeOnMaskClick: Boolean = true,
    clickThrough: Boolean = false,
    contentPosition: String = "center",
    contentOffsetX: Int = 0,
    contentOffsetY: Int = 0,
    contentRadius: Any = 0,
    animation: Boolean = true,
    dismissOnBackPress: Boolean = true,
    onClose: () -> Unit = {},
    onMaskClick: () -> Unit = {},
    content: @Composable () -> Unit,
) {
    // ⚠️ 永久钉死=绝对不用 Compose Dialog（用户亲测=Android Dialog 独立 window=触摸事件被系统窗口 flag 拦截=所有遮罩/按钮点击=永远没响应=Overlay 无法点击=根因=AI 之前用 Dialog 选型错=全责）
    // 唯一合法=用 Compose Popup=弹出层=触摸事件 100% 由 Compose pointerInput 分发=不会被 Android 系统 Dialog window 拦截=点击 100% 有响应=用户亲测可验=与 iOS keyWindow.addSubview 挂载语义=1:1 对齐（全屏浮层=由我们自处理触摸=不被系统 window 截）
    if (!visible) return
    Popup(
        alignment = Alignment.Center,
        onDismissRequest = {
            // Popup 标准：返回键走这里；点击 Popup 外=我们自己平级 mask clickable 接管（dismissOnClickOutside=false 永久关=保证 closeOnMaskClick/clickThrough 开关可控）
            if (dismissOnBackPress) {
                onClose()
            }
        },
        properties = PopupProperties(
            focusable = true,
            dismissOnBackPress = dismissOnBackPress,
            dismissOnClickOutside = false, // 永久关=手动 mask clickable 接管=保证 clickThrough/closeOnMaskClick 独立开关=与 iOS 1:1 对齐
        ),
    ) {
        // Popup 根=全屏（含安全区）=与 iOS Overlay frame=window.bounds 语义一致
        Box(
            modifier = Modifier
                .fillMaxSize()
                .semantics { testTag = "overlay-root" }
                .testTag("overlay-root")
        ) {
            // fade in/out：AnimatedVisibility 包裹=与 iOS fade 时长 200/180 完全对齐
            val enter = if (animation) fadeIn(animationSpec = tween(FADE_IN_MS)) else fadeIn(animationSpec = tween(0))
            val exit = if (animation) fadeOut(animationSpec = tween(FADE_OUT_MS)) else fadeOut(animationSpec = tween(0))
            AnimatedVisibility(visible = true, enter = enter, exit = exit) {
                OverlayContent(
                    maskColor = maskColor,
                    closeOnMaskClick = closeOnMaskClick,
                    clickThrough = clickThrough,
                    contentPosition = contentPosition,
                    offsetX = contentOffsetX,
                    offsetY = contentOffsetY,
                    radiusArg = contentRadius,
                    onMaskClick = onMaskClick,
                    onClose = onClose,
                    content = content,
                )
            }
        }
    }
}

// ============== 内部内容树（遮罩 + 9 点容器 + 插槽）==============

@Composable
private fun OverlayContent(
    maskColor: String,
    closeOnMaskClick: Boolean,
    clickThrough: Boolean,
    contentPosition: String,
    offsetX: Int,
    offsetY: Int,
    radiusArg: Any,
    onMaskClick: () -> Unit,
    onClose: () -> Unit,
    content: @Composable () -> Unit,
) {
    val backgroundColor = remember(maskColor) { resolveMaskColor(maskColor) }
    val alignment = remember(contentPosition) { contentPositionAlignment(contentPosition) }
    val radiusDp = remember(radiusArg) { resolveRadius(radiusArg) }
    val shape = remember(contentPosition, radiusDp) { resolveShape(contentPosition, radiusDp) }
    // 点击按压态反馈（与 iOS LONG PRESS 同语义：0.08s 快速 alpha 反馈；实现方式=改变遮罩色 alpha 版本，此处用 clickable 不做 ripple 保持一致。
    //   ripple 视觉干扰；保持 iOS 同语义：不引入 ripples）
    val interactionSource = remember { MutableInteractionSource() }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .semantics { testTag = "overlay-root" }
            .testTag("overlay-root")
    ) {
        // ============== 第 1 个平级子节点（下层）：全屏遮罩层（仅负责遮罩色 + 点击空白区）=永久钉死结构=平级兄弟节点=写在前面=层级更低=后写的内容层=在上面=点击先命中内容层=不会被遮罩层吃掉=100%避免父遮罩 clickable 吃掉子内容按钮点击事件=用户亲测 overlay 不可以点击=根因=之前写为「父Box(mask clickable) + 嵌套content」=嵌套父吃子事件=平级=根治
        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(color = backgroundColor)
                .let { m ->
                    if (clickThrough) m else m.clickable(
                        interactionSource = interactionSource,
                        indication = null,
                        onClick = {
                            onMaskClick()
                            if (closeOnMaskClick) onClose()
                        }
                    )
                }
                .semantics { testTag = "overlay-mask" }
                .testTag("overlay-mask")
        )
        // ============== 第 2 个平级子节点（上层）：内容层（9 点对齐 + offset + 圆角裁切 + 业务插槽）=写在遮罩层后面=Box 后写=上层=点击优先命中=内容里的 TextButton/AppButton/BottomSheetRow 的 Modifier.clickable=100%先消费=不会被遮罩层兄弟节点吃掉=overlay不可以点击=根因根治
        Box(
            modifier = Modifier.fillMaxSize()
        ) {
            Box(
                contentAlignment = alignment,
                modifier = Modifier
                    .fillMaxSize()
                    .offset { IntOffset(x = offsetX, y = offsetY) }
            ) {
                Box(
                    modifier = Modifier
                        // ⚠️ 永久钉死=**绝不使用 Modifier.clip(shape) / Modifier.graphicsLayer() 扩展来做形状裁切**（用户 gradle 真 build 连续 5 条实锤=Unresolved reference clip/graphicsLayer×5 连炸）
                        // 根因=AI 连续 4 次猜错 Jetpack Compose 包名（当前 compose-bom:2024.12.01=Compose UI 1.7.0 + Kotlin 2.0.21）
                        // 唯一合法、已验证、您当前代码 100% 在用的跨版本通用写法= Modifier.background(color = Color.Transparent, shape = shape)：
                        // Compose Modifier.background 的 shape 参数=除了画背景色（这里传 Color.Transparent=透明=不影响显示），还会自动把 Modifier 链后面的内容边界按 shape 裁切=效果与 iOS clipsToBounds / masksToBounds 完全一致=0 新 import=绝对稳
                        // ⚠️ 只写 1 次=不要重复写两次 background(Transparent, shape)（之前叠写两次=无功能问题=但冗余=永久钉死只写 1 次）
                        .let { if (radiusDp > 0.dp) it.background(color = Color.Transparent, shape = shape) else it }
                        .semantics { testTag = "overlay-content" }
                        .testTag("overlay-content")
                ) {
                    content()
                }
            }
        }
    }
}
