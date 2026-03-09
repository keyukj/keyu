# TanyuApp - 探遇漂流瓶

一个基于 Flutter 的社交应用，支持打包为 iOS Framework 集成到原生 OC 项目中。

## 项目简介

TanyuApp 是一个功能完整的社交应用，包含以下特性：

- 用户登录和注册
- AI 智能聊天
- 社交广场和帖子
- 个人资料管理
- 钱包和充值系统
- 内购功能
- WebView 集成

## 快速开始

### 方式一：一键打包（推荐）

```bash
./package_for_appstore.sh
```

这个脚本会自动完成：
1. 构建 Framework
2. 验证 Framework
3. 配置签名
4. 生成集成文档

### 方式二：分步执行

```bash
# 1. 构建 Framework
./build_framework.sh

# 2. 验证 Framework
./verify_framework.sh

# 3. 配置签名
./configure_signing.sh
```

## 项目结构

```
.
├── lib/                          # Flutter 源代码
│   ├── main.dart                # 应用入口
│   ├── screens/                 # 页面
│   ├── widgets/                 # 组件
│   └── services/                # 服务
├── ios/                         # iOS 原生代码
│   ├── Runner/                  # 主项目
│   │   ├── Info.plist          # 应用配置
│   │   └── PrivacyInfo.xcprivacy # 隐私清单
│   └── Podfile                  # CocoaPods 配置
├── assets/                      # 资源文件
├── build/frameworks/            # 构建输出（自动生成）
├── example_integration/         # 集成示例代码
├── build_framework.sh           # 构建脚本
├── verify_framework.sh          # 验证脚本
├── configure_signing.sh         # 签名配置脚本
├── package_for_appstore.sh      # 一键打包脚本
├── APP_STORE_SUBMISSION_GUIDE.md # App Store 提交指南
├── CHECKLIST.md                 # 检查清单
├── FRAMEWORK_README.md          # Framework 说明
├── FRAMEWORK_INTEGRATION.md     # 集成指南
└── QUICK_START.md               # 快速开始
```

## 环境要求

- Flutter SDK 3.10.7+
- Xcode 14.0+
- CocoaPods 1.11.0+
- iOS 13.0+
- macOS 12.0+

## 开发

### 安装依赖

```bash
flutter pub get
cd ios && pod install && cd ..
```

### 运行应用

```bash
flutter run
```

### 构建 Framework

```bash
./build_framework.sh
```

构建完成后，frameworks 将输出到 `build/frameworks/Release/` 目录。

## 集成到 OC 项目

### 1. 添加 Frameworks

将 `build/frameworks/Release/` 目录下的所有 `.xcframework` 文件拖入你的 Xcode 项目，并设置 Embed 为 "Embed & Sign"。

### 2. 配置 Build Settings

- Framework Search Paths: `$(inherited) $(PROJECT_DIR)/Frameworks`
- Other Linker Flags: `-ObjC`
- Enable Bitcode: `NO`
- iOS Deployment Target: `13.0`

### 3. 初始化 Flutter Engine

```objc
// AppDelegate.m
#import <Flutter/Flutter.h>

@interface AppDelegate ()
@property (strong, nonatomic) FlutterEngine *flutterEngine;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application 
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.flutterEngine = [[FlutterEngine alloc] initWithName:@"tanyu_engine"];
    [self.flutterEngine run];
    
    return YES;
}

@end
```

### 4. 展示 Flutter 页面

```objc
FlutterEngine *engine = [(AppDelegate *)[[UIApplication sharedApplication] delegate] flutterEngine];
FlutterViewController *flutterVC = [[FlutterViewController alloc] initWithEngine:engine nibName:nil bundle:nil];
[self.navigationController pushViewController:flutterVC animated:YES];
```

详细集成步骤请查看 [FRAMEWORK_INTEGRATION.md](FRAMEWORK_INTEGRATION.md)。

## App Store 提交

### 准备工作

1. 确保所有功能已测试
2. 配置正确的签名
3. 添加必需的隐私描述
4. 运行验证脚本

```bash
./verify_framework.sh
```

### 提交流程

1. 在 Xcode 中 Archive 项目
2. 选择 "Distribute App" → "App Store Connect"
3. 上传到 App Store Connect
4. 在 App Store Connect 中提交审核

详细提交指南请查看 [APP_STORE_SUBMISSION_GUIDE.md](APP_STORE_SUBMISSION_GUIDE.md)。

## 隐私和权限

本应用使用以下权限：

- 相册访问 - 用于选择和上传图片
- 相机访问 - 用于拍摄照片
- 用户追踪 - 用于个性化内容（可选）

所有权限都已在 `Info.plist` 和 `PrivacyInfo.xcprivacy` 中正确声明。

## 文档

- [APP_STORE_SUBMISSION_GUIDE.md](APP_STORE_SUBMISSION_GUIDE.md) - App Store 提交详细指南
- [CHECKLIST.md](CHECKLIST.md) - 提交前检查清单
- [FRAMEWORK_README.md](FRAMEWORK_README.md) - Framework 详细说明
- [FRAMEWORK_INTEGRATION.md](FRAMEWORK_INTEGRATION.md) - 集成详细步骤
- [QUICK_START.md](QUICK_START.md) - 快速开始指南

## 常见问题

### Q: 构建失败怎么办？

A: 检查以下几点：
- Flutter SDK 版本是否正确
- 依赖是否已安装（`flutter pub get` 和 `pod install`）
- Xcode 版本是否满足要求

### Q: 集成后黑屏？

A: 确保：
- Flutter Engine 已正确初始化
- 调用了 `[engine run]`
- Frameworks 的 Embed 设置为 "Embed & Sign"

### Q: 审核被拒？

A: 常见原因：
- 隐私描述不清晰或缺失
- 必需原因 API 未声明
- 签名配置错误

详细解决方案请查看 [APP_STORE_SUBMISSION_GUIDE.md](APP_STORE_SUBMISSION_GUIDE.md) 的常见问题部分。

## 技术支持

如有问题，请查看相关文档或联系开发团队。

## 许可证

MIT License

---

**版本:** 1.0.5  
**最后更新:** 2026-02-21
