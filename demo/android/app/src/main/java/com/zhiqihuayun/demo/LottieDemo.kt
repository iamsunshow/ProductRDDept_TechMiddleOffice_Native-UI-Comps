package com.zhiqihuayun.demo

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppFont
import com.zhiqihuayun.foundation.design.AppRadius
import com.zhiqihuayun.foundation.design.AppSpace
import com.zhiqihuayun.sharedui.components.AppButton
import com.zhiqihuayun.sharedui.components.Lottie
import com.zhiqihuayun.sharedui.components.rememberLottieState

// ===== Lottie 组件 Demo 页（独立页面，与 iOS LottieShowcase 一一对应） =====
// 演示点（验收文档）：
// ① 基础动画（autoplay 自动播放）
// ② 循环播放（loop=true 持续循环）
// ③ 控制播放暂停（按钮 play/pause/stop）
// ④ 自定义尺寸（80×80）

@Composable
private fun SectionTitle(text: String) {
    Text(
        text = text,
        color = AppColor.textPrimary,
        fontSize = AppFont.sizeMd,
        fontWeight = FontWeight.SemiBold
    )
}

@Composable
private fun Hint(text: String) {
    Text(
        text = text,
        color = AppColor.textSecondary,
        fontSize = AppFont.sizeXs
    )
}

@Composable
private fun LottieCard(content: @Composable () -> Unit) {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .background(AppColor.bgCard, RoundedCornerShape(AppRadius.lg))
            .padding(AppSpace.lg),
        contentAlignment = Alignment.Center
    ) {
        content()
    }
}

/** Lottie 组件 Demo 页入口（MainActivity 首页 → 信息展示 → Lottie 动画）。 */
@Composable
fun LottieDemo() {
    // D3 受控状态：按钮调 play/pause/stop
    val d3State = rememberLottieState(autoplay = true)

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(AppColor.bgPage)
            .verticalScroll(rememberScrollState())
            .padding(horizontal = AppSpace.xl, vertical = AppSpace.md),
        verticalArrangement = Arrangement.spacedBy(AppSpace.lg)
    ) {
        // 组件版本徽标：与 iOS 端保持同一版本号。
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .background(AppColor.primaryMuted, RoundedCornerShape(AppRadius.sm))
                .padding(horizontal = 10.dp, vertical = 6.dp)
        ) {
            Text(
                text = "Lottie 组件 v1.4.29",
                color = AppColor.primary,
                fontSize = AppFont.sizeXs,
                fontWeight = FontWeight.Medium,
                textAlign = TextAlign.Center,
                modifier = Modifier.fillMaxWidth()
            )
        }

        // D1 基础动画（autoplay 自动播放）
        SectionTitle("D1 基础动画（autoplay 自动播放）")
        LottieCard {
            Lottie(
                source = "happy",
                autoplay = true,
                loop = true,
            )
        }
        Hint("排查点：挂载后自动播放，环形旋转指示器转动 + 显示动画名称「happy」+ 状态「播放中」。")

        // D2 循环播放（loop=true 持续循环）
        SectionTitle("D2 循环播放（loop=true 持续循环）")
        LottieCard {
            Lottie(
                source = "loop",
                autoplay = true,
                loop = true,
            )
        }
        Hint("排查点：loop=true 时持续循环播放，不触发 onComplete；状态始终为「播放中」。")

        // D3 控制播放暂停（按钮 play/pause/stop）
        SectionTitle("D3 控制播放暂停（按钮切换）")
        LottieCard {
            Lottie(
                source = "control",
                autoplay = true,
                loop = true,
                state = d3State,
            )
        }
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(AppSpace.sm)
        ) {
            AppButton(
                text = "播放",
                onClick = { d3State.play() },
                modifier = Modifier.weight(1f),
                fontSize = AppFont.sizeSm,
                height = 40.dp
            )
            AppButton(
                text = "暂停",
                onClick = { d3State.pause() },
                modifier = Modifier.weight(1f),
                fontSize = AppFont.sizeSm,
                height = 40.dp
            )
            AppButton(
                text = "停止",
                onClick = { d3State.stop() },
                modifier = Modifier.weight(1f),
                fontSize = AppFont.sizeSm,
                height = 40.dp
            )
        }
        Hint("排查点：点「播放」环形旋转启动+状态「播放中」；点「暂停」旋转停止+状态「已暂停」；点「停止」旋转停止+状态「已停止」。")

        // D4 自定义尺寸（80×80）
        SectionTitle("D4 自定义尺寸（80×80）")
        LottieCard {
            Lottie(
                source = "mini",
                autoplay = true,
                loop = true,
                modifier = Modifier.size(80.dp)
            )
        }
        Hint("排查点：size=80×80 时动画区域缩小，仍正常播放+显示名称「mini」。")
    }
}
