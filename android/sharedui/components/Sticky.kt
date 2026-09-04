package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.lazy.LazyItemScope
import androidx.compose.foundation.lazy.LazyListScope
import androidx.compose.runtime.Composable

/**
 * Sticky 粘性布局（吸顶行）：把 LazyColumn 分组内容中的组标题/筛选条等"标题类行"登记为吸顶块，
 * 滚动到顶后钉在列表顶部、被下一组标题顶替，回滚恢复随流排布。
 *
 * 组件 ID：`ui.sticky`（api.json 契约对齐，门禁 A AI 代评通过 2026-09-04，
 * 用户"中间任何询问直接通过"总授权；P1–P4 全 A：单吸顶行封装 + 列表/通用滚动双路径 +
 * Android 走 LazyColumn 原生 stickyHeader + offset 以容器排布表达）。
 *
 * 与 iOS StickyView 的对应关系（平台差异表内放行）：
 * - iOS：自包含滚动容器 + contentOffset 监听 + pinned 平移（offset 显式传参）
 * - Android：LazyColumn 原生 stickyHeader 封装（offset 通过"吸顶条上方留位"表达：
 *   顶部固定 AppBar 场景把 LazyColumn 放 AppBar 之下，吸顶即停 AppBar 下沿）
 *
 * 一期语义：
 * - 吸顶行内容任意（组标题/筛选条/可交互行），视觉由内容自带（行为容器零视觉零 token）
 * - 吸顶态视觉不变式一期（无阴影/底色变化等状态样式）
 * - 反目标：不做多级多段 sticky 相互替换之外的吸底/吸顶态样式/悬浮操作类
 *
 * 用法（LazyColumn 内）：
 * ```kotlin
 * LazyColumn {
 *     // 分组标题（吸顶，滚动中被下一分组标题顶替）
 *     stickyHeaderItem(key = "today") { BillGroupTitle("今天") }
 *     items(bills) { BillRow(it) }
 *     stickyHeaderItem(key = "yesterday") { BillGroupTitle("昨天") }
 *     items(bills) { BillRow(it) }
 * }
 * ```
 *
 * @param key 可选稳定 key（缺省自动生成；多分组顶替时建议传分组标识）
 * @param content 吸顶行内容（LazyItemScope）
 */
@OptIn(ExperimentalFoundationApi::class)
fun LazyListScope.stickyHeaderItem(
    key: Any? = null,
    content: @Composable LazyItemScope.() -> Unit
) {
    stickyHeader(key = key, contentType = "sticky-header", content = content)
}
