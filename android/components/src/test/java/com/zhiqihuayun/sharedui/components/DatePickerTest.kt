package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.ui.Modifier
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config
import org.robolectric.annotation.GraphicsMode
import java.util.Calendar

/**
 * DatePicker 统一日期选择回归测试（#26 ui.date-picker，验证组件库 v1.4.0）。
 *
 * 覆盖 2026-09-07 方案 B 重构：三模式(date/month/year)统一为单一 DatePicker(mode)，
 * onConfirm 归一化——month 返回该月 1 号 0 点、year 返回该年 1 月 1 号 0 点。
 *
 * 本文件用例：
 * - DATE 模式确认=回传选中日期 0 点
 * - MONTH 模式确认=回传该月 1 号 0 点（日归一化为 1）
 * - YEAR 模式确认=回传该年 1 月 1 号 0 点（月/日归一化为 1）
 * - 取消不回调
 */
@RunWith(RobolectricTestRunner::class)
@GraphicsMode(GraphicsMode.Mode.NATIVE)
@Config(sdk = [34], qualifiers = "w411dp-h891dp")
class DatePickerTest {

    @get:Rule
    val composeRule = createComposeRule()

    /** 构造指定年月日 0 点的时间戳。 */
    private fun ts(year: Int, month: Int, day: Int): Long {
        val c = Calendar.getInstance()
        c.set(year, month - 1, day, 0, 0, 0)
        c.set(Calendar.MILLISECOND, 0)
        return c.timeInMillis
    }

    /** DATE 模式：确认回传选中日期 0 点。 */
    @Test
    fun test_date模式确认回传选中日期() {
        val initial = ts(2026, 9, 7)
        var confirmed: Long? = null
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                DatePickerSheet(
                    mode = DatePickerMode.DATE,
                    initialDateMillis = initial,
                    maximumDateMillis = null,
                    onDismiss = {},
                    onConfirm = { confirmed = it }
                )
            }
        }
        composeRule.onNodeWithText("确定").assertIsDisplayed()
        composeRule.onNodeWithText("确定").performClick()
        assertEquals(initial, confirmed)
    }

    /** MONTH 模式：确认回传该月 1 号 0 点（日归一化为 1）。 */
    @Test
    fun test_month模式确认回传该月1号() {
        val initial = ts(2026, 9, 15)
        var confirmed: Long? = null
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                DatePickerSheet(
                    mode = DatePickerMode.MONTH,
                    initialDateMillis = initial,
                    onDismiss = {},
                    onConfirm = { confirmed = it }
                )
            }
        }
        composeRule.onNodeWithText("确定").performClick()
        // 期望=2026-09-01 00:00:00
        assertEquals(ts(2026, 9, 1), confirmed)
    }

    /** YEAR 模式：确认回传该年 1 月 1 号 0 点（月/日归一化为 1）。 */
    @Test
    fun test_year模式确认回传该年1月1号() {
        val initial = ts(2026, 9, 15)
        var confirmed: Long? = null
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                DatePickerSheet(
                    mode = DatePickerMode.YEAR,
                    initialDateMillis = initial,
                    onDismiss = {},
                    onConfirm = { confirmed = it }
                )
            }
        }
        composeRule.onNodeWithText("确定").performClick()
        // 期望=2026-01-01 00:00:00
        assertEquals(ts(2026, 1, 1), confirmed)
    }

    /** 取消不触发 onConfirm。 */
    @Test
    fun test_取消不回调() {
        var confirmed: Long? = -1L
        var dismissed = false
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                DatePickerSheet(
                    mode = DatePickerMode.DATE,
                    initialDateMillis = ts(2026, 9, 7),
                    onDismiss = { dismissed = true },
                    onConfirm = { confirmed = it }
                )
            }
        }
        composeRule.onNodeWithText("取消").performClick()
        assertEquals(-1L, confirmed)
    }

    /** MONTH 模式跨月边界：选中 12 月→回传 12 月 1 号。 */
    @Test
    fun test_month模式12月归一化() {
        val initial = ts(2026, 12, 25)
        var confirmed: Long? = null
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                DatePickerSheet(
                    mode = DatePickerMode.MONTH,
                    initialDateMillis = initial,
                    onDismiss = {},
                    onConfirm = { confirmed = it }
                )
            }
        }
        composeRule.onNodeWithText("确定").performClick()
        assertEquals(ts(2026, 12, 1), confirmed)
    }

    /** DATE 模式闰年 2 月：选中 2024-02-29 有效（不越界修正）。 */
    @Test
    fun test_date模式闰年2月29日有效() {
        val leap = ts(2024, 2, 29)
        var confirmed: Long? = null
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                DatePickerSheet(
                    mode = DatePickerMode.DATE,
                    initialDateMillis = leap,
                    maximumDateMillis = null,
                    onDismiss = {},
                    onConfirm = { confirmed = it }
                )
            }
        }
        composeRule.onNodeWithText("确定").performClick()
        assertEquals(leap, confirmed)
    }
}
