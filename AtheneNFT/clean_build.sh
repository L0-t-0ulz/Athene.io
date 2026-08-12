#!/bin/bash
set -euo pipefail

# Run from the directory containing AtheneNFT.xcodeproj
cd "$(dirname "$0")"

echo "Cleaning AtheneNFT project..."

# Remove derived data
rm -rf ~/Library/Developer/Xcode/DerivedData/AtheneNFT-*

# Remove build folder
rm -rf build/

# Clean Xcode project
if ! xcodebuild clean -project AtheneNFT.xcodeproj -scheme AtheneNFT; then
    echo "error: xcodebuild clean failed" >&2
    exit 1
fi

echo "Clean completed. Please rebuild the project in Xcode."
