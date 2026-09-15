// swift-tools-version: 5.7
// 中台 iOS 组件包 —— 独立 Swift Package，供宿主 App 以 SPM 远程引用或 xcframework 方式引用。
// 包名/产品名 tmo-native-ui-comps（TMO=TechMiddleOffice，2026-09-15 由历史遗留名 KeepAccountsMiddleware 改名）；
// Swift 模块名 TMONativeUIComps（import TMONativeUIComps）。
//
// 清单位置（v2.0.1 变更 · 2026-09-15）：由 ios/Package.swift 迁至「仓库根目录 Package.swift」。
// 原因：SwiftPM 对 git 依赖只认仓库根目录的 Package.swift（不支持「子目录即一个包」），
// 清单留在 ios/ 子目录时宿主无法写 .package(url: "….git", exact: "…") 远程引用，
// 只能先 clone 全仓再以本地路径引用——等于没走远程依赖。
// 迁到根后宿主可远程按 tag 固定引用；相应地本文件内的 target 路径由「相对 ios/」改为「相对仓库根」。
//
// 第二条硬约束（v2.0.1 实测确立，务必牢记）：SwiftPM 不允许「被别人以 URL 引用的包」声明本地 path 依赖。
// 因此本包对外可分发的形态**不能**使用 .package(path: "ios/Vendor/…")（哪怕加 "./" 前缀也不行），
// 第三方依赖必须写远程 URL——见下方 dependencies 注释。
//
// 覆盖：Foundation（网络/存储/路由/设计/工具）+ SharedUI（通用 UI 组件）。
// 业务差异（目标页/表结构/后端地址）由宿主经 provider 注入，本包不依赖任何业务代码。

import PackageDescription

let package = Package(
    name: "tmo-native-ui-comps",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(name: "tmo-native-ui-comps", targets: ["TMONativeUIComps"])
    ],
    dependencies: [
        // v2.0.1 依赖声明由「Vendor 本地 path」改回「远程 URL」，与宿主 KeepAccounts 的声明同 URL 同版本区间，
        // 依赖图里 identity 相同 → SwiftPM 归一为一份，不会重复引入。
        //
        // 铁律（v2.0.1 实测确立）：SwiftPM 不允许「被别人以 URL 引用的包」声明本地 path 依赖
        // （.package(path:) 只能由根包/工作区清单声明）。宿主按 url 拉本包时会在清单校验阶段直接失败：
        //   Invalid manifest: 'ios/Vendor/Alamofire' is not a valid path for path-based dependencies;
        //   use relative or absolute path instead.
        // 而本地 xcodebuild / swift package dump-package **不报此错**（清单来自工作区），
        // 属「本地编译通过、宿主远程引用失败」的隐藏坑——加 "./" 前缀亦不能绕过。
        // 历史 v1.30c 的 Vendor 本地 path 方案因此无法用于远程分发；ios/Vendor 目录保留，
        // 供 demo 工程（root 工程，允许 path 依赖）与离线参考使用。
        // 宿主侧本就已远程拉取 Alamofire/GRDB/Charts/SnapKit/Kingfisher，故本改动不新增联网前提。
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.9.1"),
        .package(url: "https://github.com/groue/GRDB.swift.git", from: "6.29.3"),
        // 与宿主保持同一 URL（ChartsOrg/Charts）：若写成 danielgindi/Charts，同 identity 但 URL 分叉，
        // 依赖图可能出现两份引用并触发解析冲突。
        .package(url: "https://github.com/ChartsOrg/Charts.git", from: "4.1.0"),
        .package(url: "https://github.com/SnapKit/SnapKit.git", from: "5.6.0"),
    ],
    targets: [
        .target(
            name: "TMONativeUIComps",
            dependencies: [
                .product(name: "Alamofire", package: "Alamofire"),
                // GRDB 的 package 引用键 = 仓库名 GRDB.swift（identity 由 URL 末段推导，大小写不敏感），
                // product 名 = GRDB。写成 package: "GRDB" 会报 unknown package。
                .product(name: "GRDB", package: "GRDB.swift"),
                .product(name: "Charts", package: "Charts"),
                .product(name: "SnapKit", package: "SnapKit")
            ],
            path: "ios",
            exclude: [
                // Vendor：v2.0.1 起已不参与本包依赖解析（依赖走远程 URL，见上），仅保留作
                // demo 工程（root 工程，允许 path 依赖）与离线参考；其仓库自带 Demo App 资源
                // （如 GRDB.swift/Documentation/DemoApps 的 storyboard/xcassets/xcdatamodeld）
                // 若不排除会被当主 target 资源扫描，报 multiple resources 重复错误。
                "Vendor",
                // SPM 自身解析产物（不在 sources 目录内，仍需显式排除以避免资源扫描重复）。
                ".build",
                // xcodebuild 派生数据/归档目录（本地构建产物，不入库）。
                "build",
                // 单测源码由下方 testTarget 管理。
                "Tests",
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
            name: "TMONativeUICompsTests",
            dependencies: ["TMONativeUIComps"],
            path: "ios/Tests"
        )
    ]
)
