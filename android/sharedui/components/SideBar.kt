package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppFont
import com.zhiqihuayun.foundation.design.AppSpace

/**
 * 侧边导航目录项数据（与 iOS `SideBarItem` 同构）。
 *
 * @param title 标题（单行省略）
 * @param value 稳定标识（映射右内容/滚动段）
 * @param disabled 是否禁用（默认 false；禁用项不可点、文字透明度 40%）
 */
data class SideBarItem(
    val title: String,
    val value: String,
    val disabled: Boolean = false,
)

/**
 * SideBar 侧边导航：页面内容区左侧的竖排目录导航轨（垂直单选导航）。
 *
 * 组件 ID：`ui.side-bar`（api.json 契约对齐，门禁 A AI 代评通过 2026-09-05，
 * 用户"除特色组件外所有组件评审文档全部生成，中间任何询问直接通过"总授权；
 * P1–P4 全 A：纯导航轨 + 数据驱动 + 半受控选中 + 一期无内置右内容联动）。
 *
 * 一期语义（对标 NutUI React SideBar 收敛为库内自有设计语言）：
 * - [items]：SideBarItem 列表（title 单行省略 / value 稳定标识 / disabled 禁用不可点）
 * - [selectedValue]：外部驱动选中（半受控）；null=默认首启用项激活自管理
 * - [onChange]：点选回调 (value)；点击已激活项不重复回调（幂等）
 * - 轨内可滚动：LazyColumn（懒加载复用），项数超出可视区纵向滚动；选中项自动滚入可视
 * - 激活视觉：选中项=白底胶囊 + 主色加粗（同导航项激活先例，浮于灰轨之上）
 * - 组件=纯导航轨；宽/高由 [modifier] 定（宿主传 96.dp 缺省样轨宽）；右内容联动宿主自理
 *   （与 Elevator 划界：本组件不监听滚动/不做锚点跟随）
 *
 * 用法：
 * ```kotlin
 * SideBar(
 *     items = listOf(
 *         SideBarItem("全部", "all"),
 *         SideBarItem("餐饮", "dining"),
 *     ),
 *     modifier = Modifier
 *         .width(96.dp)
 *         .height(300.dp),
 *     onChange = { value ->
 *         // 宿主切换右侧内容
 *     }
 * )
 * ```
 *
 * @param items 目录项数据
 * @param modifier 布局修饰符（含轨宽/轨高约束）
 * @param selectedValue 外部驱动选中值（null=内部自管理）
 * @param onChange 点选回调（点击已激活项不触发）
 */
@Composable
fun SideBar(
    items: List<SideBarItem>,
    modifier: Modifier = Modifier,
    selectedValue: String? = null,
    onChange: (String) -> Unit,
) {
    val listState = rememberLazyListState()
    val defaultFirst = remember(items) { items.firstOrNull { !it.disabled }?.value }
    // 非受控模式下内部当前选中（首启用项兜底；items 变化时重置）
    var internalValue by remember(items) { mutableStateOf(defaultFirst) }
    // 有效选中 = 外部受控优先，其次内部自管理
    val currentValue = selectedValue ?: internalValue

    Box(modifier = modifier.background(AppColor.gray4)) {
        LazyColumn(
            state = listState,
            modifier = Modifier.fillMaxSize()
        ) {
            itemsIndexed(
                items = items,
                key = { _, item -> item.value }
            ) { _, item ->
                val isSelected = !item.disabled && item.value == currentValue
                SideBarRow(
                    item = item,
                    selected = isSelected,
                    onClick = {
                        if (!item.disabled && item.value != currentValue) {
                            if (selectedValue == null) internalValue = item.value
                            onChange(item.value)
                        }
                    }
                )
            }
        }
    }
    // 选中项自动滚入可视（受控/内部变化均同步；与 iOS scrollRectToVisible 同构）
    LaunchedEffect(currentValue) {
        val index = items.indexOfFirst { it.value == currentValue }
        if (index >= 0) {
            listState.animateScrollToItem(index)
        }
    }
}

/** 目录行：高 48dp；激活=白底胶囊(圆角 full) + 主色加粗；禁用=文字透明度 40% 不可点。 */
@Composable
private fun SideBarRow(item: SideBarItem, selected: Boolean, onClick: () -> Unit) {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .height(48.dp)
            // 整行可点；系统 ripple 点击反馈（表内放行，同 Grid/列表先例）；禁用行不响应
            .clickable(enabled = !item.disabled, onClick = onClick),
        contentAlignment = Alignment.Center
    ) {
        Box(
            modifier = Modifier
                .fillMaxSize()
                // 胶囊行内左右 margin xs → 胶囊宽=轨宽−8；高=48−上下 xs=40，圆角 full
                .padding(horizontal = AppSpace.xs, vertical = AppSpace.xs)
                .clip(RoundedCornerShape(20))
                .background(if (selected) AppColor.bgCard else Color.Transparent),
            contentAlignment = Alignment.Center
        ) {
            val textColor = when {
                item.disabled -> AppColor.textSecondary.copy(alpha = 0.4f)
                selected -> AppColor.primary
                else -> AppColor.textSecondary
            }
            Text(
                text = item.title,
                fontSize = AppFont.sizeSm,
                fontWeight = if (selected) FontWeight.Bold else FontWeight.Normal,
                color = textColor,
                textAlign = TextAlign.Center,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )
        }
    }
}
