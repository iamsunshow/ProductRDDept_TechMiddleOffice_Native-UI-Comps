package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.safeDrawing
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.platform.LocalLayoutDirection
import androidx.compose.ui.unit.dp

/**
 * 避让边（P2 全 A：四边可配）。
 */
enum class SafeAreaEdges {
    Top,
    Bottom,
    Left,
    Right
}

/** 默认全边集合（SafeArea 未显式传 edges 时的避让范围）。 */
val SafeAreaAllEdges: Set<SafeAreaEdges> = SafeAreaEdges.values().toSet()

/**
 * SafeArea 安全区避让容器：把内容限制在系统安全区（刘海/状态栏/圆角/手势区/Home Indicator）之内。
 *
 * 组件 ID：`ui.safe-area`（api.json 契约对齐，门禁 A AI 代评通过 2026-09-04，
 * 用户"中间任何询问直接通过"总授权；P1–P4 全 A：容器式 + edges 四边可配默认全边 +
 * Android WindowInsets.safeDrawing 实时值零硬编码）。
 *
 * 一期语义：
 * - 内容自动贴安全区排布（避让数值取系统实时 insets，机型自适应）
 * - [edges] 决定避让哪些边（默认四边全避）；未避让的边内容直接铺满
 * - 容器 pass-through：透明零绘制零背景，装饰由内容承担
 *
 * 用法：
 * ```kotlin
 * SafeArea(edges = setOf(SafeAreaEdges.Top, SafeAreaEdges.Bottom)) { 页面内容 }
 * ```
 *
 * @param edges 避让边集合（默认 [SafeAreaAllEdges]）
 * @param modifier 容器布局修饰符
 * @param content 需要避让的内容
 */
@Composable
fun SafeArea(
    edges: Set<SafeAreaEdges> = SafeAreaAllEdges,
    modifier: Modifier = Modifier,
    content: @Composable () -> Unit
) {
    val insets = WindowInsets.safeDrawing
    val density = LocalDensity.current
    val layoutDirection = LocalLayoutDirection.current
    val padding = PaddingValues(
        start = if (SafeAreaEdges.Left in edges) insets.getLeft(density, layoutDirection).dp else 0.dp,
        top = if (SafeAreaEdges.Top in edges) insets.getTop(density).dp else 0.dp,
        end = if (SafeAreaEdges.Right in edges) insets.getRight(density, layoutDirection).dp else 0.dp,
        bottom = if (SafeAreaEdges.Bottom in edges) insets.getBottom(density).dp else 0.dp
    )
    Box(modifier = modifier.padding(padding)) {
        content()
    }
}
