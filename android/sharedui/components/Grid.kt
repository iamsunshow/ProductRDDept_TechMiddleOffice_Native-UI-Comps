package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
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

/**
 * 宫格入口数据项。
 *
 * @param title 入口标题
 * @param icon 入口图标（双端统一 AppIconName，iOS 映射 SF Symbol）
 */
data class GridItem(
    val title: String,
    val icon: AppIconName
)

/**
 * 宫格 Grid：多格图标入口矩阵（卡片壳 + 可选分区标题 + 等分图标网格）。
 *
 * 组件 ID：`ui.grid`（api.json 契约对齐，门禁 A 评审通过 2026-09-04）。
 * 命名：Grid（非 NavigationGrid），与 api.json id 一致。
 *
 * 支持：
 * - [column] 列数（默认 4，支持 3/4/5）
 * - [title] 可选（空字符串时不显示标题区域）
 * - 超过 column 数量自动换行
 * - [onSelect] 点击回调（返回索引）
 *
 * @param title 分区标题（空字符串=不显示标题区域）
 * @param items 入口列表
 * @param column 列数（默认 4）
 * @param onSelect 点击回调（返回点击项的索引）
 * @param modifier 布局修饰符
 */
@Composable
fun Grid(
    title: String,
    items: List<GridItem>,
    column: Int = 4,
    onSelect: ((Int) -> Unit)? = null,
    modifier: Modifier = Modifier
) {
    Column(
        modifier = modifier
            .fillMaxWidth()
            .background(AppColor.bgCard, RoundedCornerShape(AppRadius.lg))
            .border(0.5.dp, AppColor.border, RoundedCornerShape(AppRadius.lg))
            .padding(AppSpace.lg)
    ) {
        // 分区标题（空字符串时不显示）
        if (title.isNotEmpty()) {
            Text(
                text = title,
                color = AppColor.textPrimary,
                fontSize = AppFont.sizeMd,
                fontWeight = FontWeight.SemiBold
            )
            Spacer(modifier = Modifier.height(AppSpace.md))
        }

        // 按 column 分行渲染
        val rows = items.chunked(column)
        rows.forEach { rowItems ->
            Row(
                modifier = Modifier.fillMaxWidth().height(72.dp),
                horizontalArrangement = Arrangement.SpaceEvenly
            ) {
                rowItems.forEachIndexed { indexInRow, item ->
                    val globalIndex = rows.take(rows.indexOf(rowItems)).sumOf { it.size } + indexInRow
                    Column(
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.Center,
                        modifier = Modifier
                            .weight(1f)
                            .fillMaxHeight()
                            .clickable(enabled = onSelect != null) { onSelect?.invoke(globalIndex) }
                    ) {
                        // 图标容器（绿色背景 + 白色图标，与设计规格一致）
                        Box(
                            modifier = Modifier
                                .size(26.dp)
                                .background(AppColor.primary, RoundedCornerShape(6.dp)),
                            contentAlignment = Alignment.Center
                        ) {
                            AppIcon(
                                name = item.icon,
                                size = 16.dp,
                                tint = androidx.compose.ui.graphics.Color.White
                            )
                        }
                        Spacer(modifier = Modifier.height(AppSpace.xs))
                        Text(
                            text = item.title,
                            color = AppColor.textPrimary,
                            fontSize = AppFont.sizeXs,
                            textAlign = TextAlign.Center,
                            maxLines = 2
                        )
                    }
                }
                // 不足 column 列时用空 Spacer 填充（保持等分对齐）
                repeat(column - rowItems.size) {
                    Spacer(modifier = Modifier.weight(1f))
                }
            }
            // 行间间距
            if (rowItems != rows.last()) {
                Spacer(modifier = Modifier.height(AppSpace.sm))
            }
        }
    }
}
