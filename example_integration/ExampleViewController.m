//
//  ExampleViewController.m
//  示例：如何在 OC 项目中使用 TanyuApp Flutter Framework
//

#import "ExampleViewController.h"
#import "TanyuFlutterManager.h"
#import <Flutter/Flutter.h>

@interface ExampleViewController ()

@end

@implementation ExampleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Flutter 集成示例";
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 创建示例按钮
    [self setupButtons];
}

- (void)setupButtons {
    CGFloat buttonWidth = 280;
    CGFloat buttonHeight = 50;
    CGFloat spacing = 20;
    CGFloat startY = 100;
    
    // 按钮配置
    NSArray *buttonConfigs = @[
        @{@"title": @"打开 Flutter 首页", @"action": @"openFlutterHome"},
        @{@"title": @"打开 Flutter 个人中心", @"action": @"openFlutterProfile"},
        @{@"title": @"传递用户信息到 Flutter", @"action": @"sendUserInfo"},
        @{@"title": @"调用 Flutter 方法", @"action": @"callFlutterMethod"},
        @{@"title": @"Modal 展示 Flutter", @"action": @"presentFlutter"}
    ];
    
    for (NSInteger i = 0; i < buttonConfigs.count; i++) {
        NSDictionary *config = buttonConfigs[i];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.frame = CGRectMake((self.view.bounds.size.width - buttonWidth) / 2,
                                 startY + i * (buttonHeight + spacing),
                                 buttonWidth,
                                 buttonHeight);
        button.backgroundColor = [UIColor colorWithRed:0.2 green:0.6 blue:1.0 alpha:1.0];
        [button setTitle:config[@"title"] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        button.layer.cornerRadius = 8;
        
        SEL action = NSSelectorFromString([NSString stringWithFormat:@"%@:", config[@"action"]]);
        [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:button];
    }
}

#pragma mark - Button Actions

/// 打开 Flutter 首页
- (void)openFlutterHome:(UIButton *)sender {
    NSLog(@"打开 Flutter 首页");
    
    // 创建 Flutter ViewController
    FlutterViewController *flutterVC = [[TanyuFlutterManager sharedInstance] 
                                        createFlutterViewControllerWithRoute:@"/"];
    
    // Push 展示
    [self.navigationController pushViewController:flutterVC animated:YES];
}

/// 打开 Flutter 个人中心
- (void)openFlutterProfile:(UIButton *)sender {
    NSLog(@"打开 Flutter 个人中心");
    
    // 创建带路由的 Flutter ViewController
    FlutterViewController *flutterVC = [[TanyuFlutterManager sharedInstance] 
                                        createFlutterViewControllerWithRoute:@"/profile"];
    
    [self.navigationController pushViewController:flutterVC animated:YES];
}

/// 传递用户信息到 Flutter
- (void)sendUserInfo:(UIButton *)sender {
    NSLog(@"传递用户信息到 Flutter");
    
    // 准备用户信息
    NSDictionary *userInfo = @{
        @"userId": @"12345",
        @"userName": @"张三",
        @"avatar": @"https://example.com/avatar.jpg",
        @"email": @"zhangsan@example.com",
        @"vipLevel": @2,
        @"coins": @1000
    };
    
    // 发送到 Flutter
    [[TanyuFlutterManager sharedInstance] setUserInfo:userInfo];
    
    // 显示提示
    [self showAlert:@"用户信息已发送到 Flutter"];
}

/// 调用 Flutter 方法
- (void)callFlutterMethod:(UIButton *)sender {
    NSLog(@"调用 Flutter 方法");
    
    // 调用 Flutter 的自定义方法
    [[TanyuFlutterManager sharedInstance] 
     invokeFlutterMethod:@"refreshData"
     arguments:@{@"type": @"posts", @"page": @1}
     result:^(id result) {
        NSLog(@"Flutter 返回结果: %@", result);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *message = [NSString stringWithFormat:@"Flutter 返回: %@", result];
            [self showAlert:message];
        });
    }];
}

/// Modal 展示 Flutter
- (void)presentFlutter:(UIButton *)sender {
    NSLog(@"Modal 展示 Flutter");
    
    // 创建 Flutter ViewController
    FlutterViewController *flutterVC = [[TanyuFlutterManager sharedInstance] 
                                        createFlutterViewController];
    
    // 设置 Modal 样式
    flutterVC.modalPresentationStyle = UIModalPresentationFullScreen;
    
    // 添加关闭按钮
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] 
                                    initWithTitle:@"关闭"
                                    style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(dismissFlutter)];
    flutterVC.navigationItem.leftBarButtonItem = closeButton;
    
    // 包装在 NavigationController 中
    UINavigationController *navController = [[UINavigationController alloc] 
                                            initWithRootViewController:flutterVC];
    
    // Modal 展示
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)dismissFlutter {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Helper Methods

- (void)showAlert:(NSString *)message {
    UIAlertController *alert = [UIAlertController 
                               alertControllerWithTitle:@"提示"
                               message:message
                               preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" 
                                             style:UIAlertActionStyleDefault 
                                           handler:nil]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end
