package com.zhiqihuayun.demo

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.key
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
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
import com.zhiqihuayun.sharedui.components.CountDown

// ===== CountDown 倒计时组件 Demo 页（独立页面，与 iOS CountDownShowcase 一一对应） =====
// 演示点（验收文档）：
// ① 基础倒计时（剩余 1 小时，HH:mm:ss 自驱每秒递减）
// ② 自定义格式（跨天长倒计时，DD 天 HH:mm:ss）
// ③ 暂停/继续（半受控 paused 外部按钮驱动，恢复后剩余值连续不跳秒）
// ④ 结束回调（短倒计时 5 秒，onEnd 触发宿主提示文案）

@Composable
fun CountDownDemo() {
    // D3 暂停/继续：外部 paused 状态
    var d3Paused by remember { mutableStateOf(false) }
    // D4 结束回调：重置令牌（key 强制重挂载 CountDown 重新开始 5 秒）+ 结束标记
    var d4ResetKey by remember { mutableStateOf(0) }
    var d4Ended by remember { mutableStateOf(false) }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(AppColor.bgPage)
            .verticalScroll(rememberScrollState())
            .padding(horizontal = AppSpace.xl, vertical = AppSpace.md),
        verticalArrangement = Arrangement.spacedBy(AppSpace.lg)
    ) {
        // 组件版本徽标（§7h 强制：汇报/验证必带版本号）
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .background(AppColor.primaryMuted, RoundedCornerShape(AppRadius.sm))
                .padding(horizontal = 10.dp, vertical = 6.dp)
        ) {
            Text(
                text = "CountDown 组件 v1.4.27",
                color = AppColor.primary,
                fontSize = AppFont.sizeXs,
                fontWeight = FontWeight.Medium,
                textAlign = TextAlign.Center,
                modifier = Modifier.fillMaxWidth()
            )
        }

        // D1 基础倒计时：剩余 1 小时，format=HH:mm:ss
        Text(
            text = "D1 基础倒计时（remaining=3600s，HH:mm:ss）",
            color = AppColor.textPrimary,
            fontSize = AppFont.sizeMd,
            fontWeight = FontWeight.SemiBold
        )
        Box(modifier = Modifier.fillMaxWidth(), contentAlignment = Alignment.Center) {
            CountDown(remaining = 3600L, format = "HH:mm:ss")
        }
        Text(
            text = "排查点：显示「01:00:00」并每秒自驱递减至「00:00:00」；基于时间戳重算无累积误差。",
            color = AppColor.textSecondary,
            fontSize = AppFont.sizeXs
        )

        // D2 自定义格式：跨天长倒计时，format=DD 天 HH:mm:ss
        Text(
            text = "D2 自定义格式（跨天长倒计时，DD 天 HH:mm:ss）",
            color = AppColor.textPrimary,
            fontSize = AppFont.sizeMd,
            fontWeight = FontWeight.SemiBold
        )
        Box(modifier = Modifier.fillMaxWidth(), contentAlignment = Alignment.Center) {
            // 1 天 2 时 30 分 45 秒 = 86400 + 7200 + 1800 + 45 = 95445 秒
            CountDown(remaining = 95445L, format = "DD 天 HH:mm:ss")
        }
        Text(
            text = "排查点：显示「01 天 02:30:45」并每秒递减；占位符 DD/HH/mm/ss 替换为 2 位数字，字面量「 天 」原样保留。",
            color = AppColor.textSecondary,
            fontSize = AppFont.sizeXs
        )

        // D3 暂停/继续：半受控 paused 外部按钮驱动
        Text(
            text = "D3 暂停/继续（半受控 paused 外部驱动）",
            color = AppColor.textPrimary,
            fontSize = AppFont.sizeMd,
            fontWeight = FontWeight.SemiBold
        )
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(AppSpace.sm)
        ) {
            AppButton(
                text = if (d3Paused) "继续" else "暂停",
                onClick = { d3Paused = !d3Paused },
                modifier = Modifier.weight(1f),
                fontSize = AppFont.sizeSm,
                height = 40.dp
            )
        }
        Box(modifier = Modifier.fillMaxWidth(), contentAlignment = Alignment.Center) {
            CountDown(
                remaining = 600L,
                format = "mm:ss",
                paused = d3Paused
            )
        }
        Text(
            text = "排查点：点「暂停」倒计时冻结（mm:ss 停住），点「继续」从冻结值恢复递减（不跳秒，剩余值连续）。",
            color = AppColor.textSecondary,
            fontSize = AppFont.sizeXs
        )

        // D4 结束回调：短倒计时 5 秒，onEnd 触发宿主提示
        Text(
            text = "D4 结束回调（remaining=5s，onEnd 触发宿主提示）",
            color = AppColor.textPrimary,
            fontSize = AppFont.sizeMd,
            fontWeight = FontWeight.SemiBold
        )
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(AppSpace.sm)
        ) {
            AppButton(
                text = "重置 5 秒倒计时",
                onClick = {
                    d4Ended = false
                    d4ResetKey++
                },
                modifier = Modifier.weight(1f),
                fontSize = AppFont.sizeSm,
                height = 40.dp
            )
        }
        Box(modifier = Modifier.fillMaxWidth(), contentAlignment = Alignment.Center) {
            // key 强制重挂载：d4ResetKey 变化时 CountDown 内部状态全部重置，重新开始 5 秒倒计时。
            key(d4ResetKey) {
                CountDown(
                    remaining = 5L,
                    format = "ss 秒",
                    onEnd = { d4Ended = true }
                )
            }
        }
        Text(
            text = if (d4Ended) "✅ 倒计时结束，onEnd 已触发宿主提示" else "排查点：5 秒后倒计时归零，onEnd 触发，提示文案由灰变绿。",
            color = if (d4Ended) AppColor.primary else AppColor.textSecondary,
            fontSize = AppFont.sizeXs
        )
    }
}
