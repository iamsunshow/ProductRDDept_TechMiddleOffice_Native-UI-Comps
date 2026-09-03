package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
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
 * 导航入口网格数据项。
 *
 * @param title 入口标题
 * @param icon 入口图标（双端统一 AppIconName，iOS 映射 SF Symbol）
 */
data class GridItem(
    val title: String,
    val icon: AppIconName
)

/**
 * 通用导航入口网格卡片（对标 iOS NavigationGrid）。
 *
 * 卡片壳 + 分区标题 + 等分图标入口网格，双端 1:1 对齐。
 *
 * @param title 分区标题
 * @param items 入口列表（建议 4 个）
 * @param onSelect 点击回调（返回索引）
 * @param modifier 布局修饰符
 */
@Composable
fun NavigationGrid(
    title: String,
    items: List<GridItem>,
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
        Text(
            text = title,
            color = AppColor.textPrimary,
            fontSize = AppFont.sizeMd,
            fontWeight = FontWeight.SemiBold
        )
        Spacer(modifier = Modifier.height(AppSpace.md))
        Row(
            modifier = Modifier.fillMaxWidth().height(72.dp),
            horizontalArrangement = Arrangement.SpaceEvenly
        ) {
            items.forEachIndexed { index, item ->
                Column(
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.spacedBy(AppSpace.xs),
                    modifier = Modifier
                        .weight(1f)
                        .clickable(enabled = onSelect != null) { onSelect?.invoke(index) }
                ) {
                    AppIcon(
                        name = item.icon,
                        size = 26.dp,
                        tint = AppColor.primary
                    )
                    Text(
                        text = item.title,
                        color = AppColor.textPrimary,
                        fontSize = AppFont.sizeXs,
                        textAlign = TextAlign.Center,
                        maxLines = 2
                    )
                }
            }
        }
    }
}
