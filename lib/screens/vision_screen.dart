import 'package:flutter/material.dart';
import '../models/post.dart';
import '../models/comment.dart';
import '../models/user.dart';
import '../services/data_service.dart';

class VisionScreen extends StatefulWidget {
  const VisionScreen({super.key});

  @override
  State<VisionScreen> createState() => _VisionScreenState();
}

class _VisionScreenState extends State<VisionScreen> {
  List<Post> visionPosts = [];
  bool isLoading = true;
  PageController pageController = PageController();
  int currentIndex = 0;
  
  // 记录每个帖子的点赞状态
  Map<String, bool> likedPosts = {};
  Map<String, int> postLikeCounts = {};
  
  // 记录每个用户的关注状态
  Map<String, bool> followedUsers = {};
  
  // 评论相关状态
  Map<String, List<Comment>> postComments = {};
  Map<String, int> postCommentCounts = {};
  
  // 评论输入控制器
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadVisionPosts();
  }

  @override
  void dispose() {
    pageController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadVisionPosts() async {
    try {
      final posts = await DataService.getVisionPosts();
      setState(() {
        visionPosts = posts;
        isLoading = false;
        // 初始化点赞状态和点赞数
        for (var post in posts) {
          likedPosts[post.id] = false;
          postLikeCounts[post.id] = post.likes;
          followedUsers[post.username] = false; // 初始化关注状态
        }
      });
      
      // 加载评论数据
      await _loadCommentsData();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadCommentsData() async {
    for (var post in visionPosts) {
      final comments = await DataService.getPostComments(post.id);
      setState(() {
        postComments[post.id] = comments;
        postCommentCounts[post.id] = comments.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F0F0F),
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    if (visionPosts.isEmpty) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F0F0F),
        body: Center(
          child: Text(
            '暂无内容',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: PageView.builder(
        controller: pageController,
        scrollDirection: Axis.vertical,
        itemCount: visionPosts.length,
        onPageChanged: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          return _buildVisionPost(visionPosts[index], index);
        },
      ),
    );
  }

  Widget _buildVisionPost(Post post, int index) {
    return Stack(
      children: [
        // Background Image
        Positioned.fill(
          child: Image.network(
            post.imageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: Colors.grey[800],
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[800],
                child: const Center(
                  child: Icon(Icons.error, color: Colors.white, size: 48),
                ),
              );
            },
          ),
        ),
        
        // Dark overlay
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.7),
                ],
                stops: const [0.0, 0.7, 1.0],
              ),
            ),
          ),
        ),
        
        // Top Header
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'VISION',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _showReportMenu(visionPosts[currentIndex]),
                    child: Icon(
                      Icons.more_vert,
                      color: Colors.white.withOpacity(0.8),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        // Right side actions
        Positioned(
          right: 16,
          bottom: 200,
          child: Column(
            children: [
              _buildActionButton(
                post.id,
                likedPosts[post.id] == true ? Icons.favorite : Icons.favorite_border,
                _formatCount(postLikeCounts[post.id] ?? post.likes),
                () => _toggleLike(post),
                isLiked: likedPosts[post.id] == true,
              ),
              const SizedBox(height: 24),
              _buildActionButton(
                post.id,
                Icons.comment_outlined,
                _formatCount(postCommentCounts[post.id] ?? 0),
                () => _showComments(post),
              ),
              const SizedBox(height: 24),
              _buildSimpleActionButton(
                Icons.report_outlined,
                '举报',
                () => _showReportMenu(post),
              ),
            ],
          ),
        ),
        
        // Bottom Content
        Positioned(
          bottom: 0,
          left: 0,
          right: 80, // Leave space for action buttons
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    post.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (post.description.isNotEmpty)
                    Text(
                      post.description,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: post.userAvatar.startsWith('assets/')
                                      ? Image.asset(
                                          post.userAvatar,
                                          width: 32,
                                          height: 32,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              width: 32,
                                              height: 32,
                                              decoration: BoxDecoration(
                                                color: Colors.grey[600],
                                                borderRadius: BorderRadius.circular(16),
                                              ),
                                              child: const Icon(
                                                Icons.person,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                            );
                                          },
                                        )
                                      : Image.network(
                                          post.userAvatar,
                                          width: 32,
                                          height: 32,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              width: 32,
                                              height: 32,
                                              decoration: BoxDecoration(
                                                color: Colors.grey[600],
                                                borderRadius: BorderRadius.circular(16),
                                              ),
                                              child: const Icon(
                                                Icons.person,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                            );
                                          },
                                        ),
                                ),
                                Positioned(
                                  bottom: -2,
                                  right: -2,
                                  child: Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF72E1E),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Icon(
                                      Icons.add,
                                      color: Colors.white,
                                      size: 8,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                post.username,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _followUser(post.username),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: followedUsers[post.username] == true 
                                ? Colors.grey.withOpacity(0.3)
                                : Colors.white.withOpacity(0.2),
                            ),
                            borderRadius: BorderRadius.circular(20),
                            color: followedUsers[post.username] == true 
                              ? Colors.grey.withOpacity(0.2)
                              : Colors.white.withOpacity(0.05),
                          ),
                          child: Text(
                            followedUsers[post.username] == true ? '已关注' : '关注',
                            style: TextStyle(
                              color: followedUsers[post.username] == true 
                                ? Colors.grey[300]
                                : Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        
        // Page indicator
        Positioned(
          right: 8,
          top: MediaQuery.of(context).size.height * 0.4,
          child: Column(
            children: List.generate(
              visionPosts.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(vertical: 2),
                width: 3,
                height: currentIndex == index ? 20 : 8,
                decoration: BoxDecoration(
                  color: currentIndex == index 
                    ? Colors.white 
                    : Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(String postId, IconData icon, String label, VoidCallback onTap, {bool isLiked = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              icon,
              color: isLiked ? Colors.red : Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleActionButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 10000) {
      return '${(count / 10000).toStringAsFixed(1)}w';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }

  void _toggleLike(Post post) {
    setState(() {
      bool currentLikeStatus = likedPosts[post.id] ?? false;
      likedPosts[post.id] = !currentLikeStatus;
      
      // 更新点赞数
      if (likedPosts[post.id]!) {
        postLikeCounts[post.id] = (postLikeCounts[post.id] ?? post.likes) + 1;
      } else {
        postLikeCounts[post.id] = (postLikeCounts[post.id] ?? post.likes) - 1;
      }
    });
    
    // 显示点赞反馈
    String message = likedPosts[post.id]! ? '已点赞 ${post.username} 的作品' : '已取消点赞';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.black.withOpacity(0.8),
      ),
    );
  }

  void _showComments(Post post) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => _buildCommentsSheet(post, scrollController),
      ),
    );
  }

  Widget _buildCommentsSheet(Post post, ScrollController scrollController) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text(
                      '评论',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A4040),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${postCommentCounts[post.id] ?? 0}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9C8E8E),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Color(0xFF9C8E8E)),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // Comments list
          Expanded(
            child: Builder(
              builder: (context) {
                final comments = postComments[post.id] ?? [];
                
                if (comments.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.comment_outlined,
                          size: 48,
                          color: Color(0xFF9C8E8E),
                        ),
                        SizedBox(height: 16),
                        Text(
                          '还没有评论',
                          style: TextStyle(
                            color: Color(0xFF9C8E8E),
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '快来抢沙发吧！',
                          style: TextStyle(
                            color: Color(0xFF9C8E8E),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                return ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    return _buildCommentItem(comments[index]);
                  },
                );
              },
            ),
          ),
          
          // Comment input
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  FutureBuilder<User>(
                    future: DataService.getCurrentUser(),
                    builder: (context, snapshot) {
                      final currentUser = snapshot.data ?? DataService.getDefaultUser();
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: currentUser.avatar.startsWith('assets/')
                          ? Image.asset(
                              currentUser.avatar,
                              width: 32,
                              height: 32,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                );
                              },
                            )
                          : Image.network(
                              currentUser.avatar,
                              width: 32,
                              height: 32,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                );
                              },
                            ),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _commentController,
                              decoration: const InputDecoration(
                                hintText: '说点什么...',
                                border: InputBorder.none,
                                hintStyle: TextStyle(color: Color(0xFF9C8E8E)),
                              ),
                              maxLines: null,
                              textInputAction: TextInputAction.send,
                              onSubmitted: (_) => _submitComment(post),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _submitComment(post),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              child: const Icon(
                                Icons.send,
                                color: Color(0xFFF72E1E),
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(Comment comment) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: comment.userAvatar.startsWith('assets/')
                ? Image.asset(
                    comment.userAvatar,
                    width: 32,
                    height: 32,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 20,
                        ),
                      );
                    },
                  )
                : Image.network(
                    comment.userAvatar,
                    width: 32,
                    height: 32,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 20,
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.username,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4A4040),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatCommentTime(comment.createdAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9C8E8E),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment.content,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF4A4040),
                    height: 1.4,
                  ),
                ),
                
                // Show replies if any
                if (comment.replies.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    margin: const EdgeInsets.only(left: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: comment.replies.map((reply) => _buildReplyItem(reply)).toList(),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyItem(Comment reply) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: reply.userAvatar.startsWith('assets/')
                ? Image.asset(
                    reply.userAvatar,
                    width: 24,
                    height: 24,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 14,
                        ),
                      );
                    },
                  )
                : Image.network(
                    reply.userAvatar,
                    width: 24,
                    height: 24,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 14,
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      reply.username,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4A4040),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatCommentTime(reply.createdAt),
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF9C8E8E),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  reply.content,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF4A4040),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatCommentTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}小时前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      return '${dateTime.month}月${dateTime.day}日';
    }
  }

  void _submitComment(Post post) async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    final currentUser = await DataService.getCurrentUser();
    
    // 创建新评论
    final newComment = Comment(
      id: 'comment_${DateTime.now().millisecondsSinceEpoch}',
      postId: post.id,
      userId: currentUser.id,
      username: currentUser.displayName,
      userAvatar: currentUser.avatar,
      content: content,
      createdAt: DateTime.now(),
      likes: 0,
    );

    // 添加新的顶级评论
    final comments = postComments[post.id] ?? [];
    comments.insert(0, newComment); // 新评论显示在顶部
    
    setState(() {
      postComments[post.id] = comments;
      postCommentCounts[post.id] = comments.length;
    });

    // 清空输入框
    _commentController.clear();

    // 显示成功提示
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('评论成功'),
        duration: Duration(seconds: 1),
        backgroundColor: Colors.green,
      ),
    );

    // 保存到本地存储
    try {
      await DataService.addComment(newComment);
    } catch (e) {
      print('保存评论失败: $e');
    }
  }

  void _showReportMenu(Post post) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '举报和管理',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A4040),
              ),
            ),
            const SizedBox(height: 20),
            _buildReportOption(
              Icons.report_outlined,
              '举报内容',
              '举报不当内容',
              () => _reportContent(post),
            ),
            const SizedBox(height: 16),
            _buildReportOption(
              Icons.block_outlined,
              '拉黑用户',
              '不再看到此用户的内容',
              () => _blockUser(post),
            ),
            const SizedBox(height: 16),
            _buildReportOption(
              Icons.visibility_off_outlined,
              '不感兴趣',
              '减少此类内容推荐',
              () => _notInterested(post),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildReportOption(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: const Color(0xFF9C8E8E),
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF4A4040),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9C8E8E),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[400],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _reportContent(Post post) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('举报内容'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('请选择举报原因：'),
            const SizedBox(height: 16),
            _buildReportReason('不当内容'),
            _buildReportReason('垃圾信息'),
            _buildReportReason('虚假信息'),
            _buildReportReason('侵犯版权'),
            _buildReportReason('其他'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }

  Widget _buildReportReason(String reason) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('已举报：$reason'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.black87,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          reason,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF4A4040),
          ),
        ),
      ),
    );
  }

  void _blockUser(Post post) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('拉黑用户'),
        content: Text('确定要拉黑用户 ${post.username} 吗？\n拉黑后将不再看到该用户的任何内容。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('已拉黑用户 ${post.username}'),
                  duration: const Duration(seconds: 2),
                  backgroundColor: Colors.black87,
                ),
              );
            },
            child: const Text(
              '确定',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _notInterested(Post post) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('已标记为不感兴趣，将减少此类内容推荐'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.black87,
      ),
    );
  }

  void _followUser(String username) {
    setState(() {
      bool currentFollowStatus = followedUsers[username] ?? false;
      followedUsers[username] = !currentFollowStatus;
    });
    
    String message = followedUsers[username]! ? '已关注 $username' : '已取消关注 $username';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.black87,
      ),
    );
  }
}