#!/bin/bash

# 修复 Framework 签名问题
# 使用更严格的签名参数，确保 Xcode 能够正确验证

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}修复 Framework 签名${NC}"
echo -e "${GREEN}========================================${NC}"

# 使用证书的 SHA-1 哈希值（避免歧义）
IDENTITY="DF8FC93F64E2EDC2E723F14C36FBF9E8F0E4B119"
FRAMEWORKS_DIR="./build/frameworks/Release"

# 检查证书
if ! security find-identity -v -p codesigning | grep -q "$IDENTITY"; then
    echo -e "${RED}错误: 找不到证书 $IDENTITY${NC}"
    exit 1
fi

echo -e "${GREEN}使用证书: Apple Distribution: Lonaa Chisholmm (UG5N3PCLJ5)${NC}"
echo ""

# 重新签名函数
resign_framework() {
    local framework_path="$1"
    local framework_name=$(basename "$framework_path")
    
    echo -e "${BLUE}处理 $framework_name${NC}"
    
    # 1. 完全删除旧签名
    echo "  1. 删除旧签名..."
    find "$framework_path" -name "_CodeSignature" -type d -exec rm -rf {} + 2>/dev/null || true
    find "$framework_path" -name "*.dSYM" -type d -exec rm -rf {} + 2>/dev/null || true
    
    # 2. 签名所有嵌套的二进制文件和 dylib
    echo "  2. 签名嵌套二进制文件..."
    find "$framework_path" -type f \( -name "*.dylib" -o -name "*.so" \) 2>/dev/null | while read -r lib; do
        if file "$lib" | grep -q "Mach-O"; then
            echo "     签名: $(basename "$lib")"
            codesign --force --sign "$IDENTITY" \
                --timestamp \
                --options runtime \
                "$lib" 2>&1 || true
        fi
    done
    
    # 3. 签名所有可执行文件
    find "$framework_path" -type f -perm +111 ! -path "*/Headers/*" ! -path "*/_CodeSignature/*" 2>/dev/null | while read -r binary; do
        if file "$binary" | grep -q "Mach-O"; then
            if [[ ! "$binary" =~ \.dylib$ ]] && [[ ! "$binary" =~ \.so$ ]]; then
                echo "     签名: $(basename "$binary")"
                codesign --force --sign "$IDENTITY" \
                    --timestamp \
                    --options runtime \
                    "$binary" 2>&1 || true
            fi
        fi
    done
    
    # 4. 签名每个架构的 framework
    echo "  3. 签名各架构 framework..."
    find "$framework_path" -name "*.framework" -type d | while read -r fw; do
        arch_name=$(echo "$fw" | grep -o "ios-[^/]*")
        echo "     架构: $arch_name"
        
        # 删除旧签名
        rm -rf "$fw/_CodeSignature" 2>/dev/null || true
        
        # 使用严格的签名参数
        codesign --force \
            --sign "$IDENTITY" \
            --timestamp \
            --generate-entitlement-der \
            --options runtime \
            --deep \
            --verbose \
            "$fw" 2>&1 | grep -v "replacing existing signature" || true
        
        # 验证签名
        if codesign --verify --deep --strict --verbose=2 "$fw" 2>&1; then
            echo -e "${GREEN}     ✓ 签名成功${NC}"
        else
            echo -e "${RED}     ✗ 签名验证失败${NC}"
            return 1
        fi
    done
    
    echo -e "${GREEN}  ✓ $framework_name 处理完成${NC}"
    echo ""
}

# 处理所有 frameworks（跳过 Flutter.xcframework）
for xcframework in "$FRAMEWORKS_DIR"/*.xcframework; do
    if [ -d "$xcframework" ]; then
        framework_name=$(basename "$xcframework" .xcframework)
        
        # 跳过 Flutter.xcframework
        if [ "$framework_name" = "Flutter" ]; then
            echo -e "${YELLOW}跳过 Flutter.xcframework (保持官方签名)${NC}"
            echo ""
            continue
        fi
        
        resign_framework "$xcframework"
    fi
done

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}签名修复完成！${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# 验证所有签名
echo -e "${YELLOW}验证所有 Framework 签名...${NC}"
echo ""

for xcframework in "$FRAMEWORKS_DIR"/*.xcframework; do
    if [ -d "$xcframework" ]; then
        framework_name=$(basename "$xcframework" .xcframework)
        
        echo -e "${BLUE}$framework_name.xcframework:${NC}"
        
        for arch_dir in "$xcframework"/ios-*; do
            if [ -d "$arch_dir" ]; then
                arch_name=$(basename "$arch_dir")
                for fw in "$arch_dir"/*.framework; do
                    if [ -d "$fw" ]; then
                        # 获取签名信息
                        signing_info=$(codesign -dvv "$fw" 2>&1)
                        authority=$(echo "$signing_info" | grep "Authority=" | head -1 | cut -d= -f2)
                        team_id=$(echo "$signing_info" | grep "TeamIdentifier=" | cut -d= -f2)
                        
                        if [ -n "$authority" ]; then
                            echo -e "  ${GREEN}✓${NC} $arch_name"
                            echo -e "    签名: $authority"
                            echo -e "    Team ID: $team_id"
                        else
                            echo -e "  ${RED}✗${NC} $arch_name - 未签名"
                        fi
                        break
                    fi
                done
            fi
        done
        echo ""
    fi
done

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}所有操作完成！${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}下一步：${NC}"
echo "1. 在 Xcode 中删除旧的 frameworks"
echo "2. 重新添加 $FRAMEWORKS_DIR 中的所有 frameworks"
echo "3. 确保所有 frameworks 设置为 'Embed & Sign'"
echo "4. Clean Build Folder (Cmd + Shift + K)"
echo "5. 重新编译项目"
echo ""
