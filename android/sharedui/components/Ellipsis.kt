// Ellipsis 文本省略组件（Compose 版，对齐 iOS EllipsisView）。
//
// 文本超出指定行数时自动截断显示省略号，支持点击展开/收起。
// 纯展示型文本截断组件，content+rows 自动尾部截断，
// expandText/collapseText 控制展开收起文案，
// expanded 半受控（null=内部自持/非 null=外部驱动），onExpandChange 回调。
//
// 截断规则（与设计规格 ellipsis-design-spec.html 一致）：
// - 收起态：Text maxLines=rows + overflow=TextOverflow.Ellipsis 尾部截断
// - 展开态：Text maxLines=Int.MAX_VALUE 不截断显示全文
// - expanded=null：内部 remember mutableStateOf 自持，点击自动切换
// - expanded!=null：受控模式，state 由外部驱动，内部不自持

package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppFont
import com.zhiqihuayun.foundation.design.AppRadius
import com.zhiqihuayun.foundation.design.AppSpace

/**
 * 省略方向（一期仅 tail，middle/head = 二期 anti_goal）。
 */
enum class EllipsisDirection {
    TAIL
}

/**
 * 文本省略组件：文本超出指定行数时自动截断显示省略号，支持点击展开/收起。
 *
 * @param content 要显示的文本内容
 * @param rows 最大显示行数，超出时截断显示省略号，默认 1
 * @param direction 省略方向，默认 TAIL（一期仅支持尾部）
 * @param expandText 展开按钮文案，默认「展开」
 * @param collapseText 收起按钮文案，默认「收起」
 * @param expanded 半受控展开态：null=内部自持点击切换，非 null=外部驱动受控
 * @param onExpandChange 展开态变化回调（expanded 新值）
 */
@Composable
fun Ellipsis(
    content: String,
    rows: Int = 1,
    direction: EllipsisDirection = EllipsisDirection.TAIL,
    expandText: String = "展开",
    collapseText: String = "收起",
    expanded: Boolean? = null,
    onExpandChange: ((Boolean) -> Unit)? = null,
) {
    // 半受控：expanded=null 时内部自持 state；非 null 时外部驱动。
    var internalExpanded by remember { mutableStateOf(false) }
    val isExpanded = expanded ?: internalExpanded

    fun toggle() {
        val newValue = !isExpanded
        if (expanded == null) {
            internalExpanded = newValue
        }
        onExpandChange?.invoke(newValue)
    }

    Column(
        modifier = Modifier
            .fillMaxWidth()
            .clickable { toggle() },
        verticalArrangement = Arrangement.spacedBy(AppSpace.xs)
    ) {
        Text(
            text = content,
            color = AppColor.textPrimary,
            fontSize = AppFont.sizeMd,
            fontWeight = FontWeight.Normal,
            overflow = TextOverflow.Ellipsis,
            maxLines = if (isExpanded) Int.MAX_VALUE else rows,
        )
        // 展开/收起按钮
        Text(
            text = if (isExpanded) collapseText else expandText,
            color = AppColor.primary,
            fontSize = AppFont.sizeSm,
            fontWeight = FontWeight.Medium,
        )
    }
}
