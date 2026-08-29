package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.Text
import androidx.compose.material3.rememberModalBottomSheetState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppFont
import com.zhiqihuayun.foundation.design.AppRadius
import com.zhiqihuayun.foundation.design.AppSpace

/**
 * 头像选项的通用数据模型：名称 + 符号 + 主题色。
 * 业务侧负责把自有数据（如星座）映射为该模型后传入组件。
 */
data class AvatarOption(
    val name: String,
    val symbol: String,
    val tintHex: Long
)

@Composable
fun ZodiacAvatar(
    option: AvatarOption?,
    nickname: String,
    modifier: Modifier = Modifier,
    size: Dp = 56.dp
) {
    Box(
        modifier = modifier
            .size(size)
            .clip(CircleShape)
            .background(
                if (option != null) Color(option.tintHex).copy(alpha = 0.18f)
                else AppColor.primaryMuted
            ),
        contentAlignment = Alignment.Center
    ) {
        Text(
            text = option?.symbol ?: nickname.take(1),
            color = if (option != null) Color(option.tintHex) else AppColor.primary,
            fontSize = if (option != null) AppFont.sizeXl else AppFont.sizeLg,
            fontWeight = FontWeight.SemiBold,
            textAlign = TextAlign.Center
        )
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AvatarPickerSheet(
    options: List<AvatarOption>,
    onDismiss: () -> Unit,
    onSelect: (AvatarOption) -> Unit
) {
    val signs = remember { options.shuffled() }
    val sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true)
    ModalBottomSheet(
        onDismissRequest = onDismiss,
        sheetState = sheetState,
        containerColor = AppColor.bgCard,
        dragHandle = null,
        shape = RoundedCornerShape(topStart = AppRadius.lg, topEnd = AppRadius.lg)
    ) {
        Column(modifier = Modifier.fillMaxWidth()) {
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(44.dp)
                    .background(AppColor.bgCard)
            ) {
                Text(
                    "取消",
                    color = AppColor.primary,
                    fontSize = AppFont.sizeMd,
                    modifier = Modifier
                        .align(Alignment.CenterStart)
                        .clickable(onClick = onDismiss)
                        .padding(horizontal = AppSpace.lg, vertical = AppSpace.sm)
                )
                Text(
                    "选择头像",
                    color = AppColor.textPrimary,
                    fontSize = AppFont.sizeLg,
                    fontWeight = FontWeight.SemiBold,
                    modifier = Modifier.align(Alignment.Center)
                )
            }
            HorizontalDivider(color = AppColor.border, thickness = 0.5.dp)
            LazyVerticalGrid(
                columns = GridCells.Fixed(4),
                modifier = Modifier
                    .fillMaxWidth()
                    .height(360.dp)
                    .padding(horizontal = AppSpace.lg, vertical = AppSpace.md)
            ) {
                items(signs) { sign ->
                    Column(
                        horizontalAlignment = Alignment.CenterHorizontally,
                        modifier = Modifier
                            .padding(vertical = AppSpace.sm)
                            .clickable { onSelect(sign) }
                    ) {
                        ZodiacAvatar(option = sign, nickname = sign.name, size = 56.dp)
                        Text(
                            sign.name,
                            color = AppColor.textSecondary,
                            fontSize = AppFont.sizeXs,
                            modifier = Modifier.padding(top = 4.dp)
                        )
                    }
                }
            }
        }
    }
}
