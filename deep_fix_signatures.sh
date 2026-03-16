#!/bin/bash

# 深度修复 Framework 签名
# 确保 xcframework 的每个部分都正确签名，包括 Info.plist

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}深度修复 Framework 签名${NC}"
echo -e "${GREEN}========================================${NC}"

IDENTITY="DF8FC93F64E2EDC2E723F14C36FBF9E8F0E4B119"
FRAMEWORKS_DIR="./build/frameworks/Release"

# 检查证书
if ! security find-identity -v -p codesigning | grep -q "$IDENTITY"; then
    echo -e "${RED}错误: 找不到证书${NC}"
    exit 1
fi

echo -e "${GREEN}使用证书: Apple Distribution: Lonaa Chisholmm (UG5N3PCLJ5)${NC}"
echo ""

# 深度签名函数
deep_sign_xcframework() {
    local xcframework="$1"
    local name=$(basename "$xcframework" .xcframework)
    
    echo -e "${BLUE}处理 $name.xcframework${NC}"
    
    # 1. 完全清理所有签名和缓存
    echo "  1. 清理签名和缓存..."
    find "$xcframework" -name "_CodeSignature" -type d -exec rm -rf {} + 2>/dev/null || true
    find "$xcframework" -name "*.dSYM" -type d -exec rm -rf {} + 2>/dev/null || true
    find "$xcframework" -name ".DS_Store" -type f -delete 2>/dev/null || true
    
    # 2. 处理每个架构目录
    for arch_dir in "$xcframework"/ios-*; do
        if [ ! -d "$arch_dir" ]; then
            continue
        fi
        
        arch_name=$(basename "$arch_dir")
        echo "  2. 处理架构: $arch_name"
        
        for framework in "$arch_dir"/*.framework; do
            if [ ! -d "$framework" ]; then
                continue
            fi
            
            fw_name=$(basename "$framework" .framework)
            echo "     Framework: $fw_name"
            
            # 删除旧签名
            rm -rf "$framework/_CodeSignature" 2>/dev/null || true
            
            # 签名所有资源文件中的可执行内容
            if [ -d "$framework/Frameworks" ]; then
                echo "       签名嵌套 Frameworks..."
                find "$framework/Frameworks" -name "*.framework" -type d | while read -r nested_fw; do
                    codesign --force --sign "$IDENTITY" --timestamp "$nested_fw" 2>/dev/null || true
                done
            fi
            
            # 签名所有 dylib
            if [ -d "$framework" ]; then
                echo "       签名 dylib 文件..."
                find "$framework" -name "*.dylib" -type f | while read -r dylib; do
                    if file "$dylib" 2>/dev/null | grep -q "Mach-O"; then
                        codesign --force --sign "$IDENTITY" --timestamp "$dylib" 2>/dev/null || true
                    fi
                done
            fi
            
            # 签名主二进制文件
            if [ -f "$framework/$fw_name" ]; then
                echo "       签名主二进制: $fw_name"
                if file "$framework/$fw_name" 2>/dev/null | grep -q "Mach-O"; then
                    codesign --force --sign "$IDENTITY" --timestamp "$framework/$fw_name" 2>/dev/null || true
                fi
            fi
            
            # 最终签名整个 framework（不使用 --deep，避免破坏已签名的内容）
            echo "       最终签名 framework..."
            codesign --force \
                --sign "$IDENTITY" \
                --timestamp \
                --generate-entitlement-der \
                "$framework" 2>&1 | grep -v "replacing existing signature" || true
            
            # 验证签名
            if codesign --verify --verbose=2 "$framework" 2>&1 | grep -q "valid on disk"; then
                echo -e "${GREEN}       ✓ 签名成功并验证通过${NC}"
            else
                echo -e "${RED}       ✗ 签名验证失败${NC}"
                codesign --verify --verbose=4 "$framework" 2>&1 || true
            fi
        done
    done
    
    echo -e "${GREEN}  ✓ $name.xcframework 处理完成${NC}"
    echo ""
}

# 处理所有 frameworks
for xcframework in "$FRAMEWORKS_DIR"/*.xcframework; do
    if [ ! -d "$xcframework" ]; then
        continue
    fi
    
    name=$(basename "$xcframework" .xcframework)
    
    # 跳过 Flutter.xcframework
    if [ "$name" = "Flutter" ]; then
        echo -e "${YELLOW}跳过 Flutter.xcframework (保持官方签名)${NC}"
        echo ""
        continue
    fi
    
    deep_sign_xcframework "$xcframework"
done

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}深度签名完成！${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# 详细验证
echo -e "${YELLOW}详细验证所有签名...${NC}"
echo ""

for xcframework in "$FRAMEWORKS_DIR"/*.xcframework; do
    if [ ! -d "$xcframework" ]; then
        continue
    fi
    
    name=$(basename "$xcframework" .xcframework)
    echo -e "${BLUE}$name.xcframework:${NC}"
    
    for arch_dir in "$xcframework"/ios-*; do
        if [ ! -d "$arch_dir" ]; then
            continue
        fi
        
        arch_name=$(basename "$arch_dir")
        
        for framework in "$arch_dir"/*.framework; do
            if [ ! -d "$framework" ]; then
                continue
            fi
            
            echo "  架构: $arch_name"
            
            # 检查签名
            if codesign -dvv "$framework" 2>&1 | grep -q "Authority="; then
                authority=$(codesign -dvv "$framework" 2>&1 | grep "Authority=" | head -1 | cut -d= -f2)
                team_id=$(codesign -dvv "$framework" 2>&1 | grep "TeamIdentifier=" | cut -d= -f2)
                echo -e "    ${GREEN}✓ 已签名${NC}"
                echo "      Authority: $authority"
                echo "      Team ID: $team_id"
                
                # 验证签名有效性
                if codesign --verify --verbose=2 "$framework" 2>&1 | grep -q "valid on disk"; then
                    echo -e "      ${GREEN}✓ 签名有效${NC}"
                else
                    echo -e "      ${RED}✗ 签名无效${NC}"
                fi
            else
                echo -e "    ${RED}✗ 未签名${NC}"
            fi
            
            break
        done
    done
    echo ""
done

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}修复完成！${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}重要提示：${NC}"
echo "1. 在 Xcode 中完全删除项目中的所有 .xcframework"
echo "2. 关闭 Xcode"
echo "3. 删除 DerivedData:"
echo "   rm -rf ~/Library/Developer/Xcode/DerivedData/*"
echo "4. 重新打开 Xcode"
echo "5. 将 ./build/frameworks/Release 中的所有 frameworks 重新拖入项目"
echo "6. 设置所有 frameworks 为 'Embed & Sign'"
echo "7. Clean Build Folder (Cmd + Shift + K)"
echo "8. 重新编译"
echo ""
