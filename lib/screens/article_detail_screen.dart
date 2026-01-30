import 'package:flutter/material.dart';
import '../models/article.dart';

class ArticleDetailScreen extends StatefulWidget {
  final Article article;

  const ArticleDetailScreen({
    super.key,
    required this.article,
  });

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  bool isLiked = false;
  bool isBookmarked = false;
  bool isFollowing = false;
  int likeCount = 0;

  @override
  void initState() {
    super.initState();
    // 模拟点赞数
    likeCount = (widget.article.views * 0.08).round();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // App Bar with cover image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onSelected: (value) {
                    if (value == 'block') {
                      _showBlockDialog();
                    } else if (value == 'report') {
                      _showReportDialog();
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem<String>(
                      value: 'block',
                      child: Row(
                        children: [
                          Icon(Icons.block, color: Colors.red),
                          SizedBox(width: 8),
                          Text('拉黑用户'),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'report',
                      child: Row(
                        children: [
                          Icon(Icons.report, color: Colors.orange),
                          SizedBox(width: 8),
                          Text('举报内容'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    widget.article.coverImage,
                    fit: BoxFit.cover,
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
                          Colors.black.withOpacity(0.3),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Article content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Article title
                  Text(
                    widget.article.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A4040),
                      height: 1.3,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Author info and stats
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          widget.article.authorAvatar,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 40,
                              height: 40,
                              color: Colors.grey[300],
                              child: const Icon(Icons.person, size: 20),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.article.authorName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF4A4040),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Text(
                                  _formatDate(widget.article.publishedAt),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF9C8E8E),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '·',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[400],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${widget.article.readTime} min read',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF9C8E8E),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Follow button
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isFollowing = !isFollowing;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: isFollowing ? const Color(0xFFE5E5E5) : Colors.white,
                            border: Border.all(
                              color: isFollowing ? const Color(0xFFE5E5E5) : const Color(0xFFF72E1E),
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            isFollowing ? '已关注' : '关注',
                            style: TextStyle(
                              fontSize: 12,
                              color: isFollowing ? const Color(0xFF9C8E8E) : const Color(0xFFF72E1E),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Article stats
                  Row(
                    children: [
                      Icon(
                        Icons.visibility_outlined,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.article.formattedViews,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.favorite_outline,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatCount(likeCount),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Article content
                  _buildArticleContent(),
                  
                  const SizedBox(height: 40),
                  
                  // Action buttons
                  _buildActionButtons(),
                  
                  const SizedBox(height: 40),
                  
                  // Related articles section
                  _buildRelatedArticles(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleContent() {
    // 模拟文章内容
    const content = '''
京都的秋天，是一年中最美的季节。当满城的枫叶开始泛红，当银杏叶片片飘落，整座古都仿佛被大自然的画笔重新描绘了一遍。

而在这样的季节里，如果你想要拍出一组王家卫风格的照片，那么你需要掌握几个关键要素。

## 光影的运用

王家卫电影中最令人印象深刻的，就是那些充满诗意的光影效果。在京都的秋天，你可以利用：

• **透过竹林的斑驳光影**：嵯峨野竹林是绝佳的拍摄地点
• **寺庙中的侧光**：清水寺、金阁寺的侧光营造出神秘氛围
• **街巷中的逆光**：祇园的小巷在夕阳下格外迷人

## 色彩的搭配

秋天的京都本身就是一个巨大的调色板：

红色的枫叶、金黄的银杏、深绿的松柏，再加上古建筑的木色和瓦片的青灰色，这些天然的色彩搭配就是最好的背景。

## 构图的技巧

王家卫式的构图往往带有强烈的个人风格：

1. **前景虚化**：利用花草、树枝作为前景，营造朦胧感
2. **框架构图**：利用门窗、拱桥等建筑元素作为画框
3. **对称与不对称**：在传统的对称美中寻找不对称的趣味点

## 情绪的表达

最重要的是，要在照片中融入情感。京都的秋天本身就充满了诗意和禅意，你需要做的就是用镜头捕捉这种氛围。

无论是一个人静静走过石板路的背影，还是透过窗棂看到的庭院一角，都能成为绝佳的素材。

记住，技术只是工具，真正打动人心的，永远是照片背后的情感和故事。

在京都的秋天，每一个角落都藏着一个故事，每一片落叶都诉说着时光的流转。用心去感受，用镜头去记录，你也能拍出属于自己的"王家卫式"京都秋色。
''';

    return Text(
      content,
      style: const TextStyle(
        fontSize: 16,
        height: 1.8,
        color: Color(0xFF4A4040),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Like button
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                isLiked = !isLiked;
                if (isLiked) {
                  likeCount++;
                } else {
                  likeCount--;
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isLiked ? const Color(0xFFF72E1E) : Colors.white,
                border: Border.all(
                  color: isLiked ? const Color(0xFFF72E1E) : const Color(0xFFE5E5E5),
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isLiked ? Icons.favorite : Icons.favorite_outline,
                    color: isLiked ? Colors.white : const Color(0xFF9C8E8E),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isLiked ? '已点赞' : '点赞',
                    style: TextStyle(
                      color: isLiked ? Colors.white : const Color(0xFF9C8E8E),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Bookmark button
        GestureDetector(
          onTap: () {
            setState(() {
              isBookmarked = !isBookmarked;
            });
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isBookmarked ? const Color(0xFFF72E1E) : Colors.white,
              border: Border.all(
                color: isBookmarked ? const Color(0xFFF72E1E) : const Color(0xFFE5E5E5),
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
              color: isBookmarked ? Colors.white : const Color(0xFF9C8E8E),
              size: 18,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRelatedArticles() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '相关推荐',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4A4040),
          ),
        ),
        const SizedBox(height: 16),
        
        // Related article cards
        _buildRelatedArticleCard(
          '在巴黎的咖啡馆里，如何拍出法式浪漫？',
          '咖啡师小李',
          'https://images.unsplash.com/photo-1551218808-94e220e084d2?q=80&w=300&auto=format&fit=crop',
          '8.5k',
          '6',
        ),
        
        const SizedBox(height: 16),
        
        _buildRelatedArticleCard(
          '东京街头摄影指南：捕捉都市的诗意瞬间',
          '街头摄影师',
          'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?q=80&w=300&auto=format&fit=crop',
          '12.3k',
          '4',
        ),
      ],
    );
  }

  Widget _buildRelatedArticleCard(
    String title,
    String author,
    String imageUrl,
    String views,
    String readTime,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFE5E5)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imageUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey[200],
                  child: const Icon(Icons.error),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4A4040),
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      author,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9C8E8E),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '·',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[400],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$views 阅读',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9C8E8E),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '·',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[400],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${readTime}min',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9C8E8E),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }

  String _formatCount(int count) {
    if (count >= 10000) {
      return '${(count / 10000).toStringAsFixed(1)}w';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }

  void _showBlockDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('拉黑用户'),
          content: Text('确定要拉黑用户 "${widget.article.authorName}" 吗？拉黑后将不再看到该用户的内容。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('已拉黑用户 "${widget.article.authorName}"'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              child: const Text('确定', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('举报内容'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('请选择举报原因：'),
              const SizedBox(height: 16),
              _buildReportOption('垃圾信息'),
              _buildReportOption('虚假信息'),
              _buildReportOption('违法违规'),
              _buildReportOption('侵犯版权'),
              _buildReportOption('其他原因'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildReportOption(String reason) {
    return ListTile(
      title: Text(reason),
      onTap: () {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('已举报该内容：$reason'),
            backgroundColor: Colors.orange,
          ),
        );
      },
    );
  }
}