package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.width
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import androidx.compose.ui.test.performTouchInput
import androidx.compose.ui.test.click
import androidx.compose.ui.unit.dp
import kotlin.math.abs
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config
import org.robolectric.annotation.GraphicsMode

/**
 * Tabbar 回归测试（#19 ui.tabbar，#20 台账行，验证组件库 v1.4.0）。
 *
 * 回归背景（#20，Android 侧）：
 * ①角标不在图标右上且数字不在胶囊中央=旧 align(TopCenter)+offset y=10 的 y 作用于角标上缘，
 *   整枚角标被下移 8dp（iOS top=2）；修复=offset y 改 2（上缘 2、中心 y=10）。
 * ②badge Text 默认行高额外空隙致数字视觉偏下=修复=显式 lineHeight=字号。
 * 本文件用例：
 * - 以角标数字文本中心相对栏条的几何断言锚定「角标中心 y=10dp / 锚点 cell 中心+14dp」；
 * - 半受控点按幂等：点当前项不回调、点其他项回调一次并切高亮。
 */
@RunWith(RobolectricTestRunner::class)
@GraphicsMode(GraphicsMode.Mode.NATIVE)
@Config(sdk = [34], qualifiers = "w411dp-h891dp")
class TabbarTest {

    @get:Rule
    val composeRule = createComposeRule()

    private val items = listOf(
        TabBarItem("首页", "tab1", icon = "🏠", badge = 5),
        TabBarItem("消息", "tab2", icon = "✉️"),
        TabBarItem("我的", "tab3", icon = "👤", badge = 2),
        TabBarItem("设置", "tab4", icon = "⚙️"),
    )

    /** 角标锚点：0 号 cell 的角标中心应 ≈ cell 水平中心 +14dp、距栏顶 10dp（旧 offset y=10 会变 18dp）。 */
    @Test
    fun test_regression_角标锚定图标右上中心() {
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                Tabbar(
                    items = items,
                    onChange = {},
                    modifier = Modifier.testTag("tabbar-root").width(400.dp)
                )
            }
        }
        val bar = composeRule.onNodeWithTag("tabbar-root").fetchSemanticsNode()
        // 取 0 号 cell 角标数字文本（unmerged 避免被 cell 合并吞掉几何）
        val badge = composeRule.onNodeWithText("5", useUnmergedTree = true).fetchSemanticsNode()
        val d = composeRule.density
        val cellCenterX = bar.positionInRoot.x + bar.size.width / 8f // 4 等分第 0 格中心
        val expectX = cellCenterX + with(d) { 14.dp.toPx() }
        val expectY = bar.positionInRoot.y + with(d) { 10.dp.toPx() } // 角标中心 y=上缘2+半高8
        val badgeCX = badge.positionInRoot.x + badge.size.width / 2f
        val badgeCY = badge.positionInRoot.y + badge.size.height / 2f
        val tol = with(d) { 2.dp.toPx() }
        assertTrue("角标中心 x=$badgeCX 应≈$expectX（cell 中心+14dp）", abs(badgeCX - expectX) <= tol)
        assertTrue("角标中心 y=$badgeCY 应≈$expectY（顶 2 半高 8；旧 offset y=10 为 18）", abs(badgeCY - expectY) <= tol)
    }

    /** 半受控点击：点当前激活项幂等不回调、点其他项回调一次。 */
    @Test
    fun test_半受控点击切换() {
        val calls = mutableListOf<String>()
        composeRule.setContent {
            Tabbar(items = items, onChange = { calls.add(it) })
        }
        // 当前内部选中=首个启用项「首页」，重复点它应幂等
        composeRule.onNodeWithText("首页").performClick()
        composeRule.waitForIdle()
        assertEquals("点当前激活项不得重复回调", 0, calls.size)

        // 点「消息」→ 切换回调一次
        composeRule.onNodeWithText("消息").performClick()
        composeRule.waitForIdle()
        assertEquals(listOf("tab2"), calls)

        // 再点「消息」（此时已激活）→ 幂等
        composeRule.onNodeWithText("消息").performClick()
        composeRule.waitForIdle()
        assertEquals("已激活项再点幂等", 1, calls.size)
    }
}
