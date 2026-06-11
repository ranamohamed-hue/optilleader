import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:optialeader/feature/notification/data/model/app_notification_model.dart';
import 'package:optialeader/feature/notification/data/repo/notification_repo.dart';

class NotificationRepoImpl extends NotificationRepo {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  @override
  Future<Either<String, Unit>> sendNotification(
    AppNotificationModel notification,
  ) async {
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
Stream<List<AppNotificationModel>> getAdminPendingNotifications() {
  return firebaseFirestore
      .collectionGroup('notifications')
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((snapshot) {
        final Map<String, AppNotificationModel> uniqueNotifications = {};

        for (var doc in snapshot.docs) {
          final data = doc.data();
          final model = AppNotificationModel.fromFirestore(data, doc.id);

         
          final key = "${model.relatedId}_${model.message}";

          if (!uniqueNotifications.containsKey(key)) {
            uniqueNotifications[key] = model;
          }
        }

        return uniqueNotifications.values.toList();
      });
}

  @override
  Future<Either<String, Unit>> markAsRead(
    String receiverId,
    String notificationId,
  ) async {
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
  @override
Future<Either<String, Unit>> broadcastNotification(
  List<String> receiverIds,
  AppNotificationModel notification,
) async {
  try {
    for (var uid in receiverIds) {
      // 1. إنشاء نسخة من الموديل بالـ receiverId الصحيح
      final notificationForAdmin = AppNotificationModel(
        id: '',
        title: notification.title,
        message: notification.message,
        type: notification.type,
        timestamp: notification.timestamp,
        receiverId: uid, // ✅ هنا التعديل: نضع الـ ID الصحيح لكل أدمن
        relatedId: notification.relatedId,
        doctorUid: notification.doctorUid,
        senderName: notification.senderName,
        isRead: false,
      );

      // 2. الحفظ في الفايربيز
      await firebaseFirestore
          .collection('users')
          .doc(uid) // الـ Document الصحيح للأدمن
          .collection('notifications')
          .add(notificationForAdmin.toMap());
    }
    return right(unit);
  } catch (e) {
    return left("فشل إرسال الإشعار الجماعي: ${e.toString()}");
  }
}
// ... (الدوال السابقة تبقى كما هي)

  @override
  Future<Either<String, Unit>> deleteNotification(String receiverId, String notificationId) async {
    try {
      await firebaseFirestore
          .collection('users')
          .doc(receiverId)
          .collection('notifications')
          .doc(notificationId)
          .delete();
      return right(unit);
    } catch (e) {
      return left("فشل حذف الإشعار: ${e.toString()}");
    }
  }

  @override
  Future<void> clearAllReadNotifications(String receiverId) async {
    try {
      final batch = firebaseFirestore.batch();
      final querySnapshot = await firebaseFirestore
          .collection('users')
          .doc(receiverId)
          .collection('notifications')
          .where('is_read', isEqualTo: true) // حذف المقروء فقط
          .get();

      for (var doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
    } catch (e) {
      print("خطأ أثناء التنظيف الجماعي: $e");
    }
  }
}
