/// Notification model matching backend Notification schema
class AppNotification {
  final String id;
  final String notificationId;
  final String title;
  final String description;
  final String? imageUrl;
  final DateTime? createdAt;

  AppNotification({
    required this.id,
    required this.notificationId,
    required this.title,
    required this.description,
    this.imageUrl,
    this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['_id'] ?? json['id'] ?? '',
      notificationId: json['notificationId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }
}
