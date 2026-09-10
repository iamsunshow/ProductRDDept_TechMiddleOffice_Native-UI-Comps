// Indicator 指示器组件（Compose 版，对齐 iOS IndicatorView）。
//
// 页面位置指示器——圆点/数字形态标记当前页与总页数，用于轮播、引导页、分步表单等场景的位置感知。
// current/total 驱动高亮位置，direction 控制横向/竖向排布，showNumber 切数字形态，
// block 开长条选中态，color/activeColor/size/gap 自定义视觉。
//
// 决策（与设计规格 indicator-design-spec.html 一致）：
// - P1-A showNumber 布尔切换圆点/数字两形态
// - P2-C block 开关同时支持色变+长条（false=色变，true=长条）
// - P3-B 横向+竖向 direction 参数
// - P4-A 一期=圆点/数字+横向/竖向+block长条+自定义色/大小/间距+demo四段

package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.zhiqihuayun.foundation.design.AppColor

/**
 * 指示器排布方向。
 */
enum class IndicatorDirection {
    horizontal,
    vertical
}

/**
 * 指示器：圆点/数字形态标记当前页与总页数。
 *
 * @param current 当前页索引（从 0 开始），高亮第 current 个点
 * @param total 总页数（渲染 total 个点）；total≤0 不渲染
 * @param direction 排布方向：horizontal 横向 / vertical 竖向
 * @param showNumber 数字形态：true 显示「current+1/total」胶囊，false 显示圆点序列
 * @param block 选中态长条形态：true 选中点变长条，false 选中点仅色变
 * @param size 指示点直径/边长（dp），数字形态忽略
 * @param gap 指示点间距（dp），数字形态忽略
 * @param color 未选中点颜色
 * @param activeColor 选中点颜色
 * @param modifier 外部修饰
 */
@Composable
fun Indicator(
    current: Int = 0,
    total: Int = 0,
    direction: IndicatorDirection = IndicatorDirection.horizontal,
    showNumber: Boolean = false,
    block: Boolean = false,
    size: Float = 6f,
    gap: Float = 8f,
    color: Color = AppColor.gray15,
    activeColor: Color = AppColor.primary,
    modifier: Modifier = Modifier,
) {
    // total≤0 不渲染。
    if (total <= 0) return

    if (showNumber) {
        // 数字形态：显示「current+1/total」胶囊。
        val safeCurrent = current.coerceIn(0, total - 1)
        Box(
            modifier = modifier
                .background(activeColor, RoundedCornerShape(50))
                .padding(horizontal = 10.dp, vertical = 2.dp),
            contentAlignment = Alignment.Center
        ) {
            Text(
                text = "${safeCurrent + 1} / $total",
                color = AppColor.bgCard,
                fontSize = 12.sp,
                fontWeight = FontWeight.SemiBold
            )
        }
        return
    }

    // 圆点形态：按 direction 选 Row/Column 排布。
    val safeCurrent = current.coerceIn(0, total - 1)
    val arrangement = if (direction == IndicatorDirection.horizontal) {
        Arrangement.Center
    } else {
        Arrangement.Center
    }

    // 安卓禁令：圆角裁切用 background(shape=圆角)，不用 Modifier.clip()。
    if (direction == IndicatorDirection.horizontal) {
        Row(
            modifier = modifier,
            horizontalArrangement = arrangement,
            verticalAlignment = Alignment.CenterVertically
        ) {
            for (index in 0 until total) {
                IndicatorDot(
                    isActive = index == safeCurrent,
                    block = block,
                    size = size,
                    color = color,
                    activeColor = activeColor
                )
                if (index < total - 1) {
                    // 间距用不可见 Spacer 占位（gap 在 Arrangement.spacedBy 无法直接用于 Row+条件）。
                    androidx.compose.foundation.layout.Spacer(
                        modifier = Modifier.size(gap.dp)
                    )
                }
            }
        }
    } else {
        Column(
            modifier = modifier,
            verticalArrangement = arrangement,
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            for (index in 0 until total) {
                IndicatorDot(
                    isActive = index == safeCurrent,
                    block = block,
                    size = size,
                    color = color,
                    activeColor = activeColor
                )
                if (index < total - 1) {
                    androidx.compose.foundation.layout.Spacer(
                        modifier = Modifier.size(gap.dp)
                    )
                }
            }
        }
    }
}

/**
 * 单个指示点：圆点或长条。
 */
@Composable
private fun IndicatorDot(
    isActive: Boolean,
    block: Boolean,
    size: Float,
    color: Color,
    activeColor: Color,
) {
    if (isActive && block) {
        // 长条选中态：宽=size*2.5，圆角=size/3。
        Box(
            modifier = Modifier
                .width((size * 2.5f).dp)
                .height(size.dp)
                .background(activeColor, RoundedCornerShape(size / 3f))
        )
    } else {
        // 圆点：size×size，全圆角。
        Box(
            modifier = Modifier
                .size(size.dp)
                .background(if (isActive) activeColor else color, CircleShape)
        )
    }
}
