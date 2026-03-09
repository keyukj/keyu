# TanyuApp iOS Framework 打包与集成

## 📦 项目概述

本项目提供了将 TanyuApp Flutter 应用打包成 iOS Framework 的完整解决方案，可以无缝集成到 Objective-C 原生项目中，并确保能够通过 App Store 审核。

## 🎯 特性

✅ 一键打包成 iOS Framework  
✅ 完整的隐私配置（PrivacyInfo.xcprivacy）  
✅ 正确的签名配置  
✅ 符合 App Store 审核要求  
✅ 完整的 OC 集成示例代码  
✅ Method Channel 双向通信  
✅ 详细的集成文档  

## 📚 文档导航

### 快速开始
- **[QUICK_START.md](./QUICK_START.md)** - 5 分钟快速集成指南

### 完整文档
- **[FRAMEWORK_INTEGRATION.md](./FRAMEWORK_INTEGRATION.md)** - 完整的集成文档，包含所有细节

### 示例代码
- **[example_integration/](./example_integration/)** - 完整的 OC 集成示例代码
  - `TanyuFlutterManager` - Flutter Engine 管理器
  - `ExampleViewController` - 使用示例
  - `AppDelegate_Example` - AppDelegate 配置示例

### 配置文件
- **[build_framework.sh](./build_framework.sh)** - 自动打包脚本
- **[TanyuApp.podspec](./TanyuApp.podspec)** - CocoaPods 配置
- **[ios/Runner/PrivacyInfo.xcprivacy](./ios/Runner/PrivacyInfo.xcprivacy)** - 隐私清单

## 🚀 快速开始

### 1. 打包 Framework

```bash
# 执行打包脚本
./build_framework.sh
```

打包完成后，frameworks 会生成在 `build/frameworks/Release/` 目录。

### 2. 集成到 OC 项目

#### 方式一：手动集成

1. 将 `build/frameworks/Release/` 下的所有 `.xcframework` 拖入 Xcode 项目
2. 设置所有 frameworks 为 "Embed & Sign"
3. 配置 Build Settings（详见文档）

#### 方式二：CocoaPods 集成

在 Podfile 中添加：

```ruby
pod 'TanyuApp', :path => './path/to/tanyu_app'
```

然后执行：

```bash
pod install
```

### 3. 初始化 Flutter Engine

在 `AppDelegate.m` 中：

```objc
#import "TanyuFlutterManager.h"

- (BOOL)application:(UIApplication *)application 
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [[TanyuFlutterManager sharedInstance] initializeFlutterEngine];
    return YES;
}
```

### 4. 展示 Flutter 页面

```objc
FlutterViewController *vc = [[TanyuFlutterManager sharedInstance] createFlutterViewController];
[self.navigationController pushViewController:vc animated:YES];
```

## 📋 项目结构

```
tanyu_app/
├── build_framework.sh              # 打包脚本
├── QUICK_START.md                  # 快速开始
├── FRAMEWORK_INTEGRATION.md        # 完整集成文档
├── TanyuApp.podspec               # CocoaPods 配置
├── example_integration/            # 示例代码
│   ├── README.md                  # 示例说明
│   ├── TanyuFlutterManager.h/m    # Engine 管理器
│   ├── ExampleViewController.h/m  # 使用示例
│   └── AppDelegate_Example.m      # AppDelegate 示例
├── ios/
│   └── Runner/
│       ├── Info.plist             # 已配置隐私权限
│       └── PrivacyInfo.xcprivacy  # 隐私清单
└── build/
    └── frameworks/
        └── Release/               # 打包产物（执行脚本后生成）
            ├── App.xcframework
            ├── Flutter.xcframework
            └── ...
```

## 🔧 核心功能

### 1. Flutter Engine 管理

使用 `TanyuFlutterManager` 单例管理 Flutter Engine：

```objc
// 初始化
[[TanyuFlutterManager sharedInstance] initializeFlutterEngine];

// 创建 ViewController
FlutterViewController *vc = [[TanyuFlutterManager sharedInstance] createFlutterViewController];

// 清理资源
[[TanyuFlutterManager sharedInstance] cleanup];
```

### 2. OC ↔ Flutter 通信

#### OC 调用 Flutter

```objc
[[TanyuFlutterManager sharedInstance] 
 invokeFlutterMethod:@"methodName"
 arguments:@{@"key": @"value"}
 result:^(id result) {
    NSLog(@"Flutter 返回: %@", result);
}];
```

#### Flutter 调用 OC

```dart
import 'package:flutter/services.dart';

final result = await MethodChannel('com.tantan.yu/native')
    .invokeMethod('getUserInfo');
```

### 3. 路由导航

```objc
// 打开指定路由
FlutterViewController *vc = [[TanyuFlutterManager sharedInstance] 
                            createFlutterViewControllerWithRoute:@"/profile"];
```

## 🔐 隐私与签名

### 隐私配置

项目已包含完整的隐私配置：

1. **Info.plist** - 权限描述
   - 用户追踪
   - 相册访问
   - 相机访问
   - 位置访问
   - 麦克风访问

2. **PrivacyInfo.xcprivacy** - 隐私清单
   - 数据收集类型
   - API 使用原因
   - 追踪域名

### 签名配置

支持自动签名和手动签名两种方式，详见 [FRAMEWORK_INTEGRATION.md](./FRAMEWORK_INTEGRATION.md)。

## 📱 App Store 提交

### 检查清单

- ✅ 所有权限都在 Info.plist 中声明
- ✅ PrivacyInfo.xcprivacy 文件已包含
- ✅ 签名配置正确
- ✅ 加密合规声明（ITSAppUsesNonExemptEncryption）
- ✅ 测试所有功能正常

### 提交流程

1. Archive 构建
2. Validate App 验证
3. Distribute App 上传
4. 在 App Store Connect 中完善信息

详细步骤见 [FRAMEWORK_INTEGRATION.md](./FRAMEWORK_INTEGRATION.md) 第六章。

## 🎨 示例代码

### 基础使用

```objc
// 1. 初始化（AppDelegate）
[[TanyuFlutterManager sharedInstance] initializeFlutterEngine];

// 2. 打开 Flutter 页面
FlutterViewController *vc = [[TanyuFlutterManager sharedInstance] createFlutterViewController];
[self.navigationController pushViewController:vc animated:YES];

// 3. 传递数据
[[TanyuFlutterManager sharedInstance] setUserInfo:@{@"userId": @"123"}];

// 4. 调用方法
[[TanyuFlutterManager sharedInstance] invokeFlutterMethod:@"refresh" arguments:nil result:nil];
```

### 高级用法

查看 [example_integration/ExampleViewController.m](./example_integration/ExampleViewController.m) 了解：
- Modal 展示
- 路由导航
- 双向通信
- 错误处理

## ⚡ 性能优化

### 1. 预热 Engine
在 App 启动时初始化 Flutter Engine，提高首次打开速度。

### 2. 复用 Engine
使用单例模式，避免重复创建 Engine。

### 3. 减少包体积
```bash
flutter build ios-framework --split-debug-info=./debug-info --obfuscate
```

详见 [FRAMEWORK_INTEGRATION.md](./FRAMEWORK_INTEGRATION.md) 第七章。

## 🐛 常见问题

### Q1: 编译错误 "framework not found"
检查 Framework Search Paths 配置。

### Q2: 运行时崩溃 "dyld: Library not loaded"
确保所有 frameworks 设置为 "Embed & Sign"。

### Q3: Flutter 页面黑屏
确保 Engine 已初始化并运行。

### Q4: Method Channel 无响应
检查 Channel 名称是否匹配。

更多问题见 [FRAMEWORK_INTEGRATION.md](./FRAMEWORK_INTEGRATION.md) 第九章。

## 🔄 更新流程

当 Flutter 代码更新后：

```bash
# 1. 重新打包
./build_framework.sh

# 2. 在 Xcode 中替换 frameworks

# 3. Clean Build Folder
# Cmd + Shift + K

# 4. 重新编译
```

## 📊 技术栈

- Flutter SDK: 3.10.7+
- iOS Deployment Target: 12.0+
- Xcode: 14.0+
- Language: Objective-C / Swift

## 📦 依赖插件

- in_app_purchase (内购)
- shared_preferences (本地存储)
- url_launcher (URL 启动)
- webview_flutter (WebView)

## 📖 相关资源

- [Flutter 官方文档](https://docs.flutter.dev/)
- [Flutter iOS 集成](https://docs.flutter.dev/development/add-to-app/ios/project-setup)
- [Apple 隐私清单](https://developer.apple.com/documentation/bundleresources/privacy_manifest_files)
- [App Store 审核指南](https://developer.apple.com/app-store/review/guidelines/)

## 🤝 技术支持

遇到问题？

1. 查看 [FRAMEWORK_INTEGRATION.md](./FRAMEWORK_INTEGRATION.md) 完整文档
2. 查看 [example_integration/README.md](./example_integration/README.md) 示例说明
3. 检查 Xcode 控制台日志
4. 联系开发团队

## 📝 更新日志

### v1.0.4 (2026-02-20)
- ✅ 完整的 Framework 打包方案
- ✅ 隐私配置和签名配置
- ✅ 完整的 OC 集成示例
- ✅ 详细的文档和指南
- ✅ App Store 审核支持

## 📄 许可证

[MIT License](LICENSE)

---

**开始使用：** 查看 [QUICK_START.md](./QUICK_START.md) 快速开始！

**完整文档：** 查看 [FRAMEWORK_INTEGRATION.md](./FRAMEWORK_INTEGRATION.md) 了解所有细节！

**示例代码：** 查看 [example_integration/](./example_integration/) 学习如何使用！

---

最后更新：2026-02-20
