package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.test.click
import androidx.compose.ui.test.down
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.moveTo
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.performTouchInput
import androidx.compose.ui.test.up
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config
import org.robolectric.annotation.GraphicsMode

/**
 * Range 区间选择回归测试（#36 ui.range，#30 台账行，验证组件库 v1.4.0）。
 *
 * 回归背景：
 * - #30（Range 历史问题）：Android demo 无法操作=拖动手势串行陷阱 + pointerInput key 误含受控 value
 *   （每帧 onChange→宿主回写→recompose→手势协程被取消=第二次 move 零回调=拖动即断）。
 *   修复=手势统一 awaitEachGesture 单自旋；key 仅放 min/max/step/disabled。
 *   本文件用例以「受控回写 + 连续拖动多帧回调」复现该场景=若 key 再含 value 用例即失败。
 * - start≤end 硬钳制：滑块越界一律 coerce 回合法区间（闭区间、可相等零宽单点）。
 * - disabled：整条灰不可点无回调。
 */
@RunWith(RobolectricTestRunner::class)
@GraphicsMode(GraphicsMode.Mode.NATIVE)
@Config(sdk = [34], qualifiers = "w411dp-h891dp")
class RangeTest {

    @get:Rule
    val composeRule = createComposeRule()

    /** Range 根节点当前像素尺寸（该 compose 版本无 PercentOffset 便捷类=触摸坐标改用 Offset 像素换算）。 */
    private fun rootPx() = composeRule.onNodeWithTag("range-root").fetchSemanticsNode().size

    /** 点击吸附：点轨道空段=吸附最近滑块并回调（值域 [0,100]，点 25% → start 吸附到 25）。 */
    @Test
    fun test_regression_点击吸附最近滑块() {
        var last: RangeValue? = null
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                Range(
                    value = RangeValue(0.0, 100.0),
                    onValueChange = { last = it },
                    modifier = Modifier.testTag("range-root")
                )
            }
        }
        val px = rootPx()
        composeRule.onNodeWithTag("range-root").performTouchInput {
            click(Offset(px.width * 0.25f, px.height * 0.5f))
        }
        composeRule.waitForIdle()
        assertEquals("点 25% 应吸附 start=25", 25.0, last!!.start, 1e-6)
        assertEquals("end 保持 100", 100.0, last!!.end, 1e-6)
    }

    /**
     * 受控回写下连续拖动多帧回调（#30 关键防复燃）：
     * down + 连续 moveTo（每帧 onChange 回写宿主 state），若手势被 recompose 打断则后续 move 零回调。
     */
    @Test
    fun test_regression_受控回写下拖动连续回调不中断() {
        val events = mutableListOf<RangeValue>()
        var state by mutableStateOf(RangeValue(20.0, 80.0))
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                Range(
                    value = state,
                    onValueChange = {
                        state = it
                        events.add(it)
                    },
                    modifier = Modifier.testTag("range-root")
                )
            }
        }
        val px = rootPx()
        composeRule.onNodeWithTag("range-root").performTouchInput {
            down(Offset(px.width * 0.5f, px.height * 0.5f))     // 吸附 start（50 与 start/end 等距取 start）
            moveTo(Offset(px.width * 0.65f, px.height * 0.5f))  // start→65
            moveTo(Offset(px.width * 0.9f, px.height * 0.5f))   // start→90 越 end=80 → 钳制 (80,80)
            moveTo(Offset(px.width * 0.3f, px.height * 0.5f))   // start→30
            up()
        }
        composeRule.waitForIdle()
        assertTrue("拖动应连续回调多帧（受控回写不得打断手势），实收 ${events.size} 次", events.size >= 3)
        assertTrue("每帧回调 start≤end 恒成立", events.all { it.start <= it.end })
        assertEquals(30.0, events.last().start, 1e-6)
        assertEquals(80.0, events.last().end, 1e-6)
    }

    /** 滑块越界钳制：拖 start 越过 end → start 被钳到 end（可相等=零宽单点），绝不允许 start>end。 */
    @Test
    fun test_regression_start永不超过end硬钳制() {
        val events = mutableListOf<RangeValue>()
        var state by mutableStateOf(RangeValue(40.0, 60.0))
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                Range(
                    value = state,
                    onValueChange = {
                        state = it
                        events.add(it)
                    },
                    modifier = Modifier.testTag("range-root")
                )
            }
        }
        val px = rootPx()
        composeRule.onNodeWithTag("range-root").performTouchInput {
            down(Offset(px.width * 0.2f, px.height * 0.5f))     // 吸附 start → 20
            moveTo(Offset(px.width * 0.9f, px.height * 0.5f))   // start→90 越 end=60 → 钳制 (60,60)
            moveTo(Offset(px.width * 0.1f, px.height * 0.5f))   // start→10
            up()
        }
        composeRule.waitForIdle()
        assertTrue("全序列 start≤end 恒成立", events.all { it.start <= it.end })
        assertEquals(60.0, events[1].start, 1e-6)
        assertEquals(60.0, events[1].end, 1e-6)
        assertEquals(10.0, events.last().start, 1e-6)
    }

    /** disabled：整条灰不可点不可拖=零回调。 */
    @Test
    fun test_regression_disabled零回调() {
        val events = mutableListOf<RangeValue>()
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                Range(
                    value = RangeValue(0.0, 100.0),
                    onValueChange = { events.add(it) },
                    disabled = true,
                    modifier = Modifier.testTag("range-root")
                )
            }
        }
        val px = rootPx()
        composeRule.onNodeWithTag("range-root").performTouchInput {
            click(Offset(px.width * 0.5f, px.height * 0.5f))
            click(Offset(px.width * 0.2f, px.height * 0.5f))
        }
        composeRule.waitForIdle()
        assertTrue("disabled 必须零回调", events.isEmpty())
    }
}
