import 'package:dartz/dartz.dart';
import 'package:optialeader/feature/database_admin/data/models/doctor_profile_model.dart';

abstract class AdminApprovalRepo {
  /// جلب الدكاترة اللي عندهم طلبات معلقة (أبحاث أو أنشطة بحالة pending)
  Future<Either<String, List<DoctorProfileModel>>> getPendingRequests();

  /// الموافقة على بحث
  Future<Either<String, Unit>> approveResearch(String doctorUid, String paperId, String paperTitle);

  /// رفض بحث
  Future<Either<String, Unit>> rejectResearch(String doctorUid, String paperId, String paperTitle, String reason);

  /// الموافقة على نشاط
  Future<Either<String, Unit>> approveActivity(String doctorUid, String activityId, String activityTitle);

  /// رفض نشاط
  Future<Either<String, Unit>> rejectActivity(String doctorUid, String activityId, String activityTitle, String reason);
}