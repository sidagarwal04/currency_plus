#!/bin/bash

# Build the APK
flutter build apk --release

# Rename the APK
if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
    cp build/app/outputs/flutter-apk/app-release.apk build/app/outputs/flutter-apk/currency-convert.apk
    echo "✅ APK renamed to currency-convert.apk"
    ls -lh build/app/outputs/flutter-apk/currency-convert.apk
else
    echo "❌ Error: app-release.apk not found"
fi
