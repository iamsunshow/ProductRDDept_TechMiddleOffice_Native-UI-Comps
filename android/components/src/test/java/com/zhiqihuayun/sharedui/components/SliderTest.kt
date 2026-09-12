package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Rect
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.click
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.performTouchInput
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
 * Slider 滑块回归测试（#45 ui.slider，台账 #54 行，验证组件库 v1.5.3）。
 *
 * 回归背景（#54）：用户实机反馈「Android Slider 圆形在横线上方，预期与横线垂直居中」。
 * 根因=轨道/激活段用 Alignment.CenterStart（在 44dp 容器内已垂直居中）后又叠加
 * offset(y=(44-4)/2=20dp)，轨道被二次下移到 y=40 贴底（中心 42dp），而 thumb
 * CenterStart 无 y 偏移中心在 22dp → thumb 跑到轨道上方 20dp。
 * 修复=轨道/激活段去掉多余 y offset，三层共用 CenterStart 的垂直居中（与 iOS
 * SliderView trackY=20/thumbY=10 中心同为 22pt 对齐）。
 *
 * 本文件用例：
 * - thumb / 灰轨道 / 激活段三层中心 Y 与容器中心一致（0/50/100 三档，旧 bug 轨道中心偏下 20dp 必现）
 * - 尺寸同轴：轨道高 4dp、thumb 24dp，thumb 中心落在轨道上下缘之间
 * - 点击轨道两端/分档吸附：手势端到端验证水平定位（Robolectric semantics bounds
 *   不计 Modifier.offset 位移，水平位置类断言改走 onValueChange 回调）
 */
@RunWith(RobolectricTestRunner::class)
@GraphicsMode(GraphicsMode.Mode.NATIVE)
@Config(sdk = [34], qualifiers = "w411dp-h891dp")
class SliderTest {

    @get:Rule
    val composeRule = createComposeRule()

    private var density = 0f

    private fun boundsOf(tag: String): Rect =
        composeRule.onNodeWithTag(tag).fetchSemanticsNode().boundsInRoot

    private fun Rect.centerYValue(): Float = (top + bottom) / 2f

    private fun mountSlider(
        value: Float,
        steps: Int = 0,
        onChange: (Float) -> Unit = {}
    ) {
        composeRule.setContent {
            density = LocalDensity.current.density
            Box(Modifier.fillMaxSize().padding(16.dp)) {
                Slider(
                    value = value,
                    steps = steps,
                    onValueChange = onChange,
                    modifier = Modifier.fillMaxWidth()
                )
            }
        }
    }

    /**
     * 三层垂直居中式回归（#54 核心断言）：thumb、灰轨道、激活段中心 Y 必须都等于容器中心。
     * 注意 value=0 时激活段宽度为 0，零尺寸 semantics 节点 bounds 无意义，需跳过。
     */
    private fun assertLayersVerticallyCentered(checkActive: Boolean) {
        val rootCenterY = boundsOf("slider-root").centerYValue()
        assertEquals("灰轨道中心应=容器中心（旧 bug=CenterStart 再叠加 y offset 压到贴底）",
            rootCenterY, boundsOf("slider-track").centerYValue(), 1f)
        assertEquals("thumb 中心应=容器中心（与横线垂直居中）",
            rootCenterY, boundsOf("slider-thumb").centerYValue(), 1f)
        if (checkActive) {
            assertEquals("激活段中心应=容器中心",
                rootCenterY, boundsOf("slider-active").centerYValue(), 1f)
        }
    }

    @Test
    fun test_最小值时thumb与轨道垂直居中() {
        mountSlider(0f)
        assertLayersVerticallyCentered(checkActive = false)
    }

    @Test
    fun test_中间值时三层垂直居中() {
        mountSlider(50f)
        assertLayersVerticallyCentered(checkActive = true)
    }

    @Test
    fun test_最大值时三层垂直居中() {
        mountSlider(100f)
        assertLayersVerticallyCentered(checkActive = true)
    }

    @Test
    fun test_thumb直径24dp轨道高4dp且同轴() {
        mountSlider(30f)

        val track = boundsOf("slider-track")
        val thumb = boundsOf("slider-thumb")
        assertEquals("轨道高 4dp", 4.dp.value * density, track.height, 1f)
        assertEquals("thumb 高 24dp", 24.dp.value * density, thumb.height, 1f)
        assertEquals("thumb 宽 24dp", 24.dp.value * density, thumb.width, 1f)
        assertTrue("thumb 中心应落在轨道上下缘之间（同轴）",
            thumb.centerYValue() >= track.top - 1f && thumb.centerYValue() <= track.bottom + 1f
        )
    }

    @Test
    fun test_点击轨道最左端回调0() {
        var picked = -1f
        mountSlider(50f, onChange = { picked = it })
        // 节点内坐标：root 宽 379px（411-32 padding，mdpi），thumb 半宽 12px
        composeRule.onNodeWithTag("slider-root").performTouchInput {
            click(Offset(1f, center.y))
        }
        assertEquals("点最左端应回传 0", 0f, picked, 0.5f)
    }

    @Test
    fun test_点击轨道最右端回调100() {
        var picked = -1f
        mountSlider(50f, onChange = { picked = it })
        composeRule.onNodeWithTag("slider-root").performTouchInput {
            click(Offset(width - 2f, center.y))
        }
        assertEquals("点最右端应回传 100", 100f, picked, 0.5f)
    }

    @Test
    fun test_steps分档点击吸附50() {
        var picked = -1f
        // steps=3 → stepSize=100/4=25（25/50/75 三个中间档）；点击 value≈37.5 对应像素应吸附到 50
        mountSlider(0f, steps = 3, onChange = { picked = it })
        val root = boundsOf("slider-root")
        val halfThumb = 12.dp.value * density
        val effective = root.width - 2 * halfThumb
        val xAt37_5 = halfThumb + 0.375f * effective
        composeRule.onNodeWithTag("slider-root").performTouchInput {
            click(Offset(xAt37_5, center.y))
        }
        assertEquals("37.5 位置应按 25 档距吸附到 50", 50f, picked, 0.5f)
    }
}
