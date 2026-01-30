import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../models/post.dart';
import '../models/comment.dart';
import '../services/data_service.dart';
import 'post_detail_screen.dart';

class SquareScreen extends StatefulWidget {
  const SquareScreen({super.key});

  @override
  State<SquareScreen> createState() => _SquareScreenState();
}

class _SquareScreenState extends State<SquareScreen> {
  List<Post> posts = [];
  bool isLoading = true;
  int selectedTab = 1; // 0: 关注, 1: 发现
  
  // 用于管理点赞状态
  Map<String, bool> likedPosts = {};
  Map<String, int> postLikes = {};
  
  // 用于管理评论
  Map<String, List<Comment>> postComments = {};

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    try {
      List<Post> loadedPosts;
      if (selectedTab == 0) {
        // 关注页面
        loadedPosts = await DataService.getFollowingPosts();
      } else {
        // 发现页面
        loadedPosts = await DataService.getDiscoverPosts();
      }
      
      setState(() {
        posts = loadedPosts;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _refreshPosts() async {
    setState(() {
      isLoading = true;
    });
    await _loadPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F0),
      body: SafeArea(
        child: Column(
          children: [
            // Header with tabs
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildTabItem('关注', 0),
                  const SizedBox(width: 48),
                  _buildTabItem('发现', 1),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _refreshPosts,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: MasonryGridView.count(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          itemCount: posts.length,
                          itemBuilder: (context, index) {
                            return _buildPostCard(posts[index]);
                          },
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(String title, int index) {
    final isSelected = selectedTab == index;
    return GestureDetector(
      onTap: () {
        if (selectedTab != index) {
          setState(() {
            selectedTab = index;
            isLoading = true;
          });
          _loadPosts();
        }
      },
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? const Color(0xFF4A4040) : const Color(0xFF9C8E8E),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 24,
            height: 3,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFF72E1E) : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(Post post) {
    return GestureDetector(
      onTap: () {
        _showPostDetail(post);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: post.imageUrl.startsWith('assets/')
                  ? Image.asset(
                      post.imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 150,
                          color: Colors.grey[200],
                          child: const Icon(Icons.error),
                        );
                      },
                    )
                  : Image.network(
                      post.imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 150,
                          color: Colors.grey[200],
                          child: const Center(child: CircularProgressIndicator()),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 150,
                          color: Colors.grey[200],
                          child: const Icon(Icons.error),
                        );
                      },
                    ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    post.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A4040),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // User info and stats
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: post.userAvatar.startsWith('assets/')
                            ? Image.asset(
                                post.userAvatar,
                                width: 20,
                                height: 20,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 20,
                                    height: 20,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.person, size: 14),
                                  );
                                },
                              )
                            : Image.network(
                                post.userAvatar,
                                width: 20,
                                height: 20,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 20,
                                    height: 20,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.person, size: 14),
                                  );
                                },
                              ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          post.username,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF9C8E8E),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Like button and count
                      GestureDetector(
                        onTap: () => _toggleLike(post.id),
                        child: Row(
                          children: [
                            Icon(
                              likedPosts[post.id] == true 
                                  ? Icons.favorite 
                                  : Icons.favorite_outline,
                              size: 16,
                              color: likedPosts[post.id] == true 
                                  ? const Color(0xFFF72E1E) 
                                  : const Color(0xFF9C8E8E),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatLikes(postLikes[post.id] ?? post.likes),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF9C8E8E),
                              ),
                            ),
                          ],
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

  void _toggleLike(String postId) {
    setState(() {
      final currentlyLiked = likedPosts[postId] ?? false;
      likedPosts[postId] = !currentlyLiked;
      
      final currentLikes = postLikes[postId] ?? posts.firstWhere((p) => p.id == postId).likes;
      postLikes[postId] = currentlyLiked ? currentLikes - 1 : currentLikes + 1;
    });
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