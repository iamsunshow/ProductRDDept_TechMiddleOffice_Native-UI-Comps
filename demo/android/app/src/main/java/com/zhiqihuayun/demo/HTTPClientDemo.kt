package com.zhiqihuayun.demo

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
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
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import com.zhiqihuayun.foundation.design.AppColor
import com.zhiqihuayun.foundation.design.AppFont
import com.zhiqihuayun.foundation.design.AppSpace
import com.zhiqihuayun.foundation.network.MockApiClient
import com.zhiqihuayun.foundation.network.endpoints.ApiEndpoint
import kotlinx.coroutines.launch

/**
 * HTTPClient 网络 Demo（foundation.http-client #94）。
 * 4 组排查：①健康检查（/health）②环境配置（baseURL + 环境名）
 * ③未登记路径 not_found ④请求回执（状态码 + 耗时 + 响应体预览）。
 * 全程本地 Mock 拦截（MockInterceptor），离线可成功（不依赖真后端）。
 */
@Composable
fun HTTPClientDemo() {
    val scope = rememberCoroutineScope()
    var health by remember { mutableStateOf("（未请求）") }
    var notFound by remember { mutableStateOf("（未请求）") }
    var receipt by remember { mutableStateOf("（未请求）") }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(horizontal = AppSpace.lg, vertical = AppSpace.md),
        verticalArrangement = Arrangement.spacedBy(AppSpace.lg)
    ) {
        DemoSection("D1 · 健康检查（/health）") {
            TextButton(onClick = {
                scope.launch {
                    runCatching { MockApiClient.create().api.health() }
                        .onSuccess { health = "status = ${it.status}\nservice = ${it.service}" }
                        .onFailure { health = "请求失败: ${it.message}" }
                }
            }) { Text("GET /health", fontSize = AppFont.sizeSm) }
            Text(health, fontSize = AppFont.sizeSm, color = AppColor.textPrimary)
        }

        DemoSection("D2 · 环境配置（baseURL + 环境名）") {
            Text(
                "环境: mock（一期对接 Mock 基址）\n" +
                    "baseURL = ${ApiEndpoint.BASE_URL}\n" +
                    "（宿主接入真实后端时替换 BASE_URL 常量；" +
                    "iOS 侧为 APIEnvironment.current 运行期注入，接入差异表已放行）",
                fontSize = AppFont.sizeSm, color = AppColor.textPrimary
            )
        }

        DemoSection("D3 · 未登记路径（not_found）") {
            TextButton(onClick = {
                scope.launch {
                    runCatching { MockApiClient.create().raw("unknown_demo_path") }
                        .onSuccess { notFound = "HTTP ${it.code}\n${it.body}" }
                        .onFailure { notFound = "请求失败: ${it.message}" }
                }
            }) { Text("GET /unknown_demo_path", fontSize = AppFont.sizeSm) }
            Text(notFound, fontSize = AppFont.sizeSm, color = AppColor.textPrimary)
        }

        DemoSection("D4 · 请求回执（状态码 + 耗时 + 响应体预览）") {
            TextButton(onClick = {
                scope.launch {
                    val start = System.currentTimeMillis()
                    runCatching { MockApiClient.create().raw("health") }
                        .onSuccess { response ->
                            val elapsed = System.currentTimeMillis() - start
                            receipt = "状态码: HTTP ${response.code}\n" +
                                "耗时: ${elapsed}ms（本地拦截）\n" +
                                "响应体预览: ${response.body.take(80)}"
                        }
                        .onFailure { receipt = "请求失败: ${it.message}" }
                }
            }) { Text("GET /health（原始回执）", fontSize = AppFont.sizeSm) }
            Text(receipt, fontSize = AppFont.sizeSm, color = AppColor.textPrimary)
        }

        Text(
            "foundation.http-client = 网络请求层（客户端 + 环境配置 + Mock 拦截骨架），" +
                "一期仅健康检查 + 任意路径原始出口，业务接口在 Feature 模块按需扩展；" +
                "对齐 iOS MockAPIClient（响应体逐字符一致）。",
            fontSize = AppFont.sizeXs, color = AppColor.textSecondary
        )
    }
}
