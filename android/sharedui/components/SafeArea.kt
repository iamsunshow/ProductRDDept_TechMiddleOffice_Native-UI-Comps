package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.WindowInsetsSides
import androidx.compose.foundation.layout.only
import androidx.compose.foundation.layout.safeDrawing
import androidx.compose.foundation.layout.windowInsetsPadding
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier

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
 * Android 实现要点（v1.0.3，修复 consume 不生效 + 修正错误 modifier）：
 * - v1.0.0/v1.0.1 在组合期 `WindowInsets.safeDrawing.getTop(density)` 直接读窗口全局值转 dp
 *   再套普通 padding——该读法不经过 insets 传播链，父级 `consumeWindowInsets` 一律拦不住，
 *   页面中部容器也会叠加上下系统区避让（实机 41/24dp），与 iOS 位置级 safeAreaLayoutGuide
 *   （容器已在安全区内时自动=0）语义不一致；
 * - v1.0.2 错用 `windowInsetsTopHeight/BottomHeight/StartWidth/EndWidth`——该系列语义是把
 *   inset 值设为元素尺寸（等价 `Modifier.height(inset)`，专配 Spacer 占位用），不是加 padding，
 *   四边叠加互相抢高宽，SafeArea 容器被压成一条（实机只剩小灰条），内容被挤出/压扁；
 * - v1.0.3 改用 `windowInsetsPadding(insets.only(side))`：真正按边加 padding + 读传播链剩余值
 *   （感知祖先 `consumeWindowInsets`：页面中部容器消费窗口 insets 后=0，与 iOS 对齐），
 *   且随窗口 insets 实时更新；应用后自动消费该边 inset，内部子树不重复避让。
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
    Box(
        modifier = modifier.safeAreaInsetsPadding(insets, edges)
    ) {
        content()
    }
}

/**
 * 按 [edges] 逐边应用 [windowInsetsPadding]。
 *
 * 不用 `windowInsetsTopHeight/StartWidth…`（语义=元素尺寸非 padding）；必须逐边 `only(sides)`
 * 裁剪后再套 padding，未避让的边不加 padding（内容贴容器边，与 iOS edges 语义 1:1）。
 */
private fun Modifier.safeAreaInsetsPadding(insets: WindowInsets, edges: Set<SafeAreaEdges>): Modifier {
    var m = this
    if (SafeAreaEdges.Top in edges) m = m.windowInsetsPadding(insets.only(WindowInsetsSides.Top))
    if (SafeAreaEdges.Bottom in edges) m = m.windowInsetsPadding(insets.only(WindowInsetsSides.Bottom))
    if (SafeAreaEdges.Left in edges) m = m.windowInsetsPadding(insets.only(WindowInsetsSides.Left))
    if (SafeAreaEdges.Right in edges) m = m.windowInsetsPadding(insets.only(WindowInsetsSides.Right))
    return m
}
