import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/post.dart';
import '../services/data_service.dart';
import 'edit_profile_screen.dart';
import 'post_detail_screen.dart';
import 'webview_screen.dart';

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
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFFFF0F0),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (currentUser == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFFFF0F0),
        body: Center(
          child: Text('用户数据加载失败'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F0),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Cover Image and Profile
            Stack(
              children: [
                // Cover Image
                SizedBox(
                  height: 288,
                  width: double.infinity,
                  child: Image.network(
                    'https://images.unsplash.com/photo-1504609773096-104ff2c73ba4?q=80&w=800&auto=format&fit=crop',
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
                        color: Colors.grey[300],
                        child: const Icon(Icons.landscape, size: 48),
                      );
                    },
                  ),
                ),
                
                // Gradient overlay
                Container(
                  height: 288,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.transparent,
                        Color(0xFFFFF0F0),
                      ],
                    ),
                  ),
                ),
                
                // Settings icon
                Positioned(
                  top: 56,
                  right: 24,
                  child: GestureDetector(
                    onTap: _showSettings,
                    child: const Icon(
                      Icons.settings,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
            
            // Profile Content
            Transform.translate(
              offset: const Offset(0, -64),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Picture and Edit Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(48),
                            border: Border.all(
                              color: const Color(0xFFFFF0F0),
                              width: 4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(48),
                            child: currentUser!.avatar.startsWith('assets/')
                                ? Image.asset(
                                    currentUser!.avatar,
                                    width: 96,
                                    height: 96,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 96,
                                        height: 96,
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.person, size: 48),
                                      );
                                    },
                                  )
                                : Image.network(
                                    currentUser!.avatar,
                                    width: 96,
                                    height: 96,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 96,
                                        height: 96,
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.person, size: 48),
                                      );
                                    },
                                  ),
                          ),
                        ),
                        GestureDetector(
                          onTap: _editProfile,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4A4040),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Text(
                              '编辑资料',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Name and Gender
                    Row(
                      children: [
                        Text(
                          currentUser!.displayName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4A4040),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          currentUser!.gender == 'female' ? Icons.female : Icons.male,
                          color: currentUser!.gender == 'female' ? Colors.pink : Colors.blue,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${currentUser!.age}岁',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF9C8E8E),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Bio and Interests
                    Text(
                      currentUser!.bio,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9C8E8E),
                        height: 1.4,
                      ),
                    ),
                    
                    // Interests
                    if (currentUser!.interests.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: currentUser!.interests.take(5).map((interest) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE5E5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            interest,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFFF72E1E),
                            ),
                          ),
                        )).toList(),
                      ),
                    ],
                    
                    const SizedBox(height: 16),
                    
                    // Stats
                    Row(
                      children: [
                        _buildStatItem(_formatCount(currentUser!.followers), '粉丝'),
                        const SizedBox(width: 32),
                        _buildStatItem(_formatCount(currentUser!.following), '关注'),
                        const SizedBox(width: 32),
                        _buildStatItem(_formatCount(currentUser!.totalLikes), '获赞'),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // 作品内容
                    _buildWorksGrid(),
                    
                    const SizedBox(height: 100), // Bottom padding
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String number, String label) {
    return Column(
      children: [
        Text(
          number,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4A4040),
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF9C8E8E),
          ),
        ),
      ],
    );
  }



  Widget _buildWorksGrid() {
    return Column(
      children: [
        ...userPublishedPosts.map((post) => _buildPostCard(post)),
      ],
    );
  }

  Widget _buildPostCard(Post post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 图片
          GestureDetector(
            onTap: () => _showPostDetail(post),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  post.imageUrl,
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
              ),
            ),
          ),
          
          // 内容
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题
                Text(
                  post.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A4040),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                if (post.description != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    post.description!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9C8E8E),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                
                // 标签
                if (post.tags != null && post.tags!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: post.tags!.take(3).map((tag) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE5E5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFFF72E1E),
                        ),
                      ),
                    )).toList(),
                  ),
                ],
                
                const SizedBox(height: 12),
                
                // 底部信息
                Row(
                  children: [
                    Icon(
                      Icons.favorite,
                      size: 16,
                      color: Colors.red[300],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatCount(post.likes),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9C8E8E),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _formatTime(post.createdAt),
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



  String _formatCount(int count) {
    if (count >= 10000) {
      return '${(count / 10000).toStringAsFixed(1)}W';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
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

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.8,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '设置',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A4040),
                ),
              ),
              const SizedBox(height: 20),
              Flexible(
                child: ListView(
                  controller: scrollController,
                  shrinkWrap: true,
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
      leading: Icon(
        icon, 
        color: isDestructive ? Colors.red : const Color(0xFF4A4040)
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : const Color(0xFF4A4040)
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Color(0xFF9C8E8E)),
      onTap: onTap,
    );
  }

  void _editProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(user: currentUser!),
      ),
    ).then((updatedUser) {
      if (updatedUser != null && updatedUser is User) {
        setState(() {
          currentUser = updatedUser;
        });
      }
    });
  }

  void _showPostDetail(Post post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostDetailScreen(post: post),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            '退出账号',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A4040),
            ),
          ),
          content: const Text(
            '确定要退出当前账号吗？退出后需要重新登录。',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF9C8E8E),
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                '取消',
                style: TextStyle(
                  color: Color(0xFF9C8E8E),
                  fontSize: 14,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 关闭对话框
                _logout();
              },
              child: const Text(
                '退出',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout() async {
    try {
      // 显示加载指示器
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      // 调用数据服务的退出登录方法
      await DataService.logout();

      // 关闭加载指示器
      if (mounted) {
        Navigator.of(context).pop();
      }

      // 显示退出成功提示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('已成功退出账号'),
            backgroundColor: Color(0xFF4A4040),
          ),
        );
      }

      // 跳转到登录页面，清除所有之前的页面
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      }
      
    } catch (e) {
      // 关闭加载指示器
      if (mounted) {
        Navigator.of(context).pop();
      }
      
      // 显示错误提示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('退出失败: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showHelpAndFeedback() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.7,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '帮助与反馈',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A4040),
                ),
              ),
              const SizedBox(height: 20),
              Flexible(
                child: ListView(
                  controller: scrollController,
                  shrinkWrap: true,
                  children: [
                    _buildHelpItem(Icons.quiz, '常见问题', () {
                      _showFAQ();
                    }),
                    _buildHelpItem(Icons.feedback, '意见反馈', () {
                      _showFeedbackDialog();
                    }),
                    _buildHelpItem(Icons.bug_report, '问题报告', () {
                      _showBugReportDialog();
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAboutUs() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/logo.png',
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '探遇',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A4040),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'v1.0.0',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF9C8E8E),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '每一个故事都值得被分享',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF4A4040),
                  height: 1.4,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                '确定',
                style: TextStyle(
                  color: Color(0xFF4A4040),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionItem(IconData icon, String title, VoidCallback onTap, {bool isDestructive = false}) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : const Color(0xFF4A4040),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : const Color(0xFF4A4040),
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Color(0xFF9C8E8E)),
      onTap: onTap,
    );
  }

  Widget _buildHelpItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF4A4040)),
      title: Text(
        title,
        style: const TextStyle(color: Color(0xFF4A4040)),
      ),
      trailing: const Icon(Icons.chevron_right, color: Color(0xFF9C8E8E)),
      onTap: onTap,
    );
  }

  Widget _buildContactItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF9C8E8E),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF4A4040),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            '删除账户',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          content: const Text(
            '删除账户后，您的所有数据将被永久删除且无法恢复。确定要继续吗？',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF9C8E8E),
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                '取消',
                style: TextStyle(
                  color: Color(0xFF9C8E8E),
                  fontSize: 14,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showSnackBar('账户删除功能即将上线');
              },
              child: const Text(
                '确认删除',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showFAQ() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            '常见问题',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A4040),
            ),
          ),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Q: 如何修改个人资料？',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A4040),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'A: 点击个人页面的"编辑资料"按钮即可修改。',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF9C8E8E),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Q: 如何保护我的隐私？',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A4040),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'A: 在设置中的"隐私设置"可以控制个人信息的可见性。',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF9C8E8E),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Q: 如何举报不当内容？',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A4040),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'A: 长按相关内容，选择"举报"选项。',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF9C8E8E),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                '关闭',
                style: TextStyle(
                  color: Color(0xFF4A4040),
                  fontSize: 14,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showFeedbackDialog() {
    final TextEditingController feedbackController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            '意见反馈',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A4040),
            ),
          ),
          content: TextField(
            controller: feedbackController,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: '请输入您的意见或建议...',
              border: OutlineInputBorder(),
              hintStyle: TextStyle(color: Color(0xFF9C8E8E)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                '取消',
                style: TextStyle(
                  color: Color(0xFF9C8E8E),
                  fontSize: 14,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showSnackBar('感谢您的反馈！我们会认真考虑您的建议。');
              },
              child: const Text(
                '提交',
                style: TextStyle(
                  color: Color(0xFF4A4040),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showBugReportDialog() {
    final TextEditingController bugController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            '问题报告',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A4040),
            ),
          ),
          content: TextField(
            controller: bugController,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: '请详细描述您遇到的问题...',
              border: OutlineInputBorder(),
              hintStyle: TextStyle(color: Color(0xFF9C8E8E)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                '取消',
                style: TextStyle(
                  color: Color(0xFF9C8E8E),
                  fontSize: 14,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showSnackBar('问题报告已提交，我们会尽快处理。');
              },
              child: const Text(
                '提交',
                style: TextStyle(
                  color: Color(0xFF4A4040),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF4A4040),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showPrivacyPolicy() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const WebViewScreen(
          url: 'https://sites.google.com/view/tanyuuu/%E9%A6%96%E9%A1%B5',
          title: '隐私协议',
        ),
      ),
    );
  }

  void _showUserAgreement() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const WebViewScreen(
          url: 'https://sites.google.com/view/taaanyuuu/%E9%A6%96%E9%A1%B5',
          title: '用户协议',
        ),
      ),
    );
  }
}