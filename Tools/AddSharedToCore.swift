//
//  AddSharedToCore.swift
//  Tools
//
//  Created by Automation on 2025-12-24.
//

import Foundation

// Script to modify project.pbxproj to add Shared files to MomentumFinanceCore target

let projectPath = "MomentumFinance/MomentumFinance.xcodeproj/project.pbxproj"
let sharedPath = "MomentumFinance/Shared"
let coreTargetName = "MomentumFinanceCore"

func run() {
    let url = URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent(projectPath)
    guard var content = try? String(contentsOf: url, encoding: .utf8) else {
        print("Error: Could not read project file")
        exit(1)
    }

    // Find the Core target ID
    // 52F6B3356E214580BF28E730 /* MomentumFinanceCore */
    guard let coreTargetRange = content.range(
        of: "\\/\\* MomentumFinanceCore \\*\\/ = \\{[^\\}]*buildPhases = \\(([^\\)]*)\\)",
        options: .regularExpression
    ) else {
        print("Error: Could not find MomentumFinanceCore target")
        exit(1)
    }

    // Find the Sources build phase ID for Core
    let buildPhasesBlock = String(content[coreTargetRange])
    // 082010CC617947138385A238 /* Sources */,
    guard let sourcesPhaseMatch = buildPhasesBlock.range(
        of: "([A-Z0-9]{24}) /\\* Sources \\*/",
        options: .regularExpression
    ) else {
        print("Error: Could not find Sources build phase for Core")
        exit(1)
    }
    let sourcesBuildPhaseId = String(buildPhasesBlock[sourcesPhaseMatch]).components(separatedBy: " ")[0]

    print("Found Core Sources Build Phase ID: \(sourcesBuildPhaseId)")

    // Find all PBXBuildFile entries for Shared files
    // We need to duplicate these entries but make sure we don't duplicate file references
    // Or simpler: just find all file references in 'Shared' group and add them to Core sources build phase

    // Strategy: Manual xcodebuild manipulation is hard via regex.
    // Better strategy: Use 'ruby xcodeproj' if available, otherwise just use xcodebuild to add them? No xcodebuild
    // can't add files.

    print("This script is complex to implement safely with regex. Aborting manual pbxproj edit.")
}

run()
