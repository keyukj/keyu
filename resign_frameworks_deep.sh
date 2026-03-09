#!/bin/bash

# 深度签名脚本 - 对 xcframework 内部的所有二进制文件进行签名
# 解决 signature-collection failed 错误

set -e

FRAMEWORKS_DIR="/Users/admin/Desktop/小遇/小遇/build/frameworks/Release"
CODESIGN_IDENTITY="DF8FC93F64E2EDC2E723F14C36FBF9E8F0E4B119"

echo "🔐 开始深度签名 Flutter frameworks..."
echo "📍 框架目录: $FRAMEWORKS_DIR"
echo "🔑 签名证书: Apple Distribution: Lonaa Chisholmm (UG5N3PCLJ5)"
echo ""

# 函数：深度签名 xcframework
sign_xcframework() {
    local xcframework_path="$1"
    local framework_name=$(basename "$xcframework_path")
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🔏 处理: $framework_name"
    echo ""
    
    # 遍历 xcframework 中的所有 .framework
    find "$xcframework_path" -name "*.framework" -type d | while read framework; do
        echo "  📦 签名架构: $(basename "$framework")"
        
        # 获取框架内的二进制文件路径
        framework_basename=$(basename "$framework" .framework)
        binary_path="$framework/$framework_basename"
        
        if [ -f "$binary_path" ]; then
            echo "     二进制文件: $framework_basename"
            # 签名二进制文件
            /usr/bin/codesign --force --sign "$CODESIGN_IDENTITY" \
                --timestamp \
                --generate-entitlement-der \
                "$binary_path" 2>&1 | grep -v "replacing existing signature" || true
        fi
        
        # 签名整个 framework
        /usr/bin/codesign --force --sign "$CODESIGN_IDENTITY" \
            --timestamp \
            --generate-entitlement-der \
            "$framework" 2>&1 | grep -v "replacing existing signature" || true
        
        echo "     ✅ 完成"
    done
    
    # 最后签名整个 xcframework
    echo "  🔐 签名整个 xcframework..."
    /usr/bin/codesign --force --sign "$CODESIGN_IDENTITY" \
        --timestamp \
        --generate-entitlement-der \
        "$xcframework_path" 2>&1 | grep -v "replacing existing signature" || true
    
    # 验证签名
    echo "  🔍 验证签名..."
    if /usr/bin/codesign --verify --verbose "$xcframework_path" 2>&1 | grep -q "valid on disk"; then
        echo "  ✅ $framework_name 签名验证成功"
    else
        echo "  ⚠️  $framework_name 签名验证失败"
        /usr/bin/codesign --verify --verbose "$xcframework_path" 2>&1
    fi
    echo ""
}

# 签名所有框架（除了 Flutter.xcframework）
frameworks=(
    "App.xcframework"
    "in_app_purchase_storekit.xcframework"
    "shared_preferences_foundation.xcframework"
    "url_launcher_ios.xcframework"
    "webview_flutter_wkwebview.xcframework"
)

for framework in "${frameworks[@]}"; do
    framework_path="$FRAMEWORKS_DIR/$framework"
    if [ -d "$framework_path" ]; then
        sign_xcframework "$framework_path"
    else
        echo "⚠️  未找到: $framework"
    fi
done

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "⏭️  跳过 Flutter.xcframework（Flutter 官方已签名）"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✨ 深度签名完成！"
echo ""
echo "📋 签名摘要："
echo "   - 已签名框架: ${#frameworks[@]} 个"
echo "   - 签名证书: Apple Distribution: Lonaa Chisholmm (UG5N3PCLJ5)"
echo "   - Team ID: UG5N3PCLJ5"
echo ""
echo "🎯 下一步："
echo "   1. 在 Xcode 中 Clean Build Folder (Cmd+Shift+K)"
echo "   2. 重新 Build 项目"
echo "   3. Archive 并提交"
