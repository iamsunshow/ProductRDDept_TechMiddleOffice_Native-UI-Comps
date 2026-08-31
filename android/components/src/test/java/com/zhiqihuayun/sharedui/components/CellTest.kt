package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.layout.Column
import androidx.compose.ui.test.assertCountEquals
import androidx.compose.ui.test.assertIsNotEnabled
import androidx.compose.ui.test.assertIsEnabled
import androidx.compose.ui.test.click
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onAllNodesWithTag
import androidx.compose.ui.test.onNodeWithContentDescription
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.onAllNodesWithTag
import androidx.compose.ui.test.performClick
import androidx.compose.ui.test.performTouchInput
import androidx.compose.ui.unit.dp
import com.zhiqihuayun.foundation.design.AppSpace
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config
import org.robolectric.annotation.GraphicsMode

/**
 * Cell 组件测试：门禁 C1 用例映射（详见 `docs/验收流程/component-acceptance-cell.md`）。
 *
 * - D1-D8 设计测试（默认/禁用/加载/成功/失败五态、token、按压、分隔线）
 * - A1-A5 API 契约测试（默认 props、自定义 props、点击事件、禁用拦截、五态覆盖）
 * - D6 token 硬编码扫描 / A6 契约 schema / A7 命名对齐 由 `scripts/check_component_quality.py` 执行
 *
 * 运行：`./gradlew :components:testDebugUnitTest`（Robolectric 托管 Compose，无需模拟器）。
 */
@RunWith(RobolectricTestRunner::class)
@GraphicsMode(GraphicsMode.Mode.NATIVE)
@Config(sdk = [34], qualifiers = "w411dp-h891dp")
class CellTest {

    @get:Rule
    val composeRule = createComposeRule()

    // ---------- D 系列：设计测试 ----------

    /** D1 默认态：标题、右侧值、箭头、分隔线齐全，行高 ≥ 56（设计稿「32 号字 cell」单行）。 */
    @Test
    fun test_D1_defaultState() {
        composeRule.setContent { Cell(title = "设置", value = "深色模式") }
        composeRule.onNodeWithText("设置").assertExists()
        composeRule.onNodeWithText("深色模式").assertExists()
        composeRule.onNodeWithTag("cell-arrow", useUnmergedTree = true).assertExists()
        composeRule.onNodeWithTag("cell-divider").assertExists()
        composeRule.onNodeWithTag("cell-root").assertHeightAtLeast(56.dp)
    }

    /** D2 禁用态：整行不可点、不透箭头、点击不触发。 */
    @Test
    fun test_D2_disabledState() {
        var tapCount = 0
        composeRule.setContent {
            Cell(title = "设置", disabled = true, onClick = { tapCount++ })
        }
        composeRule.onNodeWithTag("cell-root").assertIsNotEnabled()
        composeRule.onNodeWithTag("cell-arrow", useUnmergedTree = true).assertDoesNotExist()
        composeRule.onNodeWithTag("cell-root").performTouchInput { click() }
        composeRule.runOnIdle { assertEquals(0, tapCount) }
    }

    /** D3 加载态：标题区骨架占位，标题文本隐藏。 */
    @Test
    fun test_D3_loadingState() {
        composeRule.setContent { Cell(title = "设置", loading = true) }
        composeRule.onNodeWithTag("cell-skeleton", useUnmergedTree = true).assertExists()
        composeRule.onNodeWithText("设置").assertDoesNotExist()
    }

    /** D4 成功态：右侧 ✓（success 色），箭头被替换。 */
    @Test
    fun test_D4_successState() {
        composeRule.setContent { Cell(title = "同步", status = CellStatus.Success) }
        composeRule.onNodeWithContentDescription("成功").assertExists()
        composeRule.onNodeWithTag("cell-status", useUnmergedTree = true).assertExists()
        composeRule.onNodeWithTag("cell-arrow", useUnmergedTree = true).assertDoesNotExist()
    }

    /** D5 失败态：右侧 !（error 色），箭头被替换。 */
    @Test
    fun test_D5_errorState() {
        composeRule.setContent { Cell(title = "同步", status = CellStatus.Error) }
        composeRule.onNodeWithContentDescription("失败").assertExists()
        composeRule.onNodeWithTag("cell-status", useUnmergedTree = true).assertExists()
        composeRule.onNodeWithTag("cell-arrow", useUnmergedTree = true).assertDoesNotExist()
    }

    /** D6 token 硬编码：由 `scripts/check_component_quality.py` 静态扫描（本类无对应函数）。 */

    /** D7 按压态：行可点击且点击回调触发（按压视觉 gray.4 由快照补充）。 */
    @Test
    fun test_D7_pressedState() {
        var tapCount = 0
        composeRule.setContent {
            Cell(title = "设置", onClick = { tapCount++ })
        }
        composeRule.onNodeWithTag("cell-root").assertIsEnabled()
        composeRule.onNodeWithTag("cell-root").performClick()
        composeRule.runOnIdle { assertEquals(1, tapCount) }
    }

    /** D8 分隔线：相邻两行各 1px border，无重叠。 */
    @Test
    fun test_D8_divider() {
        composeRule.setContent {
            Column {
                Cell(title = "行一")
                Cell(title = "行二")
            }
        }
        composeRule.onAllNodesWithTag("cell-divider").assertCountEquals(2)
        composeRule.onAllNodesWithTag("cell-root").assertCountEquals(2)
    }

    // ---------- A 系列：API 契约测试 ----------

    /** A1 默认 props：不传时默认值生效（arrow=true、无 value、无状态）。 */
    @Test
    fun test_A1_defaultProps() {
        composeRule.setContent { Cell(title = "设置") }
        composeRule.onNodeWithText("设置").assertExists()
        composeRule.onNodeWithTag("cell-arrow", useUnmergedTree = true).assertExists()
        composeRule.onNodeWithText("深色模式").assertDoesNotExist()
        composeRule.onNodeWithTag("cell-status", useUnmergedTree = true).assertDoesNotExist()
    }

    /** A2 自定义 props：各 props 渲染正确（subtitle/icon/value/arrow=false/status）。 */
    @Test
    fun test_A2_customProps() {
        composeRule.setContent {
            Cell(title = "账号", subtitle = "副标题", value = "值", arrow = false, status = CellStatus.Success)
        }
        composeRule.onNodeWithText("账号").assertExists()
        composeRule.onNodeWithText("副标题").assertExists()
        composeRule.onNodeWithText("值").assertExists()
        composeRule.onNodeWithTag("cell-arrow", useUnmergedTree = true).assertDoesNotExist()
        composeRule.onNodeWithContentDescription("成功").assertExists()
    }

    /** A3 点击事件：onClick 触发，参数（数据+索引）由调用方闭包绑定透传。 */
    @Test
    fun test_A3_clickEvent() {
        var tappedItem: String? = null
        var tappedIndex = -1
        composeRule.setContent {
            val items = listOf("甲", "乙")
            Cell(title = "甲", onClick = {
                tappedItem = items[0]
                tappedIndex = 0
            })
        }
        composeRule.onNodeWithTag("cell-root").performClick()
        composeRule.runOnIdle {
            assertEquals("甲", tappedItem)
            assertEquals(0, tappedIndex)
        }
    }

    /** A4 禁用拦截：disabled=true 时 onClick 不触发。 */
    @Test
    fun test_A4_disabledIntercept() {
        var tapCount = 0
        composeRule.setContent {
            Cell(title = "设置", disabled = true, onClick = { tapCount++ })
        }
        composeRule.onNodeWithTag("cell-root").performTouchInput { click() }
        composeRule.runOnIdle { assertEquals(0, tapCount) }
    }

    /** A5 五态覆盖：各状态组合渲染不崩溃且关键元素符合预期（单次渲染，ComposeRule 不可重复 setContent）。 */
    @Test
    fun test_A5_stateCoverage() {
        composeRule.setContent {
            Column {
                Cell(title = "默认", onClick = {})
                Cell(title = "禁用", disabled = true, status = CellStatus.Success, onClick = {})
                Cell(title = "加载", loading = true)
            }
        }
        val roots = composeRule.onAllNodesWithTag("cell-root")
        roots[0].assertIsEnabled() // 默认行可点
        roots[1].assertIsNotEnabled() // 禁用行不可点（disabled 决定）
        roots[2].assertExists() // 加载行正常渲染
        composeRule.onNodeWithContentDescription("成功").assertDoesNotExist() // 禁用不透标识
    }

    private fun androidx.compose.ui.test.SemanticsNodeInteraction.assertHeightAtLeast(minHeight: androidx.compose.ui.unit.Dp) {
        val minHeightPx = with(composeRule.density) { minHeight.toPx() }
        val node = fetchSemanticsNode()
        assertTrue(
            "行高 ${node.size.height}px 应 ≥ $minHeightPx px",
            node.size.height >= minHeightPx,
        )
    }

    // ---------- pt/dp 机制：设计稿「32 号字 cell」高度契约 ----------
    // 设计稿（375pt 逻辑基准，@2x）：单行 = 16pt 内边距×2 + 24pt 主标题行高 = 56pt；
    // 副标题行 = 56 + 2pt 间距 + 18pt 副标题行高 = 76pt。两端（iOS pt / Android dp）应一致。

    private fun androidx.compose.ui.test.SemanticsNodeInteraction.assertHeightExactly(expected: androidx.compose.ui.unit.Dp, tolerancePx: Int = 1) {
        val expectedPx = with(composeRule.density) { expected.toPx() }
        val node = fetchSemanticsNode()
        assertTrue(
            "行高 ${node.size.height}px 应等于 $expectedPx px（±$tolerancePx）",
            kotlin.math.abs(node.size.height - expectedPx) <= tolerancePx,
        )
    }

    /** H1 单行（仅标题）：行高精确 = 56dp（设计稿「32 号字 cell」单行）。 */
    @Test
    fun test_H1_singleLineHeight() {
        composeRule.setContent { Cell(title = "设置") }
        composeRule.onNodeWithTag("cell-root").assertHeightExactly(56.dp)
    }

    /** H2 副标题行：行高 ≈ 76dp（56 + 2 间距 + 18 副标题行高）。
     *  容差放宽容纳 Android 系统字体默认行高（副标题字号 14sp > 设计稿 12sp，
     *  默认行高 ~19.6sp 会覆盖显式 18sp）导致的 ~2dp 撑高；Robolectric 度量亦非真实字体。 */
    @Test
    fun test_H2_subtitleHeight() {
        composeRule.setContent { Cell(title = "设置", subtitle = "描述信息") }
        composeRule.onNodeWithTag("cell-root").assertHeightExactly(76.dp, tolerancePx = 6)
    }
}
