// swift-tools-version: 6.2
// Momentum Finance - Personal Finance App
// Copyright © 2025 Momentum Finance. All rights reserved.

import Foundation
import PackageDescription

private let localSharedKitPath = "../shared-kit"
private let sharedKitDependency: Package.Dependency = FileManager.default.fileExists(atPath: localSharedKitPath)
    ? .package(path: localSharedKitPath)
    : .package(url: "https://github.com/dboone323/shared-kit.git", branch: "main")

private let coreExcludedSources: [String] = {
    #if os(Linux)
        return [
            "Services/BiometricAuth.swift",
            "Services/BiometricAuthManager.swift",
            "Services/BudgetAlerts.swift",
            "Services/BudgetAgent.swift",
            "Services/ReceiptScanner.swift",
            "Services/SecurityIntegrationExample.swift",
            "Services/ThemeManager.swift",
            "Utilities/ErrorHandler.swift",
        ]
    #else
        return []
    #endif
}()

let package = Package(
    name: "MomentumFinance",
    platforms: [
        .iOS(.v18),
        .macOS(.v15),
    ],
    products: [
        .library(
            name: "MomentumFinance",
            targets: ["MomentumFinanceCore", "Shared"]
        )
    ],
    dependencies: [
        sharedKitDependency,
        .package(url: "https://github.com/apple/swift-crypto.git", from: "3.0.0"),
    ],
    targets: [
        .target(
            name: "MomentumFinanceCore",
            dependencies: [
                .product(
                    name: "SharedKit",
                    package: "shared-kit",
                    condition: .when(platforms: [.iOS, .macOS])
                ),
                .product(
                    name: "Crypto",
                    package: "swift-crypto",
                    condition: .when(platforms: [.linux])
                )
            ],
            path: "Sources/MomentumFinanceCore",
            exclude: coreExcludedSources,
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
