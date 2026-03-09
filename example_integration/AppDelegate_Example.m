//
//  AppDelegate_Example.m
//  示例：AppDelegate 中如何初始化 Flutter
//
//  将此代码集成到你的 AppDelegate.m 中
//

#import "AppDelegate.h"
#import "TanyuFlutterManager.h"
#import <Flutter/Flutter.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application 
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // ========================================
    // Flutter 初始化（推荐在启动时初始化，提高首次打开速度）
    // ========================================
    
    NSLog(@"[App] 开始初始化 Flutter Engine...");
    
    // 初始化 Flutter Engine
    [[TanyuFlutterManager sharedInstance] initializeFlutterEngine];
    
    NSLog(@"[App] Flutter Engine 初始化完成");
    
    // ========================================
    // 你的其他初始化代码
    // ========================================
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // 应用即将进入后台
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // 应用已进入后台
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // 应用即将进入前台
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // 应用已激活
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // 应用即将终止，清理 Flutter 资源
    NSLog(@"[App] 清理 Flutter 资源...");
    [[TanyuFlutterManager sharedInstance] cleanup];
}

#pragma mark - URL Handling (可选)

/// 处理 URL Scheme
- (BOOL)application:(UIApplication *)app 
            openURL:(NSURL *)url 
            options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    
    // 如果需要将 URL 传递给 Flutter
    if ([url.scheme isEqualToString:@"tanyu"]) {
        [[TanyuFlutterManager sharedInstance] 
         invokeFlutterMethod:@"handleURL" 
         arguments:@{@"url": url.absoluteString}
         result:nil];
        return YES;
    }
    
    return NO;
}

/// 处理 Universal Links
- (BOOL)application:(UIApplication *)application 
    continueUserActivity:(NSUserActivity *)userActivity 
      restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler {
    
    if ([userActivity.activityType isEqualToString:NSUserActivityTypeBrowsingWeb]) {
        NSURL *url = userActivity.webpageURL;
        
        // 传递给 Flutter
        [[TanyuFlutterManager sharedInstance] 
         invokeFlutterMethod:@"handleUniversalLink" 
         arguments:@{@"url": url.absoluteString}
         result:nil];
        
        return YES;
    }
    
    return NO;
}

#pragma mark - Push Notifications (可选)

/// 注册推送通知
- (void)application:(UIApplication *)application 
    didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    // 将 Device Token 转换为字符串
    NSString *token = [self stringFromDeviceToken:deviceToken];
    NSLog(@"[App] Device Token: %@", token);
    
    // 传递给 Flutter
    [[TanyuFlutterManager sharedInstance] 
     invokeFlutterMethod:@"setDeviceToken" 
     arguments:@{@"token": token}
     result:nil];
}

/// 接收推送通知
- (void)application:(UIApplication *)application 
    didReceiveRemoteNotification:(NSDictionary *)userInfo 
          fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    NSLog(@"[App] 收到推送通知: %@", userInfo);
    
    // 传递给 Flutter
    [[TanyuFlutterManager sharedInstance] 
     invokeFlutterMethod:@"handlePushNotification" 
     arguments:userInfo
     result:^(id result) {
        completionHandler(UIBackgroundFetchResultNewData);
    }];
}

#pragma mark - Helper Methods

- (NSString *)stringFromDeviceToken:(NSData *)deviceToken {
    NSMutableString *token = [NSMutableString string];
    const unsigned char *bytes = [deviceToken bytes];
    for (NSInteger i = 0; i < deviceToken.length; i++) {
        [token appendFormat:@"%02x", bytes[i]];
    }
    return [token copy];
}

@end
