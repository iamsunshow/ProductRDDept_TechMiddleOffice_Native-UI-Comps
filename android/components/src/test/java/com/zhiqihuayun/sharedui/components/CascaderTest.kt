package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
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
 * Cascader 级联选择回归测试（验证组件库 v1.4.0）。
 *
 * 覆盖：点非叶子=下钻 / 点叶子=onChange 回传 / 禁用节点不可交互 / tab 回滚。
 */
@RunWith(RobolectricTestRunner::class)
@GraphicsMode(GraphicsMode.Mode.NATIVE)
@Config(sdk = [34], qualifiers = "w411dp-h891dp")
class CascaderTest {

    @get:Rule
    val composeRule = createComposeRule()

    private val options = listOf(
        CascaderOption("1", "生活", children = listOf(
            CascaderOption("11", "餐饮", children = listOf(
                CascaderOption("111", "正餐"),
                CascaderOption("112", "快餐")
            )),
            CascaderOption("12", "出行")
        )),
        CascaderOption("2", "工作", disabled = true)
    )

    /** 点非叶子节点=下钻显示子级。 */
    @Test
    fun test_点非叶子下钻() {
        composeRule.setContent {
            Box(Modifier.fillMaxSize().height(400.dp)) {
                Cascader(options = options, onChange = {})
            }
        }
        composeRule.onNodeWithText("生活").assertIsDisplayed()
        composeRule.onNodeWithText("生活").performClick()
        composeRule.onNodeWithText("餐饮").assertIsDisplayed()
        composeRule.onNodeWithText("出行").assertIsDisplayed()
    }

    /** 点叶子节点=onChange 回传 CascaderResult。 */
    @Test
    fun test_点叶子回传结果() {
        var result: CascaderResult? = null
        composeRule.setContent {
            Box(Modifier.fillMaxSize().height(400.dp)) {
                Cascader(options = options, onChange = { result = it })
            }
        }
        composeRule.onNodeWithText("生活").performClick()
        composeRule.onNodeWithText("餐饮").performClick()
        composeRule.onNodeWithText("正餐").performClick()
        assertEquals(listOf("1", "11", "111"), result?.values)
        assertEquals("生活/餐饮/正餐", result?.text)
    }

    /** 禁用节点不可交互。 */
    @Test
    fun test_禁用节点不可交互() {
        var result: CascaderResult? = null
        composeRule.setContent {
            Box(Modifier.fillMaxSize().height(400.dp)) {
                Cascader(options = options, onChange = { result = it })
            }
        }
        composeRule.onNodeWithText("工作").performClick()
        assertNull(result)
        // 点禁用节点不应下钻
        composeRule.onNodeWithText("工作").assertIsDisplayed()
    }

    /** tab 回滚：点击已选中层 tab 可回退。 */
    @Test
    fun test_tab回滚() {
        composeRule.setContent {
            Box(Modifier.fillMaxSize().height(400.dp)) {
                Cascader(options = options, onChange = {})
            }
        }
        composeRule.onNodeWithText("生活").performClick()
        composeRule.onNodeWithText("餐饮").performClick()
        composeRule.onNodeWithText("正餐").assertIsDisplayed()
        // 回滚到第一层
        composeRule.onNodeWithText("生活").performClick()
        composeRule.onNodeWithText("餐饮").assertIsDisplayed()
        composeRule.onNodeWithText("出行").assertIsDisplayed()
    }

    /** 半受控：外部 result 赋值=回显定位。 */
    @Test
    fun test_外部result回显() {
        val result = CascaderResult(
            values = listOf("1", "11", "111"),
            texts = listOf("生活", "餐饮", "正餐"),
            text = "生活/餐饮/正餐"
        )
        composeRule.setContent {
            Box(Modifier.fillMaxSize().height(400.dp)) {
                Cascader(options = options, result = result, onChange = {})
            }
        }
        // 回显后选中路径的文本应显示
        composeRule.onNodeWithText("生活").assertIsDisplayed()
    }
}
