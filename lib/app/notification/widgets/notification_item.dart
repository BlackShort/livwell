import 'package:flutter/material.dart';
import 'package:livwell/config/theme/app_pallete.dart';
import 'package:livwell/core/services/notification_service.dart';
import '../models/notification_model.dart';
import '../controllers/notification_controller.dart';

class NotificationItem extends StatelessWidget {
  final NotificationModel notification;
  final Function(String) onTap;
  final Function(String) onDismiss;
  
  const NotificationItem({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final notificationService = NotificationService();
    final controller = NotificationController();
    
    final typeColor = Color(notificationService.getColorForType(notification.type));
    final typeIcon = notificationService.getIconForType(notification.type);
    final timeAgo = controller.getTimeAgo(notification.timestamp);
    
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      onDismissed: (_) => onDismiss(notification.id),
      child: InkWell(
        onTap: () => onTap(notification.id),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: notification.isRead ? Colors.white : Colors.grey.shade50,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    typeIcon,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                        color: AppPallete.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppPallete.secondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      timeAgo,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppPallete.secondary.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              if (!notification.isRead)
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: typeColor,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}