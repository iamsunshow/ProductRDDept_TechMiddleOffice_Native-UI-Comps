package com.zhiqihuayun.demo

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppFont
import com.zhiqihuayun.foundation.design.AppRadius
import com.zhiqihuayun.foundation.design.AppSpace
import com.zhiqihuayun.sharedui.components.Price
import com.zhiqihuayun.sharedui.components.PriceSize
import com.zhiqihuayun.sharedui.components.PriceSymbolPosition

// ===== Price 组件 Demo 页（独立页面，与 iOS PriceShowcase 一一对应） =====
// 演示点（验收文档 六）：
// ① 基础价格（price=199，默认两位小数、符号前置、danger 红）
// ② 千分位+小数位（12345.678→12,345.68；decimalPlaces=0 无小数）
// ③ 符号大小/位置（size large；symbolPosition=after 后缀「元」；size small）
// ④ 前缀/后缀（prefix「到手价」+ suffix「起」；suffix「/月」）

@Composable
private fun PriceSectionTitle(text: String) {
    Text(
        text = text,
        color = AppColor.textPrimary,
        fontSize = AppFont.sizeMd,
        fontWeight = FontWeight.SemiBold
    )
}

@Composable
private fun PriceHint(text: String) {
    Text(
        text = text,
        color = AppColor.textSecondary,
        fontSize = AppFont.sizeXs
    )
}

/** Price 组件 Demo 页入口（MainActivity 首页 → 信息展示 → Price 价格）。 */
@Composable
fun PriceDemo() {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(AppColor.bgPage)
            .verticalScroll(rememberScrollState())
            .padding(horizontal = AppSpace.xl, vertical = AppSpace.md),
        verticalArrangement = Arrangement.spacedBy(AppSpace.lg)
    ) {
        // 组件版本徽标：与 iOS 端保持同一版本号。
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .background(AppColor.primaryMuted, RoundedCornerShape(AppRadius.sm))
                .padding(horizontal = 10.dp, vertical = 6.dp)
        ) {
            Text(
                text = "Price 组件 v1.4.31",
                color = AppColor.primary,
                fontSize = AppFont.sizeXs,
                fontWeight = FontWeight.Medium,
                textAlign = TextAlign.Center,
                modifier = Modifier.fillMaxWidth()
            )
        }

        // D1 基础价格：price=199，默认两位小数、符号前置、danger 红
        PriceSectionTitle("D1 基础价格（price=199）")
        Price(price = 199.0)
        PriceHint("排查点：显示「¥199.00」，符号 ¥ 前置、danger 红，整数 22 Bold、符号/小数 14 Semibold，底部对齐。")

        // D2 千分位 + 小数位：12345.678→12,345.68；decimalPlaces=0 无小数
        PriceSectionTitle("D2 千分位 + 小数位")
        Column(verticalArrangement = Arrangement.spacedBy(AppSpace.sm)) {
            // 12345.678 → 12,345.68
            Price(price = 12345.678)
            // 9999.5 → 10,000（decimalPlaces=0）
            Price(price = 9999.5, decimalPlaces = 0)
        }
        PriceHint("排查点：第一行「¥12,345.68」（千分位逗号 + 四舍五入到两位）；第二行「¥10,000」（decimalPlaces=0 无小数）。")

        // D3 符号大小/位置：size large；symbolPosition=after；size small
        PriceSectionTitle("D3 符号大小/位置（size / symbolPosition）")
        Column(verticalArrangement = Arrangement.spacedBy(AppSpace.sm)) {
            // size large
            Price(price = 299.0, size = PriceSize.Large)
            // symbolPosition=after 后缀「元」
            Price(price = 199.0, symbol = "元", symbolPosition = PriceSymbolPosition.After)
            // size small
            Price(price = 99.0, size = PriceSize.Small)
        }
        PriceHint("排查点：第一行 size large（整数 32 号字更大）；第二行「199.00元」符号后置；第三行 size small（整数 16 号字更小）。")

        // D4 前缀/后缀
        PriceSectionTitle("D4 前缀/后缀（prefix / suffix）")
        Column(verticalArrangement = Arrangement.spacedBy(AppSpace.sm)) {
            // prefix + suffix
            Price(price = 199.0, prefix = "到手价", suffix = "起")
            // suffix「/月」
            Price(price = 1299.0, suffix = "/月")
        }
        PriceHint("排查点：第一行「到手价 ¥199.00 起」（前缀「到手价」+ 后缀「起」均为 textSecondary 12 号）；第二行「¥1,299.00 /月」（后缀「/月」）。")
    }
}
