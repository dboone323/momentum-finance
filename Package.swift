// swift-tools-version: 6.2
// Momentum Finance - Personal Finance App
// Copyright © 2025 Momentum Finance. All rights reserved.

import PackageDescription

let package = Package(
    name: "MomentumFinance",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(
            name: "MomentumFinance",
            targets: ["MomentumFinanceCore", "Shared"]
        )
    ],
    dependencies: [
        .package(path: "../shared-kit")
    ],
    targets: [
        .target(
            name: "MomentumFinanceCore",
            dependencies: [
                .product(name: "SharedKit", package: "shared-kit")
            ],
            path: "Sources/MomentumFinanceCore",
            resources: [],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),
        .target(
            name: "Shared",
            dependencies: [
                "MomentumFinanceCore",
                .product(name: "SharedKit", package: "shared-kit"),
                .product(name: "EnterpriseScalingFramework", package: "shared-kit"),
            ],
            path: "Sources/MomentumFinanceShared",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),
    ]
)
