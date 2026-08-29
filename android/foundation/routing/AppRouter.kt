package com.zhiqihuayun.foundation.routing

import androidx.navigation.NavGraph.Companion.findStartDestination
import androidx.navigation.NavHostController

class AppRouter(
    private val navController: NavHostController
) {
    fun open(title: String) {
        when (title) {
            "账单" -> push(SecondaryRoutes.BILL)
            "预算" -> push(SecondaryRoutes.BUDGET)
            "资产管家", "资产" -> push(SecondaryRoutes.ASSETS)
            "房贷计算器" -> push(SecondaryRoutes.MORTGAGE)
            "汇率换算" -> push(SecondaryRoutes.FX)
            "设置" -> push(SecondaryRoutes.SETTINGS)
            "数据备份" -> push(SecondaryRoutes.DATA_BACKUP)
            "账号设置" -> push(SecondaryRoutes.ACCOUNT_SETTINGS)
            "登录" -> push(SecondaryRoutes.LOGIN)
            "账号安全", "账户安全中心" -> push(SecondaryRoutes.ACCOUNT_SECURITY)
            "意见反馈" -> push(SecondaryRoutes.FEEDBACK)
            "帮助中心", "使用帮助" -> push(SecondaryRoutes.HELP)
            "关于", "关于小狐记账" -> push(SecondaryRoutes.ABOUT)
            else -> push(SecondaryRoutes.placeholder(title))
        }
    }

    fun pushPlaceholder(title: String) = open(title)

    fun push(route: String) {
        navController.navigate(route)
    }

    fun pop() {
        navController.popBackStack()
    }

    /** 回到「我的」Tab 根页（放弃/完成注销）。 */
    fun popUpToProfileRoot() {
        if (!navController.popBackStack(MainDestination.Profile.route, inclusive = false)) {
            selectTab(MainDestination.Profile)
        }
    }

    fun selectTab(destination: MainDestination) {
        navController.navigate(destination.route) {
            popUpTo(navController.graph.findStartDestination().id) {
                saveState = true
            }
            launchSingleTop = true
            restoreState = true
        }
    }
}
