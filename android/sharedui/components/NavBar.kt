package com.zhiqihuayun.sharedui.components

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
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.outlined.ArrowBack
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.luminance
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
 * 顶部单行头部导航条。契约：标题严格水平+垂直居中（Box 叠层，标题 fillMaxWidth 居中，
 * 返回槽/动作槽浮于上层）；onBack=null 时返回槽不渲染；
 * 右侧动作 text + 可选 color + onTap；内容行高 44dp；白底 bgCard + 行底 hairline（可关）；
 * 导航栈/inset 由宿主自理。对应 iOS：NavBar(title, onBack?, rightAction?)。
 * 版本：Native-UI-Comps ui-version v1.0.22（返回按钮改 ScreenTopBar 同款 Material ArrowBack
 * 24dp 图标 + 48dp 热区贴左，写入组件库作为通用样式；标题垂直居中修复）。
 *
 * @param title 居中标题（单行省略；Box 叠层严格屏幕居中）
 * @param onBack 返回回调（null=不显示返回槽）
 * @param rightAction 右侧文字按钮（便捷入口，null=不显示）
 * @param backgroundColor 背景色（默认 bgCard 白底）
 * @param contentColor 前景色（标题/rightAction 默认色；返回箭头按背景亮度自适应浅色底 primary/深色底白）
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
    const val backHitWidthDp = 48 // 返回热区宽（ScreenTopBar 同款 48dp 贴左，图标居中距左 24dp）
    const val backIconDp = 24 // Material ArrowBack 图标边长（ScreenTopBar 同款）
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
        // 标题层：fillMaxWidth 严格屏幕居中，不受返回槽/动作槽宽度影响；
        // align(Center) 保证单行文字在 44dp 行高内垂直居中（v1.0.22 修复固定 height 顶对齐偏上）。
        Text(
            text = title,
            color = contentColor,
            fontSize = AppFont.sizeLg,
            fontWeight = FontWeight.SemiBold,
            textAlign = TextAlign.Center,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis,
            modifier = Modifier
                .align(Alignment.Center)
                .fillMaxWidth()
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
                // 返回按钮：ScreenTopBar（更多页/家庭账单页）同款通用样式，v1.0.22 写入组件库——
                // 48dp 热区贴左 + Material ArrowBack 24dp 图标居中（图标中心距左 24dp）；
                // 颜色按背景亮度自适应：浅色底 primary 绿、深色底（如品牌绿 headerBg）白。
                val backTint =
                    if (backgroundColor.luminance() > 0.5f) AppColor.primary else Color.White
                Box(
                    modifier = Modifier
                        .width(NavBarTokens.backHitWidthDp.dp)
                        .fillMaxHeight()
                        .clickable(onClick = onBack),
                    contentAlignment = Alignment.Center,
                ) {
                    Icon(
                        imageVector = Icons.AutoMirrored.Outlined.ArrowBack,
                        contentDescription = null,
                        tint = backTint,
                        modifier = Modifier.size(NavBarTokens.backIconDp.dp),
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
