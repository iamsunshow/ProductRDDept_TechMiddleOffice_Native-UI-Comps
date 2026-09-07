package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.ui.Modifier
import androidx.compose.ui.test.assertIsDisplayed
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
import java.util.Calendar

/**
 * CalendarCard 日历卡片回归测试（验证组件库 v1.4.0）。
 *
 * 覆盖：
 * - CalendarDate 数据类：text 格式化 / value 整数编码 / today()
 * - 日期点击=onChange 回传 CalendarDate
 * - 月份导航头渲染
 * - 范围外禁用不回调（minDate/maxDate）
 */
@RunWith(RobolectricTestRunner::class)
@GraphicsMode(GraphicsMode.Mode.NATIVE)
@Config(sdk = [34], qualifiers = "w411dp-h891dp")
class CalendarCardTest {

    @get:Rule
    val composeRule = createComposeRule()

    /** CalendarDate.text 格式化=yyyy-MM-dd。 */
    @Test
    fun test_CalendarDate_text格式化() {
        val date = CalendarDate(2026, 9, 7)
        assertEquals("2026-09-07", date.text)
    }

    /** CalendarDate.value 整数编码=year*10000+month*100+day。 */
    @Test
    fun test_CalendarDate_value编码() {
        val date = CalendarDate(2026, 9, 7)
        assertEquals(20260907, date.value)
    }

    /** CalendarDate.today()=系统今天。 */
    @Test
    fun test_CalendarDate_today() {
        val cal = Calendar.getInstance()
        val expected = CalendarDate(
            cal.get(Calendar.YEAR),
            cal.get(Calendar.MONTH) + 1,
            cal.get(Calendar.DAY_OF_MONTH)
        )
        assertEquals(expected.value, CalendarDate.today().value)
    }

    /** 月份导航头显示「yyyy 年 M 月」。 */
    @Test
    fun test_月份导航头显示() {
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                CalendarCard(
                    selected = CalendarDate(2026, 9, 7),
                    onChange = {}
                )
            }
        }
        composeRule.onNodeWithText("2026 年 9 月").assertIsDisplayed()
    }

    /** 点击有效日期=onChange 回传。 */
    @Test
    fun test_点击有效日期回调() {
        var selected: CalendarDate? = null
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                CalendarCard(
                    selected = CalendarDate(2026, 9, 1),
                    onChange = { selected = it }
                )
            }
        }
        composeRule.onNodeWithText("15").performClick()
        assertEquals(15, selected?.day)
        assertEquals(2026, selected?.year)
        assertEquals(9, selected?.month)
    }

    /** minDate 限制：范围外日期点击不回调。 */
    @Test
    fun test_minDate范围外不回调() {
        var selected: CalendarDate? = null
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                CalendarCard(
                    selected = CalendarDate(2026, 9, 15),
                    minDate = CalendarDate(2026, 9, 10),
                    onChange = { selected = it }
                )
            }
        }
        // 点 5 号=范围外，不应回调
        composeRule.onNodeWithText("5").performClick()
        assertEquals(null, selected)
    }

    /** maxDate 限制：范围外日期点击不回调。 */
    @Test
    fun test_maxDate范围外不回调() {
        var selected: CalendarDate? = null
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                CalendarCard(
                    selected = CalendarDate(2026, 9, 15),
                    maxDate = CalendarDate(2026, 9, 20),
                    onChange = { selected = it }
                )
            }
        }
        composeRule.onNodeWithText("25").performClick()
        assertEquals(null, selected)
    }

    /** 翻月箭头渲染。 */
    @Test
    fun test_翻月箭头渲染() {
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                CalendarCard(
                    selected = CalendarDate(2026, 9, 7),
                    onChange = {}
                )
            }
        }
        composeRule.onNodeWithText("‹").assertIsDisplayed()
        composeRule.onNodeWithText("›").assertIsDisplayed()
    }

    /** 星期行渲染（日~六）。 */
    @Test
    fun test_星期行渲染() {
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                CalendarCard(
                    selected = CalendarDate(2026, 9, 7),
                    onChange = {}
                )
            }
        }
        composeRule.onNodeWithText("日").assertIsDisplayed()
        composeRule.onNodeWithText("一").assertIsDisplayed()
        composeRule.onNodeWithText("六").assertIsDisplayed()
    }

    /** 跨月点击=切月后日期回调。 */
    @Test
    fun test_跨月翻页后选择() {
        var selected: CalendarDate? = null
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                CalendarCard(
                    selected = CalendarDate(2026, 9, 15),
                    onChange = { selected = it }
                )
            }
        }
        composeRule.onNodeWithText("›").performClick() // 翻到 10 月
        composeRule.onNodeWithText("1").performClick()
        assertEquals(10, selected?.month)
    }
}
