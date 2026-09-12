package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Rect
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.unit.dp
import org.junit.Assert.assertEquals
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config
import org.robolectric.annotation.GraphicsMode

/**
 * Steps 步骤条回归测试（#75 ui.steps，台账 #55 行，验证组件库 v1.5.6）。
 *
 * 回归背景（#55）：用户实机反馈「Android Steps 横线和节点断开」。对照设计规格
 * steps-design-spec.html 的 CSS 原型 `.steps-h .line{left:50%;right:-50%}`——
 * 连线必须圆心→圆心贯穿（圆片不透明盖住线头）。旧实现每个等宽 cell 只画右半段
 * （本圆心→cell 右缘），与下一圆心空半列=断开；竖向则在连线之外另加 16dp
 * 行外 Spacer，线与下一圆断开。
 *
 * 修复（双端）：
 * - 横向：cell 内补左半段（cell 左缘→本圆心），与相邻 cell 右半段拼成圆心→圆心贯穿；
 * - 竖向：间距并入连线高度（56dp），删除行外 Spacer；
 * - iOS 同步：横线 leading=本圆心、trailing 跨 cell 约束到下一圆心，line 置于圆下层。
 *
 * 本文件用例（几何存在性 L1；线段颜色靠 L4 实机）：
 * - 横向：线段数量（左半 N-1 / 右半 N-1）、每条连线圆心→圆心无缝拼接
 * - 横向：首步无左半段、末步无右半段（线不伸出首尾）
 * - 竖向：竖线从圆底连到下一圆顶（0 间隙）、竖线宽 1dp、共 N-1 根
 */
@RunWith(RobolectricTestRunner::class)
@GraphicsMode(GraphicsMode.Mode.NATIVE)
@Config(sdk = [34], qualifiers = "w411dp-h891dp")
class StepsTest {

    @get:Rule
    val composeRule = createComposeRule()

    private val items = listOf(
        StepsItem(title = "步骤一"),
        StepsItem(title = "步骤二"),
        StepsItem(title = "步骤三"),
        StepsItem(title = "步骤四"),
    )

    private fun boundsOf(tag: String): Rect =
        composeRule.onNodeWithTag(tag).fetchSemanticsNode().boundsInRoot

    private fun mountSteps(current: Int, direction: StepsDirection) {
        composeRule.setContent {
            Box(Modifier.fillMaxSize().padding(16.dp)) {
                Steps(
                    items = items,
                    current = current,
                    direction = direction,
                    onChange = {},
                    modifier = Modifier.fillMaxWidth(),
                )
            }
        }
    }

    @Test
    fun test_横向圆点4个与左右半段各3根() {
        mountSteps(current = 2, direction = StepsDirection.Horizontal)

        // 圆点 4 个；线段 tag 带索引，逐根断言存在性与数量
        repeat(4) { composeRule.onNodeWithTag("steps-circle-$it").assertExists() }

        // 左半段：i=1,2,3 共 3 根；右半段：i=0,1,2 共 3 根
        listOf("steps-hline-left-1", "steps-hline-left-2", "steps-hline-left-3").forEach {
            composeRule.onNodeWithTag(it).assertExists()
        }
        listOf("steps-hline-right-0", "steps-hline-right-1", "steps-hline-right-2").forEach {
            composeRule.onNodeWithTag(it).assertExists()
        }
        // 首步无左半段、末步无右半段
        composeRule.onNodeWithTag("steps-hline-left-0").assertDoesNotExist()
        composeRule.onNodeWithTag("steps-hline-right-3").assertDoesNotExist()
    }

    @Test
    fun test_横向连线圆心到圆心无缝拼接() {
        mountSteps(current = 2, direction = StepsDirection.Horizontal)

        for (i in 0 until 3) {
            val circleI = boundsOf("steps-circle-$i")
            val circleNext = boundsOf("steps-circle-${i + 1}")
            val rightHalf = boundsOf("steps-hline-right-$i")
            val leftHalf = boundsOf("steps-hline-left-${i + 1}")

            // 右半段：本圆心 → cell 分界
            assertEquals("连线$i 右半段起点=本圆心", circleI.centerX, rightHalf.left, 2f)
            // 左半段：cell 分界 → 下一圆心；两段在分界处相接（无缝）
            assertEquals("连线$i 两段在 cell 分界处相接", rightHalf.right, leftHalf.left, 2f)
            assertEquals("连线$i 左半段终点=下一圆心", circleNext.centerX, leftHalf.right, 2f)
            // 垂直方向都在圆心高度
            assertEquals("连线$i 右半段垂直居中于圆心", circleI.centerY, rightHalf.centerY, 1f)
            assertEquals("连线$i 左半段垂直居中于圆心", circleNext.centerY, leftHalf.centerY, 1f)
            // 线高 1dp（mdpi=1px）
            assertEquals("连线$i 高 1dp", 1f, rightHalf.height, 1f)
            assertEquals("连线$i 高 1dp", 1f, leftHalf.height, 1f)
        }
    }

    @Test
    fun test_竖向竖线从圆底连到下一圆顶零间隙() {
        mountSteps(current = 1, direction = StepsDirection.Vertical)

        repeat(4) { composeRule.onNodeWithTag("steps-circle-$it").assertExists() }
        for (i in 0 until 3) {
            val line = boundsOf("steps-vline-$i")
            val circleI = boundsOf("steps-circle-$i")
            val circleNext = boundsOf("steps-circle-${i + 1}")

            assertEquals("竖线$i 起点=本圆底部", circleI.bottom, line.top, 1f)
            assertEquals("竖线$i 终点=下一圆顶部（零间隙）", circleNext.top, line.bottom, 1f)
            assertEquals("竖线$i 宽 1dp", 1f, line.width, 1f)
        }
        composeRule.onNodeWithTag("steps-vline-3").assertDoesNotExist()
    }
}

private val Rect.centerX: Float get() = (left + right) / 2f
private val Rect.centerY: Float get() = (top + bottom) / 2f
