# 登录页 Logo 更换指南

## 📍 Logo 位置

登录页的 Logo 图片位于：
```
assets/logo.png
```

## 🖼️ 当前图片信息

- **文件路径**: `assets/logo.png`
- **文件大小**: 82KB
- **图片尺寸**: 1164 x 1164 像素
- **格式**: PNG
- **使用位置**: 登录页面（`lib/screens/login_screen.dart`）

## 🔄 如何更换 Logo

### 方法一：直接替换（推荐）

1. **准备新的 Logo 图片**
   - 建议尺寸：1024x1024 或更大（正方形）
   - 格式：PNG（支持透明背景）
   - 文件名：任意

2. **替换文件**
   ```bash
   # 备份原图片（可选）
   cp assets/logo.png assets/logo_old.png
   
   # 复制新图片并重命名为 logo.png
   cp /path/to/your/new_logo.png assets/logo.png
   ```

3. **验证**
   ```bash
   # 检查文件是否存在
   ls -lh assets/logo.png
   
   # 查看图片信息
   file assets/logo.png
   ```

4. **重新运行应用**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

### 方法二：使用不同的文件名

如果你想使用不同的文件名（例如 `brand_logo.png`）：

1. **添加新图片到 assets 目录**
   ```bash
   cp /path/to/your/new_logo.png assets/brand_logo.png
   ```

2. **更新 pubspec.yaml**
   
   确保 `pubspec.yaml` 中包含：
   ```yaml
   flutter:
     assets:
       - assets/
       - assets/images/
       - assets/img/
       - assets/logo.png
       - assets/brand_logo.png  # 添加新图片
   ```

3. **更新登录页代码**
   
   编辑 `lib/screens/login_screen.dart`，找到：
   ```dart
   Image.asset(
     'assets/logo.png',
     width: 120,
     height: 120,
     fit: BoxFit.cover,
   ),
   ```
   
   改为：
   ```dart
   Image.asset(
     'assets/brand_logo.png',  // 使用新文件名
     width: 120,
     height: 120,
     fit: BoxFit.cover,
   ),
   ```

4. **重新运行**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

## 🎨 Logo 设计建议

### 尺寸要求
- **推荐尺寸**: 1024x1024 像素（正方形）
- **最小尺寸**: 512x512 像素
- **显示尺寸**: 120x120 点（在代码中定义）

### 格式要求
- **格式**: PNG（推荐）或 JPG
- **透明背景**: 推荐使用 PNG 格式支持透明背景
- **颜色模式**: RGB

### 设计建议
- 简洁明了，易于识别
- 在小尺寸下仍然清晰可见
- 与应用主题色（红色 #F72E1E）协调
- 圆角设计（代码中已设置 24px 圆角）

## 📱 Logo 在应用中的显示效果

登录页 Logo 的显示特性：
- **尺寸**: 120x120 点
- **圆角**: 24px
- **阴影**: 红色阴影效果
- **背景**: 浅粉色背景（#FFF0F0）

## 🔍 相关文件

### 登录页代码
```
lib/screens/login_screen.dart
```

### 资源配置
```
pubspec.yaml
```

### Logo 文件
```
assets/logo.png          # 登录页 Logo
assets/images/app_icon.png  # 应用图标（不同用途）
```

## ⚠️ 注意事项

1. **不要混淆**
   - `assets/logo.png` - 登录页显示的 Logo
   - `assets/images/app_icon.png` - 应用图标（用于生成各平台图标）

2. **文件大小**
   - 建议控制在 200KB 以内
   - 过大的图片会影响应用启动速度

3. **缓存问题**
   - 如果更换后看不到新图片，运行 `flutter clean`
   - 在模拟器/真机上完全卸载应用后重新安装

4. **版本控制**
   - 建议备份原图片
   - 在 Git 中提交新图片

## 🚀 快速更换命令

```bash
# 1. 备份原图片
cp assets/logo.png assets/logo_backup.png

# 2. 复制新图片（替换下面的路径）
cp ~/Downloads/new_logo.png assets/logo.png

# 3. 清理并重新构建
flutter clean && flutter pub get

# 4. 运行应用查看效果
flutter run
```

## 📸 预览效果

更换后，新 Logo 将显示在：
- ✅ 登录页面中央
- ✅ 120x120 点的圆角容器中
- ✅ 带有红色阴影效果
- ✅ 下方显示"彼趣"文字

---

**更新日期**: 2026-02-22  
**相关文件**: `assets/logo.png`, `lib/screens/login_screen.dart`
