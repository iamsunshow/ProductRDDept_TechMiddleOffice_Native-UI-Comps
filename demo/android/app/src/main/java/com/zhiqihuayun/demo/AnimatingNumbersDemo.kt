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
import com.zhiqihuayun.sharedui.components.AnimatingNumbers
import com.zhiqihuayun.sharedui.components.AnimatingNumbersSize
import com.zhiqihuayun.sharedui.components.AppButton

// ===== AnimatingNumbers 数字动画组件 Demo 页（独立页面，与 iOS AnimatingNumbersShowcase 一一对应） =====
// 演示点（门禁 A 规格 5 节 四组 Demo）：
// ① 基础用法（value=678.94，挂载后 delay 300ms、1000ms 内从 0 滚到目标）
// ② 位数+千分位+自定义色（value=1578.94、length=8 前补 0、thousands=true、color=danger）
// ③ 动态修改数据（宿主按钮切 1578.94 → 88.80 → 12345.67，每次切换全体从 0 重滚）
// ④ 尺寸/外观档位（size=large 32/48；size=small 14/24 + backgroundColor 灰底块 + cornerRadius 4）

@Composable
private fun AnimNumSectionTitle(text: String) {
    Text(
        text = text,
        color = AppColor.textPrimary,
        fontSize = AppFont.sizeMd,
        fontWeight = FontWeight.SemiBold
    )
}

@Composable
private fun AnimNumHint(text: String) {
    Text(
        text = text,
        color = AppColor.textSecondary,
        fontSize = AppFont.sizeXs
    )
}

/** AnimatingNumbers 组件 Demo 页入口（MainActivity 首页 → 信息展示 → AnimatingNumbers 数字动画）。 */
@Composable
fun AnimatingNumbersDemo() {
    // D3 动态修改数据：宿主 state 驱动 value（label 与 value 双轨，88.80 保留两位展示，与 iOS 1:1）
    var d3Value by remember { mutableStateOf(1578.94) }
    var d3Label by remember { mutableStateOf("1578.94") }

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
                text = "AnimatingNumbers 数字动画组件 v1.0",
                color = AppColor.primary,
                fontSize = AppFont.sizeXs,
                fontWeight = FontWeight.Medium,
                textAlign = TextAlign.Center,
                modifier = Modifier.fillMaxWidth()
            )
        }

        // D1 基础用法：value=678.94
        AnimNumSectionTitle("D1 基础用法（value=678.94）")
        AnimatingNumbers(value = 678.94)
        AnimNumHint("排查点：挂载后先停留 300ms（delay），再在 1000ms 内各位从 0 滚到目标字形，最终稳定显示「678.94」；小数点静态不滚动。")

        // D2 位数 + 千分位 + 自定义色
        AnimNumSectionTitle("D2 位数 + 千分位 + 自定义色")
        AnimatingNumbers(
            value = 1578.94,
            length = 8,
            thousands = true,
            color = AppColor.error
        )
        AnimNumHint("排查点：length=8 时整数部分前补 0（目标「001,578.94」），千分位逗号静态渲染不滚动，数字为 danger 红。")

        // D3 动态修改数据：宿主按钮切 value，每次切换全体从 0 重滚
        AnimNumSectionTitle("D3 动态修改数据（切换 value 重滚）")
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(AppSpace.sm)
        ) {
            AppButton(
                text = "1578.94",
                onClick = { d3Value = 1578.94; d3Label = "1578.94" },
                modifier = Modifier.weight(1f),
                fontSize = AppFont.sizeSm,
                height = 40.dp
            )
            AppButton(
                text = "88.80",
                onClick = { d3Value = 88.80; d3Label = "88.80" },
                modifier = Modifier.weight(1f),
                fontSize = AppFont.sizeSm,
                height = 40.dp
            )
            AppButton(
                text = "12345.67",
                onClick = { d3Value = 12345.67; d3Label = "12345.67" },
                modifier = Modifier.weight(1f),
                fontSize = AppFont.sizeSm,
                height = 40.dp
            )
        }
        AnimatingNumbers(value = d3Value, thousands = true)
        AnimNumHint("排查点：点任一按钮切换 value，整串数字先归零、再重新滚到新目标（当前 value=$d3Label）。")

        // D4 尺寸/外观档位：large / small + 灰底数位块
        AnimNumSectionTitle("D4 尺寸/外观档位（size large / small + 灰底块）")
        Column(verticalArrangement = Arrangement.spacedBy(AppSpace.md)) {
            AnimatingNumbers(value = 299.0, size = AnimatingNumbersSize.Large)
            AnimatingNumbers(
                value = 99.9,
                size = AnimatingNumbersSize.Small,
                backgroundColor = AppColor.gray6,
                cornerRadius = 4.dp
            )
        }
        AnimNumHint("排查点：第一行为 large（字号 32 / 窗口高 48）；第二行为 small（字号 14 / 窗口高 24）+ gray6 灰底数位块，圆角 4。")
    }
}
