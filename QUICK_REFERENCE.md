# 快速参考 - Framework 签名和提交

## 🎯 当前状态
✅ 所有框架已成功签名  
✅ 使用证书: Apple Distribution: Lonaa Chisholmm (UG5N3PCLJ5)  
✅ 准备提交 App Store

## 📍 已签名框架位置
```
build/ios/framework/Release/
├── App.xcframework ✅
├── Flutter.xcframework ⏭️ (官方已签名)
├── in_app_purchase_storekit.xcframework ✅
├── shared_preferences_foundation.xcframework ✅
├── url_launcher_ios.xcframework ✅
└── webview_flutter_wkwebview.xcframework ✅
```

## 🚀 立即执行步骤

### 1. 在 Xcode 中更新框架（5分钟）
```
1. 打开 Xcode 项目
2. 删除旧框架（选中 → Delete → Remove Reference）
3. 拖入新框架（从 build/ios/framework/Release/）
4. 确保 Embed 设置为 "Embed & Sign"
```

### 2. Clean Build（1分钟）
```
Cmd + Shift + K
或
Product → Clean Build Folder
```

### 3. Archive（5-10分钟）
```
1. 选择 "Any iOS Device (arm64)"
2. Product → Archive
3. 等待完成
```

### 4. 提交（10-15分钟）
```
1. Organizer → 选择 Archive
2. Distribute App
3. App Store Connect → Upload
4. 完成上传
```

## ⚡ 常用命令

### 重新构建并签名
```bash
./rebuild_and_sign.sh
```

### 仅签名现有框架
```bash
./sign_new_frameworks.sh
```

### 验证签名
```bash
codesign --verify --verbose build/ios/framework/Release/url_launcher_ios.xcframework
```

### 查看签名详情
```bash
codesign -dv build/ios/framework/Release/url_launcher_ios.xcframework
```

## ❌ 解决的错误
```
ITMS-91065: Missing signature - Flutter
ITMS-91065: Missing signature - url_launcher_ios
ITMS-91065: Missing signature - webview_flutter_wkwebview
```

## ✅ 预期结果
- 不会再收到 ITMS-91065 错误
- 可以成功提交到 App Store
- 通过 Apple 审核

## 📚 详细文档
- [FINAL_SIGNING_REPORT.md](FINAL_SIGNING_REPORT.md) - 完整签名报告
- [APP_STORE_SUBMISSION_GUIDE.md](APP_STORE_SUBMISSION_GUIDE.md) - 提交指南
- [ITMS-91065_FIX.md](ITMS-91065_FIX.md) - 错误修复指南

## 🆘 遇到问题？

### 问题：Xcode 构建失败
**解决**：Clean Build Folder (Cmd+Shift+K) 后重试

### 问题：签名验证失败
**解决**：运行 `./sign_new_frameworks.sh` 重新签名

### 问题：Archive 失败
**解决**：检查所有框架 Embed 设置为 "Embed & Sign"

---

**准备就绪！** 🎉 现在可以提交到 App Store 了。
