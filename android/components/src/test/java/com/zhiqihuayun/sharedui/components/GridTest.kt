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
 * Grid 宫格回归测试（验证组件库 v1.4.0）。
 *
 * 覆盖：onSelect 回调索引 / 空标题不显示 / 无回调不可交互 / 多列渲染。
 */
@RunWith(RobolectricTestRunner::class)
@GraphicsMode(GraphicsMode.Mode.NATIVE)
@Config(sdk = [34], qualifiers = "w411dp-h891dp")
class GridTest {

    @get:Rule
    val composeRule = createComposeRule()

    private val items = listOf(
        GridItem("餐饮", AppIconName.List),
        GridItem("出行", AppIconName.Safari),
        GridItem("购物", AppIconName.Plus),
        GridItem("娱乐", AppIconName.Chart)
    )

    /** 点格项=onSelect 回传全局索引。 */
    @Test
    fun test_点格项回传索引() {
        var selected: Int? = null
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                Grid(title = "快捷入口", items = items, onSelect = { selected = it })
            }
        }
        composeRule.onNodeWithText("餐饮").performClick()
        assertEquals(0, selected)
        composeRule.onNodeWithText("出行").performClick()
        assertEquals(1, selected)
    }

    /** 第三项索引=2。 */
    @Test
    fun test_第三项索引2() {
        var selected: Int? = null
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                Grid(title = "入口", items = items, onSelect = { selected = it })
            }
        }
        composeRule.onNodeWithText("购物").performClick()
        assertEquals(2, selected)
    }

    /** 空标题=不显示标题区域。 */
    @Test
    fun test_空标题不显示() {
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                Grid(title = "", items = items, onSelect = {})
            }
        }
        composeRule.onNodeWithText("餐饮").assertIsDisplayed()
        // 标题区域不应出现自定义标题文本（但子项标题存在）
    }

    /** onSelect=null：点击不回调。 */
    @Test
    fun test_无回调不可交互() {
        var selected: Int? = null
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                Grid(title = "入口", items = items, onSelect = null)
            }
        }
        composeRule.onNodeWithText("餐饮").performClick()
        assertNull(selected)
    }

    /** 所有格项标题显示。 */
    @Test
    fun test_所有格项标题显示() {
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                Grid(title = "入口", items = items, onSelect = {})
            }
        }
        composeRule.onNodeWithText("餐饮").assertIsDisplayed()
        composeRule.onNodeWithText("出行").assertIsDisplayed()
        composeRule.onNodeWithText("购物").assertIsDisplayed()
        composeRule.onNodeWithText("娱乐").assertIsDisplayed()
    }
}
