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
 * NumberKeyboard 数字键盘回归测试（#32 ui.number-keyboard，验证组件库 v1.4.0）。
 *
 * 覆盖：数字键 onInput / 删除 onDelete / 确认 onConfirm / disabled / confirmDisabled。
 */
@RunWith(RobolectricTestRunner::class)
@GraphicsMode(GraphicsMode.Mode.NATIVE)
@Config(sdk = [34], qualifiers = "w411dp-h891dp")
class NumberKeyboardTest {

    @get:Rule
    val composeRule = createComposeRule()

    /** 数字键 1 → onInput("1")。 */
    @Test
    fun test_数字键1回调() {
        var input: String? = null
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                NumberKeyboard(onInput = { input = it })
            }
        }
        composeRule.onNodeWithText("1").performClick()
        assertEquals("1", input)
    }

    /** 数字键 0 → onInput("0")。 */
    @Test
    fun test_数字键0回调() {
        var input: String? = null
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                NumberKeyboard(onInput = { input = it })
            }
        }
        composeRule.onNodeWithText("0").performClick()
        assertEquals("0", input)
    }

    /** 点号 → onInput(".")。 */
    @Test
    fun test_点号回调() {
        var input: String? = null
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                NumberKeyboard(onInput = { input = it }, showDot = true)
            }
        }
        composeRule.onNodeWithText(".").performClick()
        assertEquals(".", input)
    }

    /** 删除键 → onDelete()。 */
    @Test
    fun test_删除键回调() {
        var deleted = false
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                NumberKeyboard(onInput = {}, onDelete = { deleted = true })
            }
        }
        composeRule.onNodeWithText("删除").performClick()
        assertEquals(true, deleted)
    }

    /** 确认键 → onConfirm()。 */
    @Test
    fun test_确认键回调() {
        var confirmed = false
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                NumberKeyboard(onInput = {}, onConfirm = { confirmed = true })
            }
        }
        composeRule.onNodeWithText("确认").performClick()
        assertEquals(true, confirmed)
    }

    /** disabled：数字键不回调。 */
    @Test
    fun test_disabled数字键不回调() {
        var input: String? = null
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                NumberKeyboard(onInput = { input = it }, disabled = true)
            }
        }
        composeRule.onNodeWithText("1").performClick()
        assertNull(input)
    }

    /** disabled：确认键不回调。 */
    @Test
    fun test_disabled确认键不回调() {
        var confirmed = false
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                NumberKeyboard(onInput = {}, onConfirm = { confirmed = true }, disabled = true)
            }
        }
        composeRule.onNodeWithText("确认").performClick()
        assertEquals(false, confirmed)
    }

    /** confirmDisabled：确认键不回调。 */
    @Test
    fun test_confirmDisabled确认键不回调() {
        var confirmed = false
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                NumberKeyboard(onInput = {}, onConfirm = { confirmed = true }, confirmDisabled = true)
            }
        }
        composeRule.onNodeWithText("确认").performClick()
        assertEquals(false, confirmed)
    }

    /** extraKey：自定义键文本显示+回调。 */
    @Test
    fun test_extraKey显示() {
        var input: String? = null
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                NumberKeyboard(onInput = { input = it }, extraKey = "+")
            }
        }
        composeRule.onNodeWithText("+").assertIsDisplayed()
        composeRule.onNodeWithText("+").performClick()
        assertEquals("+", input)
    }
}
