package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.ui.Modifier
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import org.junit.Assert.assertEquals
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config
import org.robolectric.annotation.GraphicsMode

/**
 * SegmentControl 分段控件回归测试（#31 ui.segment-control，验证组件库 v1.4.0）。
 *
 * 覆盖：
 * - 分段切换回调（点击未选段=回传 index）
 * - 幂等（点已选段不回调）
 * - 多段渲染不崩
 */
@RunWith(RobolectricTestRunner::class)
@GraphicsMode(GraphicsMode.Mode.NATIVE)
@Config(sdk = [34], qualifiers = "w411dp-h891dp")
class SegmentControlTest {

    @get:Rule
    val composeRule = createComposeRule()

    private val options = listOf("日榜", "周榜", "月榜")

    /** 分段切换：点未选段=回传 index。 */
    @Test
    fun test_分段切换回调() {
        var selected = 0
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                SegmentControl(options = options, selectedIndex = 0, onSelect = { selected = it })
            }
        }
        composeRule.onNodeWithText("周榜").performClick()
        assertEquals(1, selected)
    }

    /** 幂等：点已选段不回调。 */
    @Test
    fun test_幂等点已选段不回调() {
        var selected = -1
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                SegmentControl(options = options, selectedIndex = 1, onSelect = { selected = it })
            }
        }
        composeRule.onNodeWithText("周榜").performClick()
        assertEquals(-1, selected) // 已选再点=不回调
    }

    /** 切到第三段=回传 2。 */
    @Test
    fun test_切到第三段() {
        var selected = 0
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                SegmentControl(options = options, selectedIndex = 0, onSelect = { selected = it })
            }
        }
        composeRule.onNodeWithText("月榜").performClick()
        assertEquals(2, selected)
    }

    /** 所有分段文本均显示。 */
    @Test
    fun test_所有分段文本显示() {
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                SegmentControl(options = options, selectedIndex = 0, onSelect = {})
            }
        }
        composeRule.onNodeWithText("日榜").assertIsDisplayed()
        composeRule.onNodeWithText("周榜").assertIsDisplayed()
        composeRule.onNodeWithText("月榜").assertIsDisplayed()
    }

    /** 两段不崩。 */
    @Test
    fun test_两段渲染() {
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                SegmentControl(options = listOf("A", "B"), selectedIndex = 0, onSelect = {})
            }
        }
        composeRule.onNodeWithText("A").assertIsDisplayed()
        composeRule.onNodeWithText("B").assertIsDisplayed()
    }
}
