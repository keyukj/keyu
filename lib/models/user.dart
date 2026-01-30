class User {
  final String id;
  final String username;
  final String displayName;
  final String avatar;
  final String bio;
  final String location;
  final int followers;
  final int following;
  final int totalLikes;
  final List<String> posts;
  final String gender; // 新增：性别
  final int age; // 新增：年龄
  final List<String> interests; // 新增：兴趣爱好
  final String phone; // 新增：手机号
  final String email; // 新增：邮箱

  User({
    required this.id,
    required this.username,
    required this.displayName,
    required this.avatar,
    this.bio = '',
    this.location = '',
    this.followers = 0,
    this.following = 0,
    this.totalLikes = 0,
    this.posts = const [],
    this.gender = 'female',
    this.age = 25,
    this.interests = const [],
    this.phone = '',
    this.email = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'displayName': displayName,
      'avatar': avatar,
      'bio': bio,
      'location': location,
      'followers': followers,
      'following': following,
      'totalLikes': totalLikes,
      'posts': posts,
      'gender': gender,
      'age': age,
      'interests': interests,
      'phone': phone,
      'email': email,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      displayName: json['displayName'],
      avatar: json['avatar'],
      bio: json['bio'] ?? '',
      location: json['location'] ?? '',
      followers: json['followers'] ?? 0,
      following: json['following'] ?? 0,
      totalLikes: json['totalLikes'] ?? 0,
      posts: List<String>.from(json['posts'] ?? []),
      gender: json['gender'] ?? 'female',
      age: json['age'] ?? 25,
      interests: List<String>.from(json['interests'] ?? []),
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
    );
  }

  // 新增：创建用户副本的方法
  User copyWith({
    String? id,
    String? username,
    String? displayName,
    String? avatar,
    String? bio,
    String? location,
    int? followers,
    int? following,
    int? totalLikes,
    List<String>? posts,
    String? gender,
    int? age,
    List<String>? interests,
    String? phone,
    String? email,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      avatar: avatar ?? this.avatar,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      totalLikes: totalLikes ?? this.totalLikes,
      posts: posts ?? this.posts,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      interests: interests ?? this.interests,
      phone: phone ?? this.phone,
      email: email ?? this.email,
    );
  }
}