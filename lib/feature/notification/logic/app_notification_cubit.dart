import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart'; // ✅ عشان AppLifecycleState
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart'; // ✅ عشان الـ Debounce
import 'package:optialeader/feature/notification/data/model/app_notification_model.dart';
import 'package:optialeader/feature/notification/data/repo/notification_repo.dart';
import 'package:optialeader/feature/notification/logic/app_notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> with WidgetsBindingObserver {
  final NotificationRepo notificationRepo;
  
  String userId; 
  StreamSubscription? _notificationSubscription; 

  NotificationCubit({required this.notificationRepo, required this.userId}) : super(NotificationInitial()) {
    // ✅ نسجل الـ Observer عشان نسمع لحالة التطبيق (Foreground / Background)
    WidgetsBinding.instance.addObserver(this);
    
    if (userId.isNotEmpty) {
      fetchNotifications();
    }
  }

  // ✅ إطفاء وتشغيل الـ Stream لما التطبيق ينزل أو يرجع
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // التطبيق نزل للخلفية -> إطفاء مؤقت
      _notificationSubscription?.pause();
    } else if (state == AppLifecycleState.resumed) {
      // التطبيق رجع قدام -> تشغيل تاني
      _notificationSubscription?.resume();
    }
  }

  // تحديث الـ ID بعد اللوجين
  void updateUserIdAndFetch(String newUserId) {
    if (newUserId.isNotEmpty && newUserId != userId) {
      userId = newUserId; 
      fetchNotifications(); 
    }
  }

  // ✅ جلب الإشعارات اللحظية + الـ Debounce عشان منع الـ Spam
  void fetchNotifications() {
    emit(NotificationLoading());
    _notificationSubscription?.cancel(); 
    
    _notificationSubscription = notificationRepo.getNotifications(userId)
      .debounceTime(const Duration(milliseconds: 300)) // ✅ لو جت إشعارات كتير في ثانية، بيدمجهم في Update واحد
      .listen(
        (notifications) {
          emit(NotificationLoaded(notifications));
        }, 
        onError: (error) {
          print("🚨 خطأ لايف في الـ Stream للإشعارات: $error");
          emit(NotificationError("فشل جلب الإشعارات"));
        },
      );
  }

  // ✅ دالة الإرسال الموحدة (بتريحك في الـ UI)
  Future<void> sendNotificationSmartly(AppNotificationModel notification) async {
    if (notification.target == NotificationTarget.specificUser && notification.receiverId.isNotEmpty) {
      // لو يوزر محدد، ابعتله لوحده
      await notificationRepo.sendNotification(notification);
    } else {
      // لو صلاحية جروب، وزعها للجروب
      await notificationRepo.sendRoleBasedNotification(notification);
    }
  }

  // تعليم كمقروء
  Future<void> markAsRead(String notificationId) async {
    await notificationRepo.markAsRead(userId, notificationId);
    // ملحوظة: مش محتاج تعمل Emit، لأن الـ Stream هيشيل الإشعار أوتوماتيك لما الـ is_read تبقى true (عشان الفلتر)
  }

  // حذف إشعار
  Future<void> deleteNotification(String notificationId) async {
    await notificationRepo.deleteNotification(userId, notificationId);
  }

  // تنظيف الإشعارات المقروءة
  Future<void> clearReadNotifications() async {
    await notificationRepo.clearAllReadNotifications(userId);
  }

  // ✅ تدمير كامل لما المستخدم يعمل Logout
  void resetOnLogout() {
    _notificationSubscription?.cancel();
    _notificationSubscription = null;
    userId = ''; 
    emit(NotificationInitial());
  }

  // تنظيف الـ Stream لما الـ Cubit يتقفل من الذاكرة
  @override
  Future<void> close() {
    WidgetsBinding.instance.removeObserver(this); // ✅ شيل الـ Observer
    _notificationSubscription?.cancel();
    return super.close();
  }
}