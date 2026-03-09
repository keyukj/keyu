# ITMS-91065 错误快速修复指南

## 问题
```
ITMS-91065: Missing signature - Your app includes "Frameworks/Flutter.framework/Flutter"
ITMS-91065: Missing signature - Your app includes "Frameworks/url_launcher_ios.framework/url_launcher_ios"
ITMS-91065: Missing signature - Your app includes "Frameworks/webview_flutter_wkwebview.framework/webview_flutter_wkwebview"
```

## 原因
Apple 从 2025 年开始强制要求所有第三方 SDK 必须包含代码签名。

## 解决步骤

### 方案一：一键构建并签名（推荐）

```bash
./build_and_sign_frameworks.sh
```

### 方案二：分步执行

```bash
# 1. 构建框架
./build_framework.sh

# 2. 签名框架
./sign_frameworks.sh
```

### 验证签名

```bash
# 验证单个框架
codesign --verify --verbose build/frameworks/Release/url_launcher_ios.xcframework

# 查看签名信息
codesign -dv build/frameworks/Release/url_launcher_ios.xcframework
```

## 在 Xcode 中更新

1. 删除项目中的旧框架
2. 将 `build/frameworks/Release/` 中的已签名框架拖入项目
3. 确保 Embed 设置为 "Embed & Sign"
4. Clean Build Folder (Cmd+Shift+K)
5. Archive 并提交

## 注意事项

- ✅ Flutter.xcframework 会自动跳过（Flutter 官方已签名）
- ✅ 其他所有插件框架都会被签名
- ✅ 脚本会自动检测你的 Apple Distribution 证书
- ⚠️ 如果找不到证书，手动指定：
  ```bash
  export CODESIGN_IDENTITY="Apple Distribution: Your Name (TEAM_ID)"
  ./sign_frameworks.sh
  ```

## 查看可用证书

```bash
security find-identity -v -p codesigning
```

## 完成
签名后的框架可以通过 App Store 审核，不会再出现 ITMS-91065 错误。
