enum NotificationType { alert, warning, reminder }

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final NotificationType type;
  final bool isRead;
  final Map<String, dynamic>? additionalData;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    this.isRead = false,
    this.additionalData,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      timestamp: json['timestamp'] != null
          ? (json['timestamp'] is DateTime
              ? json['timestamp']
              : DateTime.parse(json['timestamp'].toDate().toString()))
          : DateTime.now(),
      type: _getNotificationType(json['type'] ?? 'reminder'),
      isRead: json['isRead'] ?? false,
      additionalData: json['additionalData'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'timestamp': timestamp,
      'type': type.toString().split('.').last,
      'isRead': isRead,
      'additionalData': additionalData,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? timestamp,
    NotificationType? type,
    bool? isRead,
    Map<String, dynamic>? additionalData,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      additionalData: additionalData ?? this.additionalData,
    );
  }

  static NotificationType _getNotificationType(String type) {
    switch (type.toLowerCase()) {
      case 'alert':
        return NotificationType.alert;
      case 'warning':
        return NotificationType.warning;
      case 'reminder':
      default:
        return NotificationType.reminder;
    }
  }
}