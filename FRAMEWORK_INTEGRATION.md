# TanyuApp Framework 集成完整指南

## 概述

本文档详细说明如何将 TanyuApp Flutter 项目打包成 iOS Framework，并集成到 Objective-C 项目中，确保能够通过 App Store 审核。

## 一、打包 Framework

### 1.1 环境要求

- Flutter SDK (已安装)
- Xcode 14.0+
- CocoaPods (如果使用)
- macOS 12.0+

### 1.2 执行打包

```bash
# 给脚本添加执行权限
chmod +x build_framework.sh

# 执行打包
./build_framework.sh
```

### 1.3 打包产物

打包完成后，在 `build/frameworks/Release/` 目录下会生成：

```
Release/
├── App.xcframework                              # 你的 Flutter 应用代码
├── Flutter.xcframework                          # Flutter 引擎
├── FlutterPluginRegistrant.xcframework         # 插件注册
├── in_app_purchase_storekit.xcframework        # 内购插件
├── shared_preferences_foundation.xcframework   # 本地存储插件
├── url_launcher_ios.xcframework                # URL 启动插件
└── webview_flutter_wkwebview.xcframework       # WebView 插件
```

## 二、集成到 OC 项目

### 2.1 添加 Frameworks

1. 打开你的 Xcode 项目
2. 将 `build/frameworks/Release/` 目录下的所有 `.xcframework` 文件拖入项目
3. 在弹出的对话框中：
   - ✅ Copy items if needed
   - ✅ Create groups
   - ✅ 选择正确的 Target

### 2.2 配置 Embed 设置

1. 选择项目 Target
2. 进入 "General" 标签
3. 找到 "Frameworks, Libraries, and Embedded Content" 部分
4. 确保所有 frameworks 的 Embed 选项为 **"Embed & Sign"**

### 2.3 配置 Build Settings

在 Target 的 Build Settings 中配置：

#### Framework Search Paths
```
$(inherited)
$(PROJECT_DIR)/Frameworks
```

#### Other Linker Flags
```
-ObjC
-framework Flutter
```

#### Enable Bitcode
```
NO
```

#### Strip Swift Symbols
```
NO
```

#### Runpath Search Paths
```
$(inherited)
@executable_path/Frameworks
@loader_path/Frameworks
```

## 三、代码集成

### 3.1 AppDelegate 配置

在 `AppDelegate.h` 中：

```objc
#import <UIKit/UIKit.h>
#import <Flutter/Flutter.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) FlutterEngine *flutterEngine;

@end
```

在 `AppDelegate.m` 中：

```objc
#import "AppDelegate.h"
#import <Flutter/Flutter.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application 
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // 初始化 Flutter Engine（单例模式，提高性能）
    self.flutterEngine = [[FlutterEngine alloc] initWithName:@"tanyu_engine"];
    
    // 运行 Engine
    [self.flutterEngine runWithEntrypoint:nil];
    
    // 预热引擎（可选，提高首次打开速度）
    [GeneratedPluginRegistrant registerWithRegistry:self.flutterEngine];
    
    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // 清理 Flutter Engine
    [self.flutterEngine destroyContext];
}

@end
```

### 3.2 展示 Flutter 页面

#### 方式一：Push 导航

```objc
#import <Flutter/Flutter.h>

- (void)showFlutterPage {
    // 获取共享的 Flutter Engine
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    FlutterEngine *flutterEngine = appDelegate.flutterEngine;
    
    // 创建 Flutter View Controller
    FlutterViewController *flutterVC = 
        [[FlutterViewController alloc] initWithEngine:flutterEngine 
                                              nibName:nil 
                                               bundle:nil];
    
    // 设置初始路由（可选）
    [flutterVC setInitialRoute:@"/"];
    
    // Push 展示
    [self.navigationController pushViewController:flutterVC animated:YES];
}
```

#### 方式二：Modal 展示

```objc
- (void)presentFlutterPage {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    FlutterEngine *flutterEngine = appDelegate.flutterEngine;
    
    FlutterViewController *flutterVC = 
        [[FlutterViewController alloc] initWithEngine:flutterEngine 
                                              nibName:nil 
                                               bundle:nil];
    
    // Modal 展示
    flutterVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:flutterVC animated:YES completion:nil];
}
```

### 3.3 OC 与 Flutter 通信

#### 创建 Method Channel

在 OC 中：

```objc
#import <Flutter/Flutter.h>

- (void)setupMethodChannel {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    FlutterEngine *flutterEngine = appDelegate.flutterEngine;
    
    // 创建 Method Channel
    FlutterMethodChannel *channel = [FlutterMethodChannel
        methodChannelWithName:@"com.tantan.yu/native"
        binaryMessenger:flutterEngine.binaryMessenger];
    
    // 监听 Flutter 调用
    [channel setMethodCallHandler:^(FlutterMethodCall *call, FlutterResult result) {
        if ([@"getUserInfo" isEqualToString:call.method]) {
            // 返回用户信息
            NSDictionary *userInfo = @{
                @"userId": @"12345",
                @"userName": @"张三",
                @"avatar": @"https://example.com/avatar.jpg"
            };
            result(userInfo);
        } else if ([@"openNativePage" isEqualToString:call.method]) {
            // 打开原生页面
            dispatch_async(dispatch_get_main_queue(), ^{
                // 执行打开页面的代码
            });
            result(@"success");
        } else {
            result(FlutterMethodNotImplemented);
        }
    }];
}

// 调用 Flutter 方法
- (void)callFlutterMethod {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    FlutterEngine *flutterEngine = appDelegate.flutterEngine;
    
    FlutterMethodChannel *channel = [FlutterMethodChannel
        methodChannelWithName:@"com.tantan.yu/native"
        binaryMessenger:flutterEngine.binaryMessenger];
    
    [channel invokeMethod:@"updateUserInfo" 
                arguments:@{@"userId": @"12345"}
                   result:^(id result) {
        NSLog(@"Flutter 返回: %@", result);
    }];
}
```

在 Flutter 中（lib/main.dart）：

```dart
import 'package:flutter/services.dart';

class NativeBridge {
  static const platform = MethodChannel('com.tantan.yu/native');
  
  // 调用原生方法
  static Future<Map<String, dynamic>> getUserInfo() async {
    try {
      final result = await platform.invokeMethod('getUserInfo');
      return Map<String, dynamic>.from(result);
    } catch (e) {
      print('Error: $e');
      return {};
    }
  }
  
  // 监听原生调用
  static void setupMethodHandler() {
    platform.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'updateUserInfo':
          final userId = call.arguments['userId'];
          // 处理更新逻辑
          return 'success';
        default:
          throw PlatformException(code: 'NotImplemented');
      }
    });
  }
}
```

## 四、签名配置

### 4.1 自动签名（推荐）

1. 选择项目 Target
2. 进入 "Signing & Capabilities" 标签
3. ✅ 勾选 "Automatically manage signing"
4. 选择你的 Development Team
5. 确保 Bundle Identifier 唯一

### 4.2 手动签名

1. 准备证书：
   - Development Certificate（开发）
   - Distribution Certificate（发布）

2. 准备 Provisioning Profile：
   - Development Profile
   - App Store Profile

3. 在 Xcode 中配置：
   - 取消勾选 "Automatically manage signing"
   - Debug 配置选择 Development Profile
   - Release 配置选择 App Store Profile

### 4.3 签名验证

```bash
# 验证 Framework 签名
codesign -dv --verbose=4 build/frameworks/Release/Flutter.xcframework/ios-arm64/Flutter.framework

# 验证应用签名
codesign -dv --verbose=4 /path/to/YourApp.app
```

## 五、隐私配置

### 5.1 Info.plist 权限声明

确保主项目的 Info.plist 包含所有必要的权限描述（已在 ios/Runner/Info.plist 中配置）：

- NSUserTrackingUsageDescription（用户追踪）
- NSPhotoLibraryUsageDescription（相册访问）
- NSCameraUsageDescription（相机访问）
- NSLocationWhenInUseUsageDescription（位置访问）
- NSMicrophoneUsageDescription（麦克风访问）

### 5.2 隐私清单文件

项目已包含 `PrivacyInfo.xcprivacy` 文件，声明了：

- 数据收集类型
- API 使用原因
- 追踪域名

确保此文件被正确包含在项目中。

### 5.3 App Store Connect 隐私声明

在提交应用时，需要在 App Store Connect 中声明：

1. 数据收集类型：
   - 用户 ID
   - 产品交互数据
   - 购买历史

2. 数据用途：
   - 应用功能
   - 分析
   - 个性化

3. 第三方 SDK：
   - 如使用了第三方 SDK，需要声明

## 六、App Store 提交

### 6.1 构建 Archive

1. 选择 "Generic iOS Device" 或真机
2. Product → Archive
3. 等待构建完成

### 6.2 验证构建

在 Organizer 中：

1. 选择刚才的 Archive
2. 点击 "Validate App"
3. 选择 Distribution 方式
4. 等待验证完成

### 6.3 上传到 App Store Connect

1. 点击 "Distribute App"
2. 选择 "App Store Connect"
3. 选择 Distribution 选项
4. 上传

### 6.4 常见审核问题

#### 问题 1：缺少隐私描述
解决：确保所有使用的权限都在 Info.plist 中声明

#### 问题 2：使用了私有 API
解决：检查代码，移除私有 API 调用

#### 问题 3：崩溃或性能问题
解决：
- 使用 Instruments 分析性能
- 检查内存泄漏
- 测试各种设备和系统版本

#### 问题 4：加密合规
解决：在 Info.plist 中添加：
```xml
<key>ITSAppUsesNonExemptEncryption</key>
<false/>
```

## 七、性能优化

### 7.1 预热 Flutter Engine

在 App 启动时初始化 Flutter Engine，而不是在首次使用时：

```objc
- (BOOL)application:(UIApplication *)application 
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // 提前初始化
    self.flutterEngine = [[FlutterEngine alloc] initWithName:@"tanyu_engine"];
    [self.flutterEngine runWithEntrypoint:nil];
    
    return YES;
}
```

### 7.2 复用 Flutter Engine

使用单例模式，避免重复创建 Engine：

```objc
// 好的做法：复用 Engine
AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
FlutterViewController *vc = [[FlutterViewController alloc] 
    initWithEngine:appDelegate.flutterEngine nibName:nil bundle:nil];

// 不好的做法：每次创建新 Engine
FlutterViewController *vc = [[FlutterViewController alloc] init]; // ❌
```

### 7.3 减少包体积

```bash
# 使用 --split-debug-info 分离调试信息
flutter build ios-framework --split-debug-info=./debug-info

# 使用 --obfuscate 混淆代码
flutter build ios-framework --obfuscate --split-debug-info=./debug-info
```

### 7.4 优化启动时间

1. 延迟加载非必要模块
2. 使用 Dart 的 deferred loading
3. 减少首屏渲染内容

## 八、调试技巧

### 8.1 查看 Flutter 日志

```bash
# 连接设备后查看日志
flutter logs
```

### 8.2 调试 Method Channel

在 OC 中添加日志：

```objc
[channel setMethodCallHandler:^(FlutterMethodCall *call, FlutterResult result) {
    NSLog(@"收到 Flutter 调用: %@ 参数: %@", call.method, call.arguments);
    // 处理逻辑
}];
```

### 8.3 性能分析

使用 Xcode Instruments：
- Time Profiler（CPU 分析）
- Allocations（内存分析）
- Leaks（内存泄漏）

## 九、常见问题

### Q1: 编译错误 "framework not found Flutter"

**原因**：Framework Search Paths 配置不正确

**解决**：
1. 检查 Build Settings → Framework Search Paths
2. 确保包含 `$(PROJECT_DIR)/Frameworks`
3. Clean Build Folder (Cmd + Shift + K)

### Q2: 运行时崩溃 "dyld: Library not loaded"

**原因**：Framework 没有正确嵌入

**解决**：
1. 检查 General → Frameworks, Libraries, and Embedded Content
2. 确保所有 frameworks 设置为 "Embed & Sign"
3. 重新编译

### Q3: Flutter 页面显示黑屏

**原因**：Flutter Engine 未正确初始化

**解决**：
1. 确保调用了 `[engine runWithEntrypoint:nil]`
2. 检查 Engine 是否为 nil
3. 查看控制台日志

### Q4: Method Channel 通信失败

**原因**：Channel 名称不匹配或 Engine 未运行

**解决**：
1. 确保 OC 和 Flutter 中的 Channel 名称完全一致
2. 确保 Engine 已经运行
3. 检查 binaryMessenger 是否正确

### Q5: 资源文件找不到

**原因**：资源未正确打包到 Framework

**解决**：
1. 检查 pubspec.yaml 中的 assets 配置
2. 重新运行 `flutter pub get`
3. 重新打包 Framework

### Q6: App Store 审核被拒：缺少隐私描述

**解决**：
1. 检查 Info.plist 中的权限描述
2. 确保 PrivacyInfo.xcprivacy 文件存在
3. 在 App Store Connect 中完善隐私声明

## 十、更新流程

当 Flutter 代码更新后：

1. 修改 Flutter 代码
2. 运行 `./build_framework.sh` 重新打包
3. 在 Xcode 中删除旧的 frameworks
4. 添加新的 frameworks
5. Clean Build Folder (Cmd + Shift + K)
6. 重新编译和测试

## 十一、技术支持

如遇到问题：

1. 查看本文档的常见问题部分
2. 检查 Flutter 官方文档
3. 查看 Xcode 控制台日志
4. 联系开发团队

## 附录

### A. 相关命令

```bash
# 查看 Flutter 版本
flutter --version

# 清理构建缓存
flutter clean

# 获取依赖
flutter pub get

# 打包 Framework
flutter build ios-framework --output=./build/frameworks

# 查看设备
flutter devices

# 查看日志
flutter logs
```

### B. 相关文档

- [Flutter iOS 集成文档](https://docs.flutter.dev/development/add-to-app/ios/project-setup)
- [Apple 隐私清单指南](https://developer.apple.com/documentation/bundleresources/privacy_manifest_files)
- [App Store 审核指南](https://developer.apple.com/app-store/review/guidelines/)

### C. 版本信息

- Flutter SDK: 3.10.7+
- iOS Deployment Target: 12.0+
- Xcode: 14.0+
- Swift: 5.0+

---

最后更新：2026-02-20
