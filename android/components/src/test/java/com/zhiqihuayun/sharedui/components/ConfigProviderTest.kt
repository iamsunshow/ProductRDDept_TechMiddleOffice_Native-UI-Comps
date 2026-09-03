package com.zhiqihuayun.sharedui.components

import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.unit.Dp
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppRadius
import com.zhiqihuayun.foundation.design.AppSpace
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config
import org.robolectric.annotation.GraphicsMode

/**
 * ConfigProvider 组件测试：门禁 C1 用例映射（详见 `docs/验收流程/component-acceptance-config-provider.md`）。
 *
 * Provider 型组件无视觉五态，D 系列为「配置生效测试」——以读取解析层 [AppTheme] 为观测点
 * （挂/不挂 Provider 时解析函数返回值变化）。A1-A5 API 契约测试；A6（schema）与 A7（双端
 * 命名对齐）由 `scripts/check_component_quality.py` 执行。
 *
 * 运行：`./gradlew :components:testDebugUnitTest --tests "*ConfigProviderTest*"`。
 *
 * 注：断言统一走本文件 [assertEq]（Kotlin 泛型 `==`）——Compose 的 Dp/Color 是 value class，
 * JUnit 装箱 Object equals 会按引用比较导致假失败，故不直接用 JUnit 三参断言。
 */
@RunWith(RobolectricTestRunner::class)
@GraphicsMode(GraphicsMode.Mode.NATIVE)
@Config(sdk = [34], qualifiers = "w411dp-h891dp")
class ConfigProviderTest {

    @get:Rule
    val composeRule = createComposeRule()

    private val indigo = Color(0xFF4F46E5)

    // ---------- D 系列：配置生效测试（观测点 = AppTheme 解析层） ----------

    /** D1 默认基准（零行为变化）：不挂 Provider 时解析层返回静态基准 AppTokens 值。 */
    @Test
    fun test_D1_defaultBaseline() {
        var result: Values? = null
        composeRule.setContent { result = readValues() }
        composeRule.runOnIdle {
            val v = result!!
            assertEq("primaryColor = 静态基准", AppColor.primary, v.primary)
            assertEq("radiusSm", AppRadius.sm, v.radiusSm)
            assertEq("radiusMd", AppRadius.md, v.radiusMd)
            assertEq("radiusLg", AppRadius.lg, v.radiusLg)
            assertEq("spaceSm", AppSpace.sm, v.spaceSm)
            assertEq("spaceMd", AppSpace.md, v.spaceMd)
            assertEq("spaceLg", AppSpace.lg, v.spaceLg)
            assertEq("spaceXl", AppSpace.xl, v.spaceXl)
            assertEq("locale 默认", "zh-CN", v.locale)
        }
    }

    /** D2 主题色覆盖：挂 Provider primaryColor 后，primaryColor 解析变覆盖值，其余 token 不变。 */
    @Test
    fun test_D2_primaryColorOverride() {
        var result: Values? = null
        composeRule.setContent {
            ConfigProvider(primaryColor = "#4F46E5") { result = readValues() }
        }
        composeRule.runOnIdle {
            val v = result!!
            assertEq("primaryColor 被覆盖", indigo, v.primary)
            assertEq("radius 不受影响", AppRadius.md, v.radiusMd)
            assertEq("space 不受影响", AppSpace.lg, v.spaceLg)
            assertEq("locale 不受影响", "zh-CN", v.locale)
        }
    }

    /** D3 紧凑模式：compact 后间距降一档（md→sm、lg→md、xl→lg；sm 不降）。 */
    @Test
    fun test_D3_compactMode() {
        var result: Values? = null
        composeRule.setContent {
            ConfigProvider(compact = true) { result = readValues() }
        }
        composeRule.runOnIdle {
            val v = result!!
            assertEq("sm 档不降", AppSpace.sm, v.spaceSm)
            assertEq("md→sm", AppSpace.sm, v.spaceMd)
            assertEq("lg→md", AppSpace.md, v.spaceLg)
            assertEq("xl→lg", AppSpace.lg, v.spaceXl)
            assertEq("颜色不受影响", AppColor.primary, v.primary)
            assertEq("圆角不受影响", AppRadius.md, v.radiusMd)
        }
    }

    /** D4 圆角模式：rounded 后圆角升一档（sm→md、md→lg；lg 封顶）。 */
    @Test
    fun test_D4_roundedMode() {
        var result: Values? = null
        composeRule.setContent {
            ConfigProvider(rounded = true) { result = readValues() }
        }
        composeRule.runOnIdle {
            val v = result!!
            assertEq("sm→md", AppRadius.md, v.radiusSm)
            assertEq("md→lg", AppRadius.lg, v.radiusMd)
            assertEq("lg 封顶", AppRadius.lg, v.radiusLg)
            assertEq("间距不受影响", AppSpace.md, v.spaceMd)
            assertEq("颜色不受影响", AppColor.primary, v.primary)
        }
    }

    /** D5 静态基准不被污染：覆盖只发生在读取解析层，AppTokens 静态常量零改动。 */
    @Test
    fun test_D5_staticBaselineUnpolluted() {
        composeRule.setContent {
            ConfigProvider(primaryColor = "#4F46E5", rounded = true, compact = true) {
                AppTheme.primaryColor()
            }
        }
        composeRule.runOnIdle {
            // 静态 token 常量与覆盖前一致（AppTokens 未被改）
            assertEq("AppColor.primary 未改", 0xFF16A34A.toInt(), AppColor.primary.toArgb())
            assertEq("AppRadius.sm 未改", 6f, AppRadius.sm.value)
            assertEq("AppRadius.md 未改", 10f, AppRadius.md.value)
            assertEq("AppRadius.lg 未改", 14f, AppRadius.lg.value)
            assertEq("AppSpace.sm 未改", 8f, AppSpace.sm.value)
            assertEq("AppSpace.md 未改", 12f, AppSpace.md.value)
            assertEq("AppSpace.lg 未改", 16f, AppSpace.lg.value)
            assertEq("AppSpace.xl 未改", 24f, AppSpace.xl.value)
        }
    }

    /** D6 嵌套优先级（内层覆盖 + 继承）：外层 primaryColor、内层 compact。 */
    @Test
    fun test_D6_nestedPriority() {
        var outer: Values? = null
        var inner: Values? = null
        var afterInner: Values? = null
        composeRule.setContent {
            ConfigProvider(primaryColor = "#4F46E5") {
                outer = readValues()
                ConfigProvider(compact = true) {
                    inner = readValues()
                }
                afterInner = readValues()
            }
        }
        composeRule.runOnIdle {
            assertEq("外层 primaryColor 生效", indigo, outer!!.primary)
            assertEq("外层 spaceMd 默认", AppSpace.md, outer!!.spaceMd)
            assertEq("内层继承外层 primaryColor", indigo, inner!!.primary)
            assertEq("内层 compact 生效 md→sm", AppSpace.sm, inner!!.spaceMd)
            assertEq("退出内层 primaryColor 仍生效", indigo, afterInner!!.primary)
            assertEq("退出内层 spaceMd 恢复", AppSpace.md, afterInner!!.spaceMd)
        }
    }

    /** D7 语言切换：locale 覆盖为 'en-US'，作用域外仍 'zh-CN'。 */
    @Test
    fun test_D7_localeSwitch() {
        var inside: String? = null
        var outside: String? = null
        composeRule.setContent {
            outside = AppTheme.locale()
            ConfigProvider(locale = "en-US") { inside = AppTheme.locale() }
        }
        composeRule.runOnIdle {
            assertEq("作用域内 en-US", "en-US", inside!!)
            assertEq("作用域外 zh-CN", "zh-CN", outside!!)
        }
    }

    /** D8 组合覆盖：primaryColor + rounded + compact + locale 同时生效，互不干扰。 */
    @Test
    fun test_D8_comboOverride() {
        var result: Values? = null
        composeRule.setContent {
            ConfigProvider(primaryColor = "#4F46E5", rounded = true, compact = true, locale = "en-US") {
                result = readValues()
            }
        }
        composeRule.runOnIdle {
            val v = result!!
            assertEq("primaryColor", indigo, v.primary)
            assertEq("rounded md→lg", AppRadius.lg, v.radiusMd)
            assertEq("compact lg→md", AppSpace.md, v.spaceLg)
            assertEq("locale", "en-US", v.locale)
        }
    }

    // ---------- A 系列：API 契约测试 ----------

    /** A1 默认 props：不传时默认值生效，与不挂 Provider 解析一致。 */
    @Test
    fun test_A1_defaultProps() {
        var emptyProvider: Values? = null
        var noProvider: Values? = null
        composeRule.setContent {
            noProvider = readValues()
            ConfigProvider { emptyProvider = readValues() }
        }
        composeRule.runOnIdle {
            val a = noProvider!!
            val b = emptyProvider!!
            assertEq("空 Provider 与不挂一致 primaryColor", a.primary, b.primary)
            assertEq("空 Provider 与不挂一致 radiusMd", a.radiusMd, b.radiusMd)
            assertEq("空 Provider 与不挂一致 spaceLg", a.spaceLg, b.spaceLg)
            assertEq("locale 默认 zh-CN", "zh-CN", b.locale)
        }
    }

    /** A2 自定义 props：各覆盖项按传入值生效（rounded=false 显式不升档）。 */
    @Test
    fun test_A2_customProps() {
        var result: Values? = null
        composeRule.setContent {
            ConfigProvider(primaryColor = "#DC2626", rounded = false, compact = true, locale = "en-US") {
                result = readValues()
            }
        }
        composeRule.runOnIdle {
            val v = result!!
            assertEq("primaryColor 覆盖", Color(0xFFDC2626), v.primary)
            assertEq("rounded=false 不升档", AppRadius.md, v.radiusMd)
            assertEq("compact 生效 md→sm", AppSpace.sm, v.spaceMd)
            assertEq("locale en-US", "en-US", v.locale)
        }
    }

    /** A3 作用域-子树读取：配置经上下文穿透，Provider 内任意深度可读取。 */
    @Test
    fun test_A3_scopeDescendantRead() {
        var deep: Values? = null
        composeRule.setContent {
            ConfigProvider(primaryColor = "#4F46E5") {
                ConfigProvider(locale = "en-US") {
                    deep = readValues() // 两层嵌套最深读取
                }
            }
        }
        composeRule.runOnIdle {
            assertEq("两层嵌套读取 primaryColor", indigo, deep!!.primary)
            assertEq("两层嵌套读取 locale", "en-US", deep!!.locale)
        }
    }

    /** A4 作用域-作用域外不受影响：Provider 外组件读静态基准。 */
    @Test
    fun test_A4_outOfScopeUnaffected() {
        var outside: Values? = null
        composeRule.setContent {
            ConfigProvider(primaryColor = "#4F46E5") { AppTheme.primaryColor() }
            outside = readValues() // Provider 之外（兄弟位置）
        }
        composeRule.runOnIdle {
            assertEq("作用域外读静态基准", AppColor.primary, outside!!.primary)
        }
    }

    /** A5 能力-覆盖语义：嵌套 Provider + 组合覆盖（与 D6/D8 对应）。 */
    @Test
    fun test_A5_overrideSemantics() {
        var inner: Values? = null
        var outerAfterInner: Values? = null
        composeRule.setContent {
            ConfigProvider(compact = true) {
                ConfigProvider(primaryColor = "#4F46E5", rounded = true) {
                    inner = readValues()
                }
                outerAfterInner = readValues()
            }
        }
        composeRule.runOnIdle {
            assertEq("内层 primaryColor", indigo, inner!!.primary)
            assertEq("内层 rounded md→lg", AppRadius.lg, inner!!.radiusMd)
            assertEq("内层继承外层 compact md→sm", AppSpace.sm, inner!!.spaceMd)
            assertEq("退出内层 primaryColor 回基准", AppColor.primary, outerAfterInner!!.primary)
            assertEq("退出内层 compact 仍生效", AppSpace.sm, outerAfterInner!!.spaceMd)
        }
    }

    // ---------- 解析层基础行为 ----------

    /** parseHexColor：支持 6 位 / 3 位、带/不带 # 前缀；非法返回 null。 */
    @Test
    fun test_parseHexColor() {
        assertEq("6 位带 #", Color(0xFF4F46E5), parseHexColor("#4F46E5"))
        assertEq("6 位不带 #", Color(0xFF4F46E5), parseHexColor("4F46E5"))
        assertEq("3 位展开 AABBCC", Color(0xFFAABBCC), parseHexColor("#abc"))
        assertNull("非法长度", parseHexColor("#12"))
        assertNull("非法字符", parseHexColor("xyz"))
    }

    /** AppConfig.merged 语义：overlay 覆盖同名项、nil 继承外层。 */
    @Test
    fun test_mergedSemantics() {
        val outer = AppConfig(primaryColor = Color(0xFF4F46E5), rounded = true)
        val inner = AppConfig(compact = true)
        val merged = outer.merged(inner)
        assertEq("外层 primaryColor 被继承", Color(0xFF4F46E5), merged.primaryColor!!)
        assertEq("外层 rounded 被继承", true, merged.rounded)
        assertEq("内层 compact 覆盖", true, merged.compact)
        assertNull("两端未设 → null", merged.locale)
        // 空 overlay 覆盖语义：merged 与 outer 一致
        val noOp = outer.merged(AppConfig())
        assertEq("空 overlay 不改变 outer", Color(0xFF4F46E5), noOp.primaryColor!!)
        assertEq("空 overlay 继承 rounded", true, noOp.rounded)
    }

    /** 解析层观测辅助：一次读出全部解析值。 */
    private data class Values(
        val primary: Color,
        val radiusSm: Dp,
        val radiusMd: Dp,
        val radiusLg: Dp,
        val spaceSm: Dp,
        val spaceMd: Dp,
        val spaceLg: Dp,
        val spaceXl: Dp,
        val locale: String,
    )

    @Composable
    private fun readValues(): Values = Values(
        primary = AppTheme.primaryColor(),
        radiusSm = AppTheme.radiusSm(),
        radiusMd = AppTheme.radiusMd(),
        radiusLg = AppTheme.radiusLg(),
        spaceSm = AppTheme.spaceSm(),
        spaceMd = AppTheme.spaceMd(),
        spaceLg = AppTheme.spaceLg(),
        spaceXl = AppTheme.spaceXl(),
        locale = AppTheme.locale(),
    )

    /** Kotlin 泛型断言（value class `==` 按值比较，避免 JUnit 装箱引用比较假失败）。 */
    private fun <T> assertEq(message: String, expected: T, actual: T) {
        assertTrue("$message：期望 $expected，实际 $actual", expected == actual)
    }
}
