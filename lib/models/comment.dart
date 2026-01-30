class Comment {
  final String id;
  final String postId;
  final String userId;
  final String username;
  final String userAvatar;
  final String content;
  final DateTime createdAt;
  final int likes;
  final List<Comment> replies;

  Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.username,
    required this.userAvatar,
    required this.content,
    required this.createdAt,
    this.likes = 0,
    this.replies = const [],
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      postId: json['postId'],
      userId: json['userId'],
      username: json['username'],
      userAvatar: json['userAvatar'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
      likes: json['likes'] ?? 0,
      replies: (json['replies'] as List<dynamic>?)
          ?.map((reply) => Comment.fromJson(reply))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'userId': userId,
      'username': username,
      'userAvatar': userAvatar,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'likes': likes,
      'replies': replies.map((reply) => reply.toJson()).toList(),
    };
  }
}