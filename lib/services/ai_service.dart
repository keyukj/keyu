import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class AIService {
  static const String _apiKey = 'sk-04fe19d0f3a94a60b0ceae2da2d949aa';
  static const String _baseUrl = 'https://api.deepseek.com/chat/completions';

  static Future<String> sendMessage(String message, {List<Map<String, String>>? conversationHistory}) async {
    try {
      // 构建消息历史
      List<Map<String, String>> messages = [
        {
          "role": "system",
          "content": "你是彼趣App的AI旅行助手，专门帮助用户规划旅行、推荐景点、解答旅行相关问题。请用友好、专业的语气回答，并尽量提供实用的建议。回答要简洁明了，适合在手机上阅读。"
        }
      ];

      // 添加对话历史
      if (conversationHistory != null) {
        messages.addAll(conversationHistory);
      }

      // 添加当前用户消息
      messages.add({
        "role": "user",
        "content": message
      });

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          "model": "deepseek-chat",
          "messages": messages,
          "stream": false,
          "max_tokens": 1000,
          "temperature": 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        
        if (data['choices'] != null && data['choices'].isNotEmpty) {
          return data['choices'][0]['message']['content'] ?? '抱歉，我没有理解您的问题。';
        } else {
          return '抱歉，服务暂时不可用，请稍后再试。';
        }
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        return '网络连接失败，请检查网络后重试。';
      }
    } catch (e) {
      print('AI Service Error: $e');
      if (e is SocketException) {
        return '网络连接失败，请检查网络设置。';
      } else if (e is HttpException) {
        return '服务器连接失败，请稍后重试。';
      } else {
        return '发生未知错误，请稍后重试。';
      }
    }
  }

  // 获取旅行建议的快捷方法
  static Future<String> getTravelAdvice(String destination) async {
    return await sendMessage('我想去$destination旅行，能给我一些建议吗？包括必去景点、美食推荐、注意事项等。');
  }

  // 获取景点推荐的快捷方法
  static Future<String> getAttractionRecommendations(String city, String preferences) async {
    return await sendMessage('我在$city，喜欢$preferences，能推荐一些适合的景点或活动吗？');
  }

  // 获取美食推荐的快捷方法
  static Future<String> getFoodRecommendations(String location) async {
    return await sendMessage('我在$location，能推荐一些当地特色美食和餐厅吗？');
  }
}