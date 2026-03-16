# Framework 签名问题修复说明

## 问题描述

在 Xcode 中集成 frameworks 时，出现以下错误：

```
"url_launcher_ios.xcframework" is not signed with the expected identity and may have been compromised.

Expected Signature
Team Name: Lonaa Chisholmm
Team ID: UG5N3PCLJ5
Kind: Apple Developer Program

Found Signature
No Signature
```

除了 Flutter.xcframework 之外，所有其他 frameworks 都报这个错误。

## 问题原因

Xcode 在验证 frameworks 时需要更严格的签名参数：
1. 需要 `--options runtime` 标志
2. 需要 `--generate-entitlement-der` 标志
3. 需要确保所有嵌套的二进制文件都被正确签名
4. 需要使用 `--verbose` 模式进行详细验证

## 解决方案

### 方法一：使用修复脚本（推荐）

已创建专门的修复脚本 `fix_framework_signatures.sh`，可以重新签名所有 frameworks：

```bash
./fix_framework_signatures.sh
```

这个脚本会：
1. ✅ 删除所有旧签名
2. ✅ 签名所有嵌套的二进制文件（.dylib, .so）
3. ✅ 签名所有可执行文件
4. ✅ 使用严格参数签名整个 framework
5. ✅ 验证签名的有效性
6. ✅ 跳过 Flutter.xcframework（保持官方签名）

### 方法二：重新打包

更新后的 `build_framework_for_integration.sh` 已经包含了严格的签名参数，重新打包即可：

```bash
./build_framework_for_integration.sh
```

选择选项 2（Apple Distribution 证书）。

## 签名参数说明

### 旧的签名方式（有问题）
```bash
codesign --force --deep --sign "$IDENTITY" --timestamp "$framework"
```

### 新的签名方式（修复后）
```bash
# 1. 先签名嵌套的二进制文件
codesign --force --sign "$IDENTITY" --timestamp --options runtime "$binary"

# 2. 再签名整个 framework
codesign --force --sign "$IDENTITY" \
    --timestamp \
    --generate-entitlement-der \
    --options runtime \
    --deep \
    --verbose \
    "$framework"

# 3. 验证签名
codesign --verify --deep --strict --verbose=2 "$framework"
```

### 关键参数解释

- `--options runtime`: 启用 Hardened Runtime，App Store 要求
- `--generate-entitlement-der`: 生成 DER 格式的 entitlements
- `--deep`: 深度签名，包括所有嵌套内容
- `--verbose`: 详细输出，便于调试
- `--strict`: 严格验证模式
- `--timestamp`: 添加时间戳，App Store 要求

## 验证签名

### 检查单个 framework
```bash
codesign -dvvv ./build/frameworks/Release/url_launcher_ios.xcframework/ios-arm64/url_launcher_ios.framework
```

应该看到：
```
Authority=Apple Distribution: Lonaa Chisholmm (UG5N3PCLJ5)
TeamIdentifier=UG5N3PCLJ5
```

### 验证签名有效性
```bash
codesign --verify --deep --strict --verbose=2 ./build/frameworks/Release/url_launcher_ios.xcframework/ios-arm64/url_launcher_ios.framework
```

应该看到：
```
valid on disk
satisfies its Designated Requirement
```

## 在 Xcode 中使用

### 1. 删除旧的 frameworks
在 Xcode 项目中，删除所有旧的 .xcframework 文件。

### 2. 添加新的 frameworks
将 `./build/frameworks/Release/` 中的所有 .xcframework 文件拖入项目。

### 3. 配置 Embed 选项
在 Target -> General -> Frameworks, Libraries, and Embedded Content：
- 所有 frameworks 设置为 **"Embed & Sign"**

### 4. Clean Build
```
Cmd + Shift + K
```

### 5. 重新编译
```
Cmd + B
```

## 签名状态总结

修复后的签名状态：

| Framework | 签名证书 | Team ID | 状态 |
|-----------|---------|---------|------|
| App.xcframework | Apple Distribution: Lonaa Chisholmm | UG5N3PCLJ5 | ✅ 已修复 |
| Flutter.xcframework | Developer ID Application: FLUTTER.IO LLC | S8QB4VV633 | ✅ 保持官方签名 |
| in_app_purchase_storekit.xcframework | Apple Distribution: Lonaa Chisholmm | UG5N3PCLJ5 | ✅ 已修复 |
| shared_preferences_foundation.xcframework | Apple Distribution: Lonaa Chisholmm | UG5N3PCLJ5 | ✅ 已修复 |
| url_launcher_ios.xcframework | Apple Distribution: Lonaa Chisholmm | UG5N3PCLJ5 | ✅ 已修复 |
| webview_flutter_wkwebview.xcframework | Apple Distribution: Lonaa Chisholmm | UG5N3PCLJ5 | ✅ 已修复 |

## 常见问题

### Q1: 为什么 Flutter.xcframework 不需要重新签名？
A: Flutter.xcframework 使用 Flutter 官方签名，这是被 Apple 认可的。重新签名反而可能导致问题。

### Q2: 签名后还是报错怎么办？
A: 
1. 确保在 Xcode 中完全删除了旧的 frameworks
2. Clean Build Folder (Cmd + Shift + K)
3. 删除 DerivedData: `rm -rf ~/Library/Developer/Xcode/DerivedData`
4. 重新添加 frameworks
5. 重新编译

### Q3: 可以用开发证书签名吗？
A: 可以，但建议：
- 开发和测试：使用 Apple Development 证书
- App Store 提交：使用 Apple Distribution 证书

### Q4: 签名大小不一致有问题吗？
A: 签名大小在 9096-9097 bytes 之间的微小差异是正常的，不影响使用。

## 脚本文件说明

### build_framework_for_integration.sh
- 用途：从头开始打包 frameworks
- 特点：包含严格的签名参数
- 使用场景：Flutter 代码更新后重新打包

### fix_framework_signatures.sh
- 用途：修复已有 frameworks 的签名问题
- 特点：只重新签名，不重新编译
- 使用场景：签名出现问题时快速修复

## 技术细节

### 签名顺序很重要

正确的签名顺序：
1. 签名所有 .dylib 和 .so 文件
2. 签名所有可执行文件
3. 签名整个 .framework
4. 验证签名

错误的顺序会导致签名无效。

### Hardened Runtime

`--options runtime` 启用 Hardened Runtime，这是 macOS 10.14+ 和 iOS 的要求。

Hardened Runtime 提供：
- 代码注入保护
- 动态链接库验证
- JIT 编译限制
- 调试器保护

### DER Entitlements

`--generate-entitlement-der` 生成 DER 格式的 entitlements，这是新版本 Xcode 的要求。

## 总结

✅ 问题已修复
✅ 所有 frameworks 都使用严格的签名参数
✅ Flutter.xcframework 保持官方签名
✅ 签名验证通过
✅ 可以正常集成到 Xcode 项目

---

最后更新：2026-03-10
