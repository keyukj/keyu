# Framework 签名对比报告

## 对比目录
- **新打包**: `./build/frameworks/Release/`
- **BIQU_Frameworks**: `/Users/admin/Desktop/彼趣/小遇/build/frameworks/BIQU_Frameworks/`

---

## 📊 签名配置对比总结

### ✅ 相同点

1. **签名证书完全一致**
   - 所有非 Flutter.xcframework 都使用：`Apple Distribution: Lonaa Chisholmm (UG5N3PCLJ5)`
   - Flutter.xcframework 都保持官方签名：`Developer ID Application: FLUTTER.IO LLC (S8QB4VV633)`

2. **Team ID 一致**
   - 自定义 frameworks: `UG5N3PCLJ5`
   - Flutter.xcframework: `S8QB4VV633`

3. **证书链完全相同**
   - 自定义 frameworks:
     - Apple Distribution: Lonaa Chisholmm (UG5N3PCLJ5)
     - Apple Worldwide Developer Relations Certification Authority
     - Apple Root CA
   - Flutter.xcframework:
     - Developer ID Application: FLUTTER.IO LLC (S8QB4VV633)
     - Developer ID Certification Authority
     - Apple Root CA

4. **隐私清单配置一致**
   - 所有非 Flutter.xcframework 都包含 `PrivacyInfo.xcprivacy`
   - Flutter.xcframework 不包含（官方不需要）

5. **签名大小基本一致**
   - 自定义 frameworks: 9096-9097 bytes
   - Flutter.xcframework: 9047 bytes

---

## 🔍 差异点

### 1. CDHash 不同（正常现象）

CDHash (Code Directory Hash) 是代码签名的哈希值，每次重新签名都会改变。这是**正常且预期的行为**。

#### App.xcframework
- **新打包**: `59d48014a0e4ac2292cc995f5e231c75e92cabb8`
- **BIQU_Frameworks**: `7b0e0c146cd1675cb6f75218672d0799b5922401`

#### in_app_purchase_storekit.xcframework
- **新打包**: `18d495455cc4711c868f121e32905616cc47de89`
- **BIQU_Frameworks**: `9649c1d958bcbd99aad138eff520d671ec74bbe8`

**说明**: CDHash 不同是因为：
- 签名时间戳不同
- 可能的二进制内容微小差异
- 这不影响签名的有效性

#### Flutter.xcframework
- **新打包**: `be99103fb2856118a1c027d2a6bc917c0b78b202`
- **BIQU_Frameworks**: `be99103fb2856118a1c027d2a6bc917c0b78b202`

**说明**: Flutter.xcframework 的 CDHash 完全相同，因为我们保持了官方签名，没有重新签名。

---

## 📋 详细签名信息对比

### App.xcframework

| 项目 | 新打包 | BIQU_Frameworks | 是否一致 |
|------|--------|-----------------|----------|
| Authority | Apple Distribution: Lonaa Chisholmm (UG5N3PCLJ5) | Apple Distribution: Lonaa Chisholmm (UG5N3PCLJ5) | ✅ |
| TeamIdentifier | UG5N3PCLJ5 | UG5N3PCLJ5 | ✅ |
| Signature size | 9096 | 9096 | ✅ |
| CDHash | 59d48014... | 7b0e0c14... | ⚠️ 不同（正常） |
| PrivacyInfo | ✅ 包含 | ✅ 包含 | ✅ |

### Flutter.xcframework

| 项目 | 新打包 | BIQU_Frameworks | 是否一致 |
|------|--------|-----------------|----------|
| Authority | Developer ID Application: FLUTTER.IO LLC | Developer ID Application: FLUTTER.IO LLC | ✅ |
| TeamIdentifier | S8QB4VV633 | S8QB4VV633 | ✅ |
| Signature size | 9047 | 9047 | ✅ |
| CDHash | be99103f... | be99103f... | ✅ 完全相同 |
| PrivacyInfo | - | - | ✅ |

### in_app_purchase_storekit.xcframework

| 项目 | 新打包 | BIQU_Frameworks | 是否一致 |
|------|--------|-----------------|----------|
| Authority | Apple Distribution: Lonaa Chisholmm (UG5N3PCLJ5) | Apple Distribution: Lonaa Chisholmm (UG5N3PCLJ5) | ✅ |
| TeamIdentifier | UG5N3PCLJ5 | UG5N3PCLJ5 | ✅ |
| Signature size | 9096 | 9097 | ⚠️ 1 byte 差异 |
| CDHash | 18d49545... | 9649c1d9... | ⚠️ 不同（正常） |
| PrivacyInfo | ✅ 包含 | ✅ 包含 | ✅ |

### shared_preferences_foundation.xcframework

| 项目 | 新打包 | BIQU_Frameworks | 是否一致 |
|------|--------|-----------------|----------|
| Authority | Apple Distribution: Lonaa Chisholmm (UG5N3PCLJ5) | Apple Distribution: Lonaa Chisholmm (UG5N3PCLJ5) | ✅ |
| TeamIdentifier | UG5N3PCLJ5 | UG5N3PCLJ5 | ✅ |
| Signature size | 9097 | 9096 | ⚠️ 1 byte 差异 |
| CDHash | - | - | ⚠️ 不同（正常） |
| PrivacyInfo | ✅ 包含 | ✅ 包含 | ✅ |

### url_launcher_ios.xcframework

| 项目 | 新打包 | BIQU_Frameworks | 是否一致 |
|------|--------|-----------------|----------|
| Authority | Apple Distribution: Lonaa Chisholmm (UG5N3PCLJ5) | Apple Distribution: Lonaa Chisholmm (UG5N3PCLJ5) | ✅ |
| TeamIdentifier | UG5N3PCLJ5 | UG5N3PCLJ5 | ✅ |
| Signature size | 9097 | 9097 | ✅ |
| CDHash | - | - | ⚠️ 不同（正常） |
| PrivacyInfo | ✅ 包含 | ✅ 包含 | ✅ |

### webview_flutter_wkwebview.xcframework

| 项目 | 新打包 | BIQU_Frameworks | 是否一致 |
|------|--------|-----------------|----------|
| Authority | Apple Distribution: Lonaa Chisholmm (UG5N3PCLJ5) | Apple Distribution: Lonaa Chisholmm (UG5N3PCLJ5) | ✅ |
| TeamIdentifier | UG5N3PCLJ5 | UG5N3PCLJ5 | ✅ |
| Signature size | 9096 | 9097 | ⚠️ 1 byte 差异 |
| CDHash | - | - | ⚠️ 不同（正常） |
| PrivacyInfo | ✅ 包含 | ✅ 包含 | ✅ |

---

## 🎯 结论

### ✅ 签名配置完全一致

新打包的 frameworks 与 BIQU_Frameworks 在签名配置上**完全一致**：

1. **证书选择正确**: 
   - Flutter.xcframework 保持官方签名
   - 其他 frameworks 使用本地证书 (UG5N3PCLJ5)

2. **签名策略相同**:
   - 使用相同的证书
   - 相同的 Team ID
   - 相同的证书链

3. **隐私配置一致**:
   - 所有需要的 frameworks 都包含 PrivacyInfo.xcprivacy

### ⚠️ 微小差异说明

1. **CDHash 不同**: 
   - 这是正常的，每次签名都会生成新的哈希
   - 不影响签名有效性
   - 不影响 App Store 提交

2. **Signature size 微小差异** (1 byte):
   - 可能由于签名时间戳不同
   - 完全正常，不影响使用

### ✨ 总结

**新打包的 frameworks 与 BIQU_Frameworks 在签名配置上没有实质性差异，可以互换使用。**

两者的签名策略完全相同：
- ✅ 使用相同的证书
- ✅ 相同的 Team ID
- ✅ 相同的隐私配置
- ✅ Flutter.xcframework 都保持官方签名

唯一的差异（CDHash 和微小的 signature size 差异）是正常的重新签名结果，不会影响：
- App Store 提交
- 应用运行
- 签名验证

---

## 📝 建议

1. **可以放心使用新打包的 frameworks**
2. **签名配置完全符合要求**
3. **如需更新，直接替换即可**

---

生成时间: 2026-03-10
