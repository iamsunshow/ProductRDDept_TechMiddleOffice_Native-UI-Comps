package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppFont
import com.zhiqihuayun.foundation.design.AppRadius
import com.zhiqihuayun.foundation.design.AppSpace

/**
 * SearchBar 搜索栏（ui.search-bar，#38）——数据录入区全新立项组件。
 *
 * 定位：搜索输入壳=48dp 灰底 bgPage + radiusLg 圆角（对齐已收编 Input #29 壳 token，复用不复制），
 * 前置放大镜（自绘 glyph 14 灰）+ 文本输入 + 非空清除钮 + trailing 宿主尾槽；
 * 检索语义：软键盘「搜索」键/回车=onSearch(当前文本) 一次性回调（主触发），
 * 后置搜索按钮=trailing 宿主槽自放（与键盘搜索键双路径，动作联动宿主自理）。
 * 真实检索执行/结果/历史/联想=宿主自理（组件零内部异步态）。
 *
 * 半受控：`value: String?`=nil 内部自持输入（宿主拿 onTextChange 实时拿词即可，无需回写）；
 * 外部赋值=仅同步回显（不触发 onTextChange）；disabled=整行 40% 灰不可输入、清除钮隐藏、无任何回调；
 * maxLength 仅截断键盘输入路径（外部赋值不限）；placeholder 默认「请输入搜索关键词」。
 *
 * 视觉锚点：壳 48dp 高 bgPage + radiusLg 圆角、无边框；行内水平 padding 16；放大镜 14 灰；
 * 文本 Md16 textPrimary；placeholder textSecondary Md16；清除钮 20dp 圆 gray15 底白叉（非空显示）；
 * 输入光标 primary。放大镜/清除钮=自绘 Canvas（与 iOS SearchBarView glyph 双端 1:1）。
 *
 * 规格：docs/数据与产物/design-spec/search-bar-design-spec.html（门禁 A，P1–P4 全 A）。
 * 基线：组件库 v1.4.0（2026-09-06，未过 C2/D 不升版）。
 */
@Composable
fun SearchBar(
    value: String? = null,
    onTextChange: (String) -> Unit,
    onSearch: ((String) -> Unit)? = null,
    placeholder: String = "请输入搜索关键词",
    maxLength: Int? = null,
    disabled: Boolean = false,
    trailing: (@Composable () -> Unit)? = null,
    modifier: Modifier = Modifier
) {
    // 内部自持（value=nil 半受控路径）；外部 value 非 nil=受控直读参数，无需内部回显状态
    var internalText by remember { mutableStateOf("") }
    val text = value ?: internalText

    Row(
        modifier = modifier
            .fillMaxWidth()
            .height(48.dp) // 壳高 48=对齐 Input #29/FormFieldRow min48（AppSpace 无行高档，注释锚定）
            .clip(RoundedCornerShape(AppRadius.lg))
            .background(AppColor.bgPage)
            .alpha(if (disabled) 0.4f else 1f)
            .padding(horizontal = AppSpace.lg),
        verticalAlignment = Alignment.CenterVertically
    ) {
        // 前置放大镜 glyph 14（textSecondary 灰）：自绘圆+斜柄，同 iOS MagGlyphView
        Canvas(Modifier.size(14.dp)) {
            val side = size.width
            val c = AppColor.textSecondary.copy(alpha = 0.85f)
            drawCircle(
                color = c,
                radius = side * 0.26f,
                center = Offset(side * 0.44f, side * 0.44f),
                style = Stroke(width = side * 0.15f)
            )
            drawLine(
                color = c,
                start = Offset(side * 0.64f, side * 0.64f),
                end = Offset(side * 0.90f, side * 0.90f),
                strokeWidth = side * 0.15f,
                cap = StrokeCap.Round
            )
        }
        Spacer(Modifier.width(AppSpace.sm))

        Box(
            modifier = Modifier.weight(1f),
            contentAlignment = Alignment.CenterStart
        ) {
            BasicTextField(
                value = text,
                onValueChange = { raw ->
                    val newText = if (maxLength != null && raw.length > maxLength) {
                        raw.take(maxLength)
                    } else {
                        raw
                    }
                    if (newText != text) {
                        internalText = newText
                        onTextChange(newText)
                    }
                },
                textStyle = TextStyle(
                    fontSize = AppFont.sizeMd,
                    color = AppColor.textPrimary
                ),
                cursorBrush = SolidColor(AppColor.primary),
                keyboardOptions = KeyboardOptions(
                    keyboardType = KeyboardType.Text,
                    imeAction = ImeAction.Search
                ),
                keyboardActions = KeyboardActions(
                    onSearch = { if (!disabled) onSearch?.invoke(text) }
                ),
                enabled = !disabled,
                singleLine = true,
                modifier = Modifier.fillMaxWidth()
            )
            if (text.isEmpty()) {
                Text(
                    text = placeholder,
                    fontSize = AppFont.sizeMd,
                    color = AppColor.textSecondary,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
            }
        }

        // 清除钮：非空且非禁用显示（点击清空回传空串）
        if (text.isNotEmpty() && !disabled) {
            Spacer(Modifier.width(AppSpace.sm))
            Box(
                modifier = Modifier
                    .size(20.dp)
                    .clip(CircleShape)
                    .background(AppColor.gray15)
                    .clickable {
                        internalText = ""
                        onTextChange("")
                    },
                contentAlignment = Alignment.Center
            ) {
                Canvas(Modifier.size(12.dp)) {
                    val inset = size.width * 0.2f
                    val outer = size.width - inset
                    drawLine(
                        color = Color.White,
                        start = Offset(inset, inset),
                        end = Offset(outer, outer),
                        strokeWidth = size.width * 0.17f,
                        cap = StrokeCap.Round
                    )
                    drawLine(
                        color = Color.White,
                        start = Offset(outer, inset),
                        end = Offset(inset, outer),
                        strokeWidth = size.width * 0.17f,
                        cap = StrokeCap.Round
                    )
                }
            }
        }
        // trailing 尾槽（宿主自放，如「搜索」按钮=与键盘搜索键双路径）
        if (trailing != null) {
            Spacer(Modifier.width(AppSpace.sm))
            trailing()
        }
    }
}
