package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.RowScope
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
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
 * 顶部单行头部导航条。契约：标题居中单行省略；onBack=null 时返回槽不占位、标题严格水平居中；
 * 右侧动作 text + 可选 color + onTap；内容行高 44dp；白底 bgCard + 行底 hairline；
 * 导航栈/inset 由宿主自理。对应 iOS：NavBar(title, onBack?, rightAction?)。
 * 版本：Native-UI-Comps ui-version v1.4.0（本文件为新组件初版，随 demo 徽标 v1.0）。
 *
 * @param title 居中标题（单行省略）
 * @param onBack 返回回调（null=不显示返回槽，标题严格居中）
 * @param rightAction 右侧文字按钮（便捷入口，null=不显示）
 * @param backgroundColor 背景色（默认 bgCard 白底）
 * @param contentColor 前景色（标题/返回箭头/rightAction 默认色）
 * @param actions 右侧自定义动作槽（RowScope，优先级高于 rightAction；两者可同时使用）
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
    modifier: Modifier = Modifier,
) {
    Box(
        modifier = modifier
            .fillMaxWidth()
            .background(backgroundColor),
    ) {
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
                    Text(
                        text = "←",
                        color = contentColor,
                        fontSize = AppFont.sizeXl,
                        modifier = Modifier.padding(start = NavBarTokens.backGlyphInset),
                    )
                }
            }
            Text(
                text = title,
                color = contentColor,
                fontSize = AppFont.sizeLg,
                fontWeight = FontWeight.SemiBold,
                textAlign = TextAlign.Center,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
                modifier = Modifier
                    .weight(1f)
                    .padding(horizontal = NavBarTokens.titleSideInset),
            )
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
        // 行底 hairline
        Box(
            modifier = Modifier
                .align(Alignment.BottomCenter)
                .fillMaxWidth()
                .height(0.5.dp)
                .background(AppColor.border),
        )
    }
}
