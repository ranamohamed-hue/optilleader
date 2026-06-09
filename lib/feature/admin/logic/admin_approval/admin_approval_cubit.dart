import 'package:bloc/bloc.dart';
import 'package:optialeader/feature/admin/data/repo/admin_approval/admin_approval_repo.dart';
import 'package:optialeader/feature/admin/logic/admin_approval/admin_approval_state.dart';

class AdminApprovalCubit extends Cubit<AdminApprovalState> {
  final AdminApprovalRepo adminApprovalRepo; 

  AdminApprovalCubit({required this.adminApprovalRepo}) : super(AdminApprovalInitial());

  // في AdminApprovalCubit
// في ملف AdminApprovalCubit.dart
Future<void> getPendingRequests({bool showLoading = true}) async {
  if (showLoading) {
    emit(AdminApprovalLoading());
  }
  
  final result = await adminApprovalRepo.getPendingRequests();
  result.fold(
    (error) => emit(AdminApprovalError(error)),
    (doctors) => emit(AdminApprovalLoaded(doctors)),
  );
}

 Future<void> approveResearch(String doctorUid, String paperId, String paperTitle) async {
  final result = await adminApprovalRepo.approveResearch(doctorUid, paperId, paperTitle);
  result.fold(
    (error) => emit(AdminApprovalError(error)),
    (_) => getPendingRequests(showLoading: false), // 👈 هذا هو السر: لا تظهري الـ Loading هنا!
  );
  }

  Future<void> rejectResearch(String doctorUid, String paperId, String paperTitle, String reason) async {
    final result = await adminApprovalRepo.rejectResearch(doctorUid, paperId, paperTitle, reason);
    result.fold(
      (error) => emit(AdminApprovalError(error)),
      (_) => getPendingRequests(),
    );
  }

  Future<void> approveActivity(String doctorUid, String activityId, String activityTitle) async {
    final result = await adminApprovalRepo.approveActivity(doctorUid, activityId, activityTitle);
    result.fold(
      (error) => emit(AdminApprovalError(error)),
      (_) => getPendingRequests(),
    );
  }

  Future<void> rejectActivity(String doctorUid, String activityId, String activityTitle, String reason) async {
    final result = await adminApprovalRepo.rejectActivity(doctorUid, activityId, activityTitle, reason);
    result.fold(
      (error) => emit(AdminApprovalError(error)),
      (_) => getPendingRequests(),
    );
  }
}