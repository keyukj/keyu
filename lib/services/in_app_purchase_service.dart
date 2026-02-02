import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../models/recharge_item.dart';
import 'data_service.dart';

class InAppPurchaseService {
  static final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  static late StreamSubscription<List<PurchaseDetails>> _subscription;
  static bool _isAvailable = false;
  static List<ProductDetails> _products = [];
  static bool _purchasePending = false;

  // 初始化内购服务
  static Future<void> initialize() async {
    debugPrint('=== 开始初始化内购服务 ===');
    
    // 检查运行环境
    debugPrint('运行环境检查:');
    debugPrint('  - 平台: ${Platform.operatingSystem}');
    debugPrint('  - 调试模式: $kDebugMode');
    if (Platform.isIOS) {
      debugPrint('  - iOS平台检测到');
    }
    
    try {
      _isAvailable = await _inAppPurchase.isAvailable();
      debugPrint('内购服务可用性: $_isAvailable');
      
      if (!_isAvailable) {
        debugPrint('❌ 内购服务不可用 - 可能原因:');
        if (Platform.isIOS && kDebugMode) {
          debugPrint('  1. 运行在iOS模拟器上（模拟器不支持内购）');
          debugPrint('  2. 需要在真实iOS设备上测试');
        }
        debugPrint('  3. 设备不支持内购');
        debugPrint('  4. 网络连接问题');
        debugPrint('  5. App Store服务不可用');
        debugPrint('');
        debugPrint('🔧 解决方案:');
        debugPrint('  - 在真实iOS设备上运行: flutter run -d [设备ID]');
        debugPrint('  - 设置沙盒测试账号');
        debugPrint('  - 确保App Store Connect中已配置产品');
        return;
      }

      debugPrint('✅ 内购服务可用，开始监听购买流');
      
      // 监听购买状态变化
      _subscription = _inAppPurchase.purchaseStream.listen(
        _onPurchaseUpdate,
        onDone: () {
          debugPrint('购买流监听结束');
          _subscription.cancel();
        },
        onError: (error) {
          debugPrint('❌ 购买流错误: $error');
        },
      );

      // 加载产品信息
      debugPrint('开始加载产品信息...');
      await _loadProducts();
      debugPrint('=== 内购服务初始化完成 ===');
      
    } catch (e) {
      debugPrint('❌ 初始化内购服务失败: $e');
    }
  }

  // 加载产品信息
  static Future<void> _loadProducts() async {
    final Set<String> productIds = rechargeItems.map((item) => item.id).toSet();
    
    debugPrint('=== 开始查询产品信息 ===');
    
    // Bundle ID 信息 (从Info.plist获取)
    debugPrint('预期Bundle ID: com.tantan.yu (来自Info.plist)');
    
    debugPrint('请求的产品ID列表: $productIds');
    debugPrint('产品数量: ${productIds.length}');
    
    try {
      debugPrint('🔄 向App Store发送产品查询请求...');
      final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(productIds);
      
      debugPrint('=== 收到App Store响应 ===');
      debugPrint('✅ 找到的产品数量: ${response.productDetails.length}');
      debugPrint('❌ 未找到的产品数量: ${response.notFoundIDs.length}');
      
      if (response.error != null) {
        debugPrint('❌ 查询错误: ${response.error}');
        debugPrint('错误代码: ${response.error?.code}');
        debugPrint('错误描述: ${response.error?.message}');
        debugPrint('错误详情: ${response.error?.details}');
      } else {
        debugPrint('✅ 查询成功，无错误');
      }
      
      if (response.notFoundIDs.isNotEmpty) {
        debugPrint('❌ 未找到的产品ID:');
        for (final id in response.notFoundIDs) {
          debugPrint('  - $id');
        }
        debugPrint('');
        debugPrint('可能的原因:');
        debugPrint('  1. App Store Connect中未创建这些产品');
        debugPrint('  2. 产品状态不是"准备提交"');
        debugPrint('  3. Bundle ID不匹配 (期望: com.tantan.yu)');
        debugPrint('  4. 产品审核未通过');
        debugPrint('  5. 开发者账号权限问题');
      }
      
      _products = response.productDetails;
      debugPrint('📦 成功加载 ${_products.length} 个产品');
      
      if (_products.isNotEmpty) {
        debugPrint('=== 产品详情 ===');
        for (final product in _products) {
          debugPrint('产品ID: ${product.id}');
          debugPrint('  标题: ${product.title}');
          debugPrint('  描述: ${product.description}');
          debugPrint('  价格: ${product.price}');
          debugPrint('  货币代码: ${product.currencyCode}');
          debugPrint('  原始价格: ${product.rawPrice}');
          debugPrint('---');
        }
      } else {
        debugPrint('⚠️ 没有加载到任何产品');
        debugPrint('');
        debugPrint('🔧 解决步骤:');
        debugPrint('  1. 登录 App Store Connect');
        debugPrint('  2. 创建应用 (Bundle ID: com.tantan.yu)');
        debugPrint('  3. 添加内购产品:');
        for (final id in productIds) {
          debugPrint('     - $id');
        }
        debugPrint('  4. 设置产品状态为"准备提交"');
        debugPrint('  5. 在真机上测试');
      }
      
      debugPrint('=== 产品查询完成 ===');
      
    } catch (e, stackTrace) {
      debugPrint('❌ 查询产品时发生异常: $e');
      debugPrint('堆栈跟踪: $stackTrace');
    }
  }

  // 处理购买状态更新
  static void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      _handlePurchase(purchaseDetails);
    }
  }

  // 处理单个购买
  static Future<void> _handlePurchase(PurchaseDetails purchaseDetails) async {
    if (purchaseDetails.status == PurchaseStatus.pending) {
      _purchasePending = true;
    } else {
      if (purchaseDetails.status == PurchaseStatus.error) {
        debugPrint('Purchase error: ${purchaseDetails.error}');
        _purchasePending = false;
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
                 purchaseDetails.status == PurchaseStatus.restored) {
        
        // 验证购买并发放金币
        await _deliverProduct(purchaseDetails);
        _purchasePending = false;
      }

      if (purchaseDetails.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchaseDetails);
      }
    }
  }

  // 发放产品（金币）
  static Future<void> _deliverProduct(PurchaseDetails purchaseDetails) async {
    try {
      // 根据产品ID找到对应的充值档位
      RechargeItem? rechargeItem;
      for (final item in rechargeItems) {
        if (item.id == purchaseDetails.productID) {
          rechargeItem = item;
          break;
        }
      }

      if (rechargeItem != null) {
        // 发放金币
        await DataService.addCoins(rechargeItem.coins);
        debugPrint('Delivered ${rechargeItem.coins} coins for ${purchaseDetails.productID}');
      }
    } catch (e) {
      debugPrint('Error delivering product: $e');
    }
  }

  // 发起购买
  static Future<bool> purchaseProduct(String productId) async {
    debugPrint('=== 开始购买流程 ===');
    debugPrint('产品ID: $productId');
    
    if (!_isAvailable) {
      debugPrint('❌ 内购服务不可用');
      return false;
    }

    try {
      ProductDetails? productDetails;
      for (final product in _products) {
        if (product.id == productId) {
          productDetails = product;
          break;
        }
      }

      if (productDetails == null) {
        debugPrint('❌ 产品未找到: $productId');
        return false;
      }

      debugPrint('✅ 找到产品，发起购买请求');
      final PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails);
      await _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
      return true;
    } catch (e) {
      debugPrint('❌ 购买过程中发生错误: $e');
      return false;
    }
  }

  // 恢复购买
  static Future<void> restorePurchases() async {
    if (!_isAvailable) return;
    
    try {
      await _inAppPurchase.restorePurchases();
    } catch (e) {
      debugPrint('Error restoring purchases: $e');
    }
  }

  // 获取产品详情
  static ProductDetails? getProductDetails(String productId) {
    for (final product in _products) {
      if (product.id == productId) {
        return product;
      }
    }
    return null;
  }

  // 检查是否有待处理的购买
  static bool get isPurchasePending => _purchasePending;

  // 检查内购是否可用
  static bool get isAvailable => _isAvailable;

  // 获取所有产品
  static List<ProductDetails> get products => _products;

  // 清理资源
  static void dispose() {
    _subscription.cancel();
  }
}