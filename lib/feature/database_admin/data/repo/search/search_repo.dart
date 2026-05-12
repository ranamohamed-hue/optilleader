import 'package:dartz/dartz.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:optialeader/feature/auth/data/models/user_model.dart';

class SearchRepo {
  final FirebaseFirestore _firestore;
  SearchRepo(this._firestore);

  Future<Either<String, List<UserModel>>> searchUsers({
    required String query,
    required String searchField,
    String? role, // عشان يفلتر النتايج (مثلاً دكاترة بس)
  }) async {
    try {
      QuerySnapshot snapshot;

      if (searchField == 'employee_id') {
        // البحث بالرقم الوظيفي (مطابقة تامة)
        var queryRef = _firestore
            .collection('users')
            .where('employee_id', isEqualTo: query);
            
        if (role != null) {
          queryRef = queryRef.where('role', isEqualTo: role);
        }
        snapshot = await queryRef.get();

      } else {
        // البحث بالاسم (Prefix Search)
        var queryRef = _firestore
            .collection('users')
            .where('username', isGreaterThanOrEqualTo: query)
            .where('username', isLessThanOrEqualTo: '$query\uf8ff');
            
        if (role != null) {
          queryRef = queryRef.where('role', isEqualTo: role);
        }
        snapshot = await queryRef.get();
      }

      final users = snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();

      return Right(users);
    } on FirebaseException catch (e) {
      return Left("خطأ في البحث: ${e.message}");
    } catch (e) {
      return Left("حدث خطأ غير متوقع: ${e.toString()}");
    }
  }
}