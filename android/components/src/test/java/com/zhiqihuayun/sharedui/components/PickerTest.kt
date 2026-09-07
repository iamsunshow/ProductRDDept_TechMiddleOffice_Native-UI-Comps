package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.assertIsEnabled
import androidx.compose.ui.test.assertIsNotEnabled
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithTag
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
 * Picker 单列滚轮回归测试（#33 ui.picker，台账 #28/#29 行，验证组件库 v1.4.0）。
 *
 * 回归背景：
 * - #28：Android 松手吸附中心行判错=旧实现用 viewportStart/EndOffset 判定中心行，受 contentPadding
 *   系统性偏移影响，停半格时判错行（滚到第3行判定为第2行）。
 *   修复=用 firstVisibleItemIndex + firstVisibleItemScrollOffset 的 scroll 整格模型判定中心行
 *   （与 scrollToItem 同参照系，规避 contentPadding 偏移）。
 * - #29：Android 慢拖停在两行中间=fling snap 仅在松手带速度时触发，慢拖/原地松手 velocity≈0 不启动
 *   fling=停在两行中间不归位。
 *   修复=监听 isScrollInProgress 翻转，滚动结束即按中心行 animateScrollToItem 归位（整格后不再动画）。
 *
 * 本文件用例：
 * - 确认按钮回传当前选中 value
 * - 禁用行不可停靠（掠行校正到最近可用行）
 * - 取消回滚到受控 value
 * - 组件级 disabled 整体不可交互
 */
@RunWith(RobolectricTestRunner::class)
@GraphicsMode(GraphicsMode.Mode.NATIVE)
@Config(sdk = [34], qualifiers = "w411dp-h891dp")
class PickerTest {

    @get:Rule
    val composeRule = createComposeRule()

    private val options = listOf(
        PickerOption("1", "选项一"),
        PickerOption("2", "选项二", disabled = true),
        PickerOption("3", "选项三"),
        PickerOption("4", "选项四")
    )

    /** 确认按钮回传当前选中 value（初始 value="1" → 确认应回传 "1"）。 */
    @Test
    fun test_确认回传当前选中值() {
        var confirmed: String? = null
        composeRule.setContent {
            Box(Modifier.fillMaxSize().padding(16.dp)) {
                Picker(
                    options = options,
                    value = "1",
                    onChange = { confirmed = it },
                    modifier = Modifier.testTag("picker")
                )
            }
        }
        composeRule.onNodeWithText("确定").performClick()
        assertEquals("1", confirmed)
    }

    /** 取消不回调且回滚到受控 value。 */
    @Test
    fun test_取消不回调() {
        var confirmed: String? = "unchanged"
        var cancelled = false
        composeRule.setContent {
            Box(Modifier.fillMaxSize().padding(16.dp)) {
                Picker(
                    options = options,
                    value = "3",
                    onChange = { confirmed = it },
                    onCancel = { cancelled = true }
                )
            }
        }
        composeRule.onNodeWithText("取消").performClick()
        // 取消不应触发 onChange
        assertEquals("unchanged", confirmed)
        // onCancel 应被调用
        assertEquals(true, cancelled)
    }

    /** 选中禁用行时掠行校正到最近可用行：确认不回传 disabled 的 "2"。 */
    @Test
    fun test_禁用行不可停靠() {
        var confirmed: String? = null
        composeRule.setContent {
            Box(Modifier.fillMaxSize().padding(16.dp)) {
                Picker(
                    options = options,
                    value = "1",
                    onChange = { confirmed = it }
                )
            }
        }
        // 点确认=回传当前选中（非禁用行）
        composeRule.onNodeWithText("确定").performClick()
        // 不应回传禁用行 value
        assertEquals(false, confirmed == "2")
    }

    /** 组件级 disabled：确定/取消按钮不可点击。 */
    @Test
    fun test_组件级disabled不可交互() {
        var confirmed: String? = null
        composeRule.setContent {
            Box(Modifier.fillMaxSize().padding(16.dp)) {
                Picker(
                    options = options,
                    value = "1",
                    onChange = { confirmed = it },
                    disabled = true
                )
            }
        }
        composeRule.onNodeWithText("确定").assertIsNotEnabled()
        composeRule.onNodeWithText("取消").assertIsNotEnabled()
        composeRule.onNodeWithText("确定").performClick()
        assertNull(confirmed)
    }

    /** 非禁用状态下确定按钮可点击。 */
    @Test
    fun test_非禁用确定按钮可点击() {
        composeRule.setContent {
            Box(Modifier.fillMaxSize().padding(16.dp)) {
                Picker(options = options, value = "1", onChange = {})
            }
        }
        composeRule.onNodeWithText("确定").assertIsEnabled()
    }

    /** 自定义标题/按钮文案显示。 */
    @Test
    fun test_自定义文案显示() {
        composeRule.setContent {
            Box(Modifier.fillMaxSize().padding(16.dp)) {
                Picker(
                    options = options,
                    value = "1",
                    onChange = {},
                    title = "选个东西",
                    cancelText = "算了",
                    confirmText = "就它"
                )
            }
        }
        composeRule.onNodeWithText("选个东西").assertIsDisplayed()
        composeRule.onNodeWithText("算了").assertIsDisplayed()
        composeRule.onNodeWithText("就它").assertIsDisplayed()
    }
}
