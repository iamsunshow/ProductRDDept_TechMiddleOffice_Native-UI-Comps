package com.zhiqihuayun.demo

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.rememberVectorPainter
import androidx.compose.ui.unit.dp
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppFont
import com.zhiqihuayun.foundation.design.AppSpace
import com.zhiqihuayun.sharedui.components.AppButton
import com.zhiqihuayun.sharedui.components.AppButtonStyle
import com.zhiqihuayun.sharedui.components.Cell
import com.zhiqihuayun.sharedui.components.CellStatus
import com.zhiqihuayun.sharedui.components.SegmentControl

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            MaterialTheme {
                TmoDemo()
            }
        }
    }
}

/** Native-UI-Comps Android Demo：展示组件库基础组件，供独立运行 / 自测 / 双端对齐验证。 */
@Composable
fun TmoDemo() {
    var selectedIndex by remember { mutableIntStateOf(0) }
    var clickCount by remember { mutableIntStateOf(0) }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(AppColor.bgPage)
            .verticalScroll(rememberScrollState())
            .padding(AppSpace.xl),
        verticalArrangement = Arrangement.spacedBy(AppSpace.lg)
    ) {
        Text(text = "Native-UI-Comps Demo", color = AppColor.textPrimary, fontSize = AppFont.sizeXl)

        Text(text = "SegmentControl", color = AppColor.textSecondary, fontSize = AppFont.sizeSm)
        SegmentControl(
            options = listOf("近一周", "近一月", "近一年"),
            selectedIndex = selectedIndex,
            onSelect = { selectedIndex = it }
        )

        Text(text = "AppButton (Primary)", color = AppColor.textSecondary, fontSize = AppFont.sizeSm)
        AppButton(
            text = "主操作 · 点击 $clickCount",
            onClick = { clickCount = clickCount + 1 }
        )

        Text(text = "AppButton (Secondary)", color = AppColor.textSecondary, fontSize = AppFont.sizeSm)
        AppButton(
            text = "次要操作",
            onClick = {},
            style = AppButtonStyle.Secondary
        )

        Text(text = "AppButton (Destructive / Disabled)", color = AppColor.textSecondary, fontSize = AppFont.sizeSm)
        AppButton(
            text = "破坏性操作",
            onClick = {},
            style = AppButtonStyle.Destructive
        )
        AppButton(
            text = "禁用态",
            onClick = {},
            enabled = false
        )

        Text(text = "Cell（五态 + 常用配置）", color = AppColor.textSecondary, fontSize = AppFont.sizeSm)
        Cell(title = "默认行", subtitle = "副标题示例", value = "¥3,850.00")
        Cell(
            title = "带图标",
            subtitle = "icon 参数显示左侧图标",
            icon = rememberVectorPainter(Icons.Filled.Favorite),
            value = "收藏"
        )
        Cell(title = "仅标题（无箭头）", arrow = false)
        Cell(title = "禁用态", value = "不可点", disabled = true)
        Cell(title = "加载中", value = "骨架动画", loading = true)
        Cell(title = "同步成功", value = "正常态", status = CellStatus.Success)
        Cell(title = "同步失败", value = "错误态", status = CellStatus.Error, showsDivider = false)
    }
}
