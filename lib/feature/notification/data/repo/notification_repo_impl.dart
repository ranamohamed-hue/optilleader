import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:optialeader/feature/notification/data/model/app_notification_model.dart';
import 'package:optialeader/feature/notification/data/repo/notification_repo.dart';

class NotificationRepoImpl extends NotificationRepo {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  @override
  Future<Either<String, Unit>> sendNotification(AppNotificationModel notification) async {
    try {
      // بنحفظ الإشعار في Subcollection جوا document الـ المستلم
      await firebaseFirestore
          .collection('users')
          .doc(notification.receiverId)
          .collection('notifications')
          .add(notification.toMap());
      return right(unit);
    } catch (e) {
      return left("فشل إرسال الإشعار: ${e.toString()}");
    }
  }

  @override
  Stream<List<AppNotificationModel>> getNotifications(String receiverId) {
    return firebaseFirestore
        .collection('users')
        .doc(receiverId)
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return AppNotificationModel.fromFirestore(doc.data(), doc.id);
      }).toList();
    });
  }

  @override
  Future<Either<String, Unit>> markAsRead(String receiverId, String notificationId) async {
    try {
      await firebaseFirestore
          .collection('users')
          .doc(receiverId)
          .collection('notifications')
          .doc(notificationId)
          .update({'is_read': true});
      return right(unit);
    } catch (e) {
      return left("فشل تحديث الإشعار: ${e.toString()}");
    }
  }
    // دالة بتبعت إشعار لليستة مستخدمين (للإشعارات الجماعية)
  Future<Either<String, Unit>> broadcastNotification(
    List<String> receiverIds,
    AppNotificationModel notification,
  ) async {
    try {
      // بنعمل Loop عشان نحفظ الإشعار جوه الـ Subcollection بتاعة كل يوزر
      for (var uid in receiverIds) {
        await firebaseFirestore
            .collection('users')
            .doc(uid)
            .collection('notifications')
            .add(notification.toMap());
      }
      return right(unit);
    } catch (e) {
      return left("فشل إرسال الإشعار الجماعي: ${e.toString()}");
    }
  }
}