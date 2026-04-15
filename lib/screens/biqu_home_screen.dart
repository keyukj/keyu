import 'package:flutter/material.dart';
import 'topic_changbaishan_screen.dart';
import 'topic_yadan_screen.dart';
import 'topic_nantaihang_screen.dart';
import 'recommend_detail_screen.dart';
import '../widgets/avatar_widget.dart';

class BiquHomeScreen extends StatefulWidget {
  const BiquHomeScreen({super.key});

  @override
  State<BiquHomeScreen> createState() => _BiquHomeScreenState();
}

class _BiquHomeScreenState extends State<BiquHomeScreen> {
  final PageController _bannerController = PageController(viewportFraction: 0.38);

  // null 表示使用本地资源，字符串表示网络图片
  final List<String?> bannerImages = [
    null, // 本地图片 assets/images/imga.png
    'local:assets/images/imgb.png', // 本地图片
    'local:assets/images/imgc.png', // 本地图片
  ];

  final List<Map<String, dynamic>> recommendList = [
    {
      'image': 'https://images.unsplash.com/photo-1510414842594-a61c69b5ae57?q=80&w=400&auto=format&fit=crop',
      'text': '广东周边游，带娃去山间去大自然里露营玩水',
      'avatar': 'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?q=80&w=100&auto=format&fit=crop',
      'nickname': '旅行达人',
      'likes': 166,
    },
    {
      'image': 'assets/images/imgsh.jpg',
      'text': '上海游玩，没有计划的三天两夜，惬意愉快惊喜！',
      'avatar': 'https://images.unsplash.com/photo-1501785888041-af3ef285b470?q=80&w=100&auto=format&fit=crop',
      'nickname': '小鹿出发',
      'likes': 166,
    },
    {
      'image': 'assets/images/imgsl.jpg',
      'text': '森林徒步，感受大自然的呼吸与宁静',
      'avatar': 'https://images.unsplash.com/photo-1469474968028-56623f02e42e?q=80&w=100&auto=format&fit=crop',
      'nickname': '山野清风',
      'likes': 233,
    },
    {
      'image': 'https://images.unsplash.com/photo-1469474968028-56623f02e42e?q=80&w=400&auto=format&fit=crop',
      'text': '日落黄昏下的湖边漫步，治愈一整天的疲惫',
      'avatar': 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?q=80&w=100&auto=format&fit=crop',
      'nickname': '晚风轻语',
      'likes': 89,
    },
    {
      'image': 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?q=80&w=400&auto=format&fit=crop',
      'text': '海边露营，听着海浪入睡的美好夜晚',
      'avatar': 'https://images.unsplash.com/photo-1518837695005-2083093ee35b?q=80&w=100&auto=format&fit=crop',
      'nickname': '海风少年',
      'likes': 312,
    },
    {
      'image': 'https://images.unsplash.com/photo-1501785888041-af3ef285b470?q=80&w=400&auto=format&fit=crop',
      'text': '云南小众秘境，人少景美的宝藏目的地',
      'avatar': 'https://images.unsplash.com/photo-1439066615861-d1af74d74000?q=80&w=100&auto=format&fit=crop',
      'nickname': '探路先锋',
      'likes': 198,
    },
  ];

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 顶部背景图
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/imgbg.jpg',
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          // 主内容
          SafeArea(
            child: Column(
              children: [
                // 固定顶部 50px
                const SizedBox(height: 50),
                // 可滚动内容
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      // 横向可拖拽图片
            SliverToBoxAdapter(
              child: SizedBox(
                height: 214.0 / 143.0 * (MediaQuery.of(context).size.width * 0.38),
                child: PageView.builder(
                  controller: _bannerController,
                  itemCount: bannerImages.length,
                  padEnds: false,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        if (index == 0) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TopicChangbaishanScreen(),
                            ),
                          );
                        } else if (index == 1) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TopicYadanScreen(),
                            ),
                          );
                        } else if (index == 2) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TopicNantaihangScreen(),
                            ),
                          );
                        }
                      },
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: index == 0 ? 16 : 6,
                          right: 6,
                        ),
                      child: AspectRatio(
                        aspectRatio: 143.0 / 214.0,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: bannerImages[index] == null
                              ? Image.asset(
                                  'assets/images/imga.png',
                                  fit: BoxFit.cover,
                                )
                              : bannerImages[index]!.startsWith('local:')
                                  ? Image.asset(
                                      bannerImages[index]!.substring(6),
                                      fit: BoxFit.cover,
                                    )
                                  : Image.network(
                                      bannerImages[index]!,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (context, child, progress) {
                                        if (progress == null) return child;
                                        return Container(color: const Color(0xFFBDBDBD));
                                      },
                                      errorBuilder: (context, error, stack) {
                                        return Container(color: const Color(0xFFBDBDBD));
                                      },
                                    ),
                        ),
                      ),
                    ),
                    );
                  },
                ),
              ),
            ),
            // 热门推荐标题
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: Image(
                  image: AssetImage('assets/images/imgbt.png'),
                  width: 91,
                  height: 27,
                  alignment: Alignment.centerLeft,
                ),
              ),
            ),
            // 双列瀑布流推荐
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.58,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildRecommendCard(recommendList[index]),
                  childCount: recommendList.length,
                ),
              ),
            ),
            // 底部留白
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendCard(Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecommendDetailScreen(item: item),
          ),
        );
      },
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 图片
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: item['image'].toString().startsWith('http')
              ? Image.network(
                  item['image'],
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Container(color: const Color(0xFFBDBDBD));
                  },
                  errorBuilder: (context, error, stack) {
                    return Container(color: const Color(0xFFBDBDBD));
                  },
                )
              : Image.asset(
                  item['image'],
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) {
                    return Container(color: const Color(0xFFBDBDBD));
                  },
                ),
          ),
        ),
        const SizedBox(height: 8),
        // 文案
        Text(
          item['text'],
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1A1A1A),
            height: 1.3,
          ),
        ),
        const SizedBox(height: 6),
        // 头像 + 昵称 + 点赞
        Row(
          children: [
            AvatarWidget(
              imageUrl: item['avatar'],
              name: item['nickname'],
              size: 20,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                item['nickname'],
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF999999),
                ),
              ),
            ),
            const Icon(
              Icons.favorite_border,
              size: 14,
              color: Color(0xFF999999),
            ),
            const SizedBox(width: 2),
            Text(
              '${item['likes']}',
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF999999),
              ),
            ),
          ],
        ),
      ],
    ),
    );
  }
}
