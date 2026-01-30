class Topic {
  final String id;
  final String title;
  final String icon;
  final int participantCount;
  final String color;

  Topic({
    required this.id,
    required this.title,
    required this.icon,
    required this.participantCount,
    this.color = 'red',
  });

  String get formattedCount {
    if (participantCount >= 10000) {
      return '${(participantCount / 10000).toStringAsFixed(1)}w';
    } else if (participantCount >= 1000) {
      return '${(participantCount / 1000).toStringAsFixed(1)}k';
    }
    return participantCount.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'icon': icon,
      'participantCount': participantCount,
      'color': color,
    };
  }

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id: json['id'],
      title: json['title'],
      icon: json['icon'],
      participantCount: json['participantCount'],
      color: json['color'] ?? 'red',
    );
  }
}