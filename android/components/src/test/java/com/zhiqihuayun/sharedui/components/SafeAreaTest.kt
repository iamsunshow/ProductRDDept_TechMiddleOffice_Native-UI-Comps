package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Text
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.assertHeightIsAtLeast
import androidx.compose.ui.test.assertWidthIsAtLeast
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
 * SafeArea 安全区回归测试（#19 ui.safe-area，台账 #6/#7 行，验证组件库 v1.4.0）。
 *
 * 回归背景：
 * - #6：Android 中部容器异常避让=旧实现组合期直接读 WindowInsets.safeDrawing 全局值转 dp 套普通
 *   padding，不经过 insets 传播链，父级 consumeWindowInsets 拦不住=页面中部容器也叠加上下系统区避让。
 *   修复=改用 windowInsetsPadding(insets.only(side)) 读传播链剩余值（祖先消费后=0）。
 * - #7：Android 容器被压成灰条=错用 windowInsetsTopHeight/BottomHeight/StartWidth/EndWidth
 *   （语义=把 inset 值设为元素尺寸，等价 Modifier.height(inset)，专配 Spacer 占位），四边叠加互相抢
 *   高宽，SafeArea 容器被压成一条。修复=逐边 only(sides) 后套 windowInsetsPadding（真 padding）。
 *
 * 本文件用例断言：
 * - SafeArea 容器不被压扁（高/宽≥合理阈值，不复现 #7 灰条）
 * - 内容完整显示
 * - 各边组合不崩
 */
@RunWith(RobolectricTestRunner::class)
@GraphicsMode(GraphicsMode.Mode.NATIVE)
@Config(sdk = [34], qualifiers = "w411dp-h891dp")
class SafeAreaTest {

    @get:Rule
    val composeRule = createComposeRule()

    /** #7 回归：SafeArea 容器不被压扁（旧实现 windowInsets*Height 把容器压成灰条）。 */
    @Test
    fun test_regression_容器不被压扁() {
        composeRule.setContent {
            Box(Modifier.fillMaxSize().padding(16.dp)) {
                SafeArea(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(200.dp)
                        .background(Color.Blue)
                        .testTag("safe-area")
                ) {
                    Box(Modifier.fillMaxSize().background(Color.Green))
                }
            }
        }
        val node = composeRule.onNodeWithTag("safe-area")
        node.assertIsDisplayed()
        // 复现 #7：旧实现容器被压成 0~几 dp 灰条；修复后高度≈200dp
        node.assertHeightIsAtLeast(100.dp)
        node.assertWidthIsAtLeast(100.dp)
    }

    /** SafeArea 内内容完整显示（不被裁剪）。 */
    @Test
    fun test_内容完整显示() {
        composeRule.setContent {
            Box(Modifier.fillMaxSize().padding(16.dp)) {
                SafeArea(modifier = Modifier.fillMaxWidth().height(200.dp)) {
                    Text("安全区内容", modifier = Modifier.testTag("content"))
                }
            }
        }
        composeRule.onNodeWithText("安全区内容").assertIsDisplayed()
    }

    /** 仅顶边避让不崩。 */
    @Test
    fun test_仅顶边避让() {
        composeRule.setContent {
            Box(Modifier.fillMaxSize().padding(16.dp)) {
                SafeArea(
                    edges = setOf(SafeAreaEdges.Top),
                    modifier = Modifier.fillMaxWidth().height(100.dp)
                ) {
                    Text("仅顶", modifier = Modifier.testTag("top-content"))
                }
            }
        }
        composeRule.onNodeWithText("仅顶").assertIsDisplayed()
    }

    /** 仅底边避让不崩。 */
    @Test
    fun test_仅底边避让() {
        composeRule.setContent {
            Box(Modifier.fillMaxSize().padding(16.dp)) {
                SafeArea(
                    edges = setOf(SafeAreaEdges.Bottom),
                    modifier = Modifier.fillMaxWidth().height(100.dp)
                ) {
                    Text("仅底", modifier = Modifier.testTag("bottom-content"))
                }
            }
        }
        composeRule.onNodeWithText("仅底").assertIsDisplayed()
    }

    /** 空边集合（不避让任何边）不崩=内容直接铺满。 */
    @Test
    fun test_空边集合不崩() {
        composeRule.setContent {
            Box(Modifier.fillMaxSize().padding(16.dp)) {
                SafeArea(
                    edges = emptySet(),
                    modifier = Modifier.fillMaxWidth().height(100.dp)
                ) {
                    Text("无边", modifier = Modifier.testTag("no-edge-content"))
                }
            }
        }
        composeRule.onNodeWithText("无边").assertIsDisplayed()
    }

    /** 默认全边避让=四边都套 windowInsetsPadding 不崩（回归 #6）。 */
    @Test
    fun test_默认全边避让不崩() {
        composeRule.setContent {
            Box(Modifier.fillMaxSize().padding(16.dp)) {
                SafeArea(modifier = Modifier.fillMaxWidth().height(100.dp).testTag("all-edges")) {
                    Text("全边")
                }
            }
        }
        composeRule.onNodeWithTag("all-edges").assertIsDisplayed()
    }
}
