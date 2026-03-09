#!/bin/bash

# Script to sign Flutter frameworks for App Store submission
# This resolves ITMS-91065: Missing signature errors

set -e

echo "🔐 Starting framework signing process..."

# Path to the frameworks directory
FRAMEWORKS_DIR="build/frameworks/Release"

# Check if frameworks directory exists
if [ ! -d "$FRAMEWORKS_DIR" ]; then
    echo "❌ Error: Frameworks directory not found at $FRAMEWORKS_DIR"
    echo "Please run ./build_framework.sh first to generate frameworks"
    exit 1
fi

# Get the codesigning identity
# You can specify your identity or let it auto-detect
if [ -z "$CODESIGN_IDENTITY" ]; then
    # Try to find Apple Distribution certificate first (for App Store)
    CODESIGN_IDENTITY=$(security find-identity -v -p codesigning | grep "Apple Distribution" | head -1 | awk -F'"' '{print $2}')
    
    # If not found, try Apple Development certificate
    if [ -z "$CODESIGN_IDENTITY" ]; then
        CODESIGN_IDENTITY=$(security find-identity -v -p codesigning | grep "Apple Development" | head -1 | awk -F'"' '{print $2}')
    fi
    
    # If still not found, show error
    if [ -z "$CODESIGN_IDENTITY" ]; then
        echo "❌ Error: No valid codesigning identity found"
        echo "Please install a valid Apple Distribution or Apple Development certificate"
        exit 1
    fi
fi

echo "📝 Using codesigning identity: $CODESIGN_IDENTITY"
echo ""

# Sign each framework
for framework in "$FRAMEWORKS_DIR"/*.xcframework; do
    if [ -d "$framework" ]; then
        framework_name=$(basename "$framework")
        
        # Skip Flutter.xcframework as it's already signed by Flutter team
        if [ "$framework_name" = "Flutter.xcframework" ]; then
            echo "⏭️  Skipping $framework_name (already signed by Flutter)"
            continue
        fi
        
        echo "🔏 Signing $framework_name..."
        
        # Sign the framework
        /usr/bin/codesign --force --sign "$CODESIGN_IDENTITY" --timestamp "$framework"
        
        # Verify the signature
        if /usr/bin/codesign --verify --verbose "$framework" 2>&1 | grep -q "valid on disk"; then
            echo "✅ Successfully signed $framework_name"
        else
            echo "⚠️  Warning: Signature verification failed for $framework_name"
        fi
        
        echo ""
    fi
done

echo "✨ Framework signing completed!"
echo ""
echo "Next steps:"
echo "1. Open your iOS project in Xcode"
echo "2. Replace the old frameworks with the newly signed ones from:"
echo "   $FRAMEWORKS_DIR"
echo "3. Clean build folder (Cmd+Shift+K)"
echo "4. Archive and submit to App Store"
