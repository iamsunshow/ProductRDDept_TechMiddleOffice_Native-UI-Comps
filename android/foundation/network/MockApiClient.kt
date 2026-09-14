package com.zhiqihuayun.foundation.network

import com.zhiqihuayun.foundation.network.dto.HealthDTO
import com.zhiqihuayun.foundation.network.endpoints.ApiEndpoint
import kotlinx.serialization.json.Json
import okhttp3.Interceptor
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Protocol
import okhttp3.Response
import okhttp3.ResponseBody
import okhttp3.ResponseBody.Companion.toResponseBody
import retrofit2.Response as RetrofitResponse
import retrofit2.Retrofit
import retrofit2.converter.kotlinx.serialization.asConverterFactory
import retrofit2.http.GET
import retrofit2.http.Url

interface KeepAccountsApi {
    @GET(ApiEndpoint.HEALTH)
    suspend fun health(): HealthDTO
}

/** 原始请求出口内部通道（不对外暴露 retrofit 类型，避免依赖泄漏到宿主）。 */
internal interface RawApi {
    @GET
    suspend fun raw(@Url path: String): RetrofitResponse<ResponseBody>
}

/** 原始请求结果（状态码 + 响应体字符串，对齐 iOS `getRaw` 元组语义）。 */
data class RawResponse(
    val code: Int,
    val body: String
)

/**
 * 一期 Mock 客户端：拦截请求直接返回本地 JSON，不依赖真后端。
 *
 * - [api]：业务接口（健康检查等 DTO 解码出口）。
 * - [raw]：任意相对路径原始出口（状态码 + 响应体字符串，演示未登记路径兜底）。
 */
class MockApiClient internal constructor(
    val api: KeepAccountsApi,
    private val rawApi: RawApi
) {
    /** 请求任意相对路径（原始出口，不做 DTO 解码）。 */
    suspend fun raw(path: String): RawResponse {
        val response = rawApi.raw(path)
        return RawResponse(code = response.code(), body = response.body()?.string() ?: "")
    }

    companion object {
        fun create(): MockApiClient {
            val json = Json { ignoreUnknownKeys = true }
            val client = OkHttpClient.Builder()
                .addInterceptor(MockInterceptor(json))
                .build()
            val retrofit = Retrofit.Builder()
                .baseUrl(ApiEndpoint.BASE_URL)
                .client(client)
                .addConverterFactory(json.asConverterFactory("application/json".toMediaType()))
                .build()
            return MockApiClient(
                api = retrofit.create(KeepAccountsApi::class.java),
                rawApi = retrofit.create(RawApi::class.java)
            )
        }
    }
}

private class MockInterceptor(
    private val json: Json
) : Interceptor {
    override fun intercept(chain: Interceptor.Chain): Response {
        val path = chain.request().url.encodedPath.trim('/')
        val body = when (path) {
            ApiEndpoint.HEALTH -> json.encodeToString(
                HealthDTO.serializer(),
                HealthDTO(status = "ok", service = "keep-accounts mock")
            )
            else -> """{"status":"not_found","message":"$path"}"""
        }
        return Response.Builder()
            .request(chain.request())
            .protocol(Protocol.HTTP_1_1)
            .code(200)
            .message("OK")
            .body(body.toResponseBody("application/json".toMediaType()))
            .build()
    }
}
