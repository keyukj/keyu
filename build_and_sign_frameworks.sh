#!/bin/bash

# Complete script to build and sign Flutter frameworks for App Store submission
# This resolves ITMS-91065: Missing signature errors

set -e

echo "🚀 Building and signing Flutter frameworks for App Store..."
echo ""

# Step 1: Build frameworks
echo "📦 Step 1: Building frameworks..."
./build_framework.sh

if [ $? -ne 0 ]; then
    echo "❌ Framework build failed"
    exit 1
fi

echo ""
echo "✅ Frameworks built successfully"
echo ""

# Step 2: Sign frameworks
echo "🔐 Step 2: Signing frameworks..."
./sign_frameworks.sh

if [ $? -ne 0 ]; then
    echo "❌ Framework signing failed"
    exit 1
fi

echo ""
echo "🎉 All done! Your frameworks are ready for App Store submission."
echo ""
echo "Frameworks location: build/frameworks/Release/"
echo ""
echo "Next steps:"
echo "1. Open your iOS project in Xcode"
echo "2. Replace old frameworks with signed ones"
echo "3. Clean build folder (Cmd+Shift+K)"
echo "4. Archive and submit to App Store"
