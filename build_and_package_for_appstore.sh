#!/bin/bash

# 完整的 App Store 打包流程
# 1. 构建 Flutter Framework
# 2. 签名所有 Framework
# 3. 集成到 iOS 项目
# 4. Archive 并导出 IPA

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 配置
CODESIGN_IDENTITY="DF8FC93F64E2EDC2E723F14C36FBF9E8F0E4B119"
TEAM_ID="UG5N3PCLJ5"
BUNDLE_ID="com.tantan.yu"
APP_NAME="彼趣"
SCHEME="Runner"
WORKSPACE="ios/Runner.xcworkspace"
PROJECT="ios/Runner.xcodeproj"

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}   App Store 完整打包流程${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${GREEN}应用名称:${NC} $APP_NAME"
echo -e "${GREEN}Bundle ID:${NC} $BUNDLE_ID"
echo -e "${GREEN}Team ID:${NC} $TEAM_ID"
echo ""

# ============================================
# 步骤 1: 清理旧构建
# ============================================
echo -e "${YELLOW}📦 步骤 1/5: 清理旧构建...${NC}"
flutter clean
rm -rf build/ios/framework
rm -rf build/ios/iphoneos
echo -e "${GREEN}✅ 清理完成${NC}"
echo ""

# ============================================
# 步骤 2: 构建 Flutter Framework
# ============================================
echo -e "${YELLOW}📦 步骤 2/5: 构建 Flutter Framework...${NC}"
flutter pub get
flutter build ios-framework --release

if [ ! -d "build/ios/framework/Release" ]; then
    echo -e "${RED}❌ Framework 构建失败${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Framework 构建完成${NC}"
echo ""

# ============================================
# 步骤 3: 签名所有 Framework
# ============================================
echo -e "${YELLOW}🔐 步骤 3/5: 签名 Framework...${NC}"

FRAMEWORKS_DIR="build/ios/framework/Release"
frameworks=(
    "App.xcframework"
    "in_app_purchase_storekit.xcframework"
    "shared_preferences_foundation.xcframework"
    "url_launcher_ios.xcframework"
    "webview_flutter_wkwebview.xcframework"
)

for framework in "${frameworks[@]}"; do
    if [ -d "$FRAMEWORKS_DIR/$framework" ]; then
        echo "  🔏 签名: $framework"
        /usr/bin/codesign --force --sign "$CODESIGN_IDENTITY" \
            --timestamp "$FRAMEWORKS_DIR/$framework" 2>&1 | grep -v "replacing existing signature" || true
        
        if /usr/bin/codesign --verify --verbose "$FRAMEWORKS_DIR/$framework" 2>&1 | grep -q "valid on disk"; then
            echo "  ✅ $framework 签名成功"
        else
            echo -e "${RED}  ❌ $framework 签名失败${NC}"
            exit 1
        fi
    fi
done

echo -e "${GREEN}✅ 所有 Framework 签名完成${NC}"
echo ""

# ============================================
# 步骤 4: 检查 Xcode 项目配置
# ============================================
echo -e "${YELLOW}🔍 步骤 4/5: 检查 Xcode 项目...${NC}"

# 检查项目是否存在
if [ ! -d "$PROJECT" ]; then
    echo -e "${RED}❌ 找不到 Xcode 项目: $PROJECT${NC}"
    exit 1
fi

# 检查 workspace 是否存在
if [ ! -d "$WORKSPACE" ]; then
    echo -e "${YELLOW}⚠️  Workspace 不存在，将使用 Project${NC}"
    BUILD_TARGET="-project $PROJECT"
else
    BUILD_TARGET="-workspace $WORKSPACE"
fi

echo -e "${GREEN}✅ Xcode 项目检查完成${NC}"
echo ""

# ============================================
# 步骤 5: Archive 并导出 IPA
# ============================================
echo -e "${YELLOW}📱 步骤 5/5: Archive 并导出 IPA...${NC}"

# 创建输出目录
OUTPUT_DIR="build/ios/ipa"
ARCHIVE_PATH="$OUTPUT_DIR/$APP_NAME.xcarchive"
IPA_PATH="$OUTPUT_DIR"

mkdir -p "$OUTPUT_DIR"

# Clean build folder
echo "  🧹 清理 Xcode 构建缓存..."
xcodebuild clean $BUILD_TARGET \
    -scheme "$SCHEME" \
    -configuration Release

# Archive
echo "  📦 开始 Archive..."
xcodebuild archive $BUILD_TARGET \
    -scheme "$SCHEME" \
    -configuration Release \
    -archivePath "$ARCHIVE_PATH" \
    -destination 'generic/platform=iOS' \
    CODE_SIGN_IDENTITY="Apple Distribution: Lonaa Chisholmm ($TEAM_ID)" \
    DEVELOPMENT_TEAM="$TEAM_ID" \
    PROVISIONING_PROFILE_SPECIFIER="" \
    CODE_SIGN_STYLE=Automatic

if [ ! -d "$ARCHIVE_PATH" ]; then
    echo -e "${RED}❌ Archive 失败${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Archive 完成${NC}"

# 创建 ExportOptions.plist
echo "  📝 创建导出配置..."
cat > "$OUTPUT_DIR/ExportOptions.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>teamID</key>
    <string>$TEAM_ID</string>
    <key>uploadSymbols</key>
    <true/>
    <key>uploadBitcode</key>
    <false/>
    <key>signingStyle</key>
    <string>automatic</string>
    <key>destination</key>
    <string>export</string>
</dict>
</plist>
EOF

# Export IPA
echo "  📤 导出 IPA..."
xcodebuild -exportArchive \
    -archivePath "$ARCHIVE_PATH" \
    -exportPath "$IPA_PATH" \
    -exportOptionsPlist "$OUTPUT_DIR/ExportOptions.plist"

# 查找生成的 IPA
IPA_FILE=$(find "$IPA_PATH" -name "*.ipa" -type f | head -1)

if [ -z "$IPA_FILE" ]; then
    echo -e "${RED}❌ IPA 导出失败${NC}"
    exit 1
fi

# 重命名 IPA
FINAL_IPA="$IPA_PATH/${APP_NAME}.ipa"
if [ "$IPA_FILE" != "$FINAL_IPA" ]; then
    mv "$IPA_FILE" "$FINAL_IPA"
fi

echo -e "${GREEN}✅ IPA 导出完成${NC}"
echo ""

# ============================================
# 完成总结
# ============================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}🎉 打包完成！${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${GREEN}📦 Framework 位置:${NC}"
echo "   $FRAMEWORKS_DIR"
echo ""
echo -e "${GREEN}📱 Archive 位置:${NC}"
echo "   $ARCHIVE_PATH"
echo ""
echo -e "${GREEN}📦 IPA 文件:${NC}"
echo "   $FINAL_IPA"
echo ""
echo -e "${GREEN}📊 文件大小:${NC}"
ls -lh "$FINAL_IPA" | awk '{print "   " $5}'
echo ""

# ============================================
# 下一步提示
# ============================================
echo -e "${YELLOW}🚀 下一步操作:${NC}"
echo ""
echo "1️⃣  验证 IPA:"
echo "   xcrun altool --validate-app -f \"$FINAL_IPA\" -t ios -u lonaachisholmm10@icloud.com -p vcjn-nxtu-cwmw-ewsy"
echo ""
echo "2️⃣  上传到 App Store Connect:"
echo "   xcrun altool --upload-app -f \"$FINAL_IPA\" -t ios -u lonaachisholmm10@icloud.com -p vcjn-nxtu-cwmw-ewsy"
echo ""
echo "3️⃣  或使用 Transporter 应用上传:"
echo "   - 打开 Transporter 应用"
echo "   - 拖入 IPA 文件"
echo "   - 点击上传"
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
