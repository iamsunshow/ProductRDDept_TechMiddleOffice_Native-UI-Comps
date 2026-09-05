package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
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
 * Address 地址选择（ui.address）——省市区地域选择视图（数据录入区首批三件）。
 * 数据驱动：宿主传入 省→市→区 嵌套 region 数据（RegionOption），内部按"顶部层级 tab + 当前层列表"逐级联动；
 * 选中末级（无 children 节点）即回调 onChange(AddressResult)。组件为内嵌内容视图：不含弹层/遮罩（宿主自理，
 * 可装入自定义弹层或页面卡片）；列表高度由宿主 modifier 约束。半受控：result 外部传入可按 codes 回显定位。
 *
 * 规格：docs/数据与产物/design-spec/address-design-spec.html（门禁 A review-address-A.md，P1–P4 全 A）。
 * 基线：组件库 v1.4.0（2026-09-05，未过 C2/D 不升版）。
 *
 * 设计锚点（Token 注释锚定）：
 * - 层级 tab 高 44dp、文字 Sm=14，激活=primary Semibold + 底部 2dp 主色指示线（同 Tabs 语义）
 * - 列表行高 44dp、文字 Md=16，默认 textSecondary、选中 primary Semibold；有子级行右侧"›"指示符
 * - 禁用节点 = textSecondary @ 40% 透明度，不可点
 */
data class RegionOption(
    val value: String,
    val text: String,
    val children: List<RegionOption>? = null,
    val disabled: Boolean = false
)

/** Address 选择结果：codes=各级 value；names=各级中文名；text=names 空格拼接（如"广东省 深圳市 南山区"）。 */
data class AddressResult(
    val codes: List<String>,
    val names: List<String>,
    val text: String
) {
    companion object {
        fun build(path: List<RegionOption>): AddressResult = AddressResult(
            codes = path.map { it.value },
            names = path.map { it.text },
            text = path.joinToString(" ") { it.text }
        )
    }
}

/** 按 codes 从根树逐层匹配出一串节点（匹配失败即截断；末级无 children=叶子完成）。 */
private fun matchRegionPath(root: List<RegionOption>, codes: List<String>): List<RegionOption> {
    var level = root
    val matched = mutableListOf<RegionOption>()
    for (code in codes) {
        val node = level.firstOrNull { it.value == code } ?: break
        matched.add(node)
        if (node.children.isNullOrEmpty()) break
        level = node.children
    }
    return matched
}

/** 由完整选中链切出"展开层链路 path"：path 中每个节点都有 children；叶子不入 path。 */
private fun pathOf(chain: List<RegionOption>): List<RegionOption> {
    if (chain.isEmpty()) return emptyList()
    val leaf = chain.last()
    return if (leaf.children.isNullOrEmpty()) chain.dropLast(1) else chain
}

@Composable
fun Address(
    options: List<RegionOption>,
    result: AddressResult? = null,
    onChange: (AddressResult) -> Unit,
    modifier: Modifier = Modifier
) {
    // path=已展开层链（其节点必有 children）；chosen=已选中完整链（=path + 当前层已选子行，选中叶子时末项为叶）。
    var path by remember { mutableStateOf<List<RegionOption>>(emptyList()) }
    var chosen by remember { mutableStateOf<List<RegionOption>>(emptyList()) }

    // 半受控回显：result codes 变化（初始预填 / 外部驱动）时按 codes 重定位 path/chosen。
    val resultKey = result?.codes
    LaunchedEffect(resultKey) {
        val matched = if (result != null) matchRegionPath(options, result.codes) else emptyList()
        chosen = matched
        path = pathOf(matched)
    }

    val list = if (path.isEmpty()) options else path.last().children.orEmpty()
    val isDone = chosen.size == path.size + 1 // 当前层已有选中行（含完成叶）

    // —— 层级 tab 栏（高 44dp）：tab=已选各级 text，未完成时末位补"请选择"占位（不可点仅指示当前层）——
    val tabTexts = if (isDone) chosen.map { it.text } else path.map { it.text } + listOf("请选择")
    val activeIndex = tabTexts.lastIndex

    Column(modifier) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .height(44.dp)
                .background(AppColor.bgCard),
            verticalAlignment = Alignment.Bottom
        ) {
            tabTexts.forEachIndexed { index, text ->
                val active = index == activeIndex
                // 等分 tab（spec .ad-tab flex:1，同 Tabs #20 指示线语义）：激活=primary Semibold + 整格 2dp 指示线
                Column(
                    modifier = Modifier
                        .weight(1f)
                        .height(44.dp)
                        .clickable(enabled = !isDone && index < path.size) {
                            // 回退：点已选层 tab → path/chosen 截断到该层之前，重选该层
                            path = path.take(index)
                            chosen = path.take(index)
                        }
                ) {
                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(42.dp),
                        contentAlignment = Alignment.Center
                    ) {
                        Text(
                            text = text,
                            modifier = Modifier.padding(horizontal = 8.dp),
                            fontSize = AppFont.sizeSm,
                            fontWeight = if (active) FontWeight.SemiBold else FontWeight.Normal,
                            color = if (active) AppColor.primary else AppColor.textSecondary,
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis
                        )
                    }
                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(2.dp)
                            .background(if (active) AppColor.primary else AppColor.bgCard)
                    )
                }
            }
        }

        // —— 分隔线 ——
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(1.dp)
                .background(AppColor.border)
        )

        // —— 当前层列表（滚动高度由宿主约束）——
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .verticalScroll(rememberScrollState()),
            verticalArrangement = Arrangement.Top
        ) {
            list.forEach { node ->
                val rowSelected = isDone && chosen.lastOrNull()?.value == node.value
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(44.dp)
                        .clickable(enabled = !node.disabled) {
                            val newChosen = path + node
                            chosen = newChosen
                            if (node.children.isNullOrEmpty()) {
                                // 叶子=选择完成：回调完整结果（列表保持当前层并高亮该行）
                                onChange(AddressResult.build(newChosen))
                            } else {
                                // 有子级=进入下一层
                                path = newChosen
                            }
                        }
                        .padding(horizontal = 16.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = node.text,
                        modifier = Modifier.weight(1f),
                        fontSize = AppFont.sizeMd,
                        maxLines = 1,
                        color = when {
                            node.disabled -> AppColor.textSecondary.copy(alpha = 0.4f)
                            rowSelected -> AppColor.primary
                            else -> AppColor.textSecondary
                        },
                        fontWeight = if (rowSelected) FontWeight.SemiBold else FontWeight.Normal
                    )
                    if (rowSelected) {
                        Text(
                            text = "✓",
                            fontSize = AppFont.sizeSm,
                            color = AppColor.primary
                        )
                    } else if (!node.disabled && !node.children.isNullOrEmpty()) {
                        Text(
                            text = "›",
                            fontSize = AppFont.sizeMd,
                            color = AppColor.textSecondary
                        )
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
