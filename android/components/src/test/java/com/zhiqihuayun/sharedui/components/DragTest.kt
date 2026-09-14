package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.material3.Text
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.test.junit4.createComposeRule
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

/**
 * Drag 拖拽排序回归测试（#47 ui.drag，回归测试台账 Drag 族，验证组件库 v1.9.34）。
 *
 * 回归背景（用户 2026-09-13/09-14 实机反复反馈，跨 v1.4.2~v1.9.33 共 10 余次修复）：
 * 1. 拖拽手势失效族（v1.4.2/v1.4.3/v1.4.6）——pointerInput 键、外层滚动抢事件；
 * 2. 拖拽视觉族（v1.9.0/v1.9.30/v1.9.32/v1.9.33）——透明度 0.6→0.9→1.0→0.9、缩放、
 *    底部阴影（Modifier.shadow 被相邻 item 覆盖）、graphicsLayer 修饰符顺序
 *    （放链末导致「只有图标文字在动、Cell 主体待在原地」）；
 * 3. 落位语义族（P3-A）——拖拽中不回调、释放后仅回调一次 onReorder(from,to)，
 *    未发生换位不回调。
 *
 * 可自动化部分（L1，本文件）：手势落位语义 + enabled/handle 手势挂载面 + 视觉规格值锁定。
 * 不可自动化部分（L4）：透明度/阴影/动画的实际渲染观感，只能人工实机回归
 * （Robolectric 语义树读不到 graphicsLayer，且白底叠白底像素不可判别）。
 *
 * 本文件用例：
 * - 非 handle：长按拖拽越一项落位 → onReorder(0,1) 仅一次（手势键+swap 阈值+落位回调）
 * - 非 handle：长按拖拽未越阈值即松手 → 不回调（原索引=现索引不回调）
 * - enabled=false：长按拖拽 → 不回调（纯列表不可拖）
 * - handle=true：整行长按拖拽 → 不回调（手势只挂手柄）
 * - handle=true：手柄拖拽落位 → onReorder(0,1)（手柄即时拖拽链路通）
 * - 视觉规格常量锁定：Opacity 0.9 / Scale 1.02 / 落位 250ms / 换位 350ms / 阴影 22dp+0.10
 */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34], qualifiers = "w411dp-h891dp")
class DragTest {

    @get:Rule
    val composeRule = createComposeRule()

    /** 每行固定高度（px 与 dp 1:1：Robolectric 默认 mdpi，density=1）。 */
    private val rowHeight = 56.dp
    private var density = 1f

    private fun rowHeightPx(): Float = rowHeight.value * density

    private fun mount(
        enabled: Boolean = true,
        handle: Boolean = false,
        onReorder: (Int, Int) -> Unit = { _, _ -> },
    ) {
        composeRule.setContent {
            density = LocalDensity.current.density
            Box(Modifier.height(rowHeight * 3 + 24.dp)) {
                Drag(
                    items = listOf("a", "b", "c"),
                    key = { it },
                    itemContent = { item ->
                        Box(Modifier.fillMaxWidth().height(rowHeight)) { Text(item) }
                    },
                    onReorder = onReorder,
                    enabled = enabled,
                    handle = handle,
                )
            }
        }
    }

    /** 长按拖拽：DOWN → 越过长按阈值 → 纵移 dy → UP（单一手势块内完成）。 */
    private fun longPressDrag(tag: String, dy: Float) {
        composeRule.onNodeWithTag(tag).performTouchInput {
            down(center)
            advanceEventTime(700)
            moveBy(Offset(0f, dy))
            advanceEventTime(16)
            up()
        }
        composeRule.waitForIdle()
    }

    /** 即时拖拽（handle 模式用 detectDragGestures，无长按等待）。 */
    private fun immediateDrag(tag: String, dy: Float) {
        composeRule.onNodeWithTag(tag).performTouchInput {
            down(center)
            moveBy(Offset(0f, 12f))
            advanceEventTime(16)
            moveBy(Offset(0f, dy))
            advanceEventTime(16)
            up()
        }
        composeRule.waitForIdle()
    }

    @Test
    fun test_长按拖拽越一项落位_仅回调一次_onReorder_0_1() {
        val calls = mutableListOf<Pair<Int, Int>>()
        mount(handle = false, onReorder = { from, to -> calls.add(from to to) })

        longPressDrag("drag-item-a", rowHeightPx())

        assertEquals("拖拽释放后应恰好回调一次", 1, calls.size)
        assertEquals("购物(0) 下移一项应回调 onReorder(0,1)", 0 to 1, calls[0])
    }

    @Test
    fun test_长按拖拽未越阈值松手_不回调() {
        val calls = mutableListOf<Pair<Int, Int>>()
        mount(handle = false, onReorder = { from, to -> calls.add(from to to) })

        longPressDrag("drag-item-a", rowHeightPx() * 0.3f)

        assertTrue("位移未越 itemHeight/2 未换位 → 不应回调（P3-A 原索引=现索引不回调）", calls.isEmpty())
    }

    @Test
    fun test_enabled为false_长按拖拽不回调() {
        val calls = mutableListOf<Pair<Int, Int>>()
        mount(enabled = false, handle = false, onReorder = { from, to -> calls.add(from to to) })

        longPressDrag("drag-item-a", rowHeightPx())

        assertTrue("enabled=false 不挂手势=纯列表，任何拖拽都不回调", calls.isEmpty())
    }

    @Test
    fun test_handle模式_整行长按拖拽不回调() {
        val calls = mutableListOf<Pair<Int, Int>>()
        mount(handle = true, onReorder = { from, to -> calls.add(from to to) })

        longPressDrag("drag-item-a", rowHeightPx())

        assertTrue("handle=true 手势只挂手柄，整行拖拽不应回调（对齐 iOS showsReorderControl）", calls.isEmpty())
    }

    @Test
    fun test_handle模式_手柄拖拽落位回调_onReorder_0_1() {
        val calls = mutableListOf<Pair<Int, Int>>()
        mount(handle = true, onReorder = { from, to -> calls.add(from to to) })

        immediateDrag("drag-handle-a", rowHeightPx())

        assertEquals("手柄拖拽释放后应恰好回调一次", 1, calls.size)
        assertEquals("手柄拖拽下移一项应回调 onReorder(0,1)", 0 to 1, calls[0])
    }

    /**
     * 视觉规格值锁定（历史回退点防复发）：这些值是用户实机验收通过过的规格/iOS 对齐值，
     * 任何误改（如透明度改回 0.75/1.0、换位动画回 300ms、阴影带宽回 16dp）都会被本用例拦下。
     */
    @Test
    fun test_视觉规格常量锁定_与IOS及drag设计规格一致() {
        assertEquals("拖拽态透明度=0.9（规格 opacity90 / iOS 同值；v1.9.33 用户指正回归点）",
            0.9f, DragOpacity, 0f)
        assertEquals("拖拽态缩放=1.02（规格 §4）", 1.02f, DragScale, 0f)
        assertEquals("落位动画=250ms（对齐 iOS 松手归位）", 250, DropAnimMs)
        assertEquals("item 换位动画=350ms（v1.9.30 用户反馈过快 → 慢化）",
            350, ItemPlaceAnimMs)
        assertEquals("底部阴影带宽=22dp（对齐 iOS willDisplay 实测）",
            22.dp, CellShadowHeight)
        assertEquals("底部阴影最深处 alpha=0.10（对齐 iOS 相邻 cell 分界实测）",
            0.10f, CellShadowAlpha, 0f)
    }
}
