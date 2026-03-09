# TanyuApp Framework 集成示例代码

本目录包含完整的 Objective-C 集成示例代码，展示如何在原生 iOS 项目中使用 TanyuApp Flutter Framework。

## 文件说明

### 核心管理类

#### TanyuFlutterManager.h / .m
Flutter Engine 管理器（单例模式），负责：
- Flutter Engine 的初始化和生命周期管理
- Method Channel 的创建和通信
- Flutter ViewController 的创建
- OC 与 Flutter 之间的方法调用

**主要方法：**
```objc
// 初始化 Flutter Engine
[[TanyuFlutterManager sharedInstance] initializeFlutterEngine];

// 创建 Flutter ViewController
FlutterViewController *vc = [[TanyuFlutterManager sharedInstance] createFlutterViewController];

// 调用 Flutter 方法
[[TanyuFlutterManager sharedInstance] invokeFlutterMethod:@"methodName" 
                                                arguments:@{} 
                                                   result:^(id result) {
    // 处理返回结果
}];
```

### 示例页面

#### ExampleViewController.h / .m
完整的示例页面，展示了：
- 如何打开 Flutter 页面（Push 和 Modal）
- 如何传递参数到 Flutter
- 如何调用 Flutter 方法
- 如何处理 Flutter 返回值

### AppDelegate 示例

#### AppDelegate_Example.m
展示了在 AppDelegate 中如何：
- 初始化 Flutter Engine
- 处理 URL Scheme 和 Universal Links
- 处理推送通知
- 清理资源

## 使用步骤

### 1. 复制文件到项目

将以下文件复制到你的 Xcode 项目中：

```
TanyuFlutterManager.h
TanyuFlutterManager.m
```

### 2. 在 AppDelegate 中初始化

在 `AppDelegate.m` 中添加：

```objc
#import "TanyuFlutterManager.h"

- (BOOL)application:(UIApplication *)application 
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // 初始化 Flutter Engine
    [[TanyuFlutterManager sharedInstance] initializeFlutterEngine];
    
    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // 清理资源
    [[TanyuFlutterManager sharedInstance] cleanup];
}
```

### 3. 在任意 ViewController 中使用

```objc
#import "TanyuFlutterManager.h"

- (void)showFlutterPage {
    // 创建 Flutter ViewController
    FlutterViewController *flutterVC = 
        [[TanyuFlutterManager sharedInstance] createFlutterViewController];
    
    // 展示页面
    [self.navigationController pushViewController:flutterVC animated:YES];
}
```

## 常用场景

### 场景 1：打开指定路由的 Flutter 页面

```objc
// 打开个人中心页面
FlutterViewController *vc = [[TanyuFlutterManager sharedInstance] 
                            createFlutterViewControllerWithRoute:@"/profile"];
[self.navigationController pushViewController:vc animated:YES];
```

### 场景 2：传递用户信息到 Flutter

```objc
NSDictionary *userInfo = @{
    @"userId": @"12345",
    @"userName": @"张三",
    @"avatar": @"https://example.com/avatar.jpg"
};

[[TanyuFlutterManager sharedInstance] setUserInfo:userInfo];
```

### 场景 3：调用 Flutter 方法并获取返回值

```objc
[[TanyuFlutterManager sharedInstance] 
 invokeFlutterMethod:@"getData"
 arguments:@{@"type": @"posts"}
 result:^(id result) {
    NSLog(@"Flutter 返回: %@", result);
    // 处理返回的数据
}];
```

### 场景 4：在 Flutter 中调用 OC 方法

Flutter 端代码：

```dart
import 'package:flutter/services.dart';

// 调用原生方法
final result = await MethodChannel('com.tantan.yu/native')
    .invokeMethod('getUserInfo');
print('原生返回: $result');
```

OC 端已在 `TanyuFlutterManager.m` 中实现了处理逻辑。

## Method Channel 通信协议

### OC → Flutter

已实现的方法：

| 方法名 | 参数 | 说明 |
|--------|------|------|
| `setUserInfo` | `{userId, userName, avatar, ...}` | 设置用户信息 |
| `refreshData` | `{type, page}` | 刷新数据 |
| `handleURL` | `{url}` | 处理 URL Scheme |
| `handleUniversalLink` | `{url}` | 处理 Universal Link |
| `setDeviceToken` | `{token}` | 设置推送 Token |
| `handlePushNotification` | `{...}` | 处理推送通知 |

### Flutter → OC

已实现的方法：

| 方法名 | 参数 | 返回值 | 说明 |
|--------|------|--------|------|
| `getUserInfo` | 无 | `{userId, userName, ...}` | 获取用户信息 |
| `openNativePage` | `{page, params}` | `{success}` | 打开原生页面 |
| `showToast` | `{message}` | `{success}` | 显示 Toast |
| `closeFlutterPage` | 无 | `{success}` | 关闭 Flutter 页面 |

### 添加自定义方法

在 `TanyuFlutterManager.m` 的 `handleMethodCall:result:` 方法中添加：

```objc
- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    // ... 现有代码 ...
    
    else if ([@"yourCustomMethod" isEqualToString:call.method]) {
        // 处理自定义方法
        [self handleYourCustomMethod:call.arguments result:result];
    }
}

- (void)handleYourCustomMethod:(NSDictionary *)arguments result:(FlutterResult)result {
    // 实现你的逻辑
    result(@{@"success": @YES, @"data": @"your data"});
}
```

## 性能优化建议

### 1. 预热 Engine

在 App 启动时初始化 Flutter Engine，而不是在首次使用时：

```objc
// 在 AppDelegate 的 didFinishLaunchingWithOptions 中
[[TanyuFlutterManager sharedInstance] initializeFlutterEngine];
```

### 2. 复用 Engine

使用单例模式的 TanyuFlutterManager，确保整个 App 只有一个 Flutter Engine 实例。

### 3. 避免频繁通信

Method Channel 通信有性能开销，避免在循环或高频场景中调用。

### 4. 异步处理

所有 Method Channel 调用都是异步的，注意在回调中处理结果。

## 调试技巧

### 1. 查看日志

所有关键操作都有日志输出，前缀为 `[TanyuFlutter]`：

```
[TanyuFlutter] 开始初始化 Flutter Engine...
[TanyuFlutter] Flutter Engine 初始化成功
[TanyuFlutter] 调用 Flutter 方法: getUserInfo
```

### 2. 断点调试

在 `handleMethodCall:result:` 方法中设置断点，可以查看 Flutter 调用的所有方法。

### 3. 检查 Engine 状态

```objc
if ([TanyuFlutterManager sharedInstance].flutterEngine) {
    NSLog(@"Engine 已初始化");
} else {
    NSLog(@"Engine 未初始化");
}
```

## 常见问题

### Q1: Flutter 页面显示黑屏

**原因**：Engine 未初始化或未运行

**解决**：
```objc
// 确保在 AppDelegate 中初始化
[[TanyuFlutterManager sharedInstance] initializeFlutterEngine];
```

### Q2: Method Channel 调用无响应

**原因**：Channel 名称不匹配或 Engine 未运行

**解决**：
1. 检查 OC 和 Flutter 中的 Channel 名称是否一致
2. 确保 Engine 已经运行

### Q3: 内存泄漏

**原因**：Engine 未正确释放

**解决**：
```objc
// 在 AppDelegate 的 applicationWillTerminate 中
[[TanyuFlutterManager sharedInstance] cleanup];
```

## 完整示例项目

参考 `ExampleViewController.m` 查看完整的使用示例，包括：
- 多种打开 Flutter 页面的方式
- 参数传递
- 方法调用
- 返回值处理

## 技术支持

如有问题，请查看：
1. [FRAMEWORK_INTEGRATION.md](../FRAMEWORK_INTEGRATION.md) - 完整集成文档
2. [QUICK_START.md](../QUICK_START.md) - 快速开始指南
3. Flutter 官方文档

---

最后更新：2026-02-20
