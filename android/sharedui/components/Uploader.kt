package com.zhiqihuayun.sharedui.components

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.ImageBitmap
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppFont
import com.zhiqihuayun.foundation.design.AppRadius
import com.zhiqihuayun.foundation.design.AppSpace
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.net.URL

/**
 * 上传状态机。
 */
enum class UploadStatus {
    PENDING,    // 等待上传（无蒙层）
    UPLOADING,  // 上传中（primary 蒙层+进度条）
    SUCCESS,    // 成功（无蒙层+删除角标）
    FAILED      // 失败（error 蒙层+点击重试）
}

/**
 * 上传文件项（宿主真源，组件纯渲染）。
 */
data class UploadItem(
    val id: String,
    val name: String,
    val size: Long? = null,
    val thumbnailUrl: String? = null,
    val localPath: String? = null,
    val status: UploadStatus = UploadStatus.PENDING,
    val progress: Float = 0f
)

// 常量：4 列网格 spacing 8；cell radius sm；删除角标 16；进度条高 3
private val GridSpacing = AppSpace.sm
private val CellRadius = AppRadius.sm
private val DeleteSize = 16.dp
private val ProgressHeight = 3.dp

/**
 * Uploader 上传（数据录入组件 #43，ui.uploader）：通用文件/图片上传 UI 组件。
 *
 * 视觉：4 列网格 spacing 8；cell 正方形 radiusSm bgPage；添加格=dashed border + 号居中；
 * 删除角标 16dp 圆半透明黑底白×右上角；uploading=primary 80% 蒙层+白字"上传中"+底部进度条；
 * failed=error 80% 蒙层+白字"失败"。
 *
 * 语义：value List<UploadItem> 受控必传（宿主真源）；onAdd/onRemove/onRetry 三回调；
 * maxCount 默认 9（达上限隐藏添加格）；disabled 整件 alpha0.4 不可点。
 * 组件不内置选择器和上传逻辑=宿主职责。
 */
@Composable
fun Uploader(
    value: List<UploadItem>,
    onAdd: () -> Unit,
    onRemove: (Int) -> Unit,
    onRetry: (Int) -> Unit = {},
    maxCount: Int = 9,
    disabled: Boolean = false,
    modifier: Modifier = Modifier
) {
    val showAdd = value.size < maxCount
    // 构建完整列表（文件项 + 添加按钮占位）
    val allItems: List<Any?> = value.map { it as Any? } + if (showAdd) listOf(null) else emptyList()
    val columns = 4

    Column(
        modifier = modifier
            .fillMaxWidth()
            .alpha(if (disabled) 0.4f else 1f),
        verticalArrangement = Arrangement.spacedBy(GridSpacing)
    ) {
        allItems.chunked(columns).forEach { row ->
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(GridSpacing)
            ) {
                row.forEach { item ->
                    Box(modifier = Modifier.weight(1f)) {
                        when (item) {
                            is UploadItem -> {
                                val index = value.indexOf(item)
                                UploaderCell(
                                    item = item,
                                    disabled = disabled,
                                    onDelete = { onRemove(index) },
                                    onRetry = { onRetry(index) }
                                )
                            }
                            null -> UploaderAddCell(
                                disabled = disabled,
                                onClick = onAdd
                            )
                        }
                    }
                    // 不足 4 列时用空 Box 占位保持列宽一致
                    if (row.size < columns) {
                        repeat(columns - row.size) {
                            Spacer(modifier = Modifier.weight(1f))
                        }
                    }
                }
            }
        }
    }
}

/**
 * 文件 Cell：缩略图 + 删除角标 + 状态蒙层 + 进度条。
 */
@Composable
private fun UploaderCell(
    item: UploadItem,
    disabled: Boolean,
    onDelete: () -> Unit,
    onRetry: () -> Unit
) {
    val context = LocalContext.current
    var bitmap by remember(item.id, item.localPath, item.thumbnailUrl) {
        mutableStateOf<ImageBitmap?>(null)
    }

    // 加载缩略图：localPath 优先（本地文件），其次 thumbnailUrl（网络）
    LaunchedEffect(item.localPath, item.thumbnailUrl) {
        val bmp: Bitmap? = when {
            item.localPath != null -> withContext(Dispatchers.IO) {
                BitmapFactory.decodeFile(item.localPath)
            }
            item.thumbnailUrl != null -> withContext(Dispatchers.IO) {
                try {
                    val url = URL(item.thumbnailUrl)
                    BitmapFactory.decodeStream(url.openStream())
                } catch (_: Throwable) { null }
            }
            else -> null
        }
        bitmap = bmp?.asImageBitmap()
    }

    Box(
        modifier = Modifier
            .aspectRatio(1f)
            .background(AppColor.bgPage, RoundedCornerShape(CellRadius))
            .border(1.dp, AppColor.border, RoundedCornerShape(CellRadius))
            .clickable(enabled = !disabled && item.status == UploadStatus.FAILED) {
                onRetry()
            }
    ) {
        // 缩略图
        bitmap?.let {
            androidx.compose.foundation.Image(
                bitmap = it,
                contentDescription = item.name,
                contentScale = ContentScale.Crop,
                modifier = Modifier.fillMaxSize()
            )
        }

        // 删除角标（仅 success/pending 显示）
        if (item.status == UploadStatus.SUCCESS || item.status == UploadStatus.PENDING) {
            Box(
                modifier = Modifier
                    .align(Alignment.TopEnd)
                    .padding(2.dp)
                    .size(DeleteSize)
                    .background(Color.Black.copy(alpha = 0.5f), RoundedCornerShape(50))
                    .clickable(enabled = !disabled) { onDelete() },
                contentAlignment = Alignment.Center
            ) {
                androidx.compose.foundation.Canvas(modifier = Modifier.size(DeleteSize * 0.6f)) {
                    val s = size.width
                    val stroke = 2.dp.toPx()
                    drawLine(Color.White, Offset(s * 0.25f, s * 0.25f), Offset(s * 0.75f, s * 0.75f), strokeWidth = stroke, cap = StrokeCap.Round)
                    drawLine(Color.White, Offset(s * 0.75f, s * 0.25f), Offset(s * 0.25f, s * 0.75f), strokeWidth = stroke, cap = StrokeCap.Round)
                }
            }
        }

        // 状态蒙层
        when (item.status) {
            UploadStatus.UPLOADING -> {
                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .background(AppColor.primary.copy(alpha = 0.8f), RoundedCornerShape(CellRadius)),
                    contentAlignment = Alignment.Center
                ) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Text("上传中", color = Color.White, fontSize = 10.sp)
                        // 进度条
                        Box(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(horizontal = 4.dp)
                                .padding(top = 2.dp)
                                .size(height = ProgressHeight, width = 0.dp)
                                .background(Color.White.copy(alpha = 0.3f))
                        ) {
                            Box(
                                modifier = Modifier
                                    .fillMaxWidth(item.progress)
                                    .fillMaxSize()
                                    .background(AppColor.primary)
                            )
                        }
                    }
                }
            }
            UploadStatus.FAILED -> {
                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .background(AppColor.error.copy(alpha = 0.8f), RoundedCornerShape(CellRadius)),
                    contentAlignment = Alignment.Center
                ) {
                    Text("失败", color = Color.White, fontSize = 10.sp)
                }
            }
            else -> Unit
        }
    }
}

/**
 * 添加 Cell：dashed border + + 号。
 */
@Composable
private fun UploaderAddCell(
    disabled: Boolean,
    onClick: () -> Unit
) {
    Box(
        modifier = Modifier
            .aspectRatio(1f)
            .background(AppColor.bgPage, RoundedCornerShape(CellRadius))
            .border(
                width = 1.dp,
                color = AppColor.textSecondary.copy(alpha = 0.3f),
                shape = RoundedCornerShape(CellRadius)
            )
            .clickable(enabled = !disabled) { onClick() },
        contentAlignment = Alignment.Center
    ) {
        Text(
            "+",
            color = AppColor.textSecondary,
            fontSize = AppFont.sizeXl,
            textAlign = TextAlign.Center
        )
    }
}
