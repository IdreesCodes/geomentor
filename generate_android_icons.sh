#!/bin/bash

# Generate Android app icons from GeoMentor.png
SOURCE_IMAGE="assets/images/GeoMentor.png"
ANDROID_DIR="android/app/src/main/res"

# Create all required Android icon sizes
sips -z 48 48 "$SOURCE_IMAGE" --out "$ANDROID_DIR/mipmap-mdpi/ic_launcher.png"
sips -z 72 72 "$SOURCE_IMAGE" --out "$ANDROID_DIR/mipmap-hdpi/ic_launcher.png"
sips -z 96 96 "$SOURCE_IMAGE" --out "$ANDROID_DIR/mipmap-xhdpi/ic_launcher.png"
sips -z 144 144 "$SOURCE_IMAGE" --out "$ANDROID_DIR/mipmap-xxhdpi/ic_launcher.png"
sips -z 192 192 "$SOURCE_IMAGE" --out "$ANDROID_DIR/mipmap-xxxhdpi/ic_launcher.png"

echo "All Android app icons generated successfully!"

