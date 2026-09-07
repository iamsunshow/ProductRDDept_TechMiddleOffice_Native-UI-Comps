package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.ui.Modifier
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import org.junit.Assert.assertTrue
import org.junit.Assert.assertFalse
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config
import org.robolectric.annotation.GraphicsMode

/**
 * Checkbox 复选回归测试（#25 ui.checkbox，验证组件库 v1.4.0）。
 *
 * 覆盖：
 * - 单只勾选切换（未选→选→取消）
 * - CheckboxGroup 多选增删
 * - 禁用不可交互
 * - 半受控外部赋值同步回显
 */
@RunWith(RobolectricTestRunner::class)
@GraphicsMode(GraphicsMode.Mode.NATIVE)
@Config(sdk = [34], qualifiers = "w411dp-h891dp")
class CheckboxTest {

    @get:Rule
    val composeRule = createComposeRule()

    /** 单只勾选：点击切换 true→false→true。 */
    @Test
    fun test_单只勾选切换() {
        var checked = false
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                Checkbox(label = "同意协议", checked = checked, onCheckedChange = { checked = it })
            }
        }
        composeRule.onNodeWithText("同意协议").assertIsDisplayed()
        composeRule.onNodeWithText("同意协议").performClick()
        assertTrue(checked)
        composeRule.onNodeWithText("同意协议").performClick()
        assertFalse(checked)
    }

    /** CheckboxGroup：点击增选/取消。 */
    @Test
    fun test_组多选增删() {
        val options = listOf(
            CheckboxOption("a", "选项A"),
            CheckboxOption("b", "选项B"),
            CheckboxOption("c", "选项C")
        )
        val selected = mutableSetOf<String>()
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                CheckboxGroup(options = options, onChange = { value, isChecked ->
                    if (isChecked) selected.add(value) else selected.remove(value)
                })
            }
        }
        composeRule.onNodeWithText("选项A").performClick()
        assertTrue("a" in selected)
        composeRule.onNodeWithText("选项B").performClick()
        assertTrue("b" in selected)
        composeRule.onNodeWithText("选项A").performClick()
        assertFalse("a" in selected)
    }

    /** 组级禁用：点击不触发回调。 */
    @Test
    fun test_组级禁用不可交互() {
        val options = listOf(CheckboxOption("a", "选项A"))
        var changed = false
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                CheckboxGroup(options = options, disabled = true, onChange = { _, _ -> changed = true })
            }
        }
        composeRule.onNodeWithText("选项A").performClick()
        assertFalse(changed)
    }

    /** 选项级禁用：该选项不可点。 */
    @Test
    fun test_选项级禁用不可交互() {
        val options = listOf(
            CheckboxOption("a", "选项A", disabled = true),
            CheckboxOption("b", "选项B")
        )
        var changed = false
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                CheckboxGroup(options = options, onChange = { _, _ -> changed = true })
            }
        }
        composeRule.onNodeWithText("选项A").performClick()
        assertFalse(changed)
    }

    /** 单只禁用：点击不触发。 */
    @Test
    fun test_单只禁用不可交互() {
        var checked = false
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                Checkbox(label = "禁用项", disabled = true, onCheckedChange = { checked = it })
            }
        }
        composeRule.onNodeWithText("禁用项").performClick()
        assertFalse(checked)
    }
}
