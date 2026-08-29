plugins {
    alias(libs.plugins.android.library)
    alias(libs.plugins.kotlin.android)
    alias(libs.plugins.kotlin.compose)
    alias(libs.plugins.kotlin.serialization)
    `maven-publish`
}

// 坐标：供 includeBuild 依赖替换 / GitHub Packages 发布使用，与 libs.versions.components 保持一致
group = "com.zhiqihuayun"
version = libs.versions.components.get()

android {
    namespace = "com.zhiqihuayun"
    compileSdk = 35

    defaultConfig {
        minSdk = 26
        consumerProguardFiles("consumer-rules.pro")
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    buildFeatures {
        compose = true
    }

    // 中台组件源码（保持单一来源，App 端通过移除 srcDirs 引用实现切换）
    sourceSets {
        getByName("main") {
            java.srcDirs(
                file("../foundation"),
                file("../sharedui")
            )
        }
    }
}

dependencies {
    implementation(platform(libs.androidx.compose.bom))
    implementation(libs.compose.ui.core)
    implementation(libs.compose.material3)
    implementation(libs.compose.material.icons)
    implementation(libs.androidx.navigation.compose)
    implementation(libs.retrofit)
    implementation(libs.retrofit.kotlinx.serialization)
    implementation(libs.okhttp)
    implementation(libs.kotlinx.serialization.json)
}

publishing {
    repositories {
        // GitHub Packages：发布到 maven.pkg.github.com
        // 凭据来源：gradle.properties 的 gpr.user/gpr.key，或环境变量 GITHUB_ACTOR/GITHUB_TOKEN
        maven {
            name = "GitHubPackages"
            url = uri("https://maven.pkg.github.com/${findProperty("gpr.user") ?: System.getenv("GITHUB_ACTOR") ?: "iamsunshow"}/zhiqihuayun-components")
            credentials {
                username = (findProperty("gpr.user") as String?) ?: (System.getenv("GITHUB_ACTOR") ?: "iamsunshow")
                password = (findProperty("gpr.key") as String?) ?: System.getenv("GITHUB_TOKEN").orEmpty()
            }
        }
    }
}

// AGP 的 Android software component（release）在项目评估后注册，故用 afterEvaluate 生成发布物
afterEvaluate {
    publishing {
        publications {
            register<MavenPublication>("mavenAndroid") {
                groupId = "com.zhiqihuayun"
                artifactId = "components"
                version = libs.versions.components.get()
                // 自动附加 AAR 产物 + 传递依赖 POM（compose/navigation/retrofit/okhttp/serialization）
                from(components["release"])
                pom {
                    name.set("TechMiddleOffice Android Components")
                    description.set("TMO 中台 Android 组件库（foundation + sharedui），跨 App 复用")
                    licenses {
                        license {
                            name.set("Proprietary")
                        }
                    }
                }
            }
        }
    }
}
