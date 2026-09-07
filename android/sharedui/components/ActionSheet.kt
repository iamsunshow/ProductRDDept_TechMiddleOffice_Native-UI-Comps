// ActionSheet 动作面板（Android Compose 版，对齐 iOS ActionSheetView.swift / api.json `ui.action-sheet`）。
//
// 组件 ID：`ui.action-sheet` ｜ 任务清单 #44 ｜ 操作反馈区首件 ｜ TMO 组件库 v1.4.0
//
// 定位：底部弹出的动作选择面板——点击触发按钮后从底部滑出，展示一组操作选项供用户点选，
// 选中后自动收起。受控 visible 模式（与 DatePickerSheet/Picker 一致），宿主完全控制生命周期。
//
// 契约 @param（与 api.json 100% 对齐）：
// - visible: Boolean          （*必选*：true=渲染 ModalBottomSheet + 滑入；false=不渲染）
// - title: String? = null     （null=不渲染标题行）
// - description: String? = null （null=不渲染描述行）
// - actions: List<ActionSheetItem> （*必选*：操作项列表）
// - cancelText: String = "取消" （取消按钮文案）
// - onSelect: ((Int) -> Unit)? = null （null=不回调仅收起）
// - onCancel: (() -> Unit)? = null    （null=不回调）
// - disabled: Boolean = false  （整体禁用，所有操作项灰显不可点，取消按钮仍可点收起）
//
// 事件回调：
// - onSelect: (index: Int) -> Unit （点击非禁用操作项 → 面板滑出 → 回调 index）
// - onCancel: () -> Unit           （点击取消/遮罩 → 面板滑出 → 回调）
//
// 设计规格（design-spec/action-sheet-design-spec.html）：
// - 遮罩：black 45% 透明
// - 面板：白底，顶部圆角 radiusLg 14dp
// - 标题行：高 56dp，居中，fontMd(16) textSecondary；无 title=不渲染
// - 描述行：标题下方，居中，fontSm(14) textSecondary；无 description=不渲染
// - 操作项：高 56dp，居中，fontLg(18) textPrimary；destructive=danger 色；disabled=alpha 0.4
// - 分隔线：操作项间 0.5dp hairline
// - 间距条：操作列表与取消按钮间 8dp bgPage 灰底间隙
// - 取消按钮：高 56dp，居中，fontLg(18) textPrimary，白底，顶部 hairline
// - 底部安全区：navigationBars bottom padding
// - 动画：遮罩淡入 + 面板滑入 250ms（ModalBottomSheet 内置动画）
//
// 用法：
// ```kotlin
// var visible by remember { mutableStateOf(false) }
// ActionSheet(
//     visible = visible,
//     title = "分享到",
//     actions = listOf(
//         ActionSheetItem("微信好友"),
//         ActionSheetItem("朋友圈"),
//         ActionSheetItem("复制链接")
//     ),
//     onSelect = { index -> visible = false; /* ... */ },
//     onCancel = { visible = false }
// )
// ```

package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.Text
import androidx.compose.material3.rememberModalBottomSheetState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppFont
import com.zhiqihuayun.foundation.design.AppRadius
import com.zhiqihuayun.foundation.design.AppSpace
import kotlinx.coroutines.launch

// ============== 数据模型（与 iOS ActionSheetItem 对齐）==============

/**
 * 操作项数据模型（与 api.json ActionSheetItem 对齐）。
 *
 * @param text 操作项文案
 * @param destructive 是否危险动作（红色文案），默认 false
 * @param disabled 该操作项是否禁用（灰显不可点），默认 false
 */
data class ActionSheetItem(
    val text: String,
    val destructive: Boolean = false,
    val disabled: Boolean = false
)

// ============== 主组件函数 ==============

/**
 * 底部动作面板（Compose 声明式）。全部 props 默认值与 api.json 100% 对齐。
 *
 * 受控 visible 驱动渲染/卸载 ModalBottomSheet：
 * - visible=true → 渲染 ModalBottomSheet（内置滑入动画 250ms）
 * - visible=false → 不渲染（宿主设置 visible=false 前先通过 sheetState.hide() 滑出）
 *
 * 交互：
 * - 点击操作项（非禁用）→ sheetState.hide() 滑出 → onSelect(index)
 * - 点击取消/遮罩 → sheetState.hide() 滑出 → onCancel()
 * - 禁用项 → 不触发回调，不收起
 * - 整体禁用 → 所有操作项灰显不可点，取消按钮仍可点收起
 *
 * @param visible 是否展示（受控）
 * @param title 面板标题（null=不渲染标题行）
 * @param description 标题下方描述文案（null=不渲染描述行）
 * @param actions 操作项列表
 * @param cancelText 取消按钮文案，默认 "取消"
 * @param onSelect 选中操作项回调（回传 index；null=不回调仅收起）
 * @param onCancel 取消/遮罩点击回调（null=不回调）
 * @param disabled 整体禁用（所有操作项灰显不可点，取消按钮仍可点收起）
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ActionSheet(
    visible: Boolean,
    title: String? = null,
    description: String? = null,
    actions: List<ActionSheetItem>,
    cancelText: String = "取消",
    onSelect: ((Int) -> Unit)? = null,
    onCancel: (() -> Unit)? = null,
    disabled: Boolean = false,
) {
    if (!visible) return

    val sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true)
    val scope = rememberCoroutineScope()

    // 统一收起：先动画滑出，再回调
    fun selectAction(index: Int) {
        scope.launch {
            sheetState.hide()
            onSelect?.invoke(index)
        }
    }

    fun cancelSheet() {
        scope.launch {
            sheetState.hide()
            onCancel?.invoke()
        }
    }

    ModalBottomSheet(
        onDismissRequest = { cancelSheet() },
        sheetState = sheetState,
        containerColor = AppColor.bgCard,
        shape = RoundedCornerShape(topStart = AppRadius.lg, topEnd = AppRadius.lg),
        scrimColor = Color.Black.copy(alpha = 0.45f),
        dragHandle = null,  // 无拖拽把手（与 iOS 对齐）
    ) {
        ActionSheetContent(
            title = title,
            description = description,
            actions = actions,
            cancelText = cancelText,
            disabled = disabled,
            onSelect = { selectAction(it) },
            onCancel = { cancelSheet() },
        )
    }
}

// ============== 面板内容（标题 + 描述 + 操作列表 + 间距 + 取消 + 安全区）==============

@Composable
private fun ActionSheetContent(
    title: String?,
    description: String?,
    actions: List<ActionSheetItem>,
    cancelText: String,
    disabled: Boolean,
    onSelect: (Int) -> Unit,
    onCancel: () -> Unit,
) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .background(AppColor.bgCard)
            .navigationBarsPadding()
    ) {
        // ---- 标题行（无 title=不渲染）----
        if (title != null && title.isNotEmpty()) {
            ActionSheetTitleRow(title)
            ActionSheetHairline()
        }

        // ---- 描述行（无 description=不渲染）----
        if (description != null && description.isNotEmpty()) {
            ActionSheetDescriptionRow(description)
            ActionSheetHairline()
        }

        // ---- 操作项列表 ----
        actions.forEachIndexed { index, item ->
            val isItemDisabled = disabled || item.disabled
            ActionSheetActionRow(
                text = item.text,
                destructive = item.destructive,
                disabled = isItemDisabled,
                onClick = { onSelect(index) }
            )
            // 非末项底部 hairline
            if (index < actions.lastIndex) {
                ActionSheetHairline()
            }
        }

        // ---- 间距条（8dp 灰底间隙）----
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(8.dp)
                .background(AppColor.bgPage)
        )

        // ---- 取消按钮 ----
        ActionSheetCancelRow(text = cancelText, onClick = onCancel)
    }
}

// ============== 行组件 ==============

/** 标题行：高 56dp，居中，fontMd(16) textSecondary。 */
@Composable
private fun ActionSheetTitleRow(text: String) {
    Box(
        modifier = Modifier.fillMaxWidth().height(56.dp),
        contentAlignment = Alignment.Center
    ) {
        Text(
            text = text,
            fontSize = AppFont.sizeMd,
            color = AppColor.textSecondary,
            textAlign = TextAlign.Center,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis,
            modifier = Modifier.fillMaxWidth().padding(horizontal = AppSpace.lg)
        )
    }
}

/** 描述行：居中，fontSm(14) textSecondary。 */
@Composable
private fun ActionSheetDescriptionRow(text: String) {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = AppSpace.sm),
        contentAlignment = Alignment.Center
    ) {
        Text(
            text = text,
            fontSize = AppFont.sizeSm,
            color = AppColor.textSecondary,
            textAlign = TextAlign.Center,
            modifier = Modifier.fillMaxWidth().padding(horizontal = AppSpace.lg)
        )
    }
}

/** 操作项行：高 56dp，居中，fontLg(18)；destructive=danger 色；disabled=alpha 0.4 不可点。 */
@Composable
private fun ActionSheetActionRow(
    text: String,
    destructive: Boolean,
    disabled: Boolean,
    onClick: () -> Unit,
) {
    val textColor = if (destructive) AppColor.error else AppColor.textPrimary
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .height(56.dp)
            .let { m ->
                if (disabled) m
                else m.clickable(
                    interactionSource = remember { MutableInteractionSource() },
                    indication = null,
                    onClick = onClick
                )
            }
            .let { m -> if (disabled) m.background(AppColor.bgCard.copy(alpha = 0.4f)) else m }
            .then(Modifier.fillMaxWidth()),
        contentAlignment = Alignment.Center
    ) {
        Text(
            text = text,
            fontSize = AppFont.sizeLg,
            color = textColor,
            textAlign = TextAlign.Center,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis,
            modifier = Modifier.fillMaxWidth().padding(horizontal = AppSpace.lg)
        )
    }
}

/** 取消按钮：高 56dp，居中，fontLg(18) textPrimary，白底，顶部 hairline。 */
@Composable
private fun ActionSheetCancelRow(text: String, onClick: () -> Unit) {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .height(56.dp)
            .clickable(
                interactionSource = remember { MutableInteractionSource() },
                indication = null,
                onClick = onClick
            ),
        contentAlignment = Alignment.Center
    ) {
        Text(
            text = text,
            fontSize = AppFont.sizeLg,
            color = AppColor.textPrimary,
            textAlign = TextAlign.Center,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis,
            modifier = Modifier.fillMaxWidth().padding(horizontal = AppSpace.lg)
        )
    }
}

/** hairline 分隔线 0.5dp。 */
@Composable
private fun ActionSheetHairline() {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .height(0.5.dp)
            .background(AppColor.border)
    )
}
