package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import androidx.compose.ui.unit.dp
import kotlin.math.abs
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
 * FixedNav 回归测试（#15 ui.fixed-nav，#13 台账行，验证组件库 v1.4.0）。
 *
 * 回归背景（#13，Android 5 类问题修复）：
 * ①面板通栏=面板列缺 width(IntrinsicSize.Min) 时行 fillMaxSize 撑到父级全宽
 *   → 修复=面板列 IntrinsicSize.Min、行 fillMaxWidth 内容宽（≥140）；
 * ②数字截断/紧贴标题=行内无 spacer weight 推行尾 → 修复=title 后 Spacer(weight=1f)（margin-left:auto）；
 * ③面板行可点、点项回调后自动收起（onSelect + onExpandedChange(false)）。
 * 本文件用例：面板内容宽不占满全屏、行等宽、行高 44、角标被 spacer 推离标题、点行回调并收起。
 */
@RunWith(RobolectricTestRunner::class)
@GraphicsMode(GraphicsMode.Mode.NATIVE)
@Config(sdk = [34], qualifiers = "w411dp-h891dp")
class FixedNavTest {

    @get:Rule
    val composeRule = createComposeRule()

    private val items = listOf(
        FixedNavItem("home", "首页", icon = "⌂", num = 2),
        FixedNavItem("settings", "系统设置与关于我们", num = 5),
    )

    /** 面板内容宽（不占满全屏）+ 各行等宽（列宽由最长行决定）+ 行高 44。 */
    @Test
    fun test_regression_面板不占满屏行等宽() {
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                FixedNav(items = items, expanded = true, onExpandedChange = {}, onSelect = {})
            }
        }
        val r0 = composeRule.onNodeWithTag("fixednav-row-0").fetchSemanticsNode()
        val r1 = composeRule.onNodeWithTag("fixednav-row-1").fetchSemanticsNode()
        val d = composeRule.density
        val widthLimit = with(d) { 320.dp.toPx() } // 屏宽 411dp，内容面板应在 320dp 内
        assertTrue("面板行宽 ${r1.size.width}px 应远小于屏宽（通栏 bug 会占满）", r1.size.width < widthLimit)
        assertTrue("行 0 宽=${r0.size.width} 行 1 宽=${r1.size.width} 应等宽（列宽=最长行）",
            abs(r0.size.width - r1.size.width) <= with(d) { 1.dp.toPx() })
        assertTrue("行高 ${r0.size.height}px 应≈44dp", abs(r0.size.height - with(d) { 44.dp.toPx() }) <= with(d) { 1.dp.toPx() })
        composeRule.onNodeWithTag("fixednav-row-0").assertExists()
        composeRule.onNodeWithTag("fixednav-row-1").assertExists()
    }

    /** 数字角标被 spacer 推到行尾（不紧贴标题/不截断）：角标文本左缘应离标题右缘足够远。 */
    @Test
    fun test_regression_数字被推到行尾不紧贴标题() {
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                FixedNav(items = items, expanded = true, onExpandedChange = {}, onSelect = {})
            }
        }
        val title = composeRule.onNodeWithText("首页", useUnmergedTree = true).fetchSemanticsNode()
        val num = composeRule.onNodeWithText("2", useUnmergedTree = true).fetchSemanticsNode()
        val titleRight = title.positionInRoot.x + title.size.width
        val numLeft = num.positionInRoot.x
        val d = composeRule.density
        assertTrue(
            "角标左缘($numLeft)应远离标题右缘($titleRight)（紧贴/截断 bug）",
            numLeft - titleRight > with(d) { 24.dp.toPx() }
        )
    }

    /** 点面板行：onSelect 回调该项并自动收起（expanded→false，面板消失）。 */
    @Test
    fun test_点行回调并收起() {
        var expanded by mutableStateOf(true)
        var selected: FixedNavItem? = null
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                FixedNav(
                    items = items,
                    expanded = expanded,
                    onExpandedChange = { expanded = it },
                    onSelect = { selected = it }
                )
            }
        }
        composeRule.onNodeWithTag("fixednav-row-0").performClick()
        composeRule.waitForIdle()
        assertEquals("home", selected?.key)
        assertFalse("点项后应自动收起", expanded)
        composeRule.onNodeWithTag("fixednav-row-0").assertDoesNotExist()
    }
}
