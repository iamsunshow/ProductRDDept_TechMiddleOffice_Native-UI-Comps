package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
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
 * Cascader 级联选择（ui.cascader）——任意层级树形数据的通用级联选择视图（数据录入区首批三件）。
 * 数据驱动：宿主传入任意深度嵌套树（CascaderOption），内部按"顶部路径 tab + 当前层列表"逐级联动；
 * 选中叶子（无 children 节点）即回调 onChange(CascaderResult)。组件为内嵌内容视图：不含弹层/遮罩（宿主自理）；
 * 列表高度由宿主 modifier 约束。半受控：result 外部传入可按 values 回显定位。
 * 与 Address 划界：本组件=通用任意树（品类/组织等），结果=选中路径；地域固定三级用 ui.address。
 *
 * 规格：docs/数据与产物/design-spec/cascader-design-spec.html（门禁 A review-cascader-A.md，P1–P4 全 A）。
 * 基线：组件库 v1.4.0（2026-09-05，未过 C2/D 不升版）。
 *
 * 设计锚点（Token 注释锚定）：路径 tab 高 44dp/Sm=14；列表行高 44dp/Md=16；激活 primary+2dp 指示线；
 * 禁用节点 textSecondary @ 40% 不可点。
 */
data class CascaderOption(
    val value: String,
    val text: String,
    val children: List<CascaderOption>? = null,
    val disabled: Boolean = false
)

/** Cascader 选择结果：values=各级 value；texts=各级中文名；text=texts 以 "/" 拼接（如"生活/餐饮/正餐"）。 */
data class CascaderResult(
    val values: List<String>,
    val texts: List<String>,
    val text: String
) {
    companion object {
        fun build(path: List<CascaderOption>): CascaderResult = CascaderResult(
            values = path.map { it.value },
            texts = path.map { it.text },
            text = path.joinToString("/") { it.text }
        )
    }
}

/** 按 values 从根树逐层匹配出一串节点（匹配失败即截断；末级无 children=叶子完成）。 */
private fun matchCascaderPath(root: List<CascaderOption>, values: List<String>): List<CascaderOption> {
    var level = root
    val matched = mutableListOf<CascaderOption>()
    for (code in values) {
        val node = level.firstOrNull { it.value == code } ?: break
        matched.add(node)
        if (node.children.isNullOrEmpty()) break
        level = node.children
    }
    return matched
}

/** 由完整选中链切出"展开层链路 path"：path 中每个节点都有 children；叶子不入 path。 */
private fun pathOf(chain: List<CascaderOption>): List<CascaderOption> {
    if (chain.isEmpty()) return emptyList()
    val leaf = chain.last()
    return if (leaf.children.isNullOrEmpty()) chain.dropLast(1) else chain
}

@Composable
fun Cascader(
    options: List<CascaderOption>,
    result: CascaderResult? = null,
    onChange: (CascaderResult) -> Unit,
    modifier: Modifier = Modifier
) {
    var path by remember { mutableStateOf<List<CascaderOption>>(emptyList()) }
    var chosen by remember { mutableStateOf<List<CascaderOption>>(emptyList()) }

    val resultKey = result?.values
    LaunchedEffect(resultKey) {
        val matched = if (result != null) matchCascaderPath(options, result.values) else emptyList()
        chosen = matched
        path = pathOf(matched)
    }

    val list = if (path.isEmpty()) options else path.last().children.orEmpty()
    val isDone = chosen.size == path.size + 1

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
                // 等分 tab（spec flex:1，同 Tabs #20 指示线语义）：激活=primary Semibold + 整格 2dp 指示线
                Column(
                    modifier = Modifier
                        .weight(1f)
                        .height(44.dp)
                        .clickable(enabled = !isDone && index < path.size) {
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

        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(1.dp)
                .background(AppColor.border)
        )

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
                                onChange(CascaderResult.build(newChosen))
                            } else {
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
