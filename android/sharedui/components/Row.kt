package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp

/**
 * Row 行布局：简单弹性分栏容器（Row + Col，span 比例分栏）。
 *
 * 组件 ID：`ui.row`。与 Layout（12 栅格 span/12 固定）划界：
 * Row 用任意整数 span 比例分配（如 1:2:1 = 总 span 4），不绑定 12 栅格。
 *
 * @param justify 水平分布
 * @param align 垂直对齐
 * @param gutter 子项间距
 * @param modifier 行容器修饰符
 * @param content 行内容（须用 [Col] 分栏）
 */
@Composable
fun Row(
    justify: RowJustify = RowJustify.Start,
    align: RowAlign = RowAlign.Top,
    gutter: Dp = 0.dp,
    modifier: Modifier = Modifier,
    content: @Composable androidx.compose.foundation.layout.RowScope.() -> Unit
) {
    val hArrangement: Arrangement.Horizontal = when (justify) {
        RowJustify.Start -> if (gutter > 0.dp) Arrangement.spacedBy(gutter) else Arrangement.Start
        RowJustify.Center -> Arrangement.Center
        RowJustify.End -> Arrangement.End
        RowJustify.SpaceBetween -> Arrangement.SpaceBetween
        RowJustify.SpaceAround -> Arrangement.SpaceAround
    }
    val vAlignment: Alignment.Vertical = when (align) {
        RowAlign.Top -> Alignment.Top
        RowAlign.Center -> Alignment.CenterVertically
        RowAlign.Bottom -> Alignment.Bottom
        RowAlign.Stretch -> Alignment.Top
    }
    androidx.compose.foundation.layout.Row(
        modifier = modifier.fillMaxWidth(),
        horizontalArrangement = hArrangement,
        verticalAlignment = vAlignment,
    ) { content() }
}

/** 水平分布。 */
enum class RowJustify { Start, Center, End, SpaceBetween, SpaceAround }

/** 垂直对齐。 */
enum class RowAlign { Top, Center, Bottom, Stretch }

/**
 * 分栏子项：占行宽 span/totalSpan 比例。
 * 必须在 Row 内使用（依赖 RowScope.weight）。
 *
 * @param span 宽度比例（>= 1）
 * @param modifier 列修饰符
 * @param content 列内容
 */
@Composable
fun androidx.compose.foundation.layout.RowScope.Col(
    span: Int,
    modifier: Modifier = Modifier,
    content: @Composable () -> Unit
) {
    require(span >= 1) { "span 必须 >= 1，当前 $span" }
    // weight 实现比例分配：Col 的 weight = span（Compose weight 自动归一化）
    Box(modifier = modifier.weight(span.toFloat())) {
        content()
    }
}
