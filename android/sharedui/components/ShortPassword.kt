package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.text.BasicTextField
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
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppFont

/**
 * ShortPassword 短密码（ui.short-password，#39）——数据录入区全新立项组件。
 *
 * 定位：定长数字短密码/PIN 输入内容组件（支付/交易/二次验证短密码场景）：
 * 无壳水平居中掩码圆点行（输入位以「•」掩码点随字号显示、无灰底壳/清除钮/明文显隐切换）；
 * 输入=纯数字（KeyboardType.Number + 粘贴/输入均 filter 非数字）、定长 length 字符满=自动触发一次
 * onComplete(明文字符串)、满后继续输入拒收（take 截断不进入）；
 * 行高 48=对齐库内 FormFieldRow/Input 交互行基准（注释锚定）；空态 placeholder 居中灰字。
 *
 * 半受控：`value: String?`=nil 内部自持输入（宿主拿 onChange 每字符即可，无需回写）；
 * 外部赋值=仅同步回显（不触发 onChange/onComplete=外部满位也不触发，仅输入路径触发）；
 * disabled=整行 40% 灰不可输入无任何回调；placeholder 默认「请输入 N 位数字密码」。
 * 真实校验/错误提示/重试（校验失败宿主外部 value="" 清空重输）/键盘与弹层组合（可配 #32 NumberKeyboard）=宿主自理。
 *
 * 视觉锚点：密文点/占位字号 sizeXl 22、textPrimary 掩码点 / textSecondary 占位；内容水平居中。
 *
 * 规格：docs/数据与产物/design-spec/short-password-design-spec.html（门禁 A，P1–P4 全 A）。
 * 基线：组件库 v1.4.0（2026-09-06，未过 C2/D 不升版）。
 */
@Composable
fun ShortPassword(
    value: String? = null,
    onChange: (String) -> Unit,
    onComplete: ((String) -> Unit)? = null,
    length: Int = 6,
    placeholder: String? = null,
    disabled: Boolean = false,
    modifier: Modifier = Modifier
) {
    // 内部自持（value=nil 半受控路径）；外部 value 非 nil=受控直读参数（外部赋值仅回显、无回调）
    var internalText by remember { mutableStateOf("") }
    val text = value ?: internalText
    val ph = placeholder ?: "请输入 $length 位数字密码"

    BasicTextField(
        value = text,
        onValueChange = { raw ->
            if (!disabled) {
                // 仅数字 + 按 length 截断（满位后追加即 raw 超长被 take 掉=拒收）；外部赋值路径不经此
                val filtered = raw.filter { it.isDigit() }.take(length)
                if (filtered != text) {
                    internalText = filtered
                    onChange(filtered)
                    if (filtered.length == length) {
                        onComplete?.invoke(filtered)
                    }
                }
            }
        },
        textStyle = TextStyle(
            fontSize = AppFont.sizeXl,
            color = Color.Transparent
        ),
        cursorBrush = SolidColor(Color.Transparent),
        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
        singleLine = true,
        enabled = !disabled,
        modifier = modifier
            .fillMaxWidth()
            .height(48.dp) // 行高 min 48=对齐库内 FormFieldRow/Input 交互行基准（注释锚定）
            .alpha(if (disabled) 0.4f else 1f),
        decorationBox = { inner ->
            // 掩码展示层（居中）：空态=placeholder 灰字 / 有值=密文点序列；真实输入层透明叠底供聚焦与光标链路
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .fillMaxHeight(),
                contentAlignment = Alignment.Center
            ) {
                if (text.isEmpty()) {
                    Text(
                        text = ph,
                        fontSize = AppFont.sizeXl,
                        color = AppColor.textSecondary,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )
                } else {
                    Text(
                        text = "•".repeat(text.length),
                        fontSize = AppFont.sizeXl,
                        color = AppColor.textPrimary
                    )
                }
                inner()
            }
        }
    )
}
