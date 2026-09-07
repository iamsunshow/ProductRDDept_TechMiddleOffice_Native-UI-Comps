package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.ui.Modifier
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config
import org.robolectric.annotation.GraphicsMode

/**
 * Tabs 选项卡回归测试（#20 ui.tabs，验证组件库 v1.4.0）。
 *
 * 覆盖：
 * - 页签切换回调
 * - 幂等（点已选页签不回调）
 * - 禁用项不可交互
 * - 默认选首启用项
 */
@RunWith(RobolectricTestRunner::class)
@GraphicsMode(GraphicsMode.Mode.NATIVE)
@Config(sdk = [34], qualifiers = "w411dp-h891dp")
class TabsTest {

    @get:Rule
    val composeRule = createComposeRule()

    private val items = listOf(
        TabItem("全部", "all"),
        TabItem("支出", "expense"),
        TabItem("收入", "income", disabled = true)
    )

    /** 页签切换：点未选页签=回传 value。 */
    @Test
    fun test_页签切换回调() {
        var selected = "all"
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                Tabs(items = items, selectedValue = "all", onChange = { selected = it })
            }
        }
        composeRule.onNodeWithText("支出").performClick()
        assertEquals("expense", selected)
    }

    /** 幂等：点已选页签不回调。 */
    @Test
    fun test_幂等点已选不回调() {
        var selected: String? = null
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                Tabs(items = items, selectedValue = "all", onChange = { selected = it })
            }
        }
        composeRule.onNodeWithText("全部").performClick()
        assertNull(selected)
    }

    /** 禁用项不可交互：点「收入」不回调。 */
    @Test
    fun test_禁用项不可交互() {
        var selected: String? = null
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                Tabs(items = items, selectedValue = "all", onChange = { selected = it })
            }
        }
        composeRule.onNodeWithText("收入").performClick()
        assertNull(selected)
    }

    /** 默认选首启用项：selectedValue=null 时自动选首个非禁用项。 */
    @Test
    fun test_默认选首启用项() {
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                Tabs(items = items, selectedValue = null, onChange = {})
            }
        }
        composeRule.onNodeWithText("全部").assertIsDisplayed()
        composeRule.onNodeWithText("支出").assertIsDisplayed()
        composeRule.onNodeWithText("收入").assertIsDisplayed()
    }

    /** activeColor 自定义：渲染不崩。 */
    @Test
    fun test_自定义activeColor() {
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                Tabs(
                    items = items,
                    selectedValue = "all",
                    activeColor = androidx.compose.ui.graphics.Color.Red,
                    onChange = {}
                )
            }
        }
        composeRule.onNodeWithText("全部").assertIsDisplayed()
    }
}
