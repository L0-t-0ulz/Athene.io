#!/bin/bash

# This script generates all required iOS app icon sizes from a 1024x1024 source image
# Usage: ./generate_app_icons.sh source_icon.png

if [ -z "$1" ]; then
    echo "Usage: ./generate_app_icons.sh source_icon.png"
    echo "Please provide a 1024x1024 PNG image as the source"
    exit 1
fi

SOURCE_IMAGE="$1"
OUTPUT_DIR="AtheneNFT/AtheneNFT/Assets.xcassets/AppIcon.appiconset"

# Check if source image exists
if [ ! -f "$SOURCE_IMAGE" ]; then
    echo "Error: Source image '$SOURCE_IMAGE' not found"
    exit 1
fi

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

echo "Generating app icons from $SOURCE_IMAGE..."

# Generate all required sizes
sips -z 20 20 "$SOURCE_IMAGE" --out "$OUTPUT_DIR/AppIcon-20.png"
sips -z 29 29 "$SOURCE_IMAGE" --out "$OUTPUT_DIR/AppIcon-29.png"
sips -z 40 40 "$SOURCE_IMAGE" --out "$OUTPUT_DIR/AppIcon-40.png"
sips -z 58 58 "$SOURCE_IMAGE" --out "$OUTPUT_DIR/AppIcon-58.png"
sips -z 60 60 "$SOURCE_IMAGE" --out "$OUTPUT_DIR/AppIcon-60.png"
sips -z 76 76 "$SOURCE_IMAGE" --out "$OUTPUT_DIR/AppIcon-76.png"
sips -z 80 80 "$SOURCE_IMAGE" --out "$OUTPUT_DIR/AppIcon-80.png"
sips -z 87 87 "$SOURCE_IMAGE" --out "$OUTPUT_DIR/AppIcon-87.png"
sips -z 120 120 "$SOURCE_IMAGE" --out "$OUTPUT_DIR/AppIcon-120.png"
sips -z 152 152 "$SOURCE_IMAGE" --out "$OUTPUT_DIR/AppIcon-152.png"
sips -z 167 167 "$SOURCE_IMAGE" --out "$OUTPUT_DIR/AppIcon-167.png"
sips -z 180 180 "$SOURCE_IMAGE" --out "$OUTPUT_DIR/AppIcon-180.png"

# App Store
cp "$SOURCE_IMAGE" "$OUTPUT_DIR/AppIcon-1024.png"

echo "✅ App icons generated successfully!"
echo "📁 Icons saved to: $OUTPUT_DIR"
echo ""
echo "Required icon sizes generated:"
echo "- AppIcon-20.png (20x20)"
echo "- AppIcon-29.png (29x29)"
echo "- AppIcon-40.png (40x40)"
echo "- AppIcon-58.png (58x58)"
echo "- AppIcon-60.png (60x60)"
echo "- AppIcon-76.png (76x76)"
echo "- AppIcon-80.png (80x80)"
echo "- AppIcon-87.png (87x87)"
echo "- AppIcon-120.png (120x120)"
echo "- AppIcon-152.png (152x152)"
echo "- AppIcon-167.png (167x167)"
echo "- AppIcon-180.png (180x180)"
echo "- AppIcon-1024.png (1024x1024)"