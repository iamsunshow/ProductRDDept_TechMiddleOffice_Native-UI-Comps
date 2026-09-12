package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Rect
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onAllNodesWithTag
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.performClick
import androidx.compose.ui.unit.dp
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config
import org.robolectric.annotation.GraphicsMode

/**
 * Tag 标签回归测试（#78 ui.tag，台账 #56 行，验证组件库 v1.5.7）。
 *
 * 回归背景（#56）：用户实机反馈「Android Tag Demo2/Demo4 文字（及关闭叉）没有垂直居中」。
 * 根因=Text 默认行高（≈字号×1.2+）大于字号，行盒虽被 Row 垂直居中，字形按 baseline
 * 落位使视觉中线偏离几何中心；Close 矢量图标严格几何居中→两者错位（纯文字标签同样偏）。
 * 修复=Text 收 lineHeight=fontSize + LineHeightStyle(Center, Trim.Both)；文字与叉补
 * 2dp 间隙对齐 iOS（iconSize+2）；D1/D2 Demo 外层 Row 补 verticalAlignment。
 *
 * 本文件用例（L1 节点几何；字形像素级视觉居中靠 L4 实机）：
 * - 三尺寸：tag-text 中心 Y=标签中心；标签高度 20/24/28dp
 * - closable：文字与关闭叉同轴（中心 Y 相等）、间隙 2dp、叉尺寸 iconSize
 * - 点关闭叉触发 onClose
 */
@RunWith(RobolectricTestRunner::class)
@GraphicsMode(GraphicsMode.Mode.NATIVE)
@Config(sdk = [34], qualifiers = "w411dp-h891dp")
class TagTest {

    @get:Rule
    val composeRule = createComposeRule()

    private var density = 0f

    private fun boundsOf(tag: String): Rect =
        composeRule.onNodeWithTag(tag).fetchSemanticsNode().boundsInRoot

    private val Rect.centerYValue: Float get() = (top + bottom) / 2f

    @Test
    fun test_三尺寸文字垂直居中且标签高度正确() {
        composeRule.setContent {
            density = LocalDensity.current.density
            androidx.compose.foundation.layout.Column(
                Modifier.fillMaxWidth().padding(16.dp),
                verticalArrangement = androidx.compose.foundation.layout.Arrangement.spacedBy(8.dp),
            ) {
                Box(Modifier.testTag("root-sm")) { Tag(text = "标签sm", size = TagSize.SM) }
                Box(Modifier.testTag("root-md")) { Tag(text = "标签md", size = TagSize.MD) }
                Box(Modifier.testTag("root-lg")) { Tag(text = "标签lg", size = TagSize.LG) }
            }
        }
        val cases = listOf(
            Triple("sm", 20.dp, TagSize.SM),
            Triple("md", 24.dp, TagSize.MD),
            Triple("lg", 28.dp, TagSize.LG),
        )
        cases.forEach { (key, expectedHeight, _) ->
            val root = boundsOf("root-$key")
            val text = composeRule.onAllNodesWithTag("tag-text")[
                listOf("sm", "md", "lg").indexOf(key)
            ].fetchSemanticsNode().boundsInRoot
            assertEquals("[$key] 标签高度=${expectedHeight}dp",
                expectedHeight.value * density, root.height, 1f)
            assertEquals("[$key] 文字中心 Y 应=标签中心（视觉居中修复）",
                root.centerYValue, text.centerYValue, 1f)
        }
    }

    @Test
    fun test_closable文字与关闭叉同轴且间隙2dp() {
        composeRule.setContent {
            density = LocalDensity.current.density
            Box(Modifier.fillMaxWidth().padding(16.dp).testTag("root-close")) {
                Tag(text = "可关闭", size = TagSize.SM, closable = true, onClose = {})
            }
        }
        val root = boundsOf("root-close")
        val text = boundsOf("tag-text")
        val close = boundsOf("tag-close")

        assertEquals("文字中心 Y=标签中心", root.centerYValue, text.centerYValue, 1f)
        assertEquals("关闭叉中心 Y=标签中心", root.centerYValue, close.centerYValue, 1f)
        assertEquals("文字与关闭叉中心同轴", text.centerYValue, close.centerYValue, 1f)
        assertEquals("文字→叉间隙 2dp（对齐 iOS iconSize+2）", 2.dp.value * density, close.left - text.right, 1f)
        assertEquals("SM 关闭叉尺寸 12dp（宽）", 12.dp.value * density, close.width, 1f)
        assertEquals("SM 关闭叉尺寸 12dp（高）", 12.dp.value * density, close.height, 1f)
    }

    @Test
    fun test_点击关闭叉触发onClose() {
        var clicked = 0
        composeRule.setContent {
            Box(Modifier.fillMaxWidth().padding(16.dp)) {
                Tag(text = "可关闭", closable = true, onClose = { clicked++ })
            }
        }
        composeRule.onNodeWithTag("tag-close").performClick()
        composeRule.waitForIdle()
        assertEquals("点击关闭叉应触发一次 onClose", 1, clicked)
    }

    @Test
    fun test_非closable不渲染关闭叉() {
        composeRule.setContent {
            Box(Modifier.fillMaxWidth().padding(16.dp)) {
                Tag(text = "普通标签")
            }
        }
        composeRule.onNodeWithTag("tag-close").assertDoesNotExist()
        composeRule.onNodeWithTag("tag-text").assertExists()
        // 无叉时文字右缘到包装右缘只剩 paddingH（6dp）
        val root = composeRule.onNodeWithTag("tag-text").fetchSemanticsNode().boundsInRoot
        assertTrue("文字节点应有宽度", root.width > 1f)
    }
}
