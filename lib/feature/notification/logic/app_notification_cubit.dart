import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:optialeader/feature/notification/data/model/app_notification_model.dart';
import 'package:optialeader/feature/notification/data/repo/notification_repo.dart';
import 'package:optialeader/feature/notification/logic/app_notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationRepo notificationRepo;
  final String userId;
  
  StreamSubscription? _notificationSubscription; // عشان نقدر نلغي الـ Stream

  NotificationCubit({required this.notificationRepo, required this.userId}) : super(NotificationInitial());

  // جلب الإشعارات بشكل لحظي (Real-time)
  void fetchNotifications() {
    emit(NotificationLoading());
    
    // إلغاء أي Stream قديم عشان نعمل واحدة جديدة
    _notificationSubscription?.cancel(); 
    
    _notificationSubscription = notificationRepo.getNotifications(userId).listen((notifications) {
      emit(NotificationLoaded(notifications));
    }, onError: (error) {
      emit(NotificationError("فشل جلب الإشعارات"));
    });
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