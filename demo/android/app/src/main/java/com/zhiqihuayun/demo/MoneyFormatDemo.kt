package com.zhiqihuayun.demo

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppFont
import com.zhiqihuayun.foundation.design.AppSpace
import com.zhiqihuayun.foundation.util.MoneyFormatter

/**
 * MoneyFormat 金额格式化 Demo（foundation.money-format #95）。
 * 4 组排查：①string 基础两位小数 ②currency 金额前缀 ③signed 收支方向
 * ④边界值（0 / 负数 / 大额 / 超两位舍入）。
 * 断言双端逐字符一致（小写货币符号"¥"）。
 */
@Composable
fun MoneyFormatDemo() {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(horizontal = AppSpace.lg, vertical = AppSpace.md),
        verticalArrangement = Arrangement.spacedBy(AppSpace.lg)
    ) {
        DemoSection("D1 · string —— 基础两位小数") {
            Text(
                "1121 → ${MoneyFormatter.string(1121.0)}\n" +
                    "38.5 → ${MoneyFormatter.string(38.5)}",
                fontSize = AppFont.sizeMd, color = AppColor.textPrimary
            )
        }

        DemoSection("D2 · currency —— 金额前缀 ¥") {
            Text(
                "38.5 → ${MoneyFormatter.currency(38.5)}\n" +
                    "1121 → ${MoneyFormatter.currency(1121.0)}",
                fontSize = AppFont.sizeMd, color = AppColor.textPrimary
            )
        }

        DemoSection("D3 · signed —— 收支方向") {
            Text(
                "收入 38.5 → ${MoneyFormatter.signed(38.5, isIncome = true)}\n" +
                    "支出 38.5 → ${MoneyFormatter.signed(38.5, isIncome = false)}",
                fontSize = AppFont.sizeMd, color = AppColor.textPrimary
            )
        }

        DemoSection("D4 · 边界值 —— 0 / 负数 / 大额 / 超两位舍入") {
            Text(
                "0 → ${MoneyFormatter.string(0.0)}\n" +
                    "-1118 → ${MoneyFormatter.string(-1118.0)}\n" +
                    "12345678.9 → ${MoneyFormatter.string(12345678.9)}\n" +
                    "38.567 → ${MoneyFormatter.string(38.567)}（四舍五入）",
                fontSize = AppFont.sizeMd, color = AppColor.textPrimary
            )
        }

        Text(
            "foundation.money-format = 金额字符串格式化唯一出口（string/currency/signed 三形态），" +
                "最小两位小数、不带千分位（对齐 iOS MoneyFormatter 逐字符一致）。",
            fontSize = AppFont.sizeXs, color = AppColor.textSecondary
        )
    }
}
