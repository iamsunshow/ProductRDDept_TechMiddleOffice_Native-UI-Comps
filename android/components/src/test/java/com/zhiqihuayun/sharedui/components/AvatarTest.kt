package com.zhiqihuayun.sharedui.components

import androidx.compose.ui.graphics.Color
import androidx.compose.ui.test.assertCountEquals
import androidx.compose.ui.test.assertHeightIsAtLeast
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.assertWidthIsAtLeast
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onAllNodesWithTag
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.unit.dp
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config
import org.robolectric.annotation.GraphicsMode

/**
 * Avatar 头像 · 组件测试
 *
 * 验证组件库版本：v1.4.16（契约 ui.avatar）。
 * 用例覆盖 2026-09-10 Avatar 多轮调试复盘的三个根因，防复发：
 *   #53 iOS UIView 在 UIStackView 中无 intrinsicContentSize 退化成 0 → L1 容器尺寸=size 参数校验（Android 侧 .size() 保证，此用例防退化）
 *   #54 Android Color(tintHex) RGB 3字节当 ARGB=alpha=0 透明 → L1 avatarTintColor 补 0xFF alpha 校验 + 文字节点存在校验
 *   #55 AvatarDemo 外层漏 verticalScroll（Demo 层问题，单测覆盖容器尺寸间接保证内容可渲染）
 */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [30])
@GraphicsMode(GraphicsMode.Mode.NATIVE)
class AvatarTest {

    @get:Rule
    val composeTestRule = createComposeRule()

    private val mockOption = AvatarOption("白羊座", "♈", 0xDC2626)

    // ── 根因 #53: 容器尺寸 = size 参数（防止退化成 0） ──

    @Test
    fun `option=null 容器尺寸等于 size 参数`() {
        composeTestRule.setContent {
            ZodiacAvatar(option = null, nickname = "张三", size = 56.dp)
        }

        // 容器尺寸 >= 56dp（防止 UIStackView 中无 intrinsicContentSize 退化成 0）
        composeTestRule.onNodeWithTag(AvatarTestTags.CONTAINER).assertWidthIsAtLeast(56.dp)
        composeTestRule.onNodeWithTag(AvatarTestTags.CONTAINER).assertHeightIsAtLeast(56.dp)
    }

    @Test
    fun `option=非null 容器尺寸等于 size 参数`() {
        composeTestRule.setContent {
            ZodiacAvatar(option = mockOption, nickname = "白羊", size = 72.dp)
        }

        // 星座模式容器尺寸 >= 72dp
        composeTestRule.onNodeWithTag(AvatarTestTags.CONTAINER).assertWidthIsAtLeast(72.dp)
        composeTestRule.onNodeWithTag(AvatarTestTags.CONTAINER).assertHeightIsAtLeast(72.dp)
    }

    @Test
    fun `自定义 size=40dp 容器尺寸正确`() {
        composeTestRule.setContent {
            ZodiacAvatar(option = mockOption, nickname = "Leo", size = 40.dp)
        }

        composeTestRule.onNodeWithTag(AvatarTestTags.CONTAINER).assertWidthIsAtLeast(40.dp)
        composeTestRule.onNodeWithTag(AvatarTestTags.CONTAINER).assertHeightIsAtLeast(40.dp)
    }

    // ── 根因 #54: 星座符号文字节点存在（alpha=0 透明时仍渲染但不可见，此用例验证节点存在） ──

    @Test
    fun `option=null 显示昵称首字`() {
        composeTestRule.setContent {
            ZodiacAvatar(option = null, nickname = "张三", size = 56.dp)
        }

        // 文字节点存在（昵称首字"张"）
        composeTestRule.onAllNodesWithTag(AvatarTestTags.SYMBOL).assertCountEquals(1)
        composeTestRule.onNodeWithTag(AvatarTestTags.SYMBOL).assertIsDisplayed()
    }

    @Test
    fun `option=非null 显示星座符号`() {
        composeTestRule.setContent {
            ZodiacAvatar(option = mockOption, nickname = "白羊", size = 56.dp)
        }

        // 文字节点存在（星座符号 ♈）—— 根因 #54：之前 Color(tintHex) alpha=0 透明虽渲染但不可见
        composeTestRule.onAllNodesWithTag(AvatarTestTags.SYMBOL).assertCountEquals(1)
        composeTestRule.onNodeWithTag(AvatarTestTags.SYMBOL).assertIsDisplayed()
    }

    // ── 根因 #54: avatarTintColor 补 0xFF alpha（单元测试，直接验证颜色不透明） ──

    @Test
    fun `avatarTintColor 补 0xFF alpha 前缀使颜色不透明`() {
        // RGB 3字节 0xDC2626 → ARGB 0xFFDC2626（alpha=255 不透明）
        val color = avatarTintColor(0xDC2626)
        assert(color.alpha == 1.0f) { "alpha 应为 1.0（不透明），实际 ${color.alpha}；根因 #54：Color(Long) 把 RGB 当 ARGB 导致 alpha=0" }
        assert(color.red == 0xDC / 255f) { "red 分量应保持 0xDC" }
        assert(color.green == 0x26 / 255f) { "green 分量应保持 0x26" }
        assert(color.blue == 0x26 / 255f) { "blue 分量应保持 0x26" }
    }

    @Test
    fun `avatarTintColor 对各星座色均不透明`() {
        val signs = listOf(
            0xDC2626L, // 白羊红
            0x16A34AL, // 金牛绿
            0x2563EBL, // 双子蓝
            0x7C3AEDL, // 巨蟹紫
            0xEA580CL, // 狮子橙
        )
        for (hex in signs) {
            val color = avatarTintColor(hex)
            assert(color.alpha == 1.0f) { "hex=$hex alpha 应为 1.0，实际 ${color.alpha}" }
        }
    }
}
