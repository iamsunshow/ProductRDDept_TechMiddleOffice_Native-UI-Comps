/// 网络层 Mock 客户端与环境配置（一期对接 Mock 基址）。

import Foundation
import Alamofire

/// API 基址配置（通用网络环境）。
///
/// 中台包提供 `mock` 占位环境；`current` 为可注入的当前生效环境，
/// 由宿主 App 启动时覆盖为真实后端地址。
struct APIEnvironment {
    var baseURL: URL

    /// Mock 占位（不接真实请求）。
    static let mock = APIEnvironment(baseURL: URL(string: "https://mock.keep-accounts.local")!)

    /// 当前生效环境。默认 Mock，宿主 App 启动时注入真实后端地址。
    static var current: APIEnvironment = mock
}

/// 网络客户端协议。
protocol APIClientProtocol {
    /// 请求健康检查接口。
    ///
    /// - Returns: 健康检查 DTO
    /// - Throws: 网络或解码错误
    func getHealth() async throws -> HealthDTO
}

/// Mock 网络客户端。
///
/// 只负责请求与解码；业务规则放在 Feature/Logic。
final class MockAPIClient: APIClientProtocol {
    static let shared = MockAPIClient()

    private let env: APIEnvironment
    private let session: Session

    /// 注入环境与 Alamofire 会话。
    ///
    /// - Parameters:
    ///   - env: API 环境，默认 Mock
    ///   - session: Alamofire 会话，默认 `.default`
    /// - Returns: 无
    init(env: APIEnvironment = .mock, session: Session = .default) {
        self.env = env
        self.session = session
    }

    /// GET `/health` 并解码响应。
    ///
    /// - Returns: 健康检查 DTO
    /// - Throws: 网络或解码错误
    func getHealth() async throws -> HealthDTO {
        try await session
            .request(env.baseURL.appendingPathComponent(APIEndpoint.health), method: .get)
            .serializingDecodable(HealthDTO.self)
            .value
    }
}
