#!/bin/bash
set -e

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 配置 - 使用 SHA-1 避免证书歧义
CERT="DF8FC93F64E2EDC2E723F14C36FBF9E8F0E4B119"
TEAM_ID="UG5N3PCLJ5"
OUTPUT_DIR="./build/frameworks/Release"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Flutter Framework 打包 (App Store)${NC}"
echo -e "${GREEN}========================================${NC}"

# 验证证书
if ! security find-identity -v -p codesigning | grep -q "$CERT"; then
    echo -e "${RED}错误: 找不到证书 $CERT${NC}"
    exit 1
fi
echo -e "${GREEN}✓ 证书: Apple Distribution: Lonaa Chisholmm (UG5N3PCLJ5)${NC}"
echo ""

# 清理
echo -e "${YELLOW}[1/5] 清理...${NC}"
rm -rf ./build/frameworks 2>/dev/null || true
rm -rf ./build/ios 2>/dev/null || true
mkdir -p "$OUTPUT_DIR"

# flutter clean & pub get
echo -e "${YELLOW}[2/5] 准备依赖...${NC}"
flutter clean
flutter pub get

# 构建 framework
echo -e "${YELLOW}[3/5] 构建 iOS Framework...${NC}"
flutter build ios-framework \
    --output="./build/frameworks" \
    --no-debug \
    --no-profile \
    --release

if [ ! -d "$OUTPUT_DIR" ]; then
    echo -e "${RED}构建失败！${NC}"
    exit 1
fi
echo -e "${GREEN}✓ 构建完成${NC}"

# 签名函数：对 xcframework 内每个 .framework 签名
sign_xcframework() {
    local xcfw="$1"
    local name=$(basename "$xcfw" .xcframework)

    echo -e "${BLUE}  签名 $name.xcframework${NC}"

    # 遍历所有架构目录下的 .framework
    find "$xcfw" -name "*.framework" -type d | sort | while read -r fw; do
        local arch_dir=$(basename "$(dirname "$fw")")

        # 删除旧签名
        rm -rf "$fw/_CodeSignature" 2>/dev/null || true

        # 先签名内部所有 Mach-O 二进制（dylib/so/可执行文件）
        find "$fw" -type f ! -path "*/Headers/*" ! -path "*/Modules/*" ! -path "*/_CodeSignature/*" | while read -r bin; do
            if file "$bin" | grep -q "Mach-O"; then
                codesign --force \
                    --sign "$CERT" \
                    --timestamp \
                    --options runtime \
                    "$bin" 2>/dev/null || true
            fi
        done

        # 签名整个 .framework bundle
        codesign --force \
            --sign "$CERT" \
            --timestamp \
            --options runtime \
            "$fw" 2>&1 | grep -v "replacing existing signature" || true

        # 验证
        if codesign --verify --deep --strict "$fw" 2>/dev/null; then
            echo -e "${GREEN}    ✓ $arch_dir/$(basename "$fw")${NC}"
        else
            echo -e "${RED}    ✗ $arch_dir/$(basename "$fw") 验证失败${NC}"
            exit 1
        fi
    done

    # 最后对 xcframework 本身签名（这是关键！）
    codesign --force \
        --sign "$CERT" \
        --timestamp \
        "$xcfw" 2>&1 | grep -v "replacing existing signature" || true

    if codesign --verify "$xcfw" 2>/dev/null; then
        echo -e "${GREEN}    ✓ $name.xcframework 整体签名成功${NC}"
    else
        echo -e "${RED}    ✗ $name.xcframework 整体签名失败${NC}"
        exit 1
    fi
}

# 签名所有 frameworks（跳过 Flutter.xcframework）
echo ""
echo -e "${YELLOW}[4/5] 签名 Frameworks...${NC}"
for xcfw in "$OUTPUT_DIR"/*.xcframework; do
    name=$(basename "$xcfw" .xcframework)
    if [ "$name" = "Flutter" ]; then
        echo -e "${BLUE}  跳过 Flutter.xcframework (保持官方签名)${NC}"
        continue
    fi
    sign_xcframework "$xcfw"
done

# 验证所有签名
echo ""
echo -e "${YELLOW}[5/5] 验证签名...${NC}"
all_ok=true
for xcfw in "$OUTPUT_DIR"/*.xcframework; do
    name=$(basename "$xcfw" .xcframework)
    auth=$(codesign -dvv "$xcfw" 2>&1 | grep "Authority=" | head -1 | cut -d= -f2)
    if [ -n "$auth" ]; then
        echo -e "  ${GREEN}✓${NC} $name.xcframework → $auth"
    else
        echo -e "  ${RED}✗${NC} $name.xcframework → 未签名"
        all_ok=false
    fi
done

echo ""
if [ "$all_ok" = true ]; then
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}✓ 全部完成！${NC}"
    echo -e "${GREEN}========================================${NC}"
else
    echo -e "${RED}部分 framework 签名失败，请检查！${NC}"
    exit 1
fi

echo ""
echo -e "输出目录: ${YELLOW}$OUTPUT_DIR${NC}"
ls -lh "$OUTPUT_DIR"
echo ""
echo -e "${YELLOW}集成到 Xcode 项目时：${NC}"
echo "  1. 将所有 .xcframework 拖入项目"
echo "  2. Embed 设置为 'Embed & Sign'"
echo "  3. Build Settings → ENABLE_BITCODE = NO"
echo ""
