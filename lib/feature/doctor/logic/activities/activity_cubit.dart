import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:optialeader/feature/doctor/data/model/activities_model.dart';
import 'package:optialeader/feature/doctor/data/model/verefication_status.dart';
import 'package:optialeader/feature/doctor/data/repo/activities/activity_repo.dart';
import 'package:optialeader/feature/doctor/logic/activities/acativity_state.dart';
import 'package:optialeader/feature/notification/data/model/app_notification_model.dart';
import 'package:optialeader/feature/notification/data/repo/notification_repo.dart';

class ActivityCubit extends Cubit<ActivityState> {
  final ActivityRepo activityRepo;
  final NotificationRepo notificationRepo; // محتاجينه عشان addNewActivity بس

  ActivityCubit(this.activityRepo, this.notificationRepo)
    : super(ActivityInitial());

  Future<void> addNewActivity({
    required String doctorUid,
    required ActivityModel activity,
    File? proofFile,
  }) async {
    emit(ActivityLoading());

    final result = await activityRepo.addActivity(
      doctorUid: doctorUid,
      activity: activity,
      proofFile: proofFile,
    );

    result.fold((error) => emit(ActivityError(error: error)), (_) async {
      emit(ActivitySuccess());

      // ✅ إرسال إشعار للأدمن إن في نشاط جديد (ده موجود صح)
      try {
        final notification = AppNotificationModel(
          id: '',
          title: 'طلب اعتماد نشاط جديد',
          message: 'تم إضافة نشاط بعنوان: "${activity.title}" يحتاج موافقتك',
          type: NotificationType.newActivitySubmitted,
          target: NotificationTarget.adminOnly,
          timestamp: Timestamp.now(),
          receiverId: '',
          relatedId: activity.id,
          doctorUid: doctorUid,
        );

        await notificationRepo.sendRoleBasedNotification(notification);
        print(
          "✅ Notifications sent to admins successfully via Role-Based logic",
        );
      } catch (e) {
        print("🚨 Error sending admin notification: $e");
      }
    });
  }

  Future<void> deleteActivity({
    required String doctorUid,
    required String activityId,
  }) async {
    emit(ActivityLoading());
    final result = await activityRepo.deleteActivity(doctorUid, activityId);
    result.fold(
      (error) => emit(ActivityError(error: error)),
      (_) => emit(ActivitySuccess()),
    );
  }

  // ✅ تم مسح الإشعار من هنا عشان الـ AdminApprovalRepoImpl هو اللي يبعته
  Future<void> approveActivity(String doctorUid, String activityId) async {
    emit(ActivityLoading());
    final result = await activityRepo.updateActivityStatus(
      doctorUid,
      activityId,
      VerificationStatus.approved,
    );

    result.fold(
      (error) => emit(ActivityError(error: error)),
      (_) => emit(
        ActivitySuccess(),
      ), // خلاص، أتحتت الحالة والإشعار راح من الـ Repo
    );
  }

  // ✅ تم مسح الإشعار من هنا برضو
  Future<void> rejectActivity(
    String doctorUid,
    String activityId,
    String reason,
  ) async {
    emit(ActivityLoading());
    final result = await activityRepo.updateActivityStatus(
      doctorUid,
      activityId,
      VerificationStatus.rejected,
      rejectionReason: reason,
    );

    result.fold(
      (error) => emit(ActivityError(error: error)),
      (_) => emit(
        ActivitySuccess(),
      ), // خلاص، أتحتت الحالة والإشعار راح من الـ Repo
    );
  }
}
