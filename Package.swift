// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "ProductivitySuiteCore",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "ProductivitySuiteCore",
            targets: ["ProductivitySuiteCore"]
        )
    ],
    targets: [
        .target(name: "ProductivitySuiteCore"),
        .testTarget(
            name: "ProductivitySuiteCoreTests",
            dependencies: ["ProductivitySuiteCore"]
        )
    ]
)
