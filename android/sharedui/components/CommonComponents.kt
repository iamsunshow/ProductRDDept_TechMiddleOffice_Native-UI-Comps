package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBars
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.layout.windowInsetsPadding
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.outlined.ArrowBack
import androidx.compose.material.icons.filled.Clear
import androidx.compose.material.icons.filled.Visibility
import androidx.compose.material.icons.filled.VisibilityOff
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.ui.window.Dialog
import androidx.compose.ui.window.DialogProperties
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.role
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.input.VisualTransformation
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppFont
import com.zhiqihuayun.foundation.design.AppRadius
import com.zhiqihuayun.foundation.design.AppSpace
import com.zhiqihuayun.foundation.design.AppText

/**
 * 列表空态，默认文案对齐 iOS「暂无数据」。
 */
@Composable
fun EmptyStateView(
    message: String = "暂无数据",
    modifier: Modifier = Modifier
) {
    Box(
        modifier = modifier.fillMaxSize(),
        contentAlignment = Alignment.Center
    ) {
        Text(
            text = message,
            color = AppColor.textSecondary,
            fontSize = AppFont.sizeMd,
            textAlign = TextAlign.Center
        )
    }
}

/**
 * 二级占位页：带系统返回语义。
 */
@Composable
fun PlaceholderScreen(
    title: String,
    onBack: () -> Unit,
    modifier: Modifier = Modifier
) {
    Column(modifier = modifier.fillMaxSize()) {
        ScreenTopBar(title = title, onBack = onBack)
        EmptyStateView(
            message = "「$title」开发中",
            modifier = Modifier.weight(1f)
        )
    }
}

@Composable
fun FeatureHomeScaffold(
    title: String,
    modifier: Modifier = Modifier,
    content: @Composable () -> Unit
) {
    Column(modifier = modifier.fillMaxSize()) {
        ScreenTopBar(title = title, onBack = null)
        Box(
            modifier = Modifier
                .weight(1f)
                .fillMaxSize()
                .padding(AppSpace.lg),
            contentAlignment = Alignment.Center
        ) {
            content()
        }
    }
}

/**
 * 白顶栏对齐 iOS UINavigationBar：内容高 **44dp**，标题居中 18 semibold，底部分隔。
 * （不用 Material TopAppBar，避免默认 ~64dp 破坏 1:1。）
 *
 * edge-to-edge 下用 `statusBars` inset 把内容顶到状态栏下方，避免标题/返回键与系统时间、电量重叠。
 */
@Composable
fun ScreenTopBar(
    title: String,
    onBack: (() -> Unit)?,
    modifier: Modifier = Modifier
) {
    Column(
        modifier = modifier
            .fillMaxWidth()
            .background(AppColor.bgCard)
            .windowInsetsPadding(WindowInsets.statusBars)
    ) {
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(44.dp)
        ) {
            if (onBack != null) {
                Box(
                    modifier = Modifier
                        .align(Alignment.CenterStart)
                        .size(48.dp)
                        .semantics {
                            role = Role.Button
                            contentDescription = "返回"
                        }
                        .clickable(onClick = onBack),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        imageVector = Icons.AutoMirrored.Outlined.ArrowBack,
                        contentDescription = null,
                        tint = AppColor.primary,
                        modifier = Modifier.size(24.dp)
                    )
                }
            }
            Text(
                text = title,
                fontSize = AppFont.sizeLg,
                fontWeight = FontWeight.SemiBold,
                color = AppColor.textPrimary,
                modifier = Modifier.align(Alignment.Center)
            )
        }
        HorizontalDivider(color = AppColor.border, thickness = 0.5.dp)
    }
}

@Composable
fun SimpleFeaturePlaceholder(
    title: String,
    subtitle: String,
    modifier: Modifier = Modifier
) {
    FeatureHomeScaffold(title = title, modifier = modifier) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(AppSpace.sm)
        ) {
            Text(text = subtitle, color = AppColor.textSecondary, fontSize = AppFont.sizeMd)
        }
    }
}

/* ───────────────────────── 基础输入框组件 ─────────────────────────
 * 通用登录/表单输入框，供多端复用：
 * - AppInputField：通用基础输入框（placeholder / 清除按钮 / 尾部动作 icon）
 * - PhoneInputField / EmailInputField：带自动清除的专用输入框
 * - PasswordInputField：密码输入，支持明文/密文切换
 * ────────────────────────────────────────────────────────────────── */

/** 圆形「清空」按钮（叉）：输入非空时显示在输入框尾部。 */
@Composable
private fun ClearIconButton(onClick: () -> Unit) {
    Box(
        modifier = Modifier
            .size(20.dp)
            .background(Color(0xFFD1D5DB), CircleShape)
            .clickable(onClick = onClick),
        contentAlignment = Alignment.Center
    ) {
        Icon(
            imageVector = Icons.Default.Clear,
            contentDescription = "清空",
            tint = Color.White,
            modifier = Modifier.size(14.dp)
        )
    }
}

/**
 * 通用基础输入框。
 *
 * @param value 当前文本
 * @param onValueChange 文本变化回调
 * @param placeholder 占位提示
 * @param keyboardType 键盘类型（文本/手机号/邮箱等）
 * @param visualTransformation 文本变换（密码掩码等）
 * @param showClearButton 非空时是否显示尾部圆形「清空」按钮
 * @param trailingAction 自定义尾部动作（如密码显隐切换），置于清空按钮之后
 */
@Composable
fun AppInputField(
    value: String,
    onValueChange: (String) -> Unit,
    placeholder: String,
    modifier: Modifier = Modifier,
    keyboardType: KeyboardType = KeyboardType.Text,
    visualTransformation: VisualTransformation = VisualTransformation.None,
    showClearButton: Boolean = true,
    trailingAction: (@Composable () -> Unit)? = null
) {
    BasicTextField(
        value = value,
        onValueChange = onValueChange,
        modifier = modifier
            .fillMaxWidth()
            .background(AppColor.bgPage, RoundedCornerShape(AppRadius.lg))
            .padding(horizontal = AppSpace.md),
        singleLine = true,
        keyboardOptions = KeyboardOptions(keyboardType = keyboardType),
        visualTransformation = visualTransformation,
        textStyle = TextStyle(fontSize = AppFont.sizeMd, color = AppColor.textPrimary),
        decorationBox = { innerTextField ->
            Row(
                verticalAlignment = Alignment.CenterVertically,
                modifier = Modifier.height(52.dp)
            ) {
                Box(modifier = Modifier.weight(1f)) {
                    if (value.isEmpty()) {
                        Text(
                            text = placeholder,
                            color = AppColor.textSecondary,
                            fontSize = AppFont.sizeMd
                        )
                    }
                    innerTextField()
                }
                if (value.isNotEmpty() && showClearButton) {
                    ClearIconButton { onValueChange("") }
                }
                trailingAction?.invoke()
            }
        }
    )
}

/**
 * 手机号输入框：自动数字键盘 + 非空时显示圆形「清空」按钮。
 * 供手机号登录 / 注册 / 找回密码等场景复用。
 */
@Composable
fun PhoneInputField(
    value: String,
    onValueChange: (String) -> Unit,
    placeholder: String = "手机号码",
    modifier: Modifier = Modifier
) {
    AppInputField(
        value = value,
        onValueChange = onValueChange,
        placeholder = placeholder,
        modifier = modifier,
        keyboardType = KeyboardType.Phone
    )
}

/**
 * 邮箱输入框：自动邮箱键盘 + 非空时显示圆形「清空」按钮。
 * 供邮箱登录 / 注册 / 找回密码等场景复用。
 */
@Composable
fun EmailInputField(
    value: String,
    onValueChange: (String) -> Unit,
    placeholder: String = "邮箱地址",
    modifier: Modifier = Modifier
) {
    AppInputField(
        value = value,
        onValueChange = onValueChange,
        placeholder = placeholder,
        modifier = modifier,
        keyboardType = KeyboardType.Email
    )
}

/**
 * 密码输入框：默认密文（圆点）显示，尾部眼睛 icon 可在明文/密文间切换。
 * 供手机号 / 邮箱登录等场景复用。
 *
 * @param value 当前密码
 * @param onValueChange 密码变化回调
 * @param placeholder 占位提示（默认「输入密码」）
 */
@Composable
fun PasswordInputField(
    value: String,
    onValueChange: (String) -> Unit,
    placeholder: String = "输入密码",
    modifier: Modifier = Modifier
) {
    // 明文/密文切换状态（true=明文显示，false=密文圆点）
    var passwordVisible by remember { mutableStateOf(false) }
    AppInputField(
        value = value,
        onValueChange = onValueChange,
        placeholder = placeholder,
        modifier = modifier,
        keyboardType = KeyboardType.Password,
        visualTransformation = if (passwordVisible) {
            VisualTransformation.None
        } else {
            PasswordVisualTransformation()
        },
        trailingAction = {
            Icon(
                imageVector = if (passwordVisible) Icons.Default.Visibility else Icons.Default.VisibilityOff,
                contentDescription = if (passwordVisible) "隐藏密码" else "显示密码",
                tint = AppColor.textSecondary,
                modifier = Modifier
                    .size(20.dp)
                    .clickable { passwordVisible = !passwordVisible }
            )
        }
    )
}

/* ───────────────────────── 统一弹窗组件 ─────────────────────────
 * AppDialog：项目统一弹窗标准组件（标题 / 内容 / 按钮），沉淀于中台供多端复用。
 * - 按钮布局分两档：
 *   - Vertical（默认）：按钮「通栏」全宽、自上而下排列（iOS ActionSheet 风格）
 *   - Horizontal：按钮左右并排排列（iOS Alert 风格）
 * - 弹窗尺寸、圆角、按钮高度、间距统一对齐 design token。
 * 术语约定：凡是「弹窗」即指 AppDialog 这套组件。
 * ────────────────────────────────────────────────────────────────── */

/** 弹窗按钮布局模式。 */
enum class DialogButtonLayout {
    /** 通栏全宽按钮，自上而下排列（默认）。 */
    Vertical,

    /** 左右并排排列。 */
    Horizontal
}

/** 弹窗按钮视觉样式。 */
enum class DialogButtonStyle {
    /** 主操作：填充主色背景。 */
    Primary,

    /** 次要操作：浅色描边 / 浅色背景。 */
    Default,

    /** 破坏性操作：红色文字。 */
    Destructive
}

/** 单个弹窗按钮配置。 */
data class DialogAction(
    val text: String,
    val onClick: () -> Unit,
    val style: DialogButtonStyle = DialogButtonStyle.Default
)

/**
 * 统一弹窗组件（标题 / 内容 / 按钮），沉淀于中台。
 *
 * @param title 标题（可空，空则不显示标题区）
 * @param content 正文文本（与 [contentContent] 二选一，优先取 [contentContent]）
 * @param contentContent 自定义正文内容，可用富文本/协议链接等复杂内容
 * @param actions 按钮列表。Vertical 布局每项全宽通栏排列；Horizontal 布局最多取 2 项左右排列
 * @param buttonLayout 按钮布局（默认 Vertical 通栏）
 * @param onDismiss 点击遮罩关闭回调（可空则不响应点遮罩）
 */
@Composable
fun AppDialog(
    title: String? = null,
    content: String? = null,
    contentContent: (@Composable () -> Unit)? = null,
    actions: List<DialogAction>,
    buttonLayout: DialogButtonLayout = DialogButtonLayout.Vertical,
    onDismiss: (() -> Unit)? = null
) {
    Dialog(
        onDismissRequest = { onDismiss?.invoke() },
        properties = DialogProperties(usePlatformDefaultWidth = false)
    ) {
        Card(
            shape = RoundedCornerShape(AppRadius.lg),
            colors = androidx.compose.material3.CardDefaults.cardColors(containerColor = AppColor.bgCard)
        ) {
            Column(
                modifier = Modifier
                    .widthIn(min = 300.dp, max = 360.dp)
                    .padding(horizontal = AppSpace.lg)
                    .padding(bottom = AppSpace.md)
            ) {
                // ── 标题 ──
                if (title != null) {
                    Text(
                        text = title,
                        fontSize = AppFont.sizeMd,
                        fontWeight = FontWeight.SemiBold,
                        color = AppColor.textPrimary,
                        textAlign = TextAlign.Center,
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(top = AppSpace.lg)
                    )
                }

                // ── 内容 ──
                if (contentContent != null) {
                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(vertical = AppSpace.lg)
                    ) {
                        contentContent()
                    }
                } else if (content != null) {
                    Text(
                        text = content,
                        fontSize = AppFont.sizeSm,
                        color = AppColor.textSecondary,
                        lineHeight = AppText.lineHeight(AppFont.sizeSm),
                        textAlign = TextAlign.Center,
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(vertical = AppSpace.lg)
                    )
                }

                // ── 按钮区 ──
                when (buttonLayout) {
                    DialogButtonLayout.Vertical -> DialogVerticalButtons(actions)
                    DialogButtonLayout.Horizontal -> DialogHorizontalButtons(actions)
                }
            }
        }
    }
}

/** 通栏按钮：自上而下全宽排列，两两之间留间距。 */
@Composable
private fun DialogVerticalButtons(actions: List<DialogAction>) {
    Column(verticalArrangement = Arrangement.spacedBy(AppSpace.md)) {
        actions.forEach { action ->
            AppButton(
                text = action.text,
                onClick = action.onClick,
                style = action.style.toAppButtonStyle()
            )
        }
    }
}

/** 左右并排按钮：最多 2 项，左右排列。 */
@Composable
private fun DialogHorizontalButtons(actions: List<DialogAction>) {
    val visible = actions.take(2)
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.spacedBy(AppSpace.md)
    ) {
        visible.forEach { action ->
            AppButton(
                text = action.text,
                onClick = action.onClick,
                style = action.style.toAppButtonStyle(),
                modifier = Modifier.weight(1f)
            )
        }
    }
}

/** 将弹窗按钮样式映射为中台基础按钮样式。 */
private fun DialogButtonStyle.toAppButtonStyle(): AppButtonStyle = when (this) {
    DialogButtonStyle.Primary -> AppButtonStyle.Primary
    DialogButtonStyle.Default -> AppButtonStyle.Secondary
    DialogButtonStyle.Destructive -> AppButtonStyle.Destructive
}

/**
 * 协议确认弹框（「用户协议及隐私保护」）：
 * 未勾选协议时点击登录触发，供用户先阅读并同意协议。复用统一弹窗组件 [AppDialog]。
 *
 * @param title 弹框标题
 * @param content 协议说明文案（含各协议名）
 * @param onAgree 「同意并继续」
 * @param onDisagree 「不同意」
 */
@Composable
fun AgreementConfirmDialog(
    title: String,
    content: String,
    onAgree: () -> Unit,
    onDisagree: () -> Unit
) {
    AppDialog(
        title = title,
        content = content,
        actions = listOf(
            DialogAction(text = "同意并继续", onClick = onAgree, style = DialogButtonStyle.Primary),
            DialogAction(text = "不同意", onClick = onDisagree, style = DialogButtonStyle.Default)
        ),
        buttonLayout = DialogButtonLayout.Vertical,
        onDismiss = onDisagree
    )
}
