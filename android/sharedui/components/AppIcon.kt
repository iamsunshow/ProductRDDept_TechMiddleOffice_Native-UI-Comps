package com.zhiqihuayun.sharedui.components

import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.size
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.ColorFilter
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.sharedui.icons.SfApproxIcons

/**
 * 中台统一图标名（双端共用，iOS 映射 SF Symbol，Android 映射 SfApproxIcons）。
 */
enum class AppIconName(val label: String) {
    List("列表"),
    Chart("图表"),
    Plus("加号"),
    Safari("浏览器"),
    Person("人物"),
    ArrowDown("下拉三角"),
    Smartphone("手机"),
    Mail("邮箱");

    companion object {
        /** 对应的 iOS SF Symbol 系统名（供跨端文档参考）。 */
        fun sfSymbolName(self: AppIconName): String = when (self) {
            List -> "list.bullet.rectangle"
            Chart -> "chart.xyaxis.line"
            Plus -> "plus.circle.fill"
            Safari -> "safari"
            Person -> "person"
            ArrowDown -> "arrowtriangle.down.fill"
            Smartphone -> "smartphone"
            Mail -> "envelope"
        }
    }
}

/**
 * 中台基础图标组件（Compose）。
 *
 * 封装 SfApproxIcons 矢量图标，统一双端图标使用方式。
 * Android 用 SfApproxIcons 手绘矢量近似 SF Symbols，iOS 直接用系统 SF Symbols。
 *
 * @param name 图标名（双端统一枚举）
 * @param modifier 布局修饰符
 * @param size 尺寸（dp），默认 24
 * @param tint 着色，默认 textPrimary
 */
@Composable
fun AppIcon(
    name: AppIconName,
    modifier: Modifier = Modifier,
    size: Dp = 24.dp,
    tint: Color = AppColor.textPrimary
) {
    val vector: ImageVector = when (name) {
        AppIconName.List -> SfApproxIcons.ListBulletRectangle
        AppIconName.Chart -> SfApproxIcons.ChartXyAxisLine
        AppIconName.Plus -> SfApproxIcons.PlusCircleFill
        AppIconName.Safari -> SfApproxIcons.Safari
        AppIconName.Person -> SfApproxIcons.Person
        AppIconName.ArrowDown -> SfApproxIcons.ArrowTriangleDownFill
        AppIconName.Smartphone -> SfApproxIcons.Smartphone
        AppIconName.Mail -> SfApproxIcons.Mail
    }
    Image(
        imageVector = vector,
        contentDescription = name.label,
        modifier = modifier.size(size),
        colorFilter = ColorFilter.tint(tint),
        contentScale = ContentScale.Fit
    )
}
