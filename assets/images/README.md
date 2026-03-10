# 应用图标替换说明

## 步骤1：准备图标文件
1. 将你的"彼趣"图标保存为 `app_icon.png`
2. 图标尺寸建议：1024x1024 像素
3. 格式：PNG，背景透明或纯色
4. 将文件放在 `assets/images/app_icon.png`

## 步骤2：安装依赖
```bash
flutter pub get
```

## 步骤3：生成图标
```bash
flutter pub run flutter_launcher_icons:main
```

## 步骤4：重新构建应用
```bash
flutter clean
flutter run
```

## 注意事项
- 图标应该是正方形
- 避免使用过于复杂的细节
- 确保在小尺寸下仍然清晰可见
- iOS图标会自动添加圆角，Android可以是任何形状