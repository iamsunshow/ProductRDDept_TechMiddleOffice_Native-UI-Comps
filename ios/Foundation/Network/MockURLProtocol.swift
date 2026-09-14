/// Mock 网络拦截（URLProtocol 本地返回，与 Android `MockInterceptor` 响应体逐字符一致）。

import Foundation

/// 本地 Mock 协议：拦截全部请求并直接返回本地 JSON，不产生真实网络请求。
///
/// 挂载方式：`MockAPIClient` 默认会话已注入（`URLSessionConfiguration.protocolClasses`），
/// 对齐 Android `MockInterceptor`（OkHttp Interceptor）离线语义。
final class MockURLProtocol: URLProtocol {
    override class func canInit(with request: URLRequest) -> Bool { true }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        let path = request.url?.path.trimmingCharacters(in: CharacterSet(charactersIn: "/")) ?? ""
        let body: String
        if path == APIEndpoint.health {
            // 与 Android MockInterceptor /health 成功体一致（字段 status/service）。
            body = #"{"status":"ok","service":"keep-accounts mock"}"#
        } else {
            // 与 Android 未登记路径兜底体逐字符一致。
            body = #"{"status":"not_found","message":"\#(path)"}"#
        }
        let data = body.data(using: .utf8) ?? Data()
        let response = HTTPURLResponse(
            url: request.url ?? URL(string: "https://mock.keep-accounts.local")!,
            statusCode: 200,
            httpVersion: "HTTP/1.1",
            headerFields: ["Content-Type": "application/json"]
        )!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: data)
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}
