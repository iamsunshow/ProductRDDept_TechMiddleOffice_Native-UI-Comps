package com.zhiqihuayun.demo

import android.app.Activity
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalView
import androidx.compose.ui.unit.dp
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppFont
import com.zhiqihuayun.foundation.design.AppSpace
import com.zhiqihuayun.foundation.design.ConfigureSystemBars
import com.zhiqihuayun.foundation.design.transparentStatusBarColor

/** 系统栏三态（与 iOS SystemBars.Style 同义）。 */
private enum class SystemBarsMode(val label: String) {
    DEFAULT("默认（白底深字）"),
    IMMERSIVE("沉浸（绿底白字）"),
    TRANSPARENT("透明（透明底深字）")
}

/**
 * SystemBars 系统栏 Demo（foundation.system-bars #90）。
 * 4 组排查：①默认态 ②沉浸态 ③透明态 ④三态联动切换。
 * Android 可直接设窗口状态栏底色（ConfigureSystemBars）；
 * iOS 无背景色 API，由页面在安全区自绘等价色块（差异表已放行）。
 */
@Composable
fun SystemBarsDemo() {
    var mode by remember { mutableStateOf(SystemBarsMode.DEFAULT) }
    val view = LocalView.current

    val statusBarColor = when (mode) {
        SystemBarsMode.DEFAULT -> AppColor.bgCard
        SystemBarsMode.IMMERSIVE -> AppColor.primary
        SystemBarsMode.TRANSPARENT -> Color(transparentStatusBarColor())
    }
    // 当前页状态栏 = 当前模式（演示组件本身的行为）
    ConfigureSystemBars(statusBarColor = statusBarColor)

    // 退出 Demo 页还原列表页默认态（宿主收尾示范）
    DisposableEffect(Unit) {
        onDispose {
            (view.context as? Activity)?.window?.let { window ->
                window.statusBarColor = android.graphics.Color.WHITE
            }
        }
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(horizontal = AppSpace.lg, vertical = AppSpace.md),
        verticalArrangement = Arrangement.spacedBy(AppSpace.lg)
    ) {
        DemoSection("D1 · 默认态（白底深字）") {
            TextButton(onClick = { mode = SystemBarsMode.DEFAULT }) {
                Text("应用默认态", fontSize = AppFont.sizeSm)
            }
            Text(
                "状态栏底色 bgCard（白），图标深色。\n" +
                    "ConfigureSystemBars(AppColor.bgCard) —— 图标明暗由底色亮度自动推导。",
                fontSize = AppFont.sizeSm, color = AppColor.textPrimary
            )
        }

        DemoSection("D2 · 沉浸态（绿底白字）") {
            TextButton(onClick = { mode = SystemBarsMode.IMMERSIVE }) {
                Text("应用沉浸态", fontSize = AppFont.sizeSm)
            }
            Text(
                "状态栏底色 primary（品牌绿），图标浅色。\n" +
                    "ConfigureSystemBars(AppColor.primary) —— 明细页/成果页沉浸头部。",
                fontSize = AppFont.sizeSm, color = AppColor.textPrimary
            )
        }

        DemoSection("D3 · 透明态（透明底深字）") {
            TextButton(onClick = { mode = SystemBarsMode.TRANSPARENT }) {
                Text("应用透明态", fontSize = AppFont.sizeSm)
            }
            Text(
                "状态栏底色透明，内容延伸到状态栏下方，图标深色。\n" +
                    "ConfigureSystemBars(transparentStatusBarColor())。",
                fontSize = AppFont.sizeSm, color = AppColor.textPrimary
            )
        }

        DemoSection("D4 · 三态联动切换") {
            Row(horizontalArrangement = Arrangement.spacedBy(AppSpace.xs)) {
                SystemBarsMode.values().forEach { m ->
                    TextButton(onClick = { mode = m }) {
                        Text(m.name, fontSize = AppFont.sizeSm)
                    }
                }
            }
            Text(
                "当前模式: ${mode.label}\n（切换后观察屏幕顶部状态栏实时变化）",
                fontSize = AppFont.sizeSm, color = AppColor.textPrimary
            )
        }

        Text(
            "foundation.system-bars = 按页声明系统栏外观（底色 + 图标明暗），" +
                "全局样式由宿主启动时设置，组件按页覆盖；" +
                "iOS 无状态栏背景色 API，沉浸底色由页面安全区自绘（差异表已放行）。",
            fontSize = AppFont.sizeXs, color = AppColor.textSecondary
        )
    }
}
