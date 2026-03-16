# App Store 打包上架完整指南

## 🎯 目标
将 Flutter 应用打包成 Framework，集成到 iOS 原生项目，并上架 App Store。

## 📋 前置要求

### 必需的证书和配置
- ✅ Apple Distribution 证书: `Apple Distribution: Lonaa Chisholmm (UG5N3PCLJ5)`
- ✅ App Store Provisioning Profile
- ✅ Bundle ID: `com.tantan.yu`
- ✅ Team ID: `UG5N3PCLJ5`

### 必需的工具
- ✅ Xcode 15+
- ✅ Flutter 3.38.7
- ✅ CocoaPods
- ✅ 有效的 Apple Developer 账号

## 🚀 方法一：一键自动打包（推荐）

### 运行自动化脚本

```bash
./build_and_package_for_appstore.sh
```

这个脚本会自动完成：
1. ✅ 清理旧构建
2. ✅ 构建 Flutter Framework
3. ✅ 签名所有 Framework
4. ✅ Archive iOS 项目
5. ✅ 导出 IPA 文件

### 输出位置

- **Framework**: `build/ios/framework/Release/`
- **Archive**: `build/ios/ipa/彼趣.xcarchive`
- **IPA**: `build/ios/ipa/彼趣.ipa`

## 📱 方法二：手动分步打包

### 步骤 1: 构建并签名 Framework

```bash
# 1. 清理
flutter clean

# 2. 构建 Framework
flutter pub get
flutter build ios-framework --release

# 3. 签名 Framework
./sign_new_frameworks.sh
```

### 步骤 2: 在 Xcode 中集成 Framework

1. **打开 Xcode 项目**
   ```bash
   open ios/Runner.xcworkspace
   ```

2. **删除旧 Framework**
   - 在项目导航器中选择旧的 Framework
   - 右键 → Delete → Remove Reference

3. **添加新签名的 Framework**
   - 将 `build/ios/framework/Release/` 中的所有 `.xcframework` 拖入项目
   - 勾选 "Copy items if needed"
   - 选择正确的 Target

4. **配置 Embed 设置**
   - 选择项目 Target
   - General → Frameworks, Libraries, and Embedded Content
   - 确保所有 Framework 设置为 **"Embed & Sign"**

### 步骤 3: Archive

1. **选择目标设备**
   - 在 Xcode 顶部选择 "Any iOS Device (arm64)"

2. **Clean Build**
   - Product → Clean Build Folder (Cmd+Shift+K)

3. **Archive**
   - Product → Archive
   - 等待 Archive 完成（约 5-10 分钟）

### 步骤 4: 导出 IPA

1. **打开 Organizer**
   - Window → Organizer (Cmd+Shift+Option+O)
   - 或 Archive 完成后自动打开

2. **选择 Archive**
   - 选择刚才创建的 Archive

3. **Distribute App**
   - 点击 "Distribute App"
   - 选择 "App Store Connect"
   - 选择 "Upload"

4. **配置选项**
   - ✅ Strip Swift symbols
   - ✅ Upload symbols (可选)
   - ☐ Bitcode (已禁用)

5. **签名**
   - 选择 "Automatically manage signing"
   - 或手动选择证书和 Provisioning Profile

6. **上传**
   - 点击 "Upload"
   - 等待上传完成（约 5-15 分钟）

## 📤 方法三：使用命令行上传

### 验证 IPA

```bash
xcrun altool --validate-app \
  -f build/ios/ipa/彼趣.ipa \
  -t ios \
  -u lonaachisholmm10@icloud.com \
  -p vcjn-nxtu-cwmw-ewsy
```

### 上传 IPA

```bash
xcrun altool --upload-app \
  -f build/ios/ipa/彼趣.ipa \
  -t ios \
  -u lonaachisholmm10@icloud.com \
  -p vcjn-nxtu-cwmw-ewsy
```

### 使用 Transporter 应用

1. 打开 Transporter 应用（从 App Store 下载）
2. 拖入 IPA 文件
3. 点击 "交付"
4. 等待上传完成

## 🔍 常见问题排查

### 问题 1: Archive 失败

**错误**: "Code signing failed"

**解决方案**:
```bash
# 1. 检查证书
security find-identity -v -p codesigning

# 2. 清理 Xcode 缓存
rm -rf ~/Library/Developer/Xcode/DerivedData/*

# 3. 重新 Archive
```

### 问题 2: Framework 签名失败

**错误**: "signature-collection failed"

**解决方案**:
```bash
# 重新构建并签名
./rebuild_and_sign.sh
```

### 问题 3: IPA 上传失败

**错误**: "ITMS-91065: Missing signature"

**解决方案**:
```bash
# 确保所有 Framework 已签名
./sign_new_frameworks.sh

# 验证签名
codesign --verify --verbose build/ios/framework/Release/url_launcher_ios.xcframework
```

### 问题 4: 构建时间过长

**优化方案**:
```bash
# 只构建 Release 模式
flutter build ios-framework --release

# 跳过不必要的步骤
flutter build ios-framework --release --no-tree-shake-icons
```

## ✅ 提交前检查清单

### Framework 检查
- [ ] 所有 Framework 已构建
- [ ] 所有 Framework 已签名（除 Flutter.xcframework）
- [ ] 签名验证通过

### Xcode 项目检查
- [ ] Framework 已正确嵌入
- [ ] Embed 设置为 "Embed & Sign"
- [ ] Bundle ID 正确: `com.tantan.yu`
- [ ] Team ID 正确: `UG5N3PCLJ5`
- [ ] 版本号已更新

### 隐私和权限
- [ ] Info.plist 包含所有权限描述
- [ ] PrivacyInfo.xcprivacy 文件存在
- [ ] 必需原因 API 已声明

### 测试
- [ ] 真机测试通过
- [ ] 所有功能正常
- [ ] 无崩溃和严重 bug
- [ ] 内购功能测试通过

### App Store Connect
- [ ] 应用信息已填写
- [ ] 截图已上传
- [ ] 隐私政策 URL 有效
- [ ] 审核信息已填写

## 📊 打包时间估算

| 步骤 | 预计时间 |
|------|---------|
| 构建 Framework | 2-3 分钟 |
| 签名 Framework | 10-20 秒 |
| Archive | 5-10 分钟 |
| 导出 IPA | 1-2 分钟 |
| 上传到 App Store | 5-15 分钟 |
| **总计** | **15-30 分钟** |

## 🎯 快速命令参考

```bash
# 一键打包
./build_and_package_for_appstore.sh

# 只构建 Framework
flutter build ios-framework --release

# 只签名 Framework
./sign_new_frameworks.sh

# 验证签名
codesign --verify --verbose build/ios/framework/Release/*.xcframework

# 清理构建
flutter clean && rm -rf build/

# 打开 Xcode
open ios/Runner.xcworkspace
```

## 📚 相关文档

- [APP_STORE_SUBMISSION_GUIDE.md](APP_STORE_SUBMISSION_GUIDE.md) - 详细提交指南
- [FINAL_SIGNING_REPORT.md](FINAL_SIGNING_REPORT.md) - 签名报告
- [CHECKLIST.md](CHECKLIST.md) - 完整检查清单
- [FRAMEWORK_INTEGRATION.md](FRAMEWORK_INTEGRATION.md) - Framework 集成指南

## 🆘 获取帮助

如果遇到问题：

1. 查看错误日志
2. 参考相关文档
3. 检查证书和配置
4. 清理并重新构建

---

**最后更新**: 2026-02-22  
**应用名称**: 彼趣  
**Bundle ID**: com.tantan.yu  
**Team ID**: UG5N3PCLJ5
