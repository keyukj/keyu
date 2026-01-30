import 'package:flutter/material.dart';
import '../models/post.dart';
import '../models/comment.dart';
import '../services/data_service.dart';

class PostDetailScreen extends StatefulWidget {
  final Post post;

  const PostDetailScreen({
    super.key,
    required this.post,
  });

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  List<Comment> comments = [];
  bool isLoading = true;
  bool isLiked = false;
  bool isFollowed = false;
  int likeCount = 0;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    likeCount = widget.post.likes;
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    try {
      final postComments = await DataService.getPostComments(widget.post.id);
      setState(() {
        comments = postComments;
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Post Image
                    _buildPostImage(),
                    
                    // Post Content
                    _buildPostContent(),
                    
                    // Action Buttons
                    _buildActionButtons(),
                    
                    // Comments Section
                    _buildCommentsSection(),
                  ],
                ),
              ),
            ),
            
            // Comment Input
            _buildCommentInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
              '动态详情',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A4040),
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              // 举报拉黑功能
              _showReportOptions();
            },
            icon: const Icon(
              Icons.more_vert,
              color: Color(0xFF4A4040),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostImage() {
    return Container(
      width: double.infinity,
      height: 400,
      child: Image.network(
        widget.post.imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[200],
            child: const Icon(Icons.error, size: 50),
          );
        },
      ),
    );
  }

  Widget _buildPostContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Info
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: widget.post.userAvatar.startsWith('assets/')
                    ? Image.asset(
                        widget.post.userAvatar,
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
                      )
                    : Image.network(
                        widget.post.userAvatar,
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
                      widget.post.username,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A4040),
                      ),
                    ),
                    Text(
                      _formatTime(widget.post.createdAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9C8E8E),
                      ),
                    ),
                  ],
                ),
              ),
              // Follow Button
              GestureDetector(
                onTap: () {
                  setState(() {
                    isFollowed = !isFollowed;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: isFollowed ? const Color(0xFFF72E1E) : Colors.transparent,
                    border: Border.all(color: const Color(0xFFF72E1E)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isFollowed ? '已关注' : '关注',
                    style: TextStyle(
                      fontSize: 12,
                      color: isFollowed ? Colors.white : const Color(0xFFF72E1E),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Post Title
          Text(
            widget.post.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A4040),
              height: 1.4,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Post Description
          if (widget.post.description.isNotEmpty)
            Text(
              widget.post.description,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF4A4040),
                height: 1.6,
              ),
            ),
          
          const SizedBox(height: 16),
          
          // Tags
          if (widget.post.tags.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.post.tags.map((tag) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF72E1E).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  tag,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFF72E1E),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey[200]!),
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        children: [
          // Like Button
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isLiked ? Icons.favorite : Icons.favorite_outline,
                    color: isLiked ? const Color(0xFFF72E1E) : const Color(0xFF9C8E8E),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatCount(likeCount),
                    style: TextStyle(
                      color: isLiked ? const Color(0xFFF72E1E) : const Color(0xFF9C8E8E),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Comment Button
          Expanded(
            child: GestureDetector(
              onTap: () {
                // 滚动到评论区域
                _scrollToComments();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.chat_bubble_outline,
                    color: Color(0xFF9C8E8E),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${comments.length}',
                    style: const TextStyle(
                      color: Color(0xFF9C8E8E),
                      fontWeight: FontWeight.w600,
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

  Widget _buildCommentsSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '评论 (${comments.length})',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A4040),
            ),
          ),
          
          const SizedBox(height: 16),
          
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else if (comments.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '还没有评论',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '来说点什么吧~',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: comments.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return _buildCommentItem(comments[index]);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(Comment comment) {
    return Row(
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
                      color: Colors.grey[300],
                      child: const Icon(Icons.person, size: 16),
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
                      color: Colors.grey[300],
                      child: const Icon(Icons.person, size: 16),
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
                    _formatTime(comment.createdAt),
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
              const SizedBox(height: 8),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      // 点赞评论
                    },
                    child: Row(
                      children: [
                        const Icon(
                          Icons.favorite_outline,
                          size: 16,
                          color: Color(0xFF9C8E8E),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${comment.likes}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF9C8E8E),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () {
                      // 回复评论
                      _replyToComment(comment);
                    },
                    child: const Text(
                      '回复',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9C8E8E),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _commentController,
                decoration: const InputDecoration(
                  hintText: '说点什么...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: Color(0xFF9C8E8E),
                    fontSize: 14,
                  ),
                ),
                maxLines: null,
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _sendComment,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFFF72E1E),
                shape: BoxShape.circle,
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
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
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

  void _scrollToComments() {
    // 这里可以实现滚动到评论区域的逻辑
  }

  void _sendComment() async {
    if (_commentController.text.trim().isEmpty) return;
    
    final currentUser = await DataService.getCurrentUser();
    final newComment = Comment(
      id: 'comment_${DateTime.now().millisecondsSinceEpoch}',
      postId: widget.post.id,
      userId: currentUser.id,
      username: currentUser.displayName,
      userAvatar: currentUser.avatar,
      content: _commentController.text.trim(),
      createdAt: DateTime.now(),
      likes: 0,
    );
    
    await DataService.addComment(newComment);
    
    setState(() {
      comments.insert(0, newComment);
      _commentController.clear();
    });
  }

  void _replyToComment(Comment comment) {
    _commentController.text = '@${comment.username} ';
  }

  void _showReportOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '举报选项',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildReportOption(Icons.report, '举报内容', '举报不当内容', () {
              Navigator.pop(context);
              _showReportDialog();
            }),
            const SizedBox(height: 8),
            _buildReportOption(Icons.block, '拉黑用户', '不再看到此用户的内容', () {
              Navigator.pop(context);
              _showBlockDialog();
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildReportOption(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: Colors.grey[700]),
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
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('举报内容'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('请选择举报原因：'),
            const SizedBox(height: 16),
            ...[
              '不当内容',
              '垃圾信息',
              '虚假信息',
              '侵犯版权',
              '其他原因',
            ].map((reason) => ListTile(
              title: Text(reason),
              onTap: () {
                Navigator.pop(context);
                _submitReport(reason);
              },
            )).toList(),
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

  void _showBlockDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('拉黑用户'),
        content: Text('确定要拉黑用户 "${widget.post.username}" 吗？\n拉黑后将不再看到该用户的任何内容。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _blockUser();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('确定拉黑'),
          ),
        ],
      ),
    );
  }

  void _submitReport(String reason) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('举报已提交：$reason'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _blockUser() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已拉黑用户：${widget.post.username}'),
        backgroundColor: Colors.orange,
      ),
    );
    // 这里可以添加实际的拉黑逻辑
    Navigator.pop(context);
  }
}