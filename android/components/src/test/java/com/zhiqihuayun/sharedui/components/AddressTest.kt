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
 * Address 地址选择回归测试（验证组件库 v1.4.0）。
 *
 * 覆盖：点非叶子=下钻 / 点叶子=onChange 回传 / 禁用节点不可交互 / tab 回滚。
 */
@RunWith(RobolectricTestRunner::class)
@GraphicsMode(GraphicsMode.Mode.NATIVE)
@Config(sdk = [34], qualifiers = "w411dp-h891dp")
class AddressTest {

    @get:Rule
    val composeRule = createComposeRule()

    private val options = listOf(
        RegionOption("110000", "北京市", children = listOf(
            RegionOption("110100", "市辖区", children = listOf(
                RegionOption("110101", "东城区"),
                RegionOption("110102", "西城区")
            ))
        )),
        RegionOption("120000", "天津市"),
        RegionOption("130000", "河北省", disabled = true)
    )

    /** 点非叶子=下钻显示子级。 */
    @Test
    fun test_点非叶子下钻() {
        composeRule.setContent {
            Box(Modifier.fillMaxSize().height(400.dp)) {
                Address(options = options, onChange = {})
            }
        }
        composeRule.onNodeWithText("北京市").assertIsDisplayed()
        composeRule.onNodeWithText("北京市").performClick()
        composeRule.onNodeWithText("市辖区").assertIsDisplayed()
    }

    /** 点叶子=onChange 回传 AddressResult。 */
    @Test
    fun test_点叶子回传结果() {
        var result: AddressResult? = null
        composeRule.setContent {
            Box(Modifier.fillMaxSize().height(400.dp)) {
                Address(options = options, onChange = { result = it })
            }
        }
        composeRule.onNodeWithText("北京市").performClick()
        composeRule.onNodeWithText("市辖区").performClick()
        composeRule.onNodeWithText("东城区").performClick()
        assertEquals(listOf("110000", "110100", "110101"), result?.codes)
        assertEquals("北京市 市辖区 东城区", result?.text)
    }

    /** 禁用节点不可交互。 */
    @Test
    fun test_禁用节点不可交互() {
        var result: AddressResult? = null
        composeRule.setContent {
            Box(Modifier.fillMaxSize().height(400.dp)) {
                Address(options = options, onChange = { result = it })
            }
        }
        composeRule.onNodeWithText("河北省").performClick()
        assertNull(result)
    }

    /** tab 回滚：点击已选中层 tab 可回退。 */
    @Test
    fun test_tab回滚() {
        composeRule.setContent {
            Box(Modifier.fillMaxSize().height(400.dp)) {
                Address(options = options, onChange = {})
            }
        }
        composeRule.onNodeWithText("北京市").performClick()
        composeRule.onNodeWithText("市辖区").performClick()
        composeRule.onNodeWithText("东城区").assertIsDisplayed()
        composeRule.onNodeWithText("北京市").performClick()
        composeRule.onNodeWithText("市辖区").assertIsDisplayed()
    }

    /** 半受控：外部 result 赋值=回显定位。 */
    @Test
    fun test_外部result回显() {
        val result = AddressResult(
            codes = listOf("110000", "110100", "110101"),
            names = listOf("北京市", "市辖区", "东城区"),
            text = "北京市 市辖区 东城区"
        )
        composeRule.setContent {
            Box(Modifier.fillMaxSize().height(400.dp)) {
                Address(options = options, result = result, onChange = {})
            }
        }
        composeRule.onNodeWithText("北京市").assertIsDisplayed()
    }
}
