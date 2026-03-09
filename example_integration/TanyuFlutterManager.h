//
//  TanyuFlutterManager.h
//  示例：Flutter Engine 管理器
//
//  用于管理 Flutter Engine 的生命周期和通信
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN

/// Flutter Engine 管理器（单例）
@interface TanyuFlutterManager : NSObject

/// 单例实例
+ (instancetype)sharedInstance;

/// Flutter Engine
@property (nonatomic, strong, readonly) FlutterEngine *flutterEngine;

/// Method Channel
@property (nonatomic, strong, readonly) FlutterMethodChannel *methodChannel;

/// 初始化 Flutter Engine
- (void)initializeFlutterEngine;

/// 创建 Flutter View Controller
- (FlutterViewController *)createFlutterViewController;

/// 创建带初始路由的 Flutter View Controller
/// @param route 初始路由，例如 "/home", "/profile"
- (FlutterViewController *)createFlutterViewControllerWithRoute:(NSString *)route;

/// 调用 Flutter 方法
/// @param method 方法名
/// @param arguments 参数
/// @param callback 回调
- (void)invokeFlutterMethod:(NSString *)method
                  arguments:(nullable id)arguments
                     result:(nullable FlutterResult)callback;

/// 设置用户信息到 Flutter
/// @param userInfo 用户信息字典
- (void)setUserInfo:(NSDictionary *)userInfo;

/// 清理资源
- (void)cleanup;

@end

NS_ASSUME_NONNULL_END
