#!/bin/bash
# Script to add all missing Swift files to the Xcode project
# Created for Momentum Finance App

# Define paths
PROJECT_FILE="/Users/danielstevens/github-projects/tools-automation/MomentumFinance/MomentumFinance.xcodeproj/project.pbxproj"
BACKUP_FILE="${PROJECT_FILE}.backup_$(date +%s)"

# Backup current project file
cp "${PROJECT_FILE}" "${BACKUP_FILE}"
echo "Project file backed up to: ${BACKUP_FILE}"

# List of missing files to add
declare -a MISSING_FILES=(
    "/Users/danielstevens/github-projects/tools-automation/MomentumFinance/Sources/MomentumFinanceCore/DataExporter.swift"
    "/Users/danielstevens/github-projects/tools-automation/MomentumFinance/Sources/MomentumFinanceCore/DataImporter.swift"
    "/Users/danielstevens/github-projects/tools-automation/MomentumFinance/Sources/MomentumFinanceCore/ImportExportTypes.swift"
    "/Users/danielstevens/github-projects/tools-automation/MomentumFinance/Sources/MomentumFinanceCore/CSVParsing.swift"
	"/Users/danielstevens/github-projects/tools-automation/MomentumFinance/Shared/Features/Dashboard/InsightsFilterBar.swift"
)

echo "Preparing to add missing files to Xcode project..."

# Helper functions
function generate_uuid() {
	python3 -c 'import uuid; print(str(uuid.uuid4()).upper().replace("-", ""))'
}

# For each missing file, add it to the Xcode project
for file_path in "${MISSING_FILES[@]}"; do
	if [[ -f "${file_path}" ]]; then
		file_name=$(basename "${file_path}")

		# Generate UUIDs for the file reference and build file reference
		file_ref_uuid=$(generate_uuid)
		build_file_uuid=$(generate_uuid)

		echo "Adding ${file_name} to project..."

		# Step 1: Add file reference
		file_ref="		${file_ref_uuid} /* ${file_name} */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = \"${file_name}\"; sourceTree = \"<group>\"; };"

		# Step 2: Add build file
		build_file="		${build_file_uuid} /* ${file_name} in Sources */ = {isa = PBXBuildFile; fileRef = ${file_ref_uuid} /* ${file_name} */; };"

		# Add entries to project.pbxproj
		# This is a simplified approach - for a comprehensive solution, parsing the Xcode project would be better

		# Find the PBXFileReference section and append
		sed -i '' "/Begin PBXFileReference section \*\//a\\
${file_ref}
" "${PROJECT_FILE}"

		# Find the PBXBuildFile section and append
		sed -i '' "/Begin PBXBuildFile section \*\//a\\
${build_file}
" "${PROJECT_FILE}"

		echo "Adding source reference for ${file_name} to sources build phase"
		# Add the build file reference to the sources build phase
		sed -i '' "/Begin PBXSourcesBuildPhase section/a\\
                ${build_file_uuid} /* ${file_name} in Sources */,\
+" "${PROJECT_FILE}"
		echo "Added source reference for ${file_name}"
		echo "Added ${file_name} to project"
	else
		echo "Warning: File not found: ${file_path}"
	fi
done

echo "Missing files added to Xcode project. You should now open Xcode and verify the additions."
echo "Next steps: 1) Organize files into proper groups in Xcode"
echo "            2) Set target membership for each file"
echo "            3) Ensure all imports resolve properly"
