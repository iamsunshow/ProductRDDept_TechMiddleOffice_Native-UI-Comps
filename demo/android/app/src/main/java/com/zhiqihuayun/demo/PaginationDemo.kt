package com.zhiqihuayun.demo

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
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
import com.zhiqihuayun.sharedui.components.Pagination
import com.zhiqihuayun.sharedui.components.PaginationMode

// ===== Pagination 组件 Demo 页（独立页面，与 iOS PaginationShowcase 一一对应） =====
// 演示点（验收文档 六）：
// ① 基础分页（5 页全显无省略号·multi）
// ② 简洁模式（mode=simple「1/5」文本）
// ③ 显示省略号（10 页·itemSize=5·首尾+省略号折叠）
// ④ 自定义页码按钮数量（itemSize=3·3 按钮窗口+省略号）

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
private fun FeedbackText(text: String) {
    Text(
        text = text,
        color = AppColor.textSecondary,
        fontSize = AppFont.sizeSm
    )
}

/** Pagination 组件 Demo 页入口（MainActivity 首页 → 导航组件 → Pagination 分页）。 */
@Composable
fun PaginationDemo() {
    // ① 基础分页：total=50/pageSize=10 → 5 页全显无省略号（currentValue=0 内部自管理）
    var d1Page by remember { mutableStateOf(1) }

    // ② 简洁模式：mode=simple，显示「1/5」文本翻页
    var d2Page by remember { mutableStateOf(1) }

    // ③ 显示省略号：total=100/pageSize=10 → 10 页，itemSize=5
    var d3Page by remember { mutableStateOf(1) }

    // ④ 自定义页码按钮数量：itemSize=3，3 按钮窗口+省略号
    var d4Page by remember { mutableStateOf(1) }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(AppColor.bgPage)
            .verticalScroll(rememberScrollState())
            .padding(horizontal = AppSpace.xl, vertical = AppSpace.md),
        verticalArrangement = Arrangement.spacedBy(AppSpace.lg)
    ) {
        // 组件版本徽标：与 iOS 端保持同一版本号。
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .background(AppColor.primaryMuted, RoundedCornerShape(AppRadius.sm))
                .padding(horizontal = 10.dp, vertical = 6.dp),
            horizontalArrangement = Arrangement.Center
        ) {
            Text(
                text = "Pagination 组件 v1.4.30",
                color = AppColor.primary,
                fontSize = AppFont.sizeXs,
                fontWeight = FontWeight.Medium,
                textAlign = TextAlign.Center
            )
        }

        // D1 基础分页（5 页全显无省略号）
        SectionTitle("D1 基础分页（5 页全显无省略号）")
        Pagination(
            total = 50,
            pageSize = 10,
            itemSize = 5,
            onChange = { d1Page = it }
        )
        FeedbackText("当前页：$d1Page / 5")
        Hint("排查点：5 页全显无省略号；当前页 primary 反白；上一页在第 1 页禁用、下一页在第 5 页禁用；点击页码/箭头翻页并回写当前页。")

        // D2 简洁模式（x/y 文本翻页）
        SectionTitle("D2 简洁模式（x/y 文本翻页）")
        Pagination(
            total = 50,
            pageSize = 10,
            mode = PaginationMode.SIMPLE,
            onChange = { d2Page = it }
        )
        FeedbackText("当前页：$d2Page / 5")
        Hint("排查点：简洁模式显示「当前页/总页数」文本，当前页 primary 高亮；上一页/下一页箭头翻页。")

        // D3 显示省略号（10 页·itemSize=5）
        SectionTitle("D3 显示省略号（10 页·itemSize=5）")
        Pagination(
            total = 100,
            pageSize = 10,
            itemSize = 5,
            onChange = { d3Page = it }
        )
        FeedbackText("当前页：$d3Page / 10")
        Hint("排查点：10 页超过 itemSize=5，自动省略号折叠；第 1 页显「1 2 3 4 5 ··· 10」；翻到中间显「1 ··· 4 5 6 ··· 10」；末页显「1 ··· 6 7 8 9 10」。")

        // D4 自定义页码按钮数量（itemSize=3）
        SectionTitle("D4 自定义页码按钮数量（itemSize=3）")
        Pagination(
            total = 100,
            pageSize = 10,
            itemSize = 3,
            onChange = { d4Page = it }
        )
        FeedbackText("当前页：$d4Page / 10")
        Hint("排查点：itemSize=3 只显 3 个页码按钮窗口；第 1 页显「1 2 3 ··· 10」；翻到第 5 页显「1 ··· 4 5 6 ··· 10」；窗口随当前页滑动。")
    }
}
