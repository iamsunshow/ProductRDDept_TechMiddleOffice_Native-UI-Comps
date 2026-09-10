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
import com.zhiqihuayun.sharedui.components.AppButton
import com.zhiqihuayun.sharedui.components.Ellipsis

// ===== Ellipsis 文本省略 Demo 页（独立页面，与 iOS EllipsisShowcase 一一对应） =====
// 演示点（验收文档）：
// ① 基础单行省略 + 点击展开/收起（rows=1）
// ② 多行省略（rows=3 长文本截断 + 展开）
// ③ 自定义展开收起文案
// ④ 受控外部驱动 expanded（外部按钮控制展开态）

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

/** Ellipsis 组件 Demo 页入口（MainActivity 首页 → 信息展示 → Ellipsis 文本省略）。 */
@Composable
fun EllipsisDemo() {
    // D4 受控模式：外部 state 驱动
    var d4Expanded by remember { mutableStateOf(false) }
    var d4CallbackInfo by remember { mutableStateOf("等待 onExpandChange 回调…") }

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
                text = "Ellipsis 组件 v1.4.27",
                color = AppColor.primary,
                fontSize = AppFont.sizeXs,
                fontWeight = FontWeight.Medium,
                textAlign = TextAlign.Center,
                modifier = Modifier.fillMaxWidth()
            )
        }

        // D1 基础单行省略 + 点击展开/收起（rows=1，expanded=null 内部自持）
        SectionTitle("D1 基础单行省略 + 点击展开/收起（rows=1）")
        Ellipsis(
            content = "这是一段很长的文本内容用于演示单行省略效果，当文本超出容器宽度时会自动截断显示省略号，点击可展开查看完整内容。",
            rows = 1,
        )
        Hint("排查点：单行文本超出宽度截断尾部省略号；点击文本任意位置展开显示全文+「收起」按钮；点击「收起」恢复截断。expanded=null=内部自持 state。")

        // D2 多行省略（rows=3 长文本截断 + 展开）
        SectionTitle("D2 多行省略（rows=3 长文本截断 + 展开）")
        Ellipsis(
            content = "这是一段很长的多行文本内容用于演示多行省略效果。当文本超过指定行数（此处 rows=3）时，会在第三行末尾截断并显示省略号。用户可以点击展开按钮查看完整内容，再次点击则收起回到截断状态。多行省略在商品描述、活动公告等场景非常常用，能够有效控制页面布局不被过长文本撑开。",
            rows = 3,
        )
        Hint("排查点：3 行后截断尾部省略号；点击展开后显示全文 + 「收起」按钮；点击收起恢复 3 行截断。")

        // D3 自定义展开收起文案
        SectionTitle("D3 自定义展开收起文案（expandText=\"查看全部\" / collapseText=\"收起内容\"）")
        Ellipsis(
            content = "自定义展开收起文案的演示文本，展开按钮文字改为「查看全部」，收起按钮文字改为「收起内容」，满足不同业务场景的文案需求。例如电商商品详情可能用「查看全部」更自然，而通知列表可能用「展开全文」更合适。",
            rows = 2,
            expandText = "查看全部",
            collapseText = "收起内容",
        )
        Hint("排查点：展开按钮显示「查看全部」而非默认「展开」；收起按钮显示「收起内容」而非默认「收起」。")

        // D4 受控外部驱动 expanded（外部按钮控制展开态）
        SectionTitle("D4 受控外部驱动 expanded（外部按钮控制展开态）")
        Text(
            text = d4CallbackInfo,
            color = AppColor.primary,
            fontSize = AppFont.sizeXs,
            fontWeight = FontWeight.Medium
        )
        Ellipsis(
            content = "受控模式演示：expanded 由外部 state 驱动，组件内部不自持。点击下方按钮切换展开/收起态，onExpandChange 回调会通知外部。受控模式适用于需要在外部逻辑中管理展开态的场景，例如只有登录用户才能展开全文。",
            rows = 2,
            expanded = d4Expanded,
            onExpandChange = { newValue ->
                d4CallbackInfo = "onExpandChange 回调：expanded=$newValue（外部按钮可同步切换）"
            },
        )
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(AppSpace.sm)
        ) {
            AppButton(
                text = "外部展开",
                onClick = {
                    d4Expanded = true
                    d4CallbackInfo = "外部按钮设置 expanded=true"
                },
                modifier = Modifier.weight(1f),
                fontSize = AppFont.sizeSm,
                height = 40.dp
            )
            AppButton(
                text = "外部收起",
                onClick = {
                    d4Expanded = false
                    d4CallbackInfo = "外部按钮设置 expanded=false"
                },
                modifier = Modifier.weight(1f),
                fontSize = AppFont.sizeSm,
                height = 40.dp
            )
        }
        Hint("排查点：外部按钮点击后文本展开/收起；onExpandChange 回调触发反馈条更新；组件不自持 state 完全由外部 d4Expanded 驱动。")
    }
}
