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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF4A4040)),
        ),
        title: const Text(
          '钱包充值',
          style: TextStyle(
            color: Color(0xFF4A4040),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 金币余额卡片
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF72E1E), Color(0xFFFF7E7E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF72E1E).withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Center(
                            child: CoinIcon(size: 32),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '当前余额',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const CoinIcon(size: 20),
                            const SizedBox(width: 4),
                            Text(
                              currentCoins.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // 充值选项标题
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '充值金额',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A4040),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 充值选项网格
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: rechargeItems.length,
                  itemBuilder: (context, index) {
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
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOut,
                              decoration: BoxDecoration(
                                color: isSelected 
                                    ? const Color(0xFFF72E1E).withValues(alpha: 0.1)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected 
                                      ? const Color(0xFFF72E1E)
                                      : const Color(0xFFE5E5E5),
                                  width: isSelected ? 2 : 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: isSelected 
                                        ? const Color(0xFFF72E1E).withValues(alpha: 0.2)
                                        : Colors.black.withValues(alpha: 0.05),
                                    blurRadius: isSelected ? 15 : 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  // 主要内容
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        // 金币图标和数量
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            CoinIcon(
                                              size: 18,
                                              isSelected: isSelected,
                                            ),
                                            const SizedBox(width: 2),
                                            Flexible(
                                              child: Text(
                                                item.displayCoins,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: isSelected 
                                                      ? const Color(0xFFF72E1E)
                                                      : const Color(0xFF4A4040),
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        
                                        const SizedBox(height: 8),
                                        
                                        // 价格
                                        Text(
                                          item.displayPrice,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: isSelected 
                                                ? const Color(0xFFF72E1E)
                                                : const Color(0xFF4A4040),
                                          ),
                                        ),
                                        
                                        const SizedBox(height: 4),
                                        
                                        // 性价比显示
                                        Text(
                                          '${(item.coins / item.price).toStringAsFixed(0)}币/元',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: isSelected 
                                                ? const Color(0xFFF72E1E).withValues(alpha: 0.7)
                                                : const Color(0xFF9C8E8E),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            // 充值按钮
            Container(
              padding: const EdgeInsets.all(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: selectedIndex != null ? _onRecharge : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedIndex != null 
                        ? const Color(0xFFF72E1E)
                        : const Color(0xFFE5E5E5),
                    foregroundColor: Colors.white,
                    elevation: selectedIndex != null ? 8 : 0,
                    shadowColor: const Color(0xFFF72E1E).withValues(alpha: 0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (selectedIndex != null) ...[
                        const Icon(Icons.payment, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '立即充值 ${rechargeItems[selectedIndex!].displayPrice}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ] else ...[
                        Text(
                          '请选择充值金额',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
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
    );
  }
}