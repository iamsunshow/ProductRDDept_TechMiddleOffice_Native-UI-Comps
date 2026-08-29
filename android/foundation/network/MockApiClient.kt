package com.zhiqihuayun.foundation.network

import com.zhiqihuayun.foundation.network.dto.HealthDTO
import com.zhiqihuayun.foundation.network.endpoints.ApiEndpoint
import kotlinx.serialization.json.Json
import okhttp3.Interceptor
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Protocol
import okhttp3.Response
import okhttp3.ResponseBody.Companion.toResponseBody
import retrofit2.Retrofit
import retrofit2.converter.kotlinx.serialization.asConverterFactory
import retrofit2.http.GET

interface KeepAccountsApi {
    @GET(ApiEndpoint.HEALTH)
    suspend fun health(): HealthDTO
}

/**
 * 一期 Mock 客户端：拦截请求直接返回本地 JSON，不依赖真后端。
 */
class MockApiClient(
    val api: KeepAccountsApi
) {
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
            return MockApiClient(retrofit.create(KeepAccountsApi::class.java))
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
                HealthDTO(status = "ok", message = "keep-accounts mock")
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
