package com.zhiqihuayun.sharedui.components

import androidx.compose.ui.test.assertIsNotEnabled
import androidx.compose.ui.test.click
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.performClick
import androidx.compose.ui.test.performTouchInput
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
 * Uploader 回归测试（#43 ui.uploader，门禁 B 基线，验证组件库 v1.4.0）。
 *
 * 回归背景（子仓 fix commit 序列）：
 * - 69910e5：LazyVerticalGrid 嵌套滚动容器崩溃 → 改 Column+Row chunked 布局（本文件结构用例防复燃）；
 * - e264918：删除角标「×」偏离中心；ef6131a：网格间距不均分（几何断言在 Cell 层补=见台账）；
 * - 行为契约：达 maxCount 隐藏添加格、未达显示且点击回调 onAdd；FAILED 项整格点击回调 onRetry、
 *   非 FAILED 整格不可点；SUCCESS/PENDING 角标点击回调 onRemove；disabled 全不可点零回调。
 * 本文件=首批回归补测（回归测试台账 #37~#39 同源族）。
 */
@RunWith(RobolectricTestRunner::class)
@GraphicsMode(GraphicsMode.Mode.NATIVE)
@Config(sdk = [34], qualifiers = "w411dp-h891dp")
class UploaderTest {

    @get:Rule
    val composeRule = createComposeRule()

    private fun items(count: Int, status: UploadStatus = UploadStatus.SUCCESS) =
        (0 until count).map { i ->
            UploadItem(id = "$i", name = "file$i", status = status)
        }

    /** maxCount=9 满 9 项=添加格隐藏。 */
    @Test
    fun test_regression_满9项隐藏添加格() {
        composeRule.setContent {
            Uploader(value = items(9), maxCount = 9, onAdd = {}, onRemove = {})
        }
        composeRule.onNodeWithTag("uploader-add").assertDoesNotExist()
    }

    /** maxCount=9 未满（8 项）=添加格显示。 */
    @Test
    fun test_regression_8项显示添加格() {
        composeRule.setContent {
            Uploader(value = items(8), maxCount = 9, onAdd = {}, onRemove = {})
        }
        composeRule.onNodeWithTag("uploader-add").assertExists()
    }

    /** 添加格点击 → onAdd 仅一次。 */
    @Test
    fun test_regression_添加格点击回调onAdd() {
        var addCount = 0
        composeRule.setContent {
            Uploader(value = items(2), maxCount = 9, onAdd = { addCount++ }, onRemove = {})
        }
        composeRule.onNodeWithTag("uploader-add").performClick()
        composeRule.waitForIdle()
        assertEquals(1, addCount)
    }

    /** FAILED 项整格可点 → onRetry(index)；SUCCESS 项整格不可点（防误触重试）。 */
    @Test
    fun test_regression_failed项点击回调onRetry_成功项不可点() {
        val value = listOf(
            UploadItem(id = "0", name = "a", status = UploadStatus.SUCCESS),
            UploadItem(id = "1", name = "b", status = UploadStatus.FAILED)
        )
        val retries = mutableListOf<Int>()
        composeRule.setContent {
            Uploader(value = value, onAdd = {}, onRetry = { retries.add(it) }, onRemove = {})
        }
        composeRule.onNodeWithTag("uploader-cell-0").performTouchInput { click() }
        composeRule.waitForIdle()
        assertTrue("SUCCESS 项整格不得回调 onRetry", retries.isEmpty())

        composeRule.onNodeWithTag("uploader-cell-1").performClick()
        composeRule.waitForIdle()
        assertEquals(listOf(1), retries)
    }

    /** SUCCESS 项删除角标点击 → onRemove(index)。 */
    @Test
    fun test_regression_删除角标点击回调onRemove() {
        val removes = mutableListOf<Int>()
        composeRule.setContent {
            Uploader(value = items(3), onAdd = {}, onRemove = { removes.add(it) })
        }
        composeRule.onNodeWithTag("uploader-delete-2").performClick()
        composeRule.waitForIdle()
        assertEquals(listOf(2), removes)
    }

    /** disabled：添加格/删除角标/整格重试全部不可点=零回调（40% 灰锁定语义）。 */
    @Test
    fun test_regression_disabled全局锁定零回调() {
        var addCount = 0
        val removes = mutableListOf<Int>()
        val retries = mutableListOf<Int>()
        val value = listOf(
            UploadItem(id = "0", name = "a", status = UploadStatus.SUCCESS),
            UploadItem(id = "1", name = "b", status = UploadStatus.FAILED)
        )
        composeRule.setContent {
            Uploader(
                value = value,
                disabled = true,
                onAdd = { addCount++ },
                onRemove = { removes.add(it) },
                onRetry = { retries.add(it) }
            )
        }
        composeRule.onNodeWithTag("uploader-add").assertIsNotEnabled()
        composeRule.onNodeWithTag("uploader-cell-1").assertIsNotEnabled()
        composeRule.onNodeWithTag("uploader-add").performTouchInput { click() }
        composeRule.onNodeWithTag("uploader-delete-0").performTouchInput { click() }
        composeRule.onNodeWithTag("uploader-cell-1").performTouchInput { click() }
        composeRule.waitForIdle()
        assertEquals(0, addCount)
        assertTrue(removes.isEmpty())
        assertTrue(retries.isEmpty())
    }

    /** 多行网格结构渲染不崩溃：7 项（2 行）+添加格齐全=防 LazyVerticalGrid 嵌套崩溃类回归。 */
    @Test
    fun test_regression_多行网格渲染不崩溃() {
        composeRule.setContent {
            Uploader(value = items(7), onAdd = {}, onRemove = {})
        }
        composeRule.waitForIdle()
        composeRule.onNodeWithTag("uploader-cell-0").assertExists()
        composeRule.onNodeWithTag("uploader-cell-6").assertExists()
        composeRule.onNodeWithTag("uploader-add").assertExists()
    }

    /** #39 网格间距几何回归（ef6131a）：行内 4 格等宽、横/纵格间距≈8dp、跨行行首左对齐不漂移。 */
    @Test
    fun test_regression_网格间距均匀跨行对齐() {
        composeRule.setContent {
            Uploader(value = items(7), onAdd = {}, onRemove = {})
        }
        val cell = (0..6).map { composeRule.onNodeWithTag("uploader-cell-$it").fetchSemanticsNode() }
        fun gapX(a: Int, b: Int) = cell[b].positionInRoot.x - (cell[a].positionInRoot.x + cell[a].size.width)
        val g01 = gapX(0, 1)
        val g12 = gapX(1, 2)
        val g23 = gapX(2, 3)
        val vGap = cell[4].positionInRoot.y - (cell[0].positionInRoot.y + cell[0].size.height)
        val spacingPx = with(composeRule.density) { 8.dp.toPx() }
        val tol = with(composeRule.density) { 1.5.dp.toPx() }
        assertTrue("行内横间距应均匀 g01=$g01 g12=$g12 g23=$g23", abs(g01 - g12) <= 1f && abs(g12 - g23) <= 1f)
        assertTrue("行内横间距应≈8dp: $g01", abs(g01 - spacingPx) <= tol)
        assertTrue("跨行纵间距应≈8dp: $vGap", abs(vGap - spacingPx) <= tol)
        assertTrue(
            "同行 4 格应等宽（不均分 bug）",
            abs(cell[0].size.width - cell[1].size.width) <= 1f &&
                abs(cell[1].size.width - cell[2].size.width) <= 1f &&
                abs(cell[2].size.width - cell[3].size.width) <= 1f
        )
        assertTrue("第二行行首应与第一行左对齐", abs(cell[4].positionInRoot.x - cell[0].positionInRoot.x) <= 1f)
    }

    /** #38 删除角标锚定（右上象限）：角标悬于所属 cell 右上角，不掉入格中、不跑出格。 */
    @Test
    fun test_regression_删除角标锚定右上象限() {
        composeRule.setContent {
            Uploader(value = items(2), onAdd = {}, onRemove = {})
        }
        val cell0 = composeRule.onNodeWithTag("uploader-cell-0").fetchSemanticsNode()
        val del = composeRule.onNodeWithTag("uploader-delete-0").fetchSemanticsNode()
        val cellCX = cell0.positionInRoot.x + cell0.size.width / 2f
        val cellCY = cell0.positionInRoot.y + cell0.size.height / 2f
        val delCX = del.positionInRoot.x + del.size.width / 2f
        val delCY = del.positionInRoot.y + del.size.height / 2f
        assertTrue("角标应位于 cell 右半区（delCX=$delCX vs cellCX=$cellCX）", delCX > cellCX)
        assertTrue("角标应位于 cell 上半区（delCY=$delCY vs cellCY=$cellCY）", delCY < cellCY)
    }
}
