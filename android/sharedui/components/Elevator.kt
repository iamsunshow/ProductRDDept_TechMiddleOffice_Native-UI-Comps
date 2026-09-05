package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.derivedStateOf
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppFont
import com.zhiqihuayun.foundation.design.AppSpace
import kotlinx.coroutines.launch

/**
 * 电梯楼层分组数据（与 iOS `ElevatorFloor` 同构）。
 */
data class ElevatorFloor(val key: String, val items: List<String>)

/** 组件内扁平行类型：分组标题行 / 内容行（与 iOS 无 section 扁平数据同构，标题不吸顶）。 */
private sealed class ElevatorRowItem(val floor: Int) {
    class Header(floor: Int, val key: String) : ElevatorRowItem(floor)
    class Item(floor: Int, val row: Int, val name: String) : ElevatorRowItem(floor)
}

/**
 * Elevator 电梯楼层：数据驱动分组内容 + 右侧楼/字母索引导航的"定位器"。
 *
 * 组件 ID：`ui.elevator`（api.json 契约对齐，门禁 A AI 代评通过 2026-09-05，
 * 用户"除特色组件外所有组件评审文档全部生成，中间任何询问直接通过"总授权；
 * P1–P4 全 A：自包含定高 + 索引自动/显式 + 双向联动 + 行点击可选）。
 *
 * 一期语义（对标 NutUI React Elevator 电梯楼层）：
 * - [floors]：分组数据 [(key: 分组标题, items: 组内文本行)]
 * - [index]：右侧索引；null=自动取各分组 key
 * - [onSelect]：分组行点击回调 (分组序号, 组内行号, 名称)；null=不响应行点击
 * - 交互：点右侧索引 → 对应分组首行滚到可视顶部；内容滚动 → 可视首分组高亮索引
 * - 分组标题行（32dp）为普通行随内容滚动（不吸顶）；内容行高 56dp=规范行高；
 *   LazyColumn 滚动容器高度由宿主约束（组件不强代管布局上下文）
 *
 * 用法：
 * ```kotlin
 * val floors = listOf(
 *     ElevatorFloor("1F", listOf("星巴克", "瑞幸咖啡")),
 *     ElevatorFloor("2F", listOf("优衣库", "无印良品")),
 * )
 * Elevator(floors = floors, modifier = Modifier.height(300.dp))
 * ```
 *
 * @param floors 分组数据
 * @param modifier 布局修饰符（含高度约束）
 * @param index 右侧索引（null=自动取各分组 key）
 * @param onSelect 分组行点击回调（null=不响应）
 */
@Composable
fun Elevator(
    floors: List<ElevatorFloor>,
    modifier: Modifier = Modifier,
    index: List<String>? = null,
    onSelect: ((floor: Int, row: Int, name: String) -> Unit)? = null,
) {
    val indexKeys = remember(floors, index) { index ?: floors.map { it.key } }
    val rowItems = remember(floors) {
        val result = ArrayList<ElevatorRowItem>()
        floors.forEachIndexed { floor, group ->
            result.add(ElevatorRowItem.Header(floor, group.key))
            group.items.forEachIndexed { row, name ->
                result.add(ElevatorRowItem.Item(floor, row, name))
            }
        }
        result
    }
    val listState = rememberLazyListState()
    // 滚动联动高亮：可视首行所在分组即当前分组（同 iOS indexPathsForVisibleRows 首行判定）
    val currentFloor by remember {
        derivedStateOf { rowItems.getOrNull(listState.firstVisibleItemIndex)?.floor ?: 0 }
    }
    val scope = rememberCoroutineScope()

    Row(modifier = modifier) {
        LazyColumn(
            state = listState,
            modifier = Modifier
                .weight(1f)
                .fillMaxHeight()
        ) {
            itemsIndexed(rowItems) { _, item ->
                when (item) {
                    is ElevatorRowItem.Header -> ElevatorHeaderRow(item.key)
                    is ElevatorRowItem.Item -> ElevatorItemRow(
                        name = item.name,
                        onClick = onSelect?.let { callback ->
                            { callback(item.floor, item.row, item.name) }
                        }
                    )
                }
            }
        }
        ElevatorIndexBar(
            keys = indexKeys,
            currentKey = floors.getOrNull(currentFloor)?.key,
            onKey = { key ->
                val floor = floors.indexOfFirst { it.key == key }
                if (floor >= 0) {
                    val target = rowItems.indexOfFirst { it.floor == floor && it is ElevatorRowItem.Header }
                    if (target >= 0) {
                        scope.launch { listState.animateScrollToItem(target) }
                    }
                }
            }
        )
    }
}

/** 分组标题行：高 32dp、primaryMuted 底 + primary 标题，无分隔线（与 iOS 同构）。 */
@Composable
private fun ElevatorHeaderRow(key: String) {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .height(32.dp)
            .background(AppColor.primaryMuted),
        contentAlignment = Alignment.CenterStart
    ) {
        Text(
            text = key,
            style = TextStyle(
                fontSize = AppFont.sizeXs,
                fontWeight = FontWeight.SemiBold,
                color = AppColor.primaryPressed
            ),
            modifier = Modifier.padding(horizontal = AppSpace.lg)
        )
    }
}

/** 内容行：高 56dp + 底部 0.5dp 细分割线（同库规范行高 Cell.minHeight）；onClick 空=整行不可点。 */
@Composable
private fun ElevatorItemRow(name: String, onClick: (() -> Unit)?) {
    val clickableModifier = if (onClick != null) {
        Modifier.clickable(
            interactionSource = remember { MutableInteractionSource() },
            indication = null,
            onClick = onClick
        )
    } else {
        Modifier
    }
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .height(56.dp)
            .then(clickableModifier),
        contentAlignment = Alignment.CenterStart
    ) {
        Text(
            text = name,
            style = TextStyle(
                fontSize = AppFont.sizeSm,
                color = AppColor.textPrimary
            ),
            modifier = Modifier.padding(horizontal = AppSpace.lg)
        )
        Box(
            modifier = Modifier
                .align(Alignment.BottomStart)
                .fillMaxWidth()
                .height(0.5.dp)
                .background(AppColor.border)
        )
    }
}

/** 右侧索引条：宽 44dp，索引字主色加粗=当前分组（与 iOS 同构，无涟漪）。 */
@Composable
private fun ElevatorIndexBar(keys: List<String>, currentKey: String?, onKey: (String) -> Unit) {
    Column(
        modifier = Modifier
            .width(44.dp)
            .fillMaxHeight()
            .padding(vertical = AppSpace.xs),
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        keys.forEach { key ->
            val isCurrent = key == currentKey
            Text(
                text = key,
                style = TextStyle(
                    fontSize = AppFont.sizeXs,
                    fontWeight = if (isCurrent) FontWeight.Bold else FontWeight.Normal,
                    color = if (isCurrent) AppColor.primary else AppColor.textSecondary
                ),
                textAlign = TextAlign.Center,
                modifier = Modifier
                    .padding(vertical = 4.dp)
                    .clickable(
                        interactionSource = remember { MutableInteractionSource() },
                        indication = null
                    ) {
                        onKey(key)
                    }
            )
        }
    }
}
