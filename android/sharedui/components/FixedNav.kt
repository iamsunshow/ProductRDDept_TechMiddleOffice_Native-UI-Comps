package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.IntrinsicSize
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.defaultMinSize
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.wrapContentSize
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.shadow
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
 * 悬浮导航项数据（与 iOS `FixedNavItem` 同构）。
 */
data class FixedNavItem(
    /** 唯一标识（选中回传用）。 */
    val key: String,
    /** 行展示文案。 */
    val text: String,
    /** 行图标位字符（emoji/单字符）；null=行内不显示图标位（不占位，见 D3）。 */
    val icon: String? = null,
    /** 角标数字；null 或 <=0=不显示角标。 */
    val num: Int? = null,
)

/** 悬浮导航摆放方向（type）：Right=钮靠右缘、面板同右缘对齐向上弹出；Left=对称。 */
enum class FixedNavType { Right, Left }

/**
 * FixedNavView 悬浮导航：页面边缘常驻悬浮入口钮 + 展开导航项列表的"快捷导航器"。
 *
 * 组件 ID：`ui.fixed-nav`（api.json 契约对齐，门禁 A AI 代评通过 2026-09-05；
 * P1–P4 全 A：收起胶囊钮 + 点钮弹出面板 + 点项自动收起 + type 左右 + 文案自定义）。
 *
 * 一期语义（对标 NutUI React FixedNav 悬浮导航，与 iOS `FixedNavView` 双端同构）：
 * - [items]：导航项列表（key/text/icon?/num?），面板竖排行数 = items 数
 * - [expanded]/[onExpandedChange]：展开状态受控（Compose 惯例），点钮由组件回调翻转；
 *   点面板外收起=外部在容器 tap 时回调 false（demo D4）
 * - [type]：`Right`=钮靠右缘、面板同右缘对齐向上弹出；`Left` 对称
 * - [activeText]/[unActiveText]：展开/收起态钮文案（null=默认"收起导航"/"快速导航"）
 * - [onSelect]：点某项回调（面板行点击内部回调后自动收起）；null=仅展开/收起
 * - "悬浮"定位由宿主完成（把本组件放入非滚动覆盖层锚定边角，同 BackTop 先例）；
 *   组件不代管布局上下文、不做 window 级浮层、不监听滚动
 *
 * 用法（宿主锚定角落，示例右下）：
 * ```kotlin
 * var expanded by remember { mutableStateOf(false) }
 * FixedNav(
 *     items = listOf(
 *         FixedNavItem("home", "首页", icon = "⌂", num = 2),
 *         FixedNavItem("cart", "购物车", num = 5),
 *     ),
 *     expanded = expanded,
 *     onExpandedChange = { expanded = it },
 *     onSelect = { /* 选中回传 */ },
 *     modifier = Modifier.align(Alignment.BottomEnd).padding(AppSpace.md),
 * )
 * ```
 */
@Composable
fun FixedNav(
    items: List<FixedNavItem>,
    expanded: Boolean,
    onExpandedChange: (Boolean) -> Unit,
    modifier: Modifier = Modifier,
    type: FixedNavType = FixedNavType.Right,
    activeText: String? = null,
    unActiveText: String? = null,
    onSelect: ((FixedNavItem) -> Unit)? = null,
) {
    val enabled = items.isNotEmpty()
    val activeLabel = activeText ?: "收起导航"
    val unActiveLabel = unActiveText ?: "快速导航"
    Column(
        modifier = modifier,
        verticalArrangement = Arrangement.spacedBy(AppSpace.sm),
        horizontalAlignment = if (type == FixedNavType.Right) Alignment.End else Alignment.Start,
    ) {
        if (expanded && enabled) {
            FixedNavPanel(items = items) { item ->
                onSelect?.invoke(item)
                onExpandedChange(false) // 点项自动收起（P2 契约）
            }
        }
        val capsuleShape = RoundedCornerShape(50)
        Row(
            modifier = Modifier
                .height(40.dp)
                .background(AppColor.primary, capsuleShape)
                .clickable(
                    enabled = enabled,
                    interactionSource = remember { MutableInteractionSource() },
                    indication = null, // 行/钮均无涟漪（同 Elevator onSelect 无涟漪契约）
                ) { onExpandedChange(!expanded) }
                .padding(horizontal = AppSpace.lg),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Text(
                text = if (expanded) activeLabel else unActiveLabel,
                color = Color.White,
                fontSize = AppFont.sizeSm,
                fontWeight = FontWeight.SemiBold,
            )
        }
    }
}

/** 面板卡片：卡片壳（bgCard/圆角 md/边框/阴影）+ 竖排行（行高 44，末行无下边线）。 */
@Composable
private fun FixedNavPanel(
    items: List<FixedNavItem>,
    onItemSelected: (FixedNavItem) -> Unit,
) {
    val shape = RoundedCornerShape(AppRadius.md)
    Column(
        // 面板宽 = 最长行的内容自然宽（>=140），不再跟随父容器全宽。
        // width(IntrinsicSize.Min) 让每个子 Row 用自身内容宽决定列宽；子 Row fillMaxWidth
        // 后所有行等宽，保证 num 用 weight 推到行尾时各行右端对齐。
        modifier = Modifier
            .width(IntrinsicSize.Min)
            .shadow(elevation = 4.dp, shape = shape, clip = false)
            .background(AppColor.bgCard, shape)
            .border(width = 0.5.dp, color = AppColor.border, shape = shape),
    ) {
        items.forEachIndexed { index, item ->
            val isLast = index == items.lastIndex
            Box(
                modifier = Modifier
                    .testTag("fixednav-row-$index")
                    .fillMaxWidth()
                    .defaultMinSize(minWidth = 140.dp)
                    .height(44.dp)
                    .clickable(
                        interactionSource = remember { MutableInteractionSource() },
                        indication = null,
                    ) { onItemSelected(item) },
            ) {
                Row(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(horizontal = AppSpace.md),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(AppSpace.sm),
                ) {
                    if (item.icon != null) {
                        Box(
                            modifier = Modifier
                                .size(20.dp)
                                .background(AppColor.primaryMuted, RoundedCornerShape(AppRadius.sm)),
                            contentAlignment = Alignment.Center,
                        ) {
                            Text(
                                text = item.icon,
                                color = AppColor.primary,
                                fontSize = AppFont.sizeXs,
                                fontWeight = FontWeight.SemiBold,
                                lineHeight = AppFont.sizeXs,
                                textAlign = TextAlign.Center,
                                modifier = Modifier.wrapContentSize(Alignment.Center),
                            )
                        }
                    }
                    Text(
                        text = item.text,
                        color = AppColor.textPrimary,
                        fontSize = AppFont.sizeSm,
                        maxLines = 1,
                    )
                    // 占用标题与角标之间的富余空间，把角标推到行尾（margin-left:auto 语义）。
                    // 无角标时 spacer 同样撑满行尾，保持 title 左对齐。
                    Spacer(modifier = Modifier.weight(1f))
                    if ((item.num ?: 0) > 0) {
                        Box(
                            modifier = Modifier
                                .defaultMinSize(minWidth = 16.dp, minHeight = 16.dp)
                                .background(AppColor.primary, CircleShape)
                                .padding(horizontal = AppSpace.xs),
                            contentAlignment = Alignment.Center,
                        ) {
                            Text(
                                text = "${item.num}",
                                color = Color.White,
                                fontSize = AppFont.sizeXs,
                                fontWeight = FontWeight.SemiBold,
                                lineHeight = AppFont.sizeXs,
                                textAlign = TextAlign.Center,
                            )
                        }
                    }
                }
                if (!isLast) {
                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(0.5.dp)
                            .align(Alignment.BottomCenter)
                            .background(AppColor.border),
                    )
                }
            }
        }
    }
}
