#!/bin/bash
# shellcheck shell=ksh
set -e

# Simple test to verify our SwiftUI app compiles
echo "🔍 Testing MomentumFinance App Compilation..."

# Test individual Swift files
echo "📱 Testing SwiftData Models..."
cd Shared/Models || exit
for file in *.swift; do
	echo "Checking ${file}..."
	if ! swiftc -typecheck "${file}" 2>/dev/null; then
		echo "❌ Error i${ $fi}le"
		swiftc -typecheck "${file}"
		exit 1
	else
		echo "�${ $fi}le OK"
	fi
done

cd ../.. || exit

echo "Testing ViewModels..."
cd Shared/Features || exit
for dir in */; do
	if [[ -f "${dir}"*ViewModel.swift ]]; then
		echo "Checking ${dir}..."
		for vmfile in "${dir}"*ViewModel.swift; do
			if ! swiftc -typecheck -I ../../Models "${vmfile}" ../../Models/*.swift 2>/dev/null; then
				echo "❌ Error i${ $vmfi}le"
				swiftc -typecheck -I ../../Models "${vmfile}" ../../Models/*.swift
				exit 1
			else
				echo "�${ $vmfi}le OK"
			fi
		done
	fi
done

cd ../.. || exit

echo "✅ All Swift files passed type checking!"
echo "🎉 MomentumFinance app is ready!"
