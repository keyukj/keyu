#!/bin/bash

# Framework 验证脚本
# 用于验证 Framework 是否符合 App Store 提交要求

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Framework 验证工具${NC}"
echo -e "${GREEN}App Store 提交前检查${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

FRAMEWORKS_DIR="./build/frameworks/Release"
ERRORS=0
WARNINGS=0

# 检查 frameworks 目录
if [ ! -d "$FRAMEWORKS_DIR" ]; then
    echo -e "${RED}✗ Frameworks 目录不存在: $FRAMEWORKS_DIR${NC}"
    echo -e "${YELLOW}请先运行 ./build_framework.sh${NC}"
    exit 1
fi

echo -e "${BLUE}验证目录: $FRAMEWORKS_DIR${NC}"
echo ""

# 1. 检查必需的 frameworks
echo -e "${YELLOW}[1/8] 检查必需的 Frameworks...${NC}"
REQUIRED_FRAMEWORKS=(
    "App.xcframework"
    "Flutter.xcframework"
    "FlutterPluginRegistrant.xcframework"
)

for fw in "${REQUIRED_FRAMEWORKS[@]}"; do
    if [ -d "$FRAMEWORKS_DIR/$fw" ]; then
        echo -e "${GREEN}✓ $fw 存在${NC}"
    else
        echo -e "${RED}✗ $fw 缺失${NC}"
        ((ERRORS++))
    fi
done
echo ""

# 2. 检查架构支持
echo -e "${YELLOW}[2/8] 检查架构支持...${NC}"
for xcframework in "$FRAMEWORKS_DIR"/*.xcframework; do
    if [ -d "$xcframework" ]; then
        framework_name=$(basename "$xcframework")
        echo -e "${BLUE}检查: $framework_name${NC}"
        
        has_arm64=false
        has_simulator=false
        
        for arch_dir in "$xcframework"/ios-*; do
            if [ -d "$arch_dir" ]; then
                arch_name=$(basename "$arch_dir")
                if [[ "$arch_name" == *"arm64"* ]] && [[ "$arch_name" != *"simulator"* ]]; then
                    has_arm64=true
                    echo -e "${GREEN}  ✓ 支持 arm64 (真机)${NC}"
                fi
                if [[ "$arch_name" == *"simulator"* ]]; then
                    has_simulator=true
                    echo -e "${GREEN}  ✓ 支持模拟器${NC}"
                fi
            fi
        done
        
        if [ "$has_arm64" = false ]; then
            echo -e "${RED}  ✗ 缺少 arm64 架构（真机必需）${NC}"
            ((ERRORS++))
        fi
        
        if [ "$has_simulator" = false ]; then
            echo -e "${YELLOW}  ⚠ 缺少模拟器架构（开发建议）${NC}"
            ((WARNINGS++))
        fi
    fi
done
echo ""

# 3. 检查隐私清单
echo -e "${YELLOW}[3/8] 检查隐私清单文件...${NC}"
for xcframework in "$FRAMEWORKS_DIR"/*.xcframework; do
    if [ -d "$xcframework" ]; then
        framework_name=$(basename "$xcframework")
        echo -e "${BLUE}检查: $framework_name${NC}"
        
        privacy_found=false
        for arch_dir in "$xcframework"/ios-*; do
            for framework in "$arch_dir"/*.framework; do
                if [ -f "$framework/PrivacyInfo.xcprivacy" ]; then
                    privacy_found=true
                    echo -e "${GREEN}  ✓ 包含 PrivacyInfo.xcprivacy${NC}"
                    
                    # 验证 XML 格式
                    if plutil -lint "$framework/PrivacyInfo.xcprivacy" > /dev/null 2>&1; then
                        echo -e "${GREEN}  ✓ 隐私清单格式正确${NC}"
                    else
                        echo -e "${RED}  ✗ 隐私清单格式错误${NC}"
                        ((ERRORS++))
                    fi
                    break 2
                fi
            done
        done
        
        if [ "$privacy_found" = false ]; then
            echo -e "${YELLOW}  ⚠ 未找到隐私清单${NC}"
            ((WARNINGS++))
        fi
    fi
done
echo ""

# 4. 检查签名状态
echo -e "${YELLOW}[4/8] 检查代码签名...${NC}"
for xcframework in "$FRAMEWORKS_DIR"/*.xcframework; do
    if [ -d "$xcframework" ]; then
        framework_name=$(basename "$xcframework")
        echo -e "${BLUE}检查: $framework_name${NC}"
        
        for arch_dir in "$xcframework"/ios-*; do
            for framework in "$arch_dir"/*.framework; do
                if [ -d "$framework" ]; then
                    arch_name=$(basename "$arch_dir")
                    
                    # 检查是否已签名
                    if codesign -dv "$framework" 2>/dev/null; then
                        # 验证签名
                        if codesign --verify --deep --strict "$framework" 2>/dev/null; then
                            echo -e "${GREEN}  ✓ $arch_name 签名有效${NC}"
                        else
                            echo -e "${YELLOW}  ⚠ $arch_name 签名无效${NC}"
                            ((WARNINGS++))
                        fi
                    else
                        echo -e "${YELLOW}  ⚠ $arch_name 未签名（集成时会自动签名）${NC}"
                        ((WARNINGS++))
                    fi
                fi
            done
        done
    fi
done
echo ""

# 5. 检查 Bitcode
echo -e "${YELLOW}[5/8] 检查 Bitcode 设置...${NC}"
for xcframework in "$FRAMEWORKS_DIR"/*.xcframework; do
    if [ -d "$xcframework" ]; then
        framework_name=$(basename "$xcframework")
        
        for arch_dir in "$xcframework"/ios-*; do
            for framework in "$arch_dir"/*.framework; do
                if [ -d "$framework" ]; then
                    # 查找可执行文件
                    executable=$(find "$framework" -type f -perm +111 | head -1)
                    if [ -n "$executable" ]; then
                        if otool -l "$executable" | grep -q "__LLVM"; then
                            echo -e "${YELLOW}⚠ $framework_name 包含 Bitcode（App Store 已不再需要）${NC}"
                            ((WARNINGS++))
                        fi
                        break 2
                    fi
                fi
            done
        done
    fi
done
echo -e "${GREEN}✓ Bitcode 检查完成${NC}"
echo ""

# 6. 检查文件大小
echo -e "${YELLOW}[6/8] 检查文件大小...${NC}"
total_size=0
for xcframework in "$FRAMEWORKS_DIR"/*.xcframework; do
    if [ -d "$xcframework" ]; then
        framework_name=$(basename "$xcframework")
        size=$(du -sh "$xcframework" | awk '{print $1}')
        echo -e "${BLUE}$framework_name: ${YELLOW}$size${NC}"
        
        # 计算总大小（转换为字节）
        size_bytes=$(du -s "$xcframework" | awk '{print $1}')
        total_size=$((total_size + size_bytes))
    fi
done

# 转换为 MB
total_size_mb=$((total_size / 1024))
echo -e "${BLUE}总大小: ${YELLOW}${total_size_mb}MB${NC}"

if [ $total_size_mb -gt 200 ]; then
    echo -e "${YELLOW}⚠ Frameworks 总大小较大，可能影响下载速度${NC}"
    ((WARNINGS++))
else
    echo -e "${GREEN}✓ 文件大小合理${NC}"
fi
echo ""

# 7. 检查 Info.plist
echo -e "${YELLOW}[7/8] 检查主项目 Info.plist...${NC}"
if [ -f "ios/Runner/Info.plist" ]; then
    echo -e "${GREEN}✓ 找到 Info.plist${NC}"
    
    # 检查必需的隐私描述
    REQUIRED_KEYS=(
        "NSPhotoLibraryUsageDescription"
        "NSCameraUsageDescription"
        "NSUserTrackingUsageDescription"
    )
    
    for key in "${REQUIRED_KEYS[@]}"; do
        if /usr/libexec/PlistBuddy -c "Print :$key" "ios/Runner/Info.plist" > /dev/null 2>&1; then
            echo -e "${GREEN}  ✓ $key 已配置${NC}"
        else
            echo -e "${YELLOW}  ⚠ $key 未配置${NC}"
            ((WARNINGS++))
        fi
    done
    
    # 检查加密合规
    if /usr/libexec/PlistBuddy -c "Print :ITSAppUsesNonExemptEncryption" "ios/Runner/Info.plist" > /dev/null 2>&1; then
        echo -e "${GREEN}  ✓ ITSAppUsesNonExemptEncryption 已配置${NC}"
    else
        echo -e "${YELLOW}  ⚠ ITSAppUsesNonExemptEncryption 未配置${NC}"
        ((WARNINGS++))
    fi
else
    echo -e "${RED}✗ 未找到 Info.plist${NC}"
    ((ERRORS++))
fi
echo ""

# 8. 检查 PrivacyInfo.xcprivacy
echo -e "${YELLOW}[8/8] 检查项目隐私清单...${NC}"
if [ -f "ios/Runner/PrivacyInfo.xcprivacy" ]; then
    echo -e "${GREEN}✓ 找到 PrivacyInfo.xcprivacy${NC}"
    
    # 验证格式
    if plutil -lint "ios/Runner/PrivacyInfo.xcprivacy" > /dev/null 2>&1; then
        echo -e "${GREEN}  ✓ 格式正确${NC}"
        
        # 检查必需的 API 声明
        if grep -q "NSPrivacyAccessedAPICategoryUserDefaults" "ios/Runner/PrivacyInfo.xcprivacy"; then
            echo -e "${GREEN}  ✓ 包含 UserDefaults API 声明${NC}"
        else
            echo -e "${YELLOW}  ⚠ 缺少 UserDefaults API 声明${NC}"
            ((WARNINGS++))
        fi
        
        if grep -q "NSPrivacyAccessedAPICategoryFileTimestamp" "ios/Runner/PrivacyInfo.xcprivacy"; then
            echo -e "${GREEN}  ✓ 包含 FileTimestamp API 声明${NC}"
        else
            echo -e "${YELLOW}  ⚠ 缺少 FileTimestamp API 声明${NC}"
            ((WARNINGS++))
        fi
    else
        echo -e "${RED}  ✗ 格式错误${NC}"
        ((ERRORS++))
    fi
else
    echo -e "${RED}✗ 未找到 PrivacyInfo.xcprivacy${NC}"
    ((ERRORS++))
fi
echo ""

# 生成验证报告
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}验证完成！${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✓ 所有检查通过！Framework 已准备好提交到 App Store${NC}"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠ 发现 $WARNINGS 个警告${NC}"
    echo -e "${YELLOW}建议修复警告后再提交，但不是必需的${NC}"
    exit 0
else
    echo -e "${RED}✗ 发现 $ERRORS 个错误和 $WARNINGS 个警告${NC}"
    echo -e "${RED}请修复错误后再提交到 App Store${NC}"
    exit 1
fi
