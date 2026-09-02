// swift-tools-version: 5.7
// 中台 iOS 组件包 —— 独立 Swift Package，供宿主 App 以 SPM 或 xcframework 方式引用。
//
// 覆盖：Foundation（网络/存储/路由/设计/工具）+ SharedUI（通用 UI 组件）。
// 业务差异（目标页/表结构/后端地址）由宿主经 provider 注入，本包不依赖任何业务代码。

import PackageDescription

let package = Package(
    name: "KeepAccountsMiddleware",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(name: "KeepAccountsMiddleware", targets: ["KeepAccountsMiddleware"])
    ],
    dependencies: [
        // v1.30c 根治 SwiftPM 缓存漂移：全部依赖改为 Vendor 本地路径引用。
        // 旧问题：依赖同时以「远程 URL exact」+「Vendor 本地 clone」两份同包名存在，
        // SwiftPM 从远程 URL checkout 到 .build/checkouts/<Package>/ 作为实际解析源，
        // 本地 Vendor/Charts/Package.swift 修复的脏字符不生效，导致反复报
        // "Extra arguments at positions #3, #4 / Reference to member 'produ' cannot be resolved"。
        // 改为本地 .package(path:) 后，整条链路闭环（Charts → swift-algorithms → swift-numerics
        // 均为相对本地路径），SwiftPM 直接读取 Vendor/ 下物理文件，无远程 cache 命中机会。
        .package(path: "Vendor/Alamofire"),
        .package(path: "Vendor/GRDB.swift"),   // 自身 Package.swift name="GRDB"，targets 引用名见下方
        .package(path: "Vendor/Charts"),        // 内部依赖 .package(path: "../swift-algorithms")，已闭合
        .package(path: "Vendor/SnapKit"),
    ],
    targets: [
        .target(
            name: "KeepAccountsMiddleware",
            dependencies: [
                .product(name: "Alamofire", package: "Alamofire"),
                // GRDB.swift/Package.swift 自身 name 字段 = "GRDB"（非目录名 GRDB.swift），
                // 本地路径依赖以 Package.swift 的 name 字段为 package 引用键，必须匹配。
                .product(name: "GRDB", package: "GRDB"),
                .product(name: "Charts", package: "Charts"),
                .product(name: "SnapKit", package: "SnapKit")
            ],
            path: ".",
            exclude: [
                "Package.swift",
                "Package.resolved",
                "Tests",
                // SPM 自身解析产物（不在 sources 目录内，仍需显式排除以避免资源扫描重复）。
                ".build",
                // 记账业务组件（引用 App Feature 领域类型，不属于通用中台，由 App 本地编译）：
                "SharedUI/Components/CategoryPickerView.swift",
                "SharedUI/Components/PeriodTabsView.swift",
                "SharedUI/Components/TrendChartView.swift",
                "SharedUI/Components/ZodiacAvatarView.swift"
            ],
            sources: [
                "Foundation",
                "SharedUI"
            ]
        ),
        .testTarget(
            name: "KeepAccountsMiddlewareTests",
            dependencies: ["KeepAccountsMiddleware"],
            path: "Tests"
        )
    ]
)
