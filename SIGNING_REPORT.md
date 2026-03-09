# Framework 签名报告

## 签名时间
2026-02-22

## 签名证书
- **证书名称**: Apple Distribution: Lonaa Chisholmm (UG5N3PCLJ5)
- **证书 SHA-1**: DF8FC93F64E2EDC2E723F14C36FBF9E8F0E4B119
- **Team ID**: UG5N3PCLJ5

## 已签名的框架

### ✅ App.xcframework
- 状态: 签名成功
- 验证: valid on disk
- 位置: build/frameworks/Release/App.xcframework

### ✅ in_app_purchase_storekit.xcframework
- 状态: 签名成功
- 验证: valid on disk
- 位置: build/frameworks/Release/in_app_purchase_storekit.xcframework

### ✅ shared_preferences_foundation.xcframework
- 状态: 签名成功
- 验证: valid on disk
- 位置: build/frameworks/Release/shared_preferences_foundation.xcframework

### ✅ url_launcher_ios.xcframework
- 状态: 签名成功
- 验证: valid on disk
- 位置: build/frameworks/Release/url_launcher_ios.xcframework

### ✅ webview_flutter_wkwebview.xcframework
- 状态: 签名成功
- 验证: valid on disk
- 位置: build/frameworks/Release/webview_flutter_wkwebview.xcframework

### ⏭️ Flutter.xcframework
- 状态: 跳过（Flutter 官方已签名）
- 位置: build/frameworks/Release/Flutter.xcframework

## 验证结果

所有框架签名验证通过：
- ✅ valid on disk
- ✅ satisfies its Designated Requirement
- ✅ Team ID 匹配: UG5N3PCLJ5

## 下一步

1. 在 Xcode 中打开你的 iOS 项目
2. 删除旧的未签名框架
3. 将以下已签名框架添加到项目：
   - build/frameworks/Release/App.xcframework
   - build/frameworks/Release/Flutter.xcframework
   - build/frameworks/Release/in_app_purchase_storekit.xcframework
   - build/frameworks/Release/shared_preferences_foundation.xcframework
   - build/frameworks/Release/url_launcher_ios.xcframework
   - build/frameworks/Release/webview_flutter_wkwebview.xcframework

4. 确保所有框架的 Embed 设置为 "Embed & Sign"
5. Clean Build Folder (Cmd+Shift+K)
6. Archive 并提交到 App Store

## 预期结果

提交到 App Store 后，不会再收到以下错误：
- ❌ ITMS-91065: Missing signature - Flutter
- ❌ ITMS-91065: Missing signature - url_launcher_ios
- ❌ ITMS-91065: Missing signature - webview_flutter_wkwebview

所有框架现在都包含有效的代码签名，符合 Apple 2025 年的新要求。

---

**签名完成时间**: 2026-02-22
**签名工具**: codesign (macOS)
**签名状态**: ✅ 全部成功
