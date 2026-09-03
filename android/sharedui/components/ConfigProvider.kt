package com.zhiqihuayun.sharedui.components

import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.ProvidableCompositionLocal
import androidx.compose.runtime.Stable
import androidx.compose.runtime.compositionLocalOf
import androidx.compose.runtime.remember
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.Dp
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppRadius
import com.zhiqihuayun.foundation.design.AppSpace

/**
 * 全局配置 ConfigProvider（Compose 版，对齐 iOS ConfigProvider / api.json `ui.config-provider`）。
 *
 * 定位：design-token 静态基准（AppTokens）之上的**运行时覆盖层**。本组件不产出视觉像素，
 * 只提供「配置通道」：后代组件经 [AppTheme] 解析函数读取合并后的配置；未挂 Provider 时
 * 解析函数返回静态基准，零行为变化（D1）。
 *
 * 契约 props（与 api.json 对齐，null = 未覆盖、取父级/静态基准）：
 * - `primaryColor`：主题色覆盖（十六进制字符串，如 "#4F46E5"）
 * - `rounded`：圆角升一档（sm→md，md→lg，lg 封顶）
 * - `compact`：间距降一档（md→sm，lg→md，xl→lg）
 * - `locale`：文案语言（'zh-CN' | 'en-US'）
 *
 * 覆盖语义：内层覆盖外层同名项；外层未覆盖项继承；全未设取静态基准（D6）。
 */
@Stable
data class AppConfig(
    val primaryColor: Color? = null,
    val rounded: Boolean? = null,
    val compact: Boolean? = null,
    val locale: String? = null,
) {
    /** 合并：本对象为父级（outer），入参 overlay 覆盖同名项（inner 优先）。 */
    fun merged(overlay: AppConfig): AppConfig = AppConfig(
        primaryColor = overlay.primaryColor ?: primaryColor,
        rounded = overlay.rounded ?: rounded,
        compact = overlay.compact ?: compact,
        locale = overlay.locale ?: locale,
    )

    companion object {
        /** 静态基准等价物：全字段 null，解析函数回退到 AppTokens。 */
        val Baseline = AppConfig()
    }
}

/** 解析 "#4F46E5" / "4F46E5" / "#abc" 形式为 Color；非法返回 null。 */
fun parseHexColor(input: String): Color? {
    val hex = input.trim().removePrefix("#")
    if (hex.length == 3) {
        val v = hex.toLongOrNull(16) ?: return null
        val r = (v shr 8) and 0xF
        val g = (v shr 4) and 0xF
        val b = v and 0xF
        return Color(0xFF000000L or (r shl 20) or (r shl 16) or (g shl 12) or (g shl 8) or (b shl 4) or b)
    }
    if (hex.length != 6) return null
    val v = hex.toLongOrNull(16) ?: return null
    return Color(0xFF000000L or v)
}

/**
 * 当前生效配置（CompositionLocal，默认 = 静态基准）。
 * 消费组件不要直接读本对象，统一走 [AppTheme] 解析函数。
 */
val LocalAppConfig: ProvidableCompositionLocal<AppConfig> = compositionLocalOf { AppConfig.Baseline }

/**
 * 全局配置 ConfigProvider：为子树注入配置上下文。
 *
 * 用法（应用根 / 局部区块）：
 * ```kotlin
 * ConfigProvider(primaryColor = "#4F46E5", compact = true) {
 *     // 后代组件经 AppTheme 解析函数读取，免逐层透传
 * }
 * ```
 */
@Composable
fun ConfigProvider(
    primaryColor: String? = null,
    rounded: Boolean? = null,
    compact: Boolean? = null,
    locale: String? = null,
    content: @Composable () -> Unit,
) {
    val parent = LocalAppConfig.current
    val overlay = remember(primaryColor, rounded, compact, locale) {
        AppConfig(
            primaryColor = primaryColor?.let { parseHexColor(it) },
            rounded = rounded,
            compact = compact,
            locale = locale,
        )
    }
    val merged = remember(parent, overlay) { parent.merged(overlay) }
    CompositionLocalProvider(LocalAppConfig provides merged, content = content)
}

/**
 * 读取解析层：消费组件读取 token 的唯一入口。
 *
 * 规则：先查当前配置（[LocalAppConfig]）覆盖项，未覆盖回退静态基准（AppTokens）。
 * - rounded = true → 圆角升一档：sm→md、md→lg、lg 封顶
 * - compact = true → 间距降一档：md→sm、lg→md、xl→lg（sm 不降）
 */
object AppTheme {
    /** 主题色（主色）。 */
    @Composable
    fun primaryColor(): Color = LocalAppConfig.current.primaryColor ?: AppColor.primary

    /** 圆角档位解析（rounded 升档）。sm 档：6 → rounded 后 10。 */
    @Composable
    fun radiusSm(): Dp = if (LocalAppConfig.current.rounded == true) AppRadius.md else AppRadius.sm

    /** 圆角档位解析（rounded 升档）。md 档：10 → rounded 后 14。 */
    @Composable
    fun radiusMd(): Dp = if (LocalAppConfig.current.rounded == true) AppRadius.lg else AppRadius.md

    /** 圆角档位解析（rounded 升档）。lg 档封顶（无 xl token）：默认 14，rounded 仍 14。 */
    @Composable
    fun radiusLg(): Dp = AppRadius.lg

    /** 间距档位解析（compact 降档）。sm 档不降：默认 8，compact 仍 8。 */
    @Composable
    fun spaceSm(): Dp = AppSpace.sm

    /** 间距档位解析（compact 降档）。md 档：默认 12 → compact 后 8。 */
    @Composable
    fun spaceMd(): Dp = if (LocalAppConfig.current.compact == true) AppSpace.sm else AppSpace.md

    /** 间距档位解析（compact 降档）。lg 档：默认 16 → compact 后 12。 */
    @Composable
    fun spaceLg(): Dp = if (LocalAppConfig.current.compact == true) AppSpace.md else AppSpace.lg

    /** 间距档位解析（compact 降档）。xl 档：默认 24 → compact 后 16。 */
    @Composable
    fun spaceXl(): Dp = if (LocalAppConfig.current.compact == true) AppSpace.lg else AppSpace.xl

    /** 文案语言：默认 'zh-CN'。 */
    @Composable
    fun locale(): String = LocalAppConfig.current.locale ?: "zh-CN"
}
