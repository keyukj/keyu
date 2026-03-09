#!/bin/bash

# 一键打包脚本
# 自动完成构建、验证、签名配置等所有步骤

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

clear

echo -e "${CYAN}"
echo "╔════════════════════════════════════════════════════════════╗"
echo "║                                                            ║"
echo "║          TanyuApp Framework 一键打包工具                   ║"
echo "║          App Store 提交专用                                ║"
echo "║                                                            ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""

# 检查必需的工具
echo -e "${YELLOW}检查环境...${NC}"
command -v flutter >/dev/null 2>&1 || { echo -e "${RED}错误: 未找到 Flutter${NC}"; exit 1; }
command -v pod >/dev/null 2>&1 || { echo -e "${RED}错误: 未找到 CocoaPods${NC}"; exit 1; }
command -v xcodebuild >/dev/null 2>&1 || { echo -e "${RED}错误: 未找到 Xcode${NC}"; exit 1; }
echo -e "${GREEN}✓ 环境检查通过${NC}"
echo ""

# 显示当前配置
echo -e "${BLUE}当前配置:${NC}"
echo -e "  Flutter 版本: ${YELLOW}$(flutter --version | head -1)${NC}"
echo -e "  Team ID: ${YELLOW}UG5N3PCLJ5${NC}"
echo -e "  Bundle ID: ${YELLOW}com.tantan.yu${NC}"
echo ""

# 询问是否继续
read -p "$(echo -e ${CYAN}是否开始打包？[Y/n]: ${NC})" -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]] && [[ ! -z $REPLY ]]; then
    echo -e "${YELLOW}已取消${NC}"
    exit 0
fi

echo ""
echo -e "${CYAN}════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}开始打包流程...${NC}"
echo -e "${CYAN}════════════════════════════════════════════════════════════${NC}"
echo ""

# 步骤 1: 构建 Framework
echo -e "${GREEN}[步骤 1/3] 构建 Framework${NC}"
echo -e "${BLUE}────────────────────────────────────────────────────────────${NC}"
if ./build_framework.sh; then
    echo -e "${GREEN}✓ Framework 构建成功${NC}"
else
    echo -e "${RED}✗ Framework 构建失败${NC}"
    exit 1
fi
echo ""

# 步骤 2: 验证 Framework
echo -e "${GREEN}[步骤 2/3] 验证 Framework${NC}"
echo -e "${BLUE}────────────────────────────────────────────────────────────${NC}"
if ./verify_framework.sh; then
    echo -e "${GREEN}✓ Framework 验证通过${NC}"
else
    echo -e "${YELLOW}⚠ Framework 验证发现问题，但可以继续${NC}"
fi
echo ""

# 步骤 3: 配置签名
echo -e "${GREEN}[步骤 3/3] 配置签名${NC}"
echo -e "${BLUE}────────────────────────────────────────────────────────────${NC}"
if ./configure_signing.sh; then
    echo -e "${GREEN}✓ 签名配置完成${NC}"
else
    echo -e "${YELLOW}⚠ 签名配置遇到问题，请手动检查${NC}"
fi
echo ""

# 完成
echo -e "${CYAN}════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✓ 打包流程完成！${NC}"
echo -e "${CYAN}════════════════════════════════════════════════════════════${NC}"
echo ""

# 显示输出位置
echo -e "${BLUE}Framework 输出位置:${NC}"
echo -e "  ${YELLOW}./build/frameworks/Release/${NC}"
echo ""

# 显示生成的文件
echo -e "${BLUE}生成的 Frameworks:${NC}"
ls -1 ./build/frameworks/Release/ | while read file; do
    echo -e "  ${GREEN}✓${NC} $file"
done
echo ""

# 显示文档
echo -e "${BLUE}相关文档:${NC}"
echo -e "  ${CYAN}1.${NC} 集成指南: ${YELLOW}./build/frameworks/INTEGRATION_GUIDE.md${NC}"
echo -e "  ${CYAN}2.${NC} 签名配置: ${YELLOW}./build/frameworks/SIGNING_CONFIG.md${NC}"
echo -e "  ${CYAN}3.${NC} App Store 提交指南: ${YELLOW}./APP_STORE_SUBMISSION_GUIDE.md${NC}"
echo -e "  ${CYAN}4.${NC} 检查清单: ${YELLOW}./CHECKLIST.md${NC}"
echo ""

# 下一步提示
echo -e "${CYAN}════════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}下一步操作:${NC}"
echo -e "${CYAN}════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${GREEN}1.${NC} 将 frameworks 集成到你的 OC 项目"
echo -e "   ${BLUE}→${NC} 拖入 ${YELLOW}./build/frameworks/Release/${NC} 下的所有 .xcframework"
echo -e "   ${BLUE}→${NC} 设置 Embed 为 ${YELLOW}'Embed & Sign'${NC}"
echo ""
echo -e "${GREEN}2.${NC} 配置 Xcode 项目"
echo -e "   ${BLUE}→${NC} 设置 Framework Search Paths"
echo -e "   ${BLUE}→${NC} 设置 Other Linker Flags: ${YELLOW}-ObjC${NC}"
echo -e "   ${BLUE}→${NC} 设置 Enable Bitcode: ${YELLOW}NO${NC}"
echo ""
echo -e "${GREEN}3.${NC} 配置签名"
echo -e "   ${BLUE}→${NC} 选择正确的 Team 和 Provisioning Profile"
echo -e "   ${BLUE}→${NC} 确保 Bundle ID 为: ${YELLOW}com.tantan.yu${NC}"
echo ""
echo -e "${GREEN}4.${NC} 在真机上测试"
echo -e "   ${BLUE}→${NC} 测试所有功能是否正常"
echo -e "   ${BLUE}→${NC} 检查性能和稳定性"
echo ""
echo -e "${GREEN}5.${NC} Archive 并提交"
echo -e "   ${BLUE}→${NC} Product → Archive"
echo -e "   ${BLUE}→${NC} Distribute App → App Store Connect"
echo ""

# 快速命令提示
echo -e "${CYAN}════════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}快速命令:${NC}"
echo -e "${CYAN}════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${BLUE}# 查看集成指南${NC}"
echo -e "${YELLOW}cat ./build/frameworks/INTEGRATION_GUIDE.md${NC}"
echo ""
echo -e "${BLUE}# 查看 App Store 提交指南${NC}"
echo -e "${YELLOW}cat ./APP_STORE_SUBMISSION_GUIDE.md${NC}"
echo ""
echo -e "${BLUE}# 查看检查清单${NC}"
echo -e "${YELLOW}cat ./CHECKLIST.md${NC}"
echo ""
echo -e "${BLUE}# 重新验证 Framework${NC}"
echo -e "${YELLOW}./verify_framework.sh${NC}"
echo ""

echo -e "${GREEN}祝你提交顺利！🚀${NC}"
echo ""
