class Post {
  final String id;
  final String imageUrl;
  final String title;
  final String username;
  final String userAvatar;
  final int likes;
  final List<String> tags;
  final String description;
  final DateTime createdAt;

  Post({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.username,
    required this.userAvatar,
    required this.likes,
    this.tags = const [],
    this.description = '',
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'title': title,
      'username': username,
      'userAvatar': userAvatar,
      'likes': likes,
      'tags': tags,
      'description': description,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      imageUrl: json['imageUrl'],
      title: json['title'],
      username: json['username'],
      userAvatar: json['userAvatar'],
      likes: json['likes'],
      tags: List<String>.from(json['tags'] ?? []),
      description: json['description'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
    );
  }
}