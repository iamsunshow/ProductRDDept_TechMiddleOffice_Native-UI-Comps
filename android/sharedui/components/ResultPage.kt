// ResultPage 结果反馈（Android Compose 版，对齐 iOS ResultPageView.swift / api.json `ui.result-page`）。
//
// 组件 ID：`ui.result-page` ｜ 任务清单 #56 ｜ 操作反馈区第十件 ｜ TMO 组件库 v1.4.4
//
// 定位：整页/区域级操作结果反馈——四态图标+标题+描述+操作按钮列表。
//
// 契约 @param（与 api.json 100% 对齐）：
// - type: ResultType = ResultType.SUCCESS（四态：SUCCESS/ERROR/WARNING/INFO）
// - title: String（*必选*：结果标题）
// - description: String? = null（null=不渲染描述行）
// - actions: List<ResultAction> = emptyList()（操作按钮列表）
// - icon: @Composable? = null（null=按 type 显示默认图标）
//
// 事件回调：
// - actions[i].onClick: () -> Unit（点击对应操作按钮）
//
// 设计规格（design-spec/result-page-design-spec.html）：
// - 容器：整页或区域居中，bgPage 底
// - 图标：56dp 圆形浅色底+对应色图标，居中
// - 标题：fontLg(18) textPrimary semibold，图标下 12dp
// - 描述：fontSm(14) textSecondary，标题下 4dp，居中
// - 按钮组：描述下 24dp，水平排列居中，间距 12dp
// - 按钮：高 40dp，padding 水平 20dp，圆角 8dp（复用 AppButton）
//
// 用法：
// ```kotlin
// ResultPage(
//     type = ResultType.SUCCESS,
//     title = "提交成功",
//     description = "您的申请已提交",
//     actions = listOf(
//         ResultAction(text = "返回首页", style = ResultActionStyle.PRIMARY) { /* ... */ }
//     )
// )
// ```

package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
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
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Rect
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.unit.dp
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppFont
import com.zhiqihuayun.foundation.design.AppRadius
import com.zhiqihuayun.foundation.design.AppSpace

/** 结果类型（与 api.json ResultType 对齐）。 */
enum class ResultType {
    SUCCESS,
    ERROR,
    WARNING,
    INFO
}

/** 操作按钮样式（与 api.json ResultActionStyle 对齐）。 */
enum class ResultActionStyle {
    PRIMARY,   // 主按钮（主色填充+白字）
    GHOST,     // 次按钮（白底+主色描边+主色字）
    TEXT       // 文本按钮（无背景，纯文字链接）
}

/** 操作按钮数据模型（与 api.json ResultAction 对齐）。 */
data class ResultAction(
    val text: String,
    val style: ResultActionStyle = ResultActionStyle.PRIMARY,
    val onClick: () -> Unit
)

/**
 * 结果反馈组件。
 *
 * @param type 结果类型，默认 SUCCESS
 * @param title 结果标题（必传）
 * @param description 结果描述（可选，null=不渲染）
 * @param actions 操作按钮列表，默认空
 * @param icon 自定义图标（null=按 type 显示默认图标）
 * @param modifier 可选布局修饰符
 */
@Composable
fun ResultPage(
    type: ResultType = ResultType.SUCCESS,
    title: String,
    description: String? = null,
    actions: List<ResultAction> = emptyList(),
    icon: (@Composable () -> Unit)? = null,
    modifier: Modifier = Modifier
) {
    Column(
        modifier = modifier
            .fillMaxWidth()
            .background(AppColor.bgPage),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Top
    ) {
        // 图标（56dp 圆形浅色底+对应色图标）
        if (icon != null) {
            Box(modifier = Modifier.size(56.dp)) {
                icon()
            }
        } else {
            Box(modifier = Modifier.size(56.dp)) {
                ResultIconDrawable(type = type)
            }
        }

        // 标题（fontLg textPrimary semibold，图标下 12dp）
        Spacer(modifier = Modifier.height(12.dp))
        androidx.compose.material3.Text(
            text = title,
            fontSize = AppFont.sizeLg,
            fontWeight = androidx.compose.ui.text.font.FontWeight.SemiBold,
            color = AppColor.textPrimary
        )

        // 描述（fontSm textSecondary，标题下 4dp，居中）
        if (description != null) {
            Spacer(modifier = Modifier.height(4.dp))
            androidx.compose.material3.Text(
                text = description,
                fontSize = AppFont.sizeSm,
                color = AppColor.textSecondary
            )
        }

        // 按钮组（描述下 24dp，水平排列居中，间距 12dp）
        if (actions.isNotEmpty()) {
            Spacer(modifier = Modifier.height(24.dp))
            Row(
                horizontalArrangement = Arrangement.spacedBy(AppSpace.md),
                verticalAlignment = Alignment.CenterVertically
            ) {
                actions.forEach { action ->
                    ResultActionButton(action = action)
                }
            }
        }
    }
}

/**
 * 四态图标自绘视图（success 对勾 / error 叉 / warning 感叹号 / info 字母 i）。
 */
@Composable
private fun ResultIconDrawable(type: ResultType) {
    Canvas(modifier = Modifier.size(56.dp)) {
        val canvasSize = size
        val center = Offset(canvasSize.width / 2f, canvasSize.height / 2f)
        val radius = canvasSize.minDimension / 2f

        // 1. 圆形浅色底（type 对应色 alpha 0.1）
        val (bgColor, strokeColor) = when (type) {
            ResultType.SUCCESS -> AppColor.success.copy(alpha = 0.1f) to AppColor.success
            ResultType.ERROR -> AppColor.error.copy(alpha = 0.1f) to AppColor.error
            ResultType.WARNING -> AppColor.warning.copy(alpha = 0.1f) to AppColor.warning
            ResultType.INFO -> Color(0xFF3B82F6).copy(alpha = 0.1f) to Color(0xFF3B82F6)
        }
        drawCircle(color = bgColor, radius = radius, center = center)

        // 2. 图标自绘（占圆形直径 50%）
        // v1.4.8 修复：iconSize 应基于 canvasSize（与 iOS rect.width 一致），
        // 旧版用 radius * iconScale = canvasSize/2 * 0.5 = canvasSize/4，图标只有 iOS 的 1/2 大小
        val iconScale = 0.5f
        val iconSize = canvasSize.minDimension * iconScale
        val iconLeft = center.x - iconSize / 2
        val iconTop = center.y - iconSize / 2
        val iconW = iconSize
        val iconH = iconSize
        val strokeWidth = canvasSize.minDimension / 14f

        when (type) {
            ResultType.SUCCESS -> {
                // 对勾 ✓（两段贝塞尔）
                val path = Path().apply {
                    moveTo(iconLeft + iconW * 0.15f, iconTop + iconH * 0.55f)
                    lineTo(iconLeft + iconW * 0.42f, iconTop + iconH * 0.78f)
                    lineTo(iconLeft + iconW * 0.85f, iconTop + iconH * 0.25f)
                }
                drawPath(path, color = strokeColor, style = Stroke(width = strokeWidth))
            }
            ResultType.ERROR -> {
                // 叉 ✕（两条对角线）
                val inset = iconW * 0.15f
                val path1 = Path().apply {
                    moveTo(iconLeft + inset, iconTop + inset)
                    lineTo(iconLeft + iconW - inset, iconTop + iconH - inset)
                }
                val path2 = Path().apply {
                    moveTo(iconLeft + iconW - inset, iconTop + inset)
                    lineTo(iconLeft + inset, iconTop + iconH - inset)
                }
                drawPath(path1, color = strokeColor, style = Stroke(width = strokeWidth))
                drawPath(path2, color = strokeColor, style = Stroke(width = strokeWidth))
            }
            ResultType.WARNING -> {
                // 感叹号 !（竖线+底部圆点）
                val cx = iconLeft + iconW / 2
                val path = Path().apply {
                    moveTo(cx, iconTop + iconH * 0.15f)
                    lineTo(cx, iconTop + iconH * 0.45f)
                }
                drawPath(path, color = strokeColor, style = Stroke(width = strokeWidth))
                // 底部圆点
                val dotRadius = strokeWidth / 2
                drawCircle(
                    color = strokeColor,
                    radius = dotRadius,
                    center = Offset(cx, iconTop + iconH * 0.65f)
                )
            }
            ResultType.INFO -> {
                // 字母 i（点+竖线）
                val cx = iconLeft + iconW / 2
                // 顶部圆点（与 iOS 一致：Y=0.1 而非 0.2）
                val dotRadius = strokeWidth / 2
                drawCircle(
                    color = strokeColor,
                    radius = dotRadius,
                    center = Offset(cx, iconTop + iconH * 0.1f)
                )
                // 竖线（与 iOS 一致：0.35 → 0.9 而非 0.85）
                val path = Path().apply {
                    moveTo(cx, iconTop + iconH * 0.35f)
                    lineTo(cx, iconTop + iconH * 0.9f)
                }
                drawPath(path, color = strokeColor, style = Stroke(width = strokeWidth))
            }
        }
    }
}

/**
 * 操作按钮（按 style 渲染，复用 AppButton）。
 */
@Composable
private fun ResultActionButton(action: ResultAction) {
    when (action.style) {
        ResultActionStyle.PRIMARY -> {
            AppButton(
                text = action.text,
                onClick = action.onClick,
                style = AppButtonStyle.Primary,
                fontSize = AppFont.sizeSm,
                height = 40.dp,
                radius = AppRadius.sm
            )
        }
        ResultActionStyle.GHOST -> {
            AppButton(
                text = action.text,
                onClick = action.onClick,
                style = AppButtonStyle.Secondary,
                fontSize = AppFont.sizeSm,
                height = 40.dp,
                radius = AppRadius.sm
            )
        }
        ResultActionStyle.TEXT -> {
            androidx.compose.material3.TextButton(onClick = action.onClick) {
                androidx.compose.material3.Text(
                    text = action.text,
                    fontSize = AppFont.sizeSm,
                    color = AppColor.primary
                )
            }
        }
    }
}
