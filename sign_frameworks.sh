#!/bin/bash

# Script to sign Flutter frameworks for App Store submission
# This resolves ITMS-91065: Missing signature errors

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}🔐 Starting framework signing process...${NC}"

# Path to the frameworks directory
FRAMEWORKS_DIR="build/frameworks/Release"

# Check if frameworks directory exists
if [ ! -d "$FRAMEWORKS_DIR" ]; then
    echo -e "${RED}❌ Error: Frameworks directory not found at $FRAMEWORKS_DIR${NC}"
    echo "Please run ./build_framework_unsigned.sh first to generate frameworks"
    exit 1
fi

# 使用 SHA-1 哈希值来指定证书，避免冲突
# 使用有效的 Apple Distribution 证书（非撤销的）
CODESIGN_IDENTITY="DF8FC93F64E2EDC2E723F14C36FBF9E8F0E4B119"

# 验证证书是否存在
if ! security find-identity -v -p codesigning | grep -q "$CODESIGN_IDENTITY"; then
    echo -e "${RED}❌ Error: Certificate with SHA-1 $CODESIGN_IDENTITY not found${NC}"
    echo ""
    echo "Available certificates:"
    security find-identity -v -p codesigning
    exit 1
fi

echo -e "${GREEN}📝 Using certificate SHA-1: $CODESIGN_IDENTITY${NC}"
echo -e "${GREEN}   (Apple Distribution: Lonaa Chisholmm)${NC}"
echo ""

# Sign each xcframework
for xcframework in "$FRAMEWORKS_DIR"/*.xcframework; do
    if [ -d "$xcframework" ]; then
        framework_name=$(basename "$xcframework")
        
        # 跳过 Flutter.xcframework，保留 Flutter 官方签名
        if [ "$framework_name" = "Flutter.xcframework" ]; then
            echo -e "${YELLOW}⏭️  Skipping $framework_name (keeping Flutter official signature)${NC}"
            echo ""
            continue
        fi
        
        echo -e "${BLUE}🔏 Signing $framework_name...${NC}"
        
        # 遍历 xcframework 中的所有 framework
        find "$xcframework" -name "*.framework" -type d | while read -r framework; do
            # 删除旧签名
            rm -rf "$framework/_CodeSignature" 2>/dev/null || true
            
            # 先签名所有嵌套的二进制文件和 dylib
            find "$framework" -type f \( -name "*.dylib" -o -perm +111 \) ! -path "*/Headers/*" ! -path "*/_CodeSignature/*" 2>/dev/null | while read -r binary; do
                if file "$binary" | grep -q "Mach-O"; then
                    codesign --force --sign "$CODESIGN_IDENTITY" --timestamp "$binary" 2>/dev/null || true
                fi
            done
            
            # 使用深度签名重新签名整个 framework
            if codesign --force --deep --sign "$CODESIGN_IDENTITY" --timestamp "$framework" 2>&1; then
                echo -e "${GREEN}  ✅ $(basename "$framework") signed successfully${NC}"
            else
                echo -e "${RED}  ❌ $(basename "$framework") signing failed${NC}"
                exit 1
            fi
            
            # 验证签名
            if codesign --verify --deep --strict "$framework" 2>&1; then
                echo -e "${GREEN}  ✅ $(basename "$framework") signature verified${NC}"
            else
                echo -e "${YELLOW}  ⚠️  $(basename "$framework") signature verification warning${NC}"
            fi
        done
        
        echo ""
    fi
done

echo -e "${GREEN}✨ Framework signing completed!${NC}"
echo ""
echo -e "${YELLOW}Verification:${NC}"

# 验证所有 frameworks
for xcframework in "$FRAMEWORKS_DIR"/*.xcframework; do
    if [ -d "$xcframework" ]; then
        framework_name=$(basename "$xcframework")
        echo -e "${BLUE}Checking $framework_name:${NC}"
        
        # 检查签名
        for arch_dir in "$xcframework"/ios-*; do
            for fw in "$arch_dir"/*.framework; do
                if [ -d "$fw" ]; then
                    signing_identity=$(codesign -dvv "$fw" 2>&1 | grep "Authority=" | head -1 | cut -d= -f2)
                    if [ -n "$signing_identity" ]; then
                        echo -e "${GREEN}  ✅ Signed:$signing_identity${NC}"
                    else
                        echo -e "${RED}  ❌ Not signed${NC}"
                    fi
                    break
                fi
            done
            break
        done
    fi
done

echo ""
echo -e "${GREEN}Next steps:${NC}"
echo "1. Frameworks are ready at: $FRAMEWORKS_DIR"
echo "2. Drag all .xcframework files into your Xcode project"
echo "3. Set all frameworks to 'Embed & Sign'"
echo "4. Clean build folder (Cmd+Shift+K)"
echo "5. Archive and submit to App Store"
