import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:optialeader/feature/database_admin/data/models/database_admin_model.dart';
import 'package:optialeader/feature/database_admin/data/repo/database_admin_repository/database_admin_repo.dart';

class DatabaseAdminRepoImpl implements DatabaseAdminRepo {
  final FirebaseFirestore _firestore;
  DatabaseAdminRepoImpl(this._firestore);

  @override
  Future<Either<String, DatabaseAdminProfileModel>> getAdminProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        final model = DatabaseAdminProfileModel.fromFirestore(doc.data()!, doc.id);
        return Right(model);
      } else {
        return const Left("ERROR_PROFILE_NOT_FOUND"); // ✅ استبدال النص العربي
      }
    } on FirebaseException catch (e) {
      return Left("ERROR_DB_FIRESTORE: ${e.message ?? ''}"); // ✅ استبدال النص العربي
    } catch (e) {
      return Left("ERROR_UNKNOWN: ${e.toString()}");
    }
  }

  @override
  Future<Either<String, Unit>> updateAdminInfo({
    required String uid,
    required String newPhone,
    required String addressAr,
    required String addressEn,
  }) async {
    try {
      // ✅ تعديل الـ Map عشان تتوافق مع الهيكل المتداخل (Nested) في الفايرستور
      await _firestore.collection('users').doc(uid).update({
        'profile.phone.phone1': newPhone,
        'profile.address.ar': addressAr,
        'profile.address.en': addressEn,
      });
      return const Right(unit);
    } on FirebaseException catch (e) {
      return Left("ERROR_DB_UPDATE: ${e.message ?? ''}");
    } catch (e) {
      return Left("ERROR_UNKNOWN: ${e.toString()}");
    }
  }

  @override
  Future<Either<String, Unit>> updateProfileImage(String uid, String imageUrl) async {
    try {
      // ✅ تعديل المسار عشان يتوافق مع الهيكل المتداخل
      await _firestore.collection('users').doc(uid).update({
        'profile.profile_image': imageUrl,
      });
      return const Right(unit);
    } on FirebaseException catch (e) {
      return Left("ERROR_DB_UPDATE: ${e.message ?? ''}");
    } catch (e) {
      return Left("ERROR_UNKNOWN: ${e.toString()}");
    }
  }

  @override
  @override
  Future<Map<String, int>> getUserCounts() async {
    try {
      // 1. عدد الدكاترة
      final doctorsQuery = _firestore
          .collection('users')
          .where('role', isEqualTo: 'doctor');
      final doctorsSnapshot = await doctorsQuery.count().get();
      // ✅ أضفنا ?? 0 لتحويل int? إلى int
      final int doctorsCount = doctorsSnapshot.count ?? 0; 

      // 2. عدد المحكمين
      final judgesQuery = _firestore
          .collection('users')
          .where('role', isEqualTo: 'judge');
      final judgesSnapshot = await judgesQuery.count().get();
      // ✅ أضفنا ?? 0
      final int judgesCount = judgesSnapshot.count ?? 0;

      // 3. عدد المسؤولين (الأدمن العادي)
      final adminsQuery = _firestore
          .collection('users')
          .where('role', isEqualTo: 'admin');
      final adminsSnapshot = await adminsQuery.count().get();
      // ✅ أضفنا ?? 0
      final int adminsCount = adminsSnapshot.count ?? 0;

      return {
        'doctors': doctorsCount,
        'judges': judgesCount,
        'admins': adminsCount,
      };
    } catch (e) {
      // لو حصل خطأ، نرجع الأصفار عشان التطبيق مايقفش
      return {'doctors': 0, 'judges': 0, 'admins': 0};
    }
  }
}