// Image 图片 · 增强版图片容器（Android 顶层函数与 iOS 类同名，跨端调用形式一致）
//
// 组件库版本：v1.3.0（契约 `docs/api.json` `ui.image`，门禁 B ✅ 2026-09-03 冻结）。
// 能力：fit 五模式 / position 停靠 / width·height / radius（token 档位或任意值，=宽/2 即圆形）/
// alt 无障碍 / 加载中·失败占位（可自定义）/ onTap·onLoad·onError。
// 对标 NutUI React Image（增强版 img）；不内置预览（属独立 ImagePreview）。
//
// 设计决策（门禁 A 拍板）：P1=B 网络图 URL 归业务预下载后传图对象（零三方图片加载依赖）；
// P2=B lazy 一期 N/A；P3=A 圆形 = radius 传宽/2（无魔法值）；P4=B 失败仅 onError（重试=重设 src）。
// src 语义：null=加载中占位；String=包内 drawable 资源名；Int=@DrawableRes；ImageBitmap/Bitmap=平台图对象。
// Android 与 iOS 资源体系差异（登记平台差异.md，与 Cell.icon 同型）：String 解析经 context 按
// packageName 查 drawable；Asset Catalog 名 ↔ 包内 drawable 名由业务资源规范保证同名。
//
// 几何：绘制矩形在 px 空间用 `ImageGeometry.rect`（与 iOS `ImageGeometry.rect` 同公式同数学，
// D2/D3 双端断言用同一组数值向量）。none/scale-down 的"原尺寸"取 bitmap 原始 px——资源按
// 1x 逻辑尺寸交付双端时视觉等价 iOS point 语义（设计规范约定）。
//
// 命名：本文件不 import androidx.compose.foundation.Image，避免与组件名冲突
// （同文件内需要绘制位图一律用 Canvas.drawImage）。

package com.zhiqihuayun.sharedui.components

import android.content.Context
import android.graphics.Bitmap
import android.graphics.drawable.BitmapDrawable
import androidx.compose.foundation.Canvas
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.ImageBitmap
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.IntOffset
import androidx.compose.ui.unit.IntSize
import androidx.compose.ui.unit.dp
import androidx.core.graphics.drawable.toBitmap
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppFont
import com.zhiqihuayun.foundation.design.AppRadius
import com.zhiqihuayun.foundation.design.AppSpace
import kotlin.math.max
import kotlin.math.min
import kotlin.math.roundToInt

/** 解析结果。null = 加载中占位（src 为 null 时）；Failed = 资源不可解析/不存在。 */
private sealed interface ImageResolved {
    data class Success(val bitmap: ImageBitmap) : ImageResolved
    data object Failed : ImageResolved
}

/**
 * 圆角解析（契约 radius：number | 'sm' | 'md' | 'lg'，默认 0=无圆角）：
 * token 档位 → 档位 dp；Number → 数值 dp；Dp 直通；非法/空 → 0。=宽/2 即圆形（P3=A，无魔法值）。
 */
internal fun parseRadius(radius: Any?): Dp = when (radius) {
    is String -> when (radius) {
        "sm" -> AppRadius.sm
        "md" -> AppRadius.md
        "lg" -> AppRadius.lg
        else -> 0.dp
    }
    is Dp -> radius
    is Number -> radius.toFloat().dp
    else -> 0.dp
}

/** 图源解析：ImageBitmap/Bitmap 直接成功；Int(@DrawableRes)/String(资源名) 尽力解码，失败 → Failed。 */
private fun resolveImage(context: Context, src: Any?): ImageResolved? {
    if (src == null) return null
    return when (src) {
        is ImageBitmap -> ImageResolved.Success(src)
        is Bitmap -> ImageResolved.Success(src.asImageBitmap())
        is Int -> decodeRes(context, src)?.let { ImageResolved.Success(it) } ?: ImageResolved.Failed
        is String -> {
            val id = context.resources.getIdentifier(src, "drawable", context.packageName)
            if (id != 0) decodeRes(context, id)?.let { ImageResolved.Success(it) } ?: ImageResolved.Failed
            else ImageResolved.Failed
        }
        else -> ImageResolved.Failed
    }
}

private fun decodeRes(context: Context, resId: Int): ImageBitmap? = try {
    val drawable = context.resources.getDrawable(resId, null)
    val bitmap = when {
        drawable is BitmapDrawable && drawable.bitmap != null -> drawable.bitmap
        drawable.intrinsicWidth > 0 && drawable.intrinsicHeight > 0 ->
            drawable.toBitmap(drawable.intrinsicWidth, drawable.intrinsicHeight)
        else -> drawable.toBitmap()
    }
    bitmap.asImageBitmap()
} catch (_: Throwable) {
    null
}

/** 绘制矩形纯函数：与 iOS `ImageGeometry.rect` 同公式同数学定义（单位一致即可，此处 px）。 */
object ImageGeometry {
    fun horizontalAnchor(position: String): Float = when (position) {
        "left" -> 0f
        "center" -> 0.5f
        "right" -> 1f
        else -> 0.5f // top/bottom/非法值：垂直停靠不影响水平锚
    }

    fun verticalAnchor(position: String): Float = when (position) {
        "top" -> 0f
        "center" -> 0.5f
        "bottom" -> 1f
        else -> 0.5f // left/right/非法值：水平停靠不影响垂直锚
    }

    /** fill: 铺满；contain: scale=min；cover: scale=max；none: 原尺寸；scale-down: 不放大。 */
    fun rect(
        containerW: Float,
        containerH: Float,
        imageW: Float,
        imageH: Float,
        fit: String,
        position: String,
    ): android.graphics.RectF {
        val w = containerW
        val h = containerH
        val iw = imageW
        val ih = imageH
        if (w <= 0f || h <= 0f || iw <= 0f || ih <= 0f) return android.graphics.RectF(0f, 0f, 0f, 0f)

        val (dw, dh) = when (fit) {
            "fill" -> w to h
            "contain" -> {
                val s = min(w / iw, h / ih)
                iw * s to ih * s
            }
            "cover" -> {
                val s = max(w / iw, h / ih)
                iw * s to ih * s
            }
            "none" -> iw to ih
            "scale-down" -> {
                val s = min(min(w / iw, h / ih), 1f)
                iw * s to ih * s
            }
            else -> w to h // 非法 fit 值兜底为 fill（契约五值约束）
        }

        val ax = horizontalAnchor(position)
        val ay = verticalAnchor(position)
        val x = ax * (w - dw)
        val y = ay * (h - dh)
        return android.graphics.RectF(x, y, x + dw, y + dh)
    }
}

private enum class ImageUiState { Loading, Loaded, Failed }

/**
 * 增强版图片容器。
 * @param src 图源：null=加载中占位；String=包内 drawable 资源名；Int=@DrawableRes；ImageBitmap/Bitmap=图对象。
 * @param fit 对象填充模式：'fill' | 'contain' | 'cover' | 'none' | 'scale-down'（默认 'fill'）
 * @param position 内容停靠：'center' | 'top' | 'right' | 'bottom' | 'left'（默认 'center'）
 * @param width 布局宽度（默认撑满父容器）；@param height 布局高度（默认撑满父容器）
 * @param radius 圆角：null/0=无；'sm'/'md'/'lg'=token 档位；Number=数值 dp；=宽/2 即圆形
 * @param alt 无障碍描述（contentDescription）
 * @param loadingContent / errorContent 占位自定义内容（默认内置绘制）
 * @param onTap / onLoad / onError 事件
 */
@Composable
fun Image(
    src: Any? = null,
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
    modifier: Modifier = Modifier,
) {
    val context = LocalContext.current
    val resolved = remember(src, context) { resolveImage(context, src) }
    val state = when {
        resolved == null -> ImageUiState.Loading
        resolved is ImageResolved.Failed -> ImageUiState.Failed
        else -> ImageUiState.Loaded
    }

    // 事件（P4=B：失败仅 onError；重试 = 业务重设 src，状态重新流转）
    LaunchedEffect(state) {
        when (state) {
            ImageUiState.Loaded -> onLoad?.invoke()
            ImageUiState.Failed -> onError?.invoke()
            ImageUiState.Loading -> Unit
        }
    }

    // radius：token 档位 / 数值 dp（解析逻辑抽为 internal 纯函数，单测覆盖 D4）
    val radiusDp: Dp = remember(radius) { parseRadius(radius) }

    // 语义描述（D8）：loaded=alt；loading/failed=alt 兜底可读文案
    val semanticText = when (state) {
        ImageUiState.Loaded -> alt
        ImageUiState.Loading -> alt ?: "图片加载中"
        ImageUiState.Failed -> alt ?: "图片加载失败"
    }

    val tapModifier = if (onTap != null) {
        Modifier.clickable(
            interactionSource = remember { MutableInteractionSource() },
            indication = null,
        ) { onTap() }
    } else {
        Modifier
    }

    Box(
        modifier = modifier
            .then(width?.let { Modifier.width(it) } ?: Modifier.fillMaxWidth())
            .then(height?.let { Modifier.height(it) } ?: Modifier.fillMaxHeight())
            .then(tapModifier)
            .clip(RoundedCornerShape(radiusDp))
            .background(AppColor.bgCard)
            .semantics(mergeDescendants = true) { semanticText?.let { contentDescription = it } }
            .testTag("image-root"),
        contentAlignment = Alignment.Center,
    ) {
        when (state) {
            ImageUiState.Loaded -> {
                val bitmap = (resolved as ImageResolved.Success).bitmap
                Canvas(Modifier.matchParentSize().testTag("image-canvas")) {
                    val r = ImageGeometry.rect(
                        containerW = size.width,
                        containerH = size.height,
                        imageW = bitmap.width.toFloat(),
                        imageH = bitmap.height.toFloat(),
                        fit = fit,
                        position = position,
                    )
                    drawImage(
                        image = bitmap,
                        dstOffset = IntOffset(r.left.roundToInt(), r.top.roundToInt()),
                        dstSize = IntSize(r.width().roundToInt(), r.height().roundToInt()),
                    )
                }
            }
            ImageUiState.Loading -> {
                if (loadingContent != null) {
                    loadingContent()
                } else {
                    DefaultLoadingPlaceholder()
                }
            }
            ImageUiState.Failed -> {
                if (errorContent != null) {
                    errorContent()
                } else {
                    DefaultErrorPlaceholder()
                }
            }
        }
    }
}

/** 加载中占位：bgCard 底 + 双色转圈指示器（primary + gray15 轨道）。对齐规格页 token 表。 */
@Composable
private fun DefaultLoadingPlaceholder() {
    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(AppColor.bgCard)
            .testTag("image-loading"),
        contentAlignment = Alignment.Center,
    ) {
        CircularProgressIndicator(
            modifier = Modifier.size(14.dp),
            color = AppColor.primary,
            trackColor = AppColor.gray15,
            strokeWidth = 2.dp,
        )
    }
}

/** 失败占位：bgCard 底 + 破图图形（Canvas 画框/太阳/山形，gray.25）+「加载失败」（textSecondary/sizeSm）。 */
@Composable
private fun DefaultErrorPlaceholder() {
    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(AppColor.bgCard)
            .testTag("image-error"),
        contentAlignment = Alignment.Center,
    ) {
        Column(horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.spacedBy(AppSpace.sm)) {
            // 破图图形：外框 + 左上太阳 + 右下山形折线（对齐 iOS SF Symbol "photo" 语义；deps=[] 不引图标资源）
            Canvas(Modifier.size(40.dp, 32.dp)) {
                val w = size.width
                val h = size.height
                val line = 2.dp.toPx()
                drawRect(
                    color = AppColor.gray25,
                    topLeft = Offset(line, line),
                    size = Size(w - line * 2, h - line * 2),
                    style = Stroke(width = line),
                )
                drawCircle(
                    color = AppColor.gray25,
                    radius = 2.5.dp.toPx(),
                    center = Offset(w * 0.34f, h * 0.38f),
                    style = Stroke(width = line),
                )
                val peak = Offset(w * 0.58f, h * 0.42f)
                drawLine(AppColor.gray25, Offset(w * 0.36f, h * 0.72f), peak, strokeWidth = line)
                drawLine(AppColor.gray25, peak, Offset(w * 0.8f, h * 0.72f), strokeWidth = line)
            }
            Text("加载失败", color = AppColor.textSecondary, fontSize = AppFont.sizeSm)
        }
    }
}
