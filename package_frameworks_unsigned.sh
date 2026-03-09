#!/bin/bash

# Framework 打包脚本（未签名版本）
# 将未签名的 frameworks 打包成 zip 文件，方便分发

set -e

OUTPUT_DIR="./build/frameworks/Release"
PACKAGE_NAME="TanyuApp_Frameworks_Unsigned_$(date +%Y%m%d_%H%M%S).zip"
PACKAGE_PATH="$(pwd)/build/$PACKAGE_NAME"

echo "=========================================="
echo "Framework 打包工具（未签名版本）"
echo "=========================================="

# 检查 frameworks 是否存在
if [ ! -d "$OUTPUT_DIR" ]; then
    echo "❌ 错误: 未找到 frameworks 目录"
    echo "请先运行 ./build_framework_unsigned.sh 构建 frameworks"
    exit 1
fi

echo "打包 frameworks..."

# 创建临时目录
TEMP_DIR=$(mktemp -d)
FRAMEWORKS_DIR="$TEMP_DIR/TanyuApp_Frameworks"
mkdir -p "$FRAMEWORKS_DIR"

# 复制 frameworks
cp -R "$OUTPUT_DIR"/*.xcframework "$FRAMEWORKS_DIR/"

# 复制集成指南
if [ -f "./build/frameworks/INTEGRATION_GUIDE.md" ]; then
    cp "./build/frameworks/INTEGRATION_GUIDE.md" "$FRAMEWORKS_DIR/"
fi

# 创建 README
cat > "$FRAMEWORKS_DIR/README.txt" << 'READMEEOF'
TanyuApp Frameworks (未签名版本)
==================

此包包含以下 frameworks:
- App.xcframework (主应用)
- Flutter.xcframework (Flutter 引擎)
- in_app_purchase_storekit.xcframework (内购插件)
- shared_preferences_foundation.xcframework (本地存储插件)
- url_launcher_ios.xcframework (URL 启动插件)
- webview_flutter_wkwebview.xcframework (WebView 插件)

重要说明:
- 这些 frameworks 未签名
- 嵌入到 Xcode 项目时，Xcode 会自动使用主项目的签名证书重新签名
- 必须设置为 "Embed & Sign"，不要使用 "Embed Without Signing"

集成步骤:
1. 查看 INTEGRATION_GUIDE.md 了解详细集成步骤
2. 将所有 .xcframework 文件添加到你的 Xcode 项目
3. 在 "Frameworks, Libraries, and Embedded Content" 中设置为 "Embed & Sign"
4. 配置 Build Settings:
   - Other Linker Flags: -ObjC
   - Enable Bitcode: NO
5. 确保主项目有正确的签名配置

技术支持: 请联系开发团队
READMEEOF

# 打包
cd "$TEMP_DIR"
zip -r "$PACKAGE_PATH" "TanyuApp_Frameworks" -q

# 清理临时目录
rm -rf "$TEMP_DIR"

# 显示结果
echo ""
echo "=========================================="
echo "✅ 打包完成"
echo "=========================================="
echo "包名称: $PACKAGE_NAME"
echo "包路径: $PACKAGE_PATH"
echo "包大小: $(du -h "$PACKAGE_PATH" | cut -f1)"
echo ""
echo "包含的 frameworks:"
unzip -l "$PACKAGE_PATH" | grep ".xcframework" | awk '{print "  - " $4}' | sort -u
echo ""
echo "重要提示:"
echo "  - 这些 frameworks 未签名"
echo "  - 嵌入到项目时必须选择 'Embed & Sign'"
echo "  - Xcode 会自动使用主项目的证书重新签名"
echo ""
echo "可以将此 zip 文件分发给其他开发者使用"
echo ""
