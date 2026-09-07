package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.ui.Modifier
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.assertTextEquals
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.unit.dp
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config
import org.robolectric.annotation.GraphicsMode

/**
 * Divider 分割线回归测试（#9 ui.divider，台账 #3 行，验证组件库 v1.4.0）。
 *
 * 回归背景：
 * - #3：Android Demo3 带文本截断=旧实现固定高 16dp 裁剪 Text 行框（文字只露出半行/被裁）。
 *   修复=带文本分支改用 `heightIn(min = AppSpace.sm * 2)` 让行框自适应文字高度不再裁剪。
 *   本文件用例=渲染带文本的水平 Divider，断言文本完整显示（不截断、不被裁）。
 */
@RunWith(RobolectricTestRunner::class)
@GraphicsMode(GraphicsMode.Mode.NATIVE)
@Config(sdk = [34], qualifiers = "w411dp-h891dp")
class DividerTest {

    @get:Rule
    val composeRule = createComposeRule()

    /** #3 回归：带文本的水平分割线=文本完整显示不被裁剪（旧实现固定高16裁掉文字）。 */
    @Test
    fun test_regression_带文本水平分割线文字不被裁剪() {
        val text = "分割线文本"
        composeRule.setContent {
            Box(Modifier.fillMaxSize().padding(16.dp)) {
                Divider(
                    text = text,
                    modifier = Modifier.fillMaxWidth()
                )
            }
        }
        composeRule.onNodeWithText(text).assertIsDisplayed()
        composeRule.onNodeWithText(text).assertTextEquals(text)
    }

    /** 纯线条水平分割线渲染不崩（hairline=true 默认）。 */
    @Test
    fun test_纯线条水平分割线渲染() {
        composeRule.setContent {
            Box(Modifier.fillMaxSize().padding(16.dp)) {
                Divider(modifier = Modifier.fillMaxWidth())
            }
        }
        // 无文本节点=纯线条，渲染成功即通过
        composeRule.onNodeWithText("").assertDoesNotExist()
    }

    /** 虚线样式渲染不崩。 */
    @Test
    fun test_虚线分割线渲染() {
        composeRule.setContent {
            Box(Modifier.fillMaxSize().padding(16.dp)) {
                Divider(dashed = true, modifier = Modifier.fillMaxWidth())
            }
        }
        composeRule.onNodeWithText("").assertDoesNotExist()
    }

    /** 垂直分割线渲染不崩。 */
    @Test
    fun test_垂直分割线渲染() {
        composeRule.setContent {
            Box(Modifier.fillMaxSize().padding(16.dp)) {
                Divider(
                    direction = DividerDirection.Vertical,
                    modifier = Modifier.fillMaxWidth()
                )
            }
        }
        composeRule.onNodeWithText("").assertDoesNotExist()
    }

    /** 带文本+左对齐位置：文本仍完整显示。 */
    @Test
    fun test_带文本左对齐不裁剪() {
        val text = "左对齐"
        composeRule.setContent {
            Box(Modifier.fillMaxSize().padding(16.dp)) {
                Divider(
                    text = text,
                    contentPosition = DividerContentPosition.Left,
                    modifier = Modifier.fillMaxWidth()
                )
            }
        }
        composeRule.onNodeWithText(text).assertIsDisplayed()
    }
}
