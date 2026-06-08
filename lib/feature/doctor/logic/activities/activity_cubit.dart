import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:optialeader/feature/doctor/data/model/activities_model.dart';
import 'package:optialeader/feature/doctor/data/model/verefication_status.dart';
import 'package:optialeader/feature/doctor/data/repo/activities/activity_repo.dart';
import 'package:optialeader/feature/doctor/logic/activities/acativity_state.dart';

class ActivityCubit extends Cubit<ActivityState> {
  final ActivityRepo activityRepo;

  ActivityCubit(this.activityRepo) : super(ActivityInitial());

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
      (error) => emit(ActivityError(error: error)),
      (_) => emit(ActivitySuccess()),
    );
  }

  Future<void> deleteActivity(String doctorUid, String activityId) async {
    emit(ActivityLoading());
    final result = await activityRepo.deleteActivity(doctorUid, activityId);
    result.fold(
      (error) => emit(ActivityError(error: error)),
      (_) => emit(ActivitySuccess()),
    );
  }

  // ✅ [إضافة] الدالة العامة لتغيير الحالة (للأدمن أو لأي استخدام)
  Future<void> updateActivityStatus(
    String doctorUid,
    String activityId,
    VerificationStatus status, {
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

  Future<void> approveActivity(String doctorUid, String activityId) async {
    emit(ActivityLoading());
    final result = await activityRepo.updateActivityStatus(
      doctorUid, activityId, VerificationStatus.approved,
    );
    result.fold(
      (error) => emit(ActivityError(error: error)),
      (_) => emit(ActivitySuccess()),
    );
  }

  Future<void> rejectActivity(String doctorUid, String activityId, String reason) async {
    emit(ActivityLoading());
    final result = await activityRepo.updateActivityStatus(
      doctorUid, activityId, VerificationStatus.rejected,
      rejectionReason: reason,
    );
    result.fold(
      (error) => emit(ActivityError(error: error)),
      (_) => emit(ActivitySuccess()),
    );
  }
}