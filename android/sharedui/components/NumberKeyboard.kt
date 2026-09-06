package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppFont

/**
 * NumberKeyboard 数字键盘（ui.number-keyboard，任务清单 #32）——内嵌式数字键盘面板（数据录入区）。
 * 4 行×4 列键格：1~9 三行 + 底行（首格=extraKey 文本，否则 showDot=true 显示「.」、showDot=false
 * 且无 extraKey=灰「·」空占位不可点；中格=0；末格=删除）+ 右列「确认」竖条整列主色。
 * 纯事件回调（键盘零状态、无内部值）：数字/小数/extraKey 文本=onInput(字符)，退格=onDelete()，
 * 点确认列=onConfirm()；值由宿主输入模型持有（对齐 Input 受控惯例）。禁用：confirmDisabled=仅确认列
 * buttonDisabled 灰不可点；disabled=整键盘 alpha 40% 不可点。一期无遮罩/浮层/乱序/连删（二期随 Popup）。
 * 与业务记账 AmountKeyboard（business.amount-keyboard，金额千分位/两位小数/确认金额）划界=本组件
 * 通用裸键格无金额语义。
 *
 * 规格：docs/数据与产物/design-spec/number-keyboard-design-spec.html（门禁 A P1–P4 全 A）。
 * 基线：组件库 v1.4.0（2026-09-06，未过 C2/D 不升版）。
 *
 * 设计锚点（Token 注释锚定）：整件高 208dp=52×4 行；网格缝隙=0.5dp 露 AppColor.border 底色线
 * （iOS 1/scale pt 表内放行）；键底白 bgCard；数字/点/X 字号 22=sizeXl、删除 14=sizeSm 次色、
 * 确认列 Md=16 白字整列；空占位「·」textSecondary @ 40%；confirmDisabled=buttonDisabled 灰；
 * disabled=整体 alpha 40% 不可点。
 */
@Composable
fun NumberKeyboard(
    onInput: (String) -> Unit,
    onDelete: (() -> Unit)? = null,
    onConfirm: (() -> Unit)? = null,
    confirmText: String = "确认",
    showDot: Boolean = true,
    extraKey: String? = null,
    confirmDisabled: Boolean = false,
    disabled: Boolean = false,
    modifier: Modifier = Modifier
) {
    val enabled = !disabled
    val gap = 0.5.dp
    val bottomFirst = extraKey ?: if (showDot) "." else "·" // 空占位不可点

    Column(
        modifier = modifier
            .fillMaxWidth()
            .height(208.dp)
            .background(AppColor.border)
            .alpha(if (disabled) 0.4f else 1f)
    ) {
        Row(
            modifier = Modifier.fillMaxSize(),
            horizontalArrangement = Arrangement.spacedBy(gap)
        ) {
            // ---- 左侧 3×4 数字键区（1~9 / 底行首格·0·删除）----
            Column(
                modifier = Modifier.weight(3f).fillMaxHeight(),
                verticalArrangement = Arrangement.spacedBy(gap)
            ) {
                listOf(
                    listOf("1", "2", "3"),
                    listOf("4", "5", "6"),
                    listOf("7", "8", "9"),
                    listOf(bottomFirst, "0", "删除")
                ).forEach { rowKeys ->
                    Row(
                        modifier = Modifier.weight(1f).fillMaxWidth(),
                        horizontalArrangement = Arrangement.spacedBy(gap)
                    ) {
                        rowKeys.forEach { key ->
                            val isDelete = key == "删除"
                            val isPhantom = key == "·"
                            val clickEnabled = enabled && (if (isDelete) onDelete != null else !isPhantom)
                            Box(
                                modifier = Modifier
                                    .weight(1f)
                                    .fillMaxHeight()
                                    .background(AppColor.bgCard)
                                    .clickable(enabled = clickEnabled) {
                                        when {
                                            isDelete -> onDelete?.invoke()
                                            else -> onInput(key)
                                        }
                                    },
                                contentAlignment = Alignment.Center
                            ) {
                                Text(
                                    text = key,
                                    fontSize = if (isDelete) AppFont.sizeSm else AppFont.sizeXl,
                                    color = when {
                                        isDelete -> AppColor.textSecondary
                                        isPhantom -> AppColor.textSecondary.copy(alpha = 0.4f)
                                        else -> AppColor.textPrimary
                                    }
                                )
                            }
                        }
                    }
                }
            }
            // ---- 右列「确认」竖条（跨 4 行整列主色）----
            val confirmActive = enabled && !confirmDisabled && onConfirm != null
            Box(
                modifier = Modifier
                    .weight(1f)
                    .fillMaxHeight()
                    .background(if (confirmActive) AppColor.primary else AppColor.buttonDisabled)
                    .clickable(enabled = confirmActive) { onConfirm?.invoke() },
                contentAlignment = Alignment.Center
            ) {
                Text(
                    text = confirmText,
                    fontSize = AppFont.sizeMd,
                    color = Color.White
                )
            }
        }
    }
}
