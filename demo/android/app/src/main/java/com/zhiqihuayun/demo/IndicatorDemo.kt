package com.zhiqihuayun.demo

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppFont
import com.zhiqihuayun.foundation.design.AppRadius
import com.zhiqihuayun.foundation.design.AppSpace
import com.zhiqihuayun.sharedui.components.Indicator
import com.zhiqihuayun.sharedui.components.IndicatorDirection

// ===== Indicator 组件 Demo 页（独立页面，与 iOS IndicatorShowcase 一一对应） =====
// 演示点（验收文档）：
// ① 基础指示器（横向圆点序列，色变高亮）
// ② 数字总页数（showNumber 胶囊「current+1/total」）
// ③ 竖向指示器（direction=vertical）
// ④ 自定义样式（block 长条 + success 绿 + size 8）

@Composable
private fun Hint(text: String) {
    Text(
        text = text,
        color = AppColor.textSecondary,
        fontSize = AppFont.sizeXs
    )
}

/** Indicator 组件 Demo 页入口（MainActivity 首页 → 导航组件 → Indicator 指示器）。 */
@Composable
fun IndicatorDemo() {
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
                text = "Indicator 组件 v1.4.29",
                color = AppColor.primary,
                fontSize = AppFont.sizeXs,
                fontWeight = FontWeight.Medium,
                textAlign = TextAlign.Center,
                modifier = Modifier.fillMaxWidth()
            )
        }

        // D1 基础指示器（横向 5 点·第 2 高亮·色变）
        DemoSectionCard(title = "D1 基础指示器（横向 5 点·第 2 高亮）") {
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(vertical = AppSpace.md),
                contentAlignment = Alignment.Center
            ) {
                Indicator(current = 1, total = 5)
            }
        }
        Hint("排查点：5 个圆点横向排布，第 2 个高亮（primary 蓝），其余灰（gray15）；block=false 仅色变不变形。")

        // D2 数字总页数（showNumber 胶囊「2/5」）
        DemoSectionCard(title = "D2 数字总页数（showNumber 胶囊）") {
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(vertical = AppSpace.md),
                contentAlignment = Alignment.Center
            ) {
                Indicator(current = 1, total = 5, showNumber = true)
            }
        }
        Hint("排查点：显示「2 / 5」数字胶囊，primary 底白字 12sp Semibold，圆角胶囊。")

        // D3 竖向指示器（direction=vertical·4 点·第 2 高亮）
        DemoSectionCard(title = "D3 竖向指示器（direction=vertical）") {
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(vertical = AppSpace.md),
                contentAlignment = Alignment.Center
            ) {
                Indicator(
                    current = 1,
                    total = 4,
                    direction = IndicatorDirection.vertical
                )
            }
        }
        Hint("排查点：4 个圆点纵向排布，第 2 个高亮；竖向场景（竖向轮播/分步表单侧边指示）。")

        // D4 自定义样式（block 长条 + success 绿 + size 8）
        DemoSectionCard(title = "D4 自定义样式（block 长条 + success 绿 + size 8）") {
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(vertical = AppSpace.md),
                contentAlignment = Alignment.Center
            ) {
                Indicator(
                    current = 1,
                    total = 4,
                    block = true,
                    size = 8f,
                    activeColor = AppColor.success
                )
            }
        }
        Hint("排查点：选中点变长条（width=size*2.5=20dp），success 绿色，size=8dp；其余圆点灰色不变形。")
    }
}
