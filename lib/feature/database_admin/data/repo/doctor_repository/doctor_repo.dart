import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:optialeader/feature/database_admin/data/models/doctor_profile_model.dart';

abstract class DoctorRepo {
  Future<Either<String, Unit>> saveDoctorData(DoctorProfileModel doctor);

  Future<Either<String, DoctorProfileModel?>> getDoctorProfile(String uid);
  Stream<List<DoctorProfileModel>> watchAllDoctors();
  Future<Either<String, Unit>> updateAccountStatus(String uid, bool isActive);

  Future<Either<String, Unit>> updateVacationStatus(
    String uid,
    bool isOnVacation,
  );

  //بتاخد الملف ومسار التخزين وبترجع لك الرابط
  Future<Either<String, String>> uploadFile(File file, String storagePath);
  // تحديث الصورة الشخصية مباشرة}
  Future<Either<String, Unit>> updateDoctorImage(String uid, String imageUrl);
  Future<Either<String, Unit>> deleteDoctorAccount(String uid);
  Future<Either<String, Unit>> updateDoctorProfileData(
    String uid,
    Map<String, dynamic> updatedFields,
  );
}
