// Price 价格组件（Compose 版，对齐 iOS PriceView）。
//
// 商品/订单/账本等场景的金额展示——由「前缀文本 + 货币符号 + 整数部分 + 小数部分 + 后缀文本」
// 组成的行内价格。price 数值驱动，支持 decimalPlaces 小数位、thousands 千分位、
// symbol 货币符号及大小/位置（front/after）、prefix/suffix 自定义前后缀、
// size 尺寸档位（small/medium/large）、color 价格主色。
//
// 决策（与设计规格 price-design-spec.html 一致）：
// - P1-A price=Double 数值驱动，千分位/小数位由组件统一格式化
// - P2-A thousands=true + decimalPlaces=2 默认
// - P3-A 符号独立 symbolSize + symbolPosition front/after
// - P4-A prefix/suffix 自定义前后缀文本（textSecondary、小字号）

package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Row
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.TextUnit
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppFont
import com.zhiqihuayun.foundation.design.AppSpace
import java.text.DecimalFormat
import java.text.DecimalFormatSymbols
import java.util.Locale

/** 价格尺寸档位。 */
enum class PriceSize {
    Small, Medium, Large;

    val integerFontSize: TextUnit
        get() = when (this) {
            Small -> AppFont.sizeMd      // 16
            Medium -> AppFont.sizeXl     // 22
            Large -> AppFont.sizeDisplay // 32
        }

    val symbolFontSize: TextUnit
        get() = when (this) {
            Small -> AppFont.sizeXs  // 12
            Medium -> AppFont.sizeSm // 14
            Large -> AppFont.sizeLg  // 16
        }
}

/** 货币符号位置。 */
enum class PriceSymbolPosition { Front, After }

/**
 * 价格展示组件。
 *
 * @param price 价格数值
 * @param symbol 货币符号（空字符串不显示）
 * @param decimalPlaces 小数位数，0 不显示小数
 * @param thousands 是否千分位
 * @param size 尺寸档位
 * @param symbolPosition 符号位置
 * @param color 价格主色
 * @param prefix 前缀文本
 * @param suffix 后缀文本
 * @param modifier 修饰
 */
@Composable
fun Price(
    price: Double = 0.0,
    symbol: String = "¥",
    decimalPlaces: Int = 2,
    thousands: Boolean = true,
    size: PriceSize = PriceSize.Medium,
    symbolPosition: PriceSymbolPosition = PriceSymbolPosition.Front,
    color: Color = AppColor.error,
    prefix: String = "",
    suffix: String = "",
    modifier: Modifier = Modifier,
) {
    val places = decimalPlaces.coerceAtLeast(0)
    val (integerPart, decimalPart) = formatPrice(price, places, thousands)

    Row(
        modifier = modifier,
        verticalAlignment = Alignment.Bottom,
        horizontalArrangement = Arrangement.spacedBy(AppSpace.xs)
    ) {
        if (prefix.isNotEmpty()) {
            Text(
                text = prefix,
                color = AppColor.textSecondary,
                fontSize = AppFont.sizeXs,
            )
        }
        if (symbol.isNotEmpty() && symbolPosition == PriceSymbolPosition.Front) {
            Text(
                text = symbol,
                color = color,
                fontSize = size.symbolFontSize,
                fontWeight = FontWeight.SemiBold,
            )
        }
        Text(
            text = integerPart,
            color = color,
            fontSize = size.integerFontSize,
            fontWeight = FontWeight.Bold,
        )
        if (decimalPart.isNotEmpty()) {
            Text(
                text = ".$decimalPart",
                color = color,
                fontSize = size.symbolFontSize,
                fontWeight = FontWeight.SemiBold,
            )
        }
        if (symbol.isNotEmpty() && symbolPosition == PriceSymbolPosition.After) {
            Text(
                text = symbol,
                color = color,
                fontSize = size.symbolFontSize,
                fontWeight = FontWeight.SemiBold,
            )
        }
        if (suffix.isNotEmpty()) {
            Text(
                text = suffix,
                color = AppColor.textSecondary,
                fontSize = AppFont.sizeXs,
            )
        }
    }
}

/**
 * 按 decimalPlaces 四舍五入并拆分为「整数部分 + 小数部分」字符串。
 * thousands=true 时整数部分插入逗号千分位。
 */
private fun formatPrice(price: Double, decimalPlaces: Int, thousands: Boolean): Pair<String, String> {
    // 四舍五入到指定位数。
    val factor = Math.pow(10.0, decimalPlaces.toDouble())
    val rounded = Math.round(price * factor) / factor

    // 构造 pattern：整数部分 + 小数部分。
    val intPattern = if (thousands) "#,##0" else "0"
    val decPattern = if (decimalPlaces > 0) "0".repeat(decimalPlaces) else ""
    val pattern = if (decPattern.isEmpty()) intPattern else "$intPattern.$decPattern"

    val symbols = DecimalFormatSymbols(Locale.US).apply {
        groupingSeparator = ','
        decimalSeparator = '.'
    }
    val fmt = DecimalFormat(pattern, symbols)
    val formatted = fmt.format(rounded)

    if (decimalPlaces == 0) return formatted to ""

    val dotIdx = formatted.indexOf('.')
    return if (dotIdx >= 0) {
        formatted.substring(0, dotIdx) to formatted.substring(dotIdx + 1)
    } else {
        formatted to ""
    }
}
