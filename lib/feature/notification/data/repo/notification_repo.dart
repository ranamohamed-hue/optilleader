import 'package:dartz/dartz.dart';
import 'package:optialeader/feature/notification/data/model/app_notification_model.dart';

abstract class NotificationRepo {
  // إرسال إشعار ليوزر محدد
  Future<Either<String, Unit>> sendNotification(
    AppNotificationModel notification,
  );

  // ✅ إرسال إشعار بناءً على الصلاحية (جروب)
  Future<Either<String, Unit>> sendRoleBasedNotification(
    AppNotificationModel notification,
  );

  // جلب الإشعارات لمستخدم معين (فقط الغير مقروءة)
  Stream<List<AppNotificationModel>> getNotifications(String receiverId);

  // تعيين الإشعار كمقروء
  Future<Either<String, Unit>> markAsRead(
    String receiverId,
    String notificationId,
  );

  // حذف إشعار محدد
  Future<Either<String, Unit>> deleteNotification(
    String receiverId,
    String notificationId,
  );

  // حذف جماعي للإشعارات المقروءة لتقليل الحمل على قاعدة البيانات
  Future<void> clearAllReadNotifications(String receiverId);
}
