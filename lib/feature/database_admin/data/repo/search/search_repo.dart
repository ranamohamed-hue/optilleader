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
      if (searchField == 'employee_id') {
        // 1. البحث بالرقم الوظيفي (مطابقة تامة)
        var queryRef = _firestore
            .collection('users')
            .where('employeeId', isEqualTo: query); // تأكد أن اسم الحقل في الفايرستور employeeId أو employee_id
            
        if (role != null) {
          queryRef = queryRef.where('role', isEqualTo: role);
        }
        final snapshot = await queryRef.get();
        final users = snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
        return Right(users);

      } else {
        // 2. البحث بالاسم (Prefix Search)
        
        // أ. بحث في حقل الاسم العربي
        var arabicQueryRef = _firestore
            .collection('users')
            .where('nameAr', isGreaterThanOrEqualTo: query)
            .where('nameAr', isLessThanOrEqualTo: '$query\uf8ff');
            
        if (role != null) {
          arabicQueryRef = arabicQueryRef.where('role', isEqualTo: role);
        }
        final arabicSnapshot = await arabicQueryRef.get();

        // ب. بحث في حقل الاسم الإنجليزي
        var englishQueryRef = _firestore
            .collection('users')
            .where('nameEn', isGreaterThanOrEqualTo: query)
            .where('nameEn', isLessThanOrEqualTo: '$query\uf8ff');
            
        if (role != null) {
          englishQueryRef = englishQueryRef.where('role', isEqualTo: role);
        }
        final englishSnapshot = await englishQueryRef.get();

        // ج. دمج النتائج وإزالة التكرار (باستخدام UID كمعرف فريد)
        final Map<String, UserModel> usersMap = {};

        for (var doc in arabicSnapshot.docs) {
          final user = UserModel.fromFirestore(doc);
          usersMap[user.uid] = user; // إضافة النتائج العربية
        }
        for (var doc in englishSnapshot.docs) {
          final user = UserModel.fromFirestore(doc);
          usersMap[user.uid] = user; // إضافة النتائج الإنجليزية (لو مكرر هيستبدله)
        }

        final users = usersMap.values.toList();
        return Right(users);
      }
    } on FirebaseException catch (e) {
      // ⚠️ ملاحظة هامة جداً: إذا ظهر لك خطأ يطلب منك إنشاء (Index) في الفايرستور،
      // اذهب للخطأ في الـ Console واضغط على الرابط الذي سيظهر لإنشائه تلقائياً.
      return Left("خطأ في البحث: ${e.message}");
    } catch (e) {
      return Left("حدث خطأ غير متوقع: ${e.toString()}");
    }
  }
}