// ImagePreview 图片预览组件（Compose 版，对齐 iOS ImagePreviewView）。
//
// 全屏图片预览：支持多图横滑切换、页码指示器、点击关闭。
// 一期实现：基础全屏展示 + 横滑翻页 + 指示器。缩放/拖拽关闭二期。

package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.gestures.detectHorizontalDragGestures
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.pager.HorizontalPager
import androidx.compose.foundation.pager.rememberPagerState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppFont
import com.zhiqihuayun.foundation.design.AppSpace

/**
 * 图片数据源。
 *
 * @param url 图片 URL（一期仅支持网络图片占位，实际渲染为色块+序号）
 */
data class ImageSource(
    val url: String,
)

/**
 * 图片预览组件。
 *
 * @param images 图片列表
 * @param initialIndex 初始展示索引
 * @param visible 是否显示（受控）
 * @param onDismiss 关闭回调
 * @param onPageChange 翻页回调
 * @param showIndicator 是否显示页码指示器
 */
@Composable
fun ImagePreview(
    images: List<ImageSource>,
    initialIndex: Int = 0,
    visible: Boolean,
    onDismiss: () -> Unit,
    onPageChange: ((Int) -> Unit)? = null,
    showIndicator: Boolean = true,
) {
    if (!visible || images.isEmpty()) return

    val pagerState = rememberPagerState(
        initialPage = initialIndex.coerceIn(0, images.size - 1),
        pageCount = { images.size },
    )

    LaunchedEffect(pagerState.currentPage) {
        onPageChange?.invoke(pagerState.currentPage)
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(Color.Black)
            .clickable { onDismiss() },
    ) {
        // 图片横滑
        HorizontalPager(
            state = pagerState,
            modifier = Modifier.fillMaxSize(),
        ) { page ->
            // 一期占位：色块 + 序号（二期替换为真实图片加载）
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .background(Color(0xFF1F2937)),
                contentAlignment = Alignment.Center,
            ) {
                Text(
                    text = "${page + 1}",
                    color = Color.White,
                    fontSize = AppFont.sizeDisplay,
                    fontWeight = FontWeight.Bold,
                )
            }
        }

        // 页码指示器
        if (showIndicator && images.size > 1) {
            Row(
                modifier = Modifier
                    .align(Alignment.BottomCenter)
                    .padding(bottom = AppSpace.xl),
                horizontalArrangement = Arrangement.spacedBy(AppSpace.xs),
            ) {
                repeat(images.size) { index ->
                    Box(
                        modifier = Modifier
                            .size(if (index == pagerState.currentPage) 8.dp else 6.dp)
                            .clip(CircleShape)
                            .background(
                                if (index == pagerState.currentPage) Color.White
                                else Color.White.copy(alpha = 0.4f)
                            ),
                    )
                }
            }

            // 页码文本
            Text(
                text = "${pagerState.currentPage + 1} / ${images.size}",
                color = Color.White.copy(alpha = 0.8f),
                fontSize = AppFont.sizeSm,
                modifier = Modifier
                    .align(Alignment.TopCenter)
                    .padding(top = AppSpace.xl),
            )
        }
    }
}
