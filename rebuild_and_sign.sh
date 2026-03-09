#!/bin/bash

# 完整的重新构建和签名脚本
# 解决 signature-collection failed 和 timestamp 错误

set -e

CODESIGN_IDENTITY="DF8FC93F64E2EDC2E723F14C36FBF9E8F0E4B119"

echo "🚀 开始完整的重新构建和签名流程..."
echo ""

# 步骤 1: 清理旧的构建
echo "🧹 步骤 1/3: 清理旧的构建..."
rm -rf build/frameworks
rm -rf build/ios
echo "✅ 清理完成"
echo ""

# 步骤 2: 重新构建框架
echo "📦 步骤 2/3: 重新构建框架..."
flutter clean
flutter pub get
flutter build ios-framework --release
echo "✅ 构建完成"
echo ""

# 步骤 3: 签名框架
echo "🔐 步骤 3/3: 签名框架..."
echo ""

FRAMEWORKS_DIR="build/frameworks/Release"

# 函数：签名单个 xcframework
sign_framework() {
    local framework_path="$1"
    local framework_name=$(basename "$framework_path")
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🔏 签名: $framework_name"
    
    # 移除旧签名
    find "$framework_path" -name "_CodeSignature" -type d -exec rm -rf {} + 2>/dev/null || true
    
    # 签名 xcframework 内的每个 .framework
    find "$framework_path" -name "*.framework" -type d | while read framework; do
        framework_basename=$(basename "$framework" .framework)
        binary_path="$framework/$framework_basename"
        
        if [ -f "$binary_path" ]; then
            echo "   📝 签名二进制: $framework_basename"
            /usr/bin/codesign --force --sign "$CODESIGN_IDENTITY" \
                --timestamp \
                "$binary_path" 2>&1 | grep -v "replacing existing signature" || true
        fi
        
        echo "   📝 签名框架: $(basename "$framework")"
        /usr/bin/codesign --force --sign "$CODESIGN_IDENTITY" \
            --timestamp \
            "$framework" 2>&1 | grep -v "replacing existing signature" || true
    done
    
    # 签名整个 xcframework
    echo "   📝 签名 xcframework..."
    /usr/bin/codesign --force --sign "$CODESIGN_IDENTITY" \
        --timestamp \
        "$framework_path" 2>&1 | grep -v "replacing existing signature" || true
    
    # 验证
    if /usr/bin/codesign --verify --verbose "$framework_path" 2>&1 | grep -q "valid on disk"; then
        echo "   ✅ 验证成功"
    else
        echo "   ❌ 验证失败"
        return 1
    fi
    echo ""
}

# 签名所有插件框架
frameworks=(
    "App.xcframework"
    "in_app_purchase_storekit.xcframework"
    "shared_preferences_foundation.xcframework"
    "url_launcher_ios.xcframework"
    "webview_flutter_wkwebview.xcframework"
)

success_count=0
for framework in "${frameworks[@]}"; do
    framework_path="$FRAMEWORKS_DIR/$framework"
    if [ -d "$framework_path" ]; then
        if sign_framework "$framework_path"; then
            ((success_count++))
        fi
    else
        echo "⚠️  未找到: $framework"
    fi
done

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "⏭️  Flutter.xcframework 跳过（官方已签名）"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✨ 完成！"
echo ""
echo "📊 签名统计："
echo "   - 成功: $success_count/${#frameworks[@]}"
echo "   - 证书: Apple Distribution: Lonaa Chisholmm (UG5N3PCLJ5)"
echo "   - Team ID: UG5N3PCLJ5"
echo ""
echo "📍 框架位置: $FRAMEWORKS_DIR"
echo ""
echo "🎯 下一步："
echo "   1. 在 Xcode 中删除旧框架"
echo "   2. 添加新签名的框架"
echo "   3. 确保 Embed 设置为 'Embed & Sign'"
echo "   4. Clean Build Folder (Cmd+Shift+K)"
echo "   5. Archive 并提交"
