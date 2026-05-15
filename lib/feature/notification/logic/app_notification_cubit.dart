import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:optialeader/feature/notification/logic/app_notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final String userRole; 

  NotificationCubit({required this.userRole}) : super(NotificationInitial());

  Future<void> fetchNotifications() async {
    emit(NotificationLoading());

    try {
      // ⏳ [هنا هتكتب اللوجيك لاحقاً]
      // مؤقتاً هنرجع قائمة فاضية لحد ما تكتبي اللوجيك
      await Future.delayed(const Duration(seconds: 1)); 
      emit(NotificationLoaded([])); 

    } catch (e) {
      emit(NotificationError("حدث خطأ أثناء جلب الإشعارات"));
    }
  }

  // ✅ دالة لتعليم الإشعار كمقروء
  Future<void> markAsRead(String notificationId) async {
    // ⏳ [هتكتبين اللوجيك هنا لاحقاً عشان تحدثي الفايرستور]
  }
}