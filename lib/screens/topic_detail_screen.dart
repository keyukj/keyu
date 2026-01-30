import 'package:flutter/material.dart';
import '../models/topic.dart';
import '../models/post.dart';
import '../services/data_service.dart';
import 'post_detail_screen.dart';

class TopicDetailScreen extends StatefulWidget {
  final Topic topic;

  const TopicDetailScreen({
    super.key,
    required this.topic,
  });

  @override
  State<TopicDetailScreen> createState() => _TopicDetailScreenState();
}

class _TopicDetailScreenState extends State<TopicDetailScreen> {
  List<Post> topicPosts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTopicPosts();
  }

  Future<void> _loadTopicPosts() async {
    try {
      // 根据话题获取相关帖子
      final posts = await _getTopicRelatedPosts();
      setState(() {
        topicPosts = posts;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<List<Post>> _getTopicRelatedPosts() async {
    // 模拟根据话题获取相关帖子
    final allPosts = await DataService.getDiscoverPosts();
    
    // 根据话题标题筛选相关帖子
    List<Post> relatedPosts = [];
    
    switch (widget.topic.title) {
      case '# 逃离城市':
        relatedPosts = allPosts.where((post) => 
          post.tags.any((tag) => 
            tag.contains('森林') || 
            tag.contains('山水') || 
            tag.contains('草原') ||
            tag.contains('治愈') ||
            tag.contains('自然')
          ) || 
          post.title.contains('森林') ||
          post.title.contains('山') ||
          post.title.contains('草原') ||
          post.description.contains('远离') ||
          post.description.contains('宁静')
        ).toList();
        break;
        
      case '# 胶片旅行':
        relatedPosts = allPosts.where((post) => 
          post.tags.any((tag) => 
            tag.contains('摄影') || 
            tag.contains('胶片') || 
            tag.contains('复古')
          ) || 
          post.title.contains('摄影') ||
          post.title.contains('拍') ||
          post.description.contains('镜头') ||
          post.description.contains('光影')
        ).toList();
        break;
        
      case '# 森林吸氧':
        relatedPosts = allPosts.where((post) => 
          post.tags.any((tag) => 
            tag.contains('森林') || 
            tag.contains('树') || 
            tag.contains('绿色') ||
            tag.contains('自然')
          ) || 
          post.title.contains('森林') ||
          post.title.contains('树') ||
          post.description.contains('森林') ||
          post.description.contains('绿色')
        ).toList();
        break;
        
      case '# 海边治愈':
        relatedPosts = allPosts.where((post) => 
          post.tags.any((tag) => 
            tag.contains('海') || 
            tag.contains('海滩') || 
            tag.contains('海岛') ||
            tag.contains('度假')
          ) || 
          post.title.contains('海') ||
          post.title.contains('岛') ||
          post.description.contains('海水') ||
          post.description.contains('沙滩')
        ).toList();
        break;
        
      case '# 山峰征服':
        relatedPosts = allPosts.where((post) => 
          post.tags.any((tag) => 
            tag.contains('山') || 
            tag.contains('峰') || 
            tag.contains('登山') ||
            tag.contains('挑战')
          ) || 
          post.title.contains('山') ||
          post.title.contains('峰') ||
          post.description.contains('登山') ||
          post.description.contains('征服')
        ).toList();
        break;
        
      case '# 古镇漫步':
        relatedPosts = allPosts.where((post) => 
          post.tags.any((tag) => 
            tag.contains('古镇') || 
            tag.contains('古城') || 
            tag.contains('历史') ||
            tag.contains('文化')
          ) || 
          post.title.contains('古') ||
          post.title.contains('镇') ||
          post.description.contains('古镇') ||
          post.description.contains('历史')
        ).toList();
        break;
        
      default:
        relatedPosts = allPosts.take(8).toList();
    }
    
    // 如果筛选结果太少，补充一些通用帖子
    if (relatedPosts.length < 6) {
      final additionalPosts = allPosts
          .where((post) => !relatedPosts.contains(post))
          .take(6 - relatedPosts.length)
          .toList();
      relatedPosts.addAll(additionalPosts);
    }
    
    return relatedPosts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F0),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            
            // Topic Info
            _buildTopicInfo(),
            
            // Content
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildPostsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Color(0xFF4A4040),
            ),
          ),
          const Expanded(
            child: Text(
              '话题详情',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A4040),
              ),
            ),
          ),
          const SizedBox(width: 48), // Balance the back button
        ],
      ),
    );
  }

  Widget _buildTopicInfo() {
    IconData iconData;
    Color iconColor;
    
    switch (widget.topic.icon) {
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

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Topic Icon and Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  iconData,
                  color: iconColor,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.topic.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A4040),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.topic.formattedCount} 人参与',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Topic Description
          Text(
            _getTopicDescription(),
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF4A4040),
              height: 1.5,
            ),
          ),
          
          const SizedBox(height: 20),
          
        ],
      ),
    );
  }

  String _getTopicDescription() {
    switch (widget.topic.title) {
      case '# 逃离城市':
        return '远离城市的喧嚣，寻找内心的宁静。在这里分享你的逃离计划，发现那些能让心灵得到治愈的美好地方。';
      case '# 胶片旅行':
        return '用胶片记录旅行的美好时光，感受慢节奏的摄影乐趣。每一张照片都承载着独特的情感和回忆。';
      case '# 森林吸氧':
        return '走进森林，呼吸最纯净的空气。在绿色的世界里放松身心，感受大自然的治愈力量。';
      case '# 海边治愈':
        return '听海浪的声音，感受海风的轻抚。海边是心灵最好的治愈地，让所有烦恼都随浪花消散。';
      case '# 山峰征服':
        return '挑战自我，征服高峰。每一次登顶都是对意志的考验，山峰见证着我们的成长与坚持。';
      case '# 古镇漫步':
        return '穿越时光，漫步古镇。在青石板路上感受历史的厚重，在古建筑中寻找文化的印记。';
      default:
        return '探索世界的美好，分享旅行的故事。在这里发现更多精彩的内容和志同道合的朋友。';
    }
  }

  Widget _buildPostsList() {
    if (topicPosts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '暂无相关内容',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '成为第一个分享的人吧！',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            '相关内容 (${topicPosts.length})',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A4040),
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemCount: topicPosts.length,
            itemBuilder: (context, index) {
              return _buildPostCard(topicPosts[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPostCard(Post post) {
    return GestureDetector(
      onTap: () => _showPostDetail(post),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  post.imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.error),
                    );
                  },
                ),
              ),
            ),
            
            // Content
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      post.title,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A4040),
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const Spacer(),
                    
                    // User info and likes
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: post.userAvatar.startsWith('assets/')
                                    ? Image.asset(
                                        post.userAvatar,
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
                                      )
                                    : Image.network(
                                        post.userAvatar,
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
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  post.username,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF9C8E8E),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.favorite_border,
                              size: 12,
                              color: Color(0xFF9C8E8E),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatLikes(post.likes),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF9C8E8E),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatLikes(int likes) {
    if (likes >= 10000) {
      return '${(likes / 10000).toStringAsFixed(1)}w';
    } else if (likes >= 1000) {
      return '${(likes / 1000).toStringAsFixed(1)}k';
    }
    return likes.toString();
  }

  void _showPostDetail(Post post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostDetailScreen(post: post),
      ),
    );
  }


}