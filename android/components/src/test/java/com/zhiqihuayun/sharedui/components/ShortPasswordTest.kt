package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.ui.Modifier
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithText
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config
import org.robolectric.annotation.GraphicsMode

/**
 * ShortPassword 短密码回归测试（#39 ui.short-password，验证组件库 v1.4.0）。
 *
 * 注意：BasicTextField 在 Robolectric 无真实 IME，无法模拟键盘输入触发 onValueChange。
 * L1 聚焦：placeholder 默认格式 + disabled 渲染 + 自定义 length/placeholder。
 * 输入过滤/截断/onComplete 路径= L4 人工实机。
 */
@RunWith(RobolectricTestRunner::class)
@GraphicsMode(GraphicsMode.Mode.NATIVE)
@Config(sdk = [34], qualifiers = "w411dp-h891dp")
class ShortPasswordTest {

    @get:Rule
    val composeRule = createComposeRule()

    /** 默认 placeholder「请输入 6 位数字密码」显示。 */
    @Test
    fun test_默认placeholder显示() {
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                ShortPassword(onChange = {})
            }
        }
        composeRule.onNodeWithText("请输入 6 位数字密码").assertIsDisplayed()
    }

    /** length=4 时 placeholder 显示「请输入 4 位数字密码」。 */
    @Test
    fun test_length4placeholder() {
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                ShortPassword(length = 4, onChange = {})
            }
        }
        composeRule.onNodeWithText("请输入 4 位数字密码").assertIsDisplayed()
    }

    /** 自定义 placeholder 显示。 */
    @Test
    fun test_自定义placeholder() {
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                ShortPassword(onChange = {}, placeholder = "输入支付密码")
            }
        }
        composeRule.onNodeWithText("输入支付密码").assertIsDisplayed()
    }

    /** disabled 渲染不崩。 */
    @Test
    fun test_disabled渲染不崩() {
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                ShortPassword(onChange = {}, disabled = true)
            }
        }
        composeRule.onNodeWithText("请输入 6 位数字密码").assertIsDisplayed()
    }

    /** 外部赋值受控回显=掩码点显示。 */
    @Test
    fun test_外部赋值回显掩码点() {
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                ShortPassword(value = "123", onChange = {})
            }
        }
        // 掩码点 "•••" 应显示
        composeRule.onNodeWithText("•••").assertIsDisplayed()
    }
}
