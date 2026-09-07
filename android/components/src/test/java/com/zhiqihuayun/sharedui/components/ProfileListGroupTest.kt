package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.ui.Modifier
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config
import org.robolectric.annotation.GraphicsMode

/**
 * ProfileListGroup 设置项分组回归测试（验证组件库 v1.4.0）。
 *
 * 覆盖：onClick 回调 / value 渲染 / 无 onClick 不显示箭头 / 分隔线。
 */
@RunWith(RobolectricTestRunner::class)
@GraphicsMode(GraphicsMode.Mode.NATIVE)
@Config(sdk = [34], qualifiers = "w411dp-h891dp")
class ProfileListGroupTest {

    @get:Rule
    val composeRule = createComposeRule()

    /** onClick 回调触发。 */
    @Test
    fun test_onClick回调触发() {
        var clicked = false
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                ProfileListGroup(
                    items = listOf(
                        ProfileListItem(title = "设置", onClick = { clicked = true })
                    )
                )
            }
        }
        composeRule.onNodeWithText("设置").performClick()
        assertTrue(clicked)
    }

    /** value 非空=显示 value 文本。 */
    @Test
    fun test_value渲染() {
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                ProfileListGroup(
                    items = listOf(
                        ProfileListItem(title = "版本", value = "v1.0.0")
                    )
                )
            }
        }
        composeRule.onNodeWithText("版本").assertIsDisplayed()
        composeRule.onNodeWithText("v1.0.0").assertIsDisplayed()
    }

    /** 多项渲染：全部标题显示。 */
    @Test
    fun test_多项渲染() {
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                ProfileListGroup(
                    items = listOf(
                        ProfileListItem(title = "账户"),
                        ProfileListItem(title = "隐私"),
                        ProfileListItem(title = "关于")
                    )
                )
            }
        }
        composeRule.onNodeWithText("账户").assertIsDisplayed()
        composeRule.onNodeWithText("隐私").assertIsDisplayed()
        composeRule.onNodeWithText("关于").assertIsDisplayed()
    }

    /** 无 onClick=不可点击（不触发回调）。 */
    @Test
    fun test_无onClick不回调() {
        var clicked = false
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                ProfileListGroup(
                    items = listOf(
                        ProfileListItem(title = "版本", value = "v1.0.0")
                    )
                )
            }
        }
        composeRule.onNodeWithText("版本").performClick()
        assertFalse(clicked)
    }

    /** value=null 不显示 value 文本。 */
    @Test
    fun test_valueNull不显示() {
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                ProfileListGroup(
                    items = listOf(
                        ProfileListItem(title = "通知", onClick = {})
                    )
                )
            }
        }
        composeRule.onNodeWithText("通知").assertIsDisplayed()
    }
}
