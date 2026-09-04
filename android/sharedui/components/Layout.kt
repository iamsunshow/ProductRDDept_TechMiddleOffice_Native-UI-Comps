package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.RowScope
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.Dp
import com.zhiqihuayun.foundation.design.AppSpace

/**
 * Layout 布局：横向弹性分栏容器（Row/Col，12 栅格 span 1~12）。
 *
 * 组件 ID：`ui.layout`（api.json 契约对齐，门禁 A 评审通过 2026-09-04，
 * 用户 P1–P4 全票 A：Row/Col 双组件 + 12 栅格 + gutter 默认 AppSpace.md + 一期单行）。
 * 命名：LayoutRow/LayoutCol（防与 androidx Row 冲突；双端同名同 API）。
 *
 * 一期语义：
 * - 子项按 `span/12` 比例占行宽（span 和不足 12 时右侧留空，不强制满行）
 * - 子项内容顶部对齐；行高 = 子项内容自然最大高度
 * - 等高拉伸 / center/end 对齐二期引入（双端契约同步）
 *
 * 用法：
 * ```kotlin
 * LayoutRow {
 *     LayoutCol(span = 6) { /* 卡片一 */ }
 *     LayoutCol(span = 6) { /* 卡片二 */ }
 * }
 * ```
 *
 * @param gutter 子项水平间距（默认 AppSpace.md=12，P3 用户 2026-09-04 表决 A）
 * @param modifier 行容器布局修饰符
 * @param content 行内容（须用 [LayoutCol] 分栏）
 */
@Composable
fun LayoutRow(
    gutter: Dp = AppSpace.md,
    modifier: Modifier = Modifier,
    content: @Composable RowScope.() -> Unit
) {
    Row(
        modifier = modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.spacedBy(gutter),
        verticalAlignment = Alignment.Top,
        content = content
    )
}

/**
 * 分栏子项：占行宽 `span/12`（须在 [LayoutRow] 作用域内调用）。
 *
 * @param span 栅格宽度（1~12，12 栅格）
 * @param modifier 子项布局修饰符
 * @param content 子项内容（自然高，Box 内默认顶部开始布局）
 */
@Composable
fun RowScope.LayoutCol(
    span: Int,
    modifier: Modifier = Modifier,
    content: @Composable () -> Unit
) {
    require(span in 1..12) { "span 必须在 1~12（12 栅格），当前 $span" }
    Box(modifier = modifier.weight(span / 12f)) { content() }
}
