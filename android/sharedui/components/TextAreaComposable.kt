package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicText
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.foundation.verticalScroll
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.unit.dp
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppFont
import com.zhiqihuayun.foundation.design.AppRadius
import com.zhiqihuayun.foundation.design.AppSpace
import com.zhiqihuayun.foundation.design.AppText

/**
 * TextArea 文本域（数据录入 #42 ui.textarea，门禁 B，验证组件库 v1.4.0）。
 * 通用多行文本输入内容组件（受控 value）：
 * - 灰底圆角文本域壳（bgPage + radius lg + 内边距 md 12 四向）= 与 Input #29 同壳语言（单行/多行两形态）；
 * - placeholder：textSecondary Md16 顶部左对齐（多行不垂直居中）——库内无 textTertiary token=同 Input 实现惯例；
 * - 文本 Md16 textPrimary 行高 24=AppText.cellTitleLineHeight（注释锚定）；
 * - rows 可视行：整件高 = rows×24dp + 上下内边距 12×2，默认 3 行 = 96 = 2×48 交互行基准（同 Signature 96 注释锚定）；
 * - 内容超可视行：内层内容容器 verticalScroll 手动滚动（光标超可视输入时滚回=宿主/系统键盘场景待真机细调）；
 * - maxLength：0/缺省=不限，仅输入路径截断（含粘贴/IME 超长只收前 N），外部赋值不强制截断；
 * - disabled：整壳 alpha0.4 不可编辑不可滚动无回调（含已填文本只读回显）。
 * - 受控：value 外部赋值=同步回显（不触发 onTextChange）；用户输入经 onTextChange 回调。
 */
// 可视行行高常量：24.dp 与 AppText.cellTitleLineHeight(24sp) 常规字号 1:1（spec §02 注释锚定）
private val TextAreaRowHeightDp = 24.dp

@Composable
fun TextArea(
    value: String,
    onTextChange: (String) -> Unit,
    placeholder: String? = null,
    rows: Int = 3,
    maxLength: Int? = null,
    disabled: Boolean = false,
    modifier: Modifier = Modifier
) {
    // 整件高 = rows×24 + 上下内边距 12×2（默认 3 行=96=2×48 交互行基准注释锚定）
    val shellHeight = TextAreaRowHeightDp * rows.coerceAtLeast(1) + AppSpace.md * 2

    Box(
        modifier
            .fillMaxWidth()
            .height(shellHeight)
            .alpha(if (disabled) 0.4f else 1f)
            .background(AppColor.bgPage, RoundedCornerShape(AppRadius.lg))
            .padding(AppSpace.md)
    ) {
        // 内层内容容器：固定可视高度、内容超高内部滚动（壳内边距固定不随滚动）
        Box(
            Modifier
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
        ) {
            BasicTextField(
                value = value,
                onValueChange = { raw ->
                    val t = if (maxLength != null && raw.length > maxLength) {
                        raw.take(maxLength)
                    } else {
                        raw
                    }
                    if (t != value) onTextChange(t)
                },
                textStyle = TextStyle(
                    fontSize = AppFont.sizeMd,
                    color = AppColor.textPrimary,
                    lineHeight = AppText.cellTitleLineHeight
                ),
                cursorBrush = SolidColor(AppColor.primary),
                enabled = !disabled,
                decorationBox = { inner ->
                    Box(Modifier.fillMaxWidth()) {
                        inner()
                        if (value.isEmpty() && !placeholder.isNullOrEmpty()) {
                            BasicText(
                                text = placeholder,
                                style = TextStyle(
                                    fontSize = AppFont.sizeMd,
                                    color = AppColor.textSecondary,
                                    lineHeight = AppText.cellTitleLineHeight
                                )
                            )
                        }
                    }
                },
                modifier = Modifier.fillMaxWidth()
            )
        }
    }
}
