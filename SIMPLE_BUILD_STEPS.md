# 简单打包步骤

## ✅ 已完成的准备工作

1. ✅ 所有依赖已更新到最新版本
2. ✅ CocoaPods 已重新安装
3. ✅ 品牌名称已更改为"彼趣"

## 🚀 打包步骤

### 方法 1: 使用自动化脚本（推荐）

```bash
./quick_build_ipa.sh
```

这个脚本会自动完成：
1. 构建 iOS 应用
2. Archive
3. 导出 IPA

### 方法 2: 手动在 Xcode 中打包

#### 步骤 1: 打开项目
```bash
open ios/Runner.xcworkspace
```

#### 步骤 2: 选择目标
- 在 Xcode 顶部选择 "Any iOS Device (arm64)"

#### 步骤 3: Clean Build
- Product → Clean Build Folder (Cmd+Shift+K)

#### 步骤 4: Archive
- Product → Archive
- 等待 5-10 分钟

#### 步骤 5: 导出 IPA
1. Archive 完成后会自动打开 Organizer
2. 选择刚才的 Archive
3. 点击 "Distribute App"
4. 选择 "App Store Connect"
5. 选择 "Upload"
6. 选择 "Automatically manage signing"
7. 点击 "Upload"

## 📤 上传到 App Store

### 使用 Transporter（最简单）
```bash
open -a Transporter build/ios/ipa/彼趣.ipa
```

### 使用命令行
```bash
xcrun altool --upload-app \
  -f build/ios/ipa/彼趣.ipa \
  -t ios \
  -u lonaachisholmm10@icloud.com \
  -p vcjn-nxtu-cwmw-ewsy
```

## ⏱️ 预计时间

- 构建: 3-5 分钟
- Archive: 5-10 分钟
- 导出: 1-2 分钟
- 上传: 5-15 分钟
- **总计: 15-30 分钟**

## 🔍 如果遇到错误

### 签名错误
在 Xcode 中：
1. 选择项目 Target
2. Signing & Capabilities
3. 确保 "Automatically manage signing" 已勾选
4. Team 选择: Lonaa Chisholmm (UG5N3PCLJ5)

### 构建失败
```bash
flutter clean
flutter pub get
pod install --repo-update
```

### Archive 失败
在 Xcode 中检查：
1. Build Settings → Code Signing Identity
2. 确保设置为 "Apple Distribution"
3. 或设置为 "Automatic"

## ✅ 完成后

1. 在 App Store Connect 中查看构建版本
2. 等待处理完成（5-30 分钟）
3. 选择构建版本
4. 提交审核

---

**当前版本**: 1.0.9  
**Bundle ID**: com.tantan.yu  
**Team ID**: UG5N3PCLJ5
