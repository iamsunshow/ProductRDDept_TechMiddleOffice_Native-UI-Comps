pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}

// 引用组件库本体：../../android 是 library 工程，产出 :components
// 发布坐标已改名 com.zhiqihuayun:tmo-native-ui-comps（v1.0.0），与 Gradle 工程名 components 不同，
// 自动替换按「group:工程名」匹配故需显式替换规则把新坐标指回 :components 工程
includeBuild("../../android") {
    dependencySubstitution {
        substitute(module("com.zhiqihuayun:tmo-native-ui-comps"))
            .using(project(":components"))
    }
}

rootProject.name = "zhiqihuayun-demo-android"
include(":app")
