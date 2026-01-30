class Article {
  final String id;
  final String title;
  final String content;
  final String coverImage;
  final String authorName;
  final String authorAvatar;
  final int views;
  final int readTime;
  final DateTime publishedAt;

  Article({
    required this.id,
    required this.title,
    required this.content,
    required this.coverImage,
    required this.authorName,
    required this.authorAvatar,
    required this.views,
    required this.readTime,
    required this.publishedAt,
  });

  String get formattedViews {
    if (views >= 10000) {
      return '${(views / 10000).toStringAsFixed(1)}w';
    } else if (views >= 1000) {
      return '${(views / 1000).toStringAsFixed(1)}k';
    }
    return views.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'coverImage': coverImage,
      'authorName': authorName,
      'authorAvatar': authorAvatar,
      'views': views,
      'readTime': readTime,
      'publishedAt': publishedAt.millisecondsSinceEpoch,
    };
  }

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      coverImage: json['coverImage'],
      authorName: json['authorName'],
      authorAvatar: json['authorAvatar'],
      views: json['views'],
      readTime: json['readTime'],
      publishedAt: DateTime.fromMillisecondsSinceEpoch(json['publishedAt']),
    );
  }
}