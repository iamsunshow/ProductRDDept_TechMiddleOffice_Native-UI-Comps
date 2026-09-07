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
 * Radio 排他单选回归测试（#35 ui.radio，验证组件库 v1.4.0）。
 *
 * 覆盖：
 * - 排他单选（点未选=切中，点已选=幂等忽略）
 * - 组级/选项级禁用不可交互
 * - 半受控 null=合法未选态
 */
@RunWith(RobolectricTestRunner::class)
@GraphicsMode(GraphicsMode.Mode.NATIVE)
@Config(sdk = [34], qualifiers = "w411dp-h891dp")
class RadioTest {

    @get:Rule
    val composeRule = createComposeRule()

    private val options = listOf(
        RadioOption("1", "选项一"),
        RadioOption("2", "选项二"),
        RadioOption("3", "选项三")
    )

    /** 排他单选：点未选行=切中并回调。 */
    @Test
    fun test_排他单选切中() {
        var selected: String? = null
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                RadioGroup(options = options, onChange = { selected = it })
            }
        }
        composeRule.onNodeWithText("选项二").performClick()
        assertEquals("2", selected)
    }

    /** 幂等：点已选中行不回调。 */
    @Test
    fun test_幂等点已选行不回调() {
        var selected: String? = null
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                RadioGroup(options = options, value = "2", onChange = { selected = it })
            }
        }
        composeRule.onNodeWithText("选项二").performClick()
        assertNull(selected) // 已选中再点=不回调
    }

    /** 切换排他：选 1 后再选 3=回传 3。 */
    @Test
    fun test_切换排他() {
        var selected: String? = null
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                RadioGroup(options = options, value = "1", onChange = { selected = it })
            }
        }
        composeRule.onNodeWithText("选项三").performClick()
        assertEquals("3", selected)
    }

    /** 组级禁用：不可交互。 */
    @Test
    fun test_组级禁用不可交互() {
        var selected: String? = null
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                RadioGroup(options = options, disabled = true, onChange = { selected = it })
            }
        }
        composeRule.onNodeWithText("选项一").performClick()
        assertNull(selected)
    }

    /** 选项级禁用：该选项不可点。 */
    @Test
    fun test_选项级禁用不可交互() {
        val opts = listOf(RadioOption("1", "选项一", disabled = true))
        var selected: String? = null
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                RadioGroup(options = opts, onChange = { selected = it })
            }
        }
        composeRule.onNodeWithText("选项一").performClick()
        assertNull(selected)
    }

    /** null=合法未选态，不自动回填首项。 */
    @Test
    fun test_null为合法未选态() {
        var selected: String? = "unchanged"
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                RadioGroup(options = options, value = null, onChange = { selected = it })
            }
        }
        // 初始无选中=不触发 onChange
        assertEquals("unchanged", selected)
    }
}
