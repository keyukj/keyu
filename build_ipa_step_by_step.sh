#!/bin/bash

# 分步打包脚本 - 解决签名冲突问题
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}   彼趣 App Store 打包流程${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# ============================================
# 步骤 1: 清理
# ============================================
echo -e "${YELLOW}步骤 1/6: 清理旧构建...${NC}"
flutter clean
rm -rf ios/Pods
rm -rf ios/Podfile.lock
rm -rf ~/Library/Developer/Xcode/DerivedData/*
echo -e "${GREEN}✅ 清理完成${NC}"
echo ""

# ============================================
# 步骤 2: 获取 Flutter 依赖
# ============================================
echo -e "${YELLOW}步骤 2/6: 获取 Flutter 依赖...${NC}"
flutter pub get
echo -e "${GREEN}✅ 依赖获取完成${NC}"
echo ""

# ============================================
# 步骤 3: 重新安装 Pods
# ============================================
echo -e "${YELLOW}步骤 3/6: 重新安装 CocoaPods...${NC}"
cd ios
pod install
cd ..
echo -e "${GREEN}✅ CocoaPods 安装完成${NC}"
echo ""

# ============================================
# 步骤 4: 构建 iOS 应用
# ============================================
echo -e "${YELLOW}步骤 4/6: 构建 iOS 应用...${NC}"
flutter build ios --release
echo -e "${GREEN}✅ iOS 构建完成${NC}"
echo ""

# ============================================
# 步骤 5: Archive
# ============================================
echo -e "${YELLOW}步骤 5/6: Archive...${NC}"

OUTPUT_DIR="build/ios/ipa"
ARCHIVE_PATH="$OUTPUT_DIR/彼趣.xcarchive"
mkdir -p "$OUTPUT_DIR"

# 使用自动签名
xcodebuild archive \
    -workspace ios/Runner.xcworkspace \
    -scheme Runner \
    -configuration Release \
    -archivePath "$ARCHIVE_PATH" \
    -destination 'generic/platform=iOS' \
    CODE_SIGN_STYLE=Automatic \
    DEVELOPMENT_TEAM=UG5N3PCLJ5 \
    | grep -E "^\*\*|error:|warning:|note:" || true

if [ ! -d "$ARCHIVE_PATH" ]; then
    echo -e "${RED}❌ Archive 失败${NC}"
    echo ""
    echo "请在 Xcode 中手动 Archive:"
    echo "1. open ios/Runner.xcworkspace"
    echo "2. 选择 Any iOS Device"
    echo "3. Product → Archive"
    exit 1
fi

echo -e "${GREEN}✅ Archive 完成${NC}"
echo ""

# ============================================
# 步骤 6: 导出 IPA
# ============================================
echo -e "${YELLOW}步骤 6/6: 导出 IPA...${NC}"

# 创建 ExportOptions.plist
cat > "$OUTPUT_DIR/ExportOptions.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>teamID</key>
    <string>UG5N3PCLJ5</string>
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

# 导出 IPA
xcodebuild -exportArchive \
    -archivePath "$ARCHIVE_PATH" \
    -exportPath "$OUTPUT_DIR" \
    -exportOptionsPlist "$OUTPUT_DIR/ExportOptions.plist" \
    | grep -E "^\*\*|error:|warning:|note:" || true

# 查找 IPA
IPA_FILE=$(find "$OUTPUT_DIR" -name "*.ipa" -type f | head -1)

if [ -z "$IPA_FILE" ]; then
    echo -e "${RED}❌ IPA 导出失败${NC}"
    exit 1
fi

# 重命名
FINAL_IPA="$OUTPUT_DIR/彼趣.ipa"
if [ "$IPA_FILE" != "$FINAL_IPA" ]; then
    mv "$IPA_FILE" "$FINAL_IPA"
fi

echo -e "${GREEN}✅ IPA 导出完成${NC}"
echo ""

# ============================================
# 完成
# ============================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}🎉 打包完成！${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${GREEN}📦 IPA 文件:${NC}"
echo "   $FINAL_IPA"
echo ""
echo -e "${GREEN}📊 文件大小:${NC}"
ls -lh "$FINAL_IPA" | awk '{print "   " $5}'
echo ""
echo -e "${YELLOW}🚀 上传到 App Store:${NC}"
echo ""
echo "方法 1 - 使用 Transporter (推荐):"
echo "   open -a Transporter \"$FINAL_IPA\""
echo ""
echo "方法 2 - 使用命令行:"
echo "   xcrun altool --upload-app -f \"$FINAL_IPA\" -t ios \\"
echo "     -u lonaachisholmm10@icloud.com -p vcjn-nxtu-cwmw-ewsy"
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
