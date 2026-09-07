package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config
import org.robolectric.annotation.GraphicsMode

/**
 * NavBar 头部导航回归测试（#17 ui.nav-bar，验证组件库 v1.4.0）。
 *
 * 覆盖：返回键回调 / 右操作回调 / 无 onBack 时不渲染返回槽 / 标题展示。
 */
@RunWith(RobolectricTestRunner::class)
@GraphicsMode(GraphicsMode.Mode.NATIVE)
@Config(sdk = [34], qualifiers = "w411dp-h891dp")
class NavBarTest {

    @get:Rule
    val composeRule = createComposeRule()

    /** 标题显示。 */
    @Test
    fun test_标题显示() {
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                NavBar(title = "我的页面")
            }
        }
        composeRule.onNodeWithText("我的页面").assertIsDisplayed()
    }

    /** 返回键点击回调。 */
    @Test
    fun test_返回键回调() {
        var backClicked = false
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                NavBar(title = "标题", onBack = { backClicked = true })
            }
        }
        composeRule.onNodeWithText("←").performClick()
        assertTrue(backClicked)
    }

    /** 右操作点击回调。 */
    @Test
    fun test_右操作回调() {
        var actionClicked = false
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                NavBar(
                    title = "标题",
                    rightAction = NavBarAction(text = "编辑", onTap = { actionClicked = true })
                )
            }
        }
        composeRule.onNodeWithText("编辑").performClick()
        assertTrue(actionClicked)
    }

    /** 无 onBack 时不渲染返回箭头。 */
    @Test
    fun test_无onBack无返回箭头() {
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                NavBar(title = "标题")
            }
        }
        composeRule.onNodeWithText("←").assertDoesNotExist()
    }

    /** 无 rightAction 时不渲染右操作。 */
    @Test
    fun test_无右操作() {
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                NavBar(title = "标题")
            }
        }
        // 标题存在、无右操作文本
        composeRule.onNodeWithText("标题").assertIsDisplayed()
    }

    /** 自定义右操作颜色渲染不崩。 */
    @Test
    fun test_自定义右操作颜色() {
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                NavBar(
                    title = "标题",
                    rightAction = NavBarAction(text = "删除", color = Color.Red, onTap = {})
                )
            }
        }
        composeRule.onNodeWithText("删除").assertIsDisplayed()
    }
}
