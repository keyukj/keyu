import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../services/ai_service.dart';
import '../services/data_service.dart';
import '../widgets/coin_icon.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  int _coinBalance = 1250; // 金币余额

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
    _loadCoinBalance();
  }

  void _loadCoinBalance() async {
    final balance = await DataService.getCoinBalance();
    setState(() {
      _coinBalance = balance;
    });
  }

  void _addWelcomeMessage() {
    setState(() {
      _messages.add(ChatMessage(
        text: '你好！我是彼趣AI助手 🤖\n\n我可以帮你：\n• 规划旅行路线\n• 推荐热门景点\n• 介绍当地美食\n• 解答旅行问题\n\n有什么想了解的吗？',
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF4A4040)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF72E1E), Color(0xFFFF7E7E)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.smart_toy,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI旅行助手',
                  style: TextStyle(
                    color: Color(0xFF4A4040),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    const CoinIcon(size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '$_coinBalance',
                      style: const TextStyle(
                        color: Color(0xFF9C8E8E),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '每次提问消耗1金币',
                      style: TextStyle(
                        color: Color(0xFF9C8E8E),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF4A4040)),
            onPressed: _clearChat,
          ),
        ],
      ),
      body: Column(
        children: [
          // 快捷建议按钮
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildQuickButton('🗺️ 旅行规划', () => _sendQuickMessage('帮我规划一次旅行')),
                const SizedBox(width: 8),
                _buildQuickButton('🏛️ 景点推荐', () => _sendQuickMessage('推荐一些热门景点')),
                const SizedBox(width: 8),
                _buildQuickButton('🍜 美食推荐', () => _sendQuickMessage('推荐当地美食')),
                const SizedBox(width: 8),
                _buildQuickButton('💡 旅行贴士', () => _sendQuickMessage('给我一些旅行小贴士')),
              ],
            ),
          ),
          
          const Divider(height: 1, color: Color(0xFFE5E5E5)),
          
          // 聊天消息列表
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
          
          // 加载指示器
          if (_isLoading)
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF72E1E), Color(0xFFFF7E7E)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.smart_toy,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'AI助手正在思考中...',
                    style: TextStyle(
                      color: Color(0xFF9C8E8E),
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF72E1E)),
                    ),
                  ),
                ],
              ),
            ),
          
          // 输入框
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Color(0xFFE5E5E5), width: 1),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: '输入你的旅行问题...',
                        hintStyle: const TextStyle(color: Color(0xFF9C8E8E)),
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _isLoading ? null : _sendMessage,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _isLoading 
                            ? [Colors.grey[400]!, Colors.grey[400]!]
                            : [const Color(0xFFF72E1E), const Color(0xFFFF7E7E)],
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickButton(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE5E5E5)),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Color(0xFF4A4040),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF72E1E), Color(0xFFFF7E7E)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.smart_toy,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: message.isUser ? const Color(0xFFF72E1E) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser ? Colors.white : const Color(0xFF4A4040),
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: message.isUser 
                        ? Colors.white.withValues(alpha: 0.7) 
                        : const Color(0xFF9C8E8E),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 12),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF4A4040),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _sendQuickMessage(String message) {
    if (_coinBalance < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              CoinIcon(size: 16),
              SizedBox(width: 8),
              Text('金币不足，请先充值'),
            ],
          ),
          backgroundColor: const Color(0xFFF72E1E),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          action: SnackBarAction(
            label: '去充值',
            textColor: Colors.white,
            onPressed: () {
              Navigator.pushNamed(context, '/wallet_recharge');
            },
          ),
        ),
      );
      return;
    }
    
    _messageController.text = message;
    _sendMessage();
  }

  void _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _isLoading) return;

    // 检查金币余额
    if (_coinBalance < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              CoinIcon(size: 16),
              SizedBox(width: 8),
              Text('金币不足，请先充值'),
            ],
          ),
          backgroundColor: const Color(0xFFF72E1E),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          action: SnackBarAction(
            label: '去充值',
            textColor: Colors.white,
            onPressed: () {
              Navigator.pushNamed(context, '/wallet_recharge');
            },
          ),
        ),
      );
      return;
    }

    setState(() {
      _messages.add(ChatMessage(
        text: message,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      // 扣除1金币
      final success = await DataService.deductCoins(1);
      if (success) {
        // 更新本地余额显示
        setState(() {
          _coinBalance -= 1;
        });
      }

      // 构建对话历史
      List<Map<String, String>> conversationHistory = [];
      for (int i = math.max(0, _messages.length - 10); i < _messages.length - 1; i++) {
        conversationHistory.add({
          "role": _messages[i].isUser ? "user" : "assistant",
          "content": _messages[i].text,
        });
      }

      final response = await AIService.sendMessage(message, conversationHistory: conversationHistory);
      
      setState(() {
        _messages.add(ChatMessage(
          text: response,
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          text: '抱歉，发生了错误，请稍后重试。',
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
      
      // 如果AI服务失败，退还金币
      await DataService.addCoins(1);
      setState(() {
        _coinBalance += 1;
      });
    }

    _scrollToBottom();
  }

  void _clearChat() {
    setState(() {
      _messages.clear();
    });
    _addWelcomeMessage();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}