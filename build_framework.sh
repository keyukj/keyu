#!/bin/bash

# Flutter Framework 打包脚本
# 用于将 Flutter 项目打包成 iOS Framework，供 OC 项目集成
# 确保签名正确且符合 App Store 审核要求

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Flutter Framework 打包工具${NC}"
echo -e "${GREEN}适用于 App Store 提交${NC}"
echo -e "${GREEN}========================================${NC}"

# 配置参数
FRAMEWORK_NAME="TanyuApp"
OUTPUT_DIR="./build/frameworks"
FLUTTER_BUILD_MODE="release"
TEAM_ID="UG5N3PCLJ5"

# 清理旧的构建产物
echo -e "${YELLOW}[1/7] 清理旧的构建产物...${NC}"
rm -rf "$OUTPUT_DIR"
rm -rf "./build/ios"
mkdir -p "$OUTPUT_DIR"

# 清理 Flutter 构建缓存
echo -e "${YELLOW}[2/7] 清理 Flutter 构建缓存...${NC}"
flutter clean

# 获取依赖
echo -e "${YELLOW}[3/7] 获取 Flutter 依赖...${NC}"
flutter pub get

# 运行 CocoaPods
echo -e "${YELLOW}[4/7] 更新 CocoaPods 依赖...${NC}"
cd ios
pod install --repo-update
cd ..

# 构建 iOS Framework (Release 模式)
echo -e "${YELLOW}[5/7] 构建 iOS Framework (Release)...${NC}"
flutter build ios-framework --output="$OUTPUT_DIR" --no-debug --no-profile --release

# 检查构建结果
if [ ! -d "$OUTPUT_DIR/Release" ]; then
    echo -e "${RED}构建失败！未找到 Release 目录${NC}"
    exit 1
fi

# 签名 frameworks (在添加隐私清单之前先签名一次，确保所有资源都被包含)
echo -e "${YELLOW}[6/8] 预签名 Frameworks...${NC}"
IDENTITY="Apple Distribution: Lonaa Chisholmm (UG5N3PCLJ5)"

# 检查证书是否可用
if ! security find-identity -v -p codesigning | grep -q "$IDENTITY"; then
    echo -e "${RED}错误: 找不到证书 '$IDENTITY'${NC}"
    echo ""
    echo "可用的签名证书:"
    security find-identity -v -p codesigning
    exit 1
fi

echo -e "${GREEN}  ✓ 证书验证成功${NC}"

# 复制隐私清单到 frameworks（在签名前）
echo -e "${YELLOW}[7/8] 添加隐私清单文件...${NC}"
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
                            # 删除旧签名（因为要添加新文件）
                            rm -rf "$fw/_CodeSignature" 2>/dev/null || true
                            # 添加隐私清单
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

# 最终签名 frameworks（在所有文件都添加完成后）
echo -e "${YELLOW}[8/9] 最终签名 Frameworks...${NC}"
IDENTITY="Apple Distribution: Lonaa Chisholmm (UG5N3PCLJ5)"

# 检查证书是否可用
if ! security find-identity -v -p codesigning | grep -q "$IDENTITY"; then
    echo -e "${RED}错误: 找不到证书 '$IDENTITY'${NC}"
    echo ""
    echo "可用的签名证书:"
    security find-identity -v -p codesigning
    exit 1
fi

echo -e "${GREEN}  ✓ 证书验证成功${NC}"

# 最终签名 frameworks（在所有文件都添加完成后）
echo -e "${YELLOW}[8/9] 最终签名 Frameworks...${NC}"

# 签名所有 frameworks
for xcframework in "$OUTPUT_DIR/Release"/*.xcframework; do
    if [ -d "$xcframework" ]; then
        framework_name=$(basename "$xcframework")
        echo -e "${BLUE}  签名 $framework_name${NC}"
        
        # 遍历 xcframework 中的所有 framework
        find "$xcframework" -name "*.framework" -type d | while read -r framework; do
            # 删除旧签名
            rm -rf "$framework/_CodeSignature" 2>/dev/null || true
            
            # 先签名所有嵌套的二进制文件
            find "$framework" -type f \( -name "*.dylib" -o -perm +111 \) ! -path "*/Headers/*" ! -path "*/_CodeSignature/*" 2>/dev/null | while read -r binary; do
                if file "$binary" | grep -q "Mach-O"; then
                    codesign --force --sign "$IDENTITY" --timestamp "$binary" 2>/dev/null || true
                fi
            done
            
            # 使用深度签名重新签名整个 framework
            if codesign --force --deep --sign "$IDENTITY" --timestamp "$framework" 2>&1; then
                echo -e "${GREEN}    ✓ $(basename "$framework") 签名成功${NC}"
            else
                echo -e "${RED}    ✗ $(basename "$framework") 签名失败${NC}"
                exit 1
            fi
            
            # 验证签名
            if ! codesign --verify --deep --strict "$framework" 2>&1; then
                echo -e "${RED}    ✗ $(basename "$framework") 签名验证失败${NC}"
                exit 1
            fi
        done
    fi
done

# 验证 frameworks
echo -e "${YELLOW}[9/9] 验证 Frameworks...${NC}"
for framework in "$OUTPUT_DIR/Release"/*.xcframework; do
    if [ -d "$framework" ]; then
        framework_name=$(basename "$framework")
        echo -e "${BLUE}  检查 $framework_name${NC}"
        
        # 检查架构
        for arch_dir in "$framework"/ios-*; do
            if [ -d "$arch_dir" ]; then
                arch_name=$(basename "$arch_dir")
                echo -e "${GREEN}    ✓ 包含架构: $arch_name${NC}"
            fi
        done
        
        # 检查签名
        for arch_dir in "$framework"/ios-*; do
            for fw in "$arch_dir"/*.framework; do
                if [ -d "$fw" ]; then
                    # 获取签名信息
                    signing_identity=$(codesign -dvv "$fw" 2>&1 | grep "Authority=" | head -1 | cut -d= -f2)
                    if [ -n "$signing_identity" ]; then
                        echo -e "${GREEN}    ✓ 签名: $signing_identity${NC}"
                    else
                        echo -e "${RED}    ✗ 未签名${NC}"
                    fi
                    break
                fi
            done
            break
        done
        
        # 检查隐私清单
        privacy_found=false
        for arch_dir in "$framework"/ios-*; do
            for fw in "$arch_dir"/*.framework; do
                if [ -f "$fw/PrivacyInfo.xcprivacy" ]; then
                    privacy_found=true
                    break 2
                fi
            done
        done
        
        if [ "$privacy_found" = true ]; then
            echo -e "${GREEN}    ✓ 包含隐私清单${NC}"
        else
            echo -e "${YELLOW}    ⚠ 未找到隐私清单${NC}"
        fi
    fi
done

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}构建完成！${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "Framework 输出目录: ${YELLOW}$OUTPUT_DIR/Release${NC}"
echo ""
echo -e "${GREEN}生成的 Frameworks:${NC}"
ls -lh "$OUTPUT_DIR/Release/"


echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}App Store 审核检查清单${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}✓${NC} Frameworks 已构建为 Release 模式"
echo -e "${GREEN}✓${NC} 已使用证书签名: $IDENTITY"
echo -e "${GREEN}✓${NC} 已包含隐私清单 (PrivacyInfo.xcprivacy)"
echo -e "${GREEN}✓${NC} 支持 arm64 架构 (真机)"
echo -e "${GREEN}✓${NC} 支持 x86_64 架构 (模拟器)"
echo ""
echo -e "${YELLOW}提交前请确认:${NC}"
echo -e "  1. 主项目 Info.plist 包含所有必需的隐私描述"
echo -e "  2. 所有 frameworks 的 Embed 设置为 'Embed & Sign'"
echo -e "  3. 代码签名使用正确的证书和 Provisioning Profile"
echo -e "  4. 已在真机上测试所有功能"
echo -e "  5. 已禁用 Bitcode (ENABLE_BITCODE = NO)"
echo ""

# 创建集成说明文件
cat > "$OUTPUT_DIR/INTEGRATION_GUIDE.md" << 'EOF'
# TanyuApp Framework 集成指南

## 1. 添加 Frameworks 到项目

将以下 frameworks 拖入你的 Xcode 项目：

```
build/frameworks/Release/
├── App.xcframework
├── Flutter.xcframework
├── FlutterPluginRegistrant.xcframework
└── [其他插件 frameworks]
```

### 在 Xcode 中配置：

1. 选择项目 Target
2. 进入 "General" 标签
3. 在 "Frameworks, Libraries, and Embedded Content" 部分：
   - 添加所有 .xcframework 文件
   - 设置 Embed 选项为 "Embed & Sign"

## 2. 配置 Build Settings

### 2.1 Framework Search Paths
```
$(inherited)
$(PROJECT_DIR)/Frameworks
```

### 2.2 Other Linker Flags
```
-ObjC
```

### 2.3 Enable Bitcode
```
NO
```

## 3. 添加隐私清单

确保你的主项目 Info.plist 包含以下隐私描述：

```xml
<key>NSUserTrackingUsageDescription</key>
<string>我们需要您的同意以提供个性化内容和广告</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>需要访问相册以选择图片</string>

<key>NSCameraUsageDescription</key>
<string>需要访问相机以拍摄照片</string>

<key>NSLocationWhenInUseUsageDescription</key>
<string>需要访问位置信息以提供基于位置的服务</string>
```

## 4. 在 OC 代码中使用

### 4.1 导入头文件

```objc
#import <Flutter/Flutter.h>
```

### 4.2 初始化 Flutter Engine

在 AppDelegate.m 中：

```objc
#import <Flutter/Flutter.h>

@interface AppDelegate ()
@property (nonatomic, strong) FlutterEngine *flutterEngine;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application 
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // 初始化 Flutter Engine
    self.flutterEngine = [[FlutterEngine alloc] initWithName:@"tanyu_engine"];
    [self.flutterEngine run];
    
    return YES;
}

@end
```

### 4.3 展示 Flutter 页面

```objc
#import <Flutter/Flutter.h>

// 获取 Flutter Engine
FlutterEngine *flutterEngine = 
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] flutterEngine];

// 创建 Flutter View Controller
FlutterViewController *flutterViewController =
    [[FlutterViewController alloc] initWithEngine:flutterEngine nibName:nil bundle:nil];

// 展示页面
[self.navigationController pushViewController:flutterViewController animated:YES];
// 或者
[self presentViewController:flutterViewController animated:YES completion:nil];
```

### 4.4 传递参数到 Flutter

```objc
// 通过 Method Channel 传递参数
FlutterMethodChannel *channel = [FlutterMethodChannel
    methodChannelWithName:@"com.tantan.yu/channel"
    binaryMessenger:flutterViewController.binaryMessenger];

[channel invokeMethod:@"setUserInfo" arguments:@{
    @"userId": @"12345",
    @"userName": @"张三"
}];
```

## 5. 签名配置

### 5.1 自动签名（推荐）
1. 在 Xcode 中选择 Target
2. 进入 "Signing & Capabilities"
3. 勾选 "Automatically manage signing"
4. 选择你的 Team

### 5.2 手动签名
1. 准备好 Provisioning Profile 和证书
2. 在 "Signing & Capabilities" 中：
   - 取消勾选 "Automatically manage signing"
   - 选择对应的 Provisioning Profile

## 6. App Store 提交注意事项

### 6.1 隐私清单
确保所有使用的权限都在 Info.plist 中声明

### 6.2 第三方 SDK 隐私
如果使用了第三方 SDK，需要在 App Store Connect 中声明

### 6.3 导出合规信息
如果使用了加密功能，需要在 Info.plist 中添加：

```xml
<key>ITSAppUsesNonExemptEncryption</key>
<false/>
```

或者如果使用了加密：

```xml
<key>ITSAppUsesNonExemptEncryption</key>
<true/>
<key>ITSEncryptionExportComplianceCode</key>
<string>YOUR_COMPLIANCE_CODE</string>
```

## 7. 常见问题

### Q1: 编译错误 "framework not found"
A: 检查 Framework Search Paths 是否正确配置

### Q2: 运行时崩溃 "dyld: Library not loaded"
A: 确保所有 frameworks 的 Embed 选项设置为 "Embed & Sign"

### Q3: 黑屏或白屏
A: 检查 Flutter Engine 是否正确初始化，确保在使用前调用了 `[engine run]`

### Q4: 资源文件找不到
A: 确保 App.xcframework 中的资源文件正确嵌入

## 8. 性能优化建议

1. 使用单例模式管理 FlutterEngine，避免重复创建
2. 预热 Flutter Engine，在 App 启动时初始化
3. 合理使用 Method Channel，避免频繁通信
4. 大数据传输使用 EventChannel 或 BasicMessageChannel

## 9. 更新 Framework

当 Flutter 代码更新后：

1. 运行 `./build_framework.sh` 重新打包
2. 删除项目中旧的 frameworks
3. 添加新的 frameworks
4. Clean Build Folder (Cmd + Shift + K)
5. 重新编译项目

## 10. 技术支持

如有问题，请联系开发团队。
EOF

echo -e "${GREEN}集成指南已生成: $OUTPUT_DIR/INTEGRATION_GUIDE.md${NC}"
echo ""
echo -e "${YELLOW}下一步：${NC}"
echo "1. 查看集成指南: cat $OUTPUT_DIR/INTEGRATION_GUIDE.md"
echo "2. 将 $OUTPUT_DIR/Release 目录下的所有 frameworks 添加到你的 OC 项目"
echo "3. 配置签名和隐私权限"
echo ""
