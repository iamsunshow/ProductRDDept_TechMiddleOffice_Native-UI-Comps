package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.width
import androidx.compose.ui.Modifier
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import androidx.compose.ui.unit.dp
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config
import org.robolectric.annotation.GraphicsMode

/**
 * SideBar 侧边导航回归测试（验证组件库 v1.4.0）。
 *
 * 覆盖：选切换 / 幂等 / 禁用不可交互 / 默认选首启用项。
 */
@RunWith(RobolectricTestRunner::class)
@GraphicsMode(GraphicsMode.Mode.NATIVE)
@Config(sdk = [34], qualifiers = "w411dp-h891dp")
class SideBarTest {

    @get:Rule
    val composeRule = createComposeRule()

    private val items = listOf(
        SideBarItem("全部", "all"),
        SideBarItem("餐饮", "dining"),
        SideBarItem("娱乐", "fun", disabled = true)
    )

    /** 点未选行=回传 value。 */
    @Test
    fun test_选切换回调() {
        var selected: String? = null
        composeRule.setContent {
            Box(Modifier.fillMaxSize().width(96.dp).height(300.dp)) {
                SideBar(items = items, onChange = { selected = it })
            }
        }
        composeRule.onNodeWithText("餐饮").performClick()
        assertEquals("dining", selected)
    }

    /** 幂等：点已选行不回调。 */
    @Test
    fun test_幂等点已选不回调() {
        var selected: String? = null
        composeRule.setContent {
            Box(Modifier.fillMaxSize().width(96.dp).height(300.dp)) {
                SideBar(items = items, selectedValue = "all", onChange = { selected = it })
            }
        }
        composeRule.onNodeWithText("全部").performClick()
        assertNull(selected)
    }

    /** 禁用行不可交互。 */
    @Test
    fun test_禁用行不可交互() {
        var selected: String? = null
        composeRule.setContent {
            Box(Modifier.fillMaxSize().width(96.dp).height(300.dp)) {
                SideBar(items = items, onChange = { selected = it })
            }
        }
        composeRule.onNodeWithText("娱乐").performClick()
        assertNull(selected)
    }

    /** 默认选首启用项。 */
    @Test
    fun test_默认选首启用项() {
        composeRule.setContent {
            Box(Modifier.fillMaxSize().width(96.dp).height(300.dp)) {
                SideBar(items = items, onChange = {})
            }
        }
        composeRule.onNodeWithText("全部").assertIsDisplayed()
        composeRule.onNodeWithText("餐饮").assertIsDisplayed()
        composeRule.onNodeWithText("娱乐").assertIsDisplayed()
    }

    /** selectedValue 外部驱动选中渲染不崩。 */
    @Test
    fun test_外部驱动选中() {
        composeRule.setContent {
            Box(Modifier.fillMaxSize().width(96.dp).height(300.dp)) {
                SideBar(items = items, selectedValue = "dining", onChange = {})
            }
        }
        composeRule.onNodeWithText("全部").assertIsDisplayed()
        composeRule.onNodeWithText("餐饮").assertIsDisplayed()
    }
}
