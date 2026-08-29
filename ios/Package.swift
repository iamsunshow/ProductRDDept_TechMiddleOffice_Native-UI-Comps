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
        .package(url: "https://github.com/Alamofire/Alamofire.git", exact: "5.9.1"),
        .package(url: "https://github.com/groue/GRDB.swift.git", exact: "6.29.3"),
        .package(url: "https://github.com/danielgindi/Charts.git", exact: "4.1.0"),
        .package(url: "https://github.com/SnapKit/SnapKit.git", exact: "5.6.0")
    ],
    targets: [
        .target(
            name: "KeepAccountsMiddleware",
            dependencies: [
                .product(name: "Alamofire", package: "Alamofire"),
                .product(name: "GRDB", package: "GRDB.swift"),
                .product(name: "Charts", package: "Charts"),
                .product(name: "SnapKit", package: "SnapKit")
            ],
            path: ".",
            exclude: [
                "Package.swift",
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
        )
    ]
)
