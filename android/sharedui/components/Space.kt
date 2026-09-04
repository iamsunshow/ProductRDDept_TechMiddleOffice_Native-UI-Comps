package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.Dp
import com.zhiqihuayun.foundation.design.AppSpace

/**
 * 排布方向（P1 用户全 A：单组件 + direction 双向）。
 */
enum class SpaceDirection {
    Horizontal,
    Vertical
}

/**
 * Space 间距：纯间距容器——一组任意子内容按统一档位间距排布（水平/垂直）。
 *
 * 组件 ID：`ui.space`（api.json 契约对齐，门禁 A 评审通过 2026-09-04，
 * 用户 P1–P4 全票 A：方向双向 + AppSpace 五档 + 默认 sm=8 + 一期无 wrap/split）。
 * 命名：Space（双端同名；Compose 无同名内置，避开 Spacer）。
 *
 * 一期语义：
 * - 子项按 [direction] 排布：horizontal=一行从左到右；vertical=一列从上到下
 * - 相邻子项间距 = [size]（档位 token 值）；间距仅在子项之间（首尾无 padding）
 * - 子项对齐：横向顶部对齐、纵向起始侧对齐；不拉伸子项
 * - 容器 pass-through：透明零绘制零自有文本，装饰由子项内容承担
 *
 * 用法：
 * ```kotlin
 * Space(direction = SpaceDirection.Horizontal, size = AppSpace.sm) {
 *     toolItem("记一笔"); toolItem("扫一扫")
 * }
 * ```
 *
 * @param direction 排布方向（默认 [SpaceDirection.Horizontal]）
 * @param size 相邻子项间距（默认 AppSpace.sm=8，P3 用户全 A）
 * @param modifier 容器布局修饰符
 * @param content 子项任意内容
 */
@Composable
fun Space(
    direction: SpaceDirection = SpaceDirection.Horizontal,
    size: Dp = AppSpace.sm,
    modifier: Modifier = Modifier,
    content: @Composable () -> Unit
) {
    when (direction) {
        SpaceDirection.Horizontal -> Row(
            modifier = modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(size),
            verticalAlignment = Alignment.Top,
            content = { content() }
        )
        SpaceDirection.Vertical -> Column(
            modifier = modifier.fillMaxWidth(),
            verticalArrangement = Arrangement.spacedBy(size),
            horizontalAlignment = Alignment.Start,
            content = { content() }
        )
    }
}
