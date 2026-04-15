import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/user.dart';
import '../models/post.dart';
import '../services/data_service.dart';
import 'edit_profile_screen.dart';
import 'post_dynamic_detail_screen.dart';
import 'webview_screen.dart';
import 'wallet_recharge_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? currentUser;
  List<String> userPosts = [];
  List<Post> userPublishedPosts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await DataService.getCurrentUser();
      final posts = await DataService.getUserPosts();
      final publishedPosts = await DataService.getUserPublishedPosts();
      setState(() {
        currentUser = user;
        userPosts = posts;
        userPublishedPosts = publishedPosts;
        isLoading = false;
      });
    } catch (e) {
      setState(() { isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (currentUser == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: Text('用户数据加载失败')),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
            // 顶部背景 + 头像
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
                // 设置按钮
                Positioned(
                  top: MediaQuery.of(context).padding.top + 8,
                  right: 12,
                  child: GestureDetector(
                    onTap: _showSettings,
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.settings, color: Colors.white, size: 18),
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
                      child: ClipOval(
                        child: currentUser!.avatar.startsWith('assets/')
                            ? Image.asset(currentUser!.avatar, width: 90, height: 90, fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => Container(width: 90, height: 90, color: Colors.grey[300], child: const Icon(Icons.person, size: 40)))
                            : Image.network(currentUser!.avatar, width: 90, height: 90, fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => Container(width: 90, height: 90, color: Colors.grey[300], child: const Icon(Icons.person, size: 40))),
                      ),
                    ),
                  ),
                ),
                // 钱包按钮
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: GestureDetector(
                    onTap: _openWallet,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF72E1E),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.account_balance_wallet, color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text('钱包', style: TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w500)),
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
              currentUser!.displayName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
            ),
            const SizedBox(height: 6),
            // 个性签名
            Text(
              currentUser!.bio,
              style: const TextStyle(fontSize: 13, color: Color(0xFF999999)),
            ),
            const SizedBox(height: 20),
            // 关注 / 粉丝 / 获赞
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStat(_formatCount(currentUser!.following), '关注'),
                Container(width: 1, height: 24, color: const Color(0xFFEEEEEE), margin: const EdgeInsets.symmetric(horizontal: 36)),
                _buildStat(_formatCount(currentUser!.followers), '粉丝'),
                Container(width: 1, height: 24, color: const Color(0xFFEEEEEE), margin: const EdgeInsets.symmetric(horizontal: 36)),
                _buildStat(_formatCount(currentUser!.totalLikes), '获赞'),
              ],
            ),
            const SizedBox(height: 24),
            // 作品标题
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Image.asset('assets/images/imggrbt.png', height: 28),
              ),
            ),
            const SizedBox(height: 12),
            // 作品列表
            if (userPublishedPosts.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Text('暂无作品', style: TextStyle(fontSize: 14, color: Color(0xFF999999))),
              )
            else
              ...userPublishedPosts.map((post) => _buildPostCard(post)),
            const SizedBox(height: 100),
          ],
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

  Widget _buildPostCard(Post post) {
    final imgSize = MediaQuery.of(context).size.width * 0.38;
    return GestureDetector(
      onTap: () => _showPostDetail(post),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 头像 + 昵称 + 时间
            Row(
              children: [
                ClipOval(
                  child: currentUser!.avatar.startsWith('assets/')
                      ? Image.asset(currentUser!.avatar, width: 36, height: 36, fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(width: 36, height: 36, color: Colors.grey[300]))
                      : Image.network(currentUser!.avatar, width: 36, height: 36, fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(width: 36, height: 36, color: Colors.grey[300])),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(currentUser!.displayName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A))),
                    Text(_formatTime(post.createdAt), style: const TextStyle(fontSize: 11, color: Color(0xFF999999))),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            // 正文
            Text(post.description ?? post.title, style: const TextStyle(fontSize: 14, color: Color(0xFF333333), height: 1.6)),
            const SizedBox(height: 10),
            // 图片
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: post.imageUrl.startsWith('http')
                ? Image.network(post.imageUrl, width: imgSize, height: imgSize, fit: BoxFit.cover,
                    loadingBuilder: (c, child, p) => p == null ? child : Container(width: imgSize, height: imgSize, color: const Color(0xFFEEEEEE)),
                    errorBuilder: (c, e, s) => Container(width: imgSize, height: imgSize, color: const Color(0xFFEEEEEE)),
                  )
                : Image.asset(post.imageUrl, width: imgSize, height: imgSize, fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(width: imgSize, height: imgSize, color: const Color(0xFFEEEEEE)),
                  ),
            ),
            const SizedBox(height: 10),
            // 底部操作
            Row(
              children: [
                GestureDetector(
                  onTap: () => _showDeleteDialog(context, post),
                  child: const Row(
                    children: [
                      Icon(Icons.delete_outline, size: 16, color: Color(0xFF999999)),
                      SizedBox(width: 4),
                      Text('删除', style: TextStyle(fontSize: 12, color: Color(0xFF999999))),
                    ],
                  ),
                ),
                const Spacer(),
                const Icon(Icons.favorite_border, size: 16, color: Color(0xFF999999)),
                const SizedBox(width: 4),
                Text(_formatCount(post.likes), style: const TextStyle(fontSize: 12, color: Color(0xFF999999))),
                const SizedBox(width: 20),
                const Icon(Icons.chat_bubble_outline, size: 16, color: Color(0xFF999999)),
                const SizedBox(width: 4),
                const Text('0', style: TextStyle(fontSize: 12, color: Color(0xFF999999))),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, thickness: 0.5, color: Color(0xFFF0F0F0)),
          ],
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 10000) return '${(count / 10000).toStringAsFixed(1)}W';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    if (difference.inDays > 0) return '${difference.inDays}天前';
    if (difference.inHours > 0) return '${difference.inHours}小时前';
    if (difference.inMinutes > 0) return '${difference.inMinutes}分钟前';
    return '刚刚';
  }

  void _showDeleteDialog(BuildContext ctx, Post post) {
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
              setState(() { userPublishedPosts.remove(post); });
              ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('动态已删除')));
            },
            child: const Text('删除', style: TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _openWallet() {
    HapticFeedback.lightImpact();
    Navigator.push(context, MaterialPageRoute(builder: (context) => const WalletRechargeScreen()));
  }

  void _showPostDetail(Post post) {
    final postMap = <String, dynamic>{
      'avatar': currentUser!.avatar,
      'nickname': currentUser!.displayName,
      'time': _formatTime(post.createdAt),
      'location': currentUser!.location,
      'content': post.description.isNotEmpty ? post.description : post.title,
      'images': [post.imageUrl],
      'likes': post.likes,
      'comments': 0,
    };
    Navigator.push(context, MaterialPageRoute(builder: (context) => PostDynamicDetailScreen(post: postMap, isMine: true)));
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6, minChildSize: 0.4, maxChildSize: 0.8, expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 20),
              const Text('设置', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4A4040))),
              const SizedBox(height: 20),
              Flexible(
                child: ListView(
                  controller: scrollController, shrinkWrap: true,
                  children: [
                    _buildSettingItem(Icons.edit, '编辑资料', _editProfile),
                    _buildSettingItem(Icons.help, '帮助与反馈', _showHelpAndFeedback),
                    _buildSettingItem(Icons.info, '关于我们', _showAboutUs),
                    _buildSettingItem(Icons.privacy_tip, '隐私协议', _showPrivacyPolicy),
                    _buildSettingItem(Icons.description, '用户协议', _showUserAgreement),
                    const Divider(height: 32, color: Color(0xFFE0E0E0)),
                    _buildSettingItem(Icons.logout, '退出账号', _showLogoutDialog, isDestructive: true),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String title, VoidCallback onTap, {bool isDestructive = false}) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.red : const Color(0xFF4A4040)),
      title: Text(title, style: TextStyle(color: isDestructive ? Colors.red : const Color(0xFF4A4040))),
      trailing: const Icon(Icons.chevron_right, color: Color(0xFF9C8E8E)),
      onTap: onTap,
    );
  }

  void _editProfile() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfileScreen(user: currentUser!))).then((updatedUser) {
      if (updatedUser != null && updatedUser is User) {
        setState(() { currentUser = updatedUser; });
      }
    });
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('退出账号', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4A4040))),
        content: const Text('确定要退出当前账号吗？退出后需要重新登录。', style: TextStyle(fontSize: 14, color: Color(0xFF9C8E8E), height: 1.4)),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('取消', style: TextStyle(color: Color(0xFF9C8E8E), fontSize: 14))),
          TextButton(onPressed: () { Navigator.of(context).pop(); _logout(); }, child: const Text('退出', style: TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    try {
      showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator()));
      await DataService.logout();
      if (mounted) Navigator.of(context).pop();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已成功退出账号'), backgroundColor: Color(0xFF4A4040)));
      }
      if (mounted) Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('退出失败: ${e.toString()}'), backgroundColor: Colors.red));
      }
    }
  }

  void _showHelpAndFeedback() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5, minChildSize: 0.3, maxChildSize: 0.7, expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 20),
              const Text('帮助与反馈', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4A4040))),
              const SizedBox(height: 20),
              Flexible(
                child: ListView(controller: scrollController, shrinkWrap: true, children: [
                  _buildHelpItem(Icons.quiz, '常见问题', _showFAQ),
                  _buildHelpItem(Icons.feedback, '意见反馈', _showFeedbackDialog),
                  _buildHelpItem(Icons.bug_report, '问题报告', _showBugReportDialog),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHelpItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF4A4040)),
      title: Text(title, style: const TextStyle(color: Color(0xFF4A4040))),
      trailing: const Icon(Icons.chevron_right, color: Color(0xFF9C8E8E)),
      onTap: onTap,
    );
  }

  void _showAboutUs() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.asset('assets/logo.png', width: 80, height: 80, fit: BoxFit.cover)),
            const SizedBox(height: 16),
            const Text('彼趣', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF4A4040))),
            const SizedBox(height: 8),
            const Text('v1.0.0', style: TextStyle(fontSize: 16, color: Color(0xFF9C8E8E))),
            const SizedBox(height: 16),
            const Text('每一个故事都值得被分享', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Color(0xFF4A4040), height: 1.4)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('确定', style: TextStyle(color: Color(0xFF4A4040), fontSize: 16, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const WebViewScreen(url: 'https://sites.google.com/view/tanyuuu/%E9%A6%96%E9%A1%B5', title: '隐私协议')));
  }

  void _showUserAgreement() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const WebViewScreen(url: 'https://sites.google.com/view/taaanyuuu/%E9%A6%96%E9%A1%B5', title: '用户协议')));
  }

  void _showFAQ() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('常见问题', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4A4040))),
        content: const SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Text('Q: 如何修改个人资料？', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF4A4040))),
            SizedBox(height: 4),
            Text('A: 点击个人页面的"编辑资料"按钮即可修改。', style: TextStyle(fontSize: 14, color: Color(0xFF9C8E8E))),
            SizedBox(height: 16),
            Text('Q: 如何保护我的隐私？', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF4A4040))),
            SizedBox(height: 4),
            Text('A: 在设置中的"隐私设置"可以控制个人信息的可见性。', style: TextStyle(fontSize: 14, color: Color(0xFF9C8E8E))),
            SizedBox(height: 16),
            Text('Q: 如何举报不当内容？', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF4A4040))),
            SizedBox(height: 4),
            Text('A: 长按相关内容，选择"举报"选项。', style: TextStyle(fontSize: 14, color: Color(0xFF9C8E8E))),
          ]),
        ),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('关闭', style: TextStyle(color: Color(0xFF4A4040), fontSize: 14)))],
      ),
    );
  }

  void _showFeedbackDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('意见反馈', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4A4040))),
        content: TextField(controller: controller, maxLines: 5, decoration: const InputDecoration(hintText: '请输入您的意见或建议...', border: OutlineInputBorder(), hintStyle: TextStyle(color: Color(0xFF9C8E8E)))),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('取消', style: TextStyle(color: Color(0xFF9C8E8E), fontSize: 14))),
          TextButton(onPressed: () { Navigator.of(context).pop(); _showSnackBar('感谢您的反馈！'); }, child: const Text('提交', style: TextStyle(color: Color(0xFF4A4040), fontSize: 14, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  void _showBugReportDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('问题报告', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4A4040))),
        content: TextField(controller: controller, maxLines: 5, decoration: const InputDecoration(hintText: '请详细描述您遇到的问题...', border: OutlineInputBorder(), hintStyle: TextStyle(color: Color(0xFF9C8E8E)))),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('取消', style: TextStyle(color: Color(0xFF9C8E8E), fontSize: 14))),
          TextButton(onPressed: () { Navigator.of(context).pop(); _showSnackBar('问题报告已提交'); }, child: const Text('提交', style: TextStyle(color: Color(0xFF4A4040), fontSize: 14, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: const Color(0xFF4A4040), duration: const Duration(seconds: 2)));
  }
}
