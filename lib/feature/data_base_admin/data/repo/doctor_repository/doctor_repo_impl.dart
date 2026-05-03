import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:optialeader/feature/data_base_admin/data/repo/Doctor_Repository/doctor_repo.dart';
import 'package:dartz/dartz.dart';
import 'package:optialeader/feature/data_base_admin/data/models/doctor_profile_model.dart';
import 'package:firebase_storage/firebase_storage.dart';

class DoctorRepoImpl extends DoctorRepo {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;
  CollectionReference get _usersCollection =>
      firebaseFirestore.collection('Users');

  @override
  Future<Either<String, Unit>> saveDoctorData(DoctorProfileModel doctor) async {
    try {
      await _usersCollection
          .doc(doctor.uid)
          .set(doctor.toMap(), SetOptions(merge: true));
      return right(unit);
    } catch (e) {
      return left(e.toString());
    }
  }

  @override
  Future<Either<String, DoctorProfileModel?>> getDoctorProfile(
    String uid,
  ) async {
    try {
      final doc = await _usersCollection.doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return right(
          DoctorProfileModel.fromJson(
            doc.data() as Map<String, dynamic>,
            doc.id,
          ),
        );
      }
      return right(null);
    } catch (e) {
      return left("فشل جلب بيانات الدكتور: ${e.toString()}");
    }
  }

  @override
  Stream<List<DoctorProfileModel>> watchAllDoctors() {
    return _usersCollection.where('role', isEqualTo: 'doctor').snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) {
        return DoctorProfileModel.fromJson(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    });
  }

  @override
  Future<Either<String, Unit>> updateAccountStatus(
    String uid,
    bool isActive,
  ) async {
    try {
      await _usersCollection.doc(uid).update({
        'eligibility_data.is_active': isActive,
      });
      return right(unit);
    } catch (e) {
      return left("فشل تحديث حالة الحساب: ${e.toString()}");
    }
  }

  @override
  Future<Either<String, Unit>> updateVacationStatus(
    String uid,
    bool isOnVacation,
  ) async {
    try {
      await _usersCollection.doc(uid).update({
        'eligibility_data.is_on_vacation': isOnVacation,
      });
      return right(unit);
    } catch (e) {
      return left("فشل تحديث حالة الإجازة: ${e.toString()}");
    }
  }

  @override
  Future<Either<String, String>> uploadFile(
    File file,
    String storagePath,
  ) async {
    try {
      // التصحيح الثاني: استخدام firebaseStorage للرفع
      final ref = firebaseStorage.ref().child(storagePath);
      await ref.putFile(file);

      final url = await ref.getDownloadURL();
      return right(url);
    } catch (e) {
      return left("فشل رفع الملف: ${e.toString()}");
    }
  }

  @override
  Future<Either<String, Unit>> updateDoctorImage(
    String uid,
    String imageUrl,
  ) async {
    try {
      await _usersCollection.doc(uid).update({
        'contact.profile_image_url': imageUrl,
      });
      return right(unit);
    } catch (e) {
      return left("فشل تحديث رابط الصورة: ${e.toString()}");
    }
  }

  @override
  Future<Either<String, Unit>> deleteDoctorAccount(String uid) async {
    try {
      await _usersCollection.doc(uid).delete();
      return right(unit);
    } catch (e) {
      return left("فشل حذف الحساب: ${e.toString()}");
    }
  }
}
