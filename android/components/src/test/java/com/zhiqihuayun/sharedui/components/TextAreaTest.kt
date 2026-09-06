package com.zhiqihuayun.sharedui.components

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.compose.ui.test.assertHeightIsEqualTo
import androidx.compose.ui.test.assertIsNotEnabled
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performTextInput
import androidx.compose.ui.unit.dp
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config
import org.robolectric.annotation.GraphicsMode

/**
 * TextArea 回归测试（#42 ui.textarea，门禁 B 基线，验证组件库 v1.4.0）。
 *
 * 回归背景（规格锚定 + 修复 commit 2008007/98d2646 同源）：
 * - maxLength 0/缺省=不限，仅输入路径截断（含粘贴/IME 超长只收前 N），外部赋值不强制截断、不触发回调；
 * - disabled 整壳不可编辑无回调；placeholder 空态显示/非空即隐；
 * - 整件高 = rows×24 + 上下内边距 12×2（默认 3 行=96=2×48 交互行基准注释锚定）。
 * 本文件=首批回归补测（回归测试台账 #32/#33 同源族）。
 */
@RunWith(RobolectricTestRunner::class)
@GraphicsMode(GraphicsMode.Mode.NATIVE)
@Config(sdk = [34], qualifiers = "w411dp-h891dp")
class TextAreaTest {

    @get:Rule
    val composeRule = createComposeRule()

    /** maxLength=5：键盘/IME 输入路径超长必须只收前 N（粘贴同路径）。 */
    @Test
    fun test_regression_maxLength输入路径截断() {
        val texts = mutableListOf<String>()
        composeRule.setContent {
            TextArea(value = "", onTextChange = { texts.add(it) }, maxLength = 5)
        }
        composeRule.onNodeWithTag("textarea-field").performTextInput("abcdefg")
        composeRule.waitForIdle()
        assertEquals(listOf("abcde"), texts)
    }

    /** maxLength 不得截断外部赋值：直接传超长 value=完整回显且零回调。 */
    @Test
    fun test_regression_maxLength外部赋值不截断零回调() {
        val long = "1234567890"
        val texts = mutableListOf<String>()
        composeRule.setContent {
            TextArea(value = long, onTextChange = { texts.add(it) }, maxLength = 5)
        }
        composeRule.waitForIdle()
        assertTrue("外部赋值不得触发 onTextChange", texts.isEmpty())
        composeRule.onNodeWithText(long).assertExists()
    }

    /** placeholder：空态显示、外部驱动非空即隐。 */
    @Test
    fun test_regression_placeholder显隐() {
        var text by mutableStateOf("")
        composeRule.setContent {
            TextArea(value = text, onTextChange = { text = it }, placeholder = "请输入备注")
        }
        composeRule.onNodeWithText("请输入备注").assertExists()
        composeRule.runOnIdle { text = "你好" }
        composeRule.waitForIdle()
        composeRule.onNodeWithText("请输入备注").assertDoesNotExist()
    }

    /** disabled：字段不可编辑、点击/输入零回调。 */
    @Test
    fun test_regression_disabled不可编辑() {
        val texts = mutableListOf<String>()
        composeRule.setContent {
            TextArea(value = "只读", onTextChange = { texts.add(it) }, disabled = true)
        }
        composeRule.onNodeWithTag("textarea-field").assertIsNotEnabled()
        composeRule.waitForIdle()
        assertTrue("disabled 下不得回调", texts.isEmpty())
    }

    /** 整件高数学=默认 rows=3 → 3×24+上下 24=96dp（防行高链断裂类回归）。 */
    @Test
    fun test_regression_默认整件高96() {
        composeRule.setContent {
            TextArea(value = "", onTextChange = {})
        }
        composeRule.onNodeWithTag("textarea-root").assertHeightIsEqualTo(96.dp)
    }

    /** rows=4 → 4×24+上下 24=120dp。 */
    @Test
    fun test_regression_rows4整件高120() {
        composeRule.setContent {
            TextArea(value = "", onTextChange = {}, rows = 4)
        }
        composeRule.onNodeWithTag("textarea-root").assertHeightIsEqualTo(120.dp)
    }
}
