package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.RowScope
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppFont
import com.zhiqihuayun.foundation.design.AppSpace

/**
 * NavBar 头部导航（ui.nav-bar，#17）。
 *
 * 顶部单行头部导航条。契约：标题严格水平居中（Box 叠层，标题 fillMaxWidth 居中，
 * 返回槽/动作槽浮于上层）；onBack=null 时返回槽不渲染；
 * 右侧动作 text + 可选 color + onTap；内容行高 44dp；白底 bgCard + 行底 hairline（可关）；
 * 导航栈/inset 由宿主自理。对应 iOS：NavBar(title, onBack?, rightAction?)。
 * 版本：Native-UI-Comps ui-version v1.0.21（返回字形改自绘 chevron "<"，替换文本字形 "←"）。
 *
 * @param title 居中标题（单行省略；Box 叠层严格屏幕居中）
 * @param onBack 返回回调（null=不显示返回槽）
 * @param rightAction 右侧文字按钮（便捷入口，null=不显示）
 * @param backgroundColor 背景色（默认 bgCard 白底）
 * @param contentColor 前景色（标题/返回箭头/rightAction 默认色）
 * @param actions 右侧自定义动作槽（RowScope，优先级高于 rightAction；两者可同时使用）
 * @param showDivider 是否显示底部分隔线（默认 true）
 * @param modifier 布局修饰符
 */
data class NavBarAction(
    val text: String,
    val color: Color? = null,
    val onTap: () -> Unit,
)

private object NavBarTokens {
    const val contentHeightDp = 44
    const val backHitWidthDp = 44 // 返回热区宽 ≥40dp
    val backGlyphInset = AppSpace.sm
    val sideInset = AppSpace.lg
    val titleSideInset = AppSpace.md
}

@Composable
fun NavBar(
    title: String,
    onBack: (() -> Unit)? = null,
    rightAction: NavBarAction? = null,
    backgroundColor: Color = AppColor.bgCard,
    contentColor: Color = AppColor.textPrimary,
    actions: @Composable RowScope.() -> Unit = {},
    showDivider: Boolean = true,
    modifier: Modifier = Modifier,
) {
    Box(
        modifier = modifier
            .fillMaxWidth()
            .background(backgroundColor),
    ) {
        // 标题层：fillMaxWidth 严格屏幕居中，不受返回槽/动作槽宽度影响
        Text(
            text = title,
            color = contentColor,
            fontSize = AppFont.sizeLg,
            fontWeight = FontWeight.SemiBold,
            textAlign = TextAlign.Center,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis,
            modifier = Modifier
                .fillMaxWidth()
                .height(NavBarTokens.contentHeightDp.dp)
                .padding(horizontal = NavBarTokens.titleSideInset),
        )
        // 交互层：返回槽 + 右侧动作
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .height(NavBarTokens.contentHeightDp.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            if (onBack != null) {
                Box(
                    modifier = Modifier
                        .width(NavBarTokens.backHitWidthDp.dp)
                        .fillMaxHeight()
                        .clickable(onClick = onBack),
                    contentAlignment = Alignment.CenterStart,
                ) {
                    BackChevron(
                        color = contentColor,
                        modifier = Modifier.padding(start = NavBarTokens.backGlyphInset),
                    )
                }
            }
            Spacer(modifier = Modifier.weight(1f))
            if (rightAction != null) {
                Box(
                    modifier = Modifier
                        .fillMaxHeight()
                        .clickable(onClick = rightAction.onTap),
                    contentAlignment = Alignment.Center,
                ) {
                    Text(
                        text = rightAction.text,
                        color = rightAction.color ?: contentColor,
                        fontSize = AppFont.sizeSm,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis,
                    )
                }
            }
            actions()
        }
        if (showDivider) {
            Box(
                modifier = Modifier
                    .align(Alignment.BottomCenter)
                    .fillMaxWidth()
                    .height(0.5.dp)
                    .background(AppColor.border),
            )
        }
    }
}

/**
 * 返回 chevron 矢量字形（自绘 "<"，v1.0.21 起替换文本字形 "←"）。
 *
 * 12×20dp 视口内两段圆头线：顶点 (10,1)→拐点 (2,10)→底点 (10,19)，线宽 2dp。
 * 坐标按视口比例缩放，与 iOS ChevronGlyphView 同坐标 1:1；字形几何中心=视口中心，
 * 垂直居中不依赖字体度量（文本字形的行框 ascent/descent 会导致视觉偏移）。
 */
@Composable
private fun BackChevron(color: Color, modifier: Modifier = Modifier) {
    Canvas(modifier = modifier.size(width = 12.dp, height = 20.dp)) {
        val strokePx = 2.dp.toPx()
        val top = Offset(size.width * (10f / 12f), size.height * (1f / 20f))
        val mid = Offset(size.width * (2f / 12f), size.height * (10f / 20f))
        val bottom = Offset(size.width * (10f / 12f), size.height * (19f / 20f))
        drawLine(color = color, start = top, end = mid, strokeWidth = strokePx, cap = StrokeCap.Round)
        drawLine(color = color, start = mid, end = bottom, strokeWidth = strokePx, cap = StrokeCap.Round)
    }
}
