import 'package:flutter/material.dart';
import '../widgets/avatar_widget.dart';
import '../widgets/report_dialog.dart';
import 'post_dynamic_detail_screen.dart';

class UserProfileScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  final List<Map<String, dynamic>> posts;

  const UserProfileScreen({super.key, required this.user, this.posts = const []});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool _isFollowed = false;

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final posts = widget.posts;
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 顶部渐变背景 + 头像
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(minHeight: 160),
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/imggrbg.jpg'),
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Container(),
                  ),
                ),
                // 返回按钮
                Positioned(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 12,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 16),
                    ),
                  ),
                ),
                // 头像
                Positioned(
                  bottom: 15,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                      ),
                      child: AvatarWidget(
                        imageUrl: user['avatar'],
                        name: user['nickname'],
                        size: 90,
                      ),
                    ),
                  ),
                ),
                // 关注按钮
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: GestureDetector(
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
                ),
              ],
            ),
            const SizedBox(height: 4),
            // 昵称
            Text(
              user['nickname'] ?? '用户昵称',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
            ),
            const SizedBox(height: 6),
            // 个性签名
            Text(
              user['bio'] ?? '用户的个性签名',
              style: const TextStyle(fontSize: 13, color: Color(0xFF999999)),
            ),
            const SizedBox(height: 20),
            // 关注 / 粉丝 / 点赞
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStat('${user['following'] ?? 12}', '关注'),
                Container(width: 1, height: 24, color: const Color(0xFFEEEEEE), margin: const EdgeInsets.symmetric(horizontal: 36)),
                _buildStat('${user['followers'] ?? 8}', '粉丝'),
                Container(width: 1, height: 24, color: const Color(0xFFEEEEEE), margin: const EdgeInsets.symmetric(horizontal: 36)),
                _buildStat('${user['totalLikes'] ?? 156}', '获赞'),
              ],
            ),
            const SizedBox(height: 24),
            // 动态标题
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Image.asset('assets/images/imggrbt.png', height: 28),
              ),
            ),
            const SizedBox(height: 12),
            // 动态列表
            if (posts.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Text('暂无动态', style: TextStyle(fontSize: 14, color: Color(0xFF999999))),
              )
            else
              ...posts.map((post) => _buildPostItem(context, post)),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String count, String label) {
    return Column(
      children: [
        Text(count, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF999999))),
      ],
    );
  }

  Widget _buildPostItem(BuildContext context, Map<String, dynamic> post) {
    final images = (post['images'] as List<String>?) ?? [];
    final imgSize = MediaQuery.of(context).size.width * 0.38;

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => PostDynamicDetailScreen(post: post),
        ));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 头像 + 昵称 + 时间
            Row(
              children: [
                AvatarWidget(imageUrl: post['avatar'], name: post['nickname'] ?? '', size: 36),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post['nickname'] ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A))),
                    Text(post['time'] ?? '', style: const TextStyle(fontSize: 11, color: Color(0xFF999999))),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            // 正文
            Text(post['content'] ?? '', style: const TextStyle(fontSize: 14, color: Color(0xFF333333), height: 1.6)),
            const SizedBox(height: 10),
            // 图片
            if (images.length == 1)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildImg(images[0], width: imgSize, height: imgSize),
              )
            else if (images.length >= 2)
              Row(
                children: [
                  SizedBox(width: imgSize, height: imgSize, child: ClipRRect(borderRadius: BorderRadius.circular(8),
                    child: _buildImg(images[0]),
                  )),
                  const SizedBox(width: 8),
                  SizedBox(width: imgSize, height: imgSize, child: ClipRRect(borderRadius: BorderRadius.circular(8),
                    child: _buildImg(images[1]),
                  )),
                ],
              ),
            if (images.isNotEmpty) const SizedBox(height: 8),
            // 定位
            if (post['location'] != null)
              Row(
                children: [
                  const Icon(Icons.location_on, size: 13, color: Color(0xFFF72E1E)),
                  const SizedBox(width: 2),
                  Text(post['location'], style: const TextStyle(fontSize: 12, color: Color(0xFF1A1A1A), fontWeight: FontWeight.w500)),
                ],
              ),
            const SizedBox(height: 10),
            // 底部操作
            Row(
              children: [
                GestureDetector(
                  onTap: () => _showMoreActions(context),
                  child: const Icon(Icons.more_horiz, size: 20, color: Color(0xFF999999)),
                ),
                const Spacer(),
                const Icon(Icons.favorite_border, size: 16, color: Color(0xFF999999)),
                const SizedBox(width: 4),
                Text('${post['likes'] ?? 0}', style: const TextStyle(fontSize: 12, color: Color(0xFF999999))),
                const SizedBox(width: 20),
                const Icon(Icons.chat_bubble_outline, size: 16, color: Color(0xFF999999)),
                const SizedBox(width: 4),
                Text('${post['comments'] ?? 0}', style: const TextStyle(fontSize: 12, color: Color(0xFF999999))),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, thickness: 0.5, color: Color(0xFFF0F0F0)),
          ],
        ),
      ),
    );
  }

  Widget _buildImg(String url, {double? width, double? height}) {
    if (url.startsWith('http')) {
      return Image.network(url, width: width, height: height, fit: BoxFit.cover,
        loadingBuilder: (c, child, p) => p == null ? child : Container(width: width, height: height, color: const Color(0xFFEEEEEE)),
        errorBuilder: (c, e, s) => Container(width: width, height: height, color: const Color(0xFFEEEEEE)),
      );
    }
    return Image.asset(url, width: width, height: height, fit: BoxFit.cover,
      errorBuilder: (c, e, s) => Container(width: width, height: height, color: const Color(0xFFEEEEEE)),
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
}
