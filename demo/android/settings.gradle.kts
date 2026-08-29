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
includeBuild("../../android")

rootProject.name = "zhiqihuayun-demo-android"
include(":app")
