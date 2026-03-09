#!/bin/bash

# iOS 签名配置脚本
# 用于配置 Framework 的代码签名，确保能通过 App Store 审核

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}iOS Framework 签名配置工具${NC}"
echo -e "${GREEN}========================================${NC}"

# 配置参数
TEAM_ID="UG5N3PCLJ5"
BUNDLE_ID="com.tantan.yu"
FRAMEWORKS_DIR="./build/frameworks/Release"

# 检查 frameworks 目录是否存在
if [ ! -d "$FRAMEWORKS_DIR" ]; then
    echo -e "${RED}错误: Frameworks 目录不存在${NC}"
    echo -e "${YELLOW}请先运行 ./build_framework.sh 构建 frameworks${NC}"
    exit 1
fi

echo -e "${BLUE}Team ID: ${YELLOW}$TEAM_ID${NC}"
echo -e "${BLUE}Bundle ID: ${YELLOW}$BUNDLE_ID${NC}"
echo ""

# 检查可用的签名身份
echo -e "${YELLOW}[1/4] 检查可用的签名身份...${NC}"
echo -e "${BLUE}可用的 Distribution 证书:${NC}"
security find-identity -v -p codesigning | grep "Apple Distribution" || {
    echo -e "${RED}未找到 Apple Distribution 证书${NC}"
    echo -e "${YELLOW}请在 Xcode 中配置证书或访问 developer.apple.com${NC}"
    exit 1
}

# 获取第一个可用的 Distribution 证书
SIGNING_IDENTITY=$(security find-identity -v -p codesigning | grep "Apple Distribution" | head -1 | awk -F'"' '{print $2}')
echo -e "${GREEN}将使用证书: $SIGNING_IDENTITY${NC}"
echo ""

# 检查 Provisioning Profiles
echo -e "${YELLOW}[2/4] 检查 Provisioning Profiles...${NC}"
PROFILES_DIR="$HOME/Library/MobileDevice/Provisioning Profiles"
if [ -d "$PROFILES_DIR" ]; then
    echo -e "${GREEN}找到 Provisioning Profiles 目录${NC}"
    PROFILE_COUNT=$(ls -1 "$PROFILES_DIR"/*.mobileprovision 2>/dev/null | wc -l)
    echo -e "${BLUE}已安装的 Profiles 数量: $PROFILE_COUNT${NC}"
else
    echo -e "${YELLOW}警告: 未找到 Provisioning Profiles 目录${NC}"
fi
echo ""

# 为每个 framework 配置签名
echo -e "${YELLOW}[3/4] 配置 Frameworks 签名...${NC}"
for xcframework in "$FRAMEWORKS_DIR"/*.xcframework; do
    if [ -d "$xcframework" ]; then
        framework_name=$(basename "$xcframework" .xcframework)
        echo -e "${BLUE}处理: $framework_name${NC}"
        
        # 遍历 xcframework 中的所有架构
        for arch_dir in "$xcframework"/ios-*; do
            if [ -d "$arch_dir" ]; then
                arch_name=$(basename "$arch_dir")
                
                # 查找 .framework 目录
                for framework in "$arch_dir"/*.framework; do
                    if [ -d "$framework" ]; then
                        # 检查是否已签名
                        if codesign -dv "$framework" 2>/dev/null; then
                            echo -e "${GREEN}  ✓ $arch_name 已签名${NC}"
                        else
                            echo -e "${YELLOW}  ⚠ $arch_name 未签名${NC}"
                        fi
                        
                        # 验证签名
                        if codesign --verify --deep --strict "$framework" 2>/dev/null; then
                            echo -e "${GREEN}  ✓ $arch_name 签名有效${NC}"
                        else
                            echo -e "${YELLOW}  ⚠ $arch_name 签名无效或未签名${NC}"
                        fi
                    fi
                done
            fi
        done
        echo ""
    fi
done

# 生成签名配置文件
echo -e "${YELLOW}[4/4] 生成签名配置文件...${NC}"
cat > "./build/frameworks/SIGNING_CONFIG.md" << EOF
# Framework 签名配置

## 签名信息

- **Team ID:** $TEAM_ID
- **Bundle ID:** $BUNDLE_ID
- **签名身份:** $SIGNING_IDENTITY

## 在 Xcode 中配置签名

### 方法 1: 自动签名（推荐）

1. 打开你的 Xcode 项目
2. 选择项目 Target
3. 进入 "Signing & Capabilities" 标签
4. 勾选 "Automatically manage signing"
5. 选择 Team: **$TEAM_ID**
6. 确保 Bundle Identifier 为: **$BUNDLE_ID**

### 方法 2: 手动签名

1. 打开你的 Xcode 项目
2. 选择项目 Target
3. 进入 "Signing & Capabilities" 标签
4. 取消勾选 "Automatically manage signing"
5. 配置以下选项：
   - **Signing Certificate:** Apple Distribution
   - **Provisioning Profile:** 选择匹配 $BUNDLE_ID 的 Profile
   - **Team:** $TEAM_ID

## 验证签名

在终端中运行以下命令验证 framework 签名：

\`\`\`bash
# 验证单个 framework
codesign --verify --deep --strict ./build/frameworks/Release/App.xcframework

# 验证所有 frameworks
for fw in ./build/frameworks/Release/*.xcframework; do
    echo "验证: \$(basename \$fw)"
    codesign --verify --deep --strict "\$fw"
done
\`\`\`

## 重新签名 Framework

如果需要重新签名 framework：

\`\`\`bash
# 重新签名单个 framework
codesign --force --sign "$SIGNING_IDENTITY" --timestamp ./build/frameworks/Release/App.xcframework

# 重新签名所有 frameworks
for fw in ./build/frameworks/Release/*.xcframework; do
    echo "签名: \$(basename \$fw)"
    codesign --force --sign "$SIGNING_IDENTITY" --timestamp "\$fw"
done
\`\`\`

## 常见问题

### Q1: 签名失败 "errSecInternalComponent"

**解决方案:**
- 打开 Keychain Access
- 确保证书和私钥都在 "login" keychain 中
- 右键点击证书 → Get Info → Trust → Code Signing → Always Trust

### Q2: 签名失败 "no identity found"

**解决方案:**
- 在 Xcode 中下载证书: Preferences → Accounts → Download Manual Profiles
- 或访问 developer.apple.com 下载证书

### Q3: Provisioning Profile 不匹配

**解决方案:**
- 确保 Bundle ID 与 Profile 匹配
- 在 developer.apple.com 创建新的 Profile
- 下载并双击安装 Profile

## 提交到 App Store

1. 确保所有 frameworks 签名有效
2. 在 Xcode 中 Archive 项目
3. 选择 "Distribute App" → "App Store Connect"
4. 选择正确的签名选项
5. 上传到 App Store Connect

---

生成时间: $(date)
EOF

echo -e "${GREEN}签名配置文件已生成: ./build/frameworks/SIGNING_CONFIG.md${NC}"
echo ""

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}签名配置完成！${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}下一步:${NC}"
echo "1. 查看签名配置: cat ./build/frameworks/SIGNING_CONFIG.md"
echo "2. 在 Xcode 中配置项目签名"
echo "3. 将 frameworks 添加到项目并设置 'Embed & Sign'"
echo "4. 在真机上测试"
echo ""
