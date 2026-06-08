import 'package:dartz/dartz.dart';
import 'package:optialeader/feature/notification/data/model/app_notification_model.dart';

abstract class NotificationRepo {
  Future<Either<String, Unit>> sendNotification(AppNotificationModel notification);
  Stream<List<AppNotificationModel>> getNotifications(String receiverId);
  Future<Either<String, Unit>> markAsRead(String receiverId, String notificationId);
    Future<Either<String, Unit>> broadcastNotification(
    List<String> receiverIds,
    AppNotificationModel notification,
  );
}