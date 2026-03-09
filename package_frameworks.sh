#!/bin/bash

# Framework 打包脚本
# 将签名后的 frameworks 打包成 zip 文件，方便分发

set -e

OUTPUT_DIR="./build/frameworks/Release"
PACKAGE_NAME="TanyuApp_Frameworks_$(date +%Y%m%d_%H%M%S).zip"
PACKAGE_PATH="$(pwd)/build/$PACKAGE_NAME"

echo "=========================================="
echo "Framework 打包工具"
echo "=========================================="

# 检查 frameworks 是否存在
if [ ! -d "$OUTPUT_DIR" ]; then
    echo "❌ 错误: 未找到 frameworks 目录"
    echo "请先运行 ./build_framework.sh 构建 frameworks"
    exit 1
fi

# 验证所有 frameworks 的签名
echo "验证签名..."
all_signed=true
for xcframework in "$OUTPUT_DIR"/*.xcframework; do
    if [ -d "$xcframework" ]; then
        framework_name=$(basename "$xcframework")
        echo "  检查 $framework_name..."
        
        # 查找第一个 framework 并验证签名
        first_fw=$(find "$xcframework" -name "*.framework" -type d | head -1)
        if [ -n "$first_fw" ]; then
            if codesign --verify --deep --strict "$first_fw" 2>/dev/null; then
                signing_identity=$(codesign -dvv "$first_fw" 2>&1 | grep "Authority=" | head -1 | cut -d= -f2)
                echo "    ✓ 签名: $signing_identity"
            else
                echo "    ✗ 签名验证失败"
                all_signed=false
            fi
        fi
    fi
done

if [ "$all_signed" = false ]; then
    echo ""
    echo "❌ 部分 frameworks 签名验证失败"
    echo "请重新运行 ./build_framework.sh"
    exit 1
fi

echo ""
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
TanyuApp Frameworks
==================

此包包含以下 frameworks:
- App.xcframework (主应用)
- Flutter.xcframework (Flutter 引擎)
- in_app_purchase_storekit.xcframework (内购插件)
- shared_preferences_foundation.xcframework (本地存储插件)
- url_launcher_ios.xcframework (URL 启动插件)
- webview_flutter_wkwebview.xcframework (WebView 插件)

所有 frameworks 已使用 Apple Distribution 证书签名。

集成步骤:
1. 查看 INTEGRATION_GUIDE.md 了解详细集成步骤
2. 将所有 .xcframework 文件添加到你的 Xcode 项目
3. 在 "Frameworks, Libraries, and Embedded Content" 中设置为 "Embed & Sign"
4. 配置 Build Settings 和隐私权限

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
echo "可以将此 zip 文件分发给其他开发者使用"
echo ""

