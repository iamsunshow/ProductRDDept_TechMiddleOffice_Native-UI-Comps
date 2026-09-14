# HTTPClient 网络客户端 · 门禁 A 评审单（任务清单 #94 · 未评审组件补齐批）

> 组件 ID：`foundation.http-client` ｜ 设计规格：`design-spec/http-client-design-spec.html`
> 评审方式：🖊 AI 代评（用户 2026-09-04 总授权；2026-09-14「2.0的组件本次不开发，优先开发未评审的组件」指示接棒）
> 评审日期：2026-09-14 ｜ 组件库版本：v1.4.0 ｜ 终核：并入用户 C1.5 Demo 实机验收

## 评审清单

| # | 项 | 判定 | 说明 |
| - | -- | --- | --- |
| A1 | 组件边界（SCQA） | ✅ | 定位=统一网络层（客户端构建 + 环境基址 + 一期 Mock），只请求与解码；与业务 API 划界=接口/DTO 归宿主扩展；与鉴权划界=二期；与日志埋点划界=二期 |
| A2 | Token 零硬编码 | ✅ | 纯逻辑层（无视觉输出），无 token 依赖；Demo 展示层用令牌渲染 |
| A3 | 决策投票表 | ✅ | P1-A 各用平台主流库（iOS Alamofire / Android OkHttp+Retrofit）；P2-A **iOS 新增 <code>MockURLProtocol</code> 本地拦截补缺口**（当前 <code>mock.keep-accounts.local</code> 不解析，Demo 无法展示成功）；P3-A 未知路径返回 200 + <code>not_found</code> JSON（对齐 Android 现状，逐字符一致）；P4-A 一期=客户端+环境+Mock+Demo 4 段 |
| A4 | Demo 排查 4 组 | ✅ | D1 健康检查（<code>/health</code> 成功体）/ D2 环境配置（baseURL + 环境名 + 切换回显）/ D3 未登记路径（<code>not_found</code> 体）/ D4 请求回执（状态码 200 + 耗时 + 响应体预览）。**全部离线路由，不产生真实网络请求** |
| A5 | 实现现状 | ⚠ **双端 Mock 行为不对等（本轮补齐）** | iOS `ios/Foundation/Network/MockAPIClient.swift`（Alamofire <code>MockAPIClient.shared</code> + <code>APIEnvironment</code> + <code>APIClientProtocol.getHealth()</code>，已实现，但 mock 域名不可达）；（iOS Endpoints/DTO 已具备）；Android `android/foundation/network/MockApiClient.kt`（OkHttp+Retrofit+<code>MockInterceptor</code> 本地返回 JSON + <code>KeepAccountsApi.health()</code>，已实现且离线可用）。**缺口=iOS Mock 通道不可离线成功，本轮补 <code>MockURLProtocol</code>** |
| A6 | 平台差异表 | ✅ | 表内放行：HTTP 栈（Alamofire vs OkHttp+Retrofit）、序列化（Codable vs kotlinx.serialization）、Mock 实现（URLProtocol 拦截 vs Interceptor 拦截，响应体逐字符一致）、环境配置（APIEnvironment.current vs ApiEndpoint.BASE_URL）、并发模型（async/await vs suspend） |
| A7 | anti_goals 反目标 | ✅ | 鉴权/Token 刷新=二期；重试/断线队列=二期；请求日志面板=非目标；证书固定=二期 |

## 评审结论

| 项 | 内容 |
| -- | --- |
| 结论 | ✅ 通过（P1–P4 全 A，0 保留意见；含 iOS Mock 缺口补齐决策） |
| 用户签字 | （终核并入用户 C1.5 Demo 实机验收） |
| 下一步 | 新增 iOS `MockURLProtocol.swift`（本地拦截）→ 双端 Demo（HTTPClientShowcase / HTTPClientDemo 4 段 1:1）→ api.json 补 reviewed+subcategory → demo 注册行 planned→reviewed → C1.5 验收 |
