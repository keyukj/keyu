#!/bin/bash

# 快速打包 IPA
set -e

echo "🚀 开始打包 彼趣 App..."
echo ""

# 步骤 1: 构建 iOS
echo "📱 步骤 1/3: 构建 iOS 应用..."
flutter build ios --release

# 步骤 2: Archive
echo "📦 步骤 2/3: Archive..."
xcodebuild archive \
    -workspace ios/Runner.xcworkspace \
    -scheme Runner \
    -configuration Release \
    -archivePath build/ios/ipa/彼趣.xcarchive \
    -destination 'generic/platform=iOS' \
    CODE_SIGN_STYLE=Automatic \
    DEVELOPMENT_TEAM=UG5N3PCLJ5

# 步骤 3: 导出 IPA
echo "📤 步骤 3/3: 导出 IPA..."

# 创建导出配置
cat > build/ios/ipa/ExportOptions.plist << 'EOF'
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
</dict>
</plist>
EOF

xcodebuild -exportArchive \
    -archivePath build/ios/ipa/彼趣.xcarchive \
    -exportPath build/ios/ipa \
    -exportOptionsPlist build/ios/ipa/ExportOptions.plist

# 重命名 IPA
IPA_FILE=$(find build/ios/ipa -name "*.ipa" -type f | head -1)
if [ -n "$IPA_FILE" ]; then
    mv "$IPA_FILE" build/ios/ipa/彼趣.ipa
fi

echo ""
echo "✅ 打包完成！"
echo ""
echo "📦 IPA 文件: build/ios/ipa/彼趣.ipa"
ls -lh build/ios/ipa/彼趣.ipa | awk '{print "📊 文件大小: " $5}'
echo ""
echo "🚀 上传命令:"
echo "open -a Transporter build/ios/ipa/彼趣.ipa"
