// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "StratumMobile",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "StratumMobileCore",
            targets: ["StratumMobileCore"]
        )
    ],
    targets: [
        .target(
            name: "StratumMobileCore",
            path: "Sources/StratumMobileCore"
        ),
        .testTarget(
            name: "StratumMobileCoreTests",
            dependencies: ["StratumMobileCore"],
            path: "Tests/StratumMobileCoreTests"
        )
    ]
)
