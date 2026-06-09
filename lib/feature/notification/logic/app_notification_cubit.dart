import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:optialeader/feature/notification/data/model/app_notification_model.dart';
import 'package:optialeader/feature/notification/data/repo/notification_repo.dart';
import 'package:optialeader/feature/notification/logic/app_notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationRepo notificationRepo;
  
  String userId; 
  StreamSubscription? _notificationSubscription; 

  NotificationCubit({required this.notificationRepo, required this.userId}) : super(NotificationInitial()) {
    // بنشغل الـ Stream فوراً لو الـ ID مش فاضي
    if (userId.isNotEmpty) {
      fetchNotifications();
    }
  }

  // لتحديث الـ ID وتشغيل الـ Stream بعد اللوجين فوراً
  void updateUserIdAndFetch(String newUserId) {
    if (newUserId.isNotEmpty && newUserId != userId) {
      userId = newUserId; // بنحدث الـ ID جوه الكيوبيت
      fetchNotifications(); // بنفتح الماسورة اللايف على الفايرستور بالـ ID الجديد
    }
  }

  // جلب الإشعارات بشكل لحظي (Real-time) للأدمن
  void fetchNotifications() {
    emit(NotificationLoading());
    
    // إلغاء أي Stream قديم عشان نمنع تداخل البيانات
    _notificationSubscription?.cancel(); 
    
    //  تم التغيير هنا لتقرأ من الدالة العامة الجديدة التي تراقب السيستم كله
    _notificationSubscription = notificationRepo.getAdminPendingNotifications().listen(
      (notifications) {
        emit(NotificationLoaded(notifications));
      }, 
      onError: (error) {
        print("🚨 خطأ لايف في الـ Stream للإشعارات: $error");
        emit(NotificationError("فشل جلب الإشعارات"));
      },
    );
  }

  // إرسال إشعار
  Future<void> sendNotification(AppNotificationModel notification) async {
    await notificationRepo.sendNotification(notification);
  }

  // تعليم كمقروء
  Future<void> markAsRead(String notificationId) async {
    await notificationRepo.markAsRead(userId, notificationId);
  }

  // تنظيف الـ Stream لما الـ Cubit يتقفل
  @override
  Future<void> close() {
    _notificationSubscription?.cancel();
    return super.close();
  }
}