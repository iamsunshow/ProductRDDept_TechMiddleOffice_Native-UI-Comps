// Tour 引导组件（Compose 版，对齐 iOS TourView）。
//
// 步骤式引导浮层：全屏遮罩 + 高亮目标区域 + 提示卡片。
// 支持跳过、上一步/下一步、完成。

package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppFont
import com.zhiqihuayun.foundation.design.AppRadius
import com.zhiqihuayun.foundation.design.AppSpace

/** 引导步骤。 */
data class TourStep(
    val title: String,
    val description: String,
)

/**
 * Tour 引导组件。
 *
 * @param steps 步骤列表
 * @param current 当前步骤索引
 * @param visible 是否显示
 * @param onChange 步骤切换回调
 * @param onFinish 完成/跳过回调
 * @param maskColor 遮罩颜色
 * @param showSkip 是否显示跳过按钮
 */
@Composable
fun Tour(
    steps: List<TourStep>,
    current: Int,
    visible: Boolean,
    onChange: (Int) -> Unit,
    onFinish: () -> Unit,
    maskColor: Color = Color.Black.copy(alpha = 0.7f),
    showSkip: Boolean = true,
) {
    if (!visible || steps.isEmpty()) return

    val step = steps.getOrElse(current) { return }
    val isLast = current >= steps.size - 1

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(maskColor)
            .clickable { /* 拦截点击 */ },
        contentAlignment = Alignment.Center,
    ) {
        // 提示卡片
        Column(
            modifier = Modifier
                .padding(horizontal = AppSpace.xl)
                .clip(RoundedCornerShape(AppRadius.lg))
                .background(AppColor.bgCard)
                .padding(AppSpace.lg),
        ) {
            // 步骤指示
            Text(
                text = "${current + 1} / ${steps.size}",
                color = AppColor.gray25,
                fontSize = AppFont.sizeXs,
            )
            Spacer(modifier = Modifier.height(AppSpace.sm))

            // 标题
            Text(
                text = step.title,
                color = AppColor.textPrimary,
                fontSize = AppFont.sizeMd,
                fontWeight = FontWeight.SemiBold,
            )
            Spacer(modifier = Modifier.height(AppSpace.xs))

            // 描述
            Text(
                text = step.description,
                color = AppColor.textSecondary,
                fontSize = AppFont.sizeSm,
            )
            Spacer(modifier = Modifier.height(AppSpace.lg))

            // 按钮区
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically,
            ) {
                // 跳过
                if (showSkip) {
                    Text(
                        text = "跳过",
                        color = AppColor.gray25,
                        fontSize = AppFont.sizeSm,
                        modifier = Modifier.clickable { onFinish() },
                    )
                } else {
                    Spacer(modifier = Modifier.weight(1f))
                }

                Row(horizontalArrangement = Arrangement.spacedBy(AppSpace.sm)) {
                    // 上一步
                    if (current > 0) {
                        TourButton(text = "上一步", onClick = { onChange(current - 1) })
                    }
                    // 下一步 / 完成
                    TourButton(
                        text = if (isLast) "完成" else "下一步",
                        primary = true,
                        onClick = {
                            if (isLast) onFinish() else onChange(current + 1)
                        },
                    )
                }
            }
        }
    }
}

/** Tour 按钮。 */
@Composable
private fun TourButton(text: String, primary: Boolean = false, onClick: () -> Unit) {
    val bgColor = if (primary) AppColor.primary else AppColor.bgPage
    val textColor = if (primary) Color.White else AppColor.textPrimary
    Box(
        modifier = Modifier
            .clip(RoundedCornerShape(AppRadius.sm))
            .background(bgColor)
            .clickable { onClick() }
            .padding(horizontal = AppSpace.md, vertical = AppSpace.sm),
        contentAlignment = Alignment.Center,
    ) {
        Text(
            text = text,
            color = textColor,
            fontSize = AppFont.sizeSm,
            fontWeight = FontWeight.Medium,
        )
    }
}
