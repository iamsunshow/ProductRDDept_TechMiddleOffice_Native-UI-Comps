//
//  Carousel.kt
//  SharedUI
//
//  组件 ID：`ui.carousel` ｜ 任务清单 #59 ｜ 信息展示区第一件 ｜ TMO 组件库 v1.4.20
//
//  定位：图片/内容横向分页轮播容器——支持自动播放、循环、指示器与手动滑动，
//       用于 Banner 广告位、活动推荐、商品图集等横向翻页展示。
//
//  结构：
//  - 单容器 Carousel（items 数组驱动 + autoPlay/loop/showIndicators/indicatorColor 开关 + onChange 回调）
//
//  契约 @param（与 api.json 100% 对齐）：
//  - items: 轮播内容数组（每项为 @Composable）
//  - autoPlay(默认true)/duration(默认3000L)/loop(默认true)/showIndicators(默认true)
//  - indicatorColor(默认AppColor.primary)/onChange(默认null，索引变化回调)
//
//  设计规格（design-spec/carousel-design-spec.html）：
//  - 默认高度 200dp（可通过 modifier 覆盖）
//  - 容器圆角 radiusMd(10dp)，溢出裁剪
//  - 指示器 8×8 圆形，间距 spaceSm(8dp)，底部居中，距底 8dp
//  - 当前页=indicatorColor，其他=indicatorColor.copy(alpha=0.3f)
//  - 自动播放间隔 duration 默认 3000ms
//  - 滑动 300ms ease-in-out（HorizontalPager 默认 animationSpec）
//
//  实现（与 iOS CarouselView 1:1）：
//  - HorizontalPager（androidx.compose.foundation.pager）+ rememberPagerState 分页
//  - LaunchedEffect + delay 实现 autoPlay（animateScrollToPage 翻页）
//  - loop=true：Int.MAX_VALUE 假循环+取模计算当前真实页（避免末页反向"倒带"，末张→首张无缝衔接）
//  - loop=false：pageCount=items.size，末张后停止 autoPlay
//  - 指示器：BoxWithConstraints 内 Box 叠加底部 Row（8×8 圆点+颜色切换）
//
//  用法：
//  ```kotlin
//  Carousel(
//      items = listOf(
//          { BannerImage(url1) },
//          { BannerImage(url2) },
//          { BannerImage(url3) }
//      ),
//      onChange = { index -> Log.d("Carousel", "current=$index") }
//  )
//  ```

package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.pager.HorizontalPager
import androidx.compose.foundation.pager.rememberPagerState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.rememberUpdatedState
import androidx.compose.runtime.snapshotFlow
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppRadius
import com.zhiqihuayun.foundation.design.AppSpace
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.drop

// MARK: - 轮播默认高度
private val CarouselDefaultHeight = 200.dp

// MARK: - 指示器规格
private object IndicatorTokens {
    val size = AppSpace.sm            // 圆点 8×8（=spaceSm=8dp）
    val spacing = AppSpace.sm         // 圆点间距 8dp
    val bottomPadding = AppSpace.sm   // 距底 8dp
}

/**
 * 图片/内容横向分页轮播容器。
 *
 * - 自动播放：autoPlay=true 时每 [duration] ms 自动切换下一张（LaunchedEffect + delay）
 * - 循环：loop=true 用 Int.MAX_VALUE 假循环+取模计算当前真实页（末张→首张无缝衔接）
 * - 指示器：showIndicators=true 时底部居中 8×8 圆点
 *   （当前页 [indicatorColor]，其他 [indicatorColor].copy(alpha=0.3f)）
 * - onChange：索引变化回调（自动播放/手动滑动均触发，跳过初始值）
 *
 * @param items 轮播内容数组（每项为 @Composable）
 * @param autoPlay 是否自动播放，默认 true
 * @param duration 自动播放间隔毫秒，默认 3000L
 * @param loop 是否循环轮播，默认 true
 * @param showIndicators 是否显示指示器，默认 true
 * @param indicatorColor 指示器颜色，默认 [AppColor.primary]
 * @param onChange 索引变化回调（参数为当前真实索引 0..items.size-1）
 * @param modifier 布局修饰符（默认 fillMaxWidth + 200dp 高度）
 */
@Composable
fun Carousel(
    items: List<@Composable () -> Unit>,
    autoPlay: Boolean = true,
    duration: Long = 3000L,
    loop: Boolean = true,
    showIndicators: Boolean = true,
    indicatorColor: Color = AppColor.primary,
    onChange: ((Int) -> Unit)? = null,
    modifier: Modifier = Modifier,
) {
    val count = items.size
    // 空内容直接返回，避免 pagerState.pageCount=0 触发非法状态
    if (count == 0) return

    // 循环：loop=true 且项数 > 1 用 Int.MAX_VALUE 假循环；初始页居中避免开局反向"倒带"
    val pageCount = if (loop && count > 1) Int.MAX_VALUE else count
    val initialPage = if (loop && count > 1) {
        Int.MAX_VALUE / 2 - (Int.MAX_VALUE / 2) % count
    } else {
        0
    }

    val pagerState = rememberPagerState(
        pageCount = { pageCount },
        initialPage = initialPage
    )

    // 当前真实索引（取模计算，loop=false 时直接为 currentPage）
    val currentIndex = if (loop && count > 1) pagerState.currentPage % count else pagerState.currentPage

    // 用 rememberUpdatedState 持有最新 onChange，避免回调变化导致 LaunchedEffect 重启丢事件
    val currentOnChange by rememberUpdatedState(onChange)

    // 索引变化回调（drop(1) 跳过初始 emit，distinctUntilChanged 去重）
    LaunchedEffect(pagerState, count, loop) {
        snapshotFlow { pagerState.currentPage }
            .distinctUntilChanged()
            .drop(1)
            .collect { page ->
                val real = if (loop && count > 1) page % count else page
                currentOnChange?.invoke(real)
            }
    }

    // 自动播放（LaunchedEffect + delay + animateScrollToPage）
    if (autoPlay && count > 1) {
        LaunchedEffect(pagerState, loop, duration) {
            while (true) {
                delay(duration)
                val next = if (loop) {
                    pagerState.currentPage + 1
                } else {
                    // loop=false：末张后停止 autoPlay
                    val cur = pagerState.currentPage
                    if (cur >= count - 1) return@LaunchedEffect else cur + 1
                }
                pagerState.animateScrollToPage(next)
            }
        }
    }

    // 容器（BoxWithConstraints 同 Swipe.kt 模式，便于子项按 constraints 布局）
    BoxWithConstraints(
        modifier = modifier
            .fillMaxWidth()
            .height(CarouselDefaultHeight)
            .clip(RoundedCornerShape(AppRadius.md))
            .background(AppColor.bgCard)
    ) {
        // 横向分页容器（等宽分页+吸附，HorizontalPager 默认 animationSpec 即 300ms ease-in-out）
        HorizontalPager(
            state = pagerState,
            modifier = Modifier.fillMaxSize()
        ) { page ->
            val realIndex = if (loop && count > 1) page % count else page
            items[realIndex].invoke()
        }

        // 底部指示器（8×8 圆点，间距 8dp，底部居中）
        if (showIndicators && count > 1) {
            Row(
                modifier = Modifier
                    .align(Alignment.BottomCenter)
                    .padding(bottom = IndicatorTokens.bottomPadding),
                horizontalArrangement = Arrangement.spacedBy(IndicatorTokens.spacing)
            ) {
                repeat(count) { i ->
                    val active = i == currentIndex
                    Box(
                        modifier = Modifier
                            .size(IndicatorTokens.size)
                            .clip(CircleShape)
                            .background(
                                if (active) indicatorColor else indicatorColor.copy(alpha = 0.3f)
                            )
                    )
                }
            }
        }
    }
}
