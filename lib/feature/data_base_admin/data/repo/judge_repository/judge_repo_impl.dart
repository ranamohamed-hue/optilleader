import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:optialeader/feature/data_base_admin/data/models/judge_profile_model.dart';
import 'package:optialeader/feature/data_base_admin/data/repo/judge_repository/judge_repo.dart';

class JudgeRepoImpl extends JudgeRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference get _usersCollection => _firestore.collection('Users');
  @override
  Future<Either<String, Unit>> saveJudgeData(JudgeProfileModel judge) async {
    try {
      await _usersCollection
          .doc(judge.uid)
          .set(judge.toMap(), SetOptions(merge: true));
      return right(unit);
    } catch (e) {
      return left("فشل حفظ بيانات الحكم: ${e.toString()}");
    }
  }

  @override
  Future<Either<String, JudgeProfileModel?>> getJudgeProfile(String uid) async {
    try {
      final doc = await _usersCollection.doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return right(
          JudgeProfileModel.fromJson(
            doc.data() as Map<String, dynamic>,
            doc.id,
          ),
        );
      }
      return right(null);
    } catch (e) {
      return left("فشل جلب بيانات الحكم: ${e.toString()}");
    }
  }

  @override
  Stream<List<JudgeProfileModel>> watchAllJudges() {
    return _usersCollection.where('role', isEqualTo: 'judge').snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) {
        return JudgeProfileModel.fromJson(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    });
  }

  @override
  Future<Either<String, Unit>> updateJudgeStatus(
    String uid,
    bool isActive,
  ) async {
    try {
      await _usersCollection.doc(uid).update({'is_active': isActive});
      return right(unit);
    } catch (e) {
      return left("فشل تحديث حالة الحكم: ${e.toString()}");
    }
  }

  @override
  Future<Either<String, Unit>> updateJudgeImage(
    String uid,
    String imageUrl,
  ) async {
    try {
      await _usersCollection.doc(uid).update({
        'profile.profile_image': imageUrl,
      });
      return right(unit);
    } catch (e) {
      return left("فشل تحديث صورة الحكم: ${e.toString()}");
    }
  }

  @override
  Future<Either<String, Unit>> deleteJudgeAccount(String uid) async {
    try {
      await _usersCollection.doc(uid).delete();
      return right(unit);
    } catch (e) {
      return left("فشل حذف حساب الحكم: ${e.toString()}");
    }
  }
}
