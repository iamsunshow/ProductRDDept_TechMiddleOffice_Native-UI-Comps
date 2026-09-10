// Progress 进度条组件（Compose 版，对齐 iOS ProgressView）。
//
// 展示操作当前进度的横向进度条——一条带填充色的横向轨道，填充宽度按百分比（0-100）自适应，
// 支持自定义填充色/轨道色/高度、右侧百分比文字显示、动态进度变化过渡动画。
//
// 决策（与设计规格 progress-design-spec.html 一致）：
// - P1-A percentage 0-100 clamp（coerceIn 0f..100f，UI 不溢出）
// - P2-C animated 参数开关，默认 true（animateFloatAsState tween(300) 过渡），false 瞬切
// - P3-A 百分比文字右侧外部显示（showText 开关，文字不被条遮挡）
// - P4-A 一期=基础进度/自定义颜色+高度/百分比文字/动态进度+demo 四段

package com.zhiqihuayun.sharedui.components

import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppFont
import com.zhiqihuayun.foundation.design.AppSpace
import kotlin.math.roundToInt

/**
 * 横向进度条：填充宽度按百分比(0-100)自适应，支持自定义颜色/高度/百分比文字/动画。
 *
 * @param percentage 进度百分比（0-100，越界自动 clamp）
 * @param color 进度条填充色，默认 primary 主色绿
 * @param trackColor 轨道底色，默认 gray6 灰
 * @param height 进度条高度，默认 8.dp
 * @param showText 是否显示右侧百分比文字，默认 false
 * @param textColor 百分比文字颜色，默认 textPrimary
 * @param animated 进度变化是否带过渡动画（300ms ease），默认 true
 * @param modifier 外部修饰
 */
@Composable
fun Progress(
    percentage: Float = 0f,
    color: Color = AppColor.primary,
    trackColor: Color = AppColor.gray6,
    height: Dp = 8.dp,
    showText: Boolean = false,
    textColor: Color = AppColor.textPrimary,
    animated: Boolean = true,
    modifier: Modifier = Modifier,
) {
    // P1-A 0-100 clamp。
    val clamped = percentage.coerceIn(0f, 100f)
    val ratio = clamped / 100f

    // P2-C 动画：animated=true 时用 animateFloatAsState(tween 300) 平滑过渡，false 时直接用 ratio（瞬切）。
    val animatedRatio by animateFloatAsState(
        targetValue = if (animated) ratio else ratio,
        animationSpec = tween(durationMillis = 300),
        label = "progress",
    )
    val effectiveRatio = if (animated) animatedRatio else ratio

    Row(
        modifier = modifier.fillMaxWidth(),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(AppSpace.sm),
    ) {
        // 轨道（底层灰条）+ 填充条（上层彩条）。
        // 安卓禁令：圆角用 background(shape=RoundedCornerShape)，不用 Modifier.clip()/graphicsLayer()。
        Box(
            modifier = Modifier
                .weight(1f)
                .height(height)
                .background(trackColor, RoundedCornerShape(percent = 50))
        ) {
            Box(
                modifier = Modifier
                    .fillMaxWidth(effectiveRatio)
                    .height(height)
                    .background(color, RoundedCornerShape(percent = 50))
            )
        }

        // P3-A 右侧百分比文字（showText=true 显示）。
        if (showText) {
            Text(
                text = "${clamped.roundToInt()}%",
                color = textColor,
                fontSize = AppFont.sizeSm,
                fontWeight = FontWeight.Medium,
            )
        }
    }
}
