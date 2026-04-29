import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:optialeader/feature/admin/data/model/admin_model.dart';
import 'package:optialeader/feature/admin/data/repo/admin_repo.dart';
import 'package:optialeader/feature/auth/data/models/user_model.dart';

class AdminRepoImpl implements AdminRepo {
  final FirebaseFirestore firestore;

  AdminRepoImpl(this.firestore);

  /// =========================
  /// 🟢 GET ADMIN PROFILE
  /// =========================
  @override
  Future<Either<String, AdminModel>> getAdminProfile(String uid) async {
    try {
      final doc = await firestore.collection('users').doc(uid).get();

      if (!doc.exists) {
        return const Left('المستخدم غير موجود');
      }

      final admin = AdminModel.fromFirestore(doc);

      /// 🔒 تأكد إنه Admin
      if (admin.role != UserRole.admin) {
        return const Left('هذا المستخدم ليس أدمن');
      }

      return Right(admin);
    } catch (e) {
      print(e);
      return const Left('حدث خطأ أثناء جلب البيانات');
    }
  }

  /// =========================
  /// 🟢 UPDATE ADMIN PROFILE
  /// =========================
  @override
  Future<Either<String, void>> updateAdminProfile({
    required String uid,
    String? imageUrl,
    String? address,
    String? phone1,
    String? phone2,
  }) async {
    try {
      final docRef = firestore.collection('users').doc(uid);

      final updateData = <String, dynamic>{};

      /// 🖼️ الصورة
      if (imageUrl != null && imageUrl.isNotEmpty) {
        updateData['profile.profile_image'] = imageUrl;
      }

      /// 📍 العنوان
      if (address != null && address.isNotEmpty) {
        updateData['profile.address.ar'] = address;
        updateData['profile.address.en'] = address;
      }

      /// 📞 التليفونات
      if (phone1 != null && phone1.isNotEmpty) {
        updateData['profile.phone.phone1'] = phone1;
      }

      if (phone2 != null && phone2.isNotEmpty) {
        updateData['profile.phone.phone2'] = phone2;
      }

      /// ❌ مفيش حاجة تتحدث
      if (updateData.isEmpty) {
        return const Left('لا يوجد بيانات للتحديث');
      }

      await docRef.update(updateData);

      return const Right(null);
    } catch (e) {
      print(e);
      return const Left('فشل في تحديث البيانات');
    }
  }

  /// =========================
  /// 🟢 UPLOAD PROFILE IMAGE
  /// =========================
  @override
  Future<Either<String, String>> uploadProfileImage(
    File file,
    String uid,
  ) async {
    try {
      final ref = FirebaseStorage.instance.ref().child(
        'users/$uid/profile.jpg',
      );

      await ref.putFile(file);

      final imageUrl = await ref.getDownloadURL();

      return Right(imageUrl);
    } catch (e) {
      print(e);
      return const Left('فشل رفع الصورة');
    }
  }
}
