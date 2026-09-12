package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.Canvas
import androidx.compose.material3.DropdownMenu
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppFont
import com.zhiqihuayun.foundation.design.AppRadius
import com.zhiqihuayun.foundation.design.AppSpace

// MARK: - Data models

/// DropDown 选项数据
data class DropDownOption(val value: String, val text: String)

/// DropDownMenu 菜单项数据
data class DropDownMenuItem(
    val title: String,
    val options: List<DropDownOption>,
    var value: String = ""
)

// MARK: - DropDown

/**
 * DropDown 下拉菜单（导航组件 · ui.dropdown）：单列下拉选择器。
 *
 * 视觉：触发行高 44 灰底圆角，右侧 chevron 指示；点击展开 Material3 DropdownMenu；
 * 选中项 primary 高亮；点选项即收起。
 * 语义：value 受控选中值；onValueChange 选中回调；disabled 整体 40% 灰不可点。
 */
@Composable
fun DropDown(
    title: String = "请选择",
    options: List<DropDownOption>,
    value: String = "",
    onValueChange: ((String) -> Unit)? = null,
    disabled: Boolean = false,
    modifier: Modifier = Modifier
) {
    var expanded by remember { mutableStateOf(false) }
    // 内部选中态：外部 value 变更（如 D4「外部切到 C」）时同步；用户点选项时立即回写，
    // 即使调用方未传 onValueChange（D4），触发器显示也即时更新（台账 #63，对齐 iOS valueStorage 机制）。
    var innerValue by remember(value) { mutableStateOf(value) }
    val selectedText = options.firstOrNull { it.value == innerValue }?.text ?: title

    Box(modifier = modifier.testTag("dropdown-root")) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .height(44.dp)
                .alpha(if (disabled) 0.4f else 1f)
                .clip(RoundedCornerShape(AppRadius.md))
                .background(AppColor.bgPage)
                .clickable(enabled = !disabled) { expanded = !expanded }
                .padding(horizontal = AppSpace.md),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            Text(
                text = title,
                fontSize = AppFont.sizeSm,
                color = AppColor.textSecondary,
                maxLines = 1
            )
            // 右侧区域：选中值 + chevron + DropdownMenu
            // DropdownMenu 放在此处，面板从选中值文字下方弹出（而非标题）
            Box {
                // 文字与箭头固定 4dp 间距（台账 #60：时大时小根因=旧 width(120.dp) 固定宽，短文本留大片空白）
                Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(4.dp)) {
                    Text(
                        text = selectedText,
                        fontSize = AppFont.sizeMd,
                        color = if (options.any { it.value == innerValue }) AppColor.textPrimary else AppColor.textSecondary.copy(alpha = 0.5f),
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis,
                        modifier = Modifier.widthIn(max = 120.dp)
                    )
                    ChevronDown(color = AppColor.textSecondary.copy(alpha = 0.5f))
                }

                DropdownMenu(
                    expanded = expanded,
                    onDismissRequest = { expanded = false },
                    modifier = Modifier.background(AppColor.bgCard)
                ) {
                    options.forEach { opt ->
                        val selected = opt.value == innerValue
                        DropdownMenuItem(
                            text = {
                                // 双端统一：选中项=绿字 + 右侧 ✓ 对勾（对齐 iOS cell.textLabel primary + checkmark）
                                Row(
                                    modifier = Modifier.fillMaxWidth(),
                                    verticalAlignment = Alignment.CenterVertically,
                                    horizontalArrangement = Arrangement.SpaceBetween
                                ) {
                                    Text(
                                        text = opt.text,
                                        color = if (selected) AppColor.primary else AppColor.textPrimary,
                                        fontSize = AppFont.sizeMd
                                    )
                                    if (selected) {
                                        Text("✓", color = AppColor.primary, fontSize = AppFont.sizeMd)
                                    }
                                }
                            },
                            onClick = {
                                innerValue = opt.value
                                onValueChange?.invoke(opt.value)
                                expanded = false
                            }
                        )
                    }
                }
            }
        }
    }
}

// MARK: - DropDownMenu

/**
 * DropDownMenu 下拉菜单容器（导航组件 · ui.dropdown-menu）：管理多个下拉列。
 *
 * 视觉：水平等分按钮栏 + 展开浮层；同时只展开一列。
 * 语义：items 数据源；onValueChange(index, value) 选中回调。
 */
@Composable
fun DropDownMenu(
    items: List<DropDownMenuItem>,
    onValueChange: ((Int, String) -> Unit)? = null,
    modifier: Modifier = Modifier
) {
    var expandedIndex by remember { mutableStateOf(-1) }

    Column(modifier = modifier.testTag("dropdown-menu-root")) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(AppSpace.xs)
        ) {
            items.forEachIndexed { index, item ->
                // 每列按钮+悬浮面板包在独立 BoxWithConstraints：面板用 DropdownMenu 悬空弹出（不撑开内容区域，
                // 对齐 iOS 交互=用户 2026-09-12 指定），且自带点击面板外自动关闭。
                BoxWithConstraints(modifier = Modifier.weight(1f)) {
                    // 面板宽=本列宽（对齐 iOS PanelWidthMode.matchAnchor，台账 #65）
                    val columnWidth = maxWidth
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(44.dp)
                            .clip(RoundedCornerShape(AppRadius.md))
                            // 底色=设计 token bgPage（白卡容器上呈浅灰药丸，双端一致；曾临时 black4%，#65 回归）
                            .background(AppColor.bgPage)
                            .clickable {
                                expandedIndex = if (expandedIndex == index) -1 else index
                            }
                            .padding(horizontal = AppSpace.sm),
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.Center
                    ) {
                        // 文字与箭头固定 4dp 间距（同 D1，台账 #60）
                        Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(4.dp)) {
                            Text(
                                text = item.title,
                                fontSize = AppFont.sizeMd,
                                color = AppColor.textPrimary,
                                maxLines = 1
                            )
                            ChevronDown(color = AppColor.textSecondary.copy(alpha = 0.5f))
                        }
                    }

                    DropdownMenu(
                        expanded = expandedIndex == index,
                        onDismissRequest = { expandedIndex = -1 },
                        modifier = Modifier
                            .width(columnWidth)
                            .background(AppColor.bgCard)
                    ) {
                        item.options.forEach { opt ->
                            val selected = opt.value == item.value
                            DropdownMenuItem(
                                text = {
                                    Row(
                                        modifier = Modifier.fillMaxWidth(),
                                        verticalAlignment = Alignment.CenterVertically,
                                        horizontalArrangement = Arrangement.SpaceBetween
                                    ) {
                                        Text(
                                            text = opt.text,
                                            fontSize = AppFont.sizeMd,
                                            color = if (selected) AppColor.primary else AppColor.textPrimary
                                        )
                                        if (selected) {
                                            Text("✓", color = AppColor.primary, fontSize = AppFont.sizeMd)
                                        }
                                    }
                                },
                                onClick = {
                                    onValueChange?.invoke(index, opt.value)
                                    expandedIndex = -1
                                }
                            )
                        }
                    }
                }
            }
        }
    }
}

// MARK: - ChevronDown

/**
 * 下拉三角箭头（自绘 8×8dp 实心等腰三角，顶点向下）。
 *
 * 对齐 iOS ChevronView（8×8pt 自绘，DropDownMenuView.swift L14-48）。
 * v1.6.7 曾统一为 Icons.Default.ArrowDropDown + size(8.dp)——图标 24dp 视口整体缩到 8dp 后
 * 三角形实际仅约 2.7dp，真机几乎不可见（用户反馈 D1-D4「三角箭头没有了」），改自绘所见即所得。
 */
@Composable
private fun ChevronDown(color: Color, modifier: Modifier = Modifier) {
    Canvas(modifier = modifier.size(8.dp)) {
        val path = Path().apply {
            moveTo(0f, 0f)
            lineTo(size.width, 0f)
            lineTo(size.width / 2f, size.height)
            close()
        }
        drawPath(path = path, color = color)
    }
}
