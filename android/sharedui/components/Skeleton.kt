// Skeleton 骨架屏（Android Compose 版，对齐 iOS SkeletonView.swift / api.json `ui.skeleton`）。
//
// 组件 ID：`ui.skeleton` ｜ 任务清单 #57 ｜ 操作反馈区第十二件 ｜ TMO 组件库 v1.4.14
//
// 定位：首屏/加载过渡期占位骨架——灰块模拟内容布局，shimmer 扫光动画提示加载中。
//
// 双模式：
// - SkeletonBlock（原子块）：width/height/radius 可配，自由组合
// - SkeletonRow（包裹器）：loading 受控切换骨架/真实内容，预设 avatar+title+subtitle 行布局
//
// 契约 @param（与 api.json 100% 对齐）：
// - SkeletonBlock: width(默认100%)/height(默认12dp)/radius(默认radiusSm)
// - SkeletonRow: loading(必选)/avatar(默认true)/titleWidth(默认0.7f)/subtitle(默认true)/subtitleWidth(默认0.4f)/content slot
//
// 设计规格（design-spec/skeleton-design-spec.html）：
// - 骨架底色 gray100(#F3F4F6)，高亮 gray200(#E5E7EB)
// - shimmer 1.5s linear infinite，从左到右渐变扫光（Brush.linearGradient）
// - 行圆角 radiusSm(6dp)，头像 40×40 radiusFull
//
// 用法：
// ```kotlin
// // 原子块
// SkeletonBlock(width = 1f, height = 120.dp)
//
// // 包裹器
// SkeletonRow(loading = loading) {
//     RealContent()
// }
// ```

package com.zhiqihuayun.sharedui.components

import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.drawWithContent
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppRadius

// 骨架色 token
private val SkeletonBase = Color(0xFFF3F4F6)   // gray100
private val SkeletonActive = Color(0xFFE5E7EB) // gray200

/** 百分比宽度辅助（width=1f=fillMaxWidth，0.7f=70%） */
private fun Modifier.widthFraction(width: Float): Modifier =
    if (width >= 1f) this.fillMaxWidth() else this.then(Modifier.fillMaxWidth(width))

/**
 * shimmer 扫光修饰符——从左到右渐变扫光动画。
 */
@Composable
private fun Modifier.shimmer(): Modifier {
    val transition = rememberInfiniteTransition(label = "skeleton_shimmer")
    val progress by transition.animateFloat(
        initialValue = 0f,
        targetValue = 1f,
        animationSpec = infiniteRepeatable(
            animation = tween(durationMillis = 1500, easing = LinearEasing),
            repeatMode = RepeatMode.Restart
        ),
        label = "shimmer_progress"
    )
    return this.drawWithContent {
        drawContent()
        val width = size.width
        val shimmerWidth = width * 0.4f
        val start = progress * (width + shimmerWidth) - shimmerWidth
        drawRect(
            brush = Brush.linearGradient(
                colors = listOf(SkeletonBase, SkeletonActive, SkeletonBase),
                start = Offset(start, 0f),
                end = Offset(start + shimmerWidth, size.height)
            )
        )
    }
}

/**
 * 骨架原子块——灰块 + shimmer 扫光。
 *
 * @param width 宽度比例（0.0–1.0，相对于父容器），默认 1f (100%)
 * @param height 高度，默认 12.dp
 * @param radius 圆角，默认 AppRadius.sm (6.dp)，圆形用 CircleShape
 * @param modifier 布局修饰符
 */
@Composable
fun SkeletonBlock(
    width: Float = 1f,
    height: Dp = 12.dp,
    radius: Dp = AppRadius.sm,
    modifier: Modifier = Modifier
) {
    Box(
        modifier = modifier
            .widthFraction(width)
            .height(height)
            .clip(RoundedCornerShape(radius))
            .background(SkeletonBase)
            .shimmer()
    )
}

/**
 * 骨架行包裹器——loading=true 显示骨架行（avatar+title+subtitle），loading=false 显示 content。
 *
 * @param loading true=显示骨架，false=显示 content
 * @param avatar 是否显示头像骨架，默认 true
 * @param titleWidth 标题骨架宽度比例，默认 0.7f (70%)
 * @param subtitle 是否显示副标题骨架，默认 true
 * @param subtitleWidth 副标题骨架宽度比例，默认 0.4f (40%)
 * @param modifier 布局修饰符
 * @param content loading=false 时显示的真实内容
 */
@Composable
fun SkeletonRow(
    loading: Boolean,
    avatar: Boolean = true,
    titleWidth: Float = 0.7f,
    subtitle: Boolean = true,
    subtitleWidth: Float = 0.4f,
    modifier: Modifier = Modifier,
    content: @Composable () -> Unit
) {
    if (loading) {
        Row(
            modifier = modifier.padding(vertical = 12.dp, horizontal = 16.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            if (avatar) {
                Box(
                    modifier = Modifier
                        .size(40.dp)
                        .clip(CircleShape)
                        .background(SkeletonBase)
                        .shimmer()
                )
            }
            Column(
                modifier = Modifier.weight(1f),
                verticalArrangement = Arrangement.spacedBy(6.dp)
            ) {
                SkeletonBlock(width = titleWidth, height = 12.dp)
                if (subtitle) {
                    SkeletonBlock(width = subtitleWidth, height = 12.dp)
                }
            }
        }
    } else {
        Box(modifier = modifier) {
            content()
        }
    }
}
