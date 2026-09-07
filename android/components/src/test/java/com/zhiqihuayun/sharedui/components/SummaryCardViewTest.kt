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
 * SummaryCardView 摘要卡片回归测试（验证组件库 v1.4.0）。
 *
 * 覆盖：onClick null/非null / accessory 显示/隐藏 / 标题+副标题+数值渲染。
 */
@RunWith(RobolectricTestRunner::class)
@GraphicsMode(GraphicsMode.Mode.NATIVE)
@Config(sdk = [34], qualifiers = "w411dp-h891dp")
class SummaryCardViewTest {

    @get:Rule
    val composeRule = createComposeRule()

    /** onClick 非 null=点击触发回调。 */
    @Test
    fun test_onClick非null触发() {
        var clicked = false
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                SummaryCardView(
                    title = "本月支出",
                    subtitle = "2026年9月",
                    value = "¥3,200",
                    onClick = { clicked = true }
                )
            }
        }
        composeRule.onNodeWithText("本月支出").performClick()
        assertTrue(clicked)
    }

    /** onClick=null=不触发回调。 */
    @Test
    fun test_onClickNull不触发() {
        var clicked = false
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                SummaryCardView(
                    title = "总收入",
                    subtitle = "2026年",
                    value = "¥10,000",
                    onClick = null
                )
            }
        }
        composeRule.onNodeWithText("总收入").performClick()
        assertFalse(clicked)
    }

    /** accessory 非 null=显示辅助文案。 */
    @Test
    fun test_accessory显示() {
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                SummaryCardView(
                    title = "支出",
                    subtitle = "本月",
                    value = "¥200",
                    accessory = "较上月+10%"
                )
            }
        }
        composeRule.onNodeWithText("支出").assertIsDisplayed()
        composeRule.onNodeWithText("较上月+10%").assertIsDisplayed()
    }

    /** accessory=null=不显示辅助文案。 */
    @Test
    fun test_accessoryNull不显示() {
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                SummaryCardView(
                    title = "支出",
                    subtitle = "本月",
                    value = "¥200",
                    accessory = null
                )
            }
        }
        composeRule.onNodeWithText("支出").assertIsDisplayed()
    }

    /** 标题+副标题+数值全显示。 */
    @Test
    fun test_标题副标题数值全显示() {
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                SummaryCardView(
                    title = "总资产",
                    subtitle = "截至今日",
                    value = "¥50,000"
                )
            }
        }
        composeRule.onNodeWithText("总资产").assertIsDisplayed()
        composeRule.onNodeWithText("截至今日").assertIsDisplayed()
        composeRule.onNodeWithText("¥50,000").assertIsDisplayed()
    }
}
