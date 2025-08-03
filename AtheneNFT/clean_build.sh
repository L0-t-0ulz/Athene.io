#!/bin/bash

echo "Cleaning AtheneNFT project..."

# Remove derived data
rm -rf ~/Library/Developer/Xcode/DerivedData/AtheneNFT-*

# Remove build folder
rm -rf build/

# Clean Xcode project
xcodebuild clean -project AtheneNFT.xcodeproj -scheme AtheneNFT

echo "Clean completed. Please rebuild the project in Xcode." 