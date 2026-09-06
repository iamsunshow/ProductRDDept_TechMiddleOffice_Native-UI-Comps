package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.background
import androidx.compose.foundation.gestures.snapping.SnapPosition
import androidx.compose.foundation.gestures.snapping.rememberSnapFlingBehavior
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.derivedStateOf
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppFont
import kotlinx.coroutines.launch
import kotlin.math.abs

/**
 * Picker 选择器（ui.picker，任务清单 #33）——单列滚轮选择器内容块（数据录入区）。
 * 组件=「工具栏（高 44：取消/标题/确定）+ 单列滚轮可视区（高 220=5 行×44）」的完整选择内容块：
 * 无遮罩无自绘浮层，宿主自行承载（页面卡片内嵌 / 系统 sheet 弹层承载均可）。受控 value 决定初始
 * 滚停与外部回滚定位；用户滚轮改选后点「确定」=onChange(选中 value) 提交、点「取消」=不回调并
 * 滚回 value 行；选项级 disabled=行灰 40% 且滚掠不可停靠（停靠自动吸附最近可用行）；组件级
 * disabled=整体 40% 灰不可滚。与 Cascader（级联）/ Menu（平铺下拉）/ date-picker 系（日期专用）
 * / 业务 CategoryPicker（记账分类网格）划界；picker-view #34=二期无工具栏纯多列滚轮基础件。
 *
 * 规格：docs/数据与产物/design-spec/picker-design-spec.html（门禁 A P1–P4 全 A，2026-09-06）。
 * 基线：组件库 v1.4.0（2026-09-06，未过 C2/D 不升版）。
 *
 * 设计锚点（Token 注释锚定）：工具栏高 44dp——取消 Xs=14 次色 / 标题 Md=16 Semibold / 确定
 * Md=16 primary；滚轮可视 220dp=5 行×44dp、选中带上下 hairline 夹线、行文字 Md=16 居中；
 * 选中行=primary Semibold、其余=textPrimary；滚轮上下 70dp 线性渐变遮罩模拟纵向衰减
 * （与 iOS UIPickerView 原生渐隐的视觉差异表内放行）；滚掠吸附=SnapPosition.Center
 * 停靠行中心（foundation 1.7.6 以嵌套 object 提供，无 CenteredSnapPosition 类）；禁用=textPrimary
 * @35%、组件级 disabled 整体 40%。
 */
data class PickerOption(
    val value: String,
    val text: String,
    val disabled: Boolean = false
)

/** 从 value 行向两侧找最近启用行（两侧同距时优先下侧），用于禁用行掠行校正/取消回滚。 */
private fun nearestEnabledIndex(options: List<PickerOption>, from: Int): Int? {
    if (options.isEmpty()) return null
    var i = from
    while (i >= 0) {
        if (!options[i].disabled) return i
        i -= 1
    }
    i = from + 1
    while (i < options.size) {
        if (!options[i].disabled) return i
        i += 1
    }
    return null
}

@OptIn(ExperimentalFoundationApi::class)
@Composable
fun Picker(
    options: List<PickerOption>,
    value: String,
    onChange: (String) -> Unit,
    onCancel: (() -> Unit)? = null,
    disabled: Boolean = false,
    title: String = "请选择",
    cancelText: String = "取消",
    confirmText: String = "确定",
    modifier: Modifier = Modifier
) {
    // 可视区高 220=5 行×44（与 iOS PickerView Metrics.wheelHeight 同数值不同单位）
    val wheelHeight = 220.dp
    val rowHeightPx = 44

    // 首项需可停在中心带：上 contentPadding=(视口-行)/2=88、下 padding 补 132 使末项也可滚达中心
    val listState = rememberLazyListState()
    val scope = rememberCoroutineScope()

    // 当前可视中心行（=滚轮停靠候选），由视口几何实时推导
    val selectedIndex by remember {
        derivedStateOf {
            val info = listState.layoutInfo
            if (info.visibleItemsInfo.isEmpty()) return@derivedStateOf 0
            val viewportCenter = (info.viewportStartOffset + info.viewportEndOffset).toFloat() / 2f
            info.visibleItemsInfo.minByOrNull {
                abs(it.offset + it.size / 2f - viewportCenter)
            }?.index ?: 0
        }
    }

    // 禁用行掠行校正：停靠禁用行立即吸附到最近启用行（结果=禁用行不可停靠）
    LaunchedEffect(selectedIndex, options) {
        val opt = options.getOrNull(selectedIndex) ?: return@LaunchedEffect
        if (opt.disabled) {
            nearestEnabledIndex(options, selectedIndex)?.let { listState.animateScrollToItem(it) }
        }
    }

    // 受控 value：初始/外部变更滚轮 animate 定位到 value 行（滚动不触发 onChange）
    LaunchedEffect(value, options) {
        val vi = options.indexOfFirst { it.value == value }
        val fallback = options.indexOfFirst { !it.disabled }
        val target = if (vi >= 0) vi else if (fallback >= 0) fallback else 0
        if (target != listState.firstVisibleItemIndex || target != selectedIndex) {
            listState.animateScrollToItem(target)
        }
    }

    fun scrollToCommitted() {
        val vi = options.indexOfFirst { it.value == value }
        val fallback = options.indexOfFirst { !it.disabled }
        val target = if (vi >= 0) vi else if (fallback >= 0) fallback else 0
        scope.launch { listState.animateScrollToItem(target) }
    }

    fun commit() {
        val opt = options.getOrNull(selectedIndex) ?: return
        if (!opt.disabled) onChange(opt.value)
    }

    fun cancel() {
        scrollToCommitted()
        onCancel?.invoke()
    }

    Column(
        modifier = modifier
            .fillMaxWidth()
            .alpha(if (disabled) 0.4f else 1f)
            .background(AppColor.bgCard)
            .height(wheelHeight + 44.dp)
    ) {
        // ---- 工具栏（高 44：取消 / 标题 / 确定，下 hairline 与滚轮分隔）----
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .height(44.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            TextButton(
                onClick = { if (!disabled) cancel() },
                enabled = !disabled,
                contentPadding = PaddingValues(horizontal = 16.dp, vertical = 0.dp),
                modifier = Modifier.height(44.dp)
            ) {
                Text(cancelText, fontSize = AppFont.sizeSm, color = AppColor.textSecondary)
            }
            Text(
                text = title,
                fontSize = AppFont.sizeMd,
                fontWeight = FontWeight.SemiBold,
                color = AppColor.textPrimary,
                textAlign = TextAlign.Center,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
                modifier = Modifier
                    .weight(1f)
                    .padding(horizontal = 4.dp)
            )
            TextButton(
                onClick = { if (!disabled) commit() },
                enabled = !disabled,
                contentPadding = PaddingValues(horizontal = 16.dp, vertical = 0.dp),
                modifier = Modifier.height(44.dp)
            ) {
                Text(confirmText, fontSize = AppFont.sizeMd, color = AppColor.primary)
            }
        }
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(1.dp)
                .background(AppColor.border)
        )

        // ---- 滚轮可视区（220dp，5 行×44；选中带=上下 hairline 夹线）----
        Box(modifier = Modifier.fillMaxWidth().height(wheelHeight)) {
            LazyColumn(
                state = listState,
                contentPadding = PaddingValues(top = 88.dp, bottom = 132.dp),
                flingBehavior = rememberSnapFlingBehavior(
                    lazyListState = listState,
                    snapPosition = SnapPosition.Center
                ),
                userScrollEnabled = !disabled,
                modifier = Modifier.fillMaxSize()
            ) {
                items(count = options.size, key = { options[it].value }) { index ->
                    val opt = options[index]
                    val isSelected = index == selectedIndex
                    val rowColor = when {
                        opt.disabled -> AppColor.textPrimary.copy(alpha = 0.35f)
                        isSelected -> AppColor.primary
                        else -> AppColor.textPrimary
                    }
                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(rowHeightPx.dp),
                        contentAlignment = Alignment.Center
                    ) {
                        Text(
                            text = opt.text,
                            fontSize = AppFont.sizeMd,
                            fontWeight = if (isSelected) FontWeight.SemiBold else FontWeight.Normal,
                            color = rowColor,
                            textAlign = TextAlign.Center,
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis
                        )
                    }
                }
            }

            // 上下渐隐遮罩（顶部/底部各 70dp 线性过渡，模拟滚轮纵向衰减=表内放行的内层表现）
            Box(
                modifier = Modifier
                    .align(Alignment.TopCenter)
                    .fillMaxWidth()
                    .height(70.dp)
                    .background(Brush.verticalGradient(listOf(AppColor.bgCard, Color.Transparent)))
            )
            Box(
                modifier = Modifier
                    .align(Alignment.BottomCenter)
                    .fillMaxWidth()
                    .height(70.dp)
                    .background(
                        Brush.verticalGradient(listOf(Color.Transparent, AppColor.bgCard))
                    )
            )
            // 选中带夹线：中心行上下各 1dp hairline（Top=88 与内容首 padding 重合=中心行上缘）
            Box(
                modifier = Modifier
                    .align(Alignment.TopCenter)
                    .padding(top = 87.5.dp)
                    .fillMaxWidth()
                    .height(1.dp)
                    .background(AppColor.border)
            )
            Box(
                modifier = Modifier
                    .align(Alignment.BottomCenter)
                    .padding(bottom = 87.5.dp)
                    .fillMaxWidth()
                    .height(1.dp)
                    .background(AppColor.border)
            )
        }
    }
    // 整件 40% 灰由外层 disabled alpha 表达（不可滚已由 userScrollEnabled 关断）
}
