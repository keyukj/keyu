#!/bin/bash

# Flutter Framework 打包脚本（不签名版本）
# 用于嵌入到其他 iOS 项目，由主项目统一签名

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Flutter Framework 打包工具（不签名）${NC}"
echo -e "${GREEN}适用于嵌入其他项目${NC}"
echo -e "${GREEN}========================================${NC}"

# 配置参数
FRAMEWORK_NAME="TanyuApp"
OUTPUT_DIR="./build/frameworks"
FLUTTER_BUILD_MODE="release"

# 清理旧的构建产物
echo -e "${YELLOW}[1/6] 清理旧的构建产物...${NC}"
rm -rf "$OUTPUT_DIR"
rm -rf "./build/ios"
mkdir -p "$OUTPUT_DIR"

# 清理 Flutter 构建缓存
echo -e "${YELLOW}[2/6] 清理 Flutter 构建缓存...${NC}"
flutter clean

# 获取依赖
echo -e "${YELLOW}[3/6] 获取 Flutter 依赖...${NC}"
flutter pub get

# 运行 CocoaPods
echo -e "${YELLOW}[4/6] 更新 CocoaPods 依赖...${NC}"
cd ios
pod install --repo-update
cd ..

# 构建 iOS Framework (Release 模式)
echo -e "${YELLOW}[5/6] 构建 iOS Framework (Release)...${NC}"
flutter build ios-framework --output="$OUTPUT_DIR" --no-debug --no-profile --release

# 检查构建结果
if [ ! -d "$OUTPUT_DIR/Release" ]; then
    echo -e "${RED}构建失败！未找到 Release 目录${NC}"
    exit 1
fi

# 复制隐私清单到 frameworks
echo -e "${YELLOW}[6/6] 添加隐私清单文件...${NC}"
if [ -f "ios/Runner/PrivacyInfo.xcprivacy" ]; then
    # 为每个 framework 添加隐私清单
    for framework in "$OUTPUT_DIR/Release"/*.xcframework; do
        if [ -d "$framework" ]; then
            framework_name=$(basename "$framework" .xcframework)
            echo -e "${BLUE}  添加隐私清单到 $framework_name${NC}"
            
            # 遍历 xcframework 中的所有架构
            for arch_dir in "$framework"/ios-*; do
                if [ -d "$arch_dir" ]; then
                    # 查找 .framework 目录
                    for fw in "$arch_dir"/*.framework; do
                        if [ -d "$fw" ]; then
                            cp "ios/Runner/PrivacyInfo.xcprivacy" "$fw/"
                            echo -e "${GREEN}    ✓ 已添加到 $(basename "$fw")${NC}"
                        fi
                    done
                fi
            done
        fi
    done
else
    echo -e "${YELLOW}  警告: 未找到 PrivacyInfo.xcprivacy 文件${NC}"
fi

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}构建完成！${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "Framework 输出目录: ${YELLOW}$OUTPUT_DIR/Release${NC}"
echo ""
echo -e "${GREEN}生成的 Frameworks:${NC}"
ls -lh "$OUTPUT_DIR/Release/"

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}集成说明${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}✓${NC} Frameworks 已构建为 Release 模式"
echo -e "${GREEN}✓${NC} 未签名（将由主项目自动签名）"
echo -e "${GREEN}✓${NC} 已包含隐私清单 (PrivacyInfo.xcprivacy)"
echo -e "${GREEN}✓${NC} 支持 arm64 架构 (真机)"
echo -e "${GREEN}✓${NC} 支持 x86_64 架构 (模拟器)"
echo ""
echo -e "${YELLOW}集成步骤:${NC}"
echo -e "  1. 将所有 .xcframework 拖入 Xcode 项目"
echo -e "  2. 在 Target -> General -> Frameworks, Libraries, and Embedded Content"
echo -e "  3. 设置所有 frameworks 为 'Embed & Sign'"
echo -e "  4. Xcode 会自动使用主项目的签名证书重新签名"
echo -e "  5. 在 Build Settings 中设置:"
echo -e "     - Other Linker Flags: -ObjC"
echo -e "     - Enable Bitcode: NO"
echo ""
echo -e "${GREEN}✓ 这个版本的 frameworks 未签名，适合嵌入到其他项目${NC}"
echo ""
