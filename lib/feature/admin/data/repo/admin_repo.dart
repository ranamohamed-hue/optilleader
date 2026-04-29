import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:optialeader/feature/admin/data/model/admin_model.dart';

abstract class AdminRepo {
  /// 🟢 جلب بيانات الأدمن
  Future<Either<String, AdminModel>> getAdminProfile(String uid);

  /// 🟢 تحديث بيانات الأدمن
  Future<Either<String, void>> updateAdminProfile({
    required String uid,
    String? imageUrl,
    String? address,
    String? phone1,
    String? phone2,
  });

  /// 🟢 رفع صورة البروفايل
  Future<Either<String, String>> uploadProfileImage(
    File file,
    String uid,
  );
}