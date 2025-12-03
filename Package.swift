// swift-tools-version: 6.0
// Momentum Finance - Personal Finance App
// Copyright © 2025 Momentum Finance. All rights reserved.

import PackageDescription

let package = Package(
    name: "MomentumFinance",
    platforms: [
        .iOS(.v18),
        .macOS(.v15)
    ],
    products: [
        .library(
            name: "MomentumFinance",
            targets: ["MomentumFinanceCore", "Shared"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "MomentumFinanceCore",
            dependencies: [],
            path: "Sources/MomentumFinanceCore",
            resources: [],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),
        .target(
            name: "Shared",
            dependencies: ["MomentumFinanceCore"],
            path: "Shared",
            exclude: ["Package.swift", ".build", "README.md"],
            resources: [],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "MomentumFinanceTests",
            dependencies: ["MomentumFinanceCore", "Shared"],
            path: "MomentumFinanceTests"
        )
    ]
)
