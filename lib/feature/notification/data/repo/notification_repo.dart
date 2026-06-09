import 'package:dartz/dartz.dart';
import 'package:optialeader/feature/notification/data/model/app_notification_model.dart';

abstract class NotificationRepo {
  // إرسال إشعار لمستخدم معين
  Future<Either<String, Unit>> sendNotification(AppNotificationModel notification);
  
  // جلب الإشعارات لمستخدم معين (دكتور أو مستخدم عادي)
  Stream<List<AppNotificationModel>> getNotifications(String receiverId);

  // لجلب جميع الإشعارات المعلقة في النظام بالكامل دون الارتباط بـ UID محدد
  Stream<List<AppNotificationModel>> getAdminPendingNotifications();

  // تعيين الإشعار كمقروء
  Future<Either<String, Unit>> markAsRead(String receiverId, String notificationId);
  
  // إرسال إشعار جماعي لقائمة من المستخدمين
  Future<Either<String, Unit>> broadcastNotification(
    List<String> receiverIds,
    AppNotificationModel notification,
  );
}