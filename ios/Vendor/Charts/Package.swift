// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "Charts",
    platforms: [
          .iOS(.v12),
          .tvOS(.v12),
          .macOS(.v10_12),
    ],
    products: [
        .library(
            name: "Charts",
            targets: ["Charts"]),
        .library(
            name: "ChartsDynamic",
            type: .dynamic,
            targets: ["Charts"])
    ],
    dependencies: [
        .package(path: "../swift-algorithms")
    ],
    targets: [
        .target(
            name: "Charts",
            dependencies: [.product(name: "Algorithms", package: "swift-algorithms")],
            path: "Source/Charts"
        )
    ],
    swiftLanguageVersions: [.v5]
)
