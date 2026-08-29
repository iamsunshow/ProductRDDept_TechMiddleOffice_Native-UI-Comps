package com.zhiqihuayun.sharedui.icons

import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.PathFillType
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.StrokeJoin
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.graphics.vector.PathNode
import androidx.compose.ui.graphics.vector.PathParser
import androidx.compose.ui.graphics.vector.path
import androidx.compose.ui.unit.dp

/**
 * SF Symbol 语义近似矢量（对齐 iOS MainTabBar / 明细下拉三角），
 * 统一 stroke 风格，避免 Material 默认字形破坏 1:1。
 */
object SfApproxIcons {
    val ListBulletRectangle: ImageVector by lazy {
        ImageVector.Builder(
            name = "list.bullet.rectangle",
            defaultWidth = 24.dp,
            defaultHeight = 24.dp,
            viewportWidth = 24f,
            viewportHeight = 24f
        ).apply {
            // rounded rect outline
            path(
                fill = SolidColor(Color.Transparent),
                stroke = SolidColor(Color.Black),
                strokeLineWidth = 1.6f,
                strokeLineCap = StrokeCap.Round,
                strokeLineJoin = StrokeJoin.Round
            ) {
                moveTo(4.5f, 5.5f)
                lineTo(19.5f, 5.5f)
                curveTo(20.3f, 5.5f, 21f, 6.2f, 21f, 7f)
                lineTo(21f, 17f)
                curveTo(21f, 17.8f, 20.3f, 18.5f, 19.5f, 18.5f)
                lineTo(4.5f, 18.5f)
                curveTo(3.7f, 18.5f, 3f, 17.8f, 3f, 17f)
                lineTo(3f, 7f)
                curveTo(3f, 6.2f, 3.7f, 5.5f, 4.5f, 5.5f)
                close()
            }
            // bullets + lines
            path(fill = SolidColor(Color.Black)) {
                moveTo(6.2f, 9.2f)
                curveTo(6.2f, 8.8f, 6.5f, 8.5f, 6.9f, 8.5f)
                curveTo(7.3f, 8.5f, 7.6f, 8.8f, 7.6f, 9.2f)
                curveTo(7.6f, 9.6f, 7.3f, 9.9f, 6.9f, 9.9f)
                curveTo(6.5f, 9.9f, 6.2f, 9.6f, 6.2f, 9.2f)
                close()
            }
            path(
                fill = SolidColor(Color.Transparent),
                stroke = SolidColor(Color.Black),
                strokeLineWidth = 1.5f,
                strokeLineCap = StrokeCap.Round
            ) {
                moveTo(9.5f, 9.2f)
                lineTo(17.5f, 9.2f)
            }
            path(fill = SolidColor(Color.Black)) {
                moveTo(6.2f, 12f)
                curveTo(6.2f, 11.6f, 6.5f, 11.3f, 6.9f, 11.3f)
                curveTo(7.3f, 11.3f, 7.6f, 11.6f, 7.6f, 12f)
                curveTo(7.6f, 12.4f, 7.3f, 12.7f, 6.9f, 12.7f)
                curveTo(6.5f, 12.7f, 6.2f, 12.4f, 6.2f, 12f)
                close()
            }
            path(
                fill = SolidColor(Color.Transparent),
                stroke = SolidColor(Color.Black),
                strokeLineWidth = 1.5f,
                strokeLineCap = StrokeCap.Round
            ) {
                moveTo(9.5f, 12f)
                lineTo(17.5f, 12f)
            }
            path(fill = SolidColor(Color.Black)) {
                moveTo(6.2f, 14.8f)
                curveTo(6.2f, 14.4f, 6.5f, 14.1f, 6.9f, 14.1f)
                curveTo(7.3f, 14.1f, 7.6f, 14.4f, 7.6f, 14.8f)
                curveTo(7.6f, 15.2f, 7.3f, 15.5f, 6.9f, 15.5f)
                curveTo(6.5f, 15.5f, 6.2f, 15.2f, 6.2f, 14.8f)
                close()
            }
            path(
                fill = SolidColor(Color.Transparent),
                stroke = SolidColor(Color.Black),
                strokeLineWidth = 1.5f,
                strokeLineCap = StrokeCap.Round
            ) {
                moveTo(9.5f, 14.8f)
                lineTo(15.5f, 14.8f)
            }
        }.build()
    }

    val ChartXyAxisLine: ImageVector by lazy {
        ImageVector.Builder(
            name = "chart.xyaxis.line",
            defaultWidth = 24.dp,
            defaultHeight = 24.dp,
            viewportWidth = 24f,
            viewportHeight = 24f
        ).apply {
            path(
                fill = SolidColor(Color.Transparent),
                stroke = SolidColor(Color.Black),
                strokeLineWidth = 1.6f,
                strokeLineCap = StrokeCap.Round,
                strokeLineJoin = StrokeJoin.Round
            ) {
                moveTo(4f, 4f)
                lineTo(4f, 18.5f)
                lineTo(20f, 18.5f)
            }
            path(
                fill = SolidColor(Color.Transparent),
                stroke = SolidColor(Color.Black),
                strokeLineWidth = 1.7f,
                strokeLineCap = StrokeCap.Round,
                strokeLineJoin = StrokeJoin.Round
            ) {
                moveTo(6.5f, 15f)
                lineTo(10f, 10.5f)
                lineTo(13.2f, 12.8f)
                lineTo(18.5f, 6.5f)
            }
        }.build()
    }

    val PlusCircleFill: ImageVector by lazy {
        ImageVector.Builder(
            name = "plus.circle.fill",
            defaultWidth = 24.dp,
            defaultHeight = 24.dp,
            viewportWidth = 24f,
            viewportHeight = 24f
        ).apply {
            path(
                fill = SolidColor(Color.Black),
                pathFillType = PathFillType.EvenOdd
            ) {
                moveTo(12f, 2.5f)
                curveTo(6.75f, 2.5f, 2.5f, 6.75f, 2.5f, 12f)
                curveTo(2.5f, 17.25f, 6.75f, 21.5f, 12f, 21.5f)
                curveTo(17.25f, 21.5f, 21.5f, 17.25f, 21.5f, 12f)
                curveTo(21.5f, 6.75f, 17.25f, 2.5f, 12f, 2.5f)
                close()
                moveTo(12f, 7.2f)
                curveTo(11.5f, 7.2f, 11.1f, 7.6f, 11.1f, 8.1f)
                lineTo(11.1f, 11.1f)
                lineTo(8.1f, 11.1f)
                curveTo(7.6f, 11.1f, 7.2f, 11.5f, 7.2f, 12f)
                curveTo(7.2f, 12.5f, 7.6f, 12.9f, 8.1f, 12.9f)
                lineTo(11.1f, 12.9f)
                lineTo(11.1f, 15.9f)
                curveTo(11.1f, 16.4f, 11.5f, 16.8f, 12f, 16.8f)
                curveTo(12.5f, 16.8f, 12.9f, 16.4f, 12.9f, 15.9f)
                lineTo(12.9f, 12.9f)
                lineTo(15.9f, 12.9f)
                curveTo(16.4f, 12.9f, 16.8f, 12.5f, 16.8f, 12f)
                curveTo(16.8f, 11.5f, 16.4f, 11.1f, 15.9f, 11.1f)
                lineTo(12.9f, 11.1f)
                lineTo(12.9f, 8.1f)
                curveTo(12.9f, 7.6f, 12.5f, 7.2f, 12f, 7.2f)
                close()
            }
        }.build()
    }

    val Safari: ImageVector by lazy {
        ImageVector.Builder(
            name = "safari",
            defaultWidth = 24.dp,
            defaultHeight = 24.dp,
            viewportWidth = 24f,
            viewportHeight = 24f
        ).apply {
            path(
                fill = SolidColor(Color.Transparent),
                stroke = SolidColor(Color.Black),
                strokeLineWidth = 1.6f
            ) {
                moveTo(12f, 3f)
                curveTo(7.03f, 3f, 3f, 7.03f, 3f, 12f)
                curveTo(3f, 16.97f, 7.03f, 21f, 12f, 21f)
                curveTo(16.97f, 21f, 21f, 16.97f, 21f, 12f)
                curveTo(21f, 7.03f, 16.97f, 3f, 12f, 3f)
                close()
            }
            path(fill = SolidColor(Color.Black)) {
                moveTo(8.2f, 15.8f)
                lineTo(10.6f, 10.6f)
                lineTo(15.8f, 8.2f)
                lineTo(13.4f, 13.4f)
                close()
            }
        }.build()
    }

    val Person: ImageVector by lazy {
        ImageVector.Builder(
            name = "person",
            defaultWidth = 24.dp,
            defaultHeight = 24.dp,
            viewportWidth = 24f,
            viewportHeight = 24f
        ).apply {
            path(
                fill = SolidColor(Color.Transparent),
                stroke = SolidColor(Color.Black),
                strokeLineWidth = 1.6f
            ) {
                moveTo(12f, 4.2f)
                curveTo(13.8f, 4.2f, 15.2f, 5.6f, 15.2f, 7.4f)
                curveTo(15.2f, 9.2f, 13.8f, 10.6f, 12f, 10.6f)
                curveTo(10.2f, 10.6f, 8.8f, 9.2f, 8.8f, 7.4f)
                curveTo(8.8f, 5.6f, 10.2f, 4.2f, 12f, 4.2f)
                close()
            }
            path(
                fill = SolidColor(Color.Transparent),
                stroke = SolidColor(Color.Black),
                strokeLineWidth = 1.6f,
                strokeLineCap = StrokeCap.Round
            ) {
                moveTo(5.5f, 19.5f)
                curveTo(5.5f, 16.2f, 8.3f, 13.8f, 12f, 13.8f)
                curveTo(15.7f, 13.8f, 18.5f, 16.2f, 18.5f, 19.5f)
            }
        }.build()
    }

    /** iOS `arrowtriangle.down.fill` @ ~8–10pt */
    val ArrowTriangleDownFill: ImageVector by lazy {
        ImageVector.Builder(
            name = "arrowtriangle.down.fill",
            defaultWidth = 10.dp,
            defaultHeight = 10.dp,
            viewportWidth = 10f,
            viewportHeight = 10f
        ).apply {
            path(fill = SolidColor(Color.Black)) {
                moveTo(1.2f, 3.2f)
                lineTo(8.8f, 3.2f)
                lineTo(5f, 8.2f)
                close()
            }
        }.build()
    }

    /* ───────────────────── 登录方式图标 ─────────────────────
     * 供「其他登录方式」等场景在彩色圆底上以白色显示：
     * - Smartphone / Mail：语义线性图标（对齐 SF 风格）
     * - Wechat / Weibo / QQ：品牌填充图标（可着色，圆底上呈白色）
     *   品牌 path 取自 Simple Icons（CC0 公共领域，对应各品牌官方单色 logo）
     * ──────────────────────────────────────────────────────── */

    /** 将 SVG `d` 路径字符串解析为 Compose PathNode 列表。 */
    private fun svgPathNodes(d: String): List<PathNode> =
        PathParser().parsePathString(d).toNodes()

    /** 手机图标（线性）：圆角机身 + 听筒 + 底部主屏横条。 */
    val Smartphone: ImageVector by lazy {
        ImageVector.Builder(
            name = "smartphone",
            defaultWidth = 24.dp,
            defaultHeight = 24.dp,
            viewportWidth = 24f,
            viewportHeight = 24f
        ).apply {
            path(
                fill = SolidColor(Color.Transparent),
                stroke = SolidColor(Color.Black),
                strokeLineWidth = 1.6f,
                strokeLineCap = StrokeCap.Round,
                strokeLineJoin = StrokeJoin.Round
            ) {
                moveTo(7.2f, 2.8f)
                lineTo(16.8f, 2.8f)
                curveTo(17.9f, 2.8f, 18.8f, 3.7f, 18.8f, 4.8f)
                lineTo(18.8f, 19.2f)
                curveTo(18.8f, 20.3f, 17.9f, 21.2f, 16.8f, 21.2f)
                lineTo(7.2f, 21.2f)
                curveTo(6.1f, 21.2f, 5.2f, 20.3f, 5.2f, 19.2f)
                lineTo(5.2f, 4.8f)
                curveTo(5.2f, 3.7f, 6.1f, 2.8f, 7.2f, 2.8f)
                close()
            }
            path(
                fill = SolidColor(Color.Transparent),
                stroke = SolidColor(Color.Black),
                strokeLineWidth = 1.5f,
                strokeLineCap = StrokeCap.Round
            ) {
                moveTo(10.5f, 18.2f)
                lineTo(13.5f, 18.2f)
            }
        }.build()
    }

    /** 邮箱图标（线性）：信封 + V 型封口。 */
    val Mail: ImageVector by lazy {
        ImageVector.Builder(
            name = "mail",
            defaultWidth = 24.dp,
            defaultHeight = 24.dp,
            viewportWidth = 24f,
            viewportHeight = 24f
        ).apply {
            path(
                fill = SolidColor(Color.Transparent),
                stroke = SolidColor(Color.Black),
                strokeLineWidth = 1.6f,
                strokeLineCap = StrokeCap.Round,
                strokeLineJoin = StrokeJoin.Round
            ) {
                moveTo(4.5f, 6f)
                lineTo(19.5f, 6f)
                curveTo(20.3f, 6f, 21f, 6.7f, 21f, 7.5f)
                lineTo(21f, 17f)
                curveTo(21f, 17.8f, 20.3f, 18.5f, 19.5f, 18.5f)
                lineTo(4.5f, 18.5f)
                curveTo(3.7f, 18.5f, 3f, 17.8f, 3f, 17f)
                lineTo(3f, 7.5f)
                curveTo(3f, 6.7f, 3.7f, 6f, 4.5f, 6f)
                close()
            }
            path(
                fill = SolidColor(Color.Transparent),
                stroke = SolidColor(Color.Black),
                strokeLineWidth = 1.5f,
                strokeLineCap = StrokeCap.Round,
                strokeLineJoin = StrokeJoin.Round
            ) {
                moveTo(4f, 7f)
                lineTo(12f, 13.2f)
                lineTo(20f, 7f)
            }
        }.build()
    }

    /** 微信图标（填充）：官方单色 logo（双对话气泡 + 眼睛）。 */
    val Wechat: ImageVector by lazy {
        ImageVector.Builder(
            name = "wechat",
            defaultWidth = 24.dp,
            defaultHeight = 24.dp,
            viewportWidth = 24f,
            viewportHeight = 24f
        ).apply {
            addPath(
                fill = SolidColor(Color.Black),
                pathData = svgPathNodes(
                    "M8.691 2.188C3.891 2.188 0 5.476 0 9.53c0 2.212 1.17 4.203 3.002 5.55a.59.59 0 0 1 .213.665l-.39 1.48c-.019.07-.048.141-.048.213 0 .163.13.295.29.295a.326.326 0 0 0 .167-.054l1.903-1.114a.864.864 0 0 1 .717-.098 10.16 10.16 0 0 0 2.837.403c.276 0 .543-.027.811-.05-.857-2.578.157-4.972 1.932-6.446 1.703-1.415 3.882-1.98 5.853-1.838-.576-3.583-4.196-6.348-8.596-6.348zM5.785 5.991c.642 0 1.162.529 1.162 1.18a1.17 1.17 0 0 1-1.162 1.178A1.17 1.17 0 0 1 4.623 7.17c0-.651.52-1.18 1.162-1.18zm5.813 0c.642 0 1.162.529 1.162 1.18a1.17 1.17 0 0 1-1.162 1.178 1.17 1.17 0 0 1-1.162-1.178c0-.651.52-1.18 1.162-1.18zm5.34 2.867c-1.797-.052-3.746.512-5.28 1.786-1.72 1.428-2.687 3.72-1.78 6.22.942 2.453 3.666 4.229 6.884 4.229.826 0 1.622-.12 2.361-.336a.722.722 0 0 1 .598.082l1.584.926a.272.272 0 0 0 .14.047c.134 0 .24-.111.24-.247 0-.06-.023-.12-.038-.177l-.327-1.233a.582.582 0 0 1-.023-.156.49.49 0 0 1 .201-.398C23.024 18.48 24 16.82 24 14.98c0-3.21-2.931-5.837-6.656-6.088V8.89c-.135-.01-.27-.027-.407-.03zm-2.53 3.274c.535 0 .969.44.969.982a.976.976 0 0 1-.969.983.976.976 0 0 1-.969-.983c0-.542.434-.982.97-.982zm4.844 0c.535 0 .969.44.969.982a.976.976 0 0 1-.969.983.976.976 0 0 1-.969-.983c0-.542.434-.982.969-.982z"
                )
            )
        }.build()
    }

    /** 微博图标（填充）：中心折线 + 弧线，对齐微博品牌辨识。 */
    val Weibo: ImageVector by lazy {
        ImageVector.Builder(
            name = "weibo",
            defaultWidth = 24.dp,
            defaultHeight = 24.dp,
            viewportWidth = 24f,
            viewportHeight = 24f
        ).apply {
            // 外圈
            addPath(
                fill = SolidColor(Color.Black),
                pathData = svgPathNodes(
                    "M10.098 20.323c-3.977.391-7.414-1.406-7.672-4.02-.259-2.609 2.759-5.047 6.74-5.441 3.979-.394 7.413 1.404 7.671 4.018.259 2.6-2.759 5.049-6.737 5.439l-.002.004zM9.05 17.219c-.384.616-1.208.884-1.829.602-.612-.279-.793-.991-.406-1.593.379-.595 1.176-.861 1.793-.601.622.263.82.972.442 1.592zm1.27-1.627c-.141.237-.449.353-.689.253-.236-.09-.313-.361-.177-.586.138-.227.436-.346.672-.24.239.09.315.36.18.601l.014-.028zm.176-2.719c-1.893-.493-4.033.45-4.857 2.118-.836 1.704-.026 3.591 1.886 4.21 1.983.64 4.318-.341 5.132-2.179.8-1.793-.201-3.642-2.161-4.149zm7.563-1.224c-.346-.105-.57-.18-.405-.615.375-.977.42-1.804 0-2.404-.781-1.112-2.915-1.053-5.364-.03 0 0-.766.331-.571-.271.376-1.217.315-2.224-.27-2.809-1.338-1.337-4.869.045-7.888 3.08C1.309 10.87 0 13.273 0 15.348c0 3.981 5.099 6.395 10.086 6.395 6.536 0 10.888-3.801 10.888-6.82 0-1.822-1.547-2.854-2.915-3.284v.01zm1.908-5.092c-.766-.856-1.908-1.187-2.96-.962-.436.09-.706.511-.616.932.09.42.511.691.932.602.511-.105 1.067.044 1.442.465.376.421.466.977.316 1.473-.136.406.089.856.51.992.405.119.857-.105.992-.512.33-1.021.12-2.178-.646-3.035l.03.045zm2.418-2.195c-1.576-1.757-3.905-2.419-6.054-1.968-.496.104-.812.587-.706 1.081.104.496.586.813 1.082.707 1.532-.331 3.185.15 4.296 1.383 1.112 1.246 1.429 2.943.947 4.416-.165.48.106 1.007.586 1.157.479.165.991-.104 1.157-.586.675-2.088.241-4.478-1.338-6.235l.03.045z"
                )
            )
        }.build()
    }

    /** QQ 图标（填充）：官方单色 logo（企鹅造型）。 */
    val QQ: ImageVector by lazy {
        ImageVector.Builder(
            name = "qq",
            defaultWidth = 24.dp,
            defaultHeight = 24.dp,
            viewportWidth = 24f,
            viewportHeight = 24f
        ).apply {
            addPath(
                fill = SolidColor(Color.Black),
                pathData = svgPathNodes(
                    "M21.395 15.035a40 40 0 0 0-.803-2.264l-1.079-2.695c.001-.032.014-.562.014-.836C19.526 4.632 17.351 0 12 0S4.474 4.632 4.474 9.241c0 .274.013.804.014.836l-1.08 2.695a39 39 0 0 0-.802 2.264c-1.021 3.283-.69 4.643-.438 4.673.54.065 2.103-2.472 2.103-2.472 0 1.469.756 3.387 2.394 4.771-.612.188-1.363.479-1.845.835-.434.32-.379.646-.301.778.343.578 5.883.369 7.482.189 1.6.18 7.14.389 7.483-.189.078-.132.132-.458-.301-.778-.483-.356-1.233-.646-1.846-.836 1.637-1.384 2.393-3.302 2.393-4.771 0 0 1.563 2.537 2.103 2.472.251-.03.581-1.39-.438-4.673"
                )
            )
        }.build()
    }
}
