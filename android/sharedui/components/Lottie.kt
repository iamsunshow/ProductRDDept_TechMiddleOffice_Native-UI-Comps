// Lottie 动画组件（Compose 版，对齐 iOS LottieView）。
//
// 渲染 Lottie/Bodymovin JSON 动画的容器——输入动画源（source）、自动播放（autoplay）、
// 循环（loop）、播放速度（speed）、自定义尺寸（modifier.size），提供 play/pause/stop 命令式
// 控制（LottieState）与 onComplete 播放完成回调（仅 loop=false 触发）。
//
// 一期占位渲染（与设计规格 lottie-design-spec.html 一致）：
// - source=动画名称占位（Lottie 库集成=二期，接入 Lottie Compose 后 source 映射 JSON）
// - 占位视觉=CircularProgressIndicator 环形旋转 + Text 动画名
// - API 契约与二期完全一致，二期激活真实渲染时调用方零改动
//
// 决策（与设计规格 lottie-design-spec.html 一致）：
// - P1-C source 字符串占位（一期零三方依赖，API 契约与二期一致）
// - P2-A autoplay=true loop=true（与 NutUI/lottie-react 默认一致）
// - P3-A LottieState play/pause/stop 命令式 + autoplay 声明式双模
// - P4-A 一期占位渲染+全 API+demo 四段（Lottie 库集成=二期）

package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppFont
import com.zhiqihuayun.foundation.design.AppRadius
import com.zhiqihuayun.foundation.design.AppSpace
import kotlinx.coroutines.delay

/**
 * Lottie 动画播放状态（命令式控制，类似 rememberScrollState）。
 *
 * - [isPlaying] 当前是否播放中
 * - [play] 继续播放（暂停后恢复）
 * - [pause] 暂停在当前帧，不复位
 * - [stop] 停止并复位到首帧
 *
 * @param initialPlaying 初始播放态（autoplay=true 时为 true）
 */
class LottieState(initialPlaying: Boolean = true) {
    var isPlaying by mutableStateOf(initialPlaying)
        private set

    /** 播放状态标签（播放中/已暂停/已停止）。 */
    var statusTag by mutableStateOf(if (initialPlaying) "播放中" else "已暂停")
        private set

    fun play() {
        if (!isPlaying) {
            isPlaying = true
            statusTag = "播放中"
        }
    }

    fun pause() {
        if (isPlaying) {
            isPlaying = false
            statusTag = "已暂停"
        }
    }

    fun stop() {
        isPlaying = false
        statusTag = "已停止"
    }
}

/**
 * 创建并记住一个 [LottieState]。
 *
 * @param autoplay 初始是否播放中（autoplay=true 时 state.isPlaying 初始为 true）
 */
@Composable
fun rememberLottieState(autoplay: Boolean = true): LottieState {
    return remember { LottieState(initialPlaying = autoplay) }
}

/**
 * Lottie 动画容器：渲染 Lottie/Bodymovin JSON 动画。
 *
 * 一期占位渲染=环形旋转指示器+动画名称；二期接入 Lottie 库后 source 映射真实 JSON 激活渲染。
 *
 * @param source 动画源标识（一期=动画名称占位，二期=Lottie JSON 文件名/路径）
 * @param loop 是否循环播放（默认 true）
 * @param autoplay 是否自动播放（默认 true；驱动 state 初始播放态）
 * @param speed 播放速度（1.0=正常，0.5=慢速，2.0=快速）
 * @param state 播放状态（默认 rememberLottieState(autoplay)），命令式 play/pause/stop 控制
 * @param onComplete 播放完成回调（仅 loop=false 时触发；循环模式不触发）
 * @param modifier 外部修饰（D4 自定义尺寸用 modifier.size）
 */
@Composable
fun Lottie(
    source: String = "",
    loop: Boolean = true,
    autoplay: Boolean = true,
    speed: Float = 1f,
    state: LottieState = rememberLottieState(autoplay),
    onComplete: (() -> Unit)? = null,
    modifier: Modifier = Modifier,
) {
    val name = if (source.isEmpty()) "animation" else source

    // 非循环模式：模拟播放完成触发 onComplete（二期由 Lottie 动画实例完成回调驱动）。
    if (!loop && onComplete != null) {
        LaunchedEffect(state.isPlaying) {
            if (state.isPlaying) {
                delay((3000L / maxOf(speed, 0.1f)).toLong())
                if (state.isPlaying) {
                    onComplete.invoke()
                }
            }
        }
    }

    // 安卓禁令：圆角裁切用 background(shape=圆角矩形)，不用 Modifier.clip()/graphicsLayer()。
    Box(
        modifier = modifier
            .background(AppColor.bgCard, RoundedCornerShape(AppRadius.sm))
            .testTag("lottie-container"),
        contentAlignment = Alignment.Center,
    ) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(AppSpace.xs),
        ) {
            // 占位旋转指示器：播放中=旋转动画，暂停/停止=静态环。
            if (state.isPlaying) {
                CircularProgressIndicator(
                    color = AppColor.primary,
                    strokeWidth = 3.dp,
                    strokeCap = StrokeCap.Round,
                    modifier = Modifier
                        .size(28.dp)
                        .testTag("lottie-spinner"),
                )
            } else {
                // 暂停/停止态：静态圆环（不旋转）。
                StaticRing()
            }
            Text(
                text = name,
                color = AppColor.textSecondary,
                fontSize = AppFont.sizeXs,
                modifier = Modifier.testTag("lottie-name"),
            )
            Text(
                text = state.statusTag,
                color = if (state.isPlaying) AppColor.primary else AppColor.gray25,
                fontSize = 10.sp,
                fontWeight = FontWeight.Medium,
                modifier = Modifier.testTag("lottie-status"),
            )
        }
    }
}

/**
 * 静态圆环（暂停/停止态占位）：不旋转的圆环边框。
 */
@Composable
private fun StaticRing() {
    androidx.compose.foundation.Canvas(
        modifier = Modifier
            .size(28.dp)
            .testTag("lottie-static-ring"),
    ) {
        drawCircle(color = AppColor.gray6, style = Stroke(width = 3f))
    }
}
