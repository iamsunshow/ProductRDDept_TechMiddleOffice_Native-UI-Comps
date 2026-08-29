package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.outlined.KeyboardArrowRight
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppFont
import com.zhiqihuayun.foundation.design.AppRadius
import com.zhiqihuayun.foundation.design.AppSpace

data class ProfileListItem(
    val title: String,
    val value: String? = null,
    val onClick: (() -> Unit)? = null
)

@Composable
fun ProfileListGroup(
    items: List<ProfileListItem>,
    modifier: Modifier = Modifier
) {
    Column(
        modifier = modifier
            .fillMaxWidth()
            .background(AppColor.bgCard, RoundedCornerShape(AppRadius.lg))
    ) {
        items.forEachIndexed { index, item ->
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .then(
                        if (item.onClick != null) Modifier.clickable { item.onClick.invoke() }
                        else Modifier
                    )
                    .padding(horizontal = AppSpace.lg, vertical = 14.dp),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(item.title, color = AppColor.textPrimary, fontSize = AppFont.sizeMd)
                Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(AppSpace.sm)) {
                    if (item.value != null) {
                        Text(item.value, color = AppColor.textSecondary, fontSize = AppFont.sizeSm)
                    }
                    if (item.onClick != null) {
                        Icon(
                            Icons.AutoMirrored.Outlined.KeyboardArrowRight,
                            contentDescription = "打开${item.title}",
                            tint = AppColor.textSecondary,
                            modifier = Modifier.size(12.dp)
                        )
                    }
                }
            }
            if (index != items.lastIndex) {
                HorizontalDivider(
                    color = AppColor.border,
                    thickness = 0.5.dp,
                    modifier = Modifier.padding(start = AppSpace.lg)
                )
            }
        }
    }
}
