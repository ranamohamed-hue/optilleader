import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:optialeader/feature/database_admin/data/models/admin_profile_model.dart';
import 'package:optialeader/feature/database_admin/data/repo/admin_repository/admin_repo.dart';

class AdminRepoImpl extends AdminRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _usersCollection => _firestore.collection('users');

  @override
  Future<Either<String, Unit>> saveAdminData(AdminProfileModel admin) async {
    try {
      await _usersCollection
          .doc(admin.uid)
          .set(admin.toMap(), SetOptions(merge: true));
      return right(unit);
    } catch (e) {
      return left("ERROR_ADMIN_SAVE"); // ✅ استبدال النص العربي
    }
  }

  @override
  // ✅ [تعديل] إزالة علامة الـ ? عشان نرجع كائن صحيح أو خطأ
  Future<Either<String, AdminProfileModel>> getAdminProfile(String uid) async {
    try {
      final doc = await _usersCollection.doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return right(
          AdminProfileModel.fromJson(
            doc.data() as Map<String, dynamic>,
            doc.id,
          ),
        );
      }
      return left("ERROR_ADMIN_NOT_FOUND"); // ✅ لو مش موجود يبقى خطأ
    } catch (e) {
      return left("ERROR_DB_FETCH"); // ✅ استبدال النص العربي
    }
  }

  @override
  Stream<List<AdminProfileModel>> watchAllAdmins() {
    return _usersCollection.where('role', isEqualTo: 'admin').snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) {
        return AdminProfileModel.fromJson(
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
      await _usersCollection.doc(uid).update({'is_active': isActive});
      return right(unit);
    } catch (e) {
      return left("ERROR_ADMIN_STATUS_UPDATE"); // ✅
    }
  }

  @override
  Future<Either<String, Unit>> updateAdminImage(
    String uid,
    String imageUrl,
  ) async {
    try {
      await _usersCollection.doc(uid).update({
        'profile.profile_image': imageUrl,
      });
      return right(unit);
    } catch (e) {
      return left("ERROR_ADMIN_IMAGE_UPDATE"); // ✅
    }
  }

  @override
  Future<Either<String, Unit>> deleteAdminAccount(String uid) async {
    try {
      await _usersCollection.doc(uid).delete();
      return right(unit);
    } catch (e) {
      return left("ERROR_ADMIN_DELETE"); // ✅
    }
  }
  @override
    // ✅ [إضافة] دالة لجلب عدد الطلبات للداشبورد
  Future<Map<String, int>> getAdminDashboardCounts() async {
    try {
      int newRequestsCount = 0;
      int underReviewCount = 0;

      // 1. عدد الطلبات الجديدة (بتاعة الدكاترة)
      // ⚠️ ملاحظة: تأكدي إن اسم الـ Collection هو 'requests' أو 'orders' زي ما عندك في الفايرستور
      final newRequestsQuery = _firestore
          .collection('requests')
          .where('status', isEqualTo: 'new'); // ⚠️ تأكدي من قيمة الـ status
      final newRequestsSnapshot = await newRequestsQuery.count().get();
      newRequestsCount = newRequestsSnapshot.count ?? 0;

      // 2. عدد الطلبات تحت المراجعة (اللي المحكمين شغالين عليها)
      final underReviewQuery = _firestore
          .collection('requests')
          .where('status', isEqualTo: 'under_review'); // ⚠️ تأكدي من قيمة الـ status
      final underReviewSnapshot = await underReviewQuery.count().get();
      underReviewCount = underReviewSnapshot.count ?? 0;

      return {
        'newRequests': newRequestsCount,
        'underReview': underReviewCount,
      };
    } catch (e) {
      // لو حصل خطأ، نرجع الأصفار عشان التطبيق مايقفش
      return {'newRequests': 0, 'underReview': 0};
    }
  }

}