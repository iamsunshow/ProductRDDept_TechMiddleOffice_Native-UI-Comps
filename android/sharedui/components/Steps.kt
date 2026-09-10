// Steps 步骤条组件（Compose 版，对齐 iOS StepsView）。
//
// 展示含多个步骤的流程进度——已完成步骤打勾、当前步骤高亮、未到达步骤置灰，
// 横向或竖向排列。数据驱动 items 数组（每项 title+desc+可选 icon），
// current 控制当前步骤索引（-1=内部自管理初始 0，≥0=受控），
// direction 切换横向/竖向，已完成步骤显示对勾并把连线染主色，
// 当前步骤主色描边高亮，未开始步骤灰色置灰，支持点击已完成步骤回退（onChange）。
//
// 决策（与设计规格 steps-design-spec.html 一致）：
// - P1-C 混合受控：current=-1=内部 remember 自管理，≥0=受控
// - P2-B 一期可点击已完成步骤回退（onChange 回调），未开始/当前不可点击
// - P3-A 默认已完成=对勾，当前/未开始=数字；icon 字段可覆盖为自定义图标
// - P4-A 一期=基础步骤条/横向+竖向/当前步骤高亮/自定义图标+demo 四段

package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
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
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material.icons.filled.Share
import androidx.compose.material.icons.filled.Star
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppFont
import com.zhiqihuayun.foundation.design.AppSpace

/**
 * 步骤条方向。
 */
enum class StepsDirection { Horizontal, Vertical }

/**
 * 单个步骤数据。
 *
 * @param title 步骤标题
 * @param desc 步骤描述（可选）
 * @param icon 自定义图标名（映射到 Material Icon）；null=默认数字/对勾
 */
data class StepsItem(
    val title: String,
    val desc: String? = null,
    val icon: String? = null,
)

/// 步骤状态（由 current 推导）。
private enum class StepState { Finished, Active, Inactive }

/** 步骤圆点尺寸。 */
private val CircleSize = 24.dp

/**
 * 步骤条：展示多步流程进度。
 *
 * @param items 步骤数据数组
 * @param current 当前步骤索引（0-based）；-1=内部自管理状态（初始 0），≥0=受控
 * @param direction 步骤条方向：Horizontal 横向 / Vertical 竖向
 * @param onChange 步骤切换回调（点击已完成步骤回退时触发，返回目标索引）
 * @param modifier 外部修饰
 */
@Composable
fun Steps(
    items: List<StepsItem>,
    current: Int = -1,
    direction: StepsDirection = StepsDirection.Horizontal,
    onChange: ((Int) -> Unit)? = null,
    modifier: Modifier = Modifier,
) {
    // P1-C 混合受控：current=-1 内部 remember 自管理，≥0 受控。
    var internalCurrent by remember { mutableStateOf(0) }
    val effectiveCurrent = if (current >= 0) current else internalCurrent

    fun handleClick(index: Int) {
        // P2-B：仅已完成步骤可回退。
        if (index >= effectiveCurrent) return
        if (current < 0) internalCurrent = index
        onChange?.invoke(index)
    }

    if (direction == StepsDirection.Horizontal) {
        Row(
            modifier = modifier.fillMaxWidth(),
            verticalAlignment = Alignment.Top,
        ) {
            items.forEachIndexed { index, item ->
                val state = stepState(index, effectiveCurrent)
                HorizontalStep(
                    item = item,
                    index = index,
                    state = state,
                    isLast = index == items.lastIndex,
                    onClick = { handleClick(index) },
                    modifier = Modifier.weight(1f),
                )
            }
        }
    } else {
        Column(
            modifier = modifier.fillMaxWidth(),
        ) {
            items.forEachIndexed { index, item ->
                val state = stepState(index, effectiveCurrent)
                VerticalStep(
                    item = item,
                    index = index,
                    state = state,
                    isLast = index == items.lastIndex,
                    onClick = { handleClick(index) },
                )
            }
        }
    }
}

private fun stepState(index: Int, current: Int): StepState = when {
    index < current -> StepState.Finished
    index == current -> StepState.Active
    else -> StepState.Inactive
}

@Composable
private fun HorizontalStep(
    item: StepsItem,
    index: Int,
    state: StepState,
    isLast: Boolean,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
) {
    val clickable = state == StepState.Finished
    Column(
        modifier = modifier,
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        // 圆点 + 横向连线
        Box(
            modifier = Modifier.fillMaxWidth(),
            contentAlignment = Alignment.Center,
        ) {
            // 连线（圆点右侧到容器右端）
            if (!isLast) {
                Box(
                    modifier = Modifier
                        .align(Alignment.CenterEnd)
                        .fillMaxWidth(0.5f)
                        .height(1.dp)
                        .background(if (state == StepState.Finished) AppColor.primary else AppColor.gray6)
                )
            }
            StepCircle(item, index, state, clickable, onClick)
        }
        Spacer(Modifier.height(AppSpace.sm))
        Text(
            text = item.title,
            color = if (state == StepState.Inactive) AppColor.textSecondary else AppColor.textPrimary,
            fontSize = AppFont.sizeSm,
            textAlign = TextAlign.Center,
        )
        if (item.desc != null) {
            Spacer(Modifier.height(AppSpace.xs))
            Text(
                text = item.desc,
                color = AppColor.textSecondary,
                fontSize = AppFont.sizeXs,
                textAlign = TextAlign.Center,
            )
        }
    }
}

@Composable
private fun VerticalStep(
    item: StepsItem,
    index: Int,
    state: StepState,
    isLast: Boolean,
    onClick: () -> Unit,
) {
    val clickable = state == StepState.Finished
    Row(
        modifier = Modifier.fillMaxWidth(),
        verticalAlignment = Alignment.Top,
    ) {
        // 圆点 + 竖向连线
        Box {
            StepCircle(item, index, state, clickable, onClick)
            if (!isLast) {
                Box(
                    modifier = Modifier
                        .align(Alignment.BottomCenter)
                        .width(1.dp)
                        .height(40.dp)
                        .background(if (state == StepState.Finished) AppColor.primary else AppColor.gray6)
                )
            }
        }
        Spacer(Modifier.width(AppSpace.md))
        Column(modifier = Modifier.weight(1f)) {
            Text(
                text = item.title,
                color = if (state == StepState.Inactive) AppColor.textSecondary else AppColor.textPrimary,
                fontSize = AppFont.sizeSm,
            )
            if (item.desc != null) {
                Spacer(Modifier.height(AppSpace.xs))
                Text(
                    text = item.desc,
                    color = AppColor.textSecondary,
                    fontSize = AppFont.sizeXs,
                )
            }
        }
    }
    if (!isLast) Spacer(Modifier.height(AppSpace.md))
}

@Composable
private fun StepCircle(
    item: StepsItem,
    index: Int,
    state: StepState,
    clickable: Boolean,
    onClick: () -> Unit,
) {
    val bgColor: Color
    val borderColor: Color
    val borderWidth: androidx.compose.ui.unit.Dp
    val contentColor: Color
    when (state) {
        StepState.Finished -> {
            bgColor = AppColor.primary
            borderColor = AppColor.primary
            borderWidth = 0.dp
            contentColor = Color.White
        }
        StepState.Active -> {
            bgColor = AppColor.bgCard
            borderColor = AppColor.primary
            borderWidth = 2.dp
            contentColor = AppColor.primary
        }
        StepState.Inactive -> {
            bgColor = AppColor.bgCard
            borderColor = AppColor.gray6
            borderWidth = 1.dp
            contentColor = AppColor.gray25
        }
    }

    val circleModifier = Modifier
        .size(CircleSize)
        .clip(CircleShape)
        .background(bgColor)
        .border(borderWidth, borderColor, CircleShape)
        .then(if (clickable) Modifier.clickable(onClick = onClick) else Modifier)

    Box(
        modifier = circleModifier,
        contentAlignment = Alignment.Center,
    ) {
        val iconVector = item.icon?.let { resolveIcon(it) }
        if (iconVector != null) {
            Icon(
                imageVector = iconVector,
                contentDescription = null,
                tint = contentColor,
                modifier = Modifier.size(CircleSize * 0.6f),
            )
        } else if (state == StepState.Finished) {
            Icon(
                imageVector = Icons.Filled.Check,
                contentDescription = null,
                tint = Color.White,
                modifier = Modifier.size(CircleSize * 0.6f),
            )
        } else {
            Text(
                text = "${index + 1}",
                color = contentColor,
                fontSize = AppFont.sizeXs,
                fontWeight = FontWeight.SemiBold,
            )
        }
    }
}

/**
 * 图标名到 Material ImageVector 的映射（与 iOS SF Symbol 语义对齐）。
 * 未命中返回 null，回退到默认数字/对勾。
 */
private fun resolveIcon(name: String): ImageVector? = when (name) {
    "star", "star.fill" -> Icons.Filled.Star
    "heart", "heart.fill" -> Icons.Filled.Favorite
    "square.and.arrow.up", "share" -> Icons.Filled.Share
    "checkmark", "check" -> Icons.Filled.Check
    else -> null
}
