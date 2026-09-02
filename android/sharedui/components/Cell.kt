package com.zhiqihuayun.sharedui.components

import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.interaction.collectIsPressedAsState
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.KeyboardArrowRight
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.ColorFilter
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.graphics.painter.Painter
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.graphics.vector.rememberVectorPainter
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppFont
import com.zhiqihuayun.foundation.design.AppRadius
import com.zhiqihuayun.foundation.design.AppSpace
import com.zhiqihuayun.foundation.design.AppText

/**
 * Cell 状态标识。
 */
enum class CellStatus {
    /** 默认：右侧按 [arrow] 显示箭头。 */
    Normal,

    /** 成功：右侧 ✓（success 色）。 */
    Success,

    /** 失败：右侧 !（error 色）。 */
    Error,
}

/**
 * 通用列表行容器：左侧可选图标 + 中间标题（可副标题）+ 右侧值/箭头/状态标识。
 *
 * 对标 NutUI Cell / Ant Design List.Item，支持五态（默认/禁用/加载/成功/失败）。
 * 参数名与 `docs/api.json` 中 `ui.cell` 契约一致（A7 命名对齐）。
 * 长按交互 iOS 触发、Android 不承诺（平台差异已登记）；事件参数（数据+索引）由调用方闭包绑定。
 *
 * @param title 主标题（必填）
 * @param subtitle 副标题；为空自动隐藏（单行）
 * @param icon 左侧图标（Painter，业务侧把资源名解析为 Painter 传入）
 * @param value 右侧值文本
 * @param arrow 是否显示右侧箭头，默认 true
 * @param disabled 禁用态：背景置灰、文字置灰、不透箭头、不可点
 * @param loading 加载态：标题区骨架占位
 * @param status 状态标识，默认 Normal
 * @param showsDivider 是否显示底部 1px 分隔线（最后一行由业务置 false）
 * @param onClick 点击回调
 */
@Composable
fun Cell(
    title: String,
    modifier: Modifier = Modifier,
    subtitle: String? = null,
    icon: Painter? = null,
    value: String? = null,
    arrow: Boolean = true,
    disabled: Boolean = false,
    loading: Boolean = false,
    status: CellStatus = CellStatus.Normal,
    showsDivider: Boolean = true,
    onClick: (() -> Unit)? = null,
) {
    val interactionSource = remember { MutableInteractionSource() }
    val isPressed by interactionSource.collectIsPressedAsState()

    // 按下态背景 gray.4，松手恢复；禁用态整行 gray.4（D2/D7）。
    val backgroundColor = when {
        disabled -> AppColor.gray4
        isPressed -> AppColor.gray4
        else -> AppColor.bgCard
    }

    Column(modifier = modifier) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                // 最小行高：设计稿「32 号字 cell」单行 = 56dp（16dp 内边距×2 + 24dp 主标题行高）。
                .heightIn(min = 56.dp)
                .background(backgroundColor)
                .testTag("cell-root")
                .clickable(
                    interactionSource = interactionSource,
                    indication = null,
                    enabled = !disabled && onClick != null,
                    onClick = { onClick?.invoke() },
                )
                // 上下内边距 16dp（设计稿 cellVertical），对齐 iOS 与设计稿高度。
                .padding(horizontal = AppSpace.lg, vertical = AppSpace.cellVertical),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            if (icon != null) {
                Image(
                    painter = icon,
                    contentDescription = null,
                    modifier = Modifier
                        .size(AppSpace.xl)
                        .clip(RoundedCornerShape(AppRadius.sm)),
                    colorFilter = if (disabled) {
                        ColorFilter.tint(AppColor.gray25)
                    } else {
                        null
                    },
                )
                Spacer(modifier = Modifier.width(AppSpace.md))
            }

            // 中间标题区（加载态骨架占位）。
            if (loading) {
                // v1.30 修复：外层 Box(Modifier.weight(1f)) 撑满 Row 剩余宽度，
                // 否则 SkeletonTitle 按 40% fillMaxWidth 显示（intrinsic 宽固定），
                // Row 尾部 arrow 被挤到骨架右侧而非整行最右（第 6 行 loading 态箭头不对齐）。
                // 与正常态 Column(Modifier.weight(1f)) 对称。
                Box(modifier = Modifier.weight(1f)) {
                    SkeletonTitle()
                }
            } else {
                Column(modifier = Modifier.weight(1f)) {
                    Text(
                        text = title,
                        fontSize = AppFont.sizeMd,
                        color = if (disabled) AppColor.gray25 else AppColor.textPrimary,
                        fontWeight = FontWeight.Normal,
                        // 显式行高对齐设计稿（主 24dp），避免系统字体度量双端漂移。
                        lineHeight = AppText.cellTitleLineHeight,
                    )
                    if (!subtitle.isNullOrEmpty()) {
                        // 主标题-副标题间距：设计稿「32 号字 cell」4px@2x = 2dp。
                        Spacer(modifier = Modifier.height(2.dp))
                        Text(
                            text = subtitle,
                            fontSize = AppFont.sizeSm,
                            color = if (disabled) AppColor.gray25 else AppColor.textSecondary,
                            fontWeight = FontWeight.Normal,
                            // 显式行高对齐设计稿（副 18dp）。
                            lineHeight = AppText.cellSubtitleLineHeight,
                        )
                    }
                }
                Spacer(modifier = Modifier.width(AppSpace.sm))
            }

            // 右侧值。
            if (!value.isNullOrEmpty() && !loading) {
                Text(
                    text = value,
                    fontSize = AppFont.sizeSm,
                    color = if (disabled) AppColor.gray25 else AppColor.textSecondary,
                    fontWeight = FontWeight.Normal,
                )
            }

            // 状态标识：success/error 替换箭头位。
            if (status != CellStatus.Normal && !disabled) {
                Spacer(modifier = Modifier.width(AppSpace.sm))
                val badgeIcon: ImageVector? = when (status) {
                    // v1.30c：Error 不用 ImageVector（Material 无"圆+!"，自绘 ImageVector API 复杂易编译错），
                    // 改为直接 ErrorCircleBadge() Composable。Success 保留 CheckCircle（圆✓）。
                    CellStatus.Success -> Icons.Filled.CheckCircle
                    CellStatus.Error -> null
                    CellStatus.Normal -> null
                }
                if (status == CellStatus.Error) {
                    // 直接自绘 Composable，对齐 iOS SF Symbols `exclamationmark.circle.fill` = 圆!
                    ErrorCircleBadge(
                        modifier = Modifier
                            .size(AppSpace.xl)
                            .testTag("cell-status"),
                    )
                } else if (badgeIcon != null) {
                    Image(
                        imageVector = badgeIcon,
                        contentDescription = if (status == CellStatus.Success) "成功" else "失败",
                        modifier = Modifier
                            .size(AppSpace.xl)
                            .testTag("cell-status"),
                        colorFilter = ColorFilter.tint(AppColor.success),
                    )
                }
            }

            // 箭头：arrow 且无状态标识且非禁用时显示。
            if (arrow && status == CellStatus.Normal && !disabled) {
                Spacer(modifier = Modifier.width(AppSpace.sm))
                Image(
                    imageVector = Icons.AutoMirrored.Filled.KeyboardArrowRight,
                    contentDescription = null,
                    modifier = Modifier
                        .size(AppSpace.lg)
                        .testTag("cell-arrow"),
                    colorFilter = ColorFilter.tint(AppColor.gray25),
                )
            }
        }

        // 底部 1px 分隔线（D8）。
        if (showsDivider) {
            Spacer(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(1.dp)
                    .background(AppColor.border)
                    .testTag("cell-divider"),
            )
        }
    }
}

/** 加载态标题区骨架占位（透明度脉冲，与 iOS 0.8s 一致）。 */
@Composable
private fun SkeletonTitle() {
    val transition = rememberInfiniteTransition(label = "skeleton")
    val alpha by transition.animateFloat(
        initialValue = 1f,
        targetValue = 0.35f,
        animationSpec = infiniteRepeatable(tween(durationMillis = 800), RepeatMode.Reverse),
        label = "skeletonAlpha",
    )
    Box(
        modifier = Modifier
            .height(AppSpace.lg)
            .fillMaxWidth(0.4f)
            .background(AppColor.border, RoundedCornerShape(AppRadius.sm))
            .graphicsLayer { this.alpha = alpha }
            .testTag("cell-skeleton"),
    )
}

/**
 * 自定义 Error 标识 Composable：红色填充圆 + 白色感叹号（对齐 iOS SF Symbols
 * `exclamationmark.circle.fill` 视觉），与 Success `CheckCircle`（圆✓）配对统一。
 *
 * Material Icons 标准集没有"圆+!"向量，且 v1.30b 尝试用 `ImageVector.Builder +
 * PathBuilder + VectorConfig` 自绘时误用了 Compose 不存在的扩展 API，导致
 * Kotlin 编译失败（`:android:components:compileDebugKotlin`）。
 * 改用 Compose Canvas 直接绘制：① API 简单稳定（Compose 1.0+ 全版本兼容）；
 * ② 颜色直接取设计令牌 `AppColor.error`，随主题同步不漂移。
 *
 * 24×24dp 视窗比例：红圆占满画布 → 白竖条（2×8）x=11-13, y=6-14 →
 * 白圆点（2×2）x=11-13, y=17-19。
 */
@Composable
private fun ErrorCircleBadge(modifier: Modifier = Modifier) {
    Canvas(modifier = modifier) {
        // 以短边为基准做 24dp 视窗缩放，任意父级 size 传入时图形居中不变形。
        val canvasSize = size.minDimension
        val s = canvasSize / 24f

        // 1) 红填充圆（严格取设计令牌，随暗色模式/主题切换同步）。
        drawCircle(
            color = AppColor.error,
            radius = canvasSize / 2,
            center = center,
        )
        // 2) 白感叹号竖条：宽 2 × 高 8。
        drawRect(
            color = Color.White,
            topLeft = Offset(11f * s, 6f * s),
            size = Size(2f * s, 8f * s),
        )
        // 3) 白圆点：宽 2 × 高 2。
        drawRect(
            color = Color.White,
            topLeft = Offset(11f * s, 17f * s),
            size = Size(2f * s, 2f * s),
        )
    }
}
