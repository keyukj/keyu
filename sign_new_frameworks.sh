#!/bin/bash

# 对新构建的框架进行签名
set -e

CODESIGN_IDENTITY="DF8FC93F64E2EDC2E723F14C36FBF9E8F0E4B119"
FRAMEWORKS_DIR="build/ios/framework/Release"

echo "🔐 开始签名 Release 框架..."
echo "📍 框架目录: $FRAMEWORKS_DIR"
echo ""

# App.xcframework
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔏 签名: App.xcframework"
/usr/bin/codesign --force --sign "$CODESIGN_IDENTITY" --timestamp "$FRAMEWORKS_DIR/App.xcframework"
/usr/bin/codesign --verify --verbose "$FRAMEWORKS_DIR/App.xcframework" 2>&1 | grep "valid on disk" && echo "✅ 验证成功" || echo "❌ 验证失败"
echo ""

# in_app_purchase_storekit.xcframework
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔏 签名: in_app_purchase_storekit.xcframework"
/usr/bin/codesign --force --sign "$CODESIGN_IDENTITY" --timestamp "$FRAMEWORKS_DIR/in_app_purchase_storekit.xcframework"
/usr/bin/codesign --verify --verbose "$FRAMEWORKS_DIR/in_app_purchase_storekit.xcframework" 2>&1 | grep "valid on disk" && echo "✅ 验证成功" || echo "❌ 验证失败"
echo ""

# shared_preferences_foundation.xcframework
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔏 签名: shared_preferences_foundation.xcframework"
/usr/bin/codesign --force --sign "$CODESIGN_IDENTITY" --timestamp "$FRAMEWORKS_DIR/shared_preferences_foundation.xcframework"
/usr/bin/codesign --verify --verbose "$FRAMEWORKS_DIR/shared_preferences_foundation.xcframework" 2>&1 | grep "valid on disk" && echo "✅ 验证成功" || echo "❌ 验证失败"
echo ""

# url_launcher_ios.xcframework
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔏 签名: url_launcher_ios.xcframework"
/usr/bin/codesign --force --sign "$CODESIGN_IDENTITY" --timestamp "$FRAMEWORKS_DIR/url_launcher_ios.xcframework"
/usr/bin/codesign --verify --verbose "$FRAMEWORKS_DIR/url_launcher_ios.xcframework" 2>&1 | grep "valid on disk" && echo "✅ 验证成功" || echo "❌ 验证失败"
echo ""

# webview_flutter_wkwebview.xcframework
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔏 签名: webview_flutter_wkwebview.xcframework"
/usr/bin/codesign --force --sign "$CODESIGN_IDENTITY" --timestamp "$FRAMEWORKS_DIR/webview_flutter_wkwebview.xcframework"
/usr/bin/codesign --verify --verbose "$FRAMEWORKS_DIR/webview_flutter_wkwebview.xcframework" 2>&1 | grep "valid on disk" && echo "✅ 验证成功" || echo "❌ 验证失败"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "⏭️  Flutter.xcframework 跳过（Flutter 官方已签名）"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✨ 签名完成！"
echo ""
echo "📍 已签名框架位置: $FRAMEWORKS_DIR"
echo "🔑 使用证书: Apple Distribution: Lonaa Chisholmm (UG5N3PCLJ5)"
echo ""
echo "🎯 下一步："
echo "   1. 在 Xcode 中删除旧框架"
echo "   2. 添加以下已签名框架："
echo "      - $FRAMEWORKS_DIR/App.xcframework"
echo "      - $FRAMEWORKS_DIR/Flutter.xcframework"
echo "      - $FRAMEWORKS_DIR/in_app_purchase_storekit.xcframework"
echo "      - $FRAMEWORKS_DIR/shared_preferences_foundation.xcframework"
echo "      - $FRAMEWORKS_DIR/url_launcher_ios.xcframework"
echo "      - $FRAMEWORKS_DIR/webview_flutter_wkwebview.xcframework"
echo "   3. 确保所有框架 Embed 设置为 'Embed & Sign'"
echo "   4. Clean Build Folder (Cmd+Shift+K)"
echo "   5. Archive 并提交到 App Store"
