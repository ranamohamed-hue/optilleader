import 'package:dartz/dartz.dart';
import 'package:optialeader/feature/database_admin/data/models/admin_profile_model.dart';

abstract class AdminRepo {
  Future<Either<String, Unit>> saveAdminData(AdminProfileModel admin);
  Future<Either<String, AdminProfileModel?>> getAdminProfile(String uid);
  Stream<List<AdminProfileModel>> watchAllAdmins();
  Future<Either<String, Unit>> updateAccountStatus(String uid, bool isActive);

  Future<Either<String, Unit>> updateAdminImage(String uid, String imageUrl);
  Future<Either<String, Unit>> deleteAdminAccount(String uid);
    Future<Map<String, int>> getAdminDashboardCounts(); 

}
