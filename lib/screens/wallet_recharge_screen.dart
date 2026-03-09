import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../models/recharge_item.dart';
import '../widgets/coin_icon.dart';
import '../services/data_service.dart';
import '../services/in_app_purchase_service.dart';

class WalletRechargeScreen extends StatefulWidget {
  const WalletRechargeScreen({super.key});

  @override
  State<WalletRechargeScreen> createState() => _WalletRechargeScreenState();
}

class _WalletRechargeScreenState extends State<WalletRechargeScreen>
    with TickerProviderStateMixin {
  int currentCoins = 1250; // 当前金币余额
  int? selectedIndex;
  late AnimationController _pulseController;
  late AnimationController _scaleController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;
  late StreamSubscription<List<PurchaseDetails>> _purchaseSubscription;

  @override
  void initState() {
    super.initState();
    _loadCoinBalance();
    _initializeInAppPurchase();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
  }

  void _loadCoinBalance() async {
    final balance = await DataService.getCoinBalance();
    setState(() {
      currentCoins = balance;
    });
  }

  void _initializeInAppPurchase() async {
    await InAppPurchaseService.initialize();
    
    // 监听购买状态变化
    _purchaseSubscription = InAppPurchase.instance.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () => _purchaseSubscription.cancel(),
      onError: (error) => debugPrint('Purchase stream error: $error'),
    );
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.purchased) {
        // 购买成功，重新加载余额并显示成功提示
        _loadCoinBalance();
        _showSuccessMessage(purchaseDetails.productID);
        
        // 清除选择
        setState(() {
          selectedIndex = null;
        });
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        _showErrorDialog('购买失败', purchaseDetails.error?.message ?? '未知错误');
      }
    }
  }

  void _showSuccessMessage(String productId) {
    // 根据产品ID找到对应的充值档位
    RechargeItem? item;
    for (final rechargeItem in rechargeItems) {
      if (rechargeItem.id == productId) {
        item = rechargeItem;
        break;
      }
    }

    if (item != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const CoinIcon(size: 16),
              const SizedBox(width: 8),
              Text('充值成功！获得 ${item.displayCoins} 金币'),
            ],
          ),
          backgroundColor: const Color(0xFFF72E1E),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scaleController.dispose();
    _purchaseSubscription.cancel();
    super.dispose();
  }
  void _onItemTap(int index) {
    HapticFeedback.lightImpact();
    setState(() {
      selectedIndex = index;
    });
    _scaleController.forward().then((_) {
      _scaleController.reverse();
    });
  }

  void _onRecharge() async {
    if (selectedIndex == null) return;
    
    HapticFeedback.mediumImpact();
    final item = rechargeItems[selectedIndex!];
    
    // 检查内购是否可用
    if (!InAppPurchaseService.isAvailable) {
      _showErrorDialog('内购服务不可用', '请检查您的网络连接或稍后重试');
      return;
    }

    // 检查是否有待处理的购买
    if (InAppPurchaseService.isPurchasePending) {
      _showErrorDialog('购买进行中', '请等待当前购买完成');
      return;
    }

    // 显示确认对话框
    final confirmed = await _showConfirmDialog(item);
    if (!confirmed) return;

    // 发起苹果内购
    try {
      final success = await InAppPurchaseService.purchaseProduct(item.id);
      if (!success) {
        _showErrorDialog('购买失败', '无法发起购买，请稍后重试');
      }
    } catch (e) {
      _showErrorDialog('购买失败', '发生错误：$e');
    }
  }

  Future<bool> _showConfirmDialog(RechargeItem item) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('确认充值'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const CoinIcon(size: 20),
                const SizedBox(width: 8),
                Text('获得 ${item.displayCoins} 金币'),
              ],
            ),
            const SizedBox(height: 8),
            Text('支付金额：${item.displayPrice}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF72E1E),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('确认购买', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF4A4040), size: 18),
          ),
        ),
        title: const Text(
          '钱包充值',
          style: TextStyle(
            color: Color(0xFF4A4040),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                const SizedBox(height: 12),
                
                // 金币余额卡片 - 居中优化
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF72E1E), Color(0xFFFF6B6B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFF72E1E).withValues(alpha: 0.4),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // 金币图标动画
                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _pulseAnimation.value,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.25),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: CoinIcon(size: 44),
                              ),
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // 余额标签
                      Text(
                        '当前余额',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.95),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // 余额数字
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const CoinIcon(size: 24),
                          const SizedBox(width: 8),
                          Text(
                            currentCoins.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // 充值选项标题
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Text(
                        '选择充值金额',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D2D2D),
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.diamond, color: Color(0xFFF72E1E), size: 20),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // 充值选项网格 - 居中优化
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Center(
                      child: Wrap(
                        spacing: 14,
                        runSpacing: 14,
                        alignment: WrapAlignment.center,
                        children: List.generate(rechargeItems.length, (index) {
                          final item = rechargeItems[index];
                          final isSelected = selectedIndex == index;
                          
                          return AnimatedBuilder(
                            animation: _scaleAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: isSelected ? _scaleAnimation.value : 1.0,
                                child: GestureDetector(
                                  onTap: () => _onItemTap(index),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    curve: Curves.easeOutCubic,
                                    width: 105,
                                    height: 130,
                                    decoration: BoxDecoration(
                                      gradient: isSelected 
                                          ? const LinearGradient(
                                              colors: [Color(0xFFFFF5F5), Color(0xFFFFE5E5)],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            )
                                          : null,
                                      color: isSelected ? null : Colors.white,
                                      borderRadius: BorderRadius.circular(22),
                                      border: Border.all(
                                        color: isSelected 
                                            ? const Color(0xFFF72E1E)
                                            : const Color(0xFFE8E8E8),
                                        width: isSelected ? 2.5 : 1.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: isSelected 
                                              ? const Color(0xFFF72E1E).withValues(alpha: 0.25)
                                              : Colors.black.withValues(alpha: 0.06),
                                          blurRadius: isSelected ? 18 : 10,
                                          offset: Offset(0, isSelected ? 6 : 3),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        // 金币图标和数量
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            CoinIcon(
                                              size: 20,
                                              isSelected: isSelected,
                                            ),
                                            const SizedBox(width: 4),
                                            Flexible(
                                              child: Text(
                                                item.displayCoins,
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                  color: isSelected 
                                                      ? const Color(0xFFF72E1E)
                                                      : const Color(0xFF4A4040),
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        
                                        const SizedBox(height: 12),
                                        
                                        // 价格
                                        Text(
                                          item.displayPrice,
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: isSelected 
                                                ? const Color(0xFFF72E1E)
                                                : const Color(0xFF2D2D2D),
                                          ),
                                        ),
                                        
                                        const SizedBox(height: 6),
                                        
                                        // 性价比标签
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: isSelected 
                                                ? const Color(0xFFF72E1E).withValues(alpha: 0.15)
                                                : const Color(0xFFF5F5F5),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            '${(item.coins / item.price).toStringAsFixed(0)}币/元',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: isSelected 
                                                  ? const Color(0xFFF72E1E)
                                                  : const Color(0xFF999999),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }),
                      ),
                    ),
                  ),
                ),
                
                // 充值按钮 - 优化样式
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed: selectedIndex != null ? _onRecharge : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedIndex != null 
                            ? const Color(0xFFF72E1E)
                            : const Color(0xFFE8E8E8),
                        foregroundColor: Colors.white,
                        elevation: selectedIndex != null ? 10 : 0,
                        shadowColor: const Color(0xFFF72E1E).withValues(alpha: 0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(29),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (selectedIndex != null) ...[
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.payment, size: 18),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '立即充值 ${rechargeItems[selectedIndex!].displayPrice}',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ] else ...[
                            Icon(Icons.touch_app, size: 20, color: Colors.grey[500]),
                            const SizedBox(width: 8),
                            Text(
                              '请选择充值金额',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}