// Pagination 分页组件（Compose 版，对齐 iOS PaginationView）。
//
// 受控页码驱动的分页器——当数据总量较大需分页浏览时提供上一页/下一页 + 页码按钮翻页，
// 或简洁模式（x/y 文本）翻页，页码超量时自动省略号折叠。
// currentValue 驱动当前页（>0=受控，0=内部自管理初始 defaultValue），total + pageSize
// 计算总页数，itemSize 控制可见页码按钮数（超出自动省略号折叠），mode 切换 multi/simple。
//
// 决策（与设计规格 pagination-design-spec.html 一致）：
// - P1-C 混合受控：currentValue > 0=受控，0=内部 remember 自管理
// - P2-A 标准滑动窗口省略号：当前页居中 window + 首尾固定 + 省略号折叠
// - P3-A 支持简洁模式 simple（x/y 文本）
// - P4-A 一期=基础翻页/简洁/省略号/自定义按钮数+demo 四段

package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.KeyboardArrowLeft
import androidx.compose.material.icons.automirrored.filled.KeyboardArrowRight
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppFont
import com.zhiqihuayun.foundation.design.AppRadius
import com.zhiqihuayun.foundation.design.AppSpace

/**
 * 分页模式。
 */
enum class PaginationMode {
    /** 按钮模式：上一页/下一页 + 页码按钮（含省略号）。 */
    MULTI,

    /** 简洁模式：上一页/下一页 + x/y 文本。 */
    SIMPLE
}

/**
 * 分页按钮项（页码或省略号）。
 */
sealed class PaginationButton {
    data class Page(val page: Int) : PaginationButton()
    object Ellipsis : PaginationButton()
}

/**
 * 分页器：受控页码驱动的分页组件。
 *
 * @param currentValue 当前页（1-based）；0=内部自管理状态（初始取 defaultValue），>0=受控
 * @param defaultValue 默认当前页（非受控初始值）
 * @param total 数据总条数
 * @param pageSize 每页条数
 * @param itemSize 可见页码按钮数（超出自动省略号折叠）
 * @param mode 分页模式：multi 按钮模式 / simple 简洁模式（x/y 文本）
 * @param prevText 自定义上一页按钮文案（null=默认 chevron 箭头）
 * @param nextText 自定义下一页按钮文案（null=默认 chevron 箭头）
 * @param onChange 翻页回调，返回目标页码
 * @param modifier 外部修饰
 */
@Composable
fun Pagination(
    currentValue: Int = 0,
    defaultValue: Int = 1,
    total: Int = 0,
    pageSize: Int = 10,
    itemSize: Int = 5,
    mode: PaginationMode = PaginationMode.MULTI,
    prevText: String? = null,
    nextText: String? = null,
    onChange: ((Int) -> Unit)? = null,
    modifier: Modifier = Modifier,
) {
    // P1-C 混合受控：currentValue>0=受控（直接用），0=内部 remember 自管理（初始 defaultValue）。
    var internalPage by remember { mutableStateOf(defaultValue.coerceAtLeast(1)) }
    val effectivePage: Int = if (currentValue > 0) currentValue else internalPage

    // 总页数（向上取整）。
    val totalPages = if (total > 0 && pageSize > 0) {
        (total + pageSize - 1) / pageSize
    } else {
        0
    }
    if (totalPages <= 0) return

    // 当前页 clamp 到 [1, totalPages]。
    val page = effectivePage.coerceIn(1, totalPages)

    // 翻页：更新内部态（非受控时）、回调。
    fun goTo(target: Int) {
        val next = target.coerceIn(1, totalPages)
        if (currentValue == 0) {
            internalPage = next
        }
        onChange?.invoke(next)
    }

    // 安卓禁令：圆角裁切用 background(shape=圆角矩形)，不用 Modifier.clip()/graphicsLayer()。
    Row(
        modifier = modifier
            .background(AppColor.bgCard, RoundedCornerShape(AppRadius.lg))
            .padding(horizontal = AppSpace.sm, vertical = AppSpace.sm),
        horizontalArrangement = Arrangement.spacedBy(AppSpace.xs),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        // 上一页：page<=1 时禁用。
        NavButton(
            isPrev = true,
            disabled = page <= 1,
            prevText = prevText,
            onClick = { goTo(page - 1) },
        )
        when (mode) {
            PaginationMode.MULTI -> {
                // 页码按钮 + 省略号折叠。
                val buttons = computeButtons(current = page, total = totalPages, itemSize = itemSize)
                buttons.forEach { button ->
                    when (button) {
                        is PaginationButton.Page -> PageButton(
                            page = button.page,
                            selected = button.page == page,
                            onClick = { goTo(button.page) },
                        )
                        is PaginationButton.Ellipsis -> EllipsisView()
                    }
                }
            }
            PaginationMode.SIMPLE -> {
                // 简洁模式：x/y 文本（当前页 primary 高亮）。
                SimpleLabel(current = page, total = totalPages)
            }
        }
        // 下一页：page>=totalPages 时禁用。
        NavButton(
            isPrev = false,
            disabled = page >= totalPages,
            nextText = nextText,
            onClick = { goTo(page + 1) },
        )
    }
}

/**
 * 上一页/下一页按钮：chevron 箭头或自定义文本。
 */
@Composable
private fun NavButton(
    isPrev: Boolean,
    disabled: Boolean,
    prevText: String? = null,
    nextText: String? = null,
    onClick: () -> Unit,
) {
    val text = if (isPrev) prevText else nextText
    val tag = if (isPrev) "pagination-prev" else "pagination-next"
    val size = AppSpace.lg
    Box(
        modifier = Modifier
            .size(size)
            .then(if (disabled) Modifier else Modifier.clickable { onClick() })
            .testTag(tag),
        contentAlignment = Alignment.Center,
    ) {
        if (text != null) {
            // 自定义文本按钮。
            Text(
                text = text,
                color = if (disabled) AppColor.gray25 else AppColor.textSecondary,
                fontSize = AppFont.sizeSm,
                textAlign = TextAlign.Center,
            )
        } else {
            // 默认 chevron 箭头。
            val arrow = if (isPrev) Icons.AutoMirrored.Filled.KeyboardArrowLeft
            else Icons.AutoMirrored.Filled.KeyboardArrowRight
            Icon(
                imageVector = arrow,
                contentDescription = if (isPrev) "上一页" else "下一页",
                tint = if (disabled) AppColor.gray25 else AppColor.textSecondary,
                modifier = Modifier.size(AppSpace.lg),
            )
        }
    }
}

/**
 * 页码按钮：selected 反白（primary 底白字），非 selected 透明底。
 */
@Composable
private fun PageButton(page: Int, selected: Boolean, onClick: () -> Unit) {
    Box(
        modifier = Modifier
            .size(AppSpace.lg)
            .then(
                if (selected) Modifier.background(AppColor.primary, RoundedCornerShape(AppRadius.sm))
                else Modifier.clickable { onClick() }
            )
            .testTag("pagination-page-$page"),
        contentAlignment = Alignment.Center,
    ) {
        Text(
            text = "$page",
            color = if (selected) Color.White else AppColor.textPrimary,
            fontSize = AppFont.sizeSm,
            fontWeight = if (selected) FontWeight.SemiBold else FontWeight.Normal,
            textAlign = TextAlign.Center,
        )
    }
}

/**
 * 省略号占位：gray25，不可点。
 */
@Composable
private fun EllipsisView() {
    Box(
        modifier = Modifier
            .size(AppSpace.lg)
            .testTag("pagination-ellipsis"),
        contentAlignment = Alignment.Center,
    ) {
        Text(
            text = "···",
            color = AppColor.gray25,
            fontSize = AppFont.sizeSm,
            textAlign = TextAlign.Center,
        )
    }
}

/**
 * 简洁模式文本：当前页 primary 高亮 + " / " + 总页数 textPrimary。
 */
@Composable
private fun SimpleLabel(current: Int, total: Int) {
    Box(
        modifier = Modifier
            .width(60.dp)
            .height(AppSpace.lg)
            .testTag("pagination-simple"),
        contentAlignment = Alignment.Center,
    ) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Text(
                text = "$current",
                color = AppColor.primary,
                fontSize = AppFont.sizeSm,
                fontWeight = FontWeight.SemiBold,
            )
            Text(
                text = " / $total",
                color = AppColor.textPrimary,
                fontSize = AppFont.sizeSm,
            )
        }
    }
}

/**
 * 计算页码按钮序列：总页数 ≤ itemSize 全量；否则当前页居中 window + 首尾固定 + 省略号。
 *
 * @param current 当前页（1-based，已 clamp）
 * @param total 总页数
 * @param itemSize 可见页码按钮数
 * @return 按钮序列（页码 or 省略号）
 */
fun computeButtons(current: Int, total: Int, itemSize: Int): List<PaginationButton> {
    if (total <= 0) return emptyList()
    // 总页数不超过 itemSize → 全量渲染。
    if (total <= itemSize) {
        return (1..total).map { PaginationButton.Page(it) }
    }
    // 当前页居中 window：left = current - (itemSize-1)/2，right = left + itemSize - 1。
    val half = (itemSize - 1) / 2
    var left = current - half
    var right = left + itemSize - 1
    // 边界 clamp：window 不越过 [1, total]。
    if (left < 1) {
        left = 1
        right = itemSize
    }
    if (right > total) {
        right = total
        left = total - itemSize + 1
    }

    val result = mutableListOf<PaginationButton>()
    // 左侧：left>1 显首页，left>2 加省略号。
    if (left > 1) {
        result.add(PaginationButton.Page(1))
        if (left > 2) {
            result.add(PaginationButton.Ellipsis)
        }
    }
    // window。
    for (i in left..right) {
        result.add(PaginationButton.Page(i))
    }
    // 右侧：right<total 显末页，right<total-1 加省略号。
    if (right < total) {
        if (right < total - 1) {
            result.add(PaginationButton.Ellipsis)
        }
        result.add(PaginationButton.Page(total))
    }
    return result
}
