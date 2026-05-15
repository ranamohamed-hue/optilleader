import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:optialeader/feature/setting/data/models/user_setting_model.dart';
import 'package:optialeader/feature/setting/data/repo/setting_repo.dart';

class SettingRepoImpl implements SettingsRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<Either<String, UserSettingsModel>> getUserData({
    required String uid,
    required String role, 
  }) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();

      if (doc.exists && doc.data() != null) {
        return right(UserSettingsModel.fromFirestore(doc.data()!, uid));
      } else {
        return left("ERROR_USER_NOT_FOUND"); // ✅ تم الاستبدال
      }
    } on FirebaseException catch (e) {
      return left("ERROR_DB_CONNECTION"); // ✅ تم الاستبدال
    } catch (e) {
      return left("ERROR_UNKNOWN"); // ✅ تم الاستبدال
    }
  }

  @override
  Future<Either<String, Unit>> updateProfileData({
    required UserSettingsModel user,
    required String role,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .update(user.toUpdateMap());
      return right(unit);
    } on FirebaseException catch (e) {
      return left("ERROR_DB_UPDATE"); // ✅ تم الاستبدال
    } catch (e) {
      return left("ERROR_UNKNOWN"); // ✅ تم الاستبدال
    }
  }
}