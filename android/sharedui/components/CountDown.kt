// CountDown 倒计时组件（Compose 版，对齐 iOS CountDownView）。
//
// 纯展示型倒计时数字组件：输入目标结束时间戳（targetTime，epoch 毫秒）或剩余秒数（remaining），
// 组件自驱每秒基于时间戳重算 remaining 并格式化显示（HH:mm:ss / DD 天 HH:mm:ss / mm:ss），
// 支持半受控暂停（paused）与结束回调（onEnd）。
//
// 设计要点（与 design-spec/countdown-design-spec.html 一致）：
// - targetTime 优先；为 0 时使用 remaining（内部转 targetTime = now + remaining×1000）
// - 每秒重算 remaining = target - now + 已累计暂停时长（基于时间戳，无累积误差）
// - paused=true 暂停（停表保剩余值）；恢复时把暂停时长累加到偏移，剩余值连续不跳秒
// - format 占位符：DD=天 / HH=时(24h) / mm=分 / ss=秒
// - remaining ≤ 0 触发 onEnd 一次

package com.zhiqihuayun.sharedui.components

import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppFont
import kotlinx.coroutines.delay

/**
 * 倒计时组件：每秒基于时间戳重算剩余时间并格式化为字符串展示。
 *
 * @param targetTime 目标结束时间戳（epoch 毫秒，绝对时间，优先级高于 remaining）。0 表示使用 remaining
 * @param remaining 剩余秒数（targetTime 为 0 时使用，内部转 targetTime = now + remaining×1000）
 * @param format 格式串，占位符：DD=天 / HH=时(24h) / mm=分 / ss=秒，支持字面量（如 "DD 天 HH:mm:ss"、"mm:ss"）
 * @param autoStart 是否自动开始倒计时（false 时不开始计时；与 paused 共同决定 running = autoStart && !paused）
 * @param paused 半受控暂停：true=暂停计时（停表保剩余值）；false=继续（暂停时长累加到偏移，剩余值连续）
 * @param onEnd 剩余时间归零时触发一次；业务结束动作（跳转/提示）由宿主在此处理
 * @param modifier 文本修饰符
 */
@Composable
fun CountDown(
    targetTime: Long = 0,
    remaining: Long = 0,
    format: String = "HH:mm:ss",
    autoStart: Boolean = true,
    paused: Boolean = false,
    onEnd: (() -> Unit)? = null,
    modifier: Modifier = Modifier,
) {
    // 有效目标时间戳：targetTime 优先，否则 now + remaining×1000。
    val initialTarget = remember(targetTime, remaining) {
        if (targetTime > 0) targetTime else System.currentTimeMillis() + remaining * 1000L
    }
    // 已累计的暂停时长（毫秒）：恢复时把暂停期间流逝的时间折叠进偏移，使剩余值连续。
    var pausedAccumMs by remember(initialTarget) { mutableStateOf(0L) }
    // 当前正在进行中的暂停起点（毫秒），null=未暂停。
    var pauseStartMs by remember(initialTarget) { mutableStateOf<Long?>(null) }
    // 当前展示的剩余秒数。
    var displayedRemaining by remember(initialTarget) {
        mutableStateOf(maxOf(0L, (initialTarget - System.currentTimeMillis()) / 1000))
    }
    // 是否已结束（防止 onEnd 多次触发）。
    var ended by remember(initialTarget) { mutableStateOf(false) }

    val running = autoStart && !paused

    // 暂停/恢复副作用：running 翻转时记录暂停起点，或把暂停时长折叠进累计偏移。
    LaunchedEffect(running) {
        if (running) {
            val ps = pauseStartMs
            if (ps != null) {
                pausedAccumMs += System.currentTimeMillis() - ps
                pauseStartMs = null
            }
        } else {
            // 进入暂停（autoStart=true 且 paused=true）：记录起点。
            if (autoStart && pauseStartMs == null) {
                pauseStartMs = System.currentTimeMillis()
            }
        }
    }

    // 计时主循环：每秒重算 remaining，归零触发 onEnd。
    LaunchedEffect(initialTarget, running, ended) {
        if (!running || ended) return@LaunchedEffect
        while (true) {
            val now = System.currentTimeMillis()
            // 进行中的暂停时长：暂停期间 now 持续增长，加上 ongoing 后 remMs 保持恒定（冻结）。
            val ongoing = pauseStartMs?.let { now - it } ?: 0L
            val remMs = initialTarget - now + pausedAccumMs + ongoing
            displayedRemaining = maxOf(0L, remMs / 1000)
            if (remMs <= 0) {
                ended = true
                onEnd?.invoke()
                break
            }
            delay(1000)
        }
    }

    Text(
        text = formatCountDown(displayedRemaining, format),
        color = AppColor.textPrimary,
        fontSize = AppFont.sizeLg,
        fontWeight = FontWeight.SemiBold,
        modifier = modifier,
    )
}

// MARK: - 格式化

/**
 * 倒计时格式化：用占位符 DD/HH/mm/ss 替换为 2 位数字，其余字符原样保留。
 *
 * 示例：
 * - formatCountDown(3665, "HH:mm:ss") = "01:01:05"
 * - formatCountDown(95445, "DD 天 HH:mm:ss") = "01 天 02:30:45"
 * - formatCountDown(185, "mm:ss") = "03:05"
 */
fun formatCountDown(remainingSeconds: Long, format: String): String {
    val total = remainingSeconds.coerceAtLeast(0)
    val days = total / 86400
    val hours = (total % 86400) / 3600
    val minutes = (total % 3600) / 60
    val seconds = total % 60
    return format
        .replace("DD", days.toString().padStart(2, '0'))
        .replace("HH", hours.toString().padStart(2, '0'))
        .replace("mm", minutes.toString().padStart(2, '0'))
        .replace("ss", seconds.toString().padStart(2, '0'))
}
