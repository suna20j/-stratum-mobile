
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
        ),
        .executable(
            name: "StratumMobileApp",
            targets: ["StratumMobileApp"]
        )
    ],
    targets: [
        .target(
            name: "StratumMobileCore",
            path: "Sources/StratumMobileCore",
            sources: [
                "BitcoinHash.swift",
                "BitcoinHeader.swift",
                "CoinbaseBuilder.swift",
                "MerkleTree.swift",
                "MiningBenchmark.swift",
                "MiningDashboard.swift",
                "MiningEngine.swift",
                "NonceMiner.swift",
                "ShareTarget.swift",
                "StratumClient.swift",
                "StratumJob.swift",
                "StratumPoolSession.swift"
            ]
        ),
        .executableTarget(
            name: "StratumMobileApp",
            dependencies: ["StratumMobileCore"],
            path: "Sources/StratumMobileApp"
        ),
        .testTarget(
            name: "StratumMobileCoreTests",
            dependencies: ["StratumMobileCore"],
            path: "Tests/StratumMobileCoreTests"
        )
    ]
)
