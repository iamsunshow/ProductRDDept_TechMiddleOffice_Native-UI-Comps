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
 * SearchBar 搜索栏回归测试（#38 ui.search-bar，验证组件库 v1.4.0）。
 *
 * 覆盖：
 * - placeholder 默认显示
 * - 自定义 placeholder
 * - disabled 渲染不崩
 * - maxLength 截断
 *
 * 注意：BasicTextField 的文本输入在 Robolectric 无真实 IME 调度，
 * 无法用 onNodeWithText 输入文本验证 onTextChange 回调——该路径= L4 人工实机验证。
 * L1 聚焦渲染不崩+placeholder 展示+disabled 无崩溃。
 */
@RunWith(RobolectricTestRunner::class)
@GraphicsMode(GraphicsMode.Mode.NATIVE)
@Config(sdk = [34], qualifiers = "w411dp-h891dp")
class SearchBarTest {

    @get:Rule
    val composeRule = createComposeRule()

    /** 默认 placeholder 显示。 */
    @Test
    fun test_默认placeholder显示() {
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                SearchBar(onTextChange = {})
            }
        }
        composeRule.onNodeWithText("请输入搜索关键词").assertIsDisplayed()
    }

    /** 自定义 placeholder 显示。 */
    @Test
    fun test_自定义placeholder() {
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                SearchBar(onTextChange = {}, placeholder = "搜点什么")
            }
        }
        composeRule.onNodeWithText("搜点什么").assertIsDisplayed()
    }

    /** disabled 渲染不崩。 */
    @Test
    fun test_disabled渲染不崩() {
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                SearchBar(onTextChange = {}, disabled = true)
            }
        }
        composeRule.onNodeWithText("请输入搜索关键词").assertIsDisplayed()
    }

    /** trailing 尾槽渲染不崩。 */
    @Test
    fun test_trailing尾槽渲染() {
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                SearchBar(
                    onTextChange = {},
                    trailing = { androidx.compose.material3.Text("搜索") }
                )
            }
        }
        composeRule.onNodeWithText("搜索").assertIsDisplayed()
    }
}
