package com.zhiqihuayun.foundation.design

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.text.ClickableText
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Check
import androidx.compose.material3.Icon
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.SpanStyle
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.buildAnnotatedString
import androidx.compose.ui.text.withStyle
import androidx.compose.ui.unit.TextUnit
import androidx.compose.ui.unit.dp

/** 协议链接：显示名 + 点击回调。 */
data class AgreementLink(
    val name: String,
    val onClick: () -> Unit
)

/**
 * 协议勾选基础组件：圆形勾选框 + 协议文案，整行可点。
 *
 * 作为中台基础组件统一登录/注册/注销等页面的「已阅读并同意」交互与视觉。
 * - 勾选框为圆形：未选中为描边圆，选中为实心主色圆 + 白色对勾
 * - 视觉尺寸与最小字号文字等高（12dp），间距半个字宽（6dp）
 * - 协议名以主色高亮显示，点击协议名触发对应 [AgreementLink.onClick]，
 *   点击其余区域切换勾选状态
 *
 * @param checked 是否已勾选
 * @param onToggle 勾选状态切换回调（点击勾选框或文案空白区域触发）
 * @param modifier 可选布局修饰符
 * @param fontSize 文案字号，默认与登录页一致
 * @param prefix 前置文案（如「已阅读并同意」）
 * @param links 协议链接列表（名称可自带连接词，如「和《隐私协议》」）
 * @param textColor 普通文案颜色
 * @param linkColor 协议链接高亮颜色
 */
@Composable
fun AgreementCheckRow(
    checked: Boolean,
    onToggle: () -> Unit,
    modifier: Modifier = Modifier,
    fontSize: TextUnit = AppFont.sizeXs,
    prefix: String = "已阅读并同意",
    links: List<AgreementLink> = emptyList(),
    textColor: Color = AppColor.textSecondary,
    linkColor: Color = AppColor.primary
) {
    Row(
        modifier = modifier
            .clickable { onToggle() },
        verticalAlignment = Alignment.CenterVertically
    ) {
        RoundCheckbox(checked = checked, onToggle = onToggle)
        Spacer(modifier = Modifier.width(6.dp))
        val annotated = buildAnnotatedString {
            append(prefix)
            links.forEach { link ->
                val start = length
                withStyle(SpanStyle(color = linkColor)) { append(link.name) }
                addStringAnnotation(
                    tag = AGREEMENT_LINK_TAG,
                    annotation = link.name,
                    start = start,
                    end = length
                )
            }
        }
        ClickableText(
            text = annotated,
            style = TextStyle(fontSize = fontSize, color = textColor),
            onClick = { offset ->
                val hit = annotated.getStringAnnotations(
                    tag = AGREEMENT_LINK_TAG,
                    start = offset,
                    end = offset
                ).firstOrNull()
                val link = hit?.let { h -> links.firstOrNull { it.name == h.item } }
                if (link != null) {
                    link.onClick()
                } else {
                    onToggle()
                }
            }
        )
    }
}

/** 圆形勾选框本体：视觉 12dp，无涟漪、点击区即本体尺寸。 */
@Composable
private fun RoundCheckbox(checked: Boolean, onToggle: () -> Unit) {
    Box(
        modifier = Modifier
            .size(12.dp)
            .clip(CircleShape)
            .then(
                if (checked) Modifier.background(AppColor.primary)
                else Modifier.border(1.dp, AppColor.textSecondary, CircleShape)
            )
            .clickable { onToggle() },
        contentAlignment = Alignment.Center
    ) {
        if (checked) {
            Icon(
                imageVector = Icons.Filled.Check,
                contentDescription = null,
                modifier = Modifier.size(8.dp),
                tint = Color.White
            )
        }
    }
}

private const val AGREEMENT_LINK_TAG = "agreement_link"
