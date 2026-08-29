/// 健康检查接口 DTO，与 OpenAPI `/health` 对齐。

import Foundation

/// 健康检查响应体。
///
/// 禁止直接作为 UI 模型使用。
struct HealthDTO: Decodable {
    let status: String
    let service: String
}
