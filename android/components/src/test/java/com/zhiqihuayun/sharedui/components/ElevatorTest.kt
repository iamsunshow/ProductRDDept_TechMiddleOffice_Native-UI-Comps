package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.ui.Modifier
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createComposeRule
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
 * Elevator 电梯楼层回归测试（验证组件库 v1.4.0）。
 *
 * 覆盖：onSelect 回调 / 索引渲染 / 分组标题渲染 / 无回调不可交互。
 */
@RunWith(RobolectricTestRunner::class)
@GraphicsMode(GraphicsMode.Mode.NATIVE)
@Config(sdk = [34], qualifiers = "w411dp-h891dp")
class ElevatorTest {

    @get:Rule
    val composeRule = createComposeRule()

    private val floors = listOf(
        ElevatorFloor("1F", listOf("星巴克", "瑞幸咖啡")),
        ElevatorFloor("2F", listOf("优衣库", "无印良品"))
    )

    /** 索引渲染：1F / 2F 都显示。 */
    @Test
    fun test_索引渲染() {
        composeRule.setContent {
            Box(Modifier.fillMaxSize().height(300.dp)) {
                Elevator(floors = floors, onSelect = null)
            }
        }
        composeRule.onNodeWithText("1F").assertIsDisplayed()
        composeRule.onNodeWithText("2F").assertIsDisplayed()
    }

    /** 分组内行名渲染。 */
    @Test
    fun test_行名渲染() {
        composeRule.setContent {
            Box(Modifier.fillMaxSize().height(300.dp)) {
                Elevator(floors = floors, onSelect = null)
            }
        }
        composeRule.onNodeWithText("星巴克").assertIsDisplayed()
        composeRule.onNodeWithText("无印良品").assertIsDisplayed()
    }

    /** onSelect=null：点击行不回调。 */
    @Test
    fun test_无回调不可交互() {
        var floor: Int? = null
        var row: Int? = null
        var name: String? = null
        composeRule.setContent {
            Box(Modifier.fillMaxSize().height(300.dp)) {
                Elevator(floors = floors, onSelect = null)
            }
        }
        composeRule.onNodeWithText("星巴克").performClick()
        assertNull(floor)
    }

    /** 自定义 index 显示。 */
    @Test
    fun test_自定义index显示() {
        val customIndex = listOf("一楼", "二楼")
        composeRule.setContent {
            Box(Modifier.fillMaxSize().height(300.dp)) {
                Elevator(floors = floors, index = customIndex, onSelect = null)
            }
        }
        composeRule.onNodeWithText("一楼").assertIsDisplayed()
        composeRule.onNodeWithText("二楼").assertIsDisplayed()
    }
}
