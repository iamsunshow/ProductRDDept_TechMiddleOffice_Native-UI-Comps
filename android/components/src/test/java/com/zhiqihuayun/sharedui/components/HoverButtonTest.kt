package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.size
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
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
 * HoverButton 回归测试（#16 ui.hover-button，#17 台账行，验证组件库 v1.4.0）。
 *
 * 回归背景（#17）：icon-only 圆钮的 ✚ 不水平居中=inner Row 被强制 size(40) 撑满宽 +
 * horizontalArrangement=Start → 图标顶到圆钮左缘。
 * 修复：icon-only 分支 horizontalArrangement=Center。
 * 本文件用例以「图标文本中心 ≈ 圆钮中心」几何断言防复燃；pill 形态另有点击契约用例。
 */
@RunWith(RobolectricTestRunner::class)
@GraphicsMode(GraphicsMode.Mode.NATIVE)
@Config(sdk = [34], qualifiers = "w411dp-h891dp")
class HoverButtonTest {

    @get:Rule
    val composeRule = createComposeRule()

    /** icon-only 圆钮：缺省 ✚ 必须水平居中（圆心内）。 */
    @Test
    fun test_regression_iconOnly图标水平居中() {
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                HoverButton(
                    modifier = Modifier.testTag("hb-root").size(120.dp),
                    onTap = {}
                )
            }
        }
        val root = composeRule.onNodeWithTag("hb-root").fetchSemanticsNode()
        val icon = composeRule.onNodeWithText("✚", useUnmergedTree = true).fetchSemanticsNode()
        val cx = root.positionInRoot.x + root.size.width / 2f
        val cy = root.positionInRoot.y + root.size.height / 2f
        val ix = icon.positionInRoot.x + icon.size.width / 2f
        val iy = icon.positionInRoot.y + icon.size.height / 2f
        val tol = with(composeRule.density) { 3.dp.toPx() }
        assertTrue(
            "图标中心($ix,$iy)应≈圆钮中心($cx,$cy)（Start 顶左 bug 会偏左约 12dp）",
            abs(ix - cx) <= tol && abs(iy - cy) <= tol
        )
    }

    /** pill（icon+text）形态：渲染完整、点击回调一次。 */
    @Test
    fun test_pill形态点击回调() {
        var tapCount = 0
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                HoverButton(
                    modifier = Modifier.testTag("hb-pill").size(160.dp, 40.dp),
                    icon = "✚",
                    text = "添加",
                    onTap = { tapCount++ }
                )
            }
        }
        composeRule.onNodeWithText("添加").assertExists()
        composeRule.onNodeWithTag("hb-pill").performClick()
        composeRule.waitForIdle()
        assertEquals(1, tapCount)
    }
}
