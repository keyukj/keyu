#!/bin/bash

# Framework 重签名脚本
# 使用证书: Apple Distribution: Lonaa Chisholmm (UG5N3PCLJ5)

set -e

# 配置
FRAMEWORKS_PATH="/Users/admin/Desktop/小遇/小遇/build/frameworks/Release"
IDENTITY="Apple Distribution: Lonaa Chisholmm (UG5N3PCLJ5)"

echo "=========================================="
echo "Framework 重签名工具"
echo "=========================================="
echo "证书: $IDENTITY"
echo "路径: $FRAMEWORKS_PATH"
echo ""

# 检查证书是否可用
echo "检查证书..."
if ! security find-identity -v -p codesigning | grep -q "$IDENTITY"; then
    echo "❌ 错误: 找不到证书 '$IDENTITY'"
    echo ""
    echo "可用的签名证书:"
    security find-identity -v -p codesigning
    exit 1
fi
echo "✅ 证书验证成功"
echo ""

# 检查路径是否存在
if [ ! -d "$FRAMEWORKS_PATH" ]; then
    echo "❌ 错误: 路径不存在: $FRAMEWORKS_PATH"
    exit 1
fi

# 重签名函数
resign_framework() {
    local framework_path="$1"
    local framework_name=$(basename "$framework_path")
    
    echo "处理: $framework_name"
    
    # 遍历 xcframework 中的所有 framework
    find "$framework_path" -name "*.framework" -type d | while read -r framework; do
        echo "  签名: $(basename "$framework")"
        
        # 删除旧签名
        rm -rf "$framework/_CodeSignature" 2>/dev/null || true
        
        # 先签名所有嵌套的 dylib 和可执行文件
        find "$framework" -type f \( -name "*.dylib" -o -perm +111 \) ! -path "*/Headers/*" ! -path "*/_CodeSignature/*" 2>/dev/null | while read -r binary; do
            if file "$binary" | grep -q "Mach-O"; then
                echo "    签名二进制: $(basename "$binary")"
                codesign --force --sign "$IDENTITY" --timestamp "$binary" 2>/dev/null || true
            fi
        done
        
        # 使用深度签名重新签名整个 framework
        codesign --force --deep --sign "$IDENTITY" --timestamp --verbose "$framework"
        
        # 验证签名
        if codesign --verify --deep --verbose "$framework" 2>&1; then
            echo "  ✅ 签名成功"
        else
            echo "  ❌ 签名验证失败"
            return 1
        fi
    done
    
    echo ""
}

# 处理所有 xcframework
cd "$FRAMEWORKS_PATH"

for xcframework in *.xcframework; do
    if [ -d "$xcframework" ]; then
        resign_framework "$xcframework"
    fi
done

echo "=========================================="
echo "✅ 所有 Framework 重签名完成"
echo "=========================================="
echo ""
echo "验证签名信息:"
echo ""

# 显示签名信息
for xcframework in *.xcframework; do
    if [ -d "$xcframework" ]; then
        echo "--- $xcframework ---"
        find "$xcframework" -name "*.framework" -type d | while read -r framework; do
            echo "$(basename "$framework"):"
            codesign -dvv "$framework" 2>&1 | grep -E "Authority|Identifier|TeamIdentifier" || true
            echo ""
        done
    fi
done
