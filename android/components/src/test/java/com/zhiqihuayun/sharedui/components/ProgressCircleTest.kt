package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.ui.Modifier
import androidx.compose.ui.test.SemanticsNodeInteraction
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.unit.dp
import org.junit.Assert.assertTrue
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config
import org.robolectric.annotation.GraphicsMode

/**
 * ProgressCircle 环形进度（图表组件 #83，ui.progress-circle）回归测试。
 *
 * 覆盖：
 * - **中心文案居中契约（本次回归用例）**：文案宽/高中心 = 环心（对齐 ios/SharedUI/Components/
 *   ProgressCircleView.swift `centerX/centerY=superview` + `textAlignment=.center`）。
 *   历史缺陷：Text 误用 `Modifier.size(size - inset*2)` 把文案撑成 48×48 定尺容器
 *   （min=max），文字被画在该方框左上角，用户实机反馈「数值没有水平垂直居中于圆环」。
 * - 默认百分比文案 / centerText 覆盖 / value 超界 clamp / size 契约 / maxLines=1 单行。
 *
 * 运行：`cd android && ./gradlew :components:testDebugUnitTest --tests ProgressCircleTest`（Robolectric
 * 托管 Compose，无需模拟器）。
 *
 * 关联台账：`docs/数据与产物/回归测试台账.md`（ProgressCircle 行，落点 L1）。
 */
@RunWith(RobolectricTestRunner::class)
@GraphicsMode(GraphicsMode.Mode.NATIVE)
@Config(sdk = [34], qualifiers = "w411dp-h891dp")
class ProgressCircleTest {

    @get:Rule
    val composeRule = createComposeRule()

    // ---------- 居中契约（历史缺陷回归） ----------

    /** 默认百分比文案在环内水平+垂直居中（历史缺陷：偏左上）。 */
    @Test
    fun test_默认百分比水平垂直居中于环心() {
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                ProgressCircle(value = 0.3f)
            }
        }
        composeRule.onNodeWithText("30%").assertExistsInRoot()
        composeRule.onNodeWithTag(TAG_TEXT, useUnmergedTree = true).assertCenteredIn(TAG_ROOT)
    }

    /** 自定义 centerText 同样居中（覆盖百分比路径）。 */
    @Test
    fun test_自定义文案水平垂直居中于环心() {
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                ProgressCircle(value = 0.5f, centerText = "3/10")
            }
        }
        composeRule.onNodeWithTag(TAG_TEXT, useUnmergedTree = true).assertCenteredIn(TAG_ROOT)
    }

    /** 非默认 size（80dp）下仍居中：文案居中不随环径漂移。 */
    @Test
    fun test_非默认尺寸下仍居中() {
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                ProgressCircle(value = 0.75f, size = 80.dp)
            }
        }
        composeRule.onNodeWithTag(TAG_TEXT, useUnmergedTree = true).assertCenteredIn(TAG_ROOT)
    }

    // ---------- 文案契约 ----------

    /** 默认文案 = 百分比（value=0.3 → 「30%」）。 */
    @Test
    fun test_默认文案为百分比() {
        composeRule.setContent { ProgressCircle(value = 0.3f) }
        composeRule.onNodeWithText("30%").assertExistsInRoot()
    }

    /** centerText 覆盖百分比：自定义文案存在、百分比文案不存在。 */
    @Test
    fun test_centerText覆盖百分比() {
        composeRule.setContent { ProgressCircle(value = 0.3f, centerText = "今日 ¥128") }
        composeRule.onNodeWithText("今日 ¥128").assertExistsInRoot()
        composeRule.onNodeWithText("30%").assertDoesNotExist()
    }

    /** value 超界 clamp：[0,1] 外按边界显示（1.5 → 100% / -0.2 → 0%）。 */
    @Test
    fun test_value超界clamp到边界() {
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                ProgressCircle(value = 1.5f)
                ProgressCircle(value = -0.2f)
            }
        }
        composeRule.onNodeWithText("100%").assertExistsInRoot()
        composeRule.onNodeWithText("0%").assertExistsInRoot()
    }

    /** 文案单行（maxLines=1，对齐 iOS UILabel numberOfLines=1）：不因长文案撑成两行。 */
    @Test
    fun test_文案单行不换行() {
        composeRule.setContent {
            Box(Modifier.fillMaxSize()) {
                ProgressCircle(value = 1f, size = 80.dp, centerText = "今日 ¥128")
            }
        }
        val textNode = composeRule.onNodeWithTag(TAG_TEXT, useUnmergedTree = true).fetchSemanticsNode()
        val maxSingleLinePx = with(composeRule.density) { SINGLE_LINE_MAX_DP.dp.toPx() }
        assertTrue(
            "文案高 ${textNode.size.height}px 应 ≤ 单行上限 $maxSingleLinePx px（两行 ≈ 38dp 视为回归）",
            textNode.size.height <= maxSingleLinePx,
        )
    }

    // ---------- 尺寸契约 ----------

    /** size 契约：size=80dp 时整件（含环与文案）为 80×80。 */
    @Test
    fun test_size契约() {
        composeRule.setContent { ProgressCircle(value = 0.5f, size = 80.dp) }
        val root = composeRule.onNodeWithTag(TAG_ROOT).fetchSemanticsNode()
        val expectedPx = with(composeRule.density) { 80.dp.toPx().toInt() }
        assertTrue("环宽 ${root.size.width}px 应 = $expectedPx px", root.size.width == expectedPx)
        assertTrue("环高 ${root.size.height}px 应 = $expectedPx px", root.size.height == expectedPx)
    }

    // ---------- 断言辅助 ----------

    private fun SemanticsNodeInteraction.assertExistsInRoot() {
        assertExists()
    }

    /**
     * 断言当前节点在 [containerTag] 容器内**水平+垂直居中**（容差容纳 Robolectric 字体度量差异）。
     *
     * 判据（两条缺一不可）：
     * ① 文案中心 X/Y ≈ 环心 X/Y（`Box(contentAlignment=Center)` 的居中契约）；
     * ② 文案节点高 ≤ 单行高：节点必须是文本**自然尺寸**，不得被 `Modifier.size()` 之类
     *    定尺修饰符撑成「环内方框」——历史缺陷正是文案被撑成 size−inset×2 的方框
     *    （min=max）、文字画在方框左上角，而方框本身仍被 Box 居中，故单看 ① 测不出来。
     */
    private fun SemanticsNodeInteraction.assertCenteredIn(containerTag: String, toleranceDp: Float = 2f) {
        val node = fetchSemanticsNode()
        val container = composeRule.onNodeWithTag(containerTag).fetchSemanticsNode()
        val nodeCenterX = node.positionInRoot.x + node.size.width / 2f
        val nodeCenterY = node.positionInRoot.y + node.size.height / 2f
        val containerCenterX = container.positionInRoot.x + container.size.width / 2f
        val containerCenterY = container.positionInRoot.y + container.size.height / 2f
        val tolerancePx = with(composeRule.density) { toleranceDp.dp.toPx() }
        val singleLinePx = with(composeRule.density) { SINGLE_LINE_MAX_DP.dp.toPx() }
        assertTrue(
            "文案水平中心 ${nodeCenterX}px 应≈环心 ${containerCenterX}px（±$tolerancePx）",
            kotlin.math.abs(nodeCenterX - containerCenterX) <= tolerancePx,
        )
        assertTrue(
            "文案垂直中心 ${nodeCenterY}px 应≈环心 ${containerCenterY}px（±$tolerancePx）",
            kotlin.math.abs(nodeCenterY - containerCenterY) <= tolerancePx,
        )
        assertTrue(
            "文案节点高 ${node.size.height}px 应为自然单行高（≤ $singleLinePx px）——被撑成环内方框时文字画在方框左上角，即「数值没居中」的历史缺陷",
            node.size.height <= singleLinePx,
        )
    }

    private companion object {
        /** 内部语义锚点（无视觉契约影响，对齐 Cell/Switch 等库内 testTag 惯例）。 */
        const val TAG_ROOT = "progress-circle-root"
        const val TAG_TEXT = "progress-circle-text"

        /** 单行文案高度上限（dp）：sizeMd=16 单行 ≈ 19dp，两行 ≈ 38dp，28dp 为分界线。 */
        const val SINGLE_LINE_MAX_DP = 28f
    }
}
