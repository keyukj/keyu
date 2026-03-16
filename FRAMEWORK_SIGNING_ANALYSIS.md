# Flutter Framework 签名分析报告

## 📋 原始构建签名状态

当使用 `flutter build ios-framework` 命令构建时，各个 framework 的签名状态如下：

### 1. Flutter.xcframework ✅ 已签名
```
Identifier: io.flutter.flutter
Authority: Developer ID Application: FLUTTER.IO LLC (S8QB4VV633)
Authority: Developer ID Certification Authority
Authority: Apple Root CA
```
**结论：** Flutter 引擎由 Flutter 官方团队签名，使用 FLUTTER.IO LLC 的开发者证书。

### 2. App.xcframework ⚠️ Ad-hoc 签名
```
Identifier: io.flutter.flutter.app
Signature: adhoc
TeamIdentifier: not set
```
**结论：** 你的 Flutter 应用代码使用 ad-hoc 签名（临时签名），没有使用正式证书。

### 3. 插件 Frameworks ❌ 未签名
- in_app_purchase_storekit.xcframework
- shared_preferences_foundation.xcframework
- url_launcher_ios.xcframework
- webview_flutter_wkwebview.xcframework

```
code object is not signed at all
```
**结论：** 所有插件 frameworks 都没有签名。

## 🎯 是否需要重新签名？

### 场景 1：嵌入到其他 iOS 项目（推荐方式）
**答案：不需要手动签名**

当你将这些 frameworks 拖入 Xcode 项目并设置为 "Embed & Sign" 时：
- Xcode 会自动使用主项目的签名证书重新签名所有 frameworks
- 包括 Flutter.xcframework（会覆盖 Flutter 官方签名）
- 包括 App.xcframework（会替换 ad-hoc 签名）
- 包括所有插件 frameworks（会添加签名）

**推荐使用：** `build_framework_unsigned.sh` 脚本

### 场景 2：直接分发 Framework（不推荐）
**答案：需要手动签名**

如果你要直接分发这些 frameworks 给其他开发者使用，需要：
- 使用 Apple Distribution 证书签名所有 frameworks
- 确保签名一致性

**使用：** `sign_frameworks.sh` 脚本

## 📝 最佳实践建议

### 方案 A：嵌入到 iOS 项目（推荐）✅

1. 使用未签名版本打包：
```bash
./build_framework_unsigned.sh
```

2. 将 frameworks 拖入 Xcode 项目

3. 设置为 "Embed & Sign"

4. Xcode 自动处理签名

**优点：**
- 简单，不需要手动签名
- Xcode 自动管理签名
- 避免证书冲突
- 签名一致性由 Xcode 保证

### 方案 B：预签名版本（特殊场景）

1. 使用签名脚本：
```bash
./build_framework_unsigned.sh
./sign_frameworks.sh
```

2. 分发已签名的 frameworks

**适用场景：**
- 需要分发给多个团队
- 需要验证签名完整性
- 特殊的企业分发需求

## 🔍 签名验证命令

检查 framework 签名状态：
```bash
# 检查是否签名
codesign -dv path/to/Framework.framework

# 查看签名详情
codesign -dvv path/to/Framework.framework

# 验证签名有效性
codesign --verify --deep --strict path/to/Framework.framework
```

## ⚠️ 重要提示

1. **Flutter.xcframework 的签名**
   - 原始由 Flutter 官方签名
   - 嵌入项目后会被 Xcode 重新签名
   - 这是正常且必要的

2. **App.xcframework 的 ad-hoc 签名**
   - 这是 Flutter 构建的默认行为
   - 必须在最终应用中重新签名
   - 不影响功能

3. **插件 frameworks 未签名**
   - 这是正常的
   - 由主项目统一签名
   - 不需要预先签名

## 📊 总结

| Framework | 原始状态 | 是否需要重新签名 | 何时签名 |
|-----------|---------|----------------|---------|
| Flutter.xcframework | Flutter 官方签名 | 是 | Xcode 自动 |
| App.xcframework | Ad-hoc 签名 | 是 | Xcode 自动 |
| 插件 frameworks | 未签名 | 是 | Xcode 自动 |

**结论：** 对于嵌入到 iOS 项目的场景，使用未签名版本，让 Xcode 自动处理签名是最佳实践。
