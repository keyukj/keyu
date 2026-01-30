import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../models/topic.dart';
import '../models/article.dart';
import '../services/data_service.dart';
import 'topic_detail_screen.dart';
import 'article_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Topic> topics = [];
  List<Article> articles = [];
  bool isLoading = true;
  int _currentBannerIndex = 0;
  
  // 轮播图数据
  final List<Map<String, String>> bannerData = [
    {
      'image': 'https://images.unsplash.com/photo-1510414842594-a61c69b5ae57?q=80&w=800&auto=format&fit=crop',
      'volume': 'Vol.24',
      'title': '那些适合失恋去的治愈海边',
      'subtitle': '听海浪的声音，把烦恼都冲刷干净...',
    },
    {
      'image': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?q=80&w=800&auto=format&fit=crop',
      'volume': 'Vol.25',
      'title': '山间秘境中的诗意生活',
      'subtitle': '远离喧嚣，在自然中找回内心的宁静...',
    },
    {
      'image': 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?q=80&w=800&auto=format&fit=crop',
      'volume': 'Vol.26',
      'title': '森林深处的治愈时光',
      'subtitle': '在绿意盎然中，感受生命的力量...',
    },
    {
      'image': 'https://images.unsplash.com/photo-1469474968028-56623f02e42e?q=80&w=800&auto=format&fit=crop',
      'volume': 'Vol.27',
      'title': '湖光山色间的心灵之旅',
      'subtitle': '静谧的湖水倒映着内心的平静...',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final loadedTopics = await DataService.getTopics();
      final loadedArticles = await DataService.getArticles();
      
      setState(() {
        topics = loadedTopics;
        articles = loadedArticles;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F0),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: '探遇 ',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4A4040),
                              ),
                            ),
                            TextSpan(
                              text: 'DISCOVER',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFF72E1E),
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    

                    
                    // Featured Playlist
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _buildFeaturedCard(),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Hot Topics
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '热门话题',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4A4040),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildTopicsRow(),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Deep Column
                    if (articles.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '深度专栏',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4A4040),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // 显示多篇文章
                            ...articles.take(3).map((article) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildArticleCard(article),
                            )).toList(),
                          ],
                        ),
                      ),
                    
                    const SizedBox(height: 100), // Bottom padding for navigation
                  ],
                ),
              ),
      ),
    );
  }



  Widget _buildFeaturedCard() {
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 224,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            enlargeCenterPage: true,
            viewportFraction: 0.9,
            onPageChanged: (index, reason) {
              setState(() {
                _currentBannerIndex = index;
              });
            },
          ),
          items: bannerData.map((banner) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(horizontal: 5.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Stack(
                      children: [
                        Image.network(
                          banner['image']!,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Colors.grey[200],
                              child: const Center(child: CircularProgressIndicator()),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[200],
                              child: const Icon(Icons.error),
                            );
                          },
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.2),
                                Colors.black.withOpacity(0.7),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 20,
                          left: 20,
                          right: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      banner['volume']!,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF72E1E),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      '精选',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                banner['title']!,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                banner['subtitle']!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        // 轮播图指示器
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: bannerData.asMap().entries.map((entry) {
            return Container(
              width: _currentBannerIndex == entry.key ? 20.0 : 8.0,
              height: 8.0,
              margin: const EdgeInsets.symmetric(horizontal: 3.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.0),
                color: _currentBannerIndex == entry.key
                    ? const Color(0xFFF72E1E)
                    : const Color(0xFFE0E0E0),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTopicsRow() {
    return SizedBox(
      height: 128,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: topics.length,
        itemBuilder: (context, index) {
          final topic = topics[index];
          return Padding(
            padding: EdgeInsets.only(right: index < topics.length - 1 ? 16 : 0),
            child: _buildTopicCard(topic),
          );
        },
      ),
    );
  }

  Widget _buildTopicCard(Topic topic) {
    IconData iconData;
    Color iconColor;
    
    switch (topic.icon) {
      case 'fire':
        iconData = Icons.local_fire_department;
        iconColor = const Color(0xFFF72E1E);
        break;
      case 'camera':
        iconData = Icons.camera_alt;
        iconColor = Colors.purple;
        break;
      case 'tree':
        iconData = Icons.park;
        iconColor = Colors.green;
        break;
      case 'water':
        iconData = Icons.waves;
        iconColor = Colors.blue;
        break;
      case 'mountain':
        iconData = Icons.terrain;
        iconColor = Colors.brown;
        break;
      case 'temple':
        iconData = Icons.temple_buddhist;
        iconColor = Colors.orange;
        break;
      default:
        iconData = Icons.tag;
        iconColor = const Color(0xFFF72E1E);
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TopicDetailScreen(topic: topic),
          ),
        );
      },
      child: Container(
        width: 128,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFFE5E5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(iconData, color: iconColor, size: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  topic.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A4040),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${topic.formattedCount} 参与',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF9C8E8E),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleCard(Article article) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArticleDetailScreen(article: article),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              article.coverImage,
              width: 80,
              height: 96,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: 80,
                  height: 96,
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 80,
                  height: 96,
                  color: Colors.grey[200],
                  child: const Icon(Icons.error),
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        article.authorAvatar,
                        width: 16,
                        height: 16,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 16,
                            height: 16,
                            color: Colors.grey[300],
                            child: const Icon(Icons.person, size: 12),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      article.authorName,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF9C8E8E),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  article.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A4040),
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.visibility_outlined,
                      size: 12,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      article.formattedViews,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.access_time,
                      size: 12,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${article.readTime}min',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
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
    );
  }
}