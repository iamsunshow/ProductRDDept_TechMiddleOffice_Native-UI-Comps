package com.zhiqihuayun.foundation.design

import android.app.Activity
import android.graphics.Color as AndroidColor
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.luminance
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.platform.LocalView
import androidx.core.view.WindowCompat

/**
 * 按页设置状态栏：明细绿底浅色图标，其它页白底深色图标。
 */
@Composable
fun ConfigureSystemBars(
    statusBarColor: Color,
    navigationBarColor: Color = AppColor.bgCard
) {
    val view = LocalView.current
    DisposableEffect(statusBarColor, navigationBarColor) {
        val window = (view.context as? Activity)?.window ?: return@DisposableEffect onDispose {}
        window.statusBarColor = statusBarColor.toArgb()
        window.navigationBarColor = navigationBarColor.toArgb()
        val controller = WindowCompat.getInsetsController(window, view)
        controller.isAppearanceLightStatusBars = statusBarColor.luminance() > 0.5f
        controller.isAppearanceLightNavigationBars = true
        onDispose { }
    }
}

/** 透明状态栏初始值，由各页 ConfigureSystemBars 覆盖。 */
fun transparentStatusBarColor(): Int = AndroidColor.TRANSPARENT
