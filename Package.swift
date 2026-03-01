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
        ),
        .executable(
            name: "BudgetAudit",
            targets: ["BudgetAudit"]
        )
    ],
    dependencies: [
        sharedKitDependency,
        .package(url: "https://github.com/apple/swift-crypto.git", "3.0.0"..<"5.0.0"),
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
        .executableTarget(
            name: "BudgetAudit",
            dependencies: ["MomentumFinanceCore"],
            path: "Tools",
            exclude: [
                "ProjectScripts",
                "Automation",
                "AddSharedToCore.swift",
                "add_app_files_to_target.py",
                "add_file_ref.py",
                "add_macos_files.py",
                "add_tests_to_target.py",
                "batch_import_files.py",
                "check_app_file_count.py",
                "check_build_links.py",
                "check_encoding_and_header.py",
                "check_test_membership.py",
                "clean_pbxproj_garbage.py",
                "cleanup_broken_lines.py",
                "cleanup_duplicates.py",
                "clone_configs.py",
                "deduplicate_app_sources.py",
                "fix_file_path.py",
                "fix_macos_test_host.py",
                "fix_missing_commas.py",
                "fix_shared_group_end.py",
                "fix_target_settings.py",
                "fix_test_compilation.py",
                "fix_test_host.py",
                "fix_ui_list.py",
                "force_add_app_files.py",
                "get_missing_files.py",
                "import_missing_files.py",
                "inspect_chunk.py",
                "isolate_shared.py",
                "isolate_sources.py",
                "nuke_ids.py",
                "prune_broken_tests.py",
                "remove_ghost_files.py",
                "remove_ui_force.py",
                "remove_ui_target.py",
                "repair_braces.py",
                "revert_import.py",
                "test_fix_header.py",
                "validate_assignments.py",
                "validate_pbxproj_structure.py",
                "wrap_mac_tests.py"
            ],
            sources: ["BudgetAudit.swift"]
        ),
        .testTarget(
            name: "MomentumFinanceCoreTests",
            dependencies: ["MomentumFinanceCore"],
            path: "Tests/MomentumFinanceCoreTests"
        ),
    ]
)
