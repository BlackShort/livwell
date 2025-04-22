import 'package:livwell/app/notification/models/notification_model.dart';
import 'package:livwell/core/services/firestore_service.dart';

class NotificationService {
  final FirestoreService _firebaseService = FirestoreService();
  
  // Get a stream of notifications
  Stream<List<NotificationModel>> getNotificationsStream() {
    return _firebaseService.getNotificationsStream().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return NotificationModel.fromJson(data);
      }).toList();
    });
  }
  
  // Get notifications as a Future
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final docs = await _firebaseService.getNotifications();
      return docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return NotificationModel.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error getting notifications: $e');
      return [];
    }
  }
  
  // Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _firebaseService.markNotificationAsRead(notificationId);
    } catch (e) {
      print('Error marking notification as read: $e');
      rethrow;
    }
  }
  
  // Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firebaseService.deleteNotification(notificationId);
    } catch (e) {
      print('Error deleting notification: $e');
      rethrow;
    }
  }
  
  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      await _firebaseService.markAllNotificationsAsRead();
    } catch (e) {
      print('Error marking all notifications as read: $e');
      rethrow;
    }
  }
  
  // Get icon for notification type
  String getIconForType(NotificationType type) {
    switch (type) {
      case NotificationType.alert:
        return '🚨';
      case NotificationType.warning:
        return '⚠️';
      case NotificationType.reminder:
        return '🔔';
    }
  }
  
  // Get color for notification type
  int getColorForType(NotificationType type) {
    switch (type) {
      case NotificationType.alert:
        return 0xFFE53935; // Red
      case NotificationType.warning:
        return 0xFFFFA000; // Amber
      case NotificationType.reminder:
        return 0xFF43A047; // Green
    }
  }
}