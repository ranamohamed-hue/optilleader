import 'package:dartz/dartz.dart';
import 'package:optialeader/feature/notification/data/model/app_notification_model.dart';

abstract class NotificationRepo {
  // إرسال إشعار لمستخدم معين
  Future<Either<String, Unit>> sendNotification(AppNotificationModel notification);
  
  // جلب الإشعارات لمستخدم معين
  Stream<List<AppNotificationModel>> getNotifications(String receiverId);

  // جلب جميع الإشعارات المعلقة (مع الفلترة والـ Map التي أضفناها)
  Stream<List<AppNotificationModel>> getAdminPendingNotifications();

  // تعيين الإشعار كمقروء
  Future<Either<String, Unit>> markAsRead(String receiverId, String notificationId);
  
  // إرسال إشعار جماعي
  Future<Either<String, Unit>> broadcastNotification(
    List<String> receiverIds,
    AppNotificationModel notification,
  );

  // --- الدوال الجديدة لتقليل الحمل وحذف الإشعارات ---

  // حذف إشعار محدد
  Future<Either<String, Unit>> deleteNotification(String receiverId, String notificationId);

  // حذف جماعي للإشعارات المقروءة لتقليل الحمل على قاعدة البيانات
  Future<void> clearAllReadNotifications(String receiverId);
}