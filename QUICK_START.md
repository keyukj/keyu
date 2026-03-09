# TanyuApp Framework 快速开始

## 5 分钟快速集成指南

### 步骤 1：打包 Framework（2 分钟）

```bash
# 给脚本添加执行权限
chmod +x build_framework.sh

# 执行打包
./build_framework.sh
```

等待打包完成，会在 `build/frameworks/Release/` 生成所有需要的 frameworks。

### 步骤 2：添加到 Xcode 项目（1 分钟）

1. 打开你的 Xcode 项目
2. 将 `build/frameworks/Release/` 下的所有 `.xcframework` 文件拖入项目
3. 在 Target → General → Frameworks, Libraries, and Embedded Content 中，将所有 frameworks 设置为 **"Embed & Sign"**

### 步骤 3：配置 Build Settings（30 秒）

在 Target → Build Settings 中搜索并设置：

- **Other Linker Flags**: 添加 `-ObjC`
- **Enable Bitcode**: 设置为 `NO`

### 步骤 4：初始化 Flutter Engine（1 分钟）

在 `AppDelegate.h` 中：

```objc
#import <Flutter/Flutter.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) FlutterEngine *flutterEngine;
@end
```

在 `AppDelegate.m` 中：

```objc
#import <Flutter/Flutter.h>

- (BOOL)application:(UIApplication *)application 
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // 初始化 Flutter Engine
    self.flutterEngine = [[FlutterEngine alloc] initWithName:@"tanyu_engine"];
    [self.flutterEngine runWithEntrypoint:nil];
    
    return YES;
}
```

### 步骤 5：展示 Flutter 页面（30 秒）

在任何 ViewController 中：

```objc
#import <Flutter/Flutter.h>

- (void)showFlutterPage {
    // 获取 Engine
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // 创建 Flutter VC
    FlutterViewController *flutterVC = 
        [[FlutterViewController alloc] initWithEngine:appDelegate.flutterEngine 
                                              nibName:nil 
                                               bundle:nil];
    
    // 展示页面
    [self.navigationController pushViewController:flutterVC animated:YES];
}
```

### 完成！🎉

现在你可以运行项目，调用 `showFlutterPage` 方法就能看到 Flutter 页面了。

---

## 使用 CocoaPods 集成（可选）

如果你的项目使用 CocoaPods，可以更简单：

### 1. 在 Podfile 中添加：

```ruby
pod 'TanyuApp', :path => './path/to/tanyu_app'
```

### 2. 安装：

```bash
pod install
```

### 3. 使用（同上面的步骤 4-5）

---

## 常见问题速查

### ❌ 编译错误：framework not found

**解决**：检查 Build Settings → Framework Search Paths，确保包含 frameworks 目录

### ❌ 运行时崩溃：dyld: Library not loaded

**解决**：确保所有 frameworks 的 Embed 选项设置为 "Embed & Sign"

### ❌ Flutter 页面黑屏

**解决**：确保 Flutter Engine 已经调用 `runWithEntrypoint:nil`

### ❌ 找不到 Flutter.h

**解决**：Clean Build Folder (Cmd + Shift + K)，然后重新编译

---

## 下一步

- 📖 查看完整文档：[FRAMEWORK_INTEGRATION.md](./FRAMEWORK_INTEGRATION.md)
- 🔧 配置 OC 与 Flutter 通信
- 🔐 配置签名和隐私权限
- 📱 准备提交 App Store

---

## 需要帮助？

1. 查看 [FRAMEWORK_INTEGRATION.md](./FRAMEWORK_INTEGRATION.md) 完整文档
2. 查看 `build/frameworks/INTEGRATION_GUIDE.md`
3. 联系开发团队

---

**提示**：首次集成建议完整阅读 [FRAMEWORK_INTEGRATION.md](./FRAMEWORK_INTEGRATION.md)，了解所有配置细节和最佳实践。
