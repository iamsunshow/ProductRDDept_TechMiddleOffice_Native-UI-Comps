package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppFont

/**
 * Menu 菜单（ui.menu，任务清单 #31）——嵌入式下拉单选菜单（数据录入区）。
 * 数据驱动：宿主传入 ≤4 列 MenuColumn（key/title/options），菜单栏等分排布；点列=栏下内联展开该列
 * options 单选面板（其余列自动收起），点选选项=onChange(columnKey, optionValue) 回调并收起；
 * 重复点当前展开列=收起（幂等）。半受控 selectedValues（列 key → option value）：外部传入驱动回显
 * （高亮+标题小字），nil/缺列=该列取 options 首个启用项。组件为内嵌内容视图：无遮罩/悬浮浮层
 * （Popup 悬浮版二期）；高度随展开态变化（Column 状态驱动下方内容推挤=嵌入式语义）。
 * 与 Cascader（多级级联）/ Picker（内容常驻选择/弹层）/ OptionPicker（Modal sheet）划界。
 *
 * 规格：docs/数据与产物/design-spec/menu-design-spec.html（门禁 A P1–P4 全 A）。
 * 基线：组件库 v1.4.0（2026-09-06，未过 C2/D 不升版）。
 *
 * 设计锚点（Token 注释锚定）：菜单栏高 44dp/Md=16 标题（激活列=primary Semibold）+ Xs=12 当前值
 * 次色小字（≤列 52% 单行省略）+ ▾/▴ 指示（激活主色、展开上翻）；面板行高 44dp、max 高 220dp
 * （=5 行，超出内部滚动）、行间 hairline；选中行=primary Semibold + ✓；禁用=textSecondary @ 40%。
 */
data class MenuOption(
    val value: String,
    val text: String,
    val disabled: Boolean = false
)

data class MenuColumn(
    val key: String,
    val title: String,
    val options: List<MenuOption>,
    val disabled: Boolean = false
)

/** 解析一列当前选中 option 的 value：外部命中优先；无匹配/缺省=该列 options 首个启用项。 */
private fun resolveSelectedValue(column: MenuColumn, external: Map<String, String>?): String? {
    val explicit = external?.get(column.key)
    if (explicit != null && column.options.any { it.value == explicit }) return explicit
    return column.options.firstOrNull { !it.disabled }?.value
}

/** 全列解析（与 iOS MenuView.applyExternalSelection 同构）：外部 map 驱动，未命中/缺省回落首启用项。 */
private fun resolveSelection(columns: List<MenuColumn>, external: Map<String, String>?): Map<String, String> {
    val merged = mutableMapOf<String, String>()
    columns.forEach { column ->
        resolveSelectedValue(column, external)?.let { merged[column.key] = it }
    }
    return merged
}

@Composable
fun Menu(
    columns: List<MenuColumn>,
    selectedValues: Map<String, String>? = null,
    onChange: (String, String) -> Unit,
    modifier: Modifier = Modifier
) {
    // 半受控选中（列 key → option value）：内部点选自持；外部 selectedValues 变化按规则重算回显
    var selected by remember { mutableStateOf(resolveSelection(columns, selectedValues)) }
    LaunchedEffect(columns, selectedValues) {
        selected = resolveSelection(columns, selectedValues)
    }
    // 当前展开列 key（内部自管理，同时仅一列展开；null=全部收起）
    var activeKey by remember { mutableStateOf<String?>(null) }

    val activeColumn = columns.firstOrNull { it.key == activeKey }

    Column(modifier) {
        // ---- 菜单栏（等分 ≤4 列，高 44）----
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .height(44.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            columns.forEach { column ->
                val isActive = activeKey == column.key
                val dimmed = column.disabled
                Row(
                    modifier = Modifier
                        .weight(1f)
                        .height(44.dp)
                        .background(AppColor.bgCard)
                        .clickable(enabled = !dimmed) {
                            activeKey = if (isActive) null else column.key
                        },
                    horizontalArrangement = Arrangement.Center,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    val current = selected[column.key]?.let { value ->
                        column.options.firstOrNull { it.value == value }?.text
                    }
                    Text(
                        text = if (current.isNullOrEmpty()) column.title else column.title,
                        fontSize = AppFont.sizeMd,
                        fontWeight = if (isActive && !dimmed) FontWeight.SemiBold else FontWeight.Normal,
                        color = when {
                            dimmed -> AppColor.textSecondary.copy(alpha = 0.4f)
                            isActive -> AppColor.primary
                            else -> AppColor.textPrimary
                        },
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )
                    if (!current.isNullOrEmpty()) {
                        Text(
                            text = current,
                            modifier = Modifier.padding(start = 3.dp),
                            fontSize = AppFont.sizeXs,
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis,
                            color = if (dimmed) AppColor.textSecondary.copy(alpha = 0.4f) else AppColor.textSecondary
                        )
                    }
                    Text(
                        text = when {
                            dimmed -> "▾"
                            isActive -> "▴"
                            else -> "▾"
                        },
                        modifier = Modifier.padding(start = 3.dp),
                        fontSize = AppFont.sizeXs,
                        color = when {
                            dimmed -> AppColor.textSecondary.copy(alpha = 0.4f)
                            isActive -> AppColor.primary
                            else -> AppColor.textSecondary
                        }
                    )
                }
            }
        }
        // 菜单栏下 hairline（iOS 1/scale pt 与 Android 0.5dp 表内放行）
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(0.5.dp)
                .background(AppColor.border)
        )

        // ---- 展开面板（内联，仅一列；行高 44、max 220 内部滚动）----
        if (activeColumn != null) {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .heightIn(max = 220.dp)
                    .verticalScroll(rememberScrollState())
                    .background(AppColor.bgCard)
            ) {
                activeColumn.options.forEach { option ->
                    val isSelected = selected[activeColumn.key] == option.value
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(44.dp)
                            .clickable(enabled = !option.disabled) {
                                selected = selected + (activeColumn.key to option.value)
                                onChange(activeColumn.key, option.value)
                                activeKey = null
                            }
                            .padding(start = 16.dp, end = 16.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Text(
                            text = option.text,
                            modifier = Modifier.weight(1f),
                            fontSize = AppFont.sizeMd,
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis,
                            color = when {
                                option.disabled -> AppColor.textSecondary.copy(alpha = 0.4f)
                                isSelected -> AppColor.primary
                                else -> AppColor.textPrimary
                            },
                            fontWeight = if (isSelected && !option.disabled) FontWeight.SemiBold else FontWeight.Normal
                        )
                        if (isSelected) {
                            Text(text = "✓", fontSize = AppFont.sizeSm, color = AppColor.primary)
                        }
                    }
                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(start = 16.dp)
                            .height(0.5.dp)
                            .background(AppColor.border)
                    )
                }
            }
        }
    }
}
