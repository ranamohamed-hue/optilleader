import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:optialeader/feature/data_base_admin/data/models/admin_profile_model.dart';
import 'package:optialeader/feature/data_base_admin/data/repo/admin_repository/admin_repo.dart';

class AdminRepoImpl extends AdminRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _usersCollection => _firestore.collection('Users');

  @override
  Future<Either<String, Unit>> saveAdminData(AdminProfileModel admin) async {
    try {
      await _usersCollection
          .doc(admin.uid)
          .set(admin.toMap(), SetOptions(merge: true));
      return right(unit);
    } catch (e) {
      return left("فشل حفظ بيانات الأدمن: ${e.toString()}");
    }
  }

  @override
  Future<Either<String, AdminProfileModel?>> getAdminProfile(String uid) async {
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
      return right(null);
    } catch (e) {
      return left("فشل جلب بيانات الأدمن: ${e.toString()}");
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
      return left("فشل تحديث حالة الحساب: ${e.toString()}");
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
      return left("فشل تحديث صورة الأدمن: ${e.toString()}");
    }
  }

  @override
  Future<Either<String, Unit>> deleteAdminAccount(String uid) async {
    try {
      await _usersCollection.doc(uid).delete();
      return right(unit);
    } catch (e) {
      return left("فشل حذف حساب الأدمن: ${e.toString()}");
    }
  }
}
