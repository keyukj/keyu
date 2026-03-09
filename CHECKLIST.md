# App Store 提交检查清单

## 构建前准备

### 代码准备
- [ ] 所有功能已完成并测试
- [ ] 已修复所有已知 bug
- [ ] 代码已提交到版本控制
- [ ] 版本号已更新（pubspec.yaml 和 Info.plist）

### 依赖检查
- [ ] Flutter SDK 版本正确
- [ ] 所有依赖包版本稳定
- [ ] 运行 `flutter pub get` 成功
- [ ] 运行 `pod install` 成功

## Framework 构建

### 构建和签名步骤（重要！）
- [ ] 运行 `./build_and_sign_frameworks.sh` 成功（推荐）
  - 或分步执行：
    - [ ] 运行 `./build_framework.sh` 成功
    - [ ] 运行 `./sign_frameworks.sh` 成功
- [ ] 所有必需的 frameworks 已生成并签名
  - [ ] App.xcframework ✅ 已签名
  - [ ] Flutter.xcframework ⏭️ 跳过（Flutter 官方已签名）
  - [ ] FlutterPluginRegistrant.xcframework ✅ 已签名
  - [ ] in_app_purchase_storekit.xcframework ✅ 已签名
  - [ ] shared_preferences_foundation.xcframework ✅ 已签名
  - [ ] url_launcher_ios.xcframework ✅ 已签名
  - [ ] webview_flutter_wkwebview.xcframework ✅ 已签名

### 签名验证
- [ ] 验证框架签名：`codesign --verify --verbose build/frameworks/Release/url_launcher_ios.xcframework`
- [ ] 所有框架签名有效（显示 "valid on disk"）
- [ ] 使用正确的证书签名（Apple Distribution 或 Apple Development）

### 架构支持
- [ ] 支持 arm64 (真机)
- [ ] 支持 x86_64/arm64 (模拟器)
- [ ] 所有架构都已正确编译

## 隐私和权限

### 隐私清单
- [ ] PrivacyInfo.xcprivacy 文件存在
- [ ] 隐私清单格式正确（XML 有效）
- [ ] 已声明所有使用的 API：
  - [ ] UserDefaults (CA92.1)
  - [ ] File Timestamp (C617.1)
  - [ ] System Boot Time (35F9.1)
  - [ ] Disk Space (E174.1)

### Info.plist 配置
- [ ] 所有权限描述已添加：
  - [ ] NSPhotoLibraryUsageDescription
  - [ ] NSPhotoLibraryAddUsageDescription
  - [ ] NSCameraUsageDescription
  - [ ] NSMicrophoneUsageDescription (如需要)
  - [ ] NSLocationWhenInUseUsageDescription (如需要)
  - [ ] NSUserTrackingUsageDescription
- [ ] ITSAppUsesNonExemptEncryption 已配置
- [ ] Bundle ID 正确
- [ ] 版本号和构建号正确

### 数据收集声明
- [ ] 已准备好在 App Store Connect 中声明：
  - [ ] 用户 ID - 应用功能
  - [ ] 产品交互数据 - 分析和应用功能
  - [ ] 购买历史 - 应用功能

## 签名配置

### 证书和 Profile
- [ ] Apple Distribution 证书已安装
- [ ] Provisioning Profile 已下载
- [ ] Team ID 正确: UG5N3PCLJ5
- [ ] Bundle ID 匹配: com.tantan.yu

### Xcode 配置
- [ ] 签名方式已选择（自动或手动）
- [ ] 所有 frameworks 的 Embed 设置为 "Embed & Sign"
- [ ] Build Settings 配置正确：
  - [ ] Framework Search Paths
  - [ ] Other Linker Flags: -ObjC
  - [ ] Enable Bitcode: NO
  - [ ] iOS Deployment Target: 13.0+
  - [ ] User Script Sandboxing: NO

## 代码集成

### OC 项目集成
- [ ] Frameworks 已添加到项目
- [ ] AppDelegate 中已初始化 FlutterEngine
- [ ] Method Channel 通信已实现
- [ ] 所有 Flutter 页面可以正常打开

### 功能测试
- [ ] 登录功能正常
- [ ] 主页显示正常
- [ ] AI 聊天功能正常
- [ ] 个人资料编辑正常
- [ ] 钱包充值功能正常
- [ ] WebView 加载正常
- [ ] 内购功能正常
- [ ] 本地存储正常
- [ ] 网络请求正常

## 测试

### 真机测试
- [ ] 在 iPhone 真机上安装成功
- [ ] 所有功能在真机上正常工作
- [ ] 无崩溃和严重 bug
- [ ] 性能表现良好（无卡顿）
- [ ] 内存占用合理

### 兼容性测试
- [ ] iOS 13.0 系统测试
- [ ] iOS 14.x 系统测试
- [ ] iOS 15.x 系统测试
- [ ] iOS 16.x 系统测试
- [ ] iOS 17.x 系统测试
- [ ] 不同 iPhone 机型测试
- [ ] iPad 测试（如支持）

### 场景测试
- [ ] 冷启动测试
- [ ] 热启动测试
- [ ] 后台切换测试
- [ ] 网络切换测试（WiFi/4G/5G）
- [ ] 弱网环境测试
- [ ] 无网环境测试
- [ ] 横竖屏切换测试
- [ ] 多任务切换测试

## 验证

### 自动验证
- [ ] 运行 `./verify_framework.sh` 通过
- [ ] 运行 `./configure_signing.sh` 成功
- [ ] 所有错误已修复
- [ ] 所有警告已处理

### 手动验证
- [ ] 检查 frameworks 签名状态
- [ ] 检查 frameworks 文件大小
- [ ] 检查隐私清单完整性
- [ ] 检查 Info.plist 配置

## Archive 和导出

### Archive
- [ ] 选择 "Any iOS Device (arm64)"
- [ ] Product → Archive 成功
- [ ] Archive 在 Organizer 中可见
- [ ] Archive 大小合理

### 导出 IPA
- [ ] 选择 "App Store Connect"
- [ ] 选择 "Upload"
- [ ] 签名配置正确
- [ ] Strip Swift symbols 已勾选
- [ ] 上传成功

## TestFlight

### 内部测试
- [ ] 构建版本已处理完成
- [ ] 添加内部测试人员
- [ ] 内部测试人员可以安装
- [ ] 所有功能在 TestFlight 版本中正常

### 外部测试（可选）
- [ ] 添加外部测试人员
- [ ] 提供测试说明
- [ ] 收集测试反馈
- [ ] 修复测试中发现的问题

## App Store Connect

### 应用信息
- [ ] 应用名称正确
- [ ] 副标题吸引人
- [ ] 描述详细准确
- [ ] 关键词优化
- [ ] 支持 URL 正确
- [ ] 营销 URL 正确（如有）

### 截图和预览
- [ ] 6.5 英寸截图已上传
- [ ] 5.5 英寸截图已上传
- [ ] iPad Pro 截图已上传（如支持）
- [ ] 应用预览视频已上传（可选）
- [ ] 所有截图清晰美观

### 版本信息
- [ ] 版本号正确
- [ ] 更新说明清晰
- [ ] 版权信息正确
- [ ] 分级评定完成

### 审核信息
- [ ] 联系信息准确
- [ ] 演示账号已提供（如需要）
- [ ] 审核备注清晰
- [ ] 附件已上传（如需要）

### 隐私政策
- [ ] 隐私政策 URL 有效
- [ ] 隐私政策内容完整
- [ ] 数据收集声明准确
- [ ] 第三方 SDK 已声明

## 提交审核

### 最后检查
- [ ] 所有信息已填写完整
- [ ] 所有截图和视频已上传
- [ ] 构建版本已选择
- [ ] 价格和销售范围已设置
- [ ] 分级评定已完成

### 提交
- [ ] 点击"提交审核"
- [ ] 确认所有信息正确
- [ ] 等待审核状态更新

## 审核后

### 审核通过
- [ ] 收到审核通过通知
- [ ] 设置发布时间
- [ ] 准备营销材料
- [ ] 监控用户反馈

### 审核被拒
- [ ] 阅读拒绝原因
- [ ] 修复问题
- [ ] 重新提交
- [ ] 如有疑问，联系审核团队

## 发布后

### 监控
- [ ] 监控崩溃率
- [ ] 监控用户评分
- [ ] 回复用户评论
- [ ] 收集用户反馈

### 更新计划
- [ ] 规划下一版本功能
- [ ] 修复用户报告的问题
- [ ] 优化性能和体验

---

## 快速命令

```bash
# 1. 构建并签名 Framework（推荐）
./build_and_sign_frameworks.sh

# 或分步执行：
# 1a. 构建 Framework
./build_framework.sh

# 1b. 签名 Framework
./sign_frameworks.sh

# 2. 验证签名
codesign --verify --verbose build/frameworks/Release/url_launcher_ios.xcframework

# 3. 查看可用证书
security find-identity -v -p codesigning

# 4. 配置签名
chmod +x configure_signing.sh
./configure_signing.sh

# 5. 验证 Framework
chmod +x verify_framework.sh
./verify_framework.sh

# 6. 查看集成指南
cat build/frameworks/INTEGRATION_GUIDE.md

# 7. 查看 App Store 提交指南
cat APP_STORE_SUBMISSION_GUIDE.md
```

## 相关文档

- [ITMS-91065_FIX.md](ITMS-91065_FIX.md) - 签名错误快速修复
- [APP_STORE_SUBMISSION_GUIDE.md](APP_STORE_SUBMISSION_GUIDE.md) - 详细提交指南
- [FRAMEWORK_README.md](FRAMEWORK_README.md) - Framework 说明
- [FRAMEWORK_INTEGRATION.md](FRAMEWORK_INTEGRATION.md) - 集成步骤
- [QUICK_START.md](QUICK_START.md) - 快速开始

---

**版本:** 1.0.5  
**最后更新:** 2026-02-21
