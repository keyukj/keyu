//
//  TanyuFlutterManager.m
//  示例：Flutter Engine 管理器实现
//

#import "TanyuFlutterManager.h"

// Method Channel 名称
static NSString *const kMethodChannelName = @"com.tantan.yu/native";

@interface TanyuFlutterManager ()

@property (nonatomic, strong, readwrite) FlutterEngine *flutterEngine;
@property (nonatomic, strong, readwrite) FlutterMethodChannel *methodChannel;

@end

@implementation TanyuFlutterManager

#pragma mark - Singleton

+ (instancetype)sharedInstance {
    static TanyuFlutterManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        // 在初始化时不立即创建 Engine，等待显式调用
    }
    return self;
}

#pragma mark - Public Methods

- (void)initializeFlutterEngine {
    if (self.flutterEngine) {
        NSLog(@"[TanyuFlutter] Engine 已经初始化");
        return;
    }
    
    NSLog(@"[TanyuFlutter] 开始初始化 Flutter Engine...");
    
    // 创建 Flutter Engine
    self.flutterEngine = [[FlutterEngine alloc] initWithName:@"tanyu_engine"];
    
    // 运行 Engine
    BOOL success = [self.flutterEngine runWithEntrypoint:nil];
    if (success) {
        NSLog(@"[TanyuFlutter] Flutter Engine 初始化成功");
        
        // 设置 Method Channel
        [self setupMethodChannel];
    } else {
        NSLog(@"[TanyuFlutter] Flutter Engine 初始化失败");
    }
}

- (FlutterViewController *)createFlutterViewController {
    return [self createFlutterViewControllerWithRoute:@"/"];
}

- (FlutterViewController *)createFlutterViewControllerWithRoute:(NSString *)route {
    if (!self.flutterEngine) {
        NSLog(@"[TanyuFlutter] 警告：Engine 未初始化，正在初始化...");
        [self initializeFlutterEngine];
    }
    
    FlutterViewController *flutterVC = [[FlutterViewController alloc]
                                        initWithEngine:self.flutterEngine
                                        nibName:nil
                                        bundle:nil];
    
    // 设置初始路由
    if (route && ![route isEqualToString:@"/"]) {
        [flutterVC setInitialRoute:route];
    }
    
    NSLog(@"[TanyuFlutter] 创建 Flutter ViewController，路由: %@", route);
    
    return flutterVC;
}

- (void)invokeFlutterMethod:(NSString *)method
                  arguments:(nullable id)arguments
                     result:(nullable FlutterResult)callback {
    if (!self.methodChannel) {
        NSLog(@"[TanyuFlutter] 错误：Method Channel 未初始化");
        if (callback) {
            callback([FlutterError errorWithCode:@"CHANNEL_ERROR"
                                         message:@"Method Channel not initialized"
                                         details:nil]);
        }
        return;
    }
    
    NSLog(@"[TanyuFlutter] 调用 Flutter 方法: %@, 参数: %@", method, arguments);
    
    [self.methodChannel invokeMethod:method arguments:arguments result:^(id result) {
        NSLog(@"[TanyuFlutter] Flutter 返回: %@", result);
        if (callback) {
            callback(result);
        }
    }];
}

- (void)setUserInfo:(NSDictionary *)userInfo {
    [self invokeFlutterMethod:@"setUserInfo" arguments:userInfo result:^(id result) {
        NSLog(@"[TanyuFlutter] 用户信息已设置");
    }];
}

- (void)cleanup {
    NSLog(@"[TanyuFlutter] 清理资源...");
    
    if (self.flutterEngine) {
        [self.flutterEngine destroyContext];
        self.flutterEngine = nil;
    }
    
    self.methodChannel = nil;
}

#pragma mark - Private Methods

- (void)setupMethodChannel {
    // 创建 Method Channel
    self.methodChannel = [FlutterMethodChannel
                          methodChannelWithName:kMethodChannelName
                          binaryMessenger:self.flutterEngine.binaryMessenger];
    
    // 设置方法调用处理器
    __weak typeof(self) weakSelf = self;
    [self.methodChannel setMethodCallHandler:^(FlutterMethodCall *call, FlutterResult result) {
        [weakSelf handleMethodCall:call result:result];
    }];
    
    NSLog(@"[TanyuFlutter] Method Channel 已设置: %@", kMethodChannelName);
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSLog(@"[TanyuFlutter] 收到 Flutter 调用: %@, 参数: %@", call.method, call.arguments);
    
    if ([@"getUserInfo" isEqualToString:call.method]) {
        // 返回用户信息
        [self handleGetUserInfo:result];
        
    } else if ([@"openNativePage" isEqualToString:call.method]) {
        // 打开原生页面
        [self handleOpenNativePage:call.arguments result:result];
        
    } else if ([@"showToast" isEqualToString:call.method]) {
        // 显示 Toast
        [self handleShowToast:call.arguments result:result];
        
    } else if ([@"closeFlutterPage" isEqualToString:call.method]) {
        // 关闭 Flutter 页面
        [self handleCloseFlutterPage:result];
        
    } else {
        NSLog(@"[TanyuFlutter] 未实现的方法: %@", call.method);
        result(FlutterMethodNotImplemented);
    }
}

#pragma mark - Method Handlers

- (void)handleGetUserInfo:(FlutterResult)result {
    // 这里应该从你的用户管理系统获取真实数据
    // 示例数据：
    NSDictionary *userInfo = @{
        @"userId": @"12345",
        @"userName": @"张三",
        @"avatar": @"https://example.com/avatar.jpg",
        @"email": @"zhangsan@example.com",
        @"phone": @"13800138000"
    };
    
    result(userInfo);
}

- (void)handleOpenNativePage:(NSDictionary *)arguments result:(FlutterResult)result {
    NSString *pageName = arguments[@"page"];
    NSDictionary *params = arguments[@"params"];
    
    NSLog(@"[TanyuFlutter] 打开原生页面: %@, 参数: %@", pageName, params);
    
    // 在主线程执行 UI 操作
    dispatch_async(dispatch_get_main_queue(), ^{
        // 这里实现你的页面跳转逻辑
        // 例如：
        // if ([pageName isEqualToString:@"profile"]) {
        //     ProfileViewController *vc = [[ProfileViewController alloc] init];
        //     // 设置参数
        //     // 跳转
        // }
        
        result(@{@"success": @YES});
    });
}

- (void)handleShowToast:(NSDictionary *)arguments result:(FlutterResult)result {
    NSString *message = arguments[@"message"];
    
    NSLog(@"[TanyuFlutter] 显示 Toast: %@", message);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // 这里实现你的 Toast 显示逻辑
        // 例如使用 MBProgressHUD 或其他 Toast 库
        
        result(@{@"success": @YES});
    });
}

- (void)handleCloseFlutterPage:(FlutterResult)result {
    NSLog(@"[TanyuFlutter] 关闭 Flutter 页面");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // 获取当前显示的 Flutter ViewController 并关闭
        UIViewController *topVC = [self topViewController];
        if ([topVC isKindOfClass:[FlutterViewController class]]) {
            if (topVC.navigationController) {
                [topVC.navigationController popViewControllerAnimated:YES];
            } else {
                [topVC dismissViewControllerAnimated:YES completion:nil];
            }
        }
        
        result(@{@"success": @YES});
    });
}

#pragma mark - Helper Methods

- (UIViewController *)topViewController {
    UIViewController *topVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
    }
    
    if ([topVC isKindOfClass:[UINavigationController class]]) {
        topVC = [(UINavigationController *)topVC topViewController];
    }
    
    if ([topVC isKindOfClass:[UITabBarController class]]) {
        topVC = [(UITabBarController *)topVC selectedViewController];
        
        if ([topVC isKindOfClass:[UINavigationController class]]) {
            topVC = [(UINavigationController *)topVC topViewController];
        }
    }
    
    return topVC;
}

#pragma mark - Dealloc

- (void)dealloc {
    [self cleanup];
}

@end
