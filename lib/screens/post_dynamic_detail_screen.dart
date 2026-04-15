import 'package:flutter/material.dart';
import '../widgets/avatar_widget.dart';
import '../widgets/report_dialog.dart';
import '../services/data_service.dart';

class PostDynamicDetailScreen extends StatefulWidget {
  final Map<String, dynamic> post;
  final bool isMine;
  const PostDynamicDetailScreen({super.key, required this.post, this.isMine = false});

  @override
  State<PostDynamicDetailScreen> createState() => _PostDynamicDetailScreenState();
}

class _PostDynamicDetailScreenState extends State<PostDynamicDetailScreen> {
  bool _isLiked = false;
  bool _isFollowed = false;
  late int _likeCount;
  String _myAvatar = '';
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocus = FocusNode();

  final List<Map<String, dynamic>> _comments = [];

  @override
  void initState() {
    super.initState();
    _likeCount = widget.post['likes'] as int;
    // 从 post 数据加载评论
    final commentList = widget.post['commentList'] as List<dynamic>?;
    if (commentList != null) {
      for (final c in commentList) {
        _comments.add(Map<String, dynamic>.from(c as Map));
      }
    }
    _loadMyAvatar();
  }

  Future<void> _loadMyAvatar() async {
    try {
      final user = await DataService.getCurrentUser();
      setState(() { _myAvatar = user.avatar; });
    } catch (_) {}
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocus.dispose();
    super.dispose();
  }

  void _submitComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _comments.insert(0, {'name': '我', 'avatar': _myAvatar, 'text': text, 'time': '刚刚'});
      _commentController.clear();
    });
    _commentFocus.unfocus();
  }

  void _showDeleteConfirm(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('删除动态', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
        content: const Text('确定要删除这条动态吗？删除后无法恢复。', style: TextStyle(fontSize: 14, color: Color(0xFF999999), height: 1.4)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消', style: TextStyle(color: Color(0xFF999999), fontSize: 14))),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('动态已删除')));
            },
            child: const Text('删除', style: TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showMoreActions(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.flag_outlined, color: Color(0xFFF72E1E)),
              title: const Text('举报', style: TextStyle(fontSize: 15, color: Color(0xFF1A1A1A))),
              onTap: () { Navigator.pop(context); showReportDialog(ctx); },
            ),
            ListTile(
              leading: const Icon(Icons.block, color: Color(0xFF1A1A1A)),
              title: const Text('拉黑', style: TextStyle(fontSize: 15, color: Color(0xFF1A1A1A))),
              onTap: () { Navigator.pop(context); ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('已拉黑该用户'))); },
            ),
            ListTile(
              leading: const Icon(Icons.visibility_off, color: Color(0xFF1A1A1A)),
              title: const Text('屏蔽', style: TextStyle(fontSize: 15, color: Color(0xFF1A1A1A))),
              onTap: () { Navigator.pop(context); ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('已屏蔽该用户内容'))); },
            ),
            const SizedBox(height: 8),
            ListTile(
              title: const Text('取消', textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: Color(0xFF999999))),
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final images = post['images'] as List<String>;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1A1A1A), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('动态详情', style: TextStyle(fontSize: 17, color: Color(0xFF1A1A1A), fontWeight: FontWeight.w600)),
        centerTitle: true,
        actions: [
          widget.isMine
            ? IconButton(
                icon: const Icon(Icons.delete_outline, color: Color(0xFF1A1A1A), size: 22),
                onPressed: () => _showDeleteConfirm(context),
              )
            : IconButton(
                icon: const Icon(Icons.more_horiz, color: Color(0xFF1A1A1A), size: 22),
                onPressed: () => _showMoreActions(context),
              ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 作者信息
              Row(
                children: [
                  AvatarWidget(imageUrl: post['avatar'], name: post['nickname'], size: 44),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(post['nickname'], style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A))),
                        const SizedBox(height: 2),
                        Text(post['time'], style: const TextStyle(fontSize: 12, color: Color(0xFF999999))),
                      ],
                    ),
                  ),
                  // 关注按钮
                  GestureDetector(
                    onTap: () { setState(() { _isFollowed = !_isFollowed; }); },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: _isFollowed ? const Color(0xFFF5F5F5) : const Color(0xFFF72E1E),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!_isFollowed) const Icon(Icons.add, color: Colors.white, size: 16),
                          if (!_isFollowed) const SizedBox(width: 2),
                          Text(_isFollowed ? '已关注' : '关注', style: TextStyle(fontSize: 13, color: _isFollowed ? const Color(0xFF999999) : Colors.white, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // 正文
              Text(post['content'], style: const TextStyle(fontSize: 16, color: Color(0xFF333333), height: 1.7)),
              const SizedBox(height: 16),
              // 图片并排展示
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: images.map((url) {
                  final imgSize = (MediaQuery.of(context).size.width - 40 - 8) / 2;
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: url.startsWith('http')
                      ? Image.network(url,
                          width: imgSize, height: imgSize, fit: BoxFit.cover,
                          loadingBuilder: (c, child, p) => p == null ? child : Container(width: imgSize, height: imgSize, color: const Color(0xFFEEEEEE)),
                          errorBuilder: (c, e, s) => Container(width: imgSize, height: imgSize, color: const Color(0xFFEEEEEE)),
                        )
                      : Image.asset(url,
                          width: imgSize, height: imgSize, fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(width: imgSize, height: imgSize, color: const Color(0xFFEEEEEE)),
                        ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              // 定位
              Row(
                children: [
                  const Icon(Icons.location_on, size: 14, color: Color(0xFFF72E1E)),
                  const SizedBox(width: 2),
                  Text(post['location'], style: const TextStyle(fontSize: 13, color: Color(0xFF1A1A1A), fontWeight: FontWeight.w500)),
                ],
              ),
              const SizedBox(height: 24),
              // 评论区标题
              Text('评论 ${_comments.length}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
              const SizedBox(height: 16),
              // 评论列表
              ..._comments.map((c) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AvatarWidget(imageUrl: c['avatar']?.toString(), name: c['name']?.toString() ?? '', size: 32),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(c['name']?.toString() ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A))),
                              const SizedBox(width: 8),
                              Text(c['time']?.toString() ?? '', style: const TextStyle(fontSize: 11, color: Color(0xFF999999))),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(c['text']?.toString() ?? '', style: const TextStyle(fontSize: 14, color: Color(0xFF333333), height: 1.5)),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      // 底部评论输入栏
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(left: 16, right: 16, top: 10, bottom: MediaQuery.of(context).padding.bottom + 10),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFF0F0F0))),
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  controller: _commentController,
                  focusNode: _commentFocus,
                  style: const TextStyle(fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: '写评论...',
                    hintStyle: TextStyle(fontSize: 14, color: Color(0xFF999999)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    isDense: true,
                  ),
                  onSubmitted: (_) => _submitComment(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // 点赞按钮
            GestureDetector(
              onTap: () {
                setState(() {
                  _isLiked = !_isLiked;
                  _likeCount += _isLiked ? 1 : -1;
                });
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isLiked ? Icons.favorite : Icons.favorite_border,
                    size: 24,
                    color: _isLiked ? const Color(0xFFF72E1E) : const Color(0xFF999999),
                  ),
                  Text(
                    '$_likeCount',
                    style: TextStyle(fontSize: 10, color: _isLiked ? const Color(0xFFF72E1E) : const Color(0xFF999999)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: _submitComment,
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF72E1E),
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: const Text('发送', style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
