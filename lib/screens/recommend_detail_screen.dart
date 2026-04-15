import 'package:flutter/material.dart';
import '../widgets/avatar_widget.dart';
import '../widgets/report_dialog.dart';

class RecommendDetailScreen extends StatelessWidget {
  final Map<String, dynamic> item;

  const RecommendDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 360,
            pinned: true,
            backgroundColor: Colors.white,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () => showReportDialog(context, message: '是否举报该内容？'),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.flag_outlined, color: Colors.white, size: 18),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: item['image'].toString().startsWith('http')
                ? Image.network(
                    item['image'],
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(color: const Color(0xFFEEEEEE));
                    },
                    errorBuilder: (context, error, stack) {
                      return Container(color: const Color(0xFFEEEEEE));
                    },
                  )
                : Image.asset(
                    item['image'],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) {
                      return Container(color: const Color(0xFFEEEEEE));
                    },
                  ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['text'],
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      AvatarWidget(
                        imageUrl: item['avatar'],
                        name: item['nickname'],
                        size: 40,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['nickname'],
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              '旅行博主 · 3小时前',
                              style: TextStyle(fontSize: 12, color: Color(0xFF999999)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    item['content'] ?? _defaultContent(item['text']),
                    style: const TextStyle(fontSize: 15, color: Color(0xFF333333), height: 1.8),
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildTag('旅行'),
                      _buildTag('户外'),
                      _buildTag('风景'),
                      _buildTag('攻略'),
                    ],
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        '# $text',
        style: const TextStyle(fontSize: 12, color: Color(0xFFF72E1E)),
      ),
    );
  }

  String _defaultContent(String title) {
    return '这次旅行真的超出预期。$title\n\n'
        '出发前其实没有做太多攻略，就是想找一个能让自己放松下来的地方，远离城市的喧嚣，好好感受一下大自然的气息。\n\n'
        '到了之后才发现，这里的美远比照片里看到的更加震撼。清晨的光线洒在山间，雾气还没有完全散去，整个画面像是一幅水墨画。空气清新得让人忍不住深呼吸，每一口都带着草木的香气。\n\n'
        '白天沿着步道慢慢走，不赶时间，遇到好看的地方就停下来坐一会儿。听听鸟叫，看看远处的山峦起伏，感觉时间在这里变得特别慢。\n\n'
        '傍晚的时候找了一个视野开阔的地方看日落，天边的云被染成了金色和橘红色，渐渐过渡到深紫色，最后归于宁静的深蓝。那一刻觉得，所有的疲惫都值了。\n\n'
        '晚上住在当地的民宿，老板很热情，推荐了好几个小众的观景点。吃的是地道的家常菜，简单但特别有味道。\n\n'
        '这趟旅行让我重新理解了"慢下来"的意义。不是每次出行都要打卡所有景点，有时候就是找一个喜欢的地方，安安静静地待着，就已经是最好的旅行了。\n\n'
        '强烈推荐给想要逃离日常的朋友们，真的会被治愈到。';
  }
}
