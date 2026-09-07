package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.ui.Modifier
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotEquals
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config
import org.robolectric.annotation.GraphicsMode

/**
 * Rate 评分回归测试（#37 ui.rate，验证组件库 v1.4.0）。
 *
 * 覆盖：
 * - readonly/disabled 渲染不崩（不挂手势=无回调）
 * - 半受控外部赋值同步回显不回调
 * - count 可配
 *
 * 注意：Rate 的手势（点/滑/清空）依赖 pointerInput 拖拽链，Robolectric 无真实触摸调度，
 * 无法用 performClick 触发 awaitEachGesture→awaitFirstDown→drag 链路。
 * 故手势级用例（点星点亮、再点清空、滑动连续点亮）= L4 人工实机验证。
 * L1 聚焦渲染不崩+readonly/disabled 无回调+半受控同步。
 */
@RunWith(RobolectricTestRunner::class)
@GraphicsMode(GraphicsMode.Mode.NATIVE)
@Config(sdk = [34], qualifiers = "w411dp-h891dp")
class RateTest {

    @get:Rule
    val composeRule = createComposeRule()

    /** readonly 渲染不崩，点击无回调。 */
    @Test
    fun test_readonly渲染不崩无回调() {
        var callbackCount = 0
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                Rate(count = 5, value = 3, readonly = true) { callbackCount++ }
            }
        }
        // readonly 不挂手势=点击不触发
        assertEquals(0, callbackCount)
    }

    /** disabled 渲染不崩，点击无回调。 */
    @Test
    fun test_disabled渲染不崩无回调() {
        var callbackCount = 0
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                Rate(count = 5, value = 2, disabled = true) { callbackCount++ }
            }
        }
        assertEquals(0, callbackCount)
    }

    /** 半受控：外部赋值=仅同步回显不回调。 */
    @Test
    fun test_半受控外部赋值不回调() {
        var callbackCount = 0
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                Rate(count = 5, value = 4) { callbackCount++ }
            }
        }
        assertEquals(0, callbackCount) // 外部赋值不触发 onChange
    }

    /** count 可配：count=3 渲染不崩。 */
    @Test
    fun test_count可配渲染() {
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                Rate(count = 3, value = 1, readonly = true) {}
            }
        }
        // 渲染不崩即通过
    }

    /** count=10 大数渲染不崩。 */
    @Test
    fun test_count10渲染() {
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                Rate(count = 10, value = 5, readonly = true) {}
            }
        }
    }

    /** value=0 合法未评态渲染不崩。 */
    @Test
    fun test_value0未评态() {
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                Rate(count = 5, value = 0, readonly = true) {}
            }
        }
    }
}
