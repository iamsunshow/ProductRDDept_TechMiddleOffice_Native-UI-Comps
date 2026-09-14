package com.zhiqihuayun.demo

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
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppFont
import com.zhiqihuayun.foundation.design.AppSpace
import com.zhiqihuayun.foundation.routing.MainDestination
import com.zhiqihuayun.foundation.routing.SecondaryRoutes

/**
 * Router 路由 Demo（foundation.router #92）。
 * 4 组排查：①路由表总览（一级 5 Tab + 二级示例）②一级 Tab 切换请求
 * ③二级 push 请求 + 返回 ④未登记标题兜底占位。
 * 采用内层路由状态机回显，不真 push 进 Demo 宿主栈（避免污染组件库 Demo 导航栈）。
 */
@Composable
fun RouterDemo() {
    var selectedTab by remember { mutableStateOf(MainDestination.Ledger) }
    var stack by remember { mutableStateOf(listOf<String>()) }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(horizontal = AppSpace.lg, vertical = AppSpace.md),
        verticalArrangement = Arrangement.spacedBy(AppSpace.lg)
    ) {
        DemoSection("D1 · 路由表总览") {
            Text(
                "一级 Tab（MainDestination 5）:\n" +
                    MainDestination.values().joinToString(" / ") { it.route } +
                    "\n\n二级示例（SecondaryRoutes）:\n" +
                    "bill · budget · assets · mortgage · fx · settings · " +
                    "transaction_detail/{recordId} · placeholder/{title}",
                fontSize = AppFont.sizeSm, color = AppColor.textPrimary
            )
        }

        DemoSection("D2 · 一级 Tab 切换请求") {
            Row(horizontalArrangement = Arrangement.spacedBy(AppSpace.xs)) {
                MainDestination.values().forEach { dest ->
                    TextButton(onClick = { selectedTab = dest }) {
                        Text(dest.route, fontSize = AppFont.sizeSm)
                    }
                }
            }
            Text(
                "当前选中 Tab: ${selectedTab.route}\n" +
                    "（宿主 AppRouter.selectTab(dest) → 导航容器切 Tab，状态保留）",
                fontSize = AppFont.sizeSm, color = AppColor.textPrimary
            )
        }

        DemoSection("D3 · 二级 push 请求 + 返回") {
            Row(horizontalArrangement = Arrangement.spacedBy(AppSpace.sm)) {
                TextButton(onClick = { stack = stack + SecondaryRoutes.BILL }) {
                    Text("push 账单(bill)", fontSize = AppFont.sizeSm)
                }
                TextButton(onClick = {
                    if (stack.isNotEmpty()) stack = stack.dropLast(1)
                }) {
                    Text("返回 pop", fontSize = AppFont.sizeSm)
                }
            }
            Text(
                "导航栈: ${if (stack.isEmpty()) "（空）" else stack.joinToString(" → ")}\n" +
                    "（push 后隐藏底栏，系统/导航容器自动提供返回）",
                fontSize = AppFont.sizeSm, color = AppColor.textPrimary
            )
        }

        DemoSection("D4 · 未登记标题兜底占位") {
            TextButton(onClick = {
                stack = stack + SecondaryRoutes.placeholder("未登记页面")
            }) {
                Text("push 未登记标题「未登记页面」", fontSize = AppFont.sizeSm)
            }
            Text(
                "兜底路由: ${SecondaryRoutes.PLACEHOLDER}\n" +
                    "解析结果: placeholder/未登记页面 → NativePlaceholderViewController 占位页",
                fontSize = AppFont.sizeSm, color = AppColor.textPrimary
            )
        }

        Text(
            "foundation.router = 应用内导航机制唯一出口（Tab 切换 + push/pop + 路由表集中声明 + 目标页宿主注入），" +
                "不含任何导航 UI（导航 UI 归 NavBar/Tabbar/Tabs/SideBar）。",
            fontSize = AppFont.sizeXs, color = AppColor.textSecondary
        )
    }
}
