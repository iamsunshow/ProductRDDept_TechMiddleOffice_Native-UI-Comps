// Collapse 折叠面板组件（Compose 版，对齐 iOS CollapseView）。
//
// 可折叠/展开的内容区域——点击标题展开或收起内容，用于将较长内容分组收纳、节省页面纵向空间。
// 数据驱动 items 数组（每项 title+content+key+disabled），activeKeys 控制展开项 key 列表
// （null=内部自管理，非 null=受控），accordion 开手风琴互斥（只展一项），右侧 chevron 箭头展开时旋转。
//
// 决策（与设计规格 collapse-design-spec.html 一致）：
// - P1-C 混合受控：activeKeys 非空=受控，null=内部 remember 自管理
// - P2-A 一期无动画：瞬切显隐（高度动画=二期）
// - P3-A 默认右侧 chevron 旋转：收起=右指(0°)，展开=下指(rotate 90°)
// - P4-A 一期=基础折叠/手风琴/禁用/受控+demo 四段

package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
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
import androidx.compose.ui.draw.rotate
import androidx.compose.ui.graphics.ColorFilter
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppFont
import com.zhiqihuayun.foundation.design.AppRadius
import com.zhiqihuayun.foundation.design.AppSpace

/**
 * 折叠项数据。
 *
 * @param key 项唯一标识（对应 activeKeys 中的值）
 * @param title 标题行文案
 * @param content 展开后内容（Composable）
 * @param disabled 禁用：标题置灰、不可点击展开
 */
data class CollapseItem(
    val key: String,
    val title: String,
    val disabled: Boolean = false,
    val content: @Composable () -> Unit
)

/**
 * 折叠面板：点击标题展开/收起内容区域。
 *
 * @param items 折叠项数据数组
 * @param activeKeys 展开项 key 列表；null=内部自管理状态，非 null=受控
 * @param onChange 展开态变化回调，返回最新 activeKeys
 * @param accordion 手风琴模式：true 时只允许一项展开，展新项自动收旧项
 * @param modifier 外部修饰
 */
@Composable
fun Collapse(
    items: List<CollapseItem>,
    activeKeys: List<String>? = null,
    onChange: ((List<String>) -> Unit)? = null,
    accordion: Boolean = false,
    modifier: Modifier = Modifier,
) {
    // P1-C 混合受控：activeKeys 非空=受控（直接用），null=内部 remember 自管理。
    var internalKeys by remember { mutableStateOf(emptySet<String>()) }
    val effectiveKeys: Set<String> = activeKeys?.toSet() ?: internalKeys

    fun toggle(item: CollapseItem) {
        if (item.disabled) return
        val current = effectiveKeys
        val newKeys: Set<String> = if (item.key in current) {
            // 已展开 → 收起
            current - item.key
        } else {
            // 未展开 → 展开；手风琴模式先清空只留新项
            if (accordion) setOf(item.key) else current + item.key
        }
        if (activeKeys == null) {
            internalKeys = newKeys
        }
        onChange?.invoke(newKeys.toList())
    }

    // 安卓禁令：圆角裁切用 background(shape=圆角矩形)，不用 Modifier.clip()/graphicsLayer()。
    Column(
        modifier = modifier
            .fillMaxWidth()
            .background(AppColor.bgCard, RoundedCornerShape(AppRadius.lg))
    ) {
        items.forEachIndexed { index, item ->
            val expanded = item.key in effectiveKeys
            // 标题行：上下 cellVertical（16dp）+ 左右 lg，对齐 Cell 与设计稿高度。
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .then(
                        if (item.disabled) Modifier
                        else Modifier.clickable { toggle(item) }
                    )
                    .padding(horizontal = AppSpace.lg, vertical = AppSpace.cellVertical)
                    .testTag("collapse-head-${item.key}"),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically,
            ) {
                Text(
                    text = item.title,
                    color = if (item.disabled) AppColor.gray25 else AppColor.textPrimary,
                    fontSize = AppFont.sizeMd,
                    fontWeight = FontWeight.Medium,
                    modifier = Modifier.weight(1f)
                )
                // P3-A chevron 箭头：收起=右指(0°)，展开=下指(rotate 90°)。
                // 与 Cell 箭头同款：KeyboardArrowRight + gray25，size lg(16dp)。
                Icon(
                    imageVector = Icons.AutoMirrored.Filled.KeyboardArrowRight,
                    contentDescription = null,
                    tint = AppColor.gray25,
                    modifier = Modifier
                        .size(AppSpace.lg)
                        .rotate(if (expanded) 90f else 0f)
                        .testTag("collapse-chevron-${item.key}"),
                )
            }
            // 内容区：仅展开时渲染（P2-A 瞬切，无动画）。
            if (expanded) {
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = AppSpace.lg, vertical = AppSpace.md)
                        .testTag("collapse-body-${item.key}")
                ) {
                    item.content()
                }
            }
            // 项间分隔线：非末项。
            if (index < items.lastIndex) {
                Spacer(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(1.dp)
                        .background(AppColor.border)
                )
            }
        }
    }
}
