package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.RowScope
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.defaultMinSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppFont
import com.zhiqihuayun.foundation.design.AppRadius
import com.zhiqihuayun.foundation.design.AppSpace

/**
 * Form 表单容器（ui.form，#28）——表单布局容器组件（数据录入区第二批）。
 *
 * 定位：**分组卡片 + 字段行排版 + 校验文案渲染管道**，不含具体输入控件：
 * - `Form`：单分组卡片（可选 `groupTitle` 分组标题），content 内宿主顺序放
 *   `FormFieldRow`（多分组=宿主纵向并列多个 `Form`，间距用 Space/Arrangement 控制）。
 * - `FormFieldRow`：label（左，区宽 96dp 固定，超长自动折行）+ required 必填星（primary 前置）
 *   + 内容槽（宿主自放输入控件/mock）+ 行内提示槽（error 非空=红字，否则 help 灰字，都空=不占位）。
 * - 校验算法与表单状态管理=宿主职责（校验结论经 error 文案传入，组件只渲染）。
 *
 * 组件为内嵌内容视图：无弹层/键盘/校验引擎（宿主自理）；行高 min 48dp、行间 hairline 0.5dp
 * 全卡宽分隔（同 Cell 先例）；label 空=内容全宽（宿主 content 用 weight 占余宽）。
 *
 * 设计锚点（Token 注释锚定）：label Md=16 主色；必填星 Md=16 primary；help/error 字号 Xs=12
 * 次色/红 error；卡片=bgCard + 圆角 lg + hairline 边框；行内容槽与 iOS contentView 对齐
 * （内容槽语法差异表内放行）。
 *
 * 规格：docs/数据与产物/design-spec/form-design-spec.html（门禁 A review-form-A.md，P1–P4 全 A）。
 * 基线：组件库 v1.4.0（2026-09-06，未过 C2/D 不升版）。
 */
@Composable
fun Form(
    groupTitle: String? = null,
    modifier: Modifier = Modifier,
    content: @Composable ColumnScope.() -> Unit
) {
    val shape = RoundedCornerShape(AppRadius.lg)
    Column(
        modifier = modifier
            .fillMaxWidth()
            .clip(shape)
            .background(AppColor.bgCard)
            .border(0.5.dp, AppColor.border, shape),
        verticalArrangement = Arrangement.Top
    ) {
        if (!groupTitle.isNullOrEmpty()) {
            Text(
                text = groupTitle,
                modifier = Modifier.padding(start = AppSpace.lg, top = 10.dp, end = AppSpace.lg, bottom = 4.dp),
                fontSize = AppFont.sizeXs,
                color = AppColor.textSecondary
            )
        }
        content()
    }
}

/**
 * Form 字段行：label（96dp 固定区折行，超长自动换行）+ 必填星 + 内容槽 + 行内 help/error 提示行。
 * error 优先于 help（共用提示槽）；都空=无提示行不占位。底部自带 0.5dp hairline 全卡宽分隔
 * （与 iOS 1/scale pt 表内放行；最后一行亦保留分隔，同设计稿 mock）。
 */
@Composable
fun FormFieldRow(
    label: String? = null,
    required: Boolean = false,
    help: String? = null,
    error: String? = null,
    modifier: Modifier = Modifier,
    content: @Composable RowScope.() -> Unit
) {
    val showsLabel = !label.isNullOrEmpty()
    val hasError = !error.isNullOrEmpty()
    val hint = if (hasError) error else help

    Column(modifier.fillMaxWidth()) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .defaultMinSize(minHeight = 48.dp)
                .padding(horizontal = AppSpace.lg),
            verticalAlignment = Alignment.CenterVertically
        ) {
            if (showsLabel || required) {
                // label 区固定宽 96dp（含星占位；超长自动折行顶部对齐，同 iOS labelLabel）
                Row(
                    modifier = Modifier.width(96.dp),
                    verticalAlignment = Alignment.Top
                ) {
                    if (required) {
                        Text(
                            text = "* ",
                            fontSize = AppFont.sizeMd,
                            color = AppColor.primary
                        )
                    }
                    Text(
                        text = label.orEmpty(),
                        fontSize = AppFont.sizeMd,
                        color = AppColor.textPrimary
                    )
                }
                Spacer(Modifier.width(12.dp))
            }
            content()
        }
        if (!hint.isNullOrEmpty()) {
            Text(
                text = hint,
                modifier = Modifier.padding(start = AppSpace.lg, end = AppSpace.lg, bottom = 6.dp),
                fontSize = AppFont.sizeXs,
                color = if (hasError) AppColor.error else AppColor.textSecondary
            )
        }
        // 行底 hairline 全卡宽（同 Cell 分隔先例）
        Box(
            Modifier
                .fillMaxWidth()
                .height(0.5.dp)
                .background(AppColor.border)
        )
    }
}
