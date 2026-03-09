# App Store 提交指南

## 概述

本指南帮助你将 TanyuApp Flutter Framework 集成到 OC 项目中，并确保能够通过 App Store 审核。

## 一、构建和签名 Framework

### 1.1 运行构建和签名脚本（推荐）

从 2025 年开始，Apple 要求所有第三方 SDK 必须包含代码签名。使用以下脚本一键完成构建和签名：

```bash
chmod +x build_and_sign_frameworks.sh
./build_and_sign_frameworks.sh
```

这个脚本会自动：
1. 构建所有 Flutter frameworks
2. 使用你的 Apple 证书对 frameworks 进行签名
3. 验证签名是否成功

### 1.2 手动构建和签名（可选）

如果需要分步执行：

**步骤 1：构建 frameworks**
```bash
chmod +x build_framework.sh
./build_framework.sh
```

**步骤 2：签名 frameworks**
```bash
chmod +x sign_frameworks.sh
./sign_frameworks.sh
```

构建完成后，frameworks 将输出到 `build/frameworks/Release/` 目录。

### 1.3 验证构建和签名产物

确认以下 frameworks 已生成并签名：
- `App.xcframework` - Flutter 应用代码 ✅ 已签名
- `Flutter.xcframework` - Flutter 引擎 ⏭️ 跳过（Flutter 官方已签名）
- `FlutterPluginRegistrant.xcframework` - 插件注册 ✅ 已签名
- `in_app_purchase_storekit.xcframework` - 内购插件 ✅ 已签名
- `shared_preferences_foundation.xcframework` - 本地存储插件 ✅ 已签名
- `url_launcher_ios.xcframework` - URL 启动插件 ✅ 已签名
- `webview_flutter_wkwebview.xcframework` - WebView 插件 ✅ 已签名

**验证签名：**
```bash
codesign --verify --verbose build/frameworks/Release/url_launcher_ios.xcframework
```

如果签名成功，会显示 "valid on disk" 信息。

## 二、集成到 OC 项目

### 2.1 添加 Frameworks

1. 将 `build/frameworks/Release/` 目录下的所有 `.xcframework` 文件拖入你的 Xcode 项目
2. 在弹出的对话框中：
   - ✓ Copy items if needed
   - ✓ Create groups
   - 选择正确的 Target

### 2.2 配置 Xcode 项目

在 Xcode 中选择你的项目 Target，进行以下配置：

#### General 标签

在 "Frameworks, Libraries, and Embedded Content" 部分：
- 确保所有 `.xcframework` 都已添加
- 将 Embed 选项设置为 **"Embed & Sign"**（重要！）

#### Build Settings 标签

搜索并设置以下选项：

1. **Framework Search Paths**
   ```
   $(inherited)
   $(PROJECT_DIR)/Frameworks
   ```

2. **Other Linker Flags**
   ```
   -ObjC
   ```

3. **Enable Bitcode**
   ```
   NO
   ```

4. **iOS Deployment Target**
   ```
   13.0 或更高
   ```

5. **User Script Sandboxing**
   ```
   NO
   ```

### 2.3 配置 Info.plist

在主项目的 `Info.plist` 中添加必需的隐私描述：

```xml
<!-- 用户追踪（如果需要） -->
<key>NSUserTrackingUsageDescription</key>
<string>我们需要您的同意以提供个性化内容和服务</string>

<!-- 相册访问 -->
<key>NSPhotoLibraryUsageDescription</key>
<string>需要访问相册以选择和上传图片</string>

<key>NSPhotoLibraryAddUsageDescription</key>
<string>需要保存图片到相册</string>

<!-- 相机访问 -->
<key>NSCameraUsageDescription</key>
<string>需要访问相机以拍摄照片</string>

<!-- 麦克风访问（如果需要） -->
<key>NSMicrophoneUsageDescription</key>
<string>需要访问麦克风以录制音频</string>

<!-- 位置访问（如果需要） -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>需要访问位置信息以提供基于位置的服务</string>

<!-- 网络配置 -->
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <false/>
    <key>NSAllowsLocalNetworking</key>
    <true/>
</dict>

<!-- 加密合规 -->
<key>ITSAppUsesNonExemptEncryption</key>
<false/>
```

## 三、代码集成

### 3.1 在 AppDelegate 中初始化

```objc
// AppDelegate.h
#import <UIKit/UIKit.h>
#import <Flutter/Flutter.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) FlutterEngine *flutterEngine;

@end
```

```objc
// AppDelegate.m
#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application 
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // 初始化 Flutter Engine（预热）
    self.flutterEngine = [[FlutterEngine alloc] initWithName:@"tanyu_engine"];
    [self.flutterEngine run];
    
    // 注册插件（如果需要）
    [GeneratedPluginRegistrant registerWithRegistry:self.flutterEngine];
    
    return YES;
}

@end
```

### 3.2 展示 Flutter 页面

```objc
#import <Flutter/Flutter.h>

// 获取共享的 Flutter Engine
AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
FlutterEngine *flutterEngine = appDelegate.flutterEngine;

// 创建 Flutter View Controller
FlutterViewController *flutterVC = 
    [[FlutterViewController alloc] initWithEngine:flutterEngine nibName:nil bundle:nil];

// 展示页面
[self.navigationController pushViewController:flutterVC animated:YES];
```

### 3.3 Method Channel 通信

```objc
// 创建 Method Channel
FlutterMethodChannel *channel = [FlutterMethodChannel
    methodChannelWithName:@"com.tantan.yu/channel"
    binaryMessenger:flutterVC.binaryMessenger];

// 发送消息到 Flutter
[channel invokeMethod:@"setUserInfo" arguments:@{
    @"userId": @"12345",
    @"userName": @"张三"
}];

// 接收 Flutter 消息
[channel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
    if ([@"getUserInfo" isEqualToString:call.method]) {
        result(@{@"userId": @"12345", @"userName": @"张三"});
    } else {
        result(FlutterMethodNotImplemented);
    }
}];
```

## 四、签名配置

### 4.1 自动签名（推荐）

1. 选择项目 Target
2. 进入 "Signing & Capabilities" 标签
3. ✓ Automatically manage signing
4. 选择你的 Team
5. 确保 Bundle Identifier 正确

### 4.2 手动签名

1. 准备好以下文件：
   - Apple Distribution 证书
   - App Store Provisioning Profile

2. 在 "Signing & Capabilities" 中：
   - ☐ Automatically manage signing
   - 选择 "Apple Distribution" 证书
   - 选择对应的 Provisioning Profile

3. 确保 Team ID 正确：`UG5N3PCLJ5`

## 五、App Store 审核要点

### 5.1 Framework 签名（重要！）

从 2025 年开始，Apple 强制要求所有第三方 SDK 必须包含代码签名，否则会收到 ITMS-91065 错误。

✅ 确保使用 `build_and_sign_frameworks.sh` 脚本构建和签名所有 frameworks
✅ Flutter.xcframework 由 Flutter 官方签名，无需重新签名
✅ 其他所有插件 frameworks 必须使用你的 Apple 证书签名

**常见错误：**
```
ITMS-91065: Missing signature - Your app includes "Frameworks/url_launcher_ios.framework/url_launcher_ios"
```

**解决方案：**
运行 `./sign_frameworks.sh` 对所有 frameworks 进行签名。

### 5.2 隐私清单检查

✓ 所有 frameworks 都包含 `PrivacyInfo.xcprivacy` 文件
✓ Info.plist 包含所有使用的权限描述
✓ 隐私描述文字清晰、准确

### 5.3 必需原因 API 声明

### 5.3 必需原因 API 声明

已在 `PrivacyInfo.xcprivacy` 中声明以下 API：

- **UserDefaults** (CA92.1) - 用户偏好设置
- **File Timestamp** (C617.1) - 文件时间戳访问
- **System Boot Time** (35F9.1) - 时间间隔测量
- **Disk Space** (E174.1) - 磁盘空间管理

### 5.4 第三方 SDK 声明

### 5.4 第三方 SDK 声明

在 App Store Connect 提交时，需要声明使用的第三方 SDK：

- Flutter SDK
- StoreKit (内购)
- WebKit (WebView)

### 5.5 加密合规

### 5.5 加密合规

已在 Info.plist 中设置：
```xml
<key>ITSAppUsesNonExemptEncryption</key>
<false/>
```

如果使用了 HTTPS 以外的加密，需要改为 `true` 并提供合规文档。

### 5.6 数据收集声明

在 App Store Connect 中需要声明：

- 用户 ID - 用于应用功能
- 产品交互数据 - 用于分析和应用功能
- 购买历史 - 用于应用功能（内购）

## 六、测试清单

### 6.1 真机测试

- [ ] 在真机上安装并运行
- [ ] 测试所有 Flutter 页面功能
- [ ] 测试 OC 与 Flutter 通信
- [ ] 测试内购功能
- [ ] 测试 WebView 功能
- [ ] 测试网络请求
- [ ] 测试本地存储

### 6.2 性能测试

- [ ] 启动时间正常
- [ ] 内存占用合理
- [ ] 无明显卡顿
- [ ] 无内存泄漏

### 6.3 兼容性测试

- [ ] iOS 13.0+ 系统
- [ ] iPhone 各机型
- [ ] iPad（如果支持）
- [ ] 横竖屏切换

## 七、打包提交

### 7.1 Archive

1. 在 Xcode 中选择 "Any iOS Device (arm64)"
2. Product → Archive
3. 等待 Archive 完成

### 7.2 导出 IPA

1. 在 Organizer 中选择刚才的 Archive
2. 点击 "Distribute App"
3. 选择 "App Store Connect"
4. 选择 "Upload"
5. 配置选项：
   - ✓ Strip Swift symbols
   - ☐ Upload symbols (可选)
   - ✓ Manage Version and Build Number (可选)
6. 选择正确的签名证书和 Provisioning Profile
7. 点击 "Upload"

### 7.3 TestFlight 测试

1. 上传成功后，在 App Store Connect 中查看
2. 等待处理完成（通常 5-30 分钟）
3. 添加内部测试人员
4. 进行 TestFlight 测试
5. 收集反馈并修复问题

### 7.4 提交审核

1. 在 App Store Connect 中创建新版本
2. 填写版本信息：
   - 版本号
   - 更新说明
   - 截图
   - 描述
3. 选择构建版本
4. 填写审核信息：
   - 联系信息
   - 演示账号（如果需要）
   - 备注
5. 提交审核

## 八、常见问题

### Q1: ITMS-91065: Missing signature 错误

**问题描述：**
```
ITMS-91065: Missing signature - Your app includes "Frameworks/url_launcher_ios.framework/url_launcher_ios"
```

**解决方案：**
这是 Apple 从 2025 年开始强制要求的新规定，所有第三方 SDK 必须包含代码签名。

1. 运行签名脚本：
   ```bash
   ./sign_frameworks.sh
   ```

2. 或者使用一键构建和签名：
   ```bash
   ./build_and_sign_frameworks.sh
   ```

3. 在 Xcode 中替换旧的 frameworks
4. Clean Build Folder (Cmd + Shift + K)
5. 重新 Archive 并提交

**验证签名：**
```bash
codesign --verify --verbose build/frameworks/Release/url_launcher_ios.xcframework
```

### Q2: 编译错误 "framework not found"

### Q2: 编译错误 "framework not found"

**解决方案：**
- 检查 Framework Search Paths 配置
- 确保所有 frameworks 都已正确添加
- Clean Build Folder (Cmd + Shift + K)

### Q3: 运行时崩溃 "dyld: Library not loaded"

### Q3: 运行时崩溃 "dyld: Library not loaded"

**解决方案：**
- 确保所有 frameworks 的 Embed 设置为 "Embed & Sign"
- 检查 Deployment Target 是否一致
- 检查架构支持（arm64）

### Q4: 黑屏或白屏

### Q4: 黑屏或白屏

**解决方案：**
- 检查 Flutter Engine 是否正确初始化
- 确保调用了 `[engine run]`
- 检查 Flutter 资源文件是否正确嵌入

### Q5: 审核被拒 - 隐私问题

### Q5: 审核被拒 - 隐私问题

**解决方案：**
- 检查所有权限描述是否清晰
- 确保 PrivacyInfo.xcprivacy 文件存在
- 在 App Store Connect 中正确声明数据收集

### Q6: 审核被拒 - 必需原因 API

### Q6: 审核被拒 - 必需原因 API

**解决方案：**
- 确保 PrivacyInfo.xcprivacy 包含所有使用的 API
- 检查原因代码是否正确
- 参考 Apple 官方文档更新原因代码

### Q7: 内购无法使用

### Q7: 内购无法使用

**解决方案：**
- 确保 StoreKit framework 已添加
- 检查 Bundle ID 是否与 App Store Connect 一致
- 在沙盒环境测试
- 检查内购产品 ID 是否正确

### Q8: 签名脚本找不到证书

**问题描述：**
```
Error: No valid codesigning identity found
```

**解决方案：**
1. 确保已安装 Apple Distribution 或 Apple Development 证书
2. 在钥匙串访问中检查证书是否有效
3. 手动指定证书：
   ```bash
   export CODESIGN_IDENTITY="Apple Distribution: Your Name (TEAM_ID)"
   ./sign_frameworks.sh
   ```

4. 查看可用证书：
   ```bash
   security find-identity -v -p codesigning
   ```

## 九、更新 Framework

当 Flutter 代码更新后：

1. 运行构建和签名脚本：
   ```bash
   ./build_and_sign_frameworks.sh
   ```

2. 在 Xcode 中：
   - 删除旧的 frameworks
   - 添加新的已签名 frameworks
   - Clean Build Folder (Cmd + Shift + K)
   - 重新编译

3. 测试所有功能

4. 提交新版本

## 十、技术支持

### 相关文档

- [FRAMEWORK_README.md](FRAMEWORK_README.md) - Framework 详细说明
- [FRAMEWORK_INTEGRATION.md](FRAMEWORK_INTEGRATION.md) - 集成详细步骤
- [QUICK_START.md](QUICK_START.md) - 快速开始指南

### 联系方式

如有问题，请联系开发团队。

---

**最后更新：** 2026-02-21
**版本：** 1.0.5
