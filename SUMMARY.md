# TanyuApp Framework 打包方案总结

## 完成的工作

已为 TanyuApp 项目创建了完整的 iOS Framework 打包方案，确保能够正确嵌入到 OC 项目中并通过 App Store 审核。

## 核心文件

### 1. 构建脚本

#### `build_framework.sh` - 主构建脚本
- 清理旧的构建产物
- 运行 Flutter 构建
- 自动添加隐私清单到所有 frameworks
- 验证构建结果
- 生成集成指南

#### `package_for_appstore.sh` - 一键打包脚本（推荐使用）
- 自动执行完整的打包流程
- 友好的用户界面
- 详细的进度提示
- 完成后显示下一步操作指南

#### `verify_framework.sh` - 验证脚本
- 检查必需的 frameworks
- 验证架构支持（arm64/模拟器）
- 检查隐私清单文件
- 验证代码签名
- 检查 Bitcode 设置
- 检查文件大小
- 验证 Info.plist 配置
- 生成验证报告

#### `configure_signing.sh` - 签名配置脚本
- 检查可用的签名身份
- 检查 Provisioning Profiles
- 验证 frameworks 签名状态
- 生成签名配置文档

### 2. 配置文件

#### `ios/Runner/PrivacyInfo.xcprivacy` - 隐私清单
已配置以下内容：
- 数据收集类型声明
  - 用户 ID
  - 产品交互数据
  - 购买历史
- 必需原因 API 声明
  - UserDefaults (CA92.1)
  - File Timestamp (C617.1)
  - System Boot Time (35F9.1)
  - Disk Space (E174.1)

#### `ios/Runner/Info.plist` - 应用配置
已配置：
- 所有必需的隐私权限描述
- 加密合规声明
- 网络安全配置
- Bundle ID 和版本信息

#### `ExportOptions.plist` - 导出配置
已配置：
- Team ID: UG5N3PCLJ5
- Bundle ID: com.tantan.yu
- 签名方式和证书
- App Store Connect 导出设置

#### `TanyuApp.podspec` - CocoaPods 配置
已配置：
- Framework 路径
- 资源文件
- 依赖关系
- 隐私清单集成

### 3. 文档

#### `APP_STORE_SUBMISSION_GUIDE.md` - App Store 提交指南
详细说明：
- 构建 Framework 的步骤
- 集成到 OC 项目的方法
- 代码集成示例
- 签名配置方法
- App Store 审核要点
- 测试清单
- 打包提交流程
- 常见问题解决方案

#### `CHECKLIST.md` - 检查清单
包含：
- 构建前准备
- Framework 构建检查
- 隐私和权限配置
- 签名配置
- 代码集成
- 功能测试
- 验证步骤
- Archive 和导出
- TestFlight 测试
- App Store Connect 配置
- 提交审核
- 发布后监控

#### `README.md` - 项目说明
包含：
- 项目简介
- 快速开始指南
- 项目结构
- 环境要求
- 开发指南
- 集成步骤
- App Store 提交流程
- 常见问题

#### `SUMMARY.md` - 本文档
总结所有完成的工作和使用方法。

## 关键特性

### 1. 隐私合规
✓ 完整的隐私清单配置
✓ 所有必需原因 API 已声明
✓ 权限描述清晰准确
✓ 符合 Apple 最新隐私要求

### 2. 签名配置
✓ 支持自动签名和手动签名
✓ Team ID 和 Bundle ID 正确配置
✓ Provisioning Profile 配置指南
✓ 签名验证工具

### 3. 架构支持
✓ arm64 (真机)
✓ x86_64/arm64 (模拟器)
✓ XCFramework 格式
✓ 支持 iOS 13.0+

### 4. App Store 审核
✓ 禁用 Bitcode
✓ 隐私清单完整
✓ 加密合规声明
✓ 第三方 SDK 声明准备

### 5. 自动化工具
✓ 一键打包脚本
✓ 自动验证工具
✓ 签名配置助手
✓ 详细的错误提示

## 使用方法

### 快速开始（推荐）

```bash
# 一键完成所有步骤
./package_for_appstore.sh
```

### 分步执行

```bash
# 1. 构建 Framework
./build_framework.sh

# 2. 验证 Framework
./verify_framework.sh

# 3. 配置签名
./configure_signing.sh
```

### 查看文档

```bash
# 查看 App Store 提交指南
cat APP_STORE_SUBMISSION_GUIDE.md

# 查看检查清单
cat CHECKLIST.md

# 查看集成指南
cat build/frameworks/INTEGRATION_GUIDE.md
```

## 输出产物

运行构建脚本后，将在 `build/frameworks/Release/` 目录生成以下文件：

### Frameworks
- `App.xcframework` - Flutter 应用代码
- `Flutter.xcframework` - Flutter 引擎
- `FlutterPluginRegistrant.xcframework` - 插件注册
- `in_app_purchase_storekit.xcframework` - 内购插件
- `shared_preferences_foundation.xcframework` - 本地存储插件
- `url_launcher_ios.xcframework` - URL 启动插件
- `webview_flutter_wkwebview.xcframework` - WebView 插件

### 文档
- `INTEGRATION_GUIDE.md` - 集成指南
- `SIGNING_CONFIG.md` - 签名配置（运行 configure_signing.sh 后生成）

## 集成到 OC 项目

### 1. 添加 Frameworks
将所有 `.xcframework` 文件拖入 Xcode 项目，设置 Embed 为 "Embed & Sign"。

### 2. 配置 Build Settings
- Framework Search Paths: `$(inherited) $(PROJECT_DIR)/Frameworks`
- Other Linker Flags: `-ObjC`
- Enable Bitcode: `NO`
- iOS Deployment Target: `13.0`

### 3. 初始化 Flutter Engine
```objc
self.flutterEngine = [[FlutterEngine alloc] initWithName:@"tanyu_engine"];
[self.flutterEngine run];
```

### 4. 展示 Flutter 页面
```objc
FlutterViewController *flutterVC = [[FlutterViewController alloc] initWithEngine:engine nibName:nil bundle:nil];
[self.navigationController pushViewController:flutterVC animated:YES];
```

## App Store 提交流程

1. **构建 Framework**
   ```bash
   ./package_for_appstore.sh
   ```

2. **集成到项目**
   - 添加 frameworks
   - 配置 Build Settings
   - 配置签名

3. **测试**
   - 真机测试所有功能
   - 检查性能和稳定性
   - 运行验证脚本

4. **Archive**
   - Product → Archive
   - 等待 Archive 完成

5. **导出和上传**
   - Distribute App → App Store Connect
   - 选择正确的签名
   - 上传到 App Store Connect

6. **TestFlight 测试**
   - 等待处理完成
   - 内部测试
   - 收集反馈

7. **提交审核**
   - 填写应用信息
   - 上传截图
   - 声明隐私和数据收集
   - 提交审核

## 关键配置

### Team ID
```
UG5N3PCLJ5
```

### Bundle ID
```
com.tantan.yu
```

### 最低支持版本
```
iOS 13.0
```

### 签名证书
```
Apple Distribution
```

## 常见问题

### Q: 构建失败？
A: 检查 Flutter SDK 版本、依赖安装、Xcode 版本

### Q: 集成后黑屏？
A: 确保 Flutter Engine 已初始化并调用 run 方法

### Q: 签名错误？
A: 检查证书、Provisioning Profile、Team ID 配置

### Q: 审核被拒？
A: 检查隐私清单、权限描述、必需原因 API 声明

详细解决方案请查看 [APP_STORE_SUBMISSION_GUIDE.md](APP_STORE_SUBMISSION_GUIDE.md)。

## 技术栈

- Flutter 3.10.7+
- Dart 3.x
- iOS 13.0+
- Xcode 14.0+
- CocoaPods 1.11.0+

## 依赖插件

- in_app_purchase - 内购功能
- shared_preferences - 本地存储
- url_launcher - URL 启动
- webview_flutter - WebView
- http - 网络请求
- carousel_slider - 轮播图
- flutter_staggered_grid_view - 瀑布流

## 下一步

1. 运行 `./package_for_appstore.sh` 构建 Framework
2. 将 frameworks 集成到你的 OC 项目
3. 在真机上测试所有功能
4. 运行 `./verify_framework.sh` 验证
5. Archive 并提交到 App Store Connect

## 支持

如有问题，请查看：
- [APP_STORE_SUBMISSION_GUIDE.md](APP_STORE_SUBMISSION_GUIDE.md)
- [CHECKLIST.md](CHECKLIST.md)
- [README.md](README.md)

或联系开发团队获取支持。

---

**版本:** 1.0.5  
**创建日期:** 2026-02-21  
**最后更新:** 2026-02-21
