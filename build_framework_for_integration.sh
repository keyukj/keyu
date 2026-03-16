#!/bin/bash

# Flutter Framework 打包脚本 - 用于嵌入其他 App
# Flutter.xcframework 保持官方签名，其他 framework 使用本地签名

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Flutter Framework 打包工具${NC}"
echo -e "${GREEN}用于嵌入其他 App${NC}"
echo -e "${GREEN}========================================${NC}"

# 配置参数
FRAMEWORK_NAME="TanyuApp"
OUTPUT_DIR="./build/frameworks"
FLUTTER_BUILD_MODE="release"

# 获取本地签名证书
echo -e "${YELLOW}检测本地签名证书...${NC}"
echo ""
echo "可用的签名证书:"
security find-identity -v -p codesigning

echo ""
echo -e "${YELLOW}请选择签名方式:${NC}"
echo "1) Apple Development (开发证书)"
echo "2) Apple Distribution (发布证书)"
echo "3) 输入自定义证书名称"
echo "4) 不签名（仅打包）"
read -p "请选择 (1-4): " sign_choice

case $sign_choice in
    1)
        # 查找开发证书
        IDENTITY=$(security find-identity -v -p codesigning | grep "Apple Development" | head -1 | sed 's/.*"\(.*\)"/\1/')
        if [ -z "$IDENTITY" ]; then
            echo -e "${RED}未找到 Apple Development 证书${NC}"
            exit 1
        fi
        ;;
    2)
        # 使用指定证书的 SHA-1 哈希值（避免歧义）
        IDENTITY="DF8FC93F64E2EDC2E723F14C36FBF9E8F0E4B119"
        if ! security find-identity -v -p codesigning | grep -q "$IDENTITY"; then
            echo -e "${RED}未找到证书: $IDENTITY${NC}"
            exit 1
        fi
        ;;
    3)
        read -p "请输入证书名称: " IDENTITY
        if ! security find-identity -v -p codesigning | grep -q "$IDENTITY"; then
            echo -e "${RED}未找到证书: $IDENTITY${NC}"
            exit 1
        fi
        ;;
    4)
        IDENTITY=""
        echo -e "${YELLOW}将不对 frameworks 进行签名${NC}"
        ;;
    *)
        echo -e "${RED}无效的选择${NC}"
        exit 1
        ;;
esac

if [ -n "$IDENTITY" ]; then
    echo -e "${GREEN}将使用证书: $IDENTITY${NC}"
fi

# 清理旧的构建产物
echo ""
echo -e "${YELLOW}[1/6] 清理旧的构建产物...${NC}"
rm -rf "$OUTPUT_DIR" 2>/dev/null || true
rm -rf "./build/ios" 2>/dev/null || true
# 强制清理
if [ -d "$OUTPUT_DIR" ]; then
    find "$OUTPUT_DIR" -type f -delete 2>/dev/null || true
    find "$OUTPUT_DIR" -type d -delete 2>/dev/null || true
fi
mkdir -p "$OUTPUT_DIR"

# 清理 Flutter 构建缓存
echo -e "${YELLOW}[2/6] 清理 Flutter 构建缓存...${NC}"
flutter clean

# 获取依赖
echo -e "${YELLOW}[3/6] 获取 Flutter 依赖...${NC}"
flutter pub get

# 构建 iOS Framework (Release 模式)
echo -e "${YELLOW}[4/6] 构建 iOS Framework (Release)...${NC}"
flutter build ios-framework --output="$OUTPUT_DIR" --no-debug --no-profile --release

# 检查构建结果
if [ ! -d "$OUTPUT_DIR/Release" ]; then
    echo -e "${RED}构建失败！未找到 Release 目录${NC}"
    exit 1
fi

echo -e "${GREEN}  ✓ Framework 构建完成${NC}"

# 添加隐私清单到非 Flutter.xcframework 的 frameworks
echo ""
echo -e "${YELLOW}[5/6] 添加隐私清单文件...${NC}"
if [ -f "ios/Runner/PrivacyInfo.xcprivacy" ]; then
    for framework in "$OUTPUT_DIR/Release"/*.xcframework; do
        if [ -d "$framework" ]; then
            framework_name=$(basename "$framework" .xcframework)
            
            # 跳过 Flutter.xcframework（保持官方签名）
            if [ "$framework_name" = "Flutter" ]; then
                echo -e "${BLUE}  跳过 Flutter.xcframework (保持官方签名)${NC}"
                continue
            fi
            
            echo -e "${BLUE}  添加隐私清单到 $framework_name${NC}"
            
            # 遍历 xcframework 中的所有架构
            for arch_dir in "$framework"/ios-*; do
                if [ -d "$arch_dir" ]; then
                    for fw in "$arch_dir"/*.framework; do
                        if [ -d "$fw" ]; then
                            # 删除旧签名
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

# 签名 frameworks（跳过 Flutter.xcframework）
echo ""
echo -e "${YELLOW}[6/6] 签名 Frameworks...${NC}"

if [ -z "$IDENTITY" ]; then
    echo -e "${YELLOW}  跳过签名步骤${NC}"
else
    for xcframework in "$OUTPUT_DIR/Release"/*.xcframework; do
        if [ -d "$xcframework" ]; then
            framework_name=$(basename "$xcframework" .xcframework)
            
            # 跳过 Flutter.xcframework（保持官方签名）
            if [ "$framework_name" = "Flutter" ]; then
                echo -e "${BLUE}  跳过 Flutter.xcframework (保持官方签名)${NC}"
                continue
            fi
            
            echo -e "${BLUE}  签名 $framework_name.xcframework${NC}"
            
            # 遍历 xcframework 中的所有 framework
            find "$xcframework" -name "*.framework" -type d | while read -r framework; do
                # 删除旧签名
                rm -rf "$framework/_CodeSignature" 2>/dev/null || true
                
                # 先签名所有嵌套的二进制文件和 dylib
                find "$framework" -type f \( -name "*.dylib" -o -name "*.so" \) 2>/dev/null | while read -r lib; do
                    if file "$lib" | grep -q "Mach-O"; then
                        codesign --force --sign "$IDENTITY" --timestamp --options runtime "$lib" 2>/dev/null || true
                    fi
                done
                
                # 签名所有可执行文件
                find "$framework" -type f -perm +111 ! -path "*/Headers/*" ! -path "*/_CodeSignature/*" 2>/dev/null | while read -r binary; do
                    if file "$binary" | grep -q "Mach-O"; then
                        if [[ ! "$binary" =~ \.dylib$ ]] && [[ ! "$binary" =~ \.so$ ]]; then
                            codesign --force --sign "$IDENTITY" --timestamp --options runtime "$binary" 2>/dev/null || true
                        fi
                    fi
                done
                
                # 使用严格的签名参数重新签名整个 framework
                if codesign --force --sign "$IDENTITY" --timestamp --generate-entitlement-der --options runtime --deep --verbose "$framework" 2>&1 | grep -v "replacing existing signature"; then
                    echo -e "${GREEN}    ✓ $(basename "$framework") 签名成功${NC}"
                else
                    echo -e "${RED}    ✗ $(basename "$framework") 签名失败${NC}"
                    exit 1
                fi
                
                # 验证签名
                if ! codesign --verify --deep --strict --verbose=2 "$framework" 2>&1; then
                    echo -e "${RED}    ✗ $(basename "$framework") 签名验证失败${NC}"
                    exit 1
                fi
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
fi

# 验证 frameworks
echo ""
echo -e "${YELLOW}验证 Frameworks...${NC}"
for framework in "$OUTPUT_DIR/Release"/*.xcframework; do
    if [ -d "$framework" ]; then
        framework_name=$(basename "$framework" .xcframework)
        echo -e "${BLUE}  检查 $framework_name.xcframework${NC}"
        
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
                    signing_info=$(codesign -dvv "$fw" 2>&1 | grep "Authority=" | head -1 | cut -d= -f2)
                    if [ -n "$signing_info" ]; then
                        if [ "$framework_name" = "Flutter" ]; then
                            echo -e "${GREEN}    ✓ 签名: $signing_info (官方签名)${NC}"
                        else
                            echo -e "${GREEN}    ✓ 签名: $signing_info${NC}"
                        fi
                    else
                        echo -e "${YELLOW}    ⚠ 未签名${NC}"
                    fi
                    break
                fi
            done
            break
        done
        
        # 检查隐私清单（Flutter.xcframework 不需要）
        if [ "$framework_name" != "Flutter" ]; then
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
    fi
done

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}构建完成！${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "Framework 输出目录: ${YELLOW}$OUTPUT_DIR/Release${NC}"
echo ""
echo -e "${GREEN}生成的 Frameworks:${NC}"
ls -lh "$OUTPUT_DIR/Release/"

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}签名说明${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}✓${NC} Flutter.xcframework - 保持官方签名"
if [ -n "$IDENTITY" ]; then
    echo -e "${GREEN}✓${NC} 其他 Frameworks - 使用本地签名: $IDENTITY"
else
    echo -e "${YELLOW}⚠${NC} 其他 Frameworks - 未签名"
fi

# 创建集成说明文件
cat > "$OUTPUT_DIR/INTEGRATION_GUIDE.md" << 'EOF'
# TanyuApp Framework 集成指南

## 📦 Framework 说明

本次打包生成的 frameworks 签名策略：

- **Flutter.xcframework**: 保持 Flutter 官方签名，无需重新签名
- **其他 frameworks**: 使用本地证书签名，可以直接集成

## 🚀 集成步骤

### 1. 添加 Frameworks 到项目

将 `build/frameworks/Release/` 目录下的所有 `.xcframework` 文件拖入你的 Xcode 项目。

### 2. 配置 Embed 选项

在 Xcode 中：
1. 选择项目 Target
2. 进入 "General" 标签
3. 在 "Frameworks, Libraries, and Embedded Content" 部分
4. 将所有 frameworks 的 Embed 选项设置为 **"Embed & Sign"**

### 3. 配置 Build Settings

#### Framework Search Paths
```
$(inherited)
$(PROJECT_DIR)/Frameworks
```

#### Other Linker Flags
```
-ObjC
```

#### Enable Bitcode
```
NO
```

### 4. 在代码中使用

#### 导入头文件
```objc
#import <Flutter/Flutter.h>
```

#### 初始化 Flutter Engine (AppDelegate.m)
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

#### 展示 Flutter 页面
```objc
// 获取 Flutter Engine
FlutterEngine *flutterEngine = 
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] flutterEngine];

// 创建 Flutter View Controller
FlutterViewController *flutterViewController =
    [[FlutterViewController alloc] initWithEngine:flutterEngine nibName:nil bundle:nil];

// 展示页面
[self.navigationController pushViewController:flutterViewController animated:YES];
```

#### 与 Flutter 通信
```objc
// 创建 Method Channel
FlutterMethodChannel *channel = [FlutterMethodChannel
    methodChannelWithName:@"com.tantan.yu/channel"
    binaryMessenger:flutterViewController.binaryMessenger];

// 调用 Flutter 方法
[channel invokeMethod:@"methodName" arguments:@{
    @"key": @"value"
} result:^(id result) {
    NSLog(@"Flutter 返回: %@", result);
}];

// 监听 Flutter 调用
[channel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
    if ([call.method isEqualToString:@"getNativeData"]) {
        result(@{@"data": @"native data"});
    } else {
        result(FlutterMethodNotImplemented);
    }
}];
```

## 🔐 签名说明

### Flutter.xcframework
- 保持 Flutter 官方签名
- 不需要重新签名
- 可以直接使用

### 其他 Frameworks
- 已使用本地证书签名
- 如果需要重新签名，可以使用以下命令：

```bash
# 重新签名单个 framework
codesign --force --deep --sign "你的证书名称" --timestamp path/to/Framework.xcframework

# 验证签名
codesign --verify --deep --strict path/to/Framework.xcframework
```

## 📱 隐私配置

确保你的主项目 Info.plist 包含必要的隐私描述：

```xml
<key>NSUserTrackingUsageDescription</key>
<string>我们需要您的同意以提供个性化内容</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>需要访问相册以选择图片</string>

<key>NSCameraUsageDescription</key>
<string>需要访问相机以拍摄照片</string>

<key>NSLocationWhenInUseUsageDescription</key>
<string>需要访问位置信息</string>
```

## 🐛 常见问题

### Q1: 编译错误 "framework not found"
**解决方案**: 检查 Framework Search Paths 是否正确配置

### Q2: 运行时崩溃 "dyld: Library not loaded"
**解决方案**: 确保所有 frameworks 的 Embed 选项设置为 "Embed & Sign"

### Q3: Flutter 页面黑屏
**解决方案**: 
- 检查 Flutter Engine 是否正确初始化
- 确保调用了 `[engine run]`
- 检查 Flutter 代码是否有错误

### Q4: 签名验证失败
**解决方案**:
- 确保使用的证书有效
- 检查 Provisioning Profile 是否匹配
- 尝试重新签名 frameworks

### Q5: Method Channel 无响应
**解决方案**:
- 检查 Channel 名称是否匹配
- 确保 Flutter Engine 已运行
- 检查 Flutter 端是否正确设置了 MethodChannel

## 🔄 更新 Framework

当 Flutter 代码更新后：

1. 重新运行打包脚本
```bash
./build_framework_for_integration.sh
```

2. 在 Xcode 中删除旧的 frameworks

3. 添加新的 frameworks

4. Clean Build Folder (Cmd + Shift + K)

5. 重新编译项目

## 📊 性能优化建议

1. **预热 Engine**: 在 App 启动时初始化 Flutter Engine
2. **复用 Engine**: 使用单例模式管理 Engine
3. **减少通信**: 合并多次 Method Channel 调用
4. **异步加载**: 使用异步方式加载 Flutter 页面

## 📞 技术支持

如有问题，请联系开发团队。

---

最后更新：2026-03-10
EOF

echo ""
echo -e "${GREEN}集成指南已生成: $OUTPUT_DIR/INTEGRATION_GUIDE.md${NC}"
echo ""
echo -e "${YELLOW}下一步：${NC}"
echo "1. 查看集成指南: cat $OUTPUT_DIR/INTEGRATION_GUIDE.md"
echo "2. 将 frameworks 添加到你的项目"
echo "3. 配置 Embed & Sign"
echo "4. 开始集成！"
echo ""
