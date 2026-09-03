package com.zhiqihuayun.sharedui.components

import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Paint
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.size
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.ImageBitmap
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.test.assertHeightIsEqualTo
import androidx.compose.ui.test.assertWidthIsEqualTo
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithContentDescription
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import org.junit.Assert.assertEquals
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config
import org.robolectric.annotation.GraphicsMode

/**
 * Image 图片组件测试：门禁 C1 用例映射（详见 `docs/验收流程/component-acceptance-image.md`）。
 *
 * - D1-D8 设计测试（默认渲染/loading/failed 态、fit/position 几何、radius、点击、无障碍）
 * - A1-A3 API 契约测试（默认 props、自定义 props、事件）
 * - H 几何零尺寸防护
 * - D6 token 硬编码扫描 / A6 契约 schema / A7 命名对齐 由 `scripts/check_component_quality.py` 执行
 *
 * 渲染断言方式（2026-09-03 C1 记录）：几何精度在纯函数层断言（D2/D2b/D3/D3b/H1，双端同向量）；
 * 结构/状态/无障碍/事件在语义树层断言。像素采样（captureToImage）在 Robolectric 下窗口捕获
 * 不产生帧（WindowCapture 超时，非组件缺陷），已从本类移除——真实视觉/像素验收归 C1.5 实机。
 * 根节点 `semantics(mergeDescendants=true)`，子节点（canvas/loading/error/占位文案）查询一律
 * `useUnmergedTree = true`（Cell 先例同款）。
 *
 * 运行：`./gradlew :components:testDebugUnitTest`（Robolectric 托管 Compose，无需模拟器）。
 * 验证组件库版本：v1.3.0（契约 `docs/api.json` `ui.image`，门禁 B ✅ 2026-09-03 冻结）。
 */
@RunWith(RobolectricTestRunner::class)
@GraphicsMode(GraphicsMode.Mode.NATIVE)
@Config(sdk = [34], qualifiers = "w411dp-h891dp")
class ImageTest {

    @get:Rule
    val composeRule = createComposeRule()

    // ---------- 标记图（320x200：下橙 / 上蓝，宽高比 3:2 ≠ 容器 4:3）----------

    private companion object {
        val markBlue = Color(0xFF176DE8)
        val markOrange = Color(0xFFF79E1B)

        fun markBitmap(w: Int, h: Int): ImageBitmap {
            val bmp = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888)
            val canvas = Canvas(bmp)
            canvas.drawColor(markBlue.toArgbInt())
            val paint = Paint().apply { color = markOrange.toArgbInt() }
            // 下半橙（y ∈ [h/2, h]）→ 上半蓝 / 下半橙，分界 y = h/2
            canvas.drawRect(0f, h / 2f, w.toFloat(), h.toFloat(), paint)
            return bmp.asImageBitmap()
        }
    }

    private fun setImage(
        src: Any? = markBitmap(320, 200),
        fit: String = "fill",
        position: String = "center",
        width: Dp? = null,
        height: Dp? = null,
        radius: Any? = null,
        alt: String? = null,
        loadingContent: (@Composable () -> Unit)? = null,
        errorContent: (@Composable () -> Unit)? = null,
        onTap: (() -> Unit)? = null,
        onLoad: (() -> Unit)? = null,
        onError: (() -> Unit)? = null,
        containerW: Dp = 120.dp,
        containerH: Dp = 90.dp,
    ) {
        composeRule.setContent {
            Box(Modifier.size(containerW, containerH)) {
                Image(
                    src = src,
                    fit = fit,
                    position = position,
                    width = width,
                    height = height,
                    radius = radius,
                    alt = alt,
                    loadingContent = loadingContent,
                    errorContent = errorContent,
                    onTap = onTap,
                    onLoad = onLoad,
                    onError = onError,
                )
            }
        }
    }

    /** Loaded 态：仅 canvas（绘制路径），无 loading/error 占位。 */
    private fun assertCanvasOnly() {
        composeRule.onNodeWithTag("image-canvas", useUnmergedTree = true).assertExists()
        composeRule.onNodeWithTag("image-loading", useUnmergedTree = true).assertDoesNotExist()
        composeRule.onNodeWithTag("image-error", useUnmergedTree = true).assertDoesNotExist()
    }

    // ---------- D1 默认渲染 / 状态机 ----------

    /** D1 默认态：图解码进入绘制路径（canvas 在），占位无残留，onLoad 一次。 */
    @Test
    fun test_D1_defaultStateLoaded() {
        var loadCount = 0
        var errorCount = 0
        setImage(onLoad = { loadCount++ }, onError = { errorCount++ })
        composeRule.waitForIdle()
        assertCanvasOnly()
        composeRule.runOnIdle {
            assertEquals(1, loadCount)
            assertEquals(0, errorCount)
        }
    }

    /** D5 src=null → loading 占位（业务模拟慢源/解码窗口）。占位=默认双色转圈（无限动画），断言不做 waitForIdle。 */
    @Test
    fun test_D5_loadingNull() {
        var loadCount = 0
        var errorCount = 0
        setImage(src = null, onLoad = { loadCount++ }, onError = { errorCount++ })
        composeRule.onNodeWithTag("image-loading", useUnmergedTree = true).assertExists()
        composeRule.onNodeWithTag("image-canvas", useUnmergedTree = true).assertDoesNotExist()
        composeRule.onNodeWithContentDescription("图片加载中").assertExists()
        // 无限动画下不可 runOnIdle；事件在本态不会触发，直接读计数即可
        assertEquals(0, loadCount)
        assertEquals(0, errorCount)
    }

    /** D5 慢源完成：loading → loaded，占位消失，onLoad 一次（占位用静态自定义插槽，避免无限动画阻塞 idle）。 */
    @Test
    fun test_D5_loadingThenLoaded() {
        var loadCount = 0
        var src by mutableStateOf<Any?>(null)
        composeRule.setContent {
            Box(Modifier.size(120.dp, 90.dp)) {
                Image(
                    src = src,
                    loadingContent = { androidx.compose.material3.Text("占位") },
                    onLoad = { loadCount++ },
                )
            }
        }
        composeRule.onNodeWithTag("image-loading", useUnmergedTree = true).assertDoesNotExist()
        composeRule.onNodeWithText("占位", useUnmergedTree = true).assertExists()

        composeRule.runOnIdle { src = markBitmap(320, 200) }
        composeRule.waitForIdle()
        assertCanvasOnly()
        composeRule.runOnIdle { assertEquals(1, loadCount) }
    }

    /** D5b 自定义 loading 占位生效。 */
    @Test
    fun test_D5b_customLoadingContent() {
        setImage(
            src = null,
            loadingContent = { androidx.compose.material3.Text("我的加载中") },
        )
        composeRule.onNodeWithText("我的加载中", useUnmergedTree = true).assertExists()
        composeRule.onNodeWithTag("image-loading", useUnmergedTree = true).assertDoesNotExist()
    }

    // ---------- D7 失败态 ----------

    /** D7 无效资源 → 失败占位 + onError 一次 + 可读语义。 */
    @Test
    fun test_D7_errorState() {
        var errorCount = 0
        setImage(src = "no_such_drawable_xyz", onError = { errorCount++ })
        composeRule.onNodeWithTag("image-error", useUnmergedTree = true).assertExists()
        composeRule.onNodeWithTag("image-canvas", useUnmergedTree = true).assertDoesNotExist()
        composeRule.onNodeWithText("加载失败", useUnmergedTree = true).assertExists()
        composeRule.onNodeWithContentDescription("图片加载失败").assertExists()
        composeRule.runOnIdle { assertEquals(1, errorCount) }
    }

    /** D7b 自定义 error 占位生效。 */
    @Test
    fun test_D7b_customErrorContent() {
        setImage(
            src = "no_such_drawable_xyz",
            errorContent = { androidx.compose.material3.Text("自定义失败") },
        )
        composeRule.onNodeWithText("自定义失败", useUnmergedTree = true).assertExists()
        composeRule.onNodeWithTag("image-error", useUnmergedTree = true).assertDoesNotExist()
    }

    /** D7c P4=B 重试：失败后重设合法 src 恢复渲染。 */
    @Test
    fun test_D7c_retryAfterError() {
        var errorCount = 0
        var loadCount = 0
        var src by mutableStateOf<Any?>("no_such_drawable_xyz")
        composeRule.setContent {
            Box(Modifier.size(120.dp, 90.dp)) {
                Image(src = src, onLoad = { loadCount++ }, onError = { errorCount++ })
            }
        }
        composeRule.onNodeWithTag("image-error", useUnmergedTree = true).assertExists()
        composeRule.runOnIdle { assertEquals(1, errorCount) }

        composeRule.runOnIdle { src = markBitmap(320, 200) }
        composeRule.waitForIdle()
        assertCanvasOnly()
        composeRule.runOnIdle {
            assertEquals(1, errorCount)
            assertEquals(1, loadCount)
        }
    }

    // ---------- D2/D3 几何（数学闭环，向量与 iOS ImageTests 相同）----------

    private fun assertRectF(actual: android.graphics.RectF, x: Float, y: Float, w: Float, h: Float, tol: Float = 0.01f) {
        assertEquals(x, actual.left, tol)
        assertEquals(y, actual.top, tol)
        assertEquals(w, actual.width(), tol)
        assertEquals(h, actual.height(), tol)
    }

    /** D2 fit 五值绘制矩形（容器 120x90、图 320x200）。 */
    @Test
    fun test_D2_fitGeometryAllValues() {
        assertRectF(ImageGeometry.rect(120f, 90f, 320f, 200f, "fill", "center"), 0f, 0f, 120f, 90f)
        // contain: scale=0.375 → 120x75，垂直留空 15 居中
        assertRectF(ImageGeometry.rect(120f, 90f, 320f, 200f, "contain", "center"), 0f, 7.5f, 120f, 75f)
        // cover: scale=0.45 → 144x90，水平超 24 居中裁
        assertRectF(ImageGeometry.rect(120f, 90f, 320f, 200f, "cover", "center"), -12f, 0f, 144f, 90f)
        // none: 原始尺寸 320x200
        assertRectF(ImageGeometry.rect(120f, 90f, 320f, 200f, "none", "center"), -100f, -55f, 320f, 200f)
        // scale-down（图大）：同 contain
        assertRectF(ImageGeometry.rect(120f, 90f, 320f, 200f, "scale-down", "center"), 0f, 7.5f, 120f, 75f)
    }

    /** D2b scale-down 小图不放大（对照 contain 放大）。 */
    @Test
    fun test_D2b_scaleDownSmallImageNotEnlarged() {
        // scale-down：图 60x40 小于容器 → 原尺寸渲染（居中，四周留空 30/25）
        assertRectF(ImageGeometry.rect(120f, 90f, 60f, 40f, "scale-down", "center"), 30f, 25f, 60f, 40f)
        // contain：图 60x40 → scale=2 → 120x80，垂直留空 10（y=5）——对照放大行为
        assertRectF(ImageGeometry.rect(120f, 90f, 60f, 40f, "contain", "center"), 0f, 5f, 120f, 80f)
    }

    /** D3 position 停靠锚点数学。 */
    @Test
    fun test_D3_positionAnchorMath() {
        // 垂直留空：容器 160x240、图 80x60 → 160x120，垂直留空 120
        assertRectF(ImageGeometry.rect(160f, 240f, 80f, 60f, "contain", "top"), 0f, 0f, 160f, 120f)
        assertRectF(ImageGeometry.rect(160f, 240f, 80f, 60f, "contain", "center"), 0f, 60f, 160f, 120f)
        assertRectF(ImageGeometry.rect(160f, 240f, 80f, 60f, "contain", "bottom"), 0f, 120f, 160f, 120f)
        // 水平留空：容器 240x160 → 213.33x160，right 锚右缘
        val r = ImageGeometry.rect(240f, 160f, 80f, 60f, "contain", "right")
        assertEquals(240f, r.right, 0.02f)
        assertEquals(0f, r.top, 0.02f)
    }

    /** D3b cover 超容器锚定（right 保留内容右端 / left 保留左端）。 */
    @Test
    fun test_D3b_coverOversizeAnchor() {
        assertRectF(ImageGeometry.rect(100f, 100f, 200f, 50f, "cover", "right"), -300f, 0f, 400f, 100f)
        assertRectF(ImageGeometry.rect(100f, 100f, 200f, 50f, "cover", "left"), 0f, 0f, 400f, 100f)
    }

    /** D2 渲染路径连通：contain / cover 均进入绘制路径（canvas 在、无占位残留）。 */
    @Test
    fun test_D2_renderContainAndCover() {
        var fit by mutableStateOf("contain")
        composeRule.setContent {
            Box(Modifier.size(120.dp, 90.dp)) {
                Image(src = markBitmap(320, 200), fit = fit)
            }
        }
        composeRule.waitForIdle()
        assertCanvasOnly()

        composeRule.runOnIdle { fit = "cover" }
        composeRule.waitForIdle()
        assertCanvasOnly()
    }

    /** H1 容器或图尺寸为零 → 空 rect（防除零）。 */
    @Test
    fun test_H1_zeroSizedGuard() {
        assertRectF(ImageGeometry.rect(0f, 0f, 10f, 10f, "contain", "center"), 0f, 0f, 0f, 0f)
        assertRectF(ImageGeometry.rect(10f, 10f, 0f, 0f, "cover", "center"), 0f, 0f, 0f, 0f)
    }

    // ---------- D4 圆角 / D8 点击与无障碍 ----------

    /** D4 radius：token 档位 / 数值 / 空。 */
    @Test
    fun test_D4_radiusTokensAndNumeric() {
        assertEquals(0.dp, parseRadius(null))
        assertEquals(6.dp, parseRadius("sm"))
        assertEquals(10.dp, parseRadius("md"))
        assertEquals(14.dp, parseRadius("lg"))
        assertEquals(24.dp, parseRadius(24))
        assertEquals(24.5.dp, parseRadius(24.5))
    }

    /** D4b 圆形语义 = radius 传宽/2（P3=A 无魔法值）——48dp 容器 + radius 24 渲染不抛。 */
    @Test
    fun test_D4b_circleSemantics() {
        setImage(radius = 24, containerW = 48.dp, containerH = 48.dp)
        composeRule.onNodeWithTag("image-canvas", useUnmergedTree = true).assertExists()
    }

    /** D8 点击容器任意区域触发 onTap（语义 performClick → 点击区域 = 容器内全部）。 */
    @Test
    fun test_D8_tapEvent() {
        var tapCount = 0
        setImage(onTap = { tapCount++ })
        composeRule.onNodeWithTag("image-root").performClick()
        composeRule.runOnIdle { assertEquals(1, tapCount) }
    }

    /** D8 alt → contentDescription（无障碍语义）。 */
    @Test
    fun test_D8_altAccessibility() {
        setImage(alt = "用户头像")
        composeRule.onNodeWithContentDescription("用户头像").assertExists()
    }

    // ---------- A 系列 API 契约 ----------

    /** A1 默认 props：撑满父容器、进入绘制路径、无占位残留。 */
    @Test
    fun test_A1_defaultsFillContainer() {
        setImage(containerW = 120.dp, containerH = 90.dp)
        composeRule.waitForIdle()
        composeRule.onNodeWithTag("image-root").assertWidthIsEqualTo(120.dp)
        composeRule.onNodeWithTag("image-root").assertHeightIsEqualTo(90.dp)
        assertCanvasOnly()
    }

    /** A2 自定义 props：width/height/radius/alt 生效（父容器给足余量 260x120）。 */
    @Test
    fun test_A2_customProps() {
        setImage(width = 200.dp, height = 90.dp, radius = "md", alt = "封面", containerW = 260.dp, containerH = 120.dp)
        composeRule.onNodeWithTag("image-root").assertWidthIsEqualTo(200.dp)
        composeRule.onNodeWithTag("image-root").assertHeightIsEqualTo(90.dp)
        composeRule.onNodeWithContentDescription("封面").assertExists()
    }

    /** A3 事件独立触发：失败态 onError、恢复 loaded 后 onLoad 各一次（状态驱动单次 setContent）。 */
    @Test
    fun test_A3_callbacksIndependent() {
        var loadCount = 0
        var errorCount = 0
        var src by mutableStateOf<Any?>("no_such_drawable_xyz")
        composeRule.setContent {
            Box(Modifier.size(120.dp, 90.dp)) {
                Image(src = src, onLoad = { loadCount++ }, onError = { errorCount++ })
            }
        }
        composeRule.runOnIdle { assertEquals(1, errorCount) }
        composeRule.runOnIdle { assertEquals(0, loadCount) }

        composeRule.runOnIdle { src = markBitmap(320, 200) }
        composeRule.waitForIdle()
        composeRule.runOnIdle {
            assertEquals(1, errorCount)
            assertEquals(1, loadCount)
        }
    }
}

private fun Color.toArgbInt(): Int = (0xFF shl 24) or
    ((red * 255).toInt() shl 16) or ((green * 255).toInt() shl 8) or (blue * 255).toInt()
