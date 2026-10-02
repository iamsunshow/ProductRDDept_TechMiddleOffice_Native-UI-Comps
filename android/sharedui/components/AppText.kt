package com.zhiqihuayun.sharedui.components

import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextLayoutResult
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextDecoration
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.TextUnit
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppFont

/**
 * 统一文本组件：业务代码唯一文本入口，禁直接 import material3.Text。
 *
 * 内部委托 M3 Text，默认值从设计 tokens 取（AppColor.textPrimary / AppFont.sizeMd）。
 * 所有样式参数透传，签名兼容 M3 Text 常用子集。
 */
@Composable
fun AppText(
    text: String,
    modifier: Modifier = Modifier,
    color: Color = AppColor.textPrimary,
    fontSize: TextUnit = AppFont.sizeMd,
    fontWeight: FontWeight? = null,
    fontFamily: FontFamily? = null,
    textAlign: TextAlign? = null,
    textDecoration: TextDecoration? = null,
    lineHeight: TextUnit = TextUnit.Unspecified,
    letterSpacing: TextUnit = TextUnit.Unspecified,
    maxLines: Int = Int.MAX_VALUE,
    minLines: Int = 1,
    overflow: TextOverflow = TextOverflow.Clip,
    softWrap: Boolean = true,
    style: TextStyle = TextStyle.Default,
    onTextLayout: (TextLayoutResult) -> Unit = {},
) {
    Text(
        text = text,
        modifier = modifier,
        color = color,
        fontSize = fontSize,
        fontWeight = fontWeight,
        fontFamily = fontFamily,
        textAlign = textAlign,
        textDecoration = textDecoration,
        lineHeight = lineHeight,
        letterSpacing = letterSpacing,
        maxLines = maxLines,
        minLines = minLines,
        overflow = overflow,
        softWrap = softWrap,
        style = style,
        onTextLayout = onTextLayout,
    )
}
