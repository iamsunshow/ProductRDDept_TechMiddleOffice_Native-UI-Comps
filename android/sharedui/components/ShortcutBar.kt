package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppFont
import com.zhiqihuayun.foundation.design.AppRadius
import com.zhiqihuayun.foundation.design.AppSpace

/** 快捷栏视觉 token：与 iOS ShortcutBarView / design-spec §02 对齐。 */
private object ShortcutBarTokens {
    /** 图标容器尺寸（dp；=26×26 圆角 6 primary 背景）。 */
    val iconContainerSize = 26.dp
    /** 图标容器圆角 = 6dp。 */
    val iconContainerRadius = 6.dp
    /** 图标白圆尺寸（16dp，system font glyph 标准尺寸）。 */
    val iconSize = 16.dp
    /** entry 上下内边距（dp；=6dp）。 */
    val entryPaddingVertical = 6.dp
    /** entry 左右内边距（dp；=4dp）。 */
    val entryPaddingHorizontal = 4.dp
    /** entry 内 icon 与 text 间距（dp；=spaceXs=4dp）。 */
    val iconTextGap = AppSpace.xs
    /** 默认列数（4；支持 3/4/5；超长自动横滚）。 */
    const val defaultColumns = 4
}

/**
 * ShortcutBar 快捷栏入口数据项。
 */
data class ShortcutBarItem(
    val id: String,
    val icon: String,
    val text: String,
)

/**
 * 横向单行快捷入口条（数据驱动 + 等分列 + 点击回调）。
 *
 * 视觉锚点（与 iOS ShortcutBarView 1:1）：白底 bgCard + hairline 描边 + radiusLg 圆角壳 +
 * entry=图标容器 26×26 圆角 6 primary 背景 + 白色图标 16 + 文字 sizeXs=12 textPrimary 单行省略
 * + 命中整 entry + ripple 按压态。
 *
 * 语义：items `[{id, icon, text}]` 数据驱动 + columns? 列数默认 4 + onClick(id) 回调；
 * columns 超长 entries 自动横滚（horizontalScroll）。
 *
 * @param modifier items 宿主修饰（卡片壳外的尺寸/位置宿主摆放）。
 * @param items 数据驱动条目（id/图标字符/文本）。
 * @param columns 列数（默认 4；传 0/负值回退 4；items > columns 走横滚）。
 * @param disabled 整条禁用（仅命中无回调，视觉不变；对齐 iOS isUserInteractionEnabled 锁定语义）。
 * @param onClick 点击回调（返回 entry id；disabled 无回调）。
 */
@Composable
fun ShortcutBar(
    modifier: Modifier = Modifier,
    items: List<ShortcutBarItem>,
    columns: Int = ShortcutBarTokens.defaultColumns,
    disabled: Boolean = false,
    onClick: (String) -> Unit,
) {
    val effColumns = if (columns < 1) ShortcutBarTokens.defaultColumns else columns
    val cardShape = RoundedCornerShape(AppRadius.lg)
    val needsScroll = items.size > effColumns
    val containerModifier = modifier
        .fillMaxWidth()
        .clip(cardShape)
        .background(AppColor.bgCard)
        .border(0.5.dp, AppColor.border, cardShape)
        .padding(
            horizontal = AppSpace.lg,
            vertical = AppSpace.md,
        )

    // 布局契约（与 iOS ShortcutBarView 1:1）：
    //  - items ≤ columns：整条宽 = 可视宽，entry 等分（超长文本单行省略）
    //  - items > columns：entry 定宽 = 可视宽/columns（扣间距均摊），row 随内容撑宽 → 横向滚动
    BoxWithConstraints(modifier = containerModifier) {
        if (needsScroll) {
            val perColumn = maxWidth / effColumns
            val gutter = AppSpace.sm * (effColumns - 1) / effColumns
            val entryWidth = perColumn - gutter
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .horizontalScroll(rememberScrollState()),
                horizontalArrangement = Arrangement.spacedBy(AppSpace.sm),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                items.forEach { item ->
                    ShortcutBarEntry(
                        item = item,
                        disabled = disabled,
                        entryModifier = Modifier.width(entryWidth),
                        onClick = onClick,
                    )
                }
            }
        } else {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(AppSpace.sm),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                items.forEach { item ->
                    ShortcutBarEntry(
                        item = item,
                        disabled = disabled,
                        entryModifier = Modifier.weight(1f),
                        onClick = onClick,
                    )
                }
            }
        }
    }
}

/** 单个 entry：图标容器 26×26 圆角 6 primary + 白色图标 16 + sizeXs 12 textPrimary 单行省略。 */
@Composable
private fun ShortcutBarEntry(
    item: ShortcutBarItem,
    disabled: Boolean,
    entryModifier: Modifier,
    onClick: (String) -> Unit,
) {
    Column(
        modifier = entryModifier
            .clickable(enabled = !disabled) { onClick(item.id) }
            .padding(
                horizontal = ShortcutBarTokens.entryPaddingHorizontal,
                vertical = ShortcutBarTokens.entryPaddingVertical,
            ),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(ShortcutBarTokens.iconTextGap),
    ) {
        // 图标容器（primary 背景 + 白色图标 16）
        Box(
            modifier = Modifier
                .size(ShortcutBarTokens.iconContainerSize)
                .clip(RoundedCornerShape(ShortcutBarTokens.iconContainerRadius))
                .background(AppColor.primary),
            contentAlignment = Alignment.Center,
        ) {
            Text(
                text = item.icon,
                color = androidx.compose.ui.graphics.Color.White,
                fontSize = AppFont.sizeXs,
                fontWeight = FontWeight.Medium,
            )
        }
        // 文本（sizeXs=12 textPrimary 单行省略）
        Text(
            text = item.text,
            color = AppColor.textPrimary,
            fontSize = AppFont.sizeXs,
            textAlign = TextAlign.Center,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis,
            // 文本宽 = entry 宽（等分/定宽由宿主 entryModifier 决定），超长单行省略
            modifier = Modifier.fillMaxWidth(),
        )
    }
}