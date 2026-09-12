// Table 表格组件（Compose 版，对齐 iOS TableView）。
//
// 数据表格：行列布局，支持表头吸顶、斑马纹、自定义列宽、对齐方式。

package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.IntrinsicSize
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.RowScope
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppFont
import com.zhiqihuayun.foundation.design.AppRadius
import com.zhiqihuayun.foundation.design.AppSpace

/** 列定义。 */
data class TableColumn(
    val title: String,
    val width: Dp? = null,
    val align: TextAlign = TextAlign.Start,
)

/** 行数据。 */
data class TableRow(
    val cells: List<String>,
)

/**
 * 表格组件。
 *
 * @param columns 列定义
 * @param data 行数据
 * @param striped 是否斑马纹，默认 false
 * @param stickyHeader 是否吸顶表头（一期不实现滚动吸顶，仅视觉区分）
 * @param cellPadding 单元格内边距
 */
@Composable
fun Table(
    columns: List<TableColumn>,
    data: List<TableRow>,
    striped: Boolean = false,
    stickyHeader: Boolean = false,
    cellPadding: Dp = AppSpace.sm,
) {
    val borderColor = AppColor.border
    val shape = RoundedCornerShape(AppRadius.lg)
    val scrollState = rememberScrollState()

    Column(
        modifier = Modifier
            .fillMaxWidth()
            .clip(shape)
            .border(1.dp, borderColor, shape)
            .background(AppColor.bgCard, shape),
    ) {
        // 表头
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .horizontalScroll(scrollState)
                .background(if (stickyHeader) AppColor.bgPage else AppColor.bgCard)
                .height(IntrinsicSize.Min),
        ) {
            for (col in columns) {
                CellBox(
                    text = col.title,
                    width = col.width,
                    align = col.align,
                    padding = cellPadding,
                    isHeader = true,
                    borderColor = borderColor,
                )
            }
        }

        // 数据行
        data.forEachIndexed { rowIndex, row ->
            val bgColor = if (striped && rowIndex % 2 == 1) AppColor.bgPage else AppColor.bgCard
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .horizontalScroll(scrollState)
                    .background(bgColor)
                    .height(IntrinsicSize.Min),
            ) {
                for (colIndex in columns.indices) {
                    val col = columns[colIndex]
                    val text = row.cells.getOrElse(colIndex) { "" }
                    CellBox(
                        text = text,
                        width = col.width,
                        align = col.align,
                        padding = cellPadding,
                        isHeader = false,
                        borderColor = borderColor,
                    )
                }
            }
        }
    }
}

/** 表头单元格（RowScope 扩展，可用 weight）。 */
@Composable
private fun RowScope.CellBox(
    text: String,
    width: Dp?,
    align: TextAlign,
    padding: Dp,
    isHeader: Boolean,
    borderColor: Color,
) {
    val widthMod = if (width != null) Modifier.width(width) else Modifier.weight(1f)
    Box(
        modifier = Modifier
            .then(widthMod)
            .height(IntrinsicSize.Min)
            .padding(padding),
        contentAlignment = when (align) {
            TextAlign.Center -> Alignment.Center
            TextAlign.End -> Alignment.CenterEnd
            else -> Alignment.CenterStart
        },
    ) {
        Text(
            text = text,
            color = if (isHeader) AppColor.textPrimary else AppColor.textSecondary,
            fontSize = if (isHeader) AppFont.sizeSm else AppFont.sizeSm,
            fontWeight = if (isHeader) FontWeight.SemiBold else FontWeight.Normal,
            textAlign = align,
            maxLines = 2,
            overflow = TextOverflow.Ellipsis,
        )
    }
}
