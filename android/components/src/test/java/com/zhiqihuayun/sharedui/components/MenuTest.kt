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
 * Menu 菜单回归测试（验证组件库 v1.4.0）。
 *
 * 覆盖：列展开 / 点选项 onChange / 幂等折叠 / 禁用不可交互。
 */
@RunWith(RobolectricTestRunner::class)
@GraphicsMode(GraphicsMode.Mode.NATIVE)
@Config(sdk = [34], qualifiers = "w411dp-h891dp")
class MenuTest {

    @get:Rule
    val composeRule = createComposeRule()

    private val columns = listOf(
        MenuColumn(
            key = "sort",
            title = "排序",
            options = listOf(
                MenuOption("default", "默认"),
                MenuOption("price", "价格"),
                MenuOption("hot", "热门")
            )
        ),
        MenuColumn(
            key = "filter",
            title = "筛选",
            options = listOf(
                MenuOption("all", "全部"),
                MenuOption("near", "附近", disabled = true)
            )
        )
    )

    /** 点列头=展开该列 options。 */
    @Test
    fun test_点列头展开() {
        composeRule.setContent {
            Box(Modifier.fillMaxSize().height(400.dp)) {
                Menu(columns = columns, onChange = { _, _ -> })
            }
        }
        composeRule.onNodeWithText("排序").assertIsDisplayed()
        composeRule.onNodeWithText("排序").performClick()
        composeRule.onNodeWithText("默认").assertIsDisplayed()
        composeRule.onNodeWithText("价格").assertIsDisplayed()
    }

    /** 点选项=onChange(columnKey, optionValue)。 */
    @Test
    fun test_点选项回调() {
        var col: String? = null
        var opt: String? = null
        composeRule.setContent {
            Box(Modifier.fillMaxSize().height(400.dp)) {
                Menu(columns = columns, onChange = { k, v -> col = k; opt = v })
            }
        }
        composeRule.onNodeWithText("排序").performClick()
        composeRule.onNodeWithText("价格").performClick()
        assertEquals("sort", col)
        assertEquals("price", opt)
    }

    /** 幂等：点已展开列头=折叠。 */
    @Test
    fun test_幂等折叠() {
        composeRule.setContent {
            Box(Modifier.fillMaxSize().height(400.dp)) {
                Menu(columns = columns, onChange = { _, _ -> })
            }
        }
        composeRule.onNodeWithText("排序").performClick()
        composeRule.onNodeWithText("默认").assertIsDisplayed()
        composeRule.onNodeWithText("排序").performClick() // 折叠
        composeRule.onNodeWithText("默认").assertDoesNotExist()
    }

    /** 禁用选项不可交互。 */
    @Test
    fun test_禁用选项不可交互() {
        var opt: String? = null
        composeRule.setContent {
            Box(Modifier.fillMaxSize().height(400.dp)) {
                Menu(columns = columns, onChange = { _, v -> opt = v })
            }
        }
        composeRule.onNodeWithText("筛选").performClick()
        composeRule.onNodeWithText("附近").performClick()
        assertNull(opt)
    }

    /** 同时仅一列展开：展开第二列时第一列自动折叠。 */
    @Test
    fun test_同时仅一列展开() {
        composeRule.setContent {
            Box(Modifier.fillMaxSize().height(400.dp)) {
                Menu(columns = columns, onChange = { _, _ -> })
            }
        }
        composeRule.onNodeWithText("排序").performClick()
        composeRule.onNodeWithText("默认").assertIsDisplayed()
        composeRule.onNodeWithText("筛选").performClick()
        // 排序列的 options 应折叠
        composeRule.onNodeWithText("全部").assertIsDisplayed()
    }
}
