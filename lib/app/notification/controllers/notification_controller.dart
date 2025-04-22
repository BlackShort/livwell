import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:livwell/app/notification/models/notification_model.dart';
import 'package:livwell/core/services/notification_service.dart';

class NotificationController extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  
  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;
  
  StreamSubscription? _notificationSubscription;
  
  NotificationController() {
    _initNotifications();
  }
  
  void _initNotifications() {
    _isLoading = true;
    _hasError = false;
    notifyListeners();
    
    try {
      _notificationSubscription = _notificationService.getNotificationsStream().listen(
        (notifications) {
          _notifications = notifications;
          _isLoading = false;
          notifyListeners();
        },
        onError: (error) {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Failed to load notifications: $error';
          notifyListeners();
        }
      );
    } catch (e) {
      _isLoading = false;
      _hasError = true;
      _errorMessage = 'Failed to initialize notifications: $e';
      notifyListeners();
    }
  }
  
  Future<void> refreshNotifications() async {
    _isLoading = true;
    _hasError = false;
    notifyListeners();
    
    try {
      _notifications = await _notificationService.getNotifications();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _hasError = true;
      _errorMessage = 'Failed to refresh notifications: $e';
      notifyListeners();
    }
  }
  
  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationService.markAsRead(notificationId);
      
      // Update local state
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        notifyListeners();
      }
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }
  
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _notificationService.deleteNotification(notificationId);
      
      // Update local state
      _notifications.removeWhere((n) => n.id == notificationId);
      notifyListeners();
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }
  
  Future<void> markAllAsRead() async {
    try {
      await _notificationService.markAllAsRead();
      
      // Update local state
      _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
      notifyListeners();
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }
  
  int getUnreadCount() {
    return _notifications.where((n) => !n.isRead).length;
  }
  
  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }
  
  String getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month(s) ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day(s) ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour(s) ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute(s) ago';
    } else {
      return 'Just now';
    }
  }
}