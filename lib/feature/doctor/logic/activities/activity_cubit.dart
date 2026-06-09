import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:optialeader/feature/doctor/data/model/activities_model.dart';
import 'package:optialeader/feature/doctor/data/model/verefication_status.dart';
import 'package:optialeader/feature/doctor/data/repo/activities/activity_repo.dart';
import 'package:optialeader/feature/doctor/logic/activities/acativity_state.dart';
import 'package:optialeader/feature/notification/data/model/app_notification_model.dart';
import 'package:optialeader/feature/notification/data/repo/notification_repo_impl.dart';

class ActivityCubit extends Cubit<ActivityState> {
  final ActivityRepo activityRepo;
  final NotificationRepoImpl notificationRepo;

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

    result.fold(
      (error) {
        emit(ActivityError(error: error));
      },
      (_) async {
        emit(ActivitySuccess());

        try {
          print("===== START NOTIFICATION =====");

          final adminsSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .where('jop.title.en', isEqualTo: 'admin')
              .get();

          print("Admins Count = ${adminsSnapshot.docs.length}");

          final adminIds = adminsSnapshot.docs.map((doc) => doc.id).toList();

          print("Admin IDs = $adminIds");
          print("Admins Count = ${adminsSnapshot.docs.length}");
          print(adminsSnapshot.docs.map((e) => e.id).toList());
          for (String adminId in adminIds) {
            print("Sending to Admin: $adminId");

            final notification = AppNotificationModel(
              id: '',
              title: 'طلب اعتماد نشاط جديد',
              message: 'تم إضافة نشاط بعنوان: ${activity.title} يحتاج موافقتك',
              type: NotificationType.newActivitySubmitted,
              timestamp: Timestamp.now(),
              receiverId: adminId,
              relatedId: activity.id,
              doctorUid: doctorUid,
            );

            final sendResult = await notificationRepo.sendNotification(
              notification,
            );print(result);

            print("Notification Result: $sendResult");
          }

          print("===== END NOTIFICATION =====");
        } catch (e, s) {
          print("ERROR IN NOTIFICATION:");
          print(e);
          print(s);
        }
      },
    );
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

  Future<void> updateActivityStatus({
    required String doctorUid,
    required String activityId,
    required VerificationStatus status,
    String? rejectionReason,
  }) async {
    emit(ActivityLoading());
    final result = await activityRepo.updateActivityStatus(
      doctorUid,
      activityId,
      status,
      rejectionReason: rejectionReason,
    );
    result.fold(
      (error) => emit(ActivityError(error: error)),
      (_) => emit(ActivitySuccess()),
    );
  }

  Future<void> approveActivity(
    String doctorUid,
    String activityId,
    String activityTitle,
  ) async {
    emit(ActivityLoading());
    final result = await activityRepo.updateActivityStatus(
      doctorUid,
      activityId,
      VerificationStatus.approved,
    );
    result.fold(
      (error) => emit(ActivityError(error: error)),
      (_) => emit(ActivitySuccess()),
    );
  }

  Future<void> rejectActivity(
    String doctorUid,
    String activityId,
    String activityTitle,
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
      (_) => emit(ActivitySuccess()),
    );
  }
}
