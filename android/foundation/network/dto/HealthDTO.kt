package com.zhiqihuayun.foundation.network.dto

import kotlinx.serialization.Serializable

@Serializable
data class HealthDTO(
    val status: String = "ok",
    val message: String = "mock"
)
