# 🚀 快速打包上架指南

## 一键打包（最简单）

```bash
./build_and_package_for_appstore.sh
```

完成后，IPA 文件位于：`build/ios/ipa/彼趣.ipa`

## 上传到 App Store

### 方法 1: 使用 Transporter（推荐）
1. 打开 Transporter 应用
2. 拖入 `build/ios/ipa/彼趣.ipa`
3. 点击"交付"

### 方法 2: 使用命令行
```bash
xcrun altool --upload-app \
  -f build/ios/ipa/彼趣.ipa \
  -t ios \
  -u lonaachisholmm10@icloud.com \
  -p vcjn-nxtu-cwmw-ewsy
```

### 方法 3: 使用 Xcode
1. `open ios/Runner.xcworkspace`
2. Product → Archive
3. Distribute App → App Store Connect → Upload

## 如果遇到问题

### 签名错误
```bash
./sign_new_frameworks.sh
```

### 构建失败
```bash
flutter clean
flutter pub get
./build_and_package_for_appstore.sh
```

### 验证 IPA
```bash
xcrun altool --validate-app \
  -f build/ios/ipa/彼趣.ipa \
  -t ios \
  -u lonaachisholmm10@icloud.com \
  -p vcjn-nxtu-cwmw-ewsy
```

## 完整流程时间

- 构建: 2-3 分钟
- Archive: 5-10 分钟  
- 上传: 5-15 分钟
- **总计: 15-30 分钟**

## 检查清单

- [ ] 运行 `./build_and_package_for_appstore.sh`
- [ ] 检查 IPA 文件已生成
- [ ] 上传到 App Store Connect
- [ ] 在 App Store Connect 中选择构建版本
- [ ] 提交审核

---

详细文档: [APPSTORE_PACKAGE_GUIDE.md](APPSTORE_PACKAGE_GUIDE.md)
