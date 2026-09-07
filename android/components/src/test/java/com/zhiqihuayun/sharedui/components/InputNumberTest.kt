package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.ui.Modifier
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import org.junit.Assert.assertEquals
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config
import org.robolectric.annotation.GraphicsMode

/**
 * InputNumber 步进数字输入回归测试（#30 ui.input-number，验证组件库 v1.4.0）。
 *
 * 覆盖：
 * - 步进增减（+/- 按 step）
 * - 边界限制（min/max 到达按钮禁用幂等）
 * - precision 定点收敛
 * - disabled 整体不可交互
 */
@RunWith(RobolectricTestRunner::class)
@GraphicsMode(GraphicsMode.Mode.NATIVE)
@Config(sdk = [34], qualifiers = "w411dp-h891dp")
class InputNumberTest {

    @get:Rule
    val composeRule = createComposeRule()

    /** 步进增：点 + 回传 1。 */
    @Test
    fun test_步进增() {
        var value = 0.0
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                InputNumber(value = 0.0, min = 0.0, max = 10.0, onChange = { value = it })
            }
        }
        composeRule.onNodeWithText("+").performClick()
        assertEquals(1.0, value, 0.001)
    }

    /** 步进减：点 − 回传 -1。 */
    @Test
    fun test_步进减() {
        var value = 0.0
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                InputNumber(value = 0.0, min = -5.0, max = 10.0, onChange = { value = it })
            }
        }
        composeRule.onNodeWithText("−").performClick()
        assertEquals(-1.0, value, 0.001)
    }

    /** max 边界：到达 max 后点 + 幂等无回调。 */
    @Test
    fun test_到达max幂等无回调() {
        var value = 10.0
        var callbackCount = 0
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                InputNumber(value = 10.0, min = 0.0, max = 10.0, onChange = { callbackCount++ })
            }
        }
        composeRule.onNodeWithText("+").performClick()
        assertEquals(0, callbackCount) // 到达 max=幂等不回调
    }

    /** min 边界：到达 min 后点 − 幂等无回调。 */
    @Test
    fun test_到达min幂等无回调() {
        var callbackCount = 0
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                InputNumber(value = 0.0, min = 0.0, max = 10.0, onChange = { callbackCount++ })
            }
        }
        composeRule.onNodeWithText("−").performClick()
        assertEquals(0, callbackCount)
    }

    /** step=2：每次增减 2。 */
    @Test
    fun test_自定义step() {
        var value = 10.0
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                InputNumber(value = 10.0, min = 0.0, max = 100.0, step = 2.0, onChange = { value = it })
            }
        }
        composeRule.onNodeWithText("+").performClick()
        assertEquals(12.0, value, 0.001)
    }

    /** precision=2：运算展示按 2 位定点收敛。 */
    @Test
    fun test_precision定点收敛() {
        var value = 0.0
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                InputNumber(value = 0.0, min = 0.0, max = 10.0, step = 0.5, precision = 2, onChange = { value = it })
            }
        }
        composeRule.onNodeWithText("+").performClick()
        assertEquals(0.5, value, 0.001)
    }

    /** disabled：整体不可交互。 */
    @Test
    fun test_disabled不可交互() {
        var callbackCount = 0
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                InputNumber(value = 5.0, min = 0.0, max = 10.0, disabled = true, onChange = { callbackCount++ })
            }
        }
        composeRule.onNodeWithText("+").performClick()
        assertEquals(0, callbackCount)
    }

    /** step=0.5+precision=1：连续点 + 两次=1.0。 */
    @Test
    fun test_连续步进() {
        var value = 0.0
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                InputNumber(value = 0.0, min = 0.0, max = 10.0, step = 0.5, precision = 1, onChange = { value = it })
            }
        }
        composeRule.onNodeWithText("+").performClick()
        composeRule.onNodeWithText("+").performClick()
        assertEquals(1.0, value, 0.001)
    }
}
