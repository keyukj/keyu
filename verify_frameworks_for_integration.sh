#!/bin/bash

# Framework 集成前验证脚本
# 验证 frameworks 是否可以安全地嵌入到其他 iOS 项目

set -e

FRAMEWORKS_DIR="${1:-./build/frameworks/Release}"

echo "=========================================="
echo "Framework 集成验证工具"
echo "=========================================="
echo "验证目录: $FRAMEWORKS_DIR"
echo ""

if [ ! -d "$FRAMEWORKS_DIR" ]; then
    echo "❌ 错误: 目录不存在: $FRAMEWORKS_DIR"
    exit 1
fi

# 验证项目
all_passed=true

for xcframework in "$FRAMEWORKS_DIR"/*.xcframework; do
    if [ ! -d "$xcframework" ]; then
        continue
    fi
    
    framework_name=$(basename "$xcframework")
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "验证: $framework_name"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # 检查架构
    echo "1. 检查架构..."
    has_arm64=false
    has_simulator=false
    
    for arch_dir in "$xcframework"/ios-*; do
        if [ -d "$arch_dir" ]; then
            arch_name=$(basename "$arch_dir")
            echo "   ✓ $arch_name"
            
            if [[ "$arch_name" == *"arm64"* ]] && [[ "$arch_name" != *"simulator"* ]]; then
                has_arm64=true
            fi
            if [[ "$arch_name" == *"simulator"* ]]; then
                has_simulator=true
            fi
        fi
    done
    
    if [ "$has_arm64" = false ]; then
        echo "   ✗ 缺少真机架构 (arm64)"
        all_passed=false
    fi
    
    # 检查每个 framework
    for arch_dir in "$xcframework"/ios-*; do
        for framework in "$arch_dir"/*.framework; do
            if [ ! -d "$framework" ]; then
                continue
            fi
            
            arch_name=$(basename "$arch_dir")
            fw_name=$(basename "$framework")
            
            echo ""
            echo "架构: $arch_name"
            
            # 2. 验证签名
            echo "2. 验证签名..."
            if codesign --verify --deep --strict "$framework" 2>/dev/null; then
                signing_identity=$(codesign -dvv "$framework" 2>&1 | grep "Authority=" | head -1 | cut -d= -f2)
                team_id=$(codesign -dvv "$framework" 2>&1 | grep "TeamIdentifier=" | cut -d= -f2)
                echo "   ✓ 签名有效"
                echo "   ✓ 证书: $signing_identity"
                echo "   ✓ Team ID: $team_id"
            else
                echo "   ✗ 签名验证失败"
                all_passed=false
            fi
            
            # 3. 检查二进制文件
            echo "3. 检查二进制文件..."
            binary_file="$framework/$(basename "$framework" .framework)"
            if [ -f "$binary_file" ]; then
                file_info=$(file "$binary_file")
                if echo "$file_info" | grep -q "Mach-O"; then
                    echo "   ✓ 二进制文件存在"
                    
                    # 检查架构
                    if lipo -info "$binary_file" 2>/dev/null; then
                        echo "   ✓ 架构信息正常"
                    fi
                else
                    echo "   ✗ 二进制文件格式错误"
                    all_passed=false
                fi
            else
                echo "   ✗ 二进制文件不存在"
                all_passed=false
            fi
            
            # 4. 检查 Info.plist
            echo "4. 检查 Info.plist..."
            if [ -f "$framework/Info.plist" ]; then
                bundle_id=$(/usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" "$framework/Info.plist" 2>/dev/null || echo "")
                if [ -n "$bundle_id" ]; then
                    echo "   ✓ Info.plist 存在"
                    echo "   ✓ Bundle ID: $bundle_id"
                else
                    echo "   ⚠ Info.plist 存在但无法读取 Bundle ID"
                fi
            else
                echo "   ✗ Info.plist 不存在"
                all_passed=false
            fi
            
            # 5. 检查隐私清单
            echo "5. 检查隐私清单..."
            if [ -f "$framework/PrivacyInfo.xcprivacy" ]; then
                echo "   ✓ PrivacyInfo.xcprivacy 存在"
            else
                echo "   ⚠ PrivacyInfo.xcprivacy 不存在 (可选)"
            fi
            
            # 6. 检查代码签名详情
            echo "6. 检查代码签名详情..."
            signature_size=$(codesign -dvv "$framework" 2>&1 | grep "Signature size=" | cut -d= -f2)
            if [ -n "$signature_size" ]; then
                echo "   ✓ 签名大小: $signature_size bytes"
            fi
            
            # 只检查第一个 framework
            break
        done
        break
    done
    
    echo ""
done

echo "=========================================="
if [ "$all_passed" = true ]; then
    echo "✅ 所有验证通过"
    echo "=========================================="
    echo ""
    echo "Frameworks 可以安全地嵌入到其他 iOS 项目"
    echo ""
    echo "集成步骤:"
    echo "1. 将所有 .xcframework 文件拖入 Xcode 项目"
    echo "2. 在 Target -> General -> Frameworks, Libraries, and Embedded Content"
    echo "3. 设置所有 frameworks 为 'Embed & Sign'"
    echo "4. 在 Build Settings 中添加:"
    echo "   - Other Linker Flags: -ObjC"
    echo "   - Enable Bitcode: NO"
    echo "5. 配置隐私权限描述"
    echo ""
    exit 0
else
    echo "❌ 部分验证失败"
    echo "=========================================="
    echo ""
    echo "请修复上述问题后再集成到其他项目"
    echo "建议重新运行: ./build_framework.sh"
    echo ""
    exit 1
fi
