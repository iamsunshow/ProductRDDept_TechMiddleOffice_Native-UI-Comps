package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.ui.Modifier
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.assertIsNotEnabled
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config
import org.robolectric.annotation.GraphicsMode

/**
 * AppButton 基础按钮回归测试（验证组件库 v1.4.0）。
 *
 * 覆盖：
 * - 三样式渲染（Primary/Secondary/Destructive）
 * - 点击回调
 * - disabled 不可交互
 * - loading 不可交互+显示「加载中...」
 */
@RunWith(RobolectricTestRunner::class)
@GraphicsMode(GraphicsMode.Mode.NATIVE)
@Config(sdk = [34], qualifiers = "w411dp-h891dp")
class AppButtonTest {

    @get:Rule
    val composeRule = createComposeRule()

    /** Primary 点击回调。 */
    @Test
    fun test_primary点击回调() {
        var clicked = false
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                AppButton(text = "登录", onClick = { clicked = true })
            }
        }
        composeRule.onNodeWithText("登录").performClick()
        assertEquals(true, clicked)
    }

    /** Secondary 点击回调。 */
    @Test
    fun test_secondary点击回调() {
        var clicked = false
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                AppButton(text = "注册", style = AppButtonStyle.Secondary, onClick = { clicked = true })
            }
        }
        composeRule.onNodeWithText("注册").performClick()
        assertEquals(true, clicked)
    }

    /** Destructive 渲染不崩。 */
    @Test
    fun test_destructive渲染() {
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                AppButton(text = "删除", style = AppButtonStyle.Destructive, onClick = {})
            }
        }
        composeRule.onNodeWithText("删除").assertIsDisplayed()
    }

    /** disabled：点击不触发回调。 */
    @Test
    fun test_disabled不可交互() {
        var clicked = false
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                AppButton(text = "提交", enabled = false, onClick = { clicked = true })
            }
        }
        composeRule.onNodeWithText("提交").performClick()
        assertFalse(clicked)
    }

    /** loading：不可交互+显示「加载中...」。 */
    @Test
    fun test_loading不可交互() {
        var clicked = false
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                AppButton(text = "提交", loading = true, onClick = { clicked = true })
            }
        }
        composeRule.onNodeWithText("加载中...").assertIsDisplayed()
        composeRule.onNodeWithText("加载中...").performClick()
        assertFalse(clicked)
    }
}
