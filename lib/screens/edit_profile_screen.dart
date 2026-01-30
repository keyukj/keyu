import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/data_service.dart';

class EditProfileScreen extends StatefulWidget {
  final User user;

  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _displayNameController;
  late TextEditingController _bioController;
  late TextEditingController _locationController;
  
  String _selectedGender = 'female';
  int _selectedAge = 25;
  List<String> _selectedInterests = [];
  String _selectedAvatar = '';
  
  // 预设头像选项 - 全部为亚洲人
  final List<String> _avatarOptions = [
    'assets/img/头像女2.jpg', // 本地头像女2 - 替换第一张头像
    'assets/img/头像女1.jpg', // 本地头像女1 - 替换第1排第2张头像
    'assets/img/头像女3.jpg', // 本地头像女3 - 替换第1排第3张头像
    'assets/img/头像男2.jpg', // 本地头像男2 - 替换第2排第1张头像
    'assets/img/头像男1.jpg', // 本地头像男1 - 替换第2排第2张头像
    'assets/img/头像男3.jpg', // 本地头像男3 - 替换第2排第3张头像
  ];
  
  // 兴趣爱好选项
  final List<String> _interestOptions = [
    '摄影', '旅行', '美食', '咖啡', '电影', '音乐', 
    '阅读', '运动', '绘画', '舞蹈', '游戏', '购物',
    '瑜伽', '健身', '烘焙', '园艺', '宠物', '时尚',
    '科技', '艺术', '历史', '文学', '设计', '手工'
  ];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _displayNameController = TextEditingController(text: widget.user.displayName);
    _bioController = TextEditingController(text: widget.user.bio);
    _locationController = TextEditingController(text: widget.user.location);
    
    _selectedGender = widget.user.gender;
    _selectedAge = widget.user.age;
    _selectedInterests = List.from(widget.user.interests);
    _selectedAvatar = widget.user.avatar;
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF4A4040)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '编辑资料',
          style: TextStyle(
            color: Color(0xFF4A4040),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: Text(
              '保存',
              style: TextStyle(
                color: _isLoading ? Colors.grey : const Color(0xFFF72E1E),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAvatarSection(),
                  const SizedBox(height: 30),
                  _buildBasicInfoSection(),
                  const SizedBox(height: 30),
                  _buildPersonalInfoSection(),
                  const SizedBox(height: 30),
                  _buildInterestsSection(),
                  const SizedBox(height: 50),
                ],
              ),
            ),
    );
  }

  Widget _buildAvatarSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '头像',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4A4040),
          ),
        ),
        const SizedBox(height: 15),
        Center(
          child: GestureDetector(
            onTap: _showAvatarPicker,
            child: Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      color: const Color(0xFFF72E1E),
                      width: 3,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: _selectedAvatar.startsWith('assets/')
                        ? Image.asset(
                            _selectedAvatar,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.person, size: 50),
                              );
                            },
                          )
                        : Image.network(
                            _selectedAvatar,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.person, size: 50),
                              );
                            },
                          ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF72E1E),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '基本信息',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4A4040),
          ),
        ),
        const SizedBox(height: 15),
        _buildTextField('昵称', _displayNameController, '请输入昵称'),
        const SizedBox(height: 15),
        _buildTextField('个人简介', _bioController, '介绍一下自己吧', maxLines: 3),
        const SizedBox(height: 15),
        _buildTextField('所在地', _locationController, '请输入所在城市'),
      ],
    );
  }

  Widget _buildPersonalInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '个人信息',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4A4040),
          ),
        ),
        const SizedBox(height: 15),
        _buildGenderSelector(),
        const SizedBox(height: 15),
        _buildAgeSelector(),
      ],
    );
  }

  Widget _buildInterestsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '兴趣爱好',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4A4040),
          ),
        ),
        const SizedBox(height: 15),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _interestOptions.map((interest) {
            final isSelected = _selectedInterests.contains(interest);
            return GestureDetector(
              onTap: () => _toggleInterest(interest),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFF72E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? const Color(0xFFF72E1E) : Colors.grey[300]!,
                  ),
                ),
                child: Text(
                  interest,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF4A4040),
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }



  Widget _buildTextField(String label, TextEditingController controller, String hint, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF4A4040),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFF72E1E)),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '性别',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF4A4040),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedGender = 'female'),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _selectedGender == 'female' ? const Color(0xFFF72E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedGender == 'female' ? const Color(0xFFF72E1E) : Colors.grey[300]!,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.female,
                        color: _selectedGender == 'female' ? Colors.white : Colors.pink,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '女',
                        style: TextStyle(
                          color: _selectedGender == 'female' ? Colors.white : const Color(0xFF4A4040),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedGender = 'male'),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _selectedGender == 'male' ? const Color(0xFFF72E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedGender == 'male' ? const Color(0xFFF72E1E) : Colors.grey[300]!,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.male,
                        color: _selectedGender == 'male' ? Colors.white : Colors.blue,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '男',
                        style: TextStyle(
                          color: _selectedGender == 'male' ? Colors.white : const Color(0xFF4A4040),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAgeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '年龄',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF4A4040),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _showAgePicker,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$_selectedAge 岁',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF4A4040),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.grey[600],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showAvatarPicker() {
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
              '选择头像',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A4040),
              ),
            ),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
              ),
              itemCount: _avatarOptions.length,
              itemBuilder: (context, index) {
                final avatar = _avatarOptions[index];
                final isSelected = avatar == _selectedAvatar;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedAvatar = avatar;
                    });
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                        color: isSelected ? const Color(0xFFF72E1E) : Colors.grey[300]!,
                        width: isSelected ? 3 : 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: avatar.startsWith('assets/')
                          ? Image.asset(
                              avatar,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.person),
                                );
                              },
                            )
                          : Image.network(
                              avatar,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.person),
                                );
                              },
                            ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showAgePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        height: 300,
        padding: const EdgeInsets.all(20),
        child: Column(
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
              '选择年龄',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A4040),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: 83, // 18-100岁
                itemBuilder: (context, index) {
                  final age = index + 18;
                  final isSelected = age == _selectedAge;
                  return ListTile(
                    title: Text(
                      '$age 岁',
                      style: TextStyle(
                        color: isSelected ? const Color(0xFFF72E1E) : const Color(0xFF4A4040),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    trailing: isSelected ? const Icon(Icons.check, color: Color(0xFFF72E1E)) : null,
                    onTap: () {
                      setState(() {
                        _selectedAge = age;
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleInterest(String interest) {
    setState(() {
      if (_selectedInterests.contains(interest)) {
        _selectedInterests.remove(interest);
      } else {
        if (_selectedInterests.length < 10) { // 限制最多选择10个兴趣
          _selectedInterests.add(interest);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('最多只能选择10个兴趣爱好')),
          );
        }
      }
    });
  }

  Future<void> _saveProfile() async {
    if (_displayNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入昵称')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 创建更新后的用户对象
      final updatedUser = widget.user.copyWith(
        displayName: _displayNameController.text.trim(),
        bio: _bioController.text.trim(),
        location: _locationController.text.trim(),
        gender: _selectedGender,
        age: _selectedAge,
        interests: _selectedInterests,
        avatar: _selectedAvatar,
      );

      // 保存到本地存储
      await DataService.saveCurrentUser(updatedUser);

      // 显示成功消息
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('资料保存成功'),
            backgroundColor: Color(0xFFF72E1E),
          ),
        );
        
        // 返回更新后的用户数据
        Navigator.pop(context, updatedUser);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('保存失败，请重试')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}