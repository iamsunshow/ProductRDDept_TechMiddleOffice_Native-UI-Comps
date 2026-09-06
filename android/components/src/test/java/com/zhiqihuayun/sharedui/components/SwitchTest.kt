package com.zhiqihuayun.sharedui.components

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.compose.ui.test.assertIsNotEnabled
import androidx.compose.ui.test.click
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.performClick
import androidx.compose.ui.test.performTouchInput
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config
import org.robolectric.annotation.GraphicsMode

/**
 * Switch 半受控语义回归测试（#41 ui.switch，门禁 B 基线，验证组件库 v1.4.0）。
 *
 * 回归背景：Switch 半受控 checked: Boolean? 双路径（内部自持点按翻转 / 外部赋值仅回显）
 * 语义必须严格一致，否则双端 demo 与真实宿主行为漂移（相关 commit 见组件进度 #41 行）。
 * 本文件=首批回归补测（回归测试台账 #31 同源语义族），运行：
 * `cd android && ./gradlew :components:testDebugUnitTest`
 */
@RunWith(RobolectricTestRunner::class)
@GraphicsMode(GraphicsMode.Mode.NATIVE)
@Config(sdk = [34], qualifiers = "w411dp-h891dp")
class SwitchTest {

    @get:Rule
    val composeRule = createComposeRule()

    /** 半受控 nil=内部自持：点按必须双向翻转并逐次回调 true/false（on→off 与 off→on 均回调）。 */
    @Test
    fun test_regression_nil自持点按翻转双向回调() {
        val clicks = mutableListOf<Boolean>()
        composeRule.setContent {
            Switch(checked = null, onCheckedChange = { clicks.add(it) })
        }
        composeRule.onNodeWithTag("switch-root").performClick()
        composeRule.waitForIdle()
        assertEquals(listOf(true), clicks)
        composeRule.onNodeWithTag("switch-root").performClick()
        composeRule.waitForIdle()
        assertEquals(listOf(true, false), clicks)
    }

    /** 半受控外部赋值 checked：仅同步回显，绝不触发 onCheckedChange（否则受控外部驱动会死循环/误回调）。 */
    @Test
    fun test_regression_外部赋值仅回显不触发回调() {
        var ext by mutableStateOf(false)
        val clicks = mutableListOf<Boolean>()
        composeRule.setContent {
            Switch(checked = ext, onCheckedChange = { clicks.add(it) })
        }
        composeRule.runOnIdle { ext = true }
        composeRule.waitForIdle()
        composeRule.runOnIdle { ext = false }
        composeRule.waitForIdle()
        assertTrue("外部赋值不得触发 onCheckedChange", clicks.isEmpty())
    }

    /** 外部 checked 驱动到开态后，用户点按仍走内部翻转+回调（状态机不被外部值锁死）。 */
    @Test
    fun test_regression_外部驱动后点按仍回调() {
        var ext by mutableStateOf(true)
        val clicks = mutableListOf<Boolean>()
        composeRule.setContent {
            Switch(checked = ext, onCheckedChange = { clicks.add(it); ext = it })
        }
        composeRule.waitForIdle()
        composeRule.onNodeWithTag("switch-root").performClick()
        composeRule.waitForIdle()
        assertEquals(listOf(false), clicks)
    }

    /** disabled：整件不可点、无回调（含 on 态只读，不允许任何路径触发 onChange）。 */
    @Test
    fun test_regression_禁用不可点无回调() {
        val clicks = mutableListOf<Boolean>()
        composeRule.setContent {
            Switch(checked = false, onCheckedChange = { clicks.add(it) }, disabled = true)
        }
        composeRule.onNodeWithTag("switch-root").assertIsNotEnabled()
        composeRule.onNodeWithTag("switch-root").performTouchInput { click() }
        composeRule.waitForIdle()
        assertTrue("disabled 下点按不得回调", clicks.isEmpty())
    }
}
