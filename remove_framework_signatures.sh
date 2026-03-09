#!/bin/bash

# 移除 Framework 签名脚本
# 移除所有签名，让 Xcode 在嵌入时重新签名

set -e

FRAMEWORKS_DIR="./build/frameworks/Release"

echo "=========================================="
echo "移除 Framework 签名"
echo "=========================================="
echo "目录: $FRAMEWORKS_DIR"
echo ""

if [ ! -d "$FRAMEWORKS_DIR" ]; then
    echo "❌ 错误: 目录不存在: $FRAMEWORKS_DIR"
    exit 1
fi

# 移除所有 framework 的签名
for xcframework in "$FRAMEWORKS_DIR"/*.xcframework; do
    if [ -d "$xcframework" ]; then
        framework_name=$(basename "$xcframework")
        echo "处理: $framework_name"
        
        # 遍历 xcframework 中的所有 framework
        find "$xcframework" -name "*.framework" -type d | while read -r framework; do
            echo "  移除签名: $(basename "$framework")"
            
            # 删除签名目录
            rm -rf "$framework/_CodeSignature" 2>/dev/null || true
            
            # 移除扩展属性（可能包含签名信息）
            xattr -cr "$framework" 2>/dev/null || true
            
            echo "  ✓ 已移除"
        done
        
        # 移除 xcframework 级别的签名
        rm -rf "$xcframework/_CodeSignature" 2>/dev/null || true
        xattr -cr "$xcframework" 2>/dev/null || true
        
        echo ""
    fi
done

echo "=========================================="
echo "✅ 所有签名已移除"
echo "=========================================="
echo ""
echo "现在可以将 frameworks 嵌入到其他项目"
echo "Xcode 会自动使用主项目的签名证书重新签名"
echo ""
